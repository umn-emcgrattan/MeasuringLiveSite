# ============================================================
# quadrature.jl
#
# Gauss-Legendre quadrature for arbitrary n.
#
# The code:
#   1. evaluates Legendre polynomials by recursion
#   2. evaluates their derivatives
#   3. finds roots with Newton's method
#   4. computes weights from the standard formula
#
# Nodes and weights are for the interval [-1,1].
# A helper function is included for integrating on [a,b].
#
# No external packages are required.
# ============================================================

using Printf

# ------------------------------------------------------------
# Evaluate P_n(x) and P_{n-1}(x) using recursion.
#
# Returns:
#   Pn   = P_n(x)
#   Pnm1 = P_{n-1}(x)
# ------------------------------------------------------------
function legendre_pair(n, x)
    if n == 0
        return 1.0, 0.0
    elseif n == 1
        return x, 1.0
    end

    Pnm1 = 1.0      # P_0
    Pn   = x        # P_1

    for k in 1:(n-1)
        Pnp1 = ((2k + 1) * x * Pn - k * Pnm1) / (k + 1)
        Pnm1, Pn = Pn, Pnp1
    end

    return Pn, Pnm1
end


# ------------------------------------------------------------
# Evaluate P_n(x)
# ------------------------------------------------------------
function legendreP(n, x)
    Pn, _ = legendre_pair(n, x)
    return Pn
end


# ------------------------------------------------------------
# Evaluate derivative P_n'(x)
#
# Formula:
#   P_n'(x) = n/(x^2 - 1) * (x P_n(x) - P_{n-1}(x))
# ------------------------------------------------------------
function legendreP_deriv(n, x)
    if n == 0
        return 0.0
    end

    Pn, Pnm1 = legendre_pair(n, x)
    return n * (x * Pn - Pnm1) / (x^2 - 1.0)
end


# ------------------------------------------------------------
# Compute Gauss-Legendre nodes and weights on [-1,1].
#
# Uses symmetry:
#   if x is a root, then -x is also a root.
#
# Initial guesses:
#   x_k^(0) = cos( pi*(4k-1)/(4n+2) ),  k=1,...,ceil(n/2)
#
# Newton iteration:
#   x <- x - P_n(x)/P_n'(x)
# ------------------------------------------------------------
function gauss_legendre_general(n; tol=1e-14, maxit=100)
    if n < 1
        error("n must be at least 1.")
    end

    nodes   = zeros(n)
    weights = zeros(n)

    m = fld(n + 1, 2)   # number of positive-side roots to compute

    for k in 1:m
        # Good initial guess for the k-th positive root
        x = cos(pi * (4k - 1) / (4n + 2))

        # Newton iteration
        for it in 1:maxit
            Pn = legendreP(n, x)
            dPn = legendreP_deriv(n, x)

            dx = -Pn / dPn
            x += dx

            if abs(dx) < tol
                break
            end

            if it == maxit
                error("Newton iteration failed for root $k.")
            end
        end

        dPn = legendreP_deriv(n, x)
        w = 2.0 / ((1.0 - x^2) * dPn^2)

        # Fill symmetric roots/weights
        nodes[k] = -x
        nodes[n - k + 1] = x

        weights[k] = w
        weights[n - k + 1] = w
    end

    return nodes, weights
end


# ------------------------------------------------------------
# Map z in [-1,1] to x in [a,b].
# ------------------------------------------------------------
function map_to_interval(z, a, b)
    return 0.5 * (b - a) * z + 0.5 * (a + b)
end


# ------------------------------------------------------------
# Integrate f over [a,b] using n-point Gauss-Legendre quadrature.
# ------------------------------------------------------------
function gauss_integral_general(f, a, b, n)
    nodes, weights = gauss_legendre_general(n)

    val = 0.0
    for i in eachindex(nodes)
        x = map_to_interval(nodes[i], a, b)
        val += weights[i] * f(x)
    end

    return 0.5 * (b - a) * val
end


# ------------------------------------------------------------
# Simple printer for nodes and weights
# ------------------------------------------------------------
function print_rule(n)
    nodes, weights = gauss_legendre_general(n)

    println("Gauss-Legendre rule on [-1,1], n = $n")
    println("   i             node                 weight")
    for i in 1:n
        @printf("%4d   %20.14f   %20.14f\n", i, nodes[i], weights[i])
    end
end
