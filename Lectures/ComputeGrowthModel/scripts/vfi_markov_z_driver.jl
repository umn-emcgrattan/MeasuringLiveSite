include(joinpath(@__DIR__, "..", "src", "vfi.jl"))

model = default_growth_model()

solution = solve_vfi_markov_z(
    model = model,
    nk = 25,
    nz = 7,
    nh = 7,
    tol = 1e-4,
    maxit = 250,
    print_every = 10,
)

println()
print_vfi_summary(solution; label = "Markov-chain log z")

println()
print_row_sums(solution.P)

println()
print_policy_slice(solution)
