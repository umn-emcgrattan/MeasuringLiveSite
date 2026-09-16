include(joinpath(@__DIR__, "..", "src", "vfi.jl"))

model = check_growth_model()

solution = solve_vfi_markov_z(
    model = model,
    nk = 41,
    nz = 7,
    nh = 1,
    nk_choice = 401,
    k_min_factor = 0.65,
    k_max_factor = 1.35,
    tol = 1e-5,
    maxit = 1000,
    print_every = 25,
)

println()
print_vfi_summary(solution; label = "Check economy: Markov-chain log z")

println()
print_row_sums(solution.P)

println()
println("Policy errors relative to analytic solution")
function maximum_check_policy_errors(solution, model)
    max_error_k = 0.0
    max_error_c = 0.0
    for iz in eachindex(solution.z_grid)
        logz = solution.z_grid[iz]
        for ik in eachindex(solution.k_grid)
            k = solution.k_grid[ik]
            max_error_k = max(max_error_k, abs(solution.policy_k[ik, iz] - analytic_check_policy_k(k, logz, model)))
            max_error_c = max(max_error_c, abs(solution.policy_c[ik, iz] - analytic_check_policy_c(k, logz, model)))
        end
    end
    return max_error_k, max_error_c
end

max_error_k, max_error_c = maximum_check_policy_errors(solution, model)
@printf("max |k'_computed - k'_analytic|  %.8e\n", max_error_k)
@printf("max |c_computed  - c_analytic |  %.8e\n", max_error_c)

println()
print_policy_slice(solution)
