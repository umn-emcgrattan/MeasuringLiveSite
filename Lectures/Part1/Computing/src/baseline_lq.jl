# ============================================================
# baseline_lq.jl
#
# Map the stationary baseline growth model into the generic LQ
# problem solved by riccati.jl and vaughan.jl. States and controls
# are log deviations from the deterministic steady state:
#
#   X = [log(k/k_ss), log(z)]
#   u = [log(k'/k_ss), log(h/h_ss)].
# ============================================================

include(joinpath(@__DIR__, "vfi.jl"))
include(joinpath(@__DIR__, "vaughan.jl"))

function baseline_log_return(X, u, model::GrowthModel, ss=steady_state(model))
    k = ss.k * exp(X[1])
    logz = X[2]
    k_next = ss.k * exp(u[1])
    h = ss.h * exp(u[2])
    c =
        production(k, logz, h, model) +
        (1.0 - model.delta) * k -
        stationary_growth(model) * k_next -
        model.g_ss
    return utility(c, h, model)
end

function finite_difference_hessian(f, x0; relative_step=1e-5)
    n = length(x0)
    H = zeros(n, n)
    f0 = f(x0)
    steps = [relative_step * max(1.0, abs(x0[i])) for i in 1:n]

    for i in 1:n
        hi = steps[i]
        xplus = copy(x0)
        xminus = copy(x0)
        xplus[i] += hi
        xminus[i] -= hi
        H[i, i] = (f(xplus) - 2.0 * f0 + f(xminus)) / hi^2

        for j in (i + 1):n
            hj = steps[j]
            xpp = copy(x0)
            xpm = copy(x0)
            xmp = copy(x0)
            xmm = copy(x0)
            xpp[i] += hi; xpp[j] += hj
            xpm[i] += hi; xpm[j] -= hj
            xmp[i] -= hi; xmp[j] += hj
            xmm[i] -= hi; xmm[j] -= hj
            Hij = (f(xpp) - f(xpm) - f(xmp) + f(xmm)) / (4.0 * hi * hj)
            H[i, j] = Hij
            H[j, i] = Hij
        end
    end

    return H
end

function baseline_lq_problem(model::GrowthModel=default_growth_model(); derivative_step=1e-5)
    ss = steady_state(model)
    objective(v) = baseline_log_return(view(v, 1:2), view(v, 3:4), model, ss)
    H = finite_difference_hessian(objective, zeros(4); relative_step=derivative_step)

    # The Taylor approximation is multiplied by two. This leaves its
    # maximizer unchanged and matches the convention X'QX + u'Ru + 2X'Wu.
    Q = Matrix(H[1:2, 1:2])
    R = Matrix(H[3:4, 3:4])
    W = Matrix(H[1:2, 3:4])

    A = [0.0 0.0; 0.0 model.rho]
    B = [1.0 0.0; 0.0 0.0]
    C = reshape([0.0, 1.0], 2, 1)
    problem = LQProblem(A, B, C, Q, R, W, effective_discount(model))
    return (; problem, ss, H)
end

function solve_baseline_lq(model::GrowthModel=default_growth_model(); derivative_step=1e-5)
    approximation = baseline_lq_problem(model; derivative_step)
    riccati = solve_riccati_iteration(approximation.problem; print_every=0)
    vaughan = solve_vaughan(approximation.problem)
    return (; approximation..., riccati, vaughan)
end

function lq_policy_at(k, logz, model::GrowthModel, ss, solution)
    X = [log(k / ss.k), logz]
    u = -solution.F * X
    k_next = ss.k * exp(u[1])
    h = ss.h * exp(u[2])
    y = production(k, logz, h, model)
    investment = stationary_growth(model) * k_next - (1.0 - model.delta) * k
    c = y - investment - model.g_ss
    return (; c, h, k_next, investment, y)
end

function compare_lq_solutions(result)
    return (
        P_gap=norm(result.riccati.P - result.vaughan.P),
        F_gap=norm(result.riccati.F - result.vaughan.F),
        vaughan_residual=result.vaughan.residual,
    )
end
