using Printf

include(joinpath(@__DIR__, "..", "src", "numerical_differentiation.jl"))

# Lecture example: f(x) = x^2 at x0 = 1.
f(x) = x^2
fprime(x) = 2x
fsecond(x) = 2.0
x0 = 1.0

println("Finite differences for f(x) = x^2 at x0 = 1")
@printf("Exact first derivative  = %.6f\n", fprime(x0))
@printf("Exact second derivative = %.6f\n\n", fsecond(x0))
println("   delta       forward       backward        central         second")

for delta in (0.5, 0.25, 0.1, 0.01)
    @printf(
        "%8.3f   %12.6f   %12.6f   %12.6f   %12.6f\n",
        delta,
        forward_difference(f, x0, delta),
        backward_difference(f, x0, delta),
        central_difference(f, x0, delta),
        second_difference(f, x0, delta),
    )
end

