# Build an IPP-investment analogue to Griliches' computer-investment table.
#
# Source data are BEA Fixed Assets tables exported by fetch_bea_fixed_assets.jl:
#   - Table 3.7I: private intellectual property products investment by industry
#   - Table 3.7ESI: private fixed investment in equipment, structures, and IPP by industry
#   - Table 1.5: government nonresidential fixed investment and IPP

include(joinpath(@__DIR__, "griliches_table6_sector_distribution.jl"))

IPP_SOURCE_NOTE =
    "BEA Fixed Assets Tables 3.7I, 3.7ESI, and 1.5; fetched with BeaData.jl."

IPP_MEASURABLE_SECTORS = Set([
    "Agriculture, forestry, fishing, and hunting",
    "Mining",
    "Utilities",
    "Manufacturing",
    "Transportation and warehousing",
])

IPP_PRIVATE_LINE_MAP = [
    ("Agriculture, forestry, fishing, and hunting", [2], "Direct Table 3.7 mapping."),
    ("Mining", [5], "Direct Table 3.7 mapping."),
    ("Utilities", [9], "Direct Table 3.7 mapping."),
    ("Construction", [13], "Direct Table 3.7 mapping."),
    ("Manufacturing", [14], "Direct Table 3.7 mapping."),
    ("Wholesale trade", [40], "Direct Table 3.7 mapping."),
    ("Retail trade", [43], "Direct Table 3.7 mapping."),
    ("Transportation and warehousing", [48], "Direct Table 3.7 mapping."),
    ("Information", [57], "Direct Table 3.7 mapping."),
    ("Finance, insurance, real estate, rental, and leasing", [62, 73], "Finance/insurance plus real estate/rental/leasing."),
    ("Professional and business services", [76, 80, 81], "Professional/scientific/technical plus management plus administrative/waste-management services."),
    ("Educational services, health care, and social assistance", [84, 85], "Educational services plus health care/social assistance."),
    ("Arts, entertainment, recreation, accommodation, and food services", [90, 93], "Arts/entertainment/recreation plus accommodation/food services."),
    ("Other services, except government", [96], "Direct Table 3.7 mapping."),
]

IPP_SECTOR_ORDER = vcat(TABLE6_SECTOR_ORDER[1:16], ["Total"])

function fixed_assets_rows(path::AbstractString)
    raw = read_csv_rows(path)
    isempty(raw) && error("Empty Fixed Assets CSV: $(path)")
    header = raw[1]
    idx = normalized_header_index(header)
    required = ["tablename", "tablenumber", "tabledescription", "metric", "units", "lastrevised", "linenumber", "linedescription", "timeperiod", "datavalue"]
    for name in required
        haskey(idx, name) || error("Missing column $(name) in $(path)")
    end

    rows = NamedTuple[]
    for row in raw[2:end]
        isempty(row) && continue
        push!(
            rows,
            (
                table_name = strip(row[idx["tablename"]]),
                table_number = strip(row[idx["tablenumber"]]),
                table_description = strip(row[idx["tabledescription"]]),
                metric = strip(row[idx["metric"]]),
                units = strip(row[idx["units"]]),
                last_revised = strip(row[idx["lastrevised"]]),
                line_number = parse(Int, strip(row[idx["linenumber"]])),
                line_description = strip(row[idx["linedescription"]]),
                year = parse(Int, strip(row[idx["timeperiod"]])),
                value = parse(Float64, strip(row[idx["datavalue"]])),
            ),
        )
    end
    rows
end

function fixed_assets_lookup(rows)
    Dict((r.line_number, r.year) => r for r in rows)
end

function fixed_assets_value(lookup, line::Int, year::Int)
    haskey(lookup, (line, year)) ? lookup[(line, year)].value : missing
end

function fixed_assets_description(rows, line::Int)
    match = findfirst(r -> r.line_number == line, rows)
    isnothing(match) ? "" : rows[match].line_description
end

function fixed_assets_sum(lookup, lines, year::Int)
    values = [fixed_assets_value(lookup, line, year) for line in lines]
    any(ismissing, values) ? missing : sum(values)
end

function fixed_assets_sum_description(rows, lines)
    join([fixed_assets_description(rows, line) for line in lines], " + ")
end

function ipp_row_type(sector::AbstractString)
    sector in TABLE6_SERVICE_DETAIL ? "service_detail" :
    sector == "Services" ? "services_total" :
    sector == "Total" ? "total" :
    "sector"
end

function ipp_sector_order(sector::AbstractString)
    order = findfirst(==(sector), IPP_SECTOR_ORDER)
    isnothing(order) && error("Sector $(sector) is not in IPP_SECTOR_ORDER")
    order
end

function push_ipp_row!(
    rows,
    year::Int,
    sector::AbstractString,
    ipp_investment,
    fixed_investment,
    total_ipp,
    total_fixed,
    source_line::AbstractString,
    source_description::AbstractString,
    classification_note::AbstractString,
)
    ipp_share_fixed =
        ismissing(ipp_investment) || ismissing(fixed_investment) || fixed_investment == 0.0 ?
        missing :
        100.0 * ipp_investment / fixed_investment
    share_total_ipp =
        ismissing(ipp_investment) || ismissing(total_ipp) || total_ipp == 0.0 ?
        missing :
        100.0 * ipp_investment / total_ipp
    share_total_fixed =
        ismissing(fixed_investment) || ismissing(total_fixed) || total_fixed == 0.0 ?
        missing :
        100.0 * fixed_investment / total_fixed

    push!(
        rows,
        (
            year = year,
            sector = sector,
            sector_order = ipp_sector_order(sector),
            row_type = ipp_row_type(sector),
            ipp_investment_billions = ipp_investment,
            fixed_investment_billions = fixed_investment,
            ipp_share_of_fixed_investment_percent = ipp_share_fixed,
            share_of_total_ipp_percent = share_total_ipp,
            share_of_total_fixed_investment_percent = share_total_fixed,
            measurable_group = sector in IPP_MEASURABLE_SECTORS ? "Griliches measurable sectors" :
                               sector in ["Total"] ? "Total" :
                               "Other sectors",
            source_table = "FAAt307I / FAAt307ESI / FAAt105",
            source_line = source_line,
            source_description = source_description,
            classification_note = classification_note,
            source_note = IPP_SOURCE_NOTE,
        ),
    )
end

function griliches_fixed_assets_ipp_distribution(root::AbstractString = joinpath(@__DIR__, ".."))
    source_dir = joinpath(root, "source_csv", "bea_fixed_assets")
    ipp_rows = fixed_assets_rows(joinpath(source_dir, "fa_table_3_7i.csv"))
    fixed_rows = fixed_assets_rows(joinpath(source_dir, "fa_table_3_7esi.csv"))
    total_rows = fixed_assets_rows(joinpath(source_dir, "fa_table_1_5.csv"))

    ipp = fixed_assets_lookup(ipp_rows)
    fixed = fixed_assets_lookup(fixed_rows)
    total = fixed_assets_lookup(total_rows)

    private_years = Set(r.year for r in ipp_rows)
    fixed_years = Set(r.year for r in fixed_rows)
    total_years = Set(r.year for r in total_rows)
    years = sort!(collect(intersect(private_years, fixed_years, total_years)))

    rows = NamedTuple[]
    for year in years
        private_ipp = fixed_assets_value(ipp, 1, year)
        private_fixed = fixed_assets_value(fixed, 1, year)
        government_ipp = fixed_assets_value(total, 13, year)
        government_fixed = fixed_assets_value(total, 10, year)
        total_ipp =
            ismissing(private_ipp) || ismissing(government_ipp) ?
            missing :
            private_ipp + government_ipp
        total_fixed =
            ismissing(private_fixed) || ismissing(government_fixed) ?
            missing :
            private_fixed + government_fixed

        for (sector, lines, note) in IPP_PRIVATE_LINE_MAP
            ipp_value = fixed_assets_sum(ipp, lines, year)
            fixed_value = fixed_assets_sum(fixed, lines, year)
            push_ipp_row!(
                rows,
                year,
                sector,
                ipp_value,
                fixed_value,
                total_ipp,
                total_fixed,
                join(string.(lines), " + "),
                fixed_assets_sum_description(ipp_rows, lines),
                note,
            )
        end

        service_lines = [76, 80, 81, 84, 85, 90, 93, 96]
        push_ipp_row!(
            rows,
            year,
            "Services",
            fixed_assets_sum(ipp, service_lines, year),
            fixed_assets_sum(fixed, service_lines, year),
            total_ipp,
            total_fixed,
            join(string.(service_lines), " + "),
            "Sum of Table 3.7 service detail rows",
            "Total services constructed as the sum of the four Table 6D-style service detail rows.",
        )

        push_ipp_row!(
            rows,
            year,
            "Government",
            government_ipp,
            government_fixed,
            total_ipp,
            total_fixed,
            "FAAt105 line 13 / line 10",
            "Government intellectual property products / government nonresidential fixed investment",
            "Government added from Fixed Assets Table 1.5.",
        )

        push_ipp_row!(
            rows,
            year,
            "Total",
            total_ipp,
            total_fixed,
            total_ipp,
            total_fixed,
            "FAAt307I line 1 + FAAt105 line 13 / FAAt307ESI line 1 + FAAt105 line 10",
            "Private plus government intellectual property products / private fixed assets by industry plus government nonresidential fixed investment",
            "Total constructed as private industry-owner investment plus government nonresidential investment.",
        )
    end

    sort(rows; by = r -> (r.year, r.sector_order))
end

function write_griliches_fixed_assets_ipp_distribution(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_fixed_assets_ipp_investment_distribution.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_fixed_assets_ipp_distribution(root)
    header = [
        "year",
        "sector",
        "sector_order",
        "row_type",
        "ipp_investment_billions",
        "fixed_investment_billions",
        "ipp_share_of_fixed_investment_percent",
        "share_of_total_ipp_percent",
        "share_of_total_fixed_investment_percent",
        "measurable_group",
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
            r.ipp_investment_billions,
            r.fixed_investment_billions,
            r.ipp_share_of_fixed_investment_percent,
            r.share_of_total_ipp_percent,
            r.share_of_total_fixed_investment_percent,
            r.measurable_group,
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
    println(write_griliches_fixed_assets_ipp_distribution())
end
