include(joinpath(@__DIR__, "..", "src", "riccati.jl"))

problem = simple_scalar_lq_problem()

print_lq_problem(problem)
println()

solution = solve_riccati_iteration(
    problem;
    tol_P = 1e-10,
    tol_F = 1e-10,
    maxit = 1000,
    print_every = 5,
)

println()
print_riccati_solution(problem, solution)

println()
println("First few simulated states and controls from X0 = 1")
X0 = [1.0]
shocks = zeros(1, 8)
X, U = simulate_lq(problem, solution, X0, shocks)

println("   t              X_t              u_t")
for t in 1:size(U, 2)
    @printf("%4d   %14.8f   %14.8f\n", t - 1, X[1, t], U[1, t])
end
@printf("%4d   %14.8f\n", size(U, 2), X[1, end])
