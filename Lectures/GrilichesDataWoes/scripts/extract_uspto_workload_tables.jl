# Extract recent fiscal-year utility patent applications from the USPTO
# Annual Report workload tables into a stable source CSV.

using XLSX

include(joinpath(@__DIR__, "griliches_historical_productivity.jl"))

function extract_uspto_workload_utility_applications(
    workbook_path::AbstractString = joinpath(@__DIR__, "..", "originals", "USPTOFY24WorkloadTables.xlsx"),
    out_path::AbstractString = joinpath(@__DIR__, "..", "source_csv", "uspto_patent_applications", "workload_tables_fy_utility_applications.csv"),
)
    isfile(workbook_path) || error("Missing USPTO workload workbook: $(workbook_path)")

    rows = NamedTuple[]
    XLSX.openxlsx(workbook_path) do xf
        sheet = xf["Table 2 (Patents)"]
        for r in 6:52
            year = sheet[r, 1]
            utility = sheet[r, 2]
            if year isa Integer && utility isa Real
                push!(
                    rows,
                    (
                        fiscal_year = Int(year),
                        utility_applications = Float64(utility),
                    ),
                )
            end
        end
    end

    isempty(rows) && error("No utility application rows found in $(workbook_path)")
    rows = sort(rows; by = r -> r.fiscal_year)

    header = [
        "year",
        "utility_applications",
        "source_note",
    ]
    body = [
        [
            r.fiscal_year,
            r.utility_applications,
            r.fiscal_year == 2024 ?
                "USPTO FY2024 Workload Tables, Table 2 (Patents), fiscal year; FY2024 preliminary." :
                "USPTO FY2024 Workload Tables, Table 2 (Patents), fiscal year.",
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

if abspath(PROGRAM_FILE) == @__FILE__
    println(extract_uspto_workload_utility_applications())
end
