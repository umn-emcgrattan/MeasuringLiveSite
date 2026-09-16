include(joinpath(@__DIR__, "..", "src", "vfi.jl"))

model = default_growth_model()

solution = solve_vfi_continuous_z(
    model = model,
    nk = 25,
    nz = 7,
    nh = 7,
    nquad = 7,
    tol = 1e-4,
    maxit = 250,
    print_every = 10,
)

println()
print_vfi_summary(solution; label = "Continuous log z with Gaussian quadrature")

println()
print_policy_slice(solution)
