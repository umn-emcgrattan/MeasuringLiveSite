using Plots
using Printf

include(joinpath(@__DIR__, "..", "src", "quadrature.jl"))

"""
    quadrature_comparison_plot(; n=2)

Compare a midpoint Riemann sum and Gauss-Legendre quadrature using the same
number `n` of function evaluations. The integrand is the cubic example from
the appendix, `f(x) = 1 + 2x + 3x^2 + 4x^3`, on `[-1,1]`.
"""
function quadrature_comparison_plot(; n::Int = 2)
    n >= 1 || error("n must be at least 1.")

    f(x) = 1 + 2x + 3x^2 + 4x^3
    compact(x) = abs(x) < 1e-12 ? "0" : @sprintf("%.6g", x)
    exact_value = 4.0
    xgrid = range(-1.0, 1.0; length = 500)

    # Midpoint Riemann sum with n equal-width rectangles.
    edges = collect(range(-1.0, 1.0; length = n + 1))
    midpoints = [(edges[i] + edges[i + 1]) / 2 for i in 1:n]
    width = 2.0 / n
    riemann_value = width * sum(f.(midpoints))

    riemann_plot = plot(
        xgrid,
        f.(xgrid);
        color = :black,
        linewidth = 2.5,
        label = "f(x)",
        xlabel = "x",
        ylabel = "f(x)",
        title = "Riemann: $(compact(riemann_value))   |error|: $(compact(abs(riemann_value - exact_value)))",
        grid = false,
        framestyle = :box,
        legend = :topleft,
    )

    for i in 1:n
        left = edges[i]
        right = edges[i + 1]
        height = f(midpoints[i])
        rectangle = Shape(
            [left, right, right, left],
            [0.0, 0.0, height, height],
        )
        plot!(
            riemann_plot,
            rectangle;
            color = :gray,
            fillalpha = 0.25,
            linecolor = :gray,
            linewidth = 1,
            label = false,
        )
    end
    scatter!(
        riemann_plot,
        midpoints,
        f.(midpoints);
        color = :red,
        markerstrokecolor = :red,
        markersize = 4,
        label = "evaluation points",
    )

    # Gauss-Legendre quadrature with n nodes on [-1,1].
    nodes, weights = gauss_legendre_general(n)
    gauss_value = sum(weights .* f.(nodes))

    gauss_plot = plot(
        xgrid,
        f.(xgrid);
        color = :black,
        linewidth = 2.5,
        label = "f(x)",
        xlabel = "x",
        ylabel = "f(x)",
        title = "Gauss-Legendre: $(compact(gauss_value))   |error|: $(compact(abs(gauss_value - exact_value)))",
        grid = false,
        framestyle = :box,
        legend = :topleft,
    )

    plot!(
        gauss_plot,
        [-1.0, 1.0],
        [0.0, 0.0];
        color = :gray,
        linestyle = :dot,
        linewidth = 1.5,
        label = false,
    )

    for i in eachindex(nodes)
        plot!(
            gauss_plot,
            [nodes[i], nodes[i]],
            [0.0, f(nodes[i])];
            color = :red,
            linestyle = :dot,
            linewidth = 1.5,
            label = false,
        )
    end
    scatter!(
        gauss_plot,
        nodes,
        f.(nodes);
        color = :red,
        markerstrokecolor = :red,
        markersize = 6,
        label = "nodes",
    )

    return plot(
        riemann_plot,
        gauss_plot;
        layout = (1, 2),
        size = (1000, 470),
        plot_title = "Same $(n) function evaluations; exact integral = 4",
    )
end
