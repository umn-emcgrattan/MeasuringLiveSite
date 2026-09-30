using Printf

include(joinpath(@__DIR__, "..", "src", "root_finding.jl"))

f(x) = x^2 - x - 2
derivative(x) = 2x - 1
result = newton_method(f, derivative, 3.0)

println("Newton's method for f(x) = x^2 - x - 2, x0 = 3")
println(" iteration          x_k       f(x_k)      f'(x_k)      x_(k+1)")
for h in result.history
    @printf("%10d %12.8f %12.8f %12.8f %14.10f\n", h.iteration, h.x, h.fx, h.derivative, h.next_x)
end
@printf("\nRoot = %.12f, f(root) = %.3e\n", result.root, result.f_root)

