using DelimitedFiles, Plots, PlutoUI, HypertextLiteral

include("scripts/griliches_historical_productivity.jl")
include("scripts/griliches_klems_sector_compare.jl")
include("scripts/griliches_fixed_assets_ipp_compare.jl")

PREVIEW_DIR = joinpath(@__DIR__, "tmp")
mkpath(PREVIEW_DIR)

function write_preview_html(filename::AbstractString, html)
    path = joinpath(PREVIEW_DIR, filename)
    open(path, "w") do io
        show(io, MIME"text/html"(), html)
    end
    path
end

# --------------------------------------------------
# Figures
# --------------------------------------------------

fig1 = plot_griliches_productivity_1947_1990()
fig2 = plot_griliches_productivity_1947_2024()
fig3 = plot_griliches_rd_tfp_scatter()
fig4 = plot_griliches_rd_tfp_scatter_manufacturing()
fig5 = plot_griliches_patents_per_real_rd()

# --------------------------------------------------
# Tables
# --------------------------------------------------

table1 = griliches_klems_sector_compare_html(
    1963, 2024, show_title=true)

table1_path = write_preview_html("table1.html", table1)
run(`open $(table1_path)`)


table2 = griliches_klems_hours_compare_html(
    1963, 2024, show_title=true)
table2_path = write_preview_html("table2.html", table2)
run(`open $(table2_path)`)


table3 = griliches_ipp_investment_compare_html(
    1963, 2024, show_title=true)
table3_path = write_preview_html("table3.html", table3)
run(`open $(table3_path)`)
