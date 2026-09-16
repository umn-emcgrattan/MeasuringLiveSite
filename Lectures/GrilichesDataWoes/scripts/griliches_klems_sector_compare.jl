# Pluto helpers for comparing the BEA-BLS/KLEMS sector distribution.
#
# Load after DelimitedFiles, PlutoUI, and HypertextLiteral.

KLEMS_COMPARE_CSV = joinpath(
    @__DIR__,
    "..",
    "csv",
    "bea_bls_klems_sector_distribution_1963_2024.csv",
)

KLEMS_COMPARE_SECTOR_LABELS = Dict(
    "Agriculture, forestry, fishing, and hunting" => "Agriculture",
    "Finance, insurance, real estate, rental, and leasing" => "Finance, insurance, real estate",
    "Arts, entertainment, recreation, accommodation, and food services" => "Arts, accommodation, food",
)

function klems_compare_float_column(values)
    map(values) do x
        s = strip(string(x))
        isempty(s) || s == "missing" ? missing : parse(Float64, s)
    end
end

function klems_compare_read_csv(
    path::AbstractString = KLEMS_COMPARE_CSV;
    share_column::AbstractString = "share_of_value_added_percent",
)
    raw, header = readdlm(path, ',', Any, '\n'; header = true)
    names = strip.(string.(vec(header)))

    function col(name)
        idx = findfirst(==(name), names)
        isnothing(idx) && error("Column $(name) not found in $(path).")
        raw[:, idx]
    end

    years = parse.(Int, strip.(string.(col("year"))))
    sectors = strip.(string.(col("sector")))
    sector_order = parse.(Int, strip.(string.(col("sector_order"))))
    row_type = strip.(string.(col("row_type")))
    measurable_group = strip.(string.(col("measurable_group")))
    share = klems_compare_float_column(col(share_column))

    rows = NamedTuple[]
    for i in eachindex(years)
        push!(
            rows,
            (
                year = years[i],
                sector = sectors[i],
                sector_order = sector_order[i],
                row_type = row_type[i],
                measurable_group = measurable_group[i],
                share = share[i],
            ),
        )
    end
    rows
end

function klems_sector_years(
    path::AbstractString = KLEMS_COMPARE_CSV;
    share_column::AbstractString = "share_of_value_added_percent",
)
    rows = klems_compare_read_csv(path; share_column)
    sort!(unique([r.year for r in rows]))
end

klems_va_years() = klems_sector_years(KLEMS_COMPARE_CSV; share_column = "share_of_value_added_percent")
klems_hours_years() = klems_sector_years(KLEMS_COMPARE_CSV; share_column = "share_of_hours_percent")

function klems_compare_sector_label(sector::AbstractString)
    get(KLEMS_COMPARE_SECTOR_LABELS, sector, sector)
end

function klems_compare_rows(
    year_left::Integer,
    year_right::Integer;
    share_column::AbstractString = "share_of_value_added_percent",
    include_summary::Bool = true,
)
    rows = klems_compare_read_csv(; share_column)
    by_key = Dict((r.year, r.sector) => r for r in rows if r.row_type != "service_detail")
    sectors = sort(
        unique([r.sector for r in rows if r.row_type != "service_detail" && r.sector != "Total"]);
        by = s -> by_key[(year_right, s)].sector_order,
    )

    output = NamedTuple[]
    for sector in sectors
        left_row = by_key[(year_left, sector)]
        right_row = by_key[(year_right, sector)]
        left_share = left_row.share
        right_share = right_row.share
        ismissing(left_share) && continue
        ismissing(right_share) && continue
        push!(
            output,
            (
                sector = sector,
                label = klems_compare_sector_label(sector),
                sector_order = right_row.sector_order,
                left_share = left_share,
                right_share = right_share,
                change = right_share - left_share,
                is_summary = false,
                measurable_group = right_row.measurable_group,
            ),
        )
    end

    if include_summary
        for (label, group_label, order) in [
            ("Griliches measurable sectors", "Griliches measurable sectors", 98),
            ("Other sectors", "Other sectors", 99),
        ]
            group = [r for r in output if r.measurable_group == group_label]
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
                    measurable_group = group_label,
                ),
            )
        end
    end
    output
end

function klems_compare_percent(x)
    ismissing(x) ? "n.a." : string(round(x; digits = 1), "%")
end

function klems_compare_change(x)
    ismissing(x) && return "n.a."
    sign = x > 0 ? "+" : ""
    string(sign, round(x; digits = 1), " pp")
end

function griliches_klems_sector_compare_html(
    year_left::Integer,
    year_right::Integer;
    share_column::AbstractString = "share_of_value_added_percent",
    title::AbstractString = "Major Industrial Sectors",
    subtitle::AbstractString = "Share of value added, percent",
    left_selector = nothing,
    right_selector = nothing,
    show_title::Bool = true,
)
    rows = klems_compare_rows(year_left, year_right; share_column)
    max_share = maximum([max(r.left_share, r.right_share) for r in rows])

    body = map(rows) do r
        left_width = 100 * r.left_share / max_share
        right_width = 100 * r.right_share / max_share
        change_color = r.change < 0 ? "#8b2f2f" : "#1f5f4a"
        row_border = r.is_summary && r.sector_order == 98 ? "border-top:2px solid #999;" : ""
        row_weight = r.is_summary ? "700" : "600"
        @htl("""
        <tr style="$(row_border)">
            <td style="padding:7px 12px; font-weight:$(row_weight);">$(r.label)</td>
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(klems_compare_percent(r.left_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(left_width)%; background:#6b7280;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(klems_compare_percent(r.right_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(right_width)%; background:#2563a6;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; color:$(change_color); white-space:nowrap;">$(klems_compare_change(r.change))</td>
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
                $(subtitle)
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
            Source: BEA-BLS historical KLEMS, current BEA-BLS industry-level production account,
            and BLS detailed industries hours/employment. Information is classified as unmeasurable.
        </div>
    </div>
    """)
end

function griliches_klems_va_compare_html(
    year_left::Integer = first(klems_va_years()),
    year_right::Integer = last(klems_va_years());
    left_selector = nothing,
    right_selector = nothing,
    show_title::Bool = true,
)
    griliches_klems_sector_compare_html(
        year_left,
        year_right;
        share_column = "share_of_value_added_percent",
        title = "Major Industrial Sectors",
        subtitle = "Share of value added, percent",
        left_selector,
        right_selector,
        show_title,
    )
end

function griliches_klems_hours_compare_html(
    year_left::Integer = first(klems_hours_years()),
    year_right::Integer = last(klems_hours_years());
    left_selector = nothing,
    right_selector = nothing,
    show_title::Bool = true,
)
    griliches_klems_sector_compare_html(
        year_left,
        year_right;
        share_column = "share_of_hours_percent",
        title = "Major Industrial Sectors",
        subtitle = "Share of hours worked, percent",
        left_selector,
        right_selector,
        show_title,
    )
end
