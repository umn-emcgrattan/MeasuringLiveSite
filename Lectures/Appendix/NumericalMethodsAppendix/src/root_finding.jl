# ============================================================
# root_finding.jl
#
# Student-readable routines for finding zeros of functions.
#
# The routines return both the numerical result and an iteration
# history that can be printed by a driver or used in a figure.
# ============================================================

using LinearAlgebra

"""
    bisection(f, a, b; xtol=1e-10, ftol=1e-10, maxit=100)

Find a zero of the continuous scalar function `f` in the interval `[a,b]`.
The endpoint values must have opposite signs, unless an endpoint is itself a
zero. Iteration stops when either `abs(f(c)) <= ftol` or the bracket length is
no larger than `xtol`.
"""
function bisection(f, a, b; xtol=1e-10, ftol=1e-10, maxit::Int=100)
    a < b || error("The lower endpoint a must be smaller than b.")
    xtol > 0 || error("xtol must be positive.")
    ftol > 0 || error("ftol must be positive.")
    maxit >= 1 || error("maxit must be at least 1.")

    left = float(a)
    right = float(b)
    fleft = f(left)
    fright = f(right)
    history = NamedTuple[]

    if abs(fleft) <= ftol
        return (root=left, f_root=fleft, iterations=0, converged=true, history=history)
    elseif abs(fright) <= ftol
        return (root=right, f_root=fright, iterations=0, converged=true, history=history)
    elseif fleft * fright > 0
        error("f(a) and f(b) must have opposite signs.")
    end

    for iteration in 1:maxit
        midpoint = (left + right) / 2
        fmidpoint = f(midpoint)

        push!(history, (
            iteration=iteration,
            a=left,
            b=right,
            c=midpoint,
            fa=fleft,
            fb=fright,
            fc=fmidpoint,
            width=right - left,
        ))

        if abs(fmidpoint) <= ftol || right - left <= xtol
            return (
                root=midpoint,
                f_root=fmidpoint,
                iterations=iteration,
                converged=true,
                history=history,
            )
        end

        if fleft * fmidpoint < 0
            right = midpoint
            fright = fmidpoint
        else
            left = midpoint
            fleft = fmidpoint
        end
    end

    midpoint = (left + right) / 2
    return (
        root=midpoint,
        f_root=f(midpoint),
        iterations=maxit,
        converged=false,
        history=history,
    )
end

"""
    newton_method(f, derivative, x0; xtol=1e-10, ftol=1e-10, maxit=100)

Find a zero of the scalar function `f` by Newton's method, starting from `x0`.
The function `derivative` evaluates `f'`. Iteration stops when either the
residual or the Newton step is sufficiently small.
"""
function newton_method(f, derivative, x0; xtol=1e-10, ftol=1e-10, maxit::Int=100)
    xtol > 0 || error("xtol must be positive.")
    ftol > 0 || error("ftol must be positive.")
    maxit >= 1 || error("maxit must be at least 1.")

    x = float(x0)
    history = NamedTuple[]

    for iteration in 1:maxit
        fx = f(x)
        if abs(fx) <= ftol
            return (
                root=x,
                f_root=fx,
                iterations=iteration - 1,
                converged=true,
                history=history,
            )
        end

        dfx = derivative(x)
        iszero(dfx) && error("Newton's method encountered a zero derivative at x = $x.")

        step = fx / dfx
        next_x = x - step
        next_fx = f(next_x)

        push!(history, (
            iteration=iteration,
            x=x,
            fx=fx,
            derivative=dfx,
            step=step,
            next_x=next_x,
            next_fx=next_fx,
        ))

        if abs(step) <= xtol || abs(next_fx) <= ftol
            return (
                root=next_x,
                f_root=next_fx,
                iterations=iteration,
                converged=true,
                history=history,
            )
        end

        x = next_x
    end

    return (
        root=x,
        f_root=f(x),
        iterations=maxit,
        converged=false,
        history=history,
    )
end

"""
    newton_system(f, jacobian, x0; xtol=1e-10, ftol=1e-10, maxit=100)

Newton's method for a system of equations `f(x) = 0`. The supplied `jacobian`
returns the Jacobian matrix. The Newton step is computed by solving a linear
system rather than explicitly forming the inverse of the Jacobian.
"""
function newton_system(f, jacobian, x0; xtol=1e-10, ftol=1e-10, maxit::Int=100)
    xtol > 0 || error("xtol must be positive.")
    ftol > 0 || error("ftol must be positive.")
    maxit >= 1 || error("maxit must be at least 1.")

    x = Float64.(x0)
    history = NamedTuple[]

    for iteration in 1:maxit
        fx = f(x)
        if norm(fx) <= ftol
            return (
                root=x,
                f_root=fx,
                iterations=iteration - 1,
                converged=true,
                history=history,
            )
        end

        step = jacobian(x) \ fx
        next_x = x - step
        next_fx = f(next_x)

        push!(history, (
            iteration=iteration,
            x=copy(x),
            fx=copy(fx),
            step=copy(step),
            next_x=copy(next_x),
            next_fx=copy(next_fx),
        ))

        if norm(step) <= xtol || norm(next_fx) <= ftol
            return (
                root=next_x,
                f_root=next_fx,
                iterations=iteration,
                converged=true,
                history=history,
            )
        end

        x = next_x
    end

    return (
        root=x,
        f_root=f(x),
        iterations=maxit,
        converged=false,
        history=history,
    )
end

