using Printf

include(joinpath(@__DIR__, "..", "src", "baseline_lq.jl"))

model = default_growth_model()
result = solve_baseline_lq(model)
comparison = compare_lq_solutions(result)

println("Baseline stationary steady state")
@printf("k_ss       %14.8f\n", result.ss.k)
@printf("h_ss       %14.8f\n", result.ss.h)
@printf("y_ss       %14.8f\n", result.ss.y)
@printf("c_ss       %14.8f\n", result.ss.c)
@printf("g_ss       %14.8f  (placeholder)\n", model.g_ss)

println("\nRiccati versus Vaughan")
@printf("norm(P_R - P_V)  %.8e\n", comparison.P_gap)
@printf("norm(F_R - F_V)  %.8e\n", comparison.F_gap)
@printf("Vaughan residual %.8e\n", comparison.vaughan_residual)

println("\nDecision rules u = -F X")
println("Riccati F")
show(stdout, "text/plain", result.riccati.F)
println("\n\nVaughan F")
show(stdout, "text/plain", result.vaughan.F)
println()
