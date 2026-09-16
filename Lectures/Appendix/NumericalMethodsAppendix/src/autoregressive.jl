# ============================================================
# autoregressive.jl
#
# Approximate an AR(1) process with a finite-state Markov chain.
#
# Process:
#   y_{t+1} = rho*y_t + epsilon_{t+1}
#   epsilon_{t+1} ~ N(0, sigma_epsilon^2)
#
# The code:
#   1. chooses an equally spaced grid for y
#   2. constructs bins around the grid points
#   3. uses the normal CDF to fill transition probabilities
#
# No external packages are required.
# ============================================================

using Printf

# ------------------------------------------------------------
# Standard normal CDF, using a common no-package approximation.
#
# Phi(x) = Prob(Z <= x), where Z ~ N(0,1).
# ------------------------------------------------------------
function normal_cdf(x)
    if x < 0
        return 1.0 - normal_cdf(-x)
    end

    p = 0.2316419
    b1 = 0.319381530
    b2 = -0.356563782
    b3 = 1.781477937
    b4 = -1.821255978
    b5 = 1.330274429

    t = 1.0 / (1.0 + p * x)
    poly = b1 * t + b2 * t^2 + b3 * t^3 + b4 * t^4 + b5 * t^5
    density = exp(-0.5 * x^2) / sqrt(2.0 * pi)
    return 1.0 - density * poly
end


# ------------------------------------------------------------
# Unconditional standard deviation of the stationary AR(1).
# ------------------------------------------------------------
function ar1_stationary_std(rho, sigma_epsilon)
    abs(rho) < 1 || error("rho must satisfy abs(rho) < 1 for a stationary AR(1).")
    sigma_epsilon > 0 || error("sigma_epsilon must be positive.")
    return sigma_epsilon / sqrt(1.0 - rho^2)
end


# ------------------------------------------------------------
# Equally spaced grid on [-m*sigma_y, m*sigma_y].
# ------------------------------------------------------------
function ar1_grid(rho, sigma_epsilon, n; m=3.0)
    n >= 2 || error("n must be at least 2.")
    sigma_y = ar1_stationary_std(rho, sigma_epsilon)
    lo = -m * sigma_y
    hi = m * sigma_y
    step = (hi - lo) / (n - 1)
    return collect(range(lo, hi; length=n)), step
end


# ------------------------------------------------------------
# Probability of moving from y_i today to bin j tomorrow.
#
# Interior bins are [y_j - step/2, y_j + step/2].
# The first and last bins extend to -Inf and Inf.
# ------------------------------------------------------------
function ar1_transition_probability(y_i, y_j, j, n, step, rho, sigma_epsilon)
    mean_next = rho * y_i

    if j == 1
        upper = (y_j + step / 2 - mean_next) / sigma_epsilon
        return normal_cdf(upper)
    elseif j == n
        lower = (y_j - step / 2 - mean_next) / sigma_epsilon
        return 1.0 - normal_cdf(lower)
    else
        upper = (y_j + step / 2 - mean_next) / sigma_epsilon
        lower = (y_j - step / 2 - mean_next) / sigma_epsilon
        return normal_cdf(upper) - normal_cdf(lower)
    end
end


# ------------------------------------------------------------
# Tauchen-style Markov approximation for an AR(1).
#
# Returns:
#   grid = y_1,...,y_n
#   P    = transition matrix, with P[i,j] = Prob(y' = y_j | y = y_i)
# ------------------------------------------------------------
function tauchen_ar1(rho, sigma_epsilon, n; m=3.0)
    grid, step = ar1_grid(rho, sigma_epsilon, n; m)
    P = zeros(n, n)

    for i in 1:n
        for j in 1:n
            P[i, j] = ar1_transition_probability(
                grid[i],
                grid[j],
                j,
                n,
                step,
                rho,
                sigma_epsilon,
            )
        end
    end

    return grid, P
end


# ------------------------------------------------------------
# Three-state example with grid [-a, 0, a].
#
# This mirrors the hand calculation in the appendix notes.
# ------------------------------------------------------------
function three_state_ar1(rho, sigma_epsilon, a)
    sigma_epsilon > 0 || error("sigma_epsilon must be positive.")
    a > 0 || error("a must be positive.")

    grid = [-a, 0.0, a]
    step = a
    n = length(grid)
    P = zeros(n, n)

    for i in 1:n
        for j in 1:n
            P[i, j] = ar1_transition_probability(
                grid[i],
                grid[j],
                j,
                n,
                step,
                rho,
                sigma_epsilon,
            )
        end
    end

    return grid, P
end


# ------------------------------------------------------------
# Compute the next-period conditional mean implied by the
# discrete Markov approximation at each grid point.
# ------------------------------------------------------------
function markov_conditional_means(grid, P)
    return P * grid
end


# ------------------------------------------------------------
# Simple printers for student-facing scripts.
# ------------------------------------------------------------
function print_grid(grid)
    println("Grid")
    println("   i                  y_i")
    for i in eachindex(grid)
        @printf("%4d   %18.10f\n", i, grid[i])
    end
end

function print_transition_matrix(P)
    println("Transition matrix")
    for i in axes(P, 1)
        for j in axes(P, 2)
            @printf("%12.8f", P[i, j])
        end
        println()
    end
end

function print_row_sums(P)
    println("Row sums")
    for i in axes(P, 1)
        @printf("%4d   %18.12f\n", i, sum(P[i, :]))
    end
end
