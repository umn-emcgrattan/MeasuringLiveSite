include(joinpath(@__DIR__, "..", "src", "vaughan.jl"))

problem = simple_scalar_lq_problem()

print_lq_problem(problem)
println()

vaughan_solution = solve_vaughan(problem)
print_vaughan_solution(problem, vaughan_solution)

println()
println("Comparison with direct Riccati iteration")
riccati_solution = solve_riccati_iteration(problem; print_every = 0)
@printf("norm(P_vaughan - P_riccati)  %.8e\n", norm(vaughan_solution.P - riccati_solution.P))
@printf("norm(F_vaughan - F_riccati)  %.8e\n", norm(vaughan_solution.F - riccati_solution.F))

println()
println("First few simulated states and controls from X0 = 1")
X0 = [1.0]
shocks = zeros(1, 8)
X, U = simulate_lq(problem, vaughan_solution, X0, shocks)

println("   t              X_t              u_t")
for t in 1:size(U, 2)
    @printf("%4d   %14.8f   %14.8f\n", t - 1, X[1, t], U[1, t])
end
@printf("%4d   %14.8f\n", size(U, 2), X[1, end])
