using Plots

include(joinpath(@__DIR__, "src", "vfi.jl"))

const TMP_DIR = joinpath(@__DIR__, "tmp")
mkpath(TMP_DIR)

function method1_general_log_consumption_plot(; nk::Int, nh::Int = 9)
    model = default_growth_model()
    nk_choice = 5 * nk

    continuous = solve_vfi_continuous_z(
        model = model,
        nk = nk,
        nz = 11,
        nh = nh,
        nk_choice = nk_choice,
        nquad = 7,
        k_min_factor = 0.40,
        k_max_factor = 1.80,
        z_width = 5.0,
        log_k_grid = true,
        tol = 1e-4,
        maxit = 300,
        print_every = 0,
    )

    markov = solve_vfi_markov_z(
        model = model,
        nk = nk,
        nz = 11,
        nh = nh,
        nk_choice = nk_choice,
        k_min_factor = 0.40,
        k_max_factor = 1.80,
        z_width = 5.0,
        log_k_grid = true,
        tol = 1e-4,
        maxit = 300,
        print_every = 0,
    )

    z_indices = [3, 5, 6, 7, 9]
    panels = []

    for iz in z_indices
        logz = continuous.z_grid[iz]
        subtitle = @sprintf("log z = %.3f", logz)

        panel = plot(
            log.(continuous.k_grid),
            log.(continuous.policy_c[:, iz]),
            label = "continuous z VFI",
            linewidth = 2,
            xlabel = "log current capital, log k",
            ylabel = "log consumption, log c",
            title = subtitle,
            legend = iz == z_indices[1] ? :topleft : false,
        )

        plot!(
            panel,
            log.(markov.k_grid),
            log.(markov.policy_c[:, iz]),
            label = "Markov z VFI",
            linewidth = 2,
            linestyle = :dash,
        )

        push!(panels, panel)
    end

    p = plot(
        panels...,
        layout = (2, 3),
        size = (1100, 650),
        plot_title = "General economy: Method I log consumption rules, nk = $(nk)",
    )

    return p, continuous, markov
end

function method1_general_residual_experiment()
    model = default_growth_model()
    solution = solve_vfi_continuous_z(
        model = model,
        nk = 61,
        nz = 11,
        nh = 41,
        nk_choice = 401,
        nquad = 7,
        k_min_factor = 0.40,
        k_max_factor = 1.80,
        z_width = 5.0,
        log_k_grid = true,
        tol = 1e-4,
        maxit = 300,
        print_every = 50,
    )

    residuals = foc_residuals_continuous(solution)
    print_foc_residual_summary(residuals; label = "General economy continuous-z residuals, nk = 61, nh = 41")

    euler_path = joinpath(TMP_DIR, "method1_general_euler_residuals_continuous_nk061_nh041.png")
    labor_path = joinpath(TMP_DIR, "method1_general_labor_residuals_continuous_nk061_nh041.png")

    savefig(
        method1_residual_slice_plot(
            solution,
            residuals.euler;
            title = "Euler residuals: continuous z VFI, nk = 61, nh = 41",
        ),
        euler_path,
    )
    savefig(
        method1_residual_slice_plot(
            solution,
            labor_residual_as_matrix(residuals);
            title = "Labor residuals: continuous z VFI, nk = 61, nh = 41",
        ),
        labor_path,
    )

    println("Wrote ", euler_path)
    println("Wrote ", labor_path)
end

function maximum_policy_gaps(solution1, solution2)
    return (
        maximum(abs.(solution1.policy_c .- solution2.policy_c)),
        maximum(abs.(solution1.policy_k .- solution2.policy_k)),
        maximum(abs.(solution1.policy_h .- solution2.policy_h)),
    )
end

function method1_residual_slice_plot(solution, residual_matrix; title)
    z_indices = [3, 5, 6, 7, 9]
    p = plot(
        xlabel = "log current capital, log k",
        ylabel = "FOC residual",
        title = title,
        legend = :outertopright,
        size = (850, 550),
    )
    plot!(p, log.(solution.k_grid), zeros(length(solution.k_grid)); color = :black, linestyle = :dot, label = "zero")
    for iz in z_indices
        plot!(
            p,
            log.(solution.k_grid),
            residual_matrix[:, iz],
            linewidth = 2,
            label = @sprintf("log z = %.3f", solution.z_grid[iz]),
        )
    end
    return p
end

function labor_residual_as_matrix(residuals)
    out = fill(NaN, size(residuals.euler))
    for idx in eachindex(residuals.labor)
        x = residuals.labor[idx]
        out[idx] = ismissing(x) ? NaN : x
    end
    return out
end

function method1_check_consumption_plot()
    model = check_growth_model()

    continuous = solve_vfi_continuous_z(
        model = model,
        nk = 61,
        nz = 15,
        nh = 1,
        nk_choice = 601,
        nquad = 7,
        k_min_factor = 0.40,
        k_max_factor = 1.80,
        z_width = 5.0,
        log_k_grid = true,
        tol = 1e-5,
        maxit = 1000,
        print_every = 0,
    )

    markov = solve_vfi_markov_z(
        model = model,
        nk = 61,
        nz = 15,
        nh = 1,
        nk_choice = 601,
        k_min_factor = 0.40,
        k_max_factor = 1.80,
        z_width = 5.0,
        log_k_grid = true,
        tol = 1e-5,
        maxit = 1000,
        print_every = 0,
    )

    z_indices = [5, 7, 8, 9, 11]
    panels = []

    for iz in z_indices
        logz = continuous.z_grid[iz]
        exact_c = [analytic_check_policy_c(k, logz, model) for k in continuous.k_grid]
        subtitle = @sprintf("log z = %.3f", logz)

        panel = plot(
            log.(continuous.k_grid),
            exact_c,
            label = "exact",
            color = :black,
            linewidth = 2.5,
            xlabel = "log current capital, log k",
            ylabel = "consumption, c",
            title = subtitle,
            legend = iz == z_indices[1] ? :topleft : false,
        )

        plot!(
            panel,
            log.(continuous.k_grid),
            continuous.policy_c[:, iz],
            label = "continuous z VFI",
            linewidth = 2,
            linestyle = :dash,
        )

        plot!(
            panel,
            log.(markov.k_grid),
            markov.policy_c[:, iz],
            label = "Markov z VFI",
            linewidth = 2,
            linestyle = :dot,
        )

        push!(panels, panel)
    end

    p = plot(
        panels...,
        layout = (2, 3),
        size = (1100, 650),
        plot_title = "Check economy: consumption rules over k and z",
    )

    return p, continuous, markov
end

for nk in [41, 61, 81]
    plot1, continuous_solution, markov_solution = method1_general_log_consumption_plot(nk = nk)
    plot1_path = joinpath(TMP_DIR, @sprintf("method1_general_logc_nk%03d.png", nk))
    savefig(plot1, plot1_path)

    println("Wrote ", plot1_path)
    println()
    print_vfi_summary(continuous_solution; label = "General economy, continuous log z, nk = $(nk)")
    println()
    print_vfi_summary(markov_solution; label = "General economy, Markov-chain log z, nk = $(nk)")
    gap_c, gap_k, gap_h = maximum_policy_gaps(continuous_solution, markov_solution)
    println()
    println("General economy: continuous-z versus Markov-z policy gaps, nk = ", nk)
    @printf("max |c_continuous - c_markov|    %.8e\n", gap_c)
    @printf("max |k'_continuous - k'_markov|  %.8e\n", gap_k)
    @printf("max |h_continuous - h_markov|    %.8e\n", gap_h)
    println()

    if nk == 61
        continuous_residuals = foc_residuals_continuous(continuous_solution)
        markov_residuals = foc_residuals_markov(markov_solution)
        print_foc_residual_summary(continuous_residuals; label = "General economy continuous-z residuals, nk = $(nk)")
        print_foc_residual_summary(markov_residuals; label = "General economy Markov-z residuals, nk = $(nk)")
        println()

        euler_cont_path = joinpath(TMP_DIR, "method1_general_euler_residuals_continuous_nk061.png")
        euler_markov_path = joinpath(TMP_DIR, "method1_general_euler_residuals_markov_nk061.png")
        labor_cont_path = joinpath(TMP_DIR, "method1_general_labor_residuals_continuous_nk061.png")
        labor_markov_path = joinpath(TMP_DIR, "method1_general_labor_residuals_markov_nk061.png")

        savefig(
            method1_residual_slice_plot(
                continuous_solution,
                continuous_residuals.euler;
                title = "Euler residuals: continuous z VFI, nk = $(nk)",
            ),
            euler_cont_path,
        )
        savefig(
            method1_residual_slice_plot(
                markov_solution,
                markov_residuals.euler;
                title = "Euler residuals: Markov z VFI, nk = $(nk)",
            ),
            euler_markov_path,
        )
        savefig(
            method1_residual_slice_plot(
                continuous_solution,
                labor_residual_as_matrix(continuous_residuals);
                title = "Labor residuals: continuous z VFI, nk = $(nk)",
            ),
            labor_cont_path,
        )
        savefig(
            method1_residual_slice_plot(
                markov_solution,
                labor_residual_as_matrix(markov_residuals);
                title = "Labor residuals: Markov z VFI, nk = $(nk)",
            ),
            labor_markov_path,
        )

        println("Wrote ", euler_cont_path)
        println("Wrote ", euler_markov_path)
        println("Wrote ", labor_cont_path)
        println("Wrote ", labor_markov_path)
        println()
    end
end

method1_general_residual_experiment()
