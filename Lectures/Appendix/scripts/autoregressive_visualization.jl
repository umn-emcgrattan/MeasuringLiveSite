using Plots
using Printf

include(joinpath(@__DIR__, "..", "src", "autoregressive.jl"))

"""
    ar1_discretization_plot(; state_index=2, rho=0.8,
                              sigma_epsilon=0.4, a=1.0)

Visualize one row of the three-state Markov approximation to an AR(1).
The left panel shows the conditional normal density and the three bins whose
areas give the transition probabilities. The right panel shows the resulting
row of the transition matrix.
"""
function ar1_discretization_plot(;
    state_index::Int = 2,
    rho::Real = 0.8,
    sigma_epsilon::Real = 0.4,
    a::Real = 1.0,
)
    state_index in 1:3 || error("state_index must be 1, 2, or 3.")
    abs(rho) < 1 || error("rho must satisfy abs(rho) < 1.")
    sigma_epsilon > 0 || error("sigma_epsilon must be positive.")
    a > 0 || error("a must be positive.")

    grid, transition = three_state_ar1(rho, sigma_epsilon, a)
    probabilities = transition[state_index, :]
    current_state = grid[state_index]
    conditional_mean = rho * current_state

    density(x) = exp(-0.5 * ((x - conditional_mean) / sigma_epsilon)^2) /
                 (sqrt(2pi) * sigma_epsilon)
    compact(x) = abs(x) < 1e-12 ? "0" : @sprintf("%.4g", x)

    left_boundary = -a / 2
    right_boundary = a / 2
    xmin = min(-1.75a, conditional_mean - 4sigma_epsilon)
    xmax = max(1.75a, conditional_mean + 4sigma_epsilon)
    colors = [:steelblue, :gray, :indianred]
    state_names = ["−a", "0", "a"]

    density_plot = plot(
        xlabel = "tomorrow's value, yₜ₊₁",
        ylabel = "conditional density",
        title = "yₜ₊₁ | yₜ = $(state_names[state_index])",
        xlims = (xmin, xmax),
        grid = false,
        framestyle = :box,
        legend = :topleft,
        xticks = (
            [-a, left_boundary, 0.0, right_boundary, a],
            ["−a", "−a/2", "0", "a/2", "a"],
        ),
    )

    intervals = [(xmin, left_boundary), (left_boundary, right_boundary), (right_boundary, xmax)]
    for j in 1:3
        lo, hi = intervals[j]
        xs = range(lo, hi; length = 180)
        plot!(
            density_plot,
            xs,
            density.(xs);
            color = colors[j],
            linewidth = 2,
            fillrange = 0,
            fillcolor = colors[j],
            fillalpha = 0.28,
            label = "Π$(state_index)$(j) = $(compact(probabilities[j]))",
        )
    end

    vline!(
        density_plot,
        [left_boundary, right_boundary];
        color = :gray,
        linestyle = :dot,
        linewidth = 1.5,
        label = false,
    )
    vline!(
        density_plot,
        [conditional_mean];
        color = :black,
        linestyle = :dash,
        linewidth = 2,
        label = "mean ρyᵢ = $(compact(conditional_mean))",
    )

    row_sum = sum(probabilities)
    probability_plot = bar(
        1:3,
        probabilities;
        color = colors,
        linecolor = colors,
        label = false,
        xlabel = "tomorrow's discrete state",
        ylabel = "transition probability",
        title = "Row $(state_index) of Π; sum = $(compact(row_sum))",
        xticks = (1:3, ["−a", "0", "a"]),
        ylims = (0, 1.05),
        grid = false,
        framestyle = :box,
    )

    for j in 1:3
        annotate!(
            probability_plot,
            j,
            min(probabilities[j] + 0.04, 1.02),
            text(compact(probabilities[j]), 10, :center),
        )
    end

    return plot(
        density_plot,
        probability_plot;
        layout = (1, 2),
        size = (1000, 470),
        plot_title = "Three-State Approximation to an AR(1)",
    )
end

