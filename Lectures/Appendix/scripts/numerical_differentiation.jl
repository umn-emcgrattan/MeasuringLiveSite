using Plots
using Printf

include(joinpath(@__DIR__, "..", "src", "numerical_differentiation.jl"))

"""
    forward_difference_plot(; delta=0.5, x0=1.0)

Illustrate the forward-difference approximation to the derivative of
`f(x) = x^2` at `x0`. The curve, exact tangent, forward secant, and the two
function evaluations used in the approximation are shown together.
"""
function forward_difference_plot(; delta::Real = 0.5, x0::Real = 1.0)
    delta > 0 || error("delta must be positive.")

    f(x) = x^2
    fprime(x) = 2x

    x1 = x0 + delta
    exact_slope = fprime(x0)
    forward_slope = forward_difference(f, x0, delta)

    xmin = min(-0.5, x0 - 1.0)
    xmax = max(2.5, x1 + 0.5)
    xgrid = range(xmin, xmax; length = 400)
    tangent(x) = f(x0) + exact_slope * (x - x0)
    secant(x) = f(x0) + forward_slope * (x - x0)

    p = plot(
        xgrid,
        f.(xgrid);
        color = :black,
        linewidth = 2.5,
        label = "f(x) = x²",
        xlabel = "x",
        ylabel = "f(x)",
        title = "Forward-Difference Approximation",
        size = (700, 520),
        legend = :topleft,
        grid = false,
        framestyle = :box,
    )

    plot!(
        p,
        xgrid,
        tangent.(xgrid);
        color = :blue,
        linewidth = 2,
        linestyle = :dash,
        label = @sprintf("tangent: f′(x₀) = %.2f", exact_slope),
    )

    plot!(
        p,
        [x0, x1],
        secant.([x0, x1]);
        color = :red,
        linewidth = 2.5,
        label = @sprintf("forward secant: slope = %.2f", forward_slope),
    )

    scatter!(
        p,
        [x0, x1],
        [f(x0), f(x1)];
        color = :red,
        markerstrokecolor = :red,
        markersize = 6,
        label = false,
    )

    plot!(
        p,
        [x0, x0],
        [0.0, f(x0)];
        color = :gray,
        linestyle = :dot,
        linewidth = 1.5,
        label = false,
    )
    plot!(
        p,
        [x1, x1],
        [0.0, f(x1)];
        color = :gray,
        linestyle = :dot,
        linewidth = 1.5,
        label = false,
    )

    annotate!(p, x0, -0.15, text("x₀", 10, :center))
    annotate!(p, x1, -0.15, text("x₀ + δ", 10, :center))

    return p
end
