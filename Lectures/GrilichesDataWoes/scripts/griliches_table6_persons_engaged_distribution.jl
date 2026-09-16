# Build a Table-6D-style historical persons-engaged distribution from archived
# BEA NIPA Table 6.8A/B/C/D source CSVs.
#
# Python is used upstream only to extract workbook sheets to CSV. This file
# contains the economic/classification mapping.

include(joinpath(@__DIR__, "griliches_table6_sector_distribution.jl"))

const TABLE68_ARCHIVE_NOTE =
    "BEA NIPA archive, 2024 Q1 Third estimate, released June 28, 2024; Section 6 Table 6.8A/B/C/D."

function table6_sum_value(table, lines, year::Int)
    values = [table_value(table, line, year) for line in lines]
    any(ismissing, values) ? missing : sum(values)
end

function table6_sum_description(table, lines)
    join([table_description(table, line) for line in lines], " + ")
end

function table68_push!(
    rows,
    year::Int,
    sector::AbstractString,
    value,
    denominator_total,
    denominator_domestic,
    source_table::AbstractString,
    source_line::AbstractString,
    source_description::AbstractString,
    classification_note::AbstractString,
)
    sector_order = findfirst(==(sector), TABLE6_SECTOR_ORDER)
    isnothing(sector_order) && error("Sector $(sector) is not in TABLE6_SECTOR_ORDER")

    share_total =
        ismissing(value) || ismissing(denominator_total) || denominator_total == 0.0 ?
        missing :
        100.0 * value / denominator_total
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
            value_thousands = value,
            share_of_persons_engaged_percent = share_total,
            share_of_domestic_industries_percent = share_domestic,
            source_table = source_table,
            source_line = source_line,
            source_description = source_description,
            classification_note = classification_note,
            source_note = TABLE68_ARCHIVE_NOTE,
        ),
    )
end

function table68_legacy_rows(table, years, source_table::AbstractString; lines)
    rows = NamedTuple[]
    for year in years
        total = table_value(table, 1, year)
        domestic = table_value(table, 2, year)
        transportation_public_utilities = table_value(table, lines.transport_public_utilities, year)
        communications = table_value(table, lines.communications, year)
        electric_gas_sanitary = table_value(table, lines.utilities, year)
        transportation =
            ismissing(transportation_public_utilities) ||
            ismissing(communications) ||
            ismissing(electric_gas_sanitary) ?
            missing :
            transportation_public_utilities - communications - electric_gas_sanitary

        mappings = [
            ("Agriculture, forestry, fishing, and hunting", table_value(table, lines.agriculture, year), string(lines.agriculture), table_description(table, lines.agriculture), "Legacy SIC agriculture/forestry/fishing mapped to Table 6D agriculture/forestry/fishing/hunting."),
            ("Mining", table_value(table, lines.mining, year), string(lines.mining), table_description(table, lines.mining), "Direct legacy SIC mapping."),
            ("Utilities", electric_gas_sanitary, string(lines.utilities), table_description(table, lines.utilities), "Legacy electric, gas, and sanitary services mapped to Table 6D utilities."),
            ("Construction", table_value(table, lines.construction, year), string(lines.construction), table_description(table, lines.construction), "Direct legacy SIC mapping."),
            ("Manufacturing", table_value(table, lines.manufacturing, year), string(lines.manufacturing), table_description(table, lines.manufacturing), "Direct legacy SIC mapping."),
            ("Wholesale trade", table_value(table, lines.wholesale, year), string(lines.wholesale), table_description(table, lines.wholesale), "Direct legacy SIC mapping."),
            ("Retail trade", table_value(table, lines.retail, year), string(lines.retail), table_description(table, lines.retail), "Direct legacy SIC mapping."),
            ("Transportation and warehousing", transportation, "$(lines.transport_public_utilities) - $(lines.communications) - $(lines.utilities)", "Transportation and public utilities less communications and electric/gas/sanitary services", "Legacy transportation/public utilities adjusted by subtracting communications and electric/gas/sanitary services."),
            ("Information", communications, string(lines.communications), table_description(table, lines.communications), "Legacy communications mapped to Table 6D information."),
            ("Finance, insurance, real estate, rental, and leasing", table_value(table, lines.finance_real_estate, year), string(lines.finance_real_estate), table_description(table, lines.finance_real_estate), "Legacy finance/insurance/real estate mapped to Table 6D finance/insurance/real estate/rental/leasing."),
            ("Professional and business services", missing, "", "", "Service detail is not available before Table 6.8D; kept missing by design."),
            ("Educational services, health care, and social assistance", missing, "", "", "Service detail is not available before Table 6.8D; kept missing by design."),
            ("Arts, entertainment, recreation, accommodation, and food services", missing, "", "", "Service detail is not available before Table 6.8D; kept missing by design."),
            ("Other services, except government", missing, "", "", "Service detail is not available before Table 6.8D; kept missing by design."),
            ("Services", table_value(table, lines.services, year), string(lines.services), table_description(table, lines.services), "Legacy aggregate services mapped to total services."),
            ("Government", table_value(table, lines.government, year), string(lines.government), table_description(table, lines.government), "Direct legacy SIC mapping."),
            ("Rest of the world", table_value(table, lines.rest_of_world, year), string(lines.rest_of_world), table_description(table, lines.rest_of_world), "Direct mapping."),
        ]

        for (sector, value, source_line, source_description, classification_note) in mappings
            table68_push!(
                rows,
                year,
                sector,
                value,
                total,
                domestic,
                source_table,
                source_line,
                source_description,
                classification_note,
            )
        end
    end
    rows
end

function table68_modern_rows(table, years, source_table::AbstractString)
    rows = NamedTuple[]
    for year in years
        total = table_value(table, 1, year)
        domestic = table_value(table, 2, year)

        finance_real_estate = table6_sum_value(table, [57, 62], year)
        professional_business = table6_sum_value(table, [65, 69, 70], year)
        education_health = table6_sum_value(table, [73, 74], year)
        arts_food = table6_sum_value(table, [79, 82], year)
        other_services = table_value(table, 85, year)
        services =
            any(ismissing, [professional_business, education_health, arts_food, other_services]) ?
            missing :
            professional_business + education_health + arts_food + other_services

        mappings = [
            ("Agriculture, forestry, fishing, and hunting", table_value(table, 4, year), "4", table_description(table, 4), "Direct Table 6D NAICS mapping."),
            ("Mining", table_value(table, 7, year), "7", table_description(table, 7), "Direct Table 6D NAICS mapping."),
            ("Utilities", table_value(table, 11, year), "11", table_description(table, 11), "Direct Table 6D NAICS mapping."),
            ("Construction", table_value(table, 12, year), "12", table_description(table, 12), "Direct Table 6D NAICS mapping."),
            ("Manufacturing", table_value(table, 13, year), "13", table_description(table, 13), "Direct Table 6D NAICS mapping."),
            ("Wholesale trade", table_value(table, 35, year), "35", table_description(table, 35), "Direct Table 6D NAICS mapping."),
            ("Retail trade", table_value(table, 38, year), "38", table_description(table, 38), "Direct Table 6D NAICS mapping."),
            ("Transportation and warehousing", table_value(table, 43, year), "43", table_description(table, 43), "Direct Table 6D NAICS mapping."),
            ("Information", table_value(table, 52, year), "52", table_description(table, 52), "Direct Table 6D NAICS mapping."),
            ("Finance, insurance, real estate, rental, and leasing", finance_real_estate, "57 + 62", table6_sum_description(table, [57, 62]), "Constructed as finance and insurance plus real estate/rental/leasing."),
            ("Professional and business services", professional_business, "65 + 69 + 70", table6_sum_description(table, [65, 69, 70]), "Constructed as professional/scientific/technical services plus management plus administrative/waste-management services."),
            ("Educational services, health care, and social assistance", education_health, "73 + 74", table6_sum_description(table, [73, 74]), "Constructed as educational services plus health care/social assistance."),
            ("Arts, entertainment, recreation, accommodation, and food services", arts_food, "79 + 82", table6_sum_description(table, [79, 82]), "Constructed as arts/entertainment/recreation plus accommodation/food services."),
            ("Other services, except government", other_services, "85", table_description(table, 85), "Direct Table 6D NAICS mapping."),
            ("Services", services, "65 + 69 + 70 + 73 + 74 + 79 + 82 + 85", "Sum of Table 6.8D service detail rows", "Total services constructed as the sum of the four Table 6D-style service detail rows."),
            ("Government", table_value(table, 86, year), "86", table_description(table, 86), "Direct Table 6D NAICS mapping."),
            ("Rest of the world", table_value(table, 97, year), "97", table_description(table, 97), "Direct mapping."),
        ]

        for (sector, value, source_line, source_description, classification_note) in mappings
            table68_push!(
                rows,
                year,
                sector,
                value,
                total,
                domestic,
                source_table,
                source_line,
                source_description,
                classification_note,
            )
        end
    end
    rows
end

function griliches_table6_persons_engaged_distribution(root::AbstractString = joinpath(@__DIR__, ".."))
    source_dir = joinpath(root, "source_csv", "bea_nipa_archive_2024_q1_third", "section6")
    table_a = nipa_sheet_table(joinpath(source_dir, "T60800A_A.csv"))
    table_b = nipa_sheet_table(joinpath(source_dir, "T60800B_A.csv"))
    table_c = nipa_sheet_table(joinpath(source_dir, "T60800C_A.csv"))
    table_d = nipa_sheet_table(joinpath(source_dir, "T60800D_A.csv"))

    lines_a = (
        agriculture = 4,
        mining = 7,
        construction = 13,
        manufacturing = 14,
        transport_public_utilities = 37,
        communications = 46,
        utilities = 49,
        wholesale = 52,
        retail = 53,
        finance_real_estate = 54,
        services = 61,
        government = 75,
        rest_of_world = 88,
    )
    lines_bc = (
        agriculture = 4,
        mining = 7,
        construction = 12,
        manufacturing = 13,
        transport_public_utilities = 37,
        communications = 46,
        utilities = 49,
        wholesale = 50,
        retail = 51,
        finance_real_estate = 52,
        services = 60,
        government = 76,
        rest_of_world = 87,
    )

    rows = vcat(
        table68_legacy_rows(table_a, 1929:1947, "Table 6.8A"; lines = lines_a),
        table68_legacy_rows(table_b, 1948:1987, "Table 6.8B"; lines = lines_bc),
        table68_legacy_rows(table_c, 1988:1997, "Table 6.8C"; lines = lines_bc),
        table68_modern_rows(table_d, 1998:2022, "Table 6.8D"),
    )

    sort(rows; by = r -> (r.year, r.sector_order))
end

function write_griliches_table6_persons_engaged_distribution(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_nipa_table68_persons_engaged_sector_distribution_1929_2022.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_table6_persons_engaged_distribution(root)
    header = [
        "year",
        "sector",
        "sector_order",
        "row_type",
        "value_thousands",
        "share_of_persons_engaged_percent",
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
            r.value_thousands,
            r.share_of_persons_engaged_percent,
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
    println(write_griliches_table6_persons_engaged_distribution())
end
