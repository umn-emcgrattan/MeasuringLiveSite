using CSV
using DataFrames

const ROOT = normpath(joinpath(@__DIR__, ".."))
const IO_DIR = joinpath(ROOT, "source_csv", "bea_io_benchmark")
const NIPA_SOURCE = joinpath(ROOT, "source_csv", "bea_nipa", "table_5_6_5_software.csv")
const GOV_SOURCE = joinpath(ROOT, "source_csv", "bea_nipa", "table_5_9_5_government_ipp.csv")
const OUTPUT = joinpath(ROOT, "csv", "ipp_capitalization_benchmark.csv")

number(x) = ismissing(x) || isempty(strip(string(x))) ? 0.0 : parse(Float64, replace(string(x), "," => ""))

function io_column_total(year, code)
    raw = CSV.read(joinpath(IO_DIR, "use_detail_$(year).csv"), DataFrame;
                   header=false, types=String, silencewarnings=true)
    codes = strip.(coalesce.(Vector(raw[1, 3:end]), ""))
    column = only(findall(==(code), codes)) + 2
    body = raw[3:end, :]
    rowcodes = strip.(coalesce.(Vector(body[:, 1]), ""))
    total_row = only(findall(==("T005"), rowcodes))
    number(body[total_row, column]) / 1000
end

nipa = CSV.read(NIPA_SOURCE, DataFrame)
government = CSV.read(GOV_SOURCE, DataFrame)
function nipa_value(year, line)
    rows = nipa[(nipa.Year .== year) .& (nipa.Line .== line), :]
    nrow(rows) == 1 || error("Expected one NIPA line $(line) for $(year).")
    Float64(rows.Value[1])
end
function government_value(year, line)
    rows = government[(government.Year .== year) .& (government.Line .== line), :]
    nrow(rows) == 1 || error("Expected one government NIPA line $(line) for $(year).")
    Float64(rows.Value[1])
end

out = DataFrame(
    Year=Int[], IOTotalIPP=Float64[], IOPrivateIPP=Float64[], IOGovernmentIPP=Float64[],
    NIPAPrivateIPP=Float64[], Software=Float64[], PurchasedSoftware=Float64[],
    OwnAccountSoftware=Float64[], ResearchDevelopment=Float64[], ArtisticOriginals=Float64[],
    GovernmentSoftware=Float64[], GovernmentResearchDevelopment=Float64[],
    SoftwareAllSectors=Float64[], ResearchDevelopmentAllSectors=Float64[],
    OtherIPPAllSectors=Float64[], PrivateReconciliationDifference=Float64[],
)
for year in (2007, 2012, 2017)
    private_io = io_column_total(year, "F02N00")
    government_io = sum(io_column_total(year, code) for code in ("F06N00", "F07N00", "F10N00"))
    private_nipa = nipa_value(year, 1)
    software = nipa_value(year, 2)
    purchased = nipa_value(year, 3) + nipa_value(year, 4)
    own = nipa_value(year, 5)
    rd = nipa_value(year, 6)
    artistic = nipa_value(year, 26)
    government_software = sum(government_value(year, line) for line in (60, 63, 66))
    government_rd = sum(government_value(year, line) for line in (61, 64, 67))
    push!(out, (year, private_io + government_io, private_io, government_io,
                private_nipa, software, purchased, own, rd, artistic,
                government_software, government_rd, software + government_software,
                rd + government_rd, artistic,
                private_io - private_nipa))
end
mkpath(dirname(OUTPUT)); CSV.write(OUTPUT, out); println("Wrote $(OUTPUT)")

