using Plots
using Printf

if !isdefined(@__MODULE__, :newton_system)
    include(joinpath(@__DIR__, "..", "src", "root_finding.jl"))
end

root_example_function(x) = x^2 - x - 2
root_example_derivative(x) = 2x - 1
compact_root(x) = abs(x) < 1e-12 ? "0" : @sprintf("%.6g", x)

const ROOT_XLIMS = (-3.0, 5.25)
const ROOT_YLIMS = (-3.0, 22.0)

function root_base_plot(; title)
    xgrid = range(ROOT_XLIMS[1], ROOT_XLIMS[2]; length=600)
    p = plot(
        xgrid,
        root_example_function.(xgrid);
        color=:black,
        linewidth=2.5,
        label="f(x) = x² − x − 2",
        xlabel="x",
        ylabel="f(x)",
        title=title,
        xlims=ROOT_XLIMS,
        ylims=ROOT_YLIMS,
        grid=false,
        framestyle=:box,
        legend=:topleft,
    )
    hline!(p, [0.0]; color=:gray, linestyle=:dot, linewidth=1.5, label=false)
    scatter!(p, [-1.0, 2.0], [0.0, 0.0]; color=:black,
        markerstrokecolor=:black, markersize=4, label=false)
    return p
end

function bisection_visualization_plot(;
    a::Real=0.0,
    b::Real=5.0,
    iteration::Int=1,
    tolerance::Real=1e-8,
)
    iteration >= 1 || error("iteration must be positive.")
    fa = root_example_function(a)
    fb = root_example_function(b)

    if a >= b
        p = root_base_plot(title="Bisection: invalid interval")
        scatter!(p, [a, b], [fa, fb]; color=:red, markersize=7,
            label="a must be smaller than b")
        return p
    elseif fa * fb > 0
        p = root_base_plot(title="Bisection: no sign-change guarantee")
        scatter!(p, [a, b], [fa, fb]; color=:red, markerstrokecolor=:red,
            markersize=7, label="f(a) and f(b) have the same sign")
        plot!(p, [a, b], [0.0, 0.0]; color=:red, linewidth=5,
            label="proposed bracket")
        return p
    end

    result = bisection(root_example_function, a, b;
        xtol=tolerance, ftol=tolerance, maxit=100)

    if isempty(result.history)
        p = root_base_plot(title="Bisection: an endpoint is a root")
        endpoint = abs(fa) <= tolerance ? a : b
        scatter!(p, [endpoint], [0.0]; color=:red, markersize=7,
            label="root = $(compact_root(endpoint))")
        return p
    end

    shown_iteration = min(iteration, length(result.history))
    h = result.history[shown_iteration]
    width = h.b - h.a
    title = "Bisection $(shown_iteration): width = $(compact_root(width))"
    iteration > length(result.history) && (title *= " (converged)")
    p = root_base_plot(title=title)

    plot!(p, [h.a, h.b], [0.0, 0.0]; color=:blue, linewidth=6,
        label="current bracket [$(compact_root(h.a)), $(compact_root(h.b))]")
    scatter!(p, [h.a, h.b], [h.fa, h.fb]; color=:blue,
        markerstrokecolor=:blue, markersize=6, label="endpoints")
    plot!(p, [h.c, h.c], [0.0, h.fc]; color=:red,
        linestyle=:dash, linewidth=2, label=false)
    scatter!(p, [h.c], [h.fc]; color=:red, markerstrokecolor=:red,
        markersize=7, label="c = $(compact_root(h.c)); f(c) = $(compact_root(h.fc))")
    return p
end

function newton_visualization_history(x0; tolerance=1e-8, maxit=20)
    history = NamedTuple[]
    x = float(x0)
    status = :iterating

    for iteration in 1:maxit
        fx = root_example_function(x)
        dfx = root_example_derivative(x)

        if abs(fx) <= tolerance
            status = :converged
            break
        elseif abs(dfx) <= 1e-12
            push!(history, (iteration=iteration, x=x, fx=fx,
                derivative=dfx, next_x=NaN, next_fx=NaN))
            status = :zero_derivative
            break
        end

        next_x = x - fx / dfx
        next_fx = root_example_function(next_x)
        push!(history, (iteration=iteration, x=x, fx=fx,
            derivative=dfx, next_x=next_x, next_fx=next_fx))

        if abs(next_fx) <= tolerance || abs(next_x - x) <= tolerance
            status = :converged
            break
        end
        x = next_x
    end

    return history, status
end

function newton_visualization_plot(;
    x0::Real=3.0,
    iteration::Int=1,
    tolerance::Real=1e-8,
)
    iteration >= 1 || error("iteration must be positive.")
    history, status = newton_visualization_history(x0; tolerance=tolerance)

    if isempty(history)
        p = root_base_plot(title="Newton: initial guess is already a root")
        scatter!(p, [x0], [0.0]; color=:red, markersize=7,
            label="x₀ = $(compact_root(x0))")
        return p
    end

    shown_iteration = min(iteration, length(history))
    h = history[shown_iteration]
    title = "Newton $(shown_iteration): xₖ = $(compact_root(h.x))"
    iteration > length(history) && status == :converged && (title *= " (converged)")
    p = root_base_plot(title=title)
    xgrid = range(ROOT_XLIMS[1], ROOT_XLIMS[2]; length=600)
    tangent(x) = h.fx + h.derivative * (x - h.x)

    plot!(p, xgrid, tangent.(xgrid); color=:blue, linestyle=:dash,
        linewidth=2, label="tangent; f′(xₖ) = $(compact_root(h.derivative))")
    scatter!(p, [h.x], [h.fx]; color=:blue, markerstrokecolor=:blue,
        markersize=7, label="(xₖ, f(xₖ))")
    plot!(p, [h.x, h.x], [0.0, h.fx]; color=:gray,
        linestyle=:dot, linewidth=1.5, label=false)

    if isnan(h.next_x)
        annotate!(p, 1.7, 18.5, text("Newton step undefined: f′(xₖ) = 0", 9, :center))
    elseif ROOT_XLIMS[1] <= h.next_x <= ROOT_XLIMS[2]
        scatter!(p, [h.next_x], [0.0]; color=:red, markerstrokecolor=:red,
            markersize=7, label="xₖ₊₁ = $(compact_root(h.next_x))")
    else
        direction = h.next_x < ROOT_XLIMS[1] ? "left" : "right"
        annotate!(p, 1.7, 18.5,
            text("next iterate = $(compact_root(h.next_x)) (off graph to the $(direction))", 9, :center))
    end
    return p
end

function root_finding_comparison_plot(;
    a::Real=0.0,
    b::Real=5.0,
    x0::Real=3.0,
    bisection_iteration::Int=1,
    newton_iteration::Int=1,
    tolerance::Real=1e-8,
)
    bisection_plot = bisection_visualization_plot(
        a=a, b=b, iteration=bisection_iteration, tolerance=tolerance)
    newton_plot = newton_visualization_plot(
        x0=x0, iteration=newton_iteration, tolerance=tolerance)

    return plot(
        bisection_plot,
        newton_plot;
        layout=(1, 2),
        size=(1100, 480),
        plot_title="Fixed tolerance = 10⁻⁸",
    )
end
