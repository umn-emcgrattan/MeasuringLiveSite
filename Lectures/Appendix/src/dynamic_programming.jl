# ============================================================
# dynamic_programming.jl
#
# Steady-state conditions for an interior deterministic dynamic
# programming problem:
#
#   V(x) = max_u { r(x,u) + beta*V(g(x,u)) }.
#
# Students supply r_x, r_u, g, g_x, and g_u. Gradients are
# column vectors and the derivatives of g are Jacobian matrices.
# ============================================================

if !isdefined(@__MODULE__, :newton_system)
    include(joinpath(@__DIR__, "root_finding.jl"))
end

function steady_state_residual(
    z;
    beta,
    nx::Int,
    nu::Int,
    r_x,
    r_u,
    g,
    g_x,
    g_u,
)
    length(z) == 2nx + nu || error("z must contain x, u, and lambda.")
    0 < beta < 1 || error("beta must lie between zero and one.")

    x = z[1:nx]
    u = z[(nx + 1):(nx + nu)]
    lambda = z[(nx + nu + 1):(2nx + nu)]

    stationarity = g(x, u) - x
    control_foc = r_u(x, u) + beta * transpose(g_u(x, u)) * lambda
    envelope = r_x(x, u) + beta * transpose(g_x(x, u)) * lambda - lambda

    return vcat(stationarity, control_foc, envelope)
end

function finite_difference_jacobian(f, z; relative_step=sqrt(eps(Float64)))
    fz = f(z)
    J = zeros(length(fz), length(z))

    for j in eachindex(z)
        step = relative_step * max(1.0, abs(z[j]))
        zplus = copy(z)
        zminus = copy(z)
        zplus[j] += step
        zminus[j] -= step
        J[:, j] = (f(zplus) - f(zminus)) / (2step)
    end

    return J
end

function solve_steady_state(;
    beta,
    x_guess,
    u_guess,
    lambda_guess,
    r_x,
    r_u,
    g,
    g_x,
    g_u,
    xtol=1e-10,
    ftol=1e-10,
    maxit::Int=100,
)
    nx = length(x_guess)
    nu = length(u_guess)
    length(lambda_guess) == nx || error("lambda_guess must have the same length as x_guess.")

    initial_guess = vcat(x_guess, u_guess, lambda_guess)
    residual(z) = steady_state_residual(
        z;
        beta,
        nx,
        nu,
        r_x,
        r_u,
        g,
        g_x,
        g_u,
    )
    jacobian(z) = finite_difference_jacobian(residual, z)
    result = newton_system(
        residual,
        jacobian,
        initial_guess;
        xtol,
        ftol,
        maxit,
    )

    z = result.root
    return (
        x_ss=z[1:nx],
        u_ss=z[(nx + 1):(nx + nu)],
        lambda_ss=z[(nx + nu + 1):(2nx + nu)],
        residual=result.f_root,
        iterations=result.iterations,
        converged=result.converged,
        history=result.history,
    )
end

# ------------------------------------------------------------
# Full-depreciation log/Cobb-Douglas growth example.
# ------------------------------------------------------------

function growth_steady_state(A, beta, theta)
    A > 0 || error("A must be positive.")
    0 < beta < 1 || error("beta must lie between zero and one.")
    0 < theta < 1 || error("theta must lie between zero and one.")
    return (beta * A * theta)^(1 / (1 - theta))
end

growth_policy(k, A, beta, theta) = beta * theta * A * k^theta

function growth_steady_state_numerical(A, beta, theta; initial_scale=0.8)
    k_reference = growth_steady_state(A, beta, theta)

    r_x(x, u) = begin
        k = x[1]
        kprime = u[1]
        consumption = A * k^theta - kprime
        [A * theta * k^(theta - 1) / consumption]
    end
    r_u(x, u) = begin
        consumption = A * x[1]^theta - u[1]
        [-1 / consumption]
    end
    g(x, u) = [u[1]]
    g_x(x, u) = zeros(1, 1)
    g_u(x, u) = ones(1, 1)

    k_guess = initial_scale * k_reference
    u_guess = initial_scale * k_reference
    consumption_guess = A * k_guess^theta - u_guess
    lambda_guess = [1 / (beta * consumption_guess)]

    return solve_steady_state(
        beta=beta,
        x_guess=[k_guess],
        u_guess=[u_guess],
        lambda_guess=lambda_guess,
        r_x=r_x,
        r_u=r_u,
        g=g,
        g_x=g_x,
        g_u=g_u,
    )
end
