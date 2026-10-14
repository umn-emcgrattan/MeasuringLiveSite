using DelimitedFiles, Plots, HypertextLiteral

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

fig1 = macro_receipt_expenditure_plot()
savefig(fig1, joinpath(PREVIEW_DIR, "government_receipts_expenditures.png"))

table1 = macro_nipa_govt_table_html(2024; show_title = true)
table1_path = write_preview_html("government_receipts_expenditures.html", table1)

println("Wrote $(table1_path)")
println("Wrote $(joinpath(PREVIEW_DIR, "government_receipts_expenditures.png"))")

