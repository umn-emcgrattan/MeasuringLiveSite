include(joinpath(@__DIR__, "..", "src", "quadrature.jl"))

print_rule(5)

f(x) = exp(-x^2)
val = gauss_integral_general(f, -2.0, 2.0, 5)

println()
@printf("Integral ≈ %18.12f\n", val)
