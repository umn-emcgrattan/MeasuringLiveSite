# Fetch BEA Fixed Assets tables used by the patent/R&D figure.
#
# This is a source-acquisition step, not a figure transformation. It uses
# BeaData.jl, which reads the BEA UserID from ENV["BEA_USERID"] or ~/.beadatarc.

using BeaData
using CSV
using DataFrames
using Dates

const TABLE_EXPORTS = [
    ("FAAt207", "fa_table_2_7.csv"),
    ("FAAt208", "fa_table_2_8.csv"),
    ("FAAt105", "fa_table_1_5.csv"),
    ("FAAt307ESI", "fa_table_3_7esi.csv"),
    ("FAAt307I", "fa_table_3_7i.csv"),
]

function line_column_name(df::DataFrame, line_number)
    line = string(line_number)
    candidates = [
        Symbol("Line", line),
        Symbol("Line", lpad(line, 2, '0')),
        Symbol("Line", string(parse(Int, line))),
    ]
    for candidate in candidates
        if candidate in propertynames(df)
            return candidate
        end
    end
    error("Could not find data column for BEA line $(line_number)")
end

function export_bea_fixed_assets_table(table_name::AbstractString, out_path::AbstractString)
    table = bea_table("FixedAssets", table_name, "A", 0, 0)
    values = table.data_values

    out = DataFrame(
        TableName = String[],
        TableNumber = String[],
        TableDescription = String[],
        Metric = String[],
        Units = String[],
        LastRevised = String[],
        LineNumber = String[],
        LineDescription = String[],
        TimePeriod = Int[],
        DataValue = Float64[],
    )

    for line in eachrow(table.line_descriptions)
        col = line_column_name(values, line.LineNumber)
        for row in eachrow(values)
            value = row[col]
            if ismissing(value)
                continue
            end
            push!(
                out,
                (
                    table.api_tablename,
                    table.table_number,
                    table.table_description,
                    table.metric,
                    table.units,
                    table.last_revised,
                    string(line.LineNumber),
                    string(line.LineDescription),
                    year(row.TimePeriod),
                    Float64(value),
                ),
            )
        end
    end

    mkpath(dirname(out_path))
    CSV.write(out_path, out)
    out_path
end

function main(root::AbstractString = joinpath(@__DIR__, ".."))
    out_dir = joinpath(root, "source_csv", "bea_fixed_assets")
    for (table_name, filename) in TABLE_EXPORTS
        out_path = joinpath(out_dir, filename)
        println(export_bea_fixed_assets_table(table_name, out_path))
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
