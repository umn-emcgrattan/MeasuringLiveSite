include(joinpath(@__DIR__, "..", "src", "autoregressive.jl"))

rho = 0.95
sigma_epsilon = 0.01

println("Three-state AR(1) example")
a = 3.0 * ar1_stationary_std(rho, sigma_epsilon)
grid3, P3 = three_state_ar1(rho, sigma_epsilon, a)

print_grid(grid3)
println()
print_transition_matrix(P3)
println()
print_row_sums(P3)

println()
println("Five-state Tauchen-style approximation")
grid5, P5 = tauchen_ar1(rho, sigma_epsilon, 5)

print_grid(grid5)
println()
print_transition_matrix(P5)
println()
print_row_sums(P5)

println()
println("Conditional means: continuous AR(1) versus Markov approximation")
discrete_means = markov_conditional_means(grid5, P5)
println("   i             rho*y_i        sum_j P_ij*y_j")
for i in eachindex(grid5)
    @printf("%4d   %18.10f   %18.10f\n", i, rho * grid5[i], discrete_means[i])
end
