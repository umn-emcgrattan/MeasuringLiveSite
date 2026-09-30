using Printf

include(joinpath(@__DIR__, "..", "src", "root_finding.jl"))

f(x) = x^2 - x - 2
result = bisection(f, 1.0, 5.0)

println("Bisection for f(x) = x^2 - x - 2 on [1,5]")
println(" iteration          a          b          c       f(c)")
for h in result.history
    @printf("%10d %10.6f %10.6f %10.6f %10.6f\n", h.iteration, h.a, h.b, h.c, h.fc)
end
@printf("\nRoot = %.12f, f(root) = %.3e\n", result.root, result.f_root)

