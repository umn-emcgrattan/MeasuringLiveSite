# ============================================================
# numerical_differentiation.jl
#
# Finite-difference approximations to first and second
# derivatives. No external packages are required.
# ============================================================

function forward_difference(f, x0, delta)
    delta > 0 || error("delta must be positive.")
    return (f(x0 + delta) - f(x0)) / delta
end

function backward_difference(f, x0, delta)
    delta > 0 || error("delta must be positive.")
    return (f(x0) - f(x0 - delta)) / delta
end

function central_difference(f, x0, delta)
    delta > 0 || error("delta must be positive.")
    return (f(x0 + delta) - f(x0 - delta)) / (2delta)
end

function second_difference(f, x0, delta)
    delta > 0 || error("delta must be positive.")
    return (f(x0 + delta) - 2f(x0) + f(x0 - delta)) / delta^2
end

