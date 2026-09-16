# ============================================================
# riccati.jl
#
# Direct iteration on the discrete-time Riccati equation for
# a linear-quadratic maximization problem:
#
#   max sum beta^t (X_t' Q X_t + u_t' R u_t + 2 X_t' W u_t)
#   s.t. X_{t+1} = A X_t + B u_t + C epsilon_{t+1}
#
# The signs follow the maximization convention used in the lecture.
# Thus Q and R are typically negative definite near a maximum.
#
# Only Julia standard libraries are used.
# ============================================================

using LinearAlgebra
using Printf

struct LQProblem
    A::Matrix{Float64}
    B::Matrix{Float64}
    C::Matrix{Float64}
    Q::Matrix{Float64}
    R::Matrix{Float64}
    W::Matrix{Float64}
    beta::Float64
end

struct RiccatiSolution
    P::Matrix{Float64}
    F::Matrix{Float64}
    F_tilde::Matrix{Float64}
    A_tilde::Matrix{Float64}
    B_tilde::Matrix{Float64}
    Q_tilde::Matrix{Float64}
    distance_P::Float64
    distance_F::Float64
    iter::Int
    converged::Bool
end

function check_lq_dimensions(problem::LQProblem)
    A, B, C, Q, R, W = problem.A, problem.B, problem.C, problem.Q, problem.R, problem.W
    m = size(A, 1)
    n = size(B, 2)
    s = size(C, 2)

    size(A) == (m, m) || error("A must be square.")
    size(B) == (m, n) || error("B must have the same number of rows as A.")
    size(C) == (m, s) || error("C must have the same number of rows as A.")
    size(Q) == (m, m) || error("Q must be m by m.")
    size(R) == (n, n) || error("R must be n by n.")
    size(W) == (m, n) || error("W must be m by n.")
    0.0 < problem.beta <= 1.0 || error("beta should be in (0,1].")

    return m, n
end

function sympart(A)
    return 0.5 * (A + A')
end

function default_initial_P(problem::LQProblem)
    m, _ = check_lq_dimensions(problem)
    return zeros(m, m)
end

function lq_tilde_matrices(problem::LQProblem)
    check_lq_dimensions(problem)
    A, B, Q, R, W, beta = problem.A, problem.B, problem.Q, problem.R, problem.W, problem.beta

    Rinv_Wprime = R \ W'
    A_tilde = sqrt(beta) * (A - B * Rinv_Wprime)
    B_tilde = sqrt(beta) * B
    Q_tilde = Q - W * Rinv_Wprime

    return A_tilde, B_tilde, sympart(Q_tilde)
end

function riccati_gain(P, A_tilde, B_tilde, R)
    return (R + B_tilde' * P * B_tilde) \ (B_tilde' * P * A_tilde)
end

function riccati_step(P, A_tilde, B_tilde, Q_tilde, R)
    F_tilde = riccati_gain(P, A_tilde, B_tilde, R)
    P_next =
        Q_tilde +
        A_tilde' * P * A_tilde -
        A_tilde' * P * B_tilde * F_tilde
    return sympart(P_next), F_tilde
end

function relative_distance(new, old)
    denom = max(norm(old), 1.0)
    return norm(new - old) / denom
end

function solve_riccati_iteration(
    problem::LQProblem;
    P0 = default_initial_P(problem),
    tol_P::Float64 = 1e-10,
    tol_F::Float64 = 1e-10,
    maxit::Int = 1000,
    print_every::Int = 10,
)
    A_tilde, B_tilde, Q_tilde = lq_tilde_matrices(problem)
    P = sympart(Matrix{Float64}(P0))
    F_tilde = riccati_gain(P, A_tilde, B_tilde, problem.R)
    distance_P = Inf
    distance_F = Inf
    converged = false
    iter = 0

    while iter < maxit
        iter += 1
        P_next, _ = riccati_step(P, A_tilde, B_tilde, Q_tilde, problem.R)
        F_next = riccati_gain(P_next, A_tilde, B_tilde, problem.R)

        distance_P = relative_distance(P_next, P)
        distance_F = relative_distance(F_next, F_tilde)

        if print_every > 0 && (iter == 1 || iter % print_every == 0)
            @printf("Riccati iter %4d, distance_P = %.8e, distance_F = %.8e\n", iter, distance_P, distance_F)
        end

        P = P_next
        F_tilde = F_next

        if distance_P < tol_P && distance_F < tol_F
            converged = true
            print_every > 0 && @printf("Riccati iter %4d, distance_P = %.8e, distance_F = %.8e\n", iter, distance_P, distance_F)
            break
        end
    end

    F = F_tilde + problem.R \ problem.W'
    return RiccatiSolution(P, F, F_tilde, A_tilde, B_tilde, Q_tilde, distance_P, distance_F, iter, converged)
end

function closed_loop_matrix(problem::LQProblem, solution::RiccatiSolution)
    return problem.A - problem.B * solution.F
end

function closed_loop_eigenvalues(problem::LQProblem, solution::RiccatiSolution)
    return eigvals(closed_loop_matrix(problem, solution))
end

function simulate_lq(problem::LQProblem, solution::RiccatiSolution, X0, shocks)
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

function print_lq_problem(problem::LQProblem)
    m, n = check_lq_dimensions(problem)
    s = size(problem.C, 2)
    println("LQ problem")
    @printf("state dimension       %4d\n", m)
    @printf("control dimension     %4d\n", n)
    @printf("shock dimension       %4d\n", s)
    @printf("beta              %8.4f\n", problem.beta)
end

function print_riccati_solution(problem::LQProblem, solution::RiccatiSolution)
    println("Riccati solution")
    @printf("converged             %s\n", string(solution.converged))
    @printf("iterations        %8d\n", solution.iter)
    @printf("distance_P        %.8e\n", solution.distance_P)
    @printf("distance_F        %.8e\n", solution.distance_F)
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

function simple_scalar_lq_problem()
    A = [1.05;;]
    B = [1.0;;]
    C = [0.10;;]
    Q = [-1.0;;]
    R = [-0.20;;]
    W = [0.0;;]
    beta = 0.95
    return LQProblem(A, B, C, Q, R, W, beta)
end
