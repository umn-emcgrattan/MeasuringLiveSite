include(joinpath(@__DIR__, "..", "src", "autoregressive.jl"))

# Numerical version of the lecture's three-state example.
rho = 0.8
sigma_epsilon = 0.4
a = 1.0

println("Three-state AR(1) example")
grid3, P3 = three_state_ar1(rho, sigma_epsilon, a)

print_grid(grid3)
println()
print_transition_matrix(P3)
println()
print_row_sums(P3)

println()
println("Conditional means: continuous AR(1) versus Markov approximation")
discrete_means = markov_conditional_means(grid3, P3)
println("   i             rho*y_i        sum_j P_ij*y_j")
for i in eachindex(grid3)
    @printf("%4d   %18.10f   %18.10f\n", i, rho * grid3[i], discrete_means[i])
end
