# Helpers for staging MDTwithTaxes tables and figures outside Pluto.
# Load after DelimitedFiles, Plots, and HypertextLiteral.

const MACRO_GOVT_ACCOUNTS_CSV = joinpath(@__DIR__, "..", "csv", "government_receipts_expenditures.csv")

macro_parse_int(x) = x isa Number ? Int(x) : parse(Int, strip(string(x)))
function macro_parse_float(x)
    x isa Number && return Float64(x)
    s = strip(string(x))
    isempty(s) || s == "....." ? missing : parse(Float64, s)
end

function macro_read_accounts(path::AbstractString = MACRO_GOVT_ACCOUNTS_CSV)
    isfile(path) || error("Missing $(path). Run scripts/build_government_accounts.jl first.")
    raw, header = readdlm(path, ',', Any, '\n'; header = true)
    names = strip.(string.(vec(header)))
    names == ["Variable", "Label", "Line", "Indent", "Bold", "Unit", "Year", "Value"] ||
        error("Unexpected data schema in $(path).")

    years = sort!(unique(macro_parse_int.(raw[:, 7])))
    variables = strip.(string.(raw[:, 1]))
    labels = strip.(string.(raw[:, 2]))
    lines = string.(raw[:, 3])
    indents = macro_parse_int.(raw[:, 4])
    bold = lowercase.(strip.(string.(raw[:, 5]))) .== "true"
    values = macro_parse_float.(raw[:, 8])
    (; years, variables, labels, lines, indents, bold, values, raw)
end

function macro_govt_value(data, variable::AbstractString, year::Integer)
    idx = findfirst(i -> data.variables[i] == variable && macro_parse_int(data.raw[i, 7]) == year, eachindex(data.variables))
    isnothing(idx) && error("Could not find $(variable) for $(year).")
    value = data.values[idx]
    ismissing(value) && error("$(variable) is missing for $(year).")
    value
end

function macro_govt_rows(data, year::Integer; last_line::Integer = 31)
    idx = findall(i -> macro_parse_int(data.raw[i, 7]) == year && parse(Int, data.lines[i]) <= last_line, eachindex(data.variables))
    sort!(idx; by = i -> parse(Int, data.lines[i]))
end

macro_govt_commas(x) = ismissing(x) ? "-" : replace(string(round(Int, x)), r"(?<=\d)(?=(\d{3})+(?!\d))" => ",")

function macro_govt_share(x, denominator)
    if ismissing(x) || ismissing(denominator) || denominator == 0
        return "-"
    end
    string(round(100 * x / denominator; digits = 1))
end

function macro_nipa_govt_table_html(year::Integer = 2024; path::AbstractString = MACRO_GOVT_ACCOUNTS_CSV, show_title::Bool = true)
    data = macro_read_accounts(path)
    year in data.years || error("Year $(year) not found in $(path).")
    receipts = macro_govt_value(data, "current_receipts", year)
    expenditures = macro_govt_value(data, "current_expenditures", year)

    title_block = show_title ? @htl("""
    <div style="text-align:center; margin-bottom:.5em;">
        <div style="font-size:1.2em; font-weight:bold;">
            Table 1. U.S. Government Current Receipts and Expenditures (\$ Billions)
        </div>
        <div style="margin-top:.5em;">Year: $(year)</div>
    </div>
    """) : @htl("")

    rows = map(macro_govt_rows(data, year)) do i
        line = parse(Int, data.lines[i])
        denominator = line <= 19 ? receipts : expenditures
        share = macro_govt_share(data.values[i], denominator)
        weight = data.bold[i] ? "font-weight:bold;" : ""
        @htl("""
        <tr>
            <td style="padding-left:$(8 * data.indents[i])px; $(weight)">$(data.labels[i])</td>
            <td style="text-align:right; white-space:nowrap; $(weight)">$(macro_govt_commas(data.values[i]))</td>
            <td style="text-align:right; white-space:nowrap; $(weight)">$(share)</td>
        </tr>
        """)
    end

    @htl("""
    <div style="max-width:820px; margin:0 auto;">
        $(title_block)
        <table style="border-collapse:collapse; width:100%; line-height:1.25;">
            <tr>
                <th style="text-align:left;"></th>
                <th style="text-align:right;">Level</th>
                <th style="text-align:right;">% total</th>
            </tr>
            $(rows)
        </table>
        <div style="font-size:.82em; margin-top:.6em; color:#444;">
            Source: U.S. Bureau of Economic Analysis, NIPA Table 3.1.
            Receipt components are shares of current receipts; expenditure and saving rows are shares of current expenditures.
        </div>
    </div>
    """)
end

function macro_receipt_expenditure_plot(; path::AbstractString = MACRO_GOVT_ACCOUNTS_CSV)
    data = macro_read_accounts(path)
    receipts = [macro_govt_value(data, "current_receipts", year) for year in data.years]
    expenditures = [macro_govt_value(data, "current_expenditures", year) for year in data.years]
    ticks = (log.([10, 30, 100, 300, 1000, 3000, 10000]), ["10", "30", "100", "300", "1,000", "3,000", "10,000"])
    p = plot(
        data.years,
        log.(receipts);
        lw = 2,
        color = :black,
        label = "Current receipts",
        xlabel = "Year",
        ylabel = "Billions of dollars",
        title = "U.S. Government Current Receipts and Expenditures",
        size = (700, 550),
        legend = :topleft,
        grid = false,
        framestyle = :box,
        yticks = ticks,
    )
    plot!(p, data.years, log.(expenditures); lw = 2, color = :red, linestyle = :dash, label = "Current expenditures")
    p
end
