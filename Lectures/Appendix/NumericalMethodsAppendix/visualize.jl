using Plots

include(joinpath(@__DIR__, "scripts", "numerical_differentiation.jl"))
include(joinpath(@__DIR__, "scripts", "quadrature_visualization.jl"))
include(joinpath(@__DIR__, "scripts", "autoregressive_visualization.jl"))
include(joinpath(@__DIR__, "scripts", "root_finding_visualization.jl"))
include(joinpath(@__DIR__, "scripts", "dynamic_programming_visualization.jl"))

# --------------------------------------------------
# Numerical differentiation
# --------------------------------------------------

fig1 = forward_difference_plot(delta = 0.5, x0 = 1.0)

# --------------------------------------------------
# Gaussian quadrature
# --------------------------------------------------

fig2 = quadrature_comparison_plot(n = 2)

# --------------------------------------------------
# Discretized autoregressive process
# --------------------------------------------------

fig3 = ar1_discretization_plot(
    state_index = 2,
    rho = 0.8,
    sigma_epsilon = 0.4,
    a = 1.0,
)

# --------------------------------------------------
# Root finding
# --------------------------------------------------

fig4 = root_finding_comparison_plot(
    bisection_iteration = 1,
    newton_iteration = 1,
)

# --------------------------------------------------
# Dynamic programming and state normalization
# --------------------------------------------------

fig5 = growth_normalization_plot(
    A = 1.0,
    beta = 0.95,
    theta = 0.36,
    grid_width = 0.5,
)
