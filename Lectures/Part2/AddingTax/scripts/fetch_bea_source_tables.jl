using BeaData
using CSV
using DataFrames
using Dates
using Printf

const START_YEAR = 1929
const DEFAULT_END_YEAR = year(today()) - 1

struct SourceLine
    line::String
    label::String
    indent::Int
    bold::Bool
end

const SOURCE_LINES = [
    SourceLine("01", "Current receipts", 4, true),
    SourceLine("02", "Current tax receipts", 0, false),
    SourceLine("03", "Personal current taxes", 2, false),
    SourceLine("04", "Taxes on production and imports", 2, false),
    SourceLine("05", "Taxes on corporate income", 2, false),
    SourceLine("06", "Taxes from the rest of the world", 2, false),
    SourceLine("07", "Contributions for government social insurance", 0, false),
    SourceLine("08", "From persons", 2, false),
    SourceLine("09", "From the rest of the world", 2, false),
    SourceLine("10", "Income receipts on assets", 0, false),
    SourceLine("11", "Interest and miscellaneous receipts", 2, false),
    SourceLine("12", "Interest receipts", 4, false),
    SourceLine("13", "Rents and royalties", 4, false),
    SourceLine("14", "Dividends", 2, false),
    SourceLine("15", "Current transfer receipts", 0, false),
    SourceLine("16", "From business (net)", 2, false),
    SourceLine("17", "From persons", 2, false),
    SourceLine("18", "From the rest of the world", 2, false),
    SourceLine("19", "Current surplus of government enterprises", 0, false),
    SourceLine("20", "Current expenditures", 4, true),
    SourceLine("21", "Consumption expenditures", 0, false),
    SourceLine("22", "Current transfer payments", 0, false),
    SourceLine("23", "Government social benefits", 2, false),
    SourceLine("24", "To persons", 4, false),
    SourceLine("25", "To the rest of the world", 4, false),
    SourceLine("26", "Other current transfer payments to the rest of the world", 2, false),
    SourceLine("27", "Interest payments", 0, false),
    SourceLine("28", "To persons and business", 2, false),
    SourceLine("29", "To the rest of the world", 2, false),
    SourceLine("30", "Subsidies", 0, false),
    SourceLine("31", "Net government saving", 4, true),
    SourceLine("32", "Social insurance funds", 0, false),
    SourceLine("33", "Other", 0, false),
    SourceLine("34", "Total receipts", 2, true),
    SourceLine("35", "Current receipts", 4, false),
    SourceLine("36", "Capital transfer receipts", 4, false),
    SourceLine("37", "Total expenditures", 2, true),
    SourceLine("38", "Current expenditures", 4, false),
    SourceLine("39", "Gross government investment", 4, false),
    SourceLine("40", "Capital transfer payments", 4, false),
    SourceLine("41", "Net purchases of nonproduced assets", 4, false),
    SourceLine("42", "Less: Consumption of fixed capital", 4, false),
    SourceLine("43", "Net lending or net borrowing (-)", 2, true),
]

function parse_args(args)
    end_year = DEFAULT_END_YEAR
    i = 1
    while i <= length(args)
        if args[i] == "--end-year"
            i == length(args) && error("--end-year requires a value")
            end_year = parse(Int, args[i + 1])
            i += 2
        elseif startswith(args[i], "--end-year=")
            end_year = parse(Int, split(args[i], "=", limit = 2)[2])
            i += 1
        else
            error("Unknown argument: $(args[i])")
        end
    end
    START_YEAR <= end_year <= year(today()) || error("Invalid end year: $(end_year)")
    end_year
end

function main()
    end_year = parse_args(ARGS)
    @printf("Fetching BEA NIPA T30100, %d-%d\n", START_YEAR, end_year)
    key = get(ENV, "BEA_API_KEY", "")
    table = if isempty(key)
        # BeaData may have a user ID in its configuration outside this lecture.
        bea_table("NIPA", "T30100", "A", START_YEAR, end_year)
    else
        bea_table("NIPA", "T30100", "A", START_YEAR, end_year; user_id = key)
    end
    by_year = Dict(year(row.TimePeriod) => row for row in eachrow(table.data_values))

    out = DataFrame(
        Dataset = String[], Table = String[], Line = String[], Label = String[],
        Indent = Int[], Bold = Bool[], Unit = String[], Year = Int[],
        Value = Union{Missing,Float64}[],
    )
    for spec in SOURCE_LINES, yr in START_YEAR:end_year
        col = Symbol("Line" * spec.line)
        String(col) in names(table.data_values) || error("Missing $(col) in BEA response.")
        value = haskey(by_year, yr) ? by_year[yr][col] : missing
        push!(out, ("NIPA", "T30100", string(parse(Int, spec.line)), spec.label,
                    spec.indent, spec.bold, "Billions of dollars", yr,
                    ismissing(value) ? missing : Float64(value)))
    end

    root = normpath(joinpath(@__DIR__, ".."))
    path = joinpath(root, "source_csv", "bea_nipa", "table_3_1.csv")
    mkpath(dirname(path))
    CSV.write(path, out)
    println("Wrote $(path)")
end

main()
