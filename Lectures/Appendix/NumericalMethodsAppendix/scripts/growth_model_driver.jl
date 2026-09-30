using Printf

include(joinpath(@__DIR__, "..", "src", "dynamic_programming.jl"))

A = 1.0
beta = 0.95
theta = 0.36

numerical = growth_steady_state_numerical(A, beta, theta)
analytical_k = growth_steady_state(A, beta, theta)

println("Full-depreciation log/Cobb-Douglas growth model")
@printf("A = %.3f, beta = %.3f, theta = %.3f\n\n", A, beta, theta)
@printf("Analytical steady-state capital = %.12f\n", analytical_k)
@printf("Numerical steady-state capital  = %.12f\n", numerical.x_ss[1])
@printf("Numerical steady-state control  = %.12f\n", numerical.u_ss[1])
@printf("Maximum absolute residual       = %.3e\n", maximum(abs.(numerical.residual)))
println("Converged                       = ", numerical.converged)

normalized_grid = collect(range(0.5, 1.5; length=11))
capital_grid = analytical_k .* normalized_grid
policy_grid = growth_policy.(capital_grid, A, beta, theta)

println("\n      k/k_ss              k             k'        k'/k_ss")
for i in eachindex(normalized_grid)
    @printf(
        "%12.6f   %12.6f   %12.6f   %12.6f\n",
        normalized_grid[i],
        capital_grid[i],
        policy_grid[i],
        policy_grid[i] / analytical_k,
    )
end

