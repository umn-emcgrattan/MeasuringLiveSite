using CSV
using DataFrames

const ROOT = normpath(joinpath(@__DIR__, ".."))
const SOURCE_DIR = joinpath(ROOT, "source_csv", "bea_io_benchmark")
const OUTPUT = joinpath(ROOT, "csv", "ipp_io_matrix.csv")
const IPP_CODES = Set(["511200", "512100", "512200", "541700", "711500"])
const IPP_FINAL = Set(["F02N00", "F06N00", "F07N00", "F10N00"])

parsevalue(x) = ismissing(x) || isempty(strip(string(x))) ? 0.0 : parse(Float64, replace(string(x), "," => ""))

function matrix_for_year(year)
    path = joinpath(SOURCE_DIR, "use_detail_$(year).csv")
    raw = CSV.read(path, DataFrame; header=false, types=String, silencewarnings=true)
    codes = strip.(coalesce.(Vector(raw[1, 3:end]), ""))
    descriptions = strip.(coalesce.(Vector(raw[2, 3:end]), ""))
    body = raw[3:end, :]
    rowcodes = strip.(coalesce.(Vector(body[:, 1]), ""))

    industry_columns = findall(c -> !(startswith(c, "F") || c in ("T001", "T019")), codes)
    ipp_industries = filter(i -> codes[i] in IPP_CODES, industry_columns)
    other_industries = filter(i -> !(codes[i] in IPP_CODES), industry_columns)
    final_columns = findall(c -> startswith(c, "F"), codes)
    ipp_final = filter(i -> codes[i] in IPP_FINAL, final_columns)
    other_final = filter(i -> !(codes[i] in IPP_FINAL), final_columns)
    total_use = only(findall(==("T019"), codes))

    commodity_rows = findall(c -> !(c in ("T005", "V00100", "T00OTOP", "V00300", "VABAS", "T018", "T00TOP", "T00SUB", "VAPRO")), rowcodes)
    ipp_rows = filter(i -> rowcodes[i] in IPP_CODES, commodity_rows)
    other_rows = filter(i -> !(rowcodes[i] in IPP_CODES), commodity_rows)
    value(row, column) = parsevalue(body[row, column + 2]) / 1000
    block(rows, cols) = sum(value(r, c) for r in rows, c in cols)
    one(rowcode, cols) = block([only(findall(==(rowcode), rowcodes))], cols)

    output = DataFrame(Year=Int[], Row=String[], IPPIndustries=Float64[],
                       OtherIndustries=Float64[], IPPFinalDemand=Float64[],
                       OtherFinalDemand=Float64[], TotalUse=Float64[])
    for (label, rows) in (("IPP-related commodities", ipp_rows), ("Non-IPP commodities", other_rows))
        push!(output, (year, label, block(rows, ipp_industries), block(rows, other_industries),
                       block(rows, ipp_final), block(rows, other_final), block(rows, [total_use])))
    end
    push!(output, (year, "Intermediate inputs", one("T005", ipp_industries),
                   one("T005", other_industries), 0, 0,
                   one("T005", industry_columns)))
    push!(output, (year, "Value added", one("VABAS", ipp_industries),
                   one("VABAS", other_industries), 0, 0, one("VABAS", [only(findall(==("T001"), codes))])))
    push!(output, (year, "Gross output", one("T018", ipp_industries),
                   one("T018", other_industries), 0, 0, one("T018", [only(findall(==("T001"), codes))])))
    output
end

result = reduce(vcat, matrix_for_year.((2007, 2012, 2017)))
for year in unique(result.Year)
    x = result[result.Year .== year, :]
    intermediate = x[x.Row .== "Intermediate inputs", :]
    valueadded = x[x.Row .== "Value added", :]
    output = x[x.Row .== "Gross output", :]
    for column in (:IPPIndustries, :OtherIndustries)
        # Published detail may not add to totals because every cell is rounded
        # to the nearest million dollars.
        isapprox(intermediate[1, column] + valueadded[1, column], output[1, column]; atol=.5) ||
            error("Production identity failed for $(year), $(column).")
    end
end
mkpath(dirname(OUTPUT)); CSV.write(OUTPUT, result); println("Wrote $(OUTPUT)")

