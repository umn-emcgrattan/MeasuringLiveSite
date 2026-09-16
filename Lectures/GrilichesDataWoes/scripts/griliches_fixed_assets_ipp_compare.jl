# Pluto helpers for comparing BEA Fixed Assets IPP investment by sector.
#
# Use in Preface.jl after loading DelimitedFiles, PlutoUI, and HypertextLiteral:
#
# begin
#     include("scripts/griliches_fixed_assets_ipp_compare.jl")
#     left = @bind ipp_left_year Select(ipp_investment_years(); default=1947)
#     right = @bind ipp_right_year Select(ipp_investment_years(); default=last(ipp_investment_years()))
#     griliches_ipp_investment_compare_html(ipp_left_year, ipp_right_year; left_selector=left, right_selector=right)
# end

IPP_COMPARE_CSV = joinpath(
    @__DIR__,
    "..",
    "csv",
    "bea_fixed_assets_ipp_investment_distribution.csv",
)

IPP_COMPARE_LABELS = Dict(
    "Agriculture, forestry, fishing, and hunting" => "Agriculture",
    "Finance, insurance, real estate, rental, and leasing" => "Finance, insurance, real estate",
    "Arts, entertainment, recreation, accommodation, and food services" => "Arts, accommodation, food",
)

function ipp_compare_float_column(values)
    map(values) do x
        s = strip(string(x))
        isempty(s) || s == "missing" ? missing : parse(Float64, s)
    end
end

function ipp_compare_read_csv(path::AbstractString = IPP_COMPARE_CSV)
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
    share_ipp = ipp_compare_float_column(col("share_of_total_ipp_percent"))

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
                share_ipp = share_ipp[i],
            ),
        )
    end
    rows
end

function ipp_investment_years(path::AbstractString = IPP_COMPARE_CSV)
    rows = ipp_compare_read_csv(path)
    sort!(unique([r.year for r in rows]))
end

function ipp_compare_label(sector::AbstractString)
    get(IPP_COMPARE_LABELS, sector, sector)
end

function ipp_compare_rows(year_left::Integer, year_right::Integer; path::AbstractString = IPP_COMPARE_CSV)
    rows = ipp_compare_read_csv(path)
    keep = r -> r.row_type != "service_detail" && r.row_type != "total"
    by_key = Dict((r.year, r.sector) => r for r in rows if keep(r))
    sectors = sort(unique([r.sector for r in rows if keep(r)]); by = s -> by_key[(year_right, s)].sector_order)

    output = NamedTuple[]
    for sector in sectors
        left_row = by_key[(year_left, sector)]
        right_row = by_key[(year_right, sector)]
        push!(
            output,
            (
                sector = sector,
                label = ipp_compare_label(sector),
                sector_order = right_row.sector_order,
                left_share = left_row.share_ipp,
                right_share = right_row.share_ipp,
                change = right_row.share_ipp - left_row.share_ipp,
                is_summary = false,
            ),
        )
    end

    for (label, group, order) in [
        ("Griliches measurable sectors", "Griliches measurable sectors", 98),
        ("Other sectors", "Other sectors", 99),
    ]
        group_rows = [r for r in output if !r.is_summary && by_key[(year_right, r.sector)].measurable_group == group]
        left_share = sum(r.left_share for r in group_rows)
        right_share = sum(r.right_share for r in group_rows)
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

    output
end

function ipp_compare_percent(x)
    ismissing(x) ? "n.a." : string(round(x; digits = 1), "%")
end

function ipp_compare_change(x)
    ismissing(x) && return "n.a."
    sign = x > 0 ? "+" : ""
    string(sign, round(x; digits = 1), " pp")
end

function griliches_ipp_investment_compare_html(
    year_left::Integer = first(ipp_investment_years()),
    year_right::Integer = last(ipp_investment_years());
    left_selector = nothing,
    right_selector = nothing,
    show_title::Bool = true,
)
    rows = ipp_compare_rows(year_left, year_right)
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
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(ipp_compare_percent(r.left_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(left_width)%; background:#6b7280;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; white-space:nowrap;">$(ipp_compare_percent(r.right_share))</td>
            <td style="padding:7px 12px; width:28%;">
                <div style="height:10px; width:$(right_width)%; background:#2563a6;"></div>
            </td>
            <td style="padding:7px 12px; text-align:right; color:$(change_color); white-space:nowrap;">$(ipp_compare_change(r.change))</td>
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
                Intellectual Property Products Investment, $(year_left) and $(year_right)
            </div>
            <div style="font-size:.95em; color:#444; margin-top:3px;">
                Sector share of total IPP investment, percent
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
            Source: BEA Fixed Assets Tables 3.7I, 3.7ESI, and 1.5. Government is added from Table 1.5.
            Griliches measurable sectors are agriculture, mining, manufacturing, transportation, and utilities.
            Information is classified with other sectors because modern Information is broader than communications.
        </div>
    </div>
    """)
end
