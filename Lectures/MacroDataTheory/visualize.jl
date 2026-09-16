using DelimitedFiles, Plots, PlutoUI, HypertextLiteral

include("scripts/macro_data_theory_helpers.jl")

const PREVIEW_DIR = joinpath(@__DIR__, "tmp")
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

fig1 = macro_gdp_gdi_plot()

# --------------------------------------------------
# Tables
# --------------------------------------------------

table1 = macro_nipa_table_html(2024; show_title = true)
table1_path = write_preview_html("table1.html", table1)
run(`open $(table1_path)`)

table2 = macro_model_accounts_html(2024; show_title = true)
table2_path = write_preview_html("table2.html", table2)
run(`open $(table2_path)`)
