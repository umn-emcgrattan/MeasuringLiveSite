using DelimitedFiles, HypertextLiteral
include("scripts/ipp_io_helpers.jl")

const PREVIEW_DIR = joinpath(@__DIR__, "tmp")
mkpath(PREVIEW_DIR)

input_bridge_path = joinpath(PREVIEW_DIR, "pre1999_total_input_no_account.html")
open(input_bridge_path, "w") do io
    show(io, MIME"text/html"(), ipp_pre1999_total_input_html(2017; show_title=true))
end
println("Wrote $(input_bridge_path)")

output_bridge_path = joinpath(PREVIEW_DIR, "pre1999_total_output_no_account.html")
open(output_bridge_path, "w") do io
    show(io, MIME"text/html"(), ipp_pre1999_total_output_html(2017; show_title=true))
end
println("Wrote $(output_bridge_path)")

use_output_path = joinpath(PREVIEW_DIR, "total_use_gross_output.html")
open(use_output_path, "w") do io
    show(io, MIME"text/html"(), ipp_total_use_gross_output_html(2017; show_title=true))
end
println("Wrote $(use_output_path)")

