using BeaData
using CSV
using DataFrames
using Dates
using Printf

const START_YEAR = 1929
const DEFAULT_END_YEAR = 2025

struct SourceLine
    dataset::String
    table::String
    line::String
    label::String
    unit::String
end

source_line(dataset, table, line, label; unit = "Millions of dollars") =
    SourceLine(dataset, table, line, label, unit)

const SOURCE_LINES = [
    source_line("NIPA", "T10105", "01", "Gross domestic product"),
    source_line("NIPA", "T10105", "02", "Personal consumption expenditures"),
    source_line("NIPA", "T10105", "03", "Goods"),
    source_line("NIPA", "T10105", "04", "Durable goods"),
    source_line("NIPA", "T10105", "05", "Nondurable goods"),
    source_line("NIPA", "T10105", "06", "Services"),
    source_line("NIPA", "T10105", "07", "Gross private domestic investment"),
    source_line("NIPA", "T10105", "08", "Fixed investment"),
    source_line("NIPA", "T10105", "09", "Nonresidential fixed investment"),
    source_line("NIPA", "T10105", "10", "Structures"),
    source_line("NIPA", "T10105", "11", "Equipment"),
    source_line("NIPA", "T10105", "12", "Intellectual property products"),
    source_line("NIPA", "T10105", "13", "Residential fixed investment"),
    source_line("NIPA", "T10105", "14", "Change in private inventories"),
    source_line("NIPA", "T10105", "15", "Net exports of goods and services"),
    source_line("NIPA", "T10105", "16", "Exports"),
    source_line("NIPA", "T10105", "17", "Exports: Goods"),
    source_line("NIPA", "T10105", "18", "Exports: Services"),
    source_line("NIPA", "T10105", "19", "Imports"),
    source_line("NIPA", "T10105", "20", "Imports: Goods"),
    source_line("NIPA", "T10105", "21", "Imports: Services"),
    source_line("NIPA", "T10105", "22", "Government consumption expenditures and gross investment"),
    source_line("NIPA", "T10105", "23", "Federal"),
    source_line("NIPA", "T10105", "24", "National defense"),
    source_line("NIPA", "T10105", "25", "Nondefense"),
    source_line("NIPA", "T10105", "26", "State and local"),
    source_line("NIPA", "T11000", "01", "Gross domestic income"),
    source_line("NIPA", "T11000", "02", "Compensation of employees, paid"),
    source_line("NIPA", "T11000", "03", "Wages and salaries"),
    source_line("NIPA", "T11000", "04", "Wages and salaries: To persons"),
    source_line("NIPA", "T11000", "05", "Wages and salaries: To the rest of the world"),
    source_line("NIPA", "T11000", "06", "Supplements to wages and salaries"),
    source_line("NIPA", "T11000", "07", "Taxes on production and imports"),
    source_line("NIPA", "T11000", "08", "Subsidies"),
    source_line("NIPA", "T11000", "09", "Net operating surplus"),
    source_line("NIPA", "T11000", "10", "Private enterprises net operating surplus"),
    source_line("NIPA", "T11000", "11", "Net interest and miscellaneous payments"),
    source_line("NIPA", "T11000", "12", "Business current transfer payments"),
    source_line("NIPA", "T11000", "13", "Proprietors' income"),
    source_line("NIPA", "T11000", "14", "Rental income of persons"),
    source_line("NIPA", "T11000", "15", "Corporate profits"),
    source_line("NIPA", "T11000", "16", "Taxes on corporate income"),
    source_line("NIPA", "T11000", "17", "Profits after tax"),
    source_line("NIPA", "T11000", "18", "Net dividends"),
    source_line("NIPA", "T11000", "19", "Undistributed corporate profits"),
    source_line("NIPA", "T11000", "20", "Current surplus of government enterprises"),
    source_line("NIPA", "T11000", "21", "Consumption of fixed capital"),
    source_line("NIPA", "T11000", "22", "Private consumption of fixed capital"),
    source_line("NIPA", "T11000", "23", "Government consumption of fixed capital"),
    source_line("NIPA", "T11000", "24", "Statistical discrepancy"),
    source_line("NIPA", "T30500", "20", "State and local sales taxes"),
    source_line("NIPA", "T30905", "17", "Federal national defense consumption expenditures and gross investment"),
    source_line("NIPA", "T30905", "26", "Federal nondefense consumption expenditures"),
    source_line("NIPA", "T30905", "27", "Federal nondefense gross investment"),
    source_line("NIPA", "T30905", "34", "State and local government consumption expenditures"),
    source_line("NIPA", "T30905", "35", "State and local government gross investment"),
    source_line("FixedAssets", "FAAt101", "09", "Current-cost net stock of government fixed assets"),
    source_line("FixedAssets", "FAAt101", "15", "Current-cost net stock of consumer durable goods"),
    source_line("FixedAssets", "FAAt804", "01", "Current-cost depreciation of consumer durable goods"),
]

function parse_args(args)
    end_year = DEFAULT_END_YEAR
    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "--end-year"
            i == length(args) && error("--end-year requires a value")
            end_year = parse(Int, args[i + 1])
            i += 2
        elseif startswith(arg, "--end-year=")
            end_year = parse(Int, split(arg, "=", limit = 2)[2])
            i += 1
        elseif arg == "--help" || arg == "-h"
            println("""
            Usage:
              julia scripts/fetch_bea_source_tables.jl [--end-year YEAR]

            Writes direct source extracts under source_csv/.
            """)
            exit(0)
        else
            error("Unknown argument: $(arg)")
        end
    end
    end_year < START_YEAR && error("end year must be at least $(START_YEAR)")
    (; end_year)
end

function fetch_bea_table(dataset, table, start_year, end_year)
    key = get(ENV, "BEA_API_KEY", "")
    if isempty(key)
        bea_table(dataset, table, "A", start_year, end_year)
    else
        bea_table(dataset, table, "A", start_year, end_year; user_id = key)
    end
end

function table_filename(dataset, table)
    names = Dict(
        ("NIPA", "T10105") => joinpath("source_csv", "bea_nipa", "table_1_1_5.csv"),
        ("NIPA", "T11000") => joinpath("source_csv", "bea_nipa", "table_1_10.csv"),
        ("NIPA", "T30500") => joinpath("source_csv", "bea_nipa", "table_3_5.csv"),
        ("NIPA", "T30905") => joinpath("source_csv", "bea_nipa", "table_3_9_5.csv"),
        ("FixedAssets", "FAAt101") => joinpath("source_csv", "bea_fixed_assets", "table_1_1.csv"),
        ("FixedAssets", "FAAt804") => joinpath("source_csv", "bea_fixed_assets", "table_8_4.csv"),
    )
    get(names, (dataset, table), joinpath("source_csv", lowercase(dataset), lowercase(table) * ".csv"))
end

function source_rows(specs, table_data, start_year, end_year)
    years = collect(start_year:end_year)
    rows = DataFrame(
        Dataset = String[],
        Table = String[],
        Line = String[],
        Label = String[],
        Unit = String[],
        Year = Int[],
        Value = Union{Missing,Float64}[],
    )

    by_year = Dict(year(row.TimePeriod) => row for row in eachrow(table_data.data_values))
    for spec in specs
        col = Symbol("Line" * spec.line)
        colname = String(col)
        colname in names(table_data.data_values) || error("Column $(colname) not found for $(spec.dataset) $(spec.table).")
        for yr in years
            x = haskey(by_year, yr) ? by_year[yr][col] : missing
            value = ismissing(x) ? missing : 1000.0 * Float64(x)
            push!(rows, (spec.dataset, spec.table, spec.line, spec.label, spec.unit, yr, value))
        end
    end
    rows
end

function main()
    args = parse_args(ARGS)
    root = normpath(joinpath(@__DIR__, ".."))
    grouped = Dict{Tuple{String,String},Vector{SourceLine}}()
    for spec in SOURCE_LINES
        push!(get!(grouped, (spec.dataset, spec.table), SourceLine[]), spec)
    end

    for ((dataset, table), specs) in sort(collect(grouped); by = x -> x[1])
        @printf("Fetching %s %s, %d-%d\n", dataset, table, START_YEAR, args.end_year)
        table_data = fetch_bea_table(dataset, table, START_YEAR, args.end_year)
        rows = source_rows(specs, table_data, START_YEAR, args.end_year)
        out_path = joinpath(root, table_filename(dataset, table))
        mkpath(dirname(out_path))
        CSV.write(out_path, rows)
        @printf("Wrote %s\n", out_path)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
