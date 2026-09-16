# ============================================================
# vaughan.jl
#
# Eigenvalue method for the same linear-quadratic maximization
# problem solved by direct Riccati iteration in riccati.jl.
#
# Julia computes generalized eigenvalues mu from:
#
#   H2 v = mu H1 v.
#
# With H1 multiplying date t+1 variables and H2 multiplying
# date t variables, stable roots satisfy abs(mu) < 1.
#
# Only Julia standard libraries are used.
# ============================================================

include(joinpath(@__DIR__, "riccati.jl"))

struct VaughanSolution
    P::Matrix{Float64}
    F::Matrix{Float64}
    F_tilde::Matrix{Float64}
    A_tilde::Matrix{Float64}
    B_tilde::Matrix{Float64}
    Q_tilde::Matrix{Float64}
    H1::Matrix{Float64}
    H2::Matrix{Float64}
    roots::Vector{ComplexF64}
    stable_indices::Vector{Int}
    residual::Float64
end

function vaughan_matrices(problem::LQProblem)
    A_tilde, B_tilde, Q_tilde = lq_tilde_matrices(problem)
    m, _ = check_lq_dimensions(problem)

    H1 = [
        Matrix{Float64}(I, m, m)       B_tilde * (problem.R \ B_tilde')
        zeros(m, m)                    A_tilde'
    ]

    H2 = [
        A_tilde                        zeros(m, m)
        -Q_tilde                       Matrix{Float64}(I, m, m)
    ]

    return H1, H2, A_tilde, B_tilde, Q_tilde
end

function stable_root_indices(roots; tol::Float64 = 1e-8)
    return findall(abs.(roots) .< 1.0 - tol)
end

function real_if_close(A; imag_tol::Float64 = 1e-8)
    maximum(abs.(imag.(A))) <= imag_tol || error("Stable eigenspace is not numerically real.")
    return real.(A)
end

function solve_vaughan(
    problem::LQProblem;
    root_tol::Float64 = 1e-8,
    imag_tol::Float64 = 1e-8,
)
    H1, H2, A_tilde, B_tilde, Q_tilde = vaughan_matrices(problem)
    m, _ = check_lq_dimensions(problem)

    ge = eigen(H2, H1)
    roots = ComplexF64.(ge.values)
    stable_indices = stable_root_indices(roots; tol = root_tol)
    length(stable_indices) == m || error("Expected $(m) stable roots, found $(length(stable_indices)).")

    V = ge.vectors[:, stable_indices]
    V11 = V[1:m, :]
    V21 = V[(m + 1):(2m), :]

    P = sympart(real_if_close(V21 / V11; imag_tol = imag_tol))
    F_tilde = riccati_gain(P, A_tilde, B_tilde, problem.R)
    F = F_tilde + problem.R \ problem.W'

    residual =
        norm(
            P -
            (
                Q_tilde +
                A_tilde' * P * A_tilde -
                A_tilde' * P * B_tilde *
                ((problem.R + B_tilde' * P * B_tilde) \ (B_tilde' * P * A_tilde))
            )
        )

    return VaughanSolution(
        P,
        F,
        F_tilde,
        A_tilde,
        B_tilde,
        Q_tilde,
        H1,
        H2,
        roots,
        stable_indices,
        residual,
    )
end

function closed_loop_matrix(problem::LQProblem, solution::VaughanSolution)
    return problem.A - problem.B * solution.F
end

function closed_loop_eigenvalues(problem::LQProblem, solution::VaughanSolution)
    return eigvals(closed_loop_matrix(problem, solution))
end

function simulate_lq(problem::LQProblem, solution::VaughanSolution, X0, shocks)
    Acl = closed_loop_matrix(problem, solution)
    T = size(shocks, 2)
    m = length(X0)
    n = size(problem.B, 2)

    X = zeros(m, T + 1)
    U = zeros(n, T)
    X[:, 1] = X0

    for t in 1:T
        U[:, t] = -solution.F * X[:, t]
        X[:, t + 1] = Acl * X[:, t] + problem.C * shocks[:, t]
    end

    return X, U
end

function print_vaughan_solution(problem::LQProblem, solution::VaughanSolution)
    println("Vaughan generalized-eigenvalue solution")
    @printf("stable roots          %4d\n", length(solution.stable_indices))
    @printf("Riccati residual  %.8e\n", solution.residual)
    println()
    println("generalized eigenvalues from H2 v = mu H1 v")
    show(stdout, "text/plain", solution.roots)
    println()
    println()
    println("P")
    show(stdout, "text/plain", solution.P)
    println()
    println()
    println("F, with u = -F X")
    show(stdout, "text/plain", solution.F)
    println()
    println()
    println("eigenvalues of A - B F")
    show(stdout, "text/plain", closed_loop_eigenvalues(problem, solution))
    println()
end
