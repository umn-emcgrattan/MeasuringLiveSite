using CSV
using DataFrames

const ROOT = normpath(joinpath(@__DIR__, ".."))
const IO_SOURCE = joinpath(ROOT, "source_csv", "bea_io", "use_15_sector.csv")
const SW_SOURCE = joinpath(ROOT, "source_csv", "bea_nipa", "table_5_6_5_software.csv")
const OUTPUT = joinpath(ROOT, "csv", "software_io_remapping.csv")

io = CSV.read(IO_SOURCE, DataFrame)
sw = CSV.read(SW_SOURCE, DataFrame)

function one_value(df, year, column, value)
    rows = df[(df.Year .== year) .& (df[!, column] .== value), :]
    nrow(rows) == 1 || error("Expected one $(column)=$(value) observation for $(year).")
    ismissing(rows.Value[1]) && error("Missing $(column)=$(value) observation for $(year).")
    Float64(rows.Value[1])
end

out = DataFrame(
    Year=Int[], IntermediateInputsAfter=Float64[], ValueAddedAfter=Float64[],
    GrossOutputAfter=Float64[], PurchasedSoftware=Float64[],
    OwnAccountSoftware=Float64[], SoftwareInvestmentAfter=Float64[],
    IntermediateInputsBefore=Float64[], ValueAddedBefore=Float64[],
    GrossOutputBefore=Float64[],
)

for yr in sort(intersect(unique(io.Year), unique(sw.Year)))
    intermediate = one_value(io, yr, :RowCode, "T005") / 1000
    value_added = one_value(io, yr, :RowCode, "VABAS") / 1000
    gross_output = one_value(io, yr, :RowCode, "T018") / 1000
    prepackaged = one_value(sw, yr, :Line, 3)
    custom = one_value(sw, yr, :Line, 4)
    own_account = one_value(sw, yr, :Line, 5)
    purchased = prepackaged + custom
    push!(out, (yr, intermediate, value_added, gross_output, purchased, own_account,
                purchased + own_account, intermediate + purchased,
                value_added - purchased - own_account, gross_output - own_account))
end

all(isapprox.(out.IntermediateInputsAfter .+ out.ValueAddedAfter,
              out.GrossOutputAfter; atol=0.002)) || error("Current production identity failed.")
all(isapprox.(out.IntermediateInputsBefore .+ out.ValueAddedBefore,
              out.GrossOutputBefore; atol=0.002)) || error("Reconstructed production identity failed.")

mkpath(dirname(OUTPUT)); CSV.write(OUTPUT, out); println("Wrote $(OUTPUT)")

