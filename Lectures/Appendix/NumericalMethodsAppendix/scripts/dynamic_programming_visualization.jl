using Plots
using Printf

include(joinpath(@__DIR__, "..", "src", "dynamic_programming.jl"))

function growth_normalization_plot(;
    A::Real=1.0,
    beta::Real=0.95,
    theta::Real=0.36,
    grid_width::Real=0.5,
    grid_points::Int=11,
)
    0 < grid_width < 1 || error("grid_width must lie between zero and one.")
    grid_points >= 3 || error("grid_points must be at least 3.")

    k_ss = growth_steady_state(A, beta, theta)
    normalized_grid = collect(range(1 - grid_width, 1 + grid_width; length=grid_points))
    capital_grid = k_ss .* normalized_grid
    raw_policy = growth_policy.(capital_grid, A, beta, theta)
    normalized_policy = raw_policy ./ k_ss

    raw_curve = range(first(capital_grid), last(capital_grid); length=400)
    normalized_curve = range(first(normalized_grid), last(normalized_grid); length=400)

    raw_plot = plot(
        raw_curve,
        growth_policy.(raw_curve, A, beta, theta);
        color=:black,
        linewidth=2.5,
        label="k′ = βθAkᶿ",
        xlabel="current capital, k",
        ylabel="next capital, k′",
        title="Raw capital grid",
        grid=false,
        framestyle=:box,
        legend=:topleft,
    )
    plot!(raw_plot, raw_curve, raw_curve; color=:gray, linestyle=:dash, linewidth=1.5, label="45-degree line")
    scatter!(raw_plot, capital_grid, raw_policy; color=:blue, markerstrokecolor=:blue,
        markersize=4, label="grid points")
    scatter!(raw_plot, [k_ss], [k_ss]; color=:red, markerstrokecolor=:red,
        markersize=7, label="steady state")

    normalized_plot = plot(
        normalized_curve,
        normalized_curve .^ theta;
        color=:black,
        linewidth=2.5,
        label="x′ = xᶿ",
        xlabel="normalized capital, x = k/kₛₛ",
        ylabel="normalized next capital, x′",
        title="Normalized grid",
        grid=false,
        framestyle=:box,
        legend=:topleft,
    )
    plot!(normalized_plot, normalized_curve, normalized_curve;
        color=:gray, linestyle=:dash, linewidth=1.5, label="45-degree line")
    scatter!(normalized_plot, normalized_grid, normalized_policy;
        color=:blue, markerstrokecolor=:blue, markersize=4, label="grid points")
    scatter!(normalized_plot, [1.0], [1.0]; color=:red, markerstrokecolor=:red,
        markersize=7, label="steady state")

    return plot(
        raw_plot,
        normalized_plot;
        layout=(1, 2),
        size=(1100, 480),
        plot_title=@sprintf("A = %.2f, β = %.3f, θ = %.2f;  kₛₛ = %.4g", A, beta, theta, k_ss),
    )
end
