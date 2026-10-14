include(joinpath(@__DIR__, "..", "src", "quadrature.jl"))

# Lecture example: a cubic on [-1,1].
f(x) = 1 + 2x + 3x^2 + 4x^3
exact_value = 4.0
n = 2

print_rule(n)
approximation = gauss_integral_general(f, -1.0, 1.0, n)

println()
println("Lecture example: f(x) = 1 + 2x + 3x^2 + 4x^3")
@printf("Exact integral                 = %.12f\n", exact_value)
@printf("Two-node Gauss-Legendre value = %.12f\n", approximation)
@printf("Absolute error                 = %.3e\n", abs(approximation - exact_value))
