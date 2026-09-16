# Build Griliches measurable/unmeasurable productivity data from public
# BEA-BLS historical source-sheet CSV exports.
#
# Python is used only upstream to convert XLSX sheets to CSV. This file handles
# the economic transformation from sheet-level CSVs to figure-ready data.

SOURCE_NOTE_1947_1990 =
    "BEA-BLS historical KLEMS research data, value added double-deflated to millions of 1982 dollars, total hours."

SOURCE_NOTE_1947_2024 =
    "BEA-BLS historical KLEMS research data through 2016, spliced to current BEA-BLS production account for 2017-2024; value added is in millions of 1982 dollars."

SOURCE_NOTE_PATENTS_RD =
    "USPTO utility patent applications divided by BEA Fixed Assets private R&D investment, deflated with BEA Fixed Assets Table 2.8 and rebased to 1972 dollars."

MANUFACTURING = Set([
    "Wood products",
    "Nonmetallic mineral products",
    "Primary metals",
    "Fabricated metal products",
    "Machinery",
    "Computer and electronic products",
    "Electrical equipment, appliances, and components",
    "Motor vehicles, bodies and trailers, and parts",
    "Other transportation equipment",
    "Furniture and related products",
    "Miscellaneous manufacturing",
    "Food and beverage and tobacco products",
    "Textile mills and textile product mills",
    "Apparel and leather and allied products",
    "Paper products",
    "Printing and related support activities",
    "Petroleum and coal products",
    "Chemical products",
    "Plastics and rubber products",
])

TRANSPORTATION_HISTORICAL = Set(["Transportation and warehousing"])
TRANSPORTATION_CURRENT = Set([
    "Air transportation",
    "Rail transportation",
    "Water transportation",
    "Truck transportation",
    "Transit and ground passenger transportation",
    "Pipeline transportation",
    "Other transportation and support activities",
    "Warehousing and storage",
])

COMMUNICATION_HISTORICAL = Set(["Information"])
COMMUNICATION_CURRENT = Set(["Broadcasting and telecommunications"])

MEASURABLE_COMMON = Set([
    "Farms",
    "Forestry, fishing, and related activities",
    "Oil and gas extraction",
    "Mining, except oil and gas",
    "Support activities for mining",
    "Utilities",
])

UNMEASURABLE_COMMON = Set([
    "Construction",
    "Wholesale trade",
    "Retail trade",
    "Real estate",
    "Rental and leasing services and lessors of intangible assets",
    "Management of companies and enterprises",
    "Educational services",
    "Accommodation",
    "Food services and drinking places",
    "Other services, except government",
    "Federal",
    "State and local",
])

UNMEASURABLE_HISTORICAL = union(
    UNMEASURABLE_COMMON,
    Set([
        "Finance and insurance",
        "Professional, scientific, and technical services",
        "Administrative and waste management services",
        "Health care and social assistance",
        "Arts, entertainment, and recreation",
    ]),
)

UNMEASURABLE_CURRENT = union(
    UNMEASURABLE_COMMON,
    Set([
        "Federal Reserve banks, credit intermediation, and related activities",
        "Securities, commodity contracts, and investments",
        "Insurance carriers and related activities",
        "Funds, trusts, and other financial vehicles",
        "Legal services",
        "Computer systems design and related services",
        "Miscellaneous professional, scientific, and technical services",
        "Administrative and support services",
        "Waste management and remediation services",
        "Ambulatory health care services",
        "Hospitals and nursing and residential care facilities",
        "Social assistance",
        "Performing arts, spectator sports, museums, and related activities",
        "Amusements, gambling, and recreation industries",
        "Publishing industries, except internet (includes software)",
        "Motion picture and sound recording industries",
        "Data processing, internet publishing, and other information services",
    ]),
)

function parse_csv_line(line::AbstractString)
    fields = String[]
    field = IOBuffer()
    in_quotes = false
    i = firstindex(line)

    while i <= lastindex(line)
        ch = line[i]
        if in_quotes
            if ch == '"'
                next_i = nextind(line, i)
                if next_i <= lastindex(line) && line[next_i] == '"'
                    write(field, '"')
                    i = next_i
                else
                    in_quotes = false
                end
            else
                write(field, ch)
            end
        else
            if ch == '"'
                in_quotes = true
            elseif ch == ','
                push!(fields, String(take!(field)))
            else
                write(field, ch)
            end
        end
        i = nextind(line, i)
    end

    push!(fields, String(take!(field)))
    fields
end

function read_csv_rows(path::AbstractString)
    rows = Vector{Vector{String}}()
    open(path, "r") do io
        for line in eachline(io)
            push!(rows, parse_csv_line(chomp(line)))
        end
    end
    rows
end

function csv_escape(value)
    s = string(value)
    if occursin(',', s) || occursin('"', s) || occursin('\n', s) || occursin('\r', s)
        return "\"" * replace(s, "\"" => "\"\"") * "\""
    end
    s
end

function write_csv_rows(path::AbstractString, header, rows)
    mkpath(dirname(path))
    open(path, "w") do io
        println(io, join(csv_escape.(header), ","))
        for row in rows
            println(io, join(csv_escape.(row), ","))
        end
    end
end

value_float(x::AbstractString) = isempty(x) ? 0.0 : parse(Float64, x)

function group_for_historical(desc::AbstractString)
    measurable = union(MEASURABLE_COMMON, MANUFACTURING, TRANSPORTATION_HISTORICAL, COMMUNICATION_HISTORICAL)
    if desc in measurable
        return "Measurable sectors"
    elseif desc in UNMEASURABLE_HISTORICAL
        return "Unmeasurable sectors"
    else
        return nothing
    end
end

function group_for_current(desc::AbstractString)
    measurable = union(MEASURABLE_COMMON, MANUFACTURING, TRANSPORTATION_CURRENT, COMMUNICATION_CURRENT)
    if desc in measurable
        return "Measurable sectors"
    elseif desc in UNMEASURABLE_CURRENT
        return "Unmeasurable sectors"
    else
        return nothing
    end
end

function historical_source_rows(root::AbstractString = joinpath(@__DIR__, ".."))
    files = [
        joinpath(root, "source_csv", "historical_1947_2016", "underlying_data", "1947_1963.csv"),
        joinpath(root, "source_csv", "historical_1947_2016", "underlying_data", "1963_2016.csv"),
    ]

    rows = NamedTuple[]
    for path in files
        raw = read_csv_rows(path)
        header = raw[2]
        idx = Dict(name => i for (i, name) in enumerate(header))

        for row in raw[3:end]
            if length(row) < idx["hrs"] || isempty(row[idx["yr"]])
                continue
            end

            desc = row[idx["Description"]]
            group = group_for_historical(desc)
            isnothing(group) && continue

            go = value_float(row[idx["go."]])
            ii = value_float(row[idx["ii."]])
            push!(
                rows,
                (
                    year = Int(parse(Float64, row[idx["yr"]])),
                    industry = desc,
                    group = group,
                    nominal_go = go,
                    nominal_ii = ii,
                    nominal_va = go - ii,
                    go_q = value_float(row[idx["goqi."]]),
                    ii_q = value_float(row[idx["iiqi."]]),
                    hours = value_float(row[idx["hrs"]]),
                ),
            )
        end
    end

    base = Dict(
        r.industry => (r.nominal_go, r.nominal_ii, r.go_q, r.ii_q)
        for r in rows
        if r.year == 1982
    )

    out = NamedTuple[]
    for r in rows
        haskey(base, r.industry) || continue
        base_go, base_ii, base_go_q, base_ii_q = base[r.industry]
        real_go = base_go * r.go_q / base_go_q
        real_ii = base_ii * r.ii_q / base_ii_q
        push!(out, merge(r, (real_va = real_go - real_ii,)))
    end
    out
end

function aggregate_historical(rows; max_year::Union{Int, Nothing} = nothing)
    by_year_group = Dict{Tuple{Int, String}, NamedTuple{(:real_va, :hours), Tuple{Float64, Float64}}}()

    for r in rows
        if !isnothing(max_year) && r.year > max_year
            continue
        end
        key = (r.year, r.group)
        old = get(by_year_group, key, (real_va = 0.0, hours = 0.0))
        by_year_group[key] = (real_va = old.real_va + r.real_va, hours = old.hours + r.hours)
    end

    totals = Dict{Int, NamedTuple{(:real_va, :hours), Tuple{Float64, Float64}}}()
    for ((year, group), vals) in by_year_group
        group == "Total economy" && continue
        old = get(totals, year, (real_va = 0.0, hours = 0.0))
        totals[year] = (real_va = old.real_va + vals.real_va, hours = old.hours + vals.hours)
    end

    records = NamedTuple[]
    for year in sort(collect(keys(totals)))
        for group in ["Measurable sectors", "Unmeasurable sectors", "Total economy"]
            vals = group == "Total economy" ? totals[year] : get(by_year_group, (year, group), nothing)
            if isnothing(vals) || vals.hours == 0.0
                continue
            end
            output_per_hour = vals.real_va / vals.hours
            push!(
                records,
                (
                    year = year,
                    series = group,
                    real_value_added_millions = vals.real_va,
                    hours_millions = vals.hours,
                    real_value_added_per_hour = output_per_hour,
                    real_output_per_hour_thousands_1982_dollars = output_per_hour / 1000.0,
                ),
            )
        end
    end

    first_year = minimum(r.year for r in records)
    base_vals = Dict(r.series => r.real_value_added_per_hour for r in records if r.year == first_year)

    [
        merge(r, (index_first_year_100 = 100.0 * r.real_value_added_per_hour / base_vals[r.series],))
        for r in records
    ]
end

function griliches_productivity_1947_1990(root::AbstractString = joinpath(@__DIR__, ".."))
    aggregate_historical(historical_source_rows(root); max_year = 1990)
end

function sheet_table_from_source_csv(path::AbstractString)
    rows = read_csv_rows(path)
    years = [Int(parse(Float64, y)) for y in rows[2][2:end] if !isempty(y)]
    out = Dict{String, Dict{Int, Float64}}()

    for row in rows[3:end]
        if isempty(row) || isempty(row[1])
            continue
        end
        vals = Dict{Int, Float64}()
        for (year, value) in zip(years, row[2:end])
            if !isempty(value)
                vals[year] = value_float(value)
            end
        end
        out[row[1]] = vals
    end

    years, out
end

function positive_get(table, industry::AbstractString, year::Int)
    if !haskey(table, industry) || !haskey(table[industry], year)
        return nothing
    end
    value = table[industry][year]
    value > 0.0 ? value : nothing
end

function numeric_get(table, industry::AbstractString, year::Int)
    if !haskey(table, industry) || !haskey(table[industry], year)
        return nothing
    end
    table[industry][year]
end

annualized_log_growth(start::Real, finish::Real, years::Integer) =
    100.0 * (log(finish) - log(start)) / years

clean_number(x::AbstractString) = replace(strip(x), "," => "", "\$" => "")

function maybe_float(x::AbstractString)
    s = clean_number(x)
    isempty(s) && return nothing
    lowercase(s) in ["na", "n.a.", "--"] && return nothing
    all(==('.'), s) && return nothing
    parse(Float64, s)
end

function maybe_int(x::AbstractString)
    v = maybe_float(x)
    isnothing(v) && return nothing
    Int(round(v))
end

function normalized_header_index(header)
    Dict(lowercase(strip(name)) => i for (i, name) in enumerate(header))
end

function require_source(path::AbstractString, description::AbstractString)
    if !isfile(path)
        error("Missing $(description): $(path). See the README in its source_csv subdirectory.")
    end
end

function bea_fixed_asset_line(path::AbstractString; line_number::Int = 82, scale::Real = 1.0)
    raw = read_csv_rows(path)
    isempty(raw) && error("Empty BEA Fixed Assets source file: $(path)")

    header_row = findfirst(row -> any(lowercase.(strip.(row)) .== "linenumber"), raw)
    if !isnothing(header_row)
        header = raw[header_row]
        idx = normalized_header_index(header)
        required = ["linenumber", "timeperiod", "datavalue"]
        missing = [name for name in required if !haskey(idx, name)]
        isempty(missing) || error("BEA long CSV $(path) is missing columns: $(join(missing, ", "))")

        out = Dict{Int, Float64}()
        for row in raw[(header_row + 1):end]
            length(row) < maximum(values(idx)) && continue
            maybe_int(row[idx["linenumber"]]) == line_number || continue
            year = maybe_int(row[idx["timeperiod"]])
            value = maybe_float(row[idx["datavalue"]])
            if !isnothing(year) && !isnothing(value)
                out[year] = scale * value
            end
        end
        isempty(out) && error("No line $(line_number) observations found in $(path)")
        return out
    end

    year_row = findfirst(row -> count(x -> occursin(r"^\d{4}$", strip(x)), row) >= 3, raw)
    isnothing(year_row) && error("Could not identify a year header row in BEA Fixed Assets source file: $(path)")

    header = raw[year_row]
    year_cols = [(i, parse(Int, strip(x))) for (i, x) in enumerate(header) if occursin(r"^\d{4}$", strip(x))]
    candidate_rows = [
        row for row in raw[(year_row + 1):end]
        if (
            (!isempty(row) && maybe_int(row[1]) == line_number) ||
            any(cell -> occursin("Research and development", cell), row[1:min(length(row), 4)])
        )
    ]
    isempty(candidate_rows) && error("No line $(line_number) row found in $(path)")

    row = candidate_rows[1]
    out = Dict{Int, Float64}()
    for (col, year) in year_cols
        col <= length(row) || continue
        value = maybe_float(row[col])
        isnothing(value) || (out[year] = scale * value)
    end
    isempty(out) && error("No numeric observations found for line $(line_number) in $(path)")
    out
end

function fixed_assets_real_rd_1972(root::AbstractString = joinpath(@__DIR__, ".."))
    source_dir = joinpath(root, "source_csv", "bea_fixed_assets")
    nominal_path = joinpath(source_dir, "fa_table_2_7.csv")
    quantity_path = joinpath(source_dir, "fa_table_2_8.csv")
    require_source(nominal_path, "BEA Fixed Assets Table 2.7 CSV")
    require_source(quantity_path, "BEA Fixed Assets Table 2.8 CSV")

    nominal = bea_fixed_asset_line(nominal_path; line_number = 82, scale = 1000.0)
    quantity = bea_fixed_asset_line(quantity_path; line_number = 82)
    haskey(nominal, 1972) || error("BEA Fixed Assets Table 2.7 source must include 1972 to form 1972-dollar R&D investment.")
    haskey(quantity, 1972) || error("BEA Fixed Assets Table 2.8 source must include 1972 to rebase R&D investment.")
    quantity_1972 = quantity[1972]

    rows = NamedTuple[]
    for year in sort(collect(intersect(keys(nominal), keys(quantity))))
        nominal_value = nominal[year]
        quantity_value = quantity[year]
        if quantity_1972 <= 0.0 || quantity_value <= 0.0
            continue
        end
        push!(
            rows,
            (
                year = year,
                nominal_rd_investment_millions = nominal_value,
                rd_quantity_index = quantity_value,
                real_rd_investment_millions_1972_dollars = nominal[1972] * quantity_value / quantity_1972,
            ),
        )
    end
    rows
end

function read_patent_application_source(
    path::AbstractString;
    source_segment::AbstractString,
    period_type::AbstractString,
)
    require_source(path, "USPTO patent applications CSV")
    raw = read_csv_rows(path)
    isempty(raw) && error("Empty USPTO patent applications source file: $(path)")
    header = raw[1]
    idx = normalized_header_index(header)
    haskey(idx, "year") || error("USPTO CSV $(path) is missing column: year")
    domestic_has_values =
        haskey(idx, "domestic_applications") &&
        any(
            row -> length(row) >= idx["domestic_applications"] &&
                !isnothing(maybe_float(row[idx["domestic_applications"]])),
            raw[2:end],
        )
    value_col = if domestic_has_values
        "domestic_applications"
    elseif haskey(idx, "utility_applications")
        "utility_applications"
    else
        error("USPTO CSV $(path) must include domestic_applications or utility_applications")
    end
    measure = value_col == "domestic_applications" ? "domestic utility applications" : "utility applications"

    out = Dict{Int, NamedTuple{(:applications, :measure, :source_segment, :period_type), Tuple{Float64, String, String, String}}}()
    for row in raw[2:end]
        length(row) < maximum(values(idx)) && continue
        year = maybe_int(row[idx["year"]])
        applications = maybe_float(row[idx[value_col]])
        if !isnothing(year) && !isnothing(applications)
            out[year] = (
                applications = applications,
                measure = measure,
                source_segment = source_segment,
                period_type = period_type,
            )
        end
    end
    isempty(out) && error("No patent applications found in $(path)")
    out
end

function uspto_patent_applications(root::AbstractString = joinpath(@__DIR__, ".."))
    source_dir = joinpath(root, "source_csv", "uspto_patent_applications")
    calendar = read_patent_application_source(
        joinpath(source_dir, "patent_applications_by_origin.csv");
        source_segment = "PTMT calendar-year series",
        period_type = "calendar year",
    )

    extension_path = joinpath(source_dir, "workload_tables_fy_utility_applications.csv")
    if isfile(extension_path)
        last_calendar_year = maximum(keys(calendar))
        fiscal = read_patent_application_source(
            extension_path;
            source_segment = "USPTO workload-table fiscal-year extension",
            period_type = "fiscal year",
        )
        for year in sort(collect(keys(fiscal)))
            if year > last_calendar_year
                calendar[year] = fiscal[year]
            end
        end
    end

    calendar
end

function griliches_patents_per_real_rd(root::AbstractString = joinpath(@__DIR__, ".."))
    rd_rows = fixed_assets_real_rd_1972(root)
    patents = uspto_patent_applications(root)

    rows = NamedTuple[]
    for r in rd_rows
        haskey(patents, r.year) || continue
        if r.real_rd_investment_millions_1972_dollars <= 0.0
            continue
        end
        patent_row = patents[r.year]
        push!(
            rows,
            merge(
                r,
                (
                    patent_applications = patent_row.applications,
                    patent_applications_measure = patent_row.measure,
                    source_segment = patent_row.source_segment,
                    period_type = patent_row.period_type,
                    patent_applications_per_million_1972_rd_dollars =
                        patent_row.applications / r.real_rd_investment_millions_1972_dollars,
                    patent_applications_per_billion_1972_rd_dollars =
                        1000.0 * patent_row.applications / r.real_rd_investment_millions_1972_dollars,
                ),
            ),
        )
    end
    rows
end

function rd_tfp_growth_intensity(;
    start_year::Int = 2012,
    end_year::Int = 2024,
    intensity_year::Int = 2018,
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    current_dir = joinpath(root, "source_csv", "current_bea_bls_ilpa")
    _years, tfp = sheet_table_from_source_csv(joinpath(current_dir, "integrated_tfp_index.csv"))
    _years, rd_comp = sheet_table_from_source_csv(joinpath(current_dir, "capital_rd_compensation.csv"))
    _years, gross_output = sheet_table_from_source_csv(joinpath(current_dir, "gross_output.csv"))
    _years, value_added = sheet_table_from_source_csv(joinpath(current_dir, "value_added.csv"))

    rows = NamedTuple[]
    for industry in sort(collect(keys(tfp)))
        tfp_start = positive_get(tfp, industry, start_year)
        tfp_end = positive_get(tfp, industry, end_year)
        rd = numeric_get(rd_comp, industry, intensity_year)
        go = positive_get(gross_output, industry, intensity_year)
        va = positive_get(value_added, industry, intensity_year)

        if any(isnothing, (tfp_start, tfp_end, rd, go, va))
            continue
        end

        push!(
            rows,
            (
                industry = industry,
                sector_group = industry in MANUFACTURING ? "Manufacturing" : "Nonmanufacturing",
                tfp_start_year = start_year,
                tfp_end_year = end_year,
                rd_intensity_year = intensity_year,
                tfp_growth_annualized_percent = annualized_log_growth(tfp_start, tfp_end, end_year - start_year),
                rd_capital_compensation_to_gross_output = rd / go,
                rd_capital_compensation_to_value_added = rd / va,
                rd_capital_compensation_millions = rd,
                gross_output_millions = go,
                value_added_millions = va,
                tfp_start_index = tfp_start,
                tfp_end_index = tfp_end,
            ),
        )
    end
    rows
end

function griliches_rd_tfp_growth_intensity(root::AbstractString = joinpath(@__DIR__, ".."))
    vcat(
        rd_tfp_growth_intensity(; start_year = 1997, end_year = 2024, intensity_year = 2010, root = root),
        rd_tfp_growth_intensity(; start_year = 2012, end_year = 2024, intensity_year = 2018, root = root),
    )
end

function current_group_rows(hist_aggregated, root::AbstractString = joinpath(@__DIR__, ".."))
    current_dir = joinpath(root, "source_csv", "current_bea_bls_ilpa")
    years, va_nom = sheet_table_from_source_csv(joinpath(current_dir, "value_added.csv"))
    _years, va_q = sheet_table_from_source_csv(joinpath(current_dir, "va_quantity.csv"))
    _years, h_q = sheet_table_from_source_csv(joinpath(current_dir, "labor_hours_quantity.csv"))

    current_by_year_group = Dict{Tuple{Int, String}, NamedTuple{(:real_va_current, :hours_quantity), Tuple{Float64, Float64}}}()

    for (desc, row) in va_nom
        group = group_for_current(desc)
        if isnothing(group) || !haskey(va_q, desc) || !haskey(h_q, desc)
            continue
        end
        base_va_2017 = row[2017]
        for year in years
            real_va = base_va_2017 * va_q[desc][year] / 100.0
            hours_quantity = h_q[desc][year]
            old = get(current_by_year_group, (year, group), (real_va_current = 0.0, hours_quantity = 0.0))
            current_by_year_group[(year, group)] = (
                real_va_current = old.real_va_current + real_va,
                hours_quantity = old.hours_quantity + hours_quantity,
            )
        end
    end

    for year in years
        total = (real_va_current = 0.0, hours_quantity = 0.0)
        for group in ["Measurable sectors", "Unmeasurable sectors"]
            vals = get(current_by_year_group, (year, group), nothing)
            isnothing(vals) && continue
            total = (
                real_va_current = total.real_va_current + vals.real_va_current,
                hours_quantity = total.hours_quantity + vals.hours_quantity,
            )
        end
        current_by_year_group[(year, "Total economy")] = total
    end

    hist_2016 = Dict(
        r.series => (real_va = r.real_value_added_millions, hours = r.hours_millions)
        for r in hist_aggregated
        if r.year == 2016
    )

    out = NamedTuple[]
    for group in ["Measurable sectors", "Unmeasurable sectors", "Total economy"]
        current_base = current_by_year_group[(2016, group)]
        hist_base = hist_2016[group]
        for year in years
            vals = current_by_year_group[(year, group)]
            push!(
                out,
                (
                    year = year,
                    group = group,
                    real_va = hist_base.real_va * vals.real_va_current / current_base.real_va_current,
                    hours = hist_base.hours * vals.hours_quantity / current_base.hours_quantity,
                ),
            )
        end
    end
    out
end

function griliches_productivity_spliced_1947_2024(root::AbstractString = joinpath(@__DIR__, ".."))
    hist_aggregated = aggregate_historical(historical_source_rows(root))
    current_aggregated = aggregate_historical(current_group_rows(hist_aggregated, root))
    vcat(
        [r for r in hist_aggregated if r.year <= 2016],
        [r for r in current_aggregated if r.year > 2016],
    )
end

function write_griliches_productivity_1947_1990(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_bls_griliches_groups_productivity_1947_1990.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_productivity_1947_1990(root)
    header = [
        "year",
        "series",
        "real_value_added_millions",
        "hours_millions",
        "real_value_added_per_hour",
        "real_output_per_hour_thousands_1982_dollars",
        "index_first_year_100",
        "source_note",
    ]
    body = [
        [
            r.year,
            r.series,
            r.real_value_added_millions,
            r.hours_millions,
            r.real_value_added_per_hour,
            r.real_output_per_hour_thousands_1982_dollars,
            r.index_first_year_100,
            SOURCE_NOTE_1947_1990,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

function write_griliches_productivity_spliced_1947_2024(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_bls_griliches_groups_productivity_spliced_1947_2024.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_productivity_spliced_1947_2024(root)
    header = [
        "year",
        "series",
        "real_value_added_millions",
        "hours_millions",
        "real_value_added_per_hour",
        "real_output_per_hour_thousands_1982_dollars",
        "index_first_year_100",
        "source_note",
    ]
    body = [
        [
            r.year,
            r.series,
            r.real_value_added_millions,
            r.hours_millions,
            r.real_value_added_per_hour,
            r.real_output_per_hour_thousands_1982_dollars,
            r.index_first_year_100,
            SOURCE_NOTE_1947_2024,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

function write_griliches_rd_tfp_growth_intensity(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "bea_bls_tfp_growth_rd_intensity.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_rd_tfp_growth_intensity(root)
    header = [
        "industry",
        "sector_group",
        "tfp_start_year",
        "tfp_end_year",
        "rd_intensity_year",
        "tfp_growth_annualized_percent",
        "rd_capital_compensation_to_gross_output",
        "rd_capital_compensation_to_value_added",
        "rd_capital_compensation_millions",
        "gross_output_millions",
        "value_added_millions",
        "tfp_start_index",
        "tfp_end_index",
    ]
    body = [
        [
            r.industry,
            r.sector_group,
            r.tfp_start_year,
            r.tfp_end_year,
            r.rd_intensity_year,
            r.tfp_growth_annualized_percent,
            r.rd_capital_compensation_to_gross_output,
            r.rd_capital_compensation_to_value_added,
            r.rd_capital_compensation_millions,
            r.gross_output_millions,
            r.value_added_millions,
            r.tfp_start_index,
            r.tfp_end_index,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

function write_griliches_patents_per_real_rd(
    out_path::AbstractString = joinpath(@__DIR__, "..", "csv", "uspto_patent_applications_per_bea_rd_1972_dollars.csv"),
    root::AbstractString = joinpath(@__DIR__, ".."),
)
    rows = griliches_patents_per_real_rd(root)
    header = [
        "year",
        "patent_applications",
        "patent_applications_measure",
        "source_segment",
        "period_type",
        "nominal_rd_investment_millions",
        "rd_quantity_index",
        "real_rd_investment_millions_1972_dollars",
        "patent_applications_per_million_1972_rd_dollars",
        "patent_applications_per_billion_1972_rd_dollars",
        "source_note",
    ]
    body = [
        [
            r.year,
            r.patent_applications,
            r.patent_applications_measure,
            r.source_segment,
            r.period_type,
            r.nominal_rd_investment_millions,
            r.rd_quantity_index,
            r.real_rd_investment_millions_1972_dollars,
            r.patent_applications_per_million_1972_rd_dollars,
            r.patent_applications_per_billion_1972_rd_dollars,
            SOURCE_NOTE_PATENTS_RD,
        ]
        for r in rows
    ]
    write_csv_rows(out_path, header, body)
    out_path
end

function plot_griliches_productivity_rows(rows, title)
    p = plot(
        title = title,
        xlabel = "Year",
        ylabel = "Thousands of 1982 dollars",
        size = (700, 520),
        legend = :topleft,
        grid = false,
        framestyle = :box,
    )

    for (series, color, linestyle) in [
        ("Measurable sectors", :black, :solid),
        ("Total economy", :red, :solid),
        ("Unmeasurable sectors", :blue, :solid),
    ]
        series_rows = [r for r in rows if r.series == series]
        plot!(
            p,
            [r.year for r in series_rows],
            [r.real_output_per_hour_thousands_1982_dollars for r in series_rows];
            lw = 2,
            color = color,
            linestyle = linestyle,
            label = series,
        )
    end

    p
end

function plot_griliches_productivity_1947_1990(rows = griliches_productivity_1947_1990())
    plot_griliches_productivity_rows(rows, "Real Value Added Per Hour, 1947-1990")
end

function plot_griliches_productivity_1947_2024(rows = griliches_productivity_spliced_1947_2024())
    plot_griliches_productivity_rows(rows, "Real Value Added Per Hour, 1947-2024")
end

function plot_griliches_rd_tfp_scatter(;
    start_year::Int = 2012,
    end_year::Int = 2024,
    intensity_year::Int = 2018,
    rows = rd_tfp_growth_intensity(
        start_year = start_year,
        end_year = end_year,
        intensity_year = intensity_year,
    ),
)
    mfg = [r for r in rows if r.sector_group == "Manufacturing"]
    nonmfg = [r for r in rows if r.sector_group != "Manufacturing"]

    p = scatter(
        100 .* [r.rd_capital_compensation_to_gross_output for r in nonmfg],
        [r.tfp_growth_annualized_percent for r in nonmfg];
        title = "TFP Growth and R&D Intensity, $(start_year)-$(end_year)",
        xlabel = "R&D capital compensation / gross output, $(intensity_year) (percent)",
        ylabel = "Annualized TFP growth, $(start_year)-$(end_year) (percent)",
        label = "Nonmanufacturing",
        color = :gray,
        markerstrokecolor = :gray,
        markersize = 4,
        size = (700, 520),
        grid = false,
        framestyle = :box,
        legend = :topright,
    )

    scatter!(
        p,
        100 .* [r.rd_capital_compensation_to_gross_output for r in mfg],
        [r.tfp_growth_annualized_percent for r in mfg];
        label = "Manufacturing",
        color = :black,
        markerstrokecolor = :black,
        markersize = 5,
    )

    p
end

function plot_griliches_rd_tfp_scatter_manufacturing(;
    start_year::Int = 2012,
    end_year::Int = 2024,
    intensity_year::Int = 2018,
    rows = rd_tfp_growth_intensity(
        start_year = start_year,
        end_year = end_year,
        intensity_year = intensity_year,
    ),
)
    mfg = [r for r in rows if r.sector_group == "Manufacturing"]
    scatter(
        100 .* [r.rd_capital_compensation_to_gross_output for r in mfg],
        [r.tfp_growth_annualized_percent for r in mfg];
        title = "Manufacturing TFP Growth and R&D Intensity, $(start_year)-$(end_year)",
        xlabel = "R&D capital compensation / gross output, $(intensity_year) (percent)",
        ylabel = "Annualized TFP growth, $(start_year)-$(end_year) (percent)",
        label = "Manufacturing industries",
        color = :black,
        markerstrokecolor = :black,
        markersize = 5,
        size = (700, 520),
        grid = false,
        framestyle = :box,
        legend = :topright,
    )
end

function plot_griliches_patents_per_real_rd(;
    start_year::Int = 1920,
    end_year::Union{Int, Nothing} = 2024,
    rows = griliches_patents_per_real_rd(),
)
    plot_rows = [
        r for r in rows
        if r.year >= start_year && (isnothing(end_year) || r.year <= end_year)
    ]
    isempty(plot_rows) && error("No patent/R&D observations are available for the requested range.")

    calendar_rows = [r for r in plot_rows if r.period_type == "calendar year"]
    fiscal_rows = [r for r in plot_rows if r.period_type == "fiscal year"]

    p = plot(
        [r.year for r in calendar_rows],
        [r.patent_applications_per_million_1972_rd_dollars for r in calendar_rows];
        title = "Patent Applications per Real R&D Dollar",
        xlabel = "Year",
        ylabel = "Applications per million 1972 R&D dollars",
        label = "Calendar-year utility applications",
        color = :black,
        lw = 2,
        yscale = :log10,
        yticks = ([4, 8, 16, 32, 64, 128, 256, 512], ["4", "8", "16", "32", "64", "128", "256", "512"]),
        size = (700, 520),
        grid = false,
        framestyle = :box,
        legend = :topright,
    )

    if !isempty(fiscal_rows)
        bridge_rows = isempty(calendar_rows) ? fiscal_rows : vcat(calendar_rows[end:end], fiscal_rows)
        plot!(
            p,
            [r.year for r in bridge_rows],
            [r.patent_applications_per_million_1972_rd_dollars for r in bridge_rows];
            label = "Fiscal-year workload-table extension",
            color = :black,
            lw = 2,
            linestyle = :dash,
        )
    end

    p
end

if abspath(PROGRAM_FILE) == @__FILE__
    println(write_griliches_productivity_1947_1990())
    println(write_griliches_productivity_spliced_1947_2024())
    println(write_griliches_rd_tfp_growth_intensity())
    patent_sources = [
        joinpath(@__DIR__, "..", "source_csv", "bea_fixed_assets", "fa_table_2_7.csv"),
        joinpath(@__DIR__, "..", "source_csv", "bea_fixed_assets", "fa_table_2_8.csv"),
        joinpath(@__DIR__, "..", "source_csv", "uspto_patent_applications", "patent_applications_by_origin.csv"),
        joinpath(@__DIR__, "..", "source_csv", "uspto_patent_applications", "workload_tables_fy_utility_applications.csv"),
    ]
    if all(isfile, patent_sources)
        println(write_griliches_patents_per_real_rd())
    end
end
