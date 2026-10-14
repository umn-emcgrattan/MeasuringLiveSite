# ============================================================
# vfi.jl
#
# Value function iteration for a stochastic growth model.
#
# Two versions are included:
#   1. continuous log z with Gaussian quadrature
#   2. finite-state Markov chain for log z
#
# The code is deliberately explicit. Choices are found by grid search,
# interpolation is written out, and only standard libraries are used.
# ============================================================

using LinearAlgebra
using Printf

include(joinpath(@__DIR__, "..", "..", "..", "Appendix", "src", "quadrature.jl"))
include(joinpath(@__DIR__, "..", "..", "..", "Appendix", "src", "autoregressive.jl"))
include(joinpath(@__DIR__, "..", "..", "..", "Appendix", "src", "root_finding.jl"))

struct GrowthModel
    beta::Float64
    theta::Float64
    delta::Float64
    gamma_z::Float64
    gamma_n::Float64
    rho::Float64
    sigma_epsilon::Float64
    productivity_exponent::Float64
    labor_weight::Float64
    g_ss::Float64
    fixed_labor::Union{Nothing, Float64}
end

function default_growth_model(; g_ss::Real=0.0)
    GrowthModel(
        0.95,  # beta
        0.40,  # capital share
        0.05,  # depreciation
        0.00,  # technology growth
        0.00,  # population growth
        0.82,  # persistence of log z
        0.013, # innovation standard deviation
        0.60,  # labor-augmenting z enters output with exponent 1-theta
        2.50,  # weight on leisure
        Float64(g_ss), # placeholder stationary government spending; calibrate later
        nothing,
    )
end

function check_growth_model()
    GrowthModel(
        0.96,  # beta
        0.36,  # capital share
        1.00,  # full depreciation
        0.00,  # no technology growth
        0.00,  # no population growth
        0.90,  # persistence of log z
        0.02,  # innovation standard deviation
        1.00,  # check economy has output z*k^theta
        0.00,  # no labor/leisure term
        0.00,  # no government spending in the analytical check economy
        1.00,  # inelastic labor
    )
end

production(k, logz, h, model::GrowthModel) =
    exp(model.productivity_exponent * logz) * k^model.theta * h^(1.0 - model.theta)

production_k(k, logz, h, model::GrowthModel) =
    model.theta * exp(model.productivity_exponent * logz) * k^(model.theta - 1.0) * h^(1.0 - model.theta)

production_h(k, logz, h, model::GrowthModel) =
    (1.0 - model.theta) * exp(model.productivity_exponent * logz) * k^model.theta * h^(-model.theta)

function utility(c, h, model::GrowthModel)
    c <= 0.0 && return -Inf
    if model.fixed_labor === nothing
        h <= 0.0 || h >= 1.0 ? -Inf : log(c) + model.labor_weight * log(1.0 - h)
    else
        log(c)
    end
end

function make_grid(lo, hi, n)
    n >= 2 || error("grid needs at least two points")
    collect(range(lo, hi; length=n))
end

function make_capital_grid(lo, hi, n; log_grid::Bool = false)
    lo > 0.0 || error("capital grid lower bound must be positive")
    hi > lo || error("capital grid upper bound must exceed lower bound")
    if log_grid
        return exp.(range(log(lo), log(hi); length=n))
    end
    return make_grid(lo, hi, n)
end

function stationary_growth(model::GrowthModel)
    return (1.0 + model.gamma_n) * (1.0 + model.gamma_z)
end

function effective_discount(model::GrowthModel)
    return model.beta * (1.0 + model.gamma_n)
end

function steady_state(model::GrowthModel)
    growth = stationary_growth(model)
    beta_hat = effective_discount(model)
    beta_hat < 1.0 || error("beta*(1+gamma_n) must be less than one.")

    marginal_product = growth / beta_hat - (1.0 - model.delta)
    marginal_product > 0.0 || error("parameters imply a nonpositive steady-state marginal product.")
    zeta = (marginal_product / model.theta)^(1.0 / (model.theta - 1.0))

    if model.fixed_labor === nothing
        q = growth - (1.0 - model.delta)
        numerator = (1.0 - model.theta) * zeta^model.theta + model.labor_weight * model.g_ss
        denominator =
            model.labor_weight * (zeta^model.theta - q * zeta) +
            (1.0 - model.theta) * zeta^model.theta
        h = numerator / denominator
    else
        h = model.fixed_labor
    end

    0.0 < h < 1.0 || model.fixed_labor == 1.0 || error("steady-state hours must lie in (0,1).")
    k = zeta * h
    y = k^model.theta * h^(1.0 - model.theta)
    investment = (growth - (1.0 - model.delta)) * k
    c = y - investment - model.g_ss
    c > 0.0 || error("parameters imply nonpositive steady-state consumption.")

    return (; k, h, y, c, investment, zeta, growth, beta_hat)
end

function steady_state_capital(model::GrowthModel; h=nothing, logz=0.0)
    logz == 0.0 || error("steady_state_capital is defined for the mean productivity state logz=0.")
    h === nothing || @warn "The h keyword is ignored; hours are computed from the steady-state conditions."
    return steady_state(model).k
end

function labor_choice(k, logz, k_next, model::GrowthModel; xtol=1e-12, ftol=1e-12)
    if model.fixed_labor !== nothing
        return model.fixed_labor
    end

    scale = k^model.theta * exp(model.productivity_exponent * logz)
    total_nonconsumption = stationary_growth(model) * k_next - (1.0 - model.delta) * k + model.g_ss
    chi = total_nonconsumption / scale
    chi < 1.0 || return nothing

    residual(h) =
        1.0 - h -
        model.labor_weight / (1.0 - model.theta) * (h - chi * h^model.theta)

    lower = eps(Float64)
    upper = 1.0 - eps(Float64)
    result = bisection(residual, lower, upper; xtol, ftol, maxit=200)
    result.converged || return nothing
    return result.root
end

function allocation_given_choice(k, logz, k_next, model::GrowthModel)
    h = labor_choice(k, logz, k_next, model)
    h === nothing && return nothing
    y = production(k, logz, h, model)
    investment = stationary_growth(model) * k_next - (1.0 - model.delta) * k
    c = y - investment - model.g_ss
    isfinite(utility(c, h, model)) || return nothing
    return (; c, h, investment, y)
end

function bracket_index(grid, x)
    n = length(grid)
    if x <= grid[1]
        return 1, 1, 0.0
    elseif x >= grid[n]
        return n, n, 0.0
    end

    hi = searchsortedfirst(grid, x)
    lo = hi - 1
    weight_hi = (x - grid[lo]) / (grid[hi] - grid[lo])
    return lo, hi, weight_hi
end

function linear_interpolate(grid, values, x)
    lo, hi, weight_hi = bracket_index(grid, x)
    lo == hi && return values[lo]
    return (1.0 - weight_hi) * values[lo] + weight_hi * values[hi]
end

function bilinear_interpolate(k_grid, z_grid, V, k, logz)
    k_lo, k_hi, wk = bracket_index(k_grid, k)
    z_lo, z_hi, wz = bracket_index(z_grid, logz)

    if k_lo == k_hi && z_lo == z_hi
        return V[k_lo, z_lo]
    elseif k_lo == k_hi
        return (1.0 - wz) * V[k_lo, z_lo] + wz * V[k_lo, z_hi]
    elseif z_lo == z_hi
        return (1.0 - wk) * V[k_lo, z_lo] + wk * V[k_hi, z_lo]
    end

    v_ll = V[k_lo, z_lo]
    v_hl = V[k_hi, z_lo]
    v_lh = V[k_lo, z_hi]
    v_hh = V[k_hi, z_hi]

    return (
        (1.0 - wk) * (1.0 - wz) * v_ll +
        wk * (1.0 - wz) * v_hl +
        (1.0 - wk) * wz * v_lh +
        wk * wz * v_hh
    )
end

function normal_quadrature(n, sigma)
    nodes, weights = gauss_legendre_general(n)
    lo = -4.0 * sigma
    hi = 4.0 * sigma
    eps = [map_to_interval(x, lo, hi) for x in nodes]

    unscaled_weights = zeros(n)
    for i in 1:n
        density = exp(-0.5 * (eps[i] / sigma)^2) / (sigma * sqrt(2.0 * pi))
        unscaled_weights[i] = 0.5 * (hi - lo) * weights[i] * density
    end

    # Renormalize because the finite interval cuts off tiny normal tails.
    return eps, unscaled_weights ./ sum(unscaled_weights)
end

function expected_value_continuous(k_next, logz, V, k_grid, z_grid, eps_nodes, eps_weights, model::GrowthModel)
    val = 0.0
    for i in eachindex(eps_nodes)
        logz_next = model.rho * logz + eps_nodes[i]
        val += eps_weights[i] * bilinear_interpolate(k_grid, z_grid, V, k_next, logz_next)
    end
    return val
end

function bellman_rhs(k, logz, k_next, continuation, model::GrowthModel)
    allocation = allocation_given_choice(k, logz, k_next, model)
    allocation === nothing && return -Inf, nothing
    value = utility(allocation.c, allocation.h, model) + effective_discount(model) * continuation
    return value, allocation
end

function analytic_check_policy_k(k, logz, model::GrowthModel)
    return model.beta * model.theta * exp(logz) * k^model.theta
end

function analytic_check_policy_c(k, logz, model::GrowthModel)
    return (1.0 - model.beta * model.theta) * exp(logz) * k^model.theta
end

function policy_at(solution, k, logz)
    c = bilinear_interpolate(solution.k_grid, solution.z_grid, solution.policy_c, k, logz)
    h = bilinear_interpolate(solution.k_grid, solution.z_grid, solution.policy_h, k, logz)
    kp = bilinear_interpolate(solution.k_grid, solution.z_grid, solution.policy_k, k, logz)
    return c, h, kp
end

function policy_at_markov(solution, k, iz)
    c = linear_interpolate(solution.k_grid, solution.policy_c[:, iz], k)
    h = linear_interpolate(solution.k_grid, solution.policy_h[:, iz], k)
    kp = linear_interpolate(solution.k_grid, solution.policy_k[:, iz], k)
    return c, h, kp
end

function labor_foc_residual(k, logz, c, h, model::GrowthModel)
    model.fixed_labor !== nothing && return missing
    return production_h(k, logz, h, model) / c - model.labor_weight / (1.0 - h)
end

function euler_residual_continuous(solution, ik, iz)
    model = solution.model
    growth = stationary_growth(model)
    k = solution.k_grid[ik]
    logz = solution.z_grid[iz]
    c = solution.policy_c[ik, iz]
    h = solution.policy_h[ik, iz]
    kp = solution.policy_k[ik, iz]

    expected_marginal_value = 0.0
    for i in eachindex(solution.eps_nodes)
        logz_next = model.rho * logz + solution.eps_nodes[i]
        c_next, h_next, _ = policy_at(solution, kp, logz_next)
        expected_marginal_value += solution.eps_weights[i] *
            (production_k(kp, logz_next, h_next, model) + 1.0 - model.delta) / c_next
    end

    return growth / c - effective_discount(model) * expected_marginal_value
end

function euler_residual_markov(solution, ik, iz)
    model = solution.model
    growth = stationary_growth(model)
    c = solution.policy_c[ik, iz]
    kp = solution.policy_k[ik, iz]

    expected_marginal_value = 0.0
    for iz_next in axes(solution.P, 2)
        logz_next = solution.z_grid[iz_next]
        c_next, h_next, _ = policy_at_markov(solution, kp, iz_next)
        expected_marginal_value += solution.P[iz, iz_next] *
            (production_k(kp, logz_next, h_next, model) + 1.0 - model.delta) / c_next
    end

    return growth / c - effective_discount(model) * expected_marginal_value
end

function foc_residuals_continuous(solution)
    nk = length(solution.k_grid)
    nz = length(solution.z_grid)
    euler = zeros(nk, nz)
    labor = Matrix{Union{Missing, Float64}}(missing, nk, nz)

    for iz in 1:nz
        logz = solution.z_grid[iz]
        for ik in 1:nk
            k = solution.k_grid[ik]
            c = solution.policy_c[ik, iz]
            h = solution.policy_h[ik, iz]
            euler[ik, iz] = euler_residual_continuous(solution, ik, iz)
            labor[ik, iz] = labor_foc_residual(k, logz, c, h, solution.model)
        end
    end

    return (; euler, labor)
end

function foc_residuals_markov(solution)
    nk = length(solution.k_grid)
    nz = length(solution.z_grid)
    euler = zeros(nk, nz)
    labor = Matrix{Union{Missing, Float64}}(missing, nk, nz)

    for iz in 1:nz
        logz = solution.z_grid[iz]
        for ik in 1:nk
            k = solution.k_grid[ik]
            c = solution.policy_c[ik, iz]
            h = solution.policy_h[ik, iz]
            euler[ik, iz] = euler_residual_markov(solution, ik, iz)
            labor[ik, iz] = labor_foc_residual(k, logz, c, h, solution.model)
        end
    end

    return (; euler, labor)
end

function print_foc_residual_summary(residuals; label = "FOC residuals")
    finite_labor = collect(skipmissing(vec(residuals.labor)))
    println(label)
    @printf("max |Euler residual|   %.8e\n", maximum(abs.(residuals.euler)))
    if !isempty(finite_labor)
        @printf("max |labor residual|   %.8e\n", maximum(abs.(finite_labor)))
    end
end

function solve_vfi_continuous_z(;
    model::GrowthModel = default_growth_model(),
    nk::Int = 45,
    nz::Int = 9,
    nk_choice::Int = nk,
    nquad::Int = 7,
    k_min_factor::Float64 = 0.65,
    k_max_factor::Float64 = 1.35,
    z_width::Float64 = 3.0,
    log_k_grid::Bool = false,
    tol::Float64 = 1e-5,
    maxit::Int = 500,
    print_every::Int = 10,
)
    k_ss = steady_state_capital(model)
    k_grid = make_capital_grid(k_min_factor * k_ss, k_max_factor * k_ss, nk; log_grid = log_k_grid)
    k_choice_grid = make_capital_grid(k_grid[1], k_grid[end], nk_choice; log_grid = log_k_grid)
    sigma_z = ar1_stationary_std(model.rho, model.sigma_epsilon)
    z_grid = make_grid(-z_width * sigma_z, z_width * sigma_z, nz)
    eps_nodes, eps_weights = normal_quadrature(nquad, model.sigma_epsilon)

    V = zeros(nk, nz)
    Vnew = similar(V)
    continuation_values = zeros(nk_choice, nz)
    policy_k = zeros(nk, nz)
    policy_h = zeros(nk, nz)
    policy_c = zeros(nk, nz)

    distance = Inf
    iter = 0
    while iter < maxit && distance > tol
        iter += 1
        for iz in 1:nz
            logz = z_grid[iz]
            for ik_next in 1:nk_choice
                continuation_values[ik_next, iz] = expected_value_continuous(
                    k_choice_grid[ik_next],
                    logz,
                    V,
                    k_grid,
                    z_grid,
                    eps_nodes,
                    eps_weights,
                    model,
                )
            end
        end

        for iz in 1:nz
            logz = z_grid[iz]
            for ik in 1:nk
                k = k_grid[ik]
                best_value = -Inf
                best_k = k_grid[1]
                best_h = model.fixed_labor === nothing ? NaN : model.fixed_labor
                best_c = 0.0

                for ik_next in 1:nk_choice
                    k_next = k_choice_grid[ik_next]
                    continuation = continuation_values[ik_next, iz]
                    val, allocation = bellman_rhs(k, logz, k_next, continuation, model)
                    if val > best_value
                        best_value = val
                        best_k = k_next
                        best_h = allocation.h
                        best_c = allocation.c
                    end
                end

                Vnew[ik, iz] = best_value
                policy_k[ik, iz] = best_k
                policy_h[ik, iz] = best_h
                policy_c[ik, iz] = best_c
            end
        end

        distance = maximum(abs.(Vnew .- V))
        V, Vnew = Vnew, V
        if print_every > 0 && (iter == 1 || iter % print_every == 0 || distance <= tol)
            @printf("continuous z VFI iter %4d, distance = %.8e\n", iter, distance)
        end
    end

    return (; model, k_grid, k_choice_grid, z_grid, eps_nodes, eps_weights, V, policy_k, policy_h, policy_c, distance, iter)
end

function expected_value_markov(ik_next, iz, V, P)
    val = 0.0
    for iz_next in axes(P, 2)
        val += P[iz, iz_next] * V[ik_next, iz_next]
    end
    return val
end

function expected_value_markov(k_next, iz, V, P, k_grid)
    val = 0.0
    for iz_next in axes(P, 2)
        val += P[iz, iz_next] * linear_interpolate(k_grid, V[:, iz_next], k_next)
    end
    return val
end

function solve_vfi_markov_z(;
    model::GrowthModel = default_growth_model(),
    nk::Int = 45,
    nz::Int = 9,
    nk_choice::Int = nk,
    k_min_factor::Float64 = 0.65,
    k_max_factor::Float64 = 1.35,
    z_width::Float64 = 3.0,
    log_k_grid::Bool = false,
    tol::Float64 = 1e-5,
    maxit::Int = 500,
    print_every::Int = 10,
)
    k_ss = steady_state_capital(model)
    k_grid = make_capital_grid(k_min_factor * k_ss, k_max_factor * k_ss, nk; log_grid = log_k_grid)
    k_choice_grid = make_capital_grid(k_grid[1], k_grid[end], nk_choice; log_grid = log_k_grid)
    z_grid, P = tauchen_ar1(model.rho, model.sigma_epsilon, nz; m=z_width)

    V = zeros(nk, nz)
    Vnew = similar(V)
    continuation_values = zeros(nk_choice, nz)
    policy_k_index = ones(Int, nk, nz)
    policy_k = zeros(nk, nz)
    policy_h = zeros(nk, nz)
    policy_c = zeros(nk, nz)

    distance = Inf
    iter = 0
    while iter < maxit && distance > tol
        iter += 1
        for iz in 1:nz
            for ik_next in 1:nk_choice
                continuation_values[ik_next, iz] = expected_value_markov(k_choice_grid[ik_next], iz, V, P, k_grid)
            end
        end

        for iz in 1:nz
            logz = z_grid[iz]
            for ik in 1:nk
                k = k_grid[ik]
                best_value = -Inf
                best_ik_next = 1
                best_h = model.fixed_labor === nothing ? NaN : model.fixed_labor
                best_c = 0.0

                for ik_next in 1:nk_choice
                    k_next = k_choice_grid[ik_next]
                    continuation = continuation_values[ik_next, iz]
                    val, allocation = bellman_rhs(k, logz, k_next, continuation, model)
                    if val > best_value
                        best_value = val
                        best_ik_next = ik_next
                        best_h = allocation.h
                        best_c = allocation.c
                    end
                end

                Vnew[ik, iz] = best_value
                policy_k_index[ik, iz] = best_ik_next
                policy_k[ik, iz] = k_choice_grid[best_ik_next]
                policy_h[ik, iz] = best_h
                policy_c[ik, iz] = best_c
            end
        end

        distance = maximum(abs.(Vnew .- V))
        V, Vnew = Vnew, V
        if print_every > 0 && (iter == 1 || iter % print_every == 0 || distance <= tol)
            @printf("markov z VFI iter %4d, distance = %.8e\n", iter, distance)
        end
    end

    return (; model, k_grid, k_choice_grid, z_grid, P, V, policy_k_index, policy_k, policy_h, policy_c, distance, iter)
end

function print_vfi_summary(solution; label="VFI solution")
    mid_k = cld(length(solution.k_grid), 2)
    mid_z = cld(length(solution.z_grid), 2)

    println(label)
    @printf("iterations       %8d\n", solution.iter)
    @printf("final distance   %12.6e\n", solution.distance)
    @printf("middle k         %12.6f\n", solution.k_grid[mid_k])
    @printf("middle log z     %12.6f\n", solution.z_grid[mid_z])
    @printf("policy k'        %12.6f\n", solution.policy_k[mid_k, mid_z])
    @printf("policy h         %12.6f\n", solution.policy_h[mid_k, mid_z])
    @printf("policy c         %12.6f\n", solution.policy_c[mid_k, mid_z])
end

function print_policy_slice(solution; iz=cld(length(solution.z_grid), 2))
    @printf("Policy slice at log z = %.6f\n", solution.z_grid[iz])
    println("   i              k              k'              h              c")
    for ik in eachindex(solution.k_grid)
        @printf(
            "%4d   %12.6f   %12.6f   %12.6f   %12.6f\n",
            ik,
            solution.k_grid[ik],
            solution.policy_k[ik, iz],
            solution.policy_h[ik, iz],
            solution.policy_c[ik, iz],
        )
    end
end
