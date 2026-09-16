# Build Griliches-style sector value-added and hours shares from the
# BEA-BLS/KLEMS production-account family.
#
# Python is used upstream only to convert XLSX sheets to CSV. This file reads
# those CSVs and does the economic/classification work.

include(joinpath(@__DIR__, "griliches_historical_productivity.jl"))

KLEMS_SECTOR_NOTE =
    "BEA-BLS historical KLEMS 1963-2016, current BEA-BLS ILPA 1997-2024, and BLS detailed industry hours/employment 1987-2025."

KLEMS_SECTOR_ORDER = [
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
    "Total",
]

KLEMS_SERVICE_DETAIL = Set([
    "Professional and business services",
    "Educational services, health care, and social assistance",
    "Arts, entertainment, recreation, accommodation, and food services",
    "Other services, except government",
])

KLEMS_MEASURABLE_SECTORS = Set([
    "Agriculture, forestry, fishing, and hunting",
    "Mining",
    "Utilities",
    "Manufacturing",
    "Transportation and warehousing",
])

KLEMS_AGRICULTURE = Set(["Farms", "Forestry, fishing, and related activities"])
KLEMS_MINING = Set(["Oil and gas extraction", "Mining, except oil and gas", "Support activities for mining"])
KLEMS_INFORMATION = Set([
    "Publishing industries, except internet (includes software)",
    "Motion picture and sound recording industries",
    "Broadcasting and telecommunications",
    "Data processing, internet publishing, and other information services",
])
KLEMS_FINANCE_REAL_ESTATE = Set([
    "Federal Reserve banks, credit intermediation, and related activities",
    "Securities, commodity contracts, and investments",
    "Insurance carriers and related activities",
    "Funds, trusts, and other financial vehicles",
    "Real estate",
    "Rental and leasing services and lessors of intangible assets",
])
KLEMS_PROFESSIONAL_BUSINESS = Set([
    "Legal services",
    "Computer systems design and related services",
    "Miscellaneous professional, scientific, and technical services",
    "Management of companies and enterprises",
    "Administrative and support services",
    "Waste management and remediation services",
])
KLEMS_EDUCATION_HEALTH = Set([
    "Educational services",
    "Ambulatory health care services",
    "Hospitals and Nursing and residential care",
    "Hospitals and nursing and residential care facilities",
    "Social assistance",
])
KLEMS_ARTS_ACCOMMODATION_FOOD = Set([
    "Performing arts, spectator sports, museums, and related activities",
    "Amusements, gambling, and recreation industries",
    "Accommodation",
    "Food services and drinking places",
])
KLEMS_GOVERNMENT = Set(["Federal", "State and local"])

function klems_sector_for_description(desc::AbstractString)
    desc in KLEMS_AGRICULTURE && return "Agriculture, forestry, fishing, and hunting"
    desc in KLEMS_MINING && return "Mining"
    desc == "Utilities" && return "Utilities"
    desc == "Construction" && return "Construction"
    desc in MANUFACTURING && return "Manufacturing"
    desc == "Wholesale trade" && return "Wholesale trade"
    desc == "Retail trade" && return "Retail trade"
    desc in TRANSPORTATION_CURRENT && return "Transportation and warehousing"
    desc in KLEMS_INFORMATION && return "Information"
    desc in KLEMS_FINANCE_REAL_ESTATE && return "Finance, insurance, real estate, rental, and leasing"
    desc in KLEMS_PROFESSIONAL_BUSINESS && return "Professional and business services"
    desc in KLEMS_EDUCATION_HEALTH && return "Educational services, health care, and social assistance"
    desc in KLEMS_ARTS_ACCOMMODATION_FOOD && return "Arts, entertainment, recreation, accommodation, and food services"
    desc == "Other services, except government" && return "Other services, except government"
    desc in KLEMS_GOVERNMENT && return "Government"
    nothing
end

KLEMS_BLS_CODE_MAP = Dict(
    "Agriculture, forestry, fishing, and hunting" => ["111", "112", "113", "114", "115"],
    "Mining" => ["211", "212", "213"],
    "Utilities" => ["22"],
    "Construction" => ["236", "237", "238"],
    "Manufacturing" => ["311", "312", "313", "314", "315", "316", "321", "322", "323", "324", "325", "326", "327", "331", "332", "333", "334", "335", "336", "337", "339"],
    "Wholesale trade" => ["42"],
    "Retail trade" => ["44,45"],
    "Transportation and warehousing" => ["481", "482", "483", "484", "485", "486", "487", "488", "491", "492", "493"],
    "Information" => ["511", "512", "515", "517", "518", "519"],
    "Finance, insurance, real estate, rental, and leasing" => ["521", "522", "523", "524", "525", "531", "532", "533"],
    "Professional and business services" => ["54", "55", "561", "562"],
    "Educational services, health care, and social assistance" => ["61", "621", "622", "623", "624"],
    "Arts, entertainment, recreation, accommodation, and food services" => ["711", "712", "713", "721", "722"],
    "Other services, except government" => ["811", "812", "813", "814"],
    "Government" => ["901"],
)

function empty_sector_values()
    Dict(sector => 0.0 for sector in KLEMS_SECTOR_ORDER if sector != "Services" && sector != "Total")
end

function add_services_and_total(values::Dict{String, Float64})
    values["Services"] = sum(get(values, sector, 0.0) for sector in KLEMS_SERVICE_DETAIL)
    values["Total"] = sum(get(values, sector, 0.0) for sector in KLEMS_SECTOR_ORDER if sector != "Services" && sector != "Total")
    values
end

function historical_klems_va_hours(root::AbstractString)
    path = joinpath(root, "source_csv", "historical_1947_2016", "underlying_data", "1963_2016.csv")
    raw = read_csv_rows(path)
    header = raw[2]
    idx = Dict(name => i for (i, name) in enumerate(header))
    va_by_year = Dict{Int, Dict{String, Float64}}()
    hours_by_year = Dict{Int, Dict{String, Float64}}()

    for row in raw[3:end]
        length(row) < idx["hrs"] && continue
        isempty(row[idx["yr"]]) && continue
        year = Int(parse(Float64, row[idx["yr"]]))
        sector = klems_sector_for_description(row[idx["Description"]])
        isnothing(sector) && continue
        va = value_float(row[idx["go."]]) - value_float(row[idx["ii."]])
        hours = value_float(row[idx["hrs"]])
        vy = get!(va_by_year, year, empty_sector_values())
        hy = get!(hours_by_year, year, empty_sector_values())
        vy[sector] = get(vy, sector, 0.0) + va
        hy[sector] = get(hy, sector, 0.0) + hours
    end

    for values in values(va_by_year)
        add_services_and_total(values)
    end
    for values in values(hours_by_year)
        add_services_and_total(values)
    end
    va_by_year, hours_by_year
end

function current_ilpa_va(root::AbstractString)
    path = joinpath(root, "source_csv", "current_bea_bls_ilpa", "value_added.csv")
    years, table = sheet_table_from_source_csv(path)
    out = Dict{Int, Dict{String, Float64}}()
    for year in years
        values = empty_sector_values()
        for (desc, row) in table
            sector = klems_sector_for_description(desc)
            isnothing(sector) && continue
            values[sector] = get(values, sector, 0.0) + row[year]
        end
        out[year] = add_services_and_total(values)
    end
    out
end

function bls_hours_employment(root::AbstractString; measure::AbstractString = "Hours worked", units::AbstractString = "Millions of hours")
    path = joinpath(root, "source_csv", "bls_productivity", "hours_employment_detailed_industries.csv")
    raw = read_csv_rows(path)
    header = raw[1]
    idx = Dict(name => i for (i, name) in enumerate(header))
    out = Dict{Int, Dict{String, Float64}}()
    code_to_sector = Dict(code => sector for (sector, codes) in KLEMS_BLS_CODE_MAP for code in codes)

    for row in raw[2:end]
        length(row) < idx["Value"] && continue
        row[idx["Basis"]] == "All workers" || continue
        row[idx["Measure"]] == measure || continue
        row[idx["Units"]] == units || continue
        sector = get(code_to_sector, row[idx["NAICS"]], nothing)
        isnothing(sector) && continue
        year = parse(Int, row[idx["Year"]])
        values = get!(out, year, empty_sector_values())
        values[sector] = get(values, sector, 0.0) + parse(Float64, row[idx["Value"]])
    end

    for values in values(out)
        add_services_and_total(values)
    end
    out
end

function source_for_year(year::Int, kind::Symbol)
    if kind == :va
        year <= 1996 && return "BEA-BLS historical KLEMS 1963-2016 sheet; nominal VA = go. - ii."
        return "Current BEA-BLS ILPA Value Added sheet."
    elseif kind == :hours
        year <= 1986 && return "BEA-BLS historical KLEMS 1963-2016 sheet; hrs."
        return "BLS detailed industries hours/employment workbook; hours worked, millions of hours."
    else
        error("kind must be :va or :hours")
    end
end

function klems_row_type(sector::AbstractString)
    sector in KLEMS_SERVICE_DETAIL ? "service_detail" :
    sector == "Services" ? "services_total" :
    sector == "Total" ? "total" :
    "sector"
end

function griliches_klems_sector_distribution(root::AbstractString = joinpath(@__DIR__, ".."))
    hist_va, hist_hours = historical_klems_va_hours(root)
    current_va = current_ilpa_va(root)
    bls_hours = bls_hours_employment(root)

    years = 1963:min(maximum(keys(current_va)), maximum(keys(bls_hours)))
    rows = NamedTuple[]
    for year in years
        va_values = year <= 1996 ? hist_va[year] : current_va[year]
        hour_values = year <= 1986 ? hist_hours[year] : bls_hours[year]
        va_total = va_values["Total"]
        hours_total = hour_values["Total"]
        for sector in KLEMS_SECTOR_ORDER
            value_va = va_values[sector]
            value_hours = hour_values[sector]
            push!(
                rows,
                (
                    year = year,
                    sector = sector,
                    sector_order = findfirst(==(sector), KLEMS_SECTOR_ORDER),
                    row_type = klems_row_type(sector),
                    nominal_value_added_millions = value_va,
                    share_of_value_added_percent = 100.0 * value_va / va_total,
                    hours_millions = value_hours,
                    share_of_hours_percent = 100.0 * value_hours / hours_total,
                    measurable_group = sector in KLEMS_MEASURABLE_SECTORS ? "Griliches measurable sectors" :
                                       sector == "Total" ? "Total" :
                                       "Other sectors",
                    va_source = source_for_year(year, :va),
                    hours_source = source_for_year(year, :hours),
                    classification_note = "Information is classified as unmeasurable because modern Information includes publishing/software, motion picture/sound, broadcasting/telecom, and data/internet/other information services.",
                    source_note = KLEMS_SECTOR_NOTE,
                ),
            )
        end
    end
    sort(rows; by = r -> (r.year, r.sector_order))
end

function write_griliches_klems_sector_distribution(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_bls_klems_sector_distribution_1963_2024.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_klems_sector_distribution(root)
    header = [
        "year",
        "sector",
        "sector_order",
        "row_type",
        "nominal_value_added_millions",
        "share_of_value_added_percent",
        "hours_millions",
        "share_of_hours_percent",
        "measurable_group",
        "va_source",
        "hours_source",
        "classification_note",
        "source_note",
    ]
    body = [
        [
            r.year,
            r.sector,
            r.sector_order,
            r.row_type,
            r.nominal_value_added_millions,
            r.share_of_value_added_percent,
            r.hours_millions,
            r.share_of_hours_percent,
            r.measurable_group,
            r.va_source,
            r.hours_source,
            r.classification_note,
            r.source_note,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

if abspath(PROGRAM_FILE) == @__FILE__
    println(write_griliches_klems_sector_distribution())
end
