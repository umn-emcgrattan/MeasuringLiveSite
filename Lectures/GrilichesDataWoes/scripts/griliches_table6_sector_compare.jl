# Pluto helpers for comparing the BEA NIPA Table-6D-style sector distribution.
#
# Use in Preface.jl after loading DelimitedFiles, PlutoUI, and HypertextLiteral:
#
# begin
#     include("scripts/griliches_table6_sector_compare.jl")
#     left = @bind table6_left_year Select(table6_sector_years(); default=1948)
#     right = @bind table6_right_year Select(table6_sector_years(); default=last(table6_sector_years()))
#     griliches_table6_sector_compare_html(table6_left_year, table6_right_year; left_selector=left, right_selector=right)
# end
#
# For persons engaged, use table68_persons_engaged_years() and
# griliches_table68_persons_engaged_compare_html().

TABLE6_COMPARE_CSV = joinpath(
    @__DIR__,
    "..",
    "csv",
    "bea_nipa_table6d_sector_distribution_1948_2023.csv",
)

TABLE68_COMPARE_CSV = joinpath(
    @__DIR__,
    "..",
    "csv",
    "bea_nipa_table68_persons_engaged_sector_distribution_1929_2022.csv",
)

TABLE6_COMPARE_SECTOR_LABELS = Dict(
    "Agriculture, forestry, fishing, and hunting" => "Agriculture",
    "Finance, insurance, real estate, rental, and leasing" => "Finance, insurance, real estate",
    "Arts, entertainment, recreation, accommodation, and food services" => "Arts, accommodation, food",
)

TABLE6_COMPARE_MEASURABLE_SECTORS = Set([
    "Agriculture, forestry, fishing, and hunting",
    "Mining",
    "Utilities",
    "Manufacturing",
    "Transportation and warehousing",
])

function table6_compare_read_csv(
    path::AbstractString = TABLE6_COMPARE_CSV;
    total_share_column::AbstractString = "share_of_national_income_percent",
    domestic_share_column::AbstractString = "share_of_domestic_industries_percent",
)
    raw, header = readdlm(path, ',', Any, '\n'; header = true)
    names = strip.(string.(vec(header)))
    rows = NamedTuple[]

    function col(name)
        idx = findfirst(==(name), names)
        isnothing(idx) && error("Column $(name) not found in $(path).")
        raw[:, idx]
    end

    years = parse.(Int, strip.(string.(col("year"))))
    sectors = strip.(string.(col("sector")))
    sector_order = parse.(Int, strip.(string.(col("sector_order"))))
    row_type = strip.(string.(col("row_type")))
    share_total = table6_compare_float_column(col(total_share_column))
    share_domestic = table6_compare_float_column(col(domestic_share_column))

    for i in eachindex(years)
        push!(
            rows,
            (
                year = years[i],
                sector = sectors[i],
                sector_order = sector_order[i],
                row_type = row_type[i],
                share_total = share_total[i],
                share_domestic = share_domestic[i],
            ),
        )
    end

    rows
end

function table6_compare_float_column(values)
    map(values) do x
        s = strip(string(x))
        isempty(s) || s == "missing" ? missing : parse(Float64, s)
    end
end

function table6_sector_years(path::AbstractString = TABLE6_COMPARE_CSV; total_share_column::AbstractString = "share_of_national_income_percent")
    rows = table6_compare_read_csv(path; total_share_column)
    sort!(unique([r.year for r in rows]))
end

table68_persons_engaged_years() =
    table6_sector_years(TABLE68_COMPARE_CSV; total_share_column = "share_of_persons_engaged_percent")

function table6_compare_sector_label(sector::AbstractString)
    get(TABLE6_COMPARE_SECTOR_LABELS, sector, sector)
end

function table6_compare_share(row; basis::Symbol = :national_income)
    if basis in (:national_income, :persons_engaged, :total)
        return row.share_total
    elseif basis == :domestic_industries
        return row.share_domestic
    else
        error("basis must be :national_income or :domestic_industries")
    end
end

function table6_compare_rows(
    year_left::Integer,
    year_right::Integer;
    basis::Symbol = :national_income,
    path::AbstractString = TABLE6_COMPARE_CSV,
    total_share_column::AbstractString = "share_of_national_income_percent",
    include_summary::Bool = true,
)
    rows = table6_compare_read_csv(path; total_share_column)
    by_key = Dict((r.year, r.sector) => r for r in rows if r.row_type != "service_detail")
    sectors = sort(
        unique([r.sector for r in rows if r.row_type != "service_detail"]);
        by = s -> by_key[(year_right, s)].sector_order,
    )

    output = NamedTuple[]
    for sector in sectors
        left_row = by_key[(year_left, sector)]
        right_row = by_key[(year_right, sector)]
        left_share = table6_compare_share(left_row; basis)
        right_share = table6_compare_share(right_row; basis)
        ismissing(left_share) && continue
        ismissing(right_share) && continue
        push!(
            output,
            (
                sector = sector,
                label = table6_compare_sector_label(sector),
                sector_order = right_row.sector_order,
                left_share = left_share,
                right_share = right_share,
                change = right_share - left_share,
                is_summary = false,
            ),
        )
    end
    if include_summary
        measurable = [r for r in output if r.sector in TABLE6_COMPARE_MEASURABLE_SECTORS]
        other = [r for r in output if !(r.sector in TABLE6_COMPARE_MEASURABLE_SECTORS)]
        for (label, group, order) in [
            ("Griliches measurable sectors", measurable, 98),
            ("Other sectors", other, 99),
        ]
            left_share = sum(r.left_share for r in group)
            right_share = sum(r.right_share for r in group)
            push!(
                output,
                (
                    sector = label,
                    label = label,
                    sector_order = order,
                    left_share = left_share,
                    right_share = right_share,
                    change = right_share - left_share,
                    is_summary = true,
                ),
            )
        end
    end
    output
end

function table6_compare_percent(x)
    ismissing(x) ? "n.a." : string(round(x; digits = 1), "%")
end

function table6_compare_change(x)
    ismissing(x) && return "n.a."
    sign = x > 0 ? "+" : ""
    string(sign, round(x; digits = 1), " pp")
end

function griliches_table6_sector_compare_html(
    year_left::Integer = first(table6_sector_years()),
    year_right::Integer = last(table6_sector_years());
    left_selector = nothing,
    right_selector = nothing,
    basis::Symbol = :national_income,
    path::AbstractString = TABLE6_COMPARE_CSV,
    total_share_column::AbstractString = "share_of_national_income_percent",
    title::AbstractString = "Major Industrial Sectors",
    subtitle::Union{AbstractString, Nothing} = nothing,
    show_title::Bool = true,
)
    rows = table6_compare_rows(year_left, year_right; basis, path, total_share_column)
    max_share = maximum([max(r.left_share, r.right_share) for r in rows])
    title_basis = isnothing(subtitle) ? (
        basis == :national_income ? "Share of national income" :
        basis == :persons_engaged ? "Share of persons engaged in production" :
        "Share of domestic-industry national income"
    ) : subtitle

    body = map(rows) do r
        left_width = 100 * r.left_share / max_share
        right_width = 100 * r.right_share / max_share
        change_color = r.change < 0 ? "#8b2f2f" : "#1f5f4a"
        row_border = r.is_summary && r.sector_order == 98 ? "border-top:2px solid #999;" : ""
        row_weight = r.is_summary ? "700" : "600"
        @htl("""
        <tr style="$(row_border)">
            <td style="padding:7px 12px; font-weight:$(row_weight);">$(r.label)</td>
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(table6_compare_percent(r.left_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(left_width)%; background:#6b7280;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(table6_compare_percent(r.right_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(right_width)%; background:#2563a6;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; color:$(change_color); white-space:nowrap;">$(table6_compare_change(r.change))</td>
        </tr>
        """)
    end

    controls = if isnothing(left_selector) && isnothing(right_selector)
        @htl("")
    else
        @htl("""
        <div style="display:flex; gap:18px; justify-content:center; align-items:center; margin:8px 0 14px 0; flex-wrap:wrap;">
            <div>First year: $(left_selector)</div>
            <div>Second year: $(right_selector)</div>
        </div>
        """)
    end

    title_block = show_title ? @htl("""
        <div style="text-align:center; margin-bottom:4px;">
            <div style="font-size:1.2em; font-weight:bold;">
                $(title), $(year_left) and $(year_right)
            </div>
            <div style="font-size:.95em; color:#444; margin-top:3px;">
                $(title_basis), percent
            </div>
        </div>
    """) : @htl("")

    @htl("""
    <div style="max-width:980px; margin:0 auto;">
        $(title_block)
        $(controls)
        <table style="border-collapse:collapse; width:100%; font-size:.92em;">
            <thead>
                <tr style="border-top:2px solid #999; border-bottom:2px solid #999;">
                    <th style="text-align:left; padding:8px 12px;">Sector</th>
                    <th style="text-align:right; padding:8px 12px;">$(year_left)</th>
                    <th></th>
                    <th style="text-align:right; padding:8px 12px;">$(year_right)</th>
                    <th></th>
                    <th style="text-align:right; padding:8px 12px;">Change</th>
                </tr>
            </thead>
            <tbody>
                $(body)
            </tbody>
        </table>
        <div style="font-size:.82em; color:#555; margin-top:10px; line-height:1.35;">
            Source: BEA NIPA archive, Table 6.1B/C/D. Pre-1998 communications are mapped to information;
            electric, gas, and sanitary services are mapped to utilities; transportation is net of those two components.
            Griliches measurable sectors are agriculture, mining, manufacturing, transportation, and utilities.
            Information is classified with other sectors because modern Information is broader than communications.
        </div>
    </div>
    """)
end

function griliches_table68_persons_engaged_compare_html(
    year_left::Integer = first(table68_persons_engaged_years()),
    year_right::Integer = last(table68_persons_engaged_years());
    left_selector = nothing,
    right_selector = nothing,
    basis::Symbol = :persons_engaged,
    show_title::Bool = true,
)
    griliches_table6_sector_compare_html(
        year_left,
        year_right;
        left_selector,
        right_selector,
        basis,
        path = TABLE68_COMPARE_CSV,
        total_share_column = "share_of_persons_engaged_percent",
        title = "Persons Engaged in Production by Sector",
        subtitle = basis == :domestic_industries ?
                   "Share of domestic-industry persons engaged, percent" :
                   "Share of persons engaged in production, percent",
        show_title,
    )
end
