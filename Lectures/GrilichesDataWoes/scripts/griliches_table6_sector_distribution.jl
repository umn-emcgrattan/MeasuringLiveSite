# Build a Table-6D-style historical sector distribution from archived BEA NIPA
# Table 6.1B/C/D source CSVs.
#
# Python is used upstream only to extract workbook sheets to CSV. This file
# contains the economic/classification mapping.

include(joinpath(@__DIR__, "griliches_historical_productivity.jl"))

TABLE6_ARCHIVE_NOTE =
    "BEA NIPA archive, 2024 Q1 Third estimate, released June 28, 2024; Section 6 Table 6.1B/C/D."

TABLE6_SECTOR_ORDER = [
    "Agriculture, forestry, fishing, and hunting",
    "Mining",
    "Utilities",
    "Construction",
    "Manufacturing",
    "Wholesale trade",
    "Retail trade",
    "Transportation and warehousing",
    "Information",
    "Finance, insurance, real estate, rental, and leasing",
    "Professional and business services",
    "Educational services, health care, and social assistance",
    "Arts, entertainment, recreation, accommodation, and food services",
    "Other services, except government",
    "Services",
    "Government",
    "Rest of the world",
]

TABLE6_SERVICE_DETAIL = Set([
    "Professional and business services",
    "Educational services, health care, and social assistance",
    "Arts, entertainment, recreation, accommodation, and food services",
    "Other services, except government",
])

function nipa_sheet_table(path::AbstractString)
    raw = read_csv_rows(path)
    header_row = findfirst(row -> !isempty(row) && strip(row[1]) == "Line", raw)
    isnothing(header_row) && error("Could not find NIPA table header row in $(path)")

    header = raw[header_row]
    year_cols = [(i, parse(Int, strip(v))) for (i, v) in enumerate(header) if occursin(r"^\d{4}$", strip(v))]
    rows_by_line = Dict{Int, NamedTuple}()

    for row in raw[(header_row + 1):end]
        isempty(row) && continue
        line_text = clean_number(row[1])
        line = isempty(line_text) ? nothing : tryparse(Int, line_text)
        isnothing(line) && continue

        values = Dict{Int, Union{Float64, Missing}}()
        for (col, year) in year_cols
            value = col <= length(row) ? maybe_float(row[col]) : nothing
            values[year] = isnothing(value) ? missing : value
        end

        rows_by_line[line] = (
            description = strip(row[2]),
            series_code = strip(row[3]),
            values = values,
        )
    end

    rows_by_line
end

function table_value(table, line::Int, year::Int)
    if !haskey(table, line) || !haskey(table[line].values, year)
        return missing
    end
    table[line].values[year]
end

function table_description(table, line::Int)
    haskey(table, line) ? table[line].description : ""
end

function table_series_code(table, line::Int)
    haskey(table, line) ? table[line].series_code : ""
end

function table6_push!(
    rows,
    year::Int,
    sector::AbstractString,
    value,
    denominator_national,
    denominator_domestic,
    source_table::AbstractString,
    source_line::AbstractString,
    source_description::AbstractString,
    classification_note::AbstractString,
    source_note::AbstractString,
)
    sector_order = findfirst(==(sector), TABLE6_SECTOR_ORDER)
    if isnothing(sector_order)
        error("Sector $(sector) is not in TABLE6_SECTOR_ORDER")
    end

    share_national =
        ismissing(value) || ismissing(denominator_national) || denominator_national == 0.0 ?
        missing :
        100.0 * value / denominator_national
    share_domestic =
        sector == "Rest of the world" ||
        ismissing(value) ||
        ismissing(denominator_domestic) ||
        denominator_domestic == 0.0 ?
        missing :
        100.0 * value / denominator_domestic
    row_type =
        sector in TABLE6_SERVICE_DETAIL ? "service_detail" :
        sector == "Services" ? "services_total" :
        "sector"

    push!(
        rows,
        (
            year = year,
            sector = sector,
            sector_order = sector_order,
            row_type = row_type,
            value_millions = value,
            share_of_national_income_percent = share_national,
            share_of_domestic_industries_percent = share_domestic,
            source_table = source_table,
            source_line = source_line,
            source_description = source_description,
            classification_note = classification_note,
            source_note = source_note,
        ),
    )
end

function table6_legacy_rows(table, years, source_table::AbstractString)
    rows = NamedTuple[]
    for year in years
        national = table_value(table, 1, year)
        domestic = table_value(table, 2, year)
        transportation_public_utilities = table_value(table, 10, year)
        communications = table_value(table, 12, year)
        electric_gas_sanitary = table_value(table, 13, year)
        transportation =
            ismissing(transportation_public_utilities) ||
            ismissing(communications) ||
            ismissing(electric_gas_sanitary) ?
            missing :
            transportation_public_utilities - communications - electric_gas_sanitary

        mappings = [
            ("Agriculture, forestry, fishing, and hunting", table_value(table, 4, year), "4", table_description(table, 4), "Legacy SIC agriculture/forestry/fishing mapped to Table 6D agriculture/forestry/fishing/hunting."),
            ("Mining", table_value(table, 5, year), "5", table_description(table, 5), "Direct legacy SIC mapping."),
            ("Utilities", electric_gas_sanitary, "13", table_description(table, 13), "Legacy electric, gas, and sanitary services mapped to Table 6D utilities."),
            ("Construction", table_value(table, 6, year), "6", table_description(table, 6), "Direct legacy SIC mapping."),
            ("Manufacturing", table_value(table, 7, year), "7", table_description(table, 7), "Direct legacy SIC mapping."),
            ("Wholesale trade", table_value(table, 14, year), "14", table_description(table, 14), "Direct legacy SIC mapping."),
            ("Retail trade", table_value(table, 15, year), "15", table_description(table, 15), "Direct legacy SIC mapping."),
            ("Transportation and warehousing", transportation, "10 - 12 - 13", "Transportation and public utilities less communications and electric/gas/sanitary services", "Legacy transportation/public utilities adjusted by subtracting communications and electric/gas/sanitary services."),
            ("Information", communications, "12", table_description(table, 12), "Legacy communications mapped to Table 6D information."),
            ("Finance, insurance, real estate, rental, and leasing", table_value(table, 16, year), "16", table_description(table, 16), "Legacy finance/insurance/real estate mapped to Table 6D finance/insurance/real estate/rental/leasing."),
            ("Professional and business services", missing, "", "", "Service detail is not available before Table 6.1D; kept missing by design."),
            ("Educational services, health care, and social assistance", missing, "", "", "Service detail is not available before Table 6.1D; kept missing by design."),
            ("Arts, entertainment, recreation, accommodation, and food services", missing, "", "", "Service detail is not available before Table 6.1D; kept missing by design."),
            ("Other services, except government", missing, "", "", "Service detail is not available before Table 6.1D; kept missing by design."),
            ("Services", table_value(table, 17, year), "17", table_description(table, 17), "Legacy aggregate services mapped to total services."),
            ("Government", table_value(table, 18, year), "18", table_description(table, 18), "Direct legacy SIC mapping."),
            ("Rest of the world", table_value(table, 19, year), "19", table_description(table, 19), "Direct mapping."),
        ]

        for (sector, value, source_line, source_description, classification_note) in mappings
            table6_push!(
                rows,
                year,
                sector,
                value,
                national,
                domestic,
                source_table,
                source_line,
                source_description,
                classification_note,
                TABLE6_ARCHIVE_NOTE,
            )
        end
    end
    rows
end

function table6_modern_rows(table, years, source_table::AbstractString)
    rows = NamedTuple[]
    for year in years
        national = table_value(table, 1, year)
        domestic = table_value(table, 2, year)
        service_lines = [16, 17, 18, 19]
        service_values = [table_value(table, line, year) for line in service_lines]
        services =
            any(ismissing, service_values) ? missing : sum(service_values)

        mappings = [
            ("Agriculture, forestry, fishing, and hunting", table_value(table, 4, year), "4", table_description(table, 4), "Direct Table 6D NAICS mapping."),
            ("Mining", table_value(table, 5, year), "5", table_description(table, 5), "Direct Table 6D NAICS mapping."),
            ("Utilities", table_value(table, 6, year), "6", table_description(table, 6), "Direct Table 6D NAICS mapping."),
            ("Construction", table_value(table, 7, year), "7", table_description(table, 7), "Direct Table 6D NAICS mapping."),
            ("Manufacturing", table_value(table, 8, year), "8", table_description(table, 8), "Direct Table 6D NAICS mapping."),
            ("Wholesale trade", table_value(table, 11, year), "11", table_description(table, 11), "Direct Table 6D NAICS mapping."),
            ("Retail trade", table_value(table, 12, year), "12", table_description(table, 12), "Direct Table 6D NAICS mapping."),
            ("Transportation and warehousing", table_value(table, 13, year), "13", table_description(table, 13), "Direct Table 6D NAICS mapping."),
            ("Information", table_value(table, 14, year), "14", table_description(table, 14), "Direct Table 6D NAICS mapping."),
            ("Finance, insurance, real estate, rental, and leasing", table_value(table, 15, year), "15", table_description(table, 15), "Direct Table 6D NAICS mapping."),
            ("Professional and business services", table_value(table, 16, year), "16", table_description(table, 16), "Direct Table 6D NAICS mapping."),
            ("Educational services, health care, and social assistance", table_value(table, 17, year), "17", table_description(table, 17), "Direct Table 6D NAICS mapping."),
            ("Arts, entertainment, recreation, accommodation, and food services", table_value(table, 18, year), "18", table_description(table, 18), "Direct Table 6D NAICS mapping."),
            ("Other services, except government", table_value(table, 19, year), "19", table_description(table, 19), "Direct Table 6D NAICS mapping."),
            ("Services", services, "16 + 17 + 18 + 19", "Sum of Table 6D service detail rows", "Total services constructed as the sum of the four Table 6D service detail rows."),
            ("Government", table_value(table, 20, year), "20", table_description(table, 20), "Direct Table 6D NAICS mapping."),
            ("Rest of the world", table_value(table, 21, year), "21", table_description(table, 21), "Direct mapping."),
        ]

        for (sector, value, source_line, source_description, classification_note) in mappings
            table6_push!(
                rows,
                year,
                sector,
                value,
                national,
                domestic,
                source_table,
                source_line,
                source_description,
                classification_note,
                TABLE6_ARCHIVE_NOTE,
            )
        end
    end
    rows
end

function griliches_table6_sector_distribution(root::AbstractString = joinpath(@__DIR__, ".."))
    source_dir = joinpath(root, "source_csv", "bea_nipa_archive_2024_q1_third", "section6")
    table_b = nipa_sheet_table(joinpath(source_dir, "T60100B_A.csv"))
    table_c = nipa_sheet_table(joinpath(source_dir, "T60100C_A.csv"))
    table_d = nipa_sheet_table(joinpath(source_dir, "T60100D_A.csv"))

    rows = vcat(
        table6_legacy_rows(table_b, 1948:1987, "Table 6.1B"),
        table6_legacy_rows(table_c, 1988:1997, "Table 6.1C"),
        table6_modern_rows(table_d, 1998:2023, "Table 6.1D"),
    )

    sort(rows; by = r -> (r.year, r.sector_order))
end

function write_griliches_table6_sector_distribution(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_nipa_table6d_sector_distribution_1948_2023.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_table6_sector_distribution(root)
    header = [
        "year",
        "sector",
        "sector_order",
        "row_type",
        "value_millions",
        "share_of_national_income_percent",
        "share_of_domestic_industries_percent",
        "source_table",
        "source_line",
        "source_description",
        "classification_note",
        "source_note",
    ]
    body = [
        [
            r.year,
            r.sector,
            r.sector_order,
            r.row_type,
            r.value_millions,
            r.share_of_national_income_percent,
            r.share_of_domestic_industries_percent,
            r.source_table,
            r.source_line,
            r.source_description,
            r.classification_note,
            r.source_note,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

if abspath(PROGRAM_FILE) == @__FILE__
    println(write_griliches_table6_sector_distribution())
end
