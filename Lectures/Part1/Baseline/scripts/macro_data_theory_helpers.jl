# Helpers for staging MacroDataTheory tables and figures outside Pluto.
#
# Load after DelimitedFiles, Plots, PlutoUI, and HypertextLiteral.

const MACRO_ACCOUNTS_CSV = joinpath(@__DIR__, "..", "csv", "macro_data_theory_accounts.csv")

function macro_read_accounts(path::AbstractString = MACRO_ACCOUNTS_CSV)
    isfile(path) || error("Missing $(path). Run scripts/fetch_bea_source_tables.jl and scripts/build_macro_accounts.jl first.")
    raw, header = readdlm(path, ',', Any, '\n'; header = true)
    header_vec = strip.(string.(vec(header)))
    years = parse.(Int, header_vec[8:end])
    variable_names = strip.(string.(raw[:, 1]))
    values = map(raw[:, 8:end]) do x
        if x isa Number
            Float64(x)
        else
            s = strip(String(x))
            isempty(s) || s == "....." ? missing : parse(Float64, s)
        end
    end
    (; years, variable_names, values)
end

function macro_context(year::Integer; path::AbstractString = MACRO_ACCOUNTS_CSV)
    data = macro_read_accounts(path)
    year_col = findfirst(==(year), data.years)
    isnothing(year_col) && error("Year $(year) not found in $(path).")

    function value(variable)
        row = findfirst(==(variable), data.variable_names)
        isnothing(row) && error("Could not find variable: $(variable)")
        x = data.values[row, year_col]
        ismissing(x) ? missing : x / 1000
    end

    function series(variable)
        row = findfirst(==(variable), data.variable_names)
        isnothing(row) && error("Could not find variable: $(variable)")
        data.values[row, :] ./ 1000
    end

    function fill_before(variable, first_year)
        x = copy(series(variable))
        idx = findfirst(==(first_year), data.years)
        isnothing(idx) && error("Year $(first_year) not found.")
        x[1:idx-1] .= 0
        x
    end

    (; data.years, value, series, fill_before)
end

function macro_commas(n::Integer)
    sign = n < 0 ? "-" : ""
    s = string(abs(n))
    r = reverse(s)
    parts = [r[i:min(i + 2, end)] for i in 1:3:length(r)]
    sign * join(reverse.(parts) |> reverse, ",")
end

macro_format_billions(x) = ismissing(x) ? "-" : macro_commas(round(Int, x))

function macro_format_share(x, denominator)
    if ismissing(x) || ismissing(denominator) || denominator == 0
        return "-"
    end
    string(round(100 * x / denominator; digits = 1))
end

function macro_level_share_cells(x, denominator, share_label::AbstractString)
    @htl("""
    <td style="text-align:right; white-space:nowrap;">$(macro_format_billions(x))</td>
    <td style="text-align:right; white-space:nowrap;" title="$(share_label)">$(macro_format_share(x, denominator))</td>
    """)
end

function macro_nipa_table_html(year::Integer = 2024; path::AbstractString = MACRO_ACCOUNTS_CSV, show_title::Bool = true)
    ctx = macro_context(year; path)
    gdp = ctx.value("gdp")
    cells(variable) = macro_level_share_cells(ctx.value(variable), gdp, "%GDP")

    title_block = show_title ? @htl("""
    <div style="text-align:center; margin-bottom:.5em;">
        <div style="font-size:1.2em; font-weight:bold;">
            Table 1. U.S. National Income and Product Accounts (\$ Billions)
        </div>
        <div style="margin-top:0.5em;">Year: $(year)</div>
    </div>
    """) : @htl("")

    @htl("""
    <div style="max-width:760px; margin:0 auto;">
        $(title_block)
        <table style="border-collapse:collapse; width:100%;">
        <tr>
            <th style="text-align:left;">    </th>
            <th style="text-align:right;">Level</th>
            <th style="text-align:right;">%GDP</th>
        </tr>
        <tr><td><b>Gross domestic product</b></td>$(cells("gdp"))</tr>
        <tr><td style="padding-left:20px;">Personal consumption expenditures</td>$(cells("pce"))</tr>
        <tr><td style="padding-left:40px;">Services</td>$(cells("pce_services"))</tr>
        <tr><td style="padding-left:40px;">Nondurable goods</td>$(cells("pce_nondurable_goods"))</tr>
        <tr><td style="padding-left:40px;">Durable goods</td>$(cells("pce_durable_goods"))</tr>
        <tr><td style="padding-left:20px;">Gross private domestic investment</td>$(cells("gross_private_domestic_investment"))</tr>
        <tr><td style="padding-left:40px;">Fixed investment</td>$(cells("fixed_investment"))</tr>
        <tr><td style="padding-left:60px;">Nonresidential</td>$(cells("nonresidential_fixed_investment"))</tr>
        <tr><td style="padding-left:80px;">Equipment</td>$(cells("equipment_investment"))</tr>
        <tr><td style="padding-left:80px;">Structures</td>$(cells("structures_investment"))</tr>
        <tr><td style="padding-left:80px;">Intellectual property products</td>$(cells("intellectual_property_products_investment"))</tr>
        <tr><td style="padding-left:60px;">Residential</td>$(cells("residential_fixed_investment"))</tr>
        <tr><td style="padding-left:40px;">Change in private inventories</td>$(cells("change_in_private_inventories"))</tr>
        <tr><td style="padding-left:20px;">Government consumption expenditures and gross investment</td>$(cells("government_consumption_and_investment"))</tr>
        <tr><td style="padding-left:40px;">Federal</td>$(cells("federal_government_consumption_and_investment"))</tr>
        <tr><td style="padding-left:40px;">State and local</td>$(cells("state_and_local_government_consumption_and_investment"))</tr>
        <tr><td style="padding-left:20px;">Net exports</td>$(cells("net_exports"))</tr>
        <tr><td style="padding-left:40px;">Exports</td>$(cells("exports"))</tr>
        <tr><td style="padding-left:40px;">Imports</td>$(cells("imports"))</tr>
        <tr><td><b>Gross domestic income</b></td>$(cells("gdi"))</tr>
        <tr><td style="padding-left:20px;">Compensation of employees</td>$(cells("compensation_of_employees"))</tr>
        <tr><td style="padding-left:40px;">Wages and salaries</td>$(cells("wages_and_salaries"))</tr>
        <tr><td style="padding-left:40px;">Supplements to wages and salaries</td>$(cells("supplements_to_wages_and_salaries"))</tr>
        <tr><td style="padding-left:20px;">Taxes on production and imports</td>$(cells("taxes_on_production_and_imports"))</tr>
        <tr><td style="padding-left:20px;">Less: Subsidies</td>$(cells("subsidies"))</tr>
        <tr><td style="padding-left:20px;">Net operating surplus</td>$(cells("net_operating_surplus"))</tr>
        <tr><td style="padding-left:40px;">Private enterprises</td>$(cells("private_enterprises_net_operating_surplus"))</tr>
        <tr><td style="padding-left:60px;">Corporate profits</td>$(cells("corporate_profits"))</tr>
        <tr><td style="padding-left:80px;">Taxes on corporate income</td>$(cells("taxes_on_corporate_income"))</tr>
        <tr><td style="padding-left:80px;">Net dividends</td>$(cells("net_dividends"))</tr>
        <tr><td style="padding-left:80px;">Undistributed profits</td>$(cells("undistributed_corporate_profits"))</tr>
        <tr><td style="padding-left:60px;">Proprietors' income</td>$(cells("proprietors_income"))</tr>
        <tr><td style="padding-left:60px;">Rental income</td>$(cells("rental_income"))</tr>
        <tr><td style="padding-left:60px;">Net interest</td>$(cells("net_interest_and_miscellaneous_payments"))</tr>
        <tr><td style="padding-left:60px;">Business current transfer payments</td>$(cells("business_current_transfer_payments"))</tr>
        <tr><td style="padding-left:40px;">Current surplus of government enterprises</td>$(cells("current_surplus_of_government_enterprises"))</tr>
        <tr><td style="padding-left:20px;">Consumption of fixed capital</td>$(cells("consumption_of_fixed_capital"))</tr>
        <tr><td><b>Statistical discrepancy</b></td>$(cells("statistical_discrepancy"))</tr>
        </table>
    </div>
    """)
end

function macro_gdp_gdi_plot(; path::AbstractString = MACRO_ACCOUNTS_CSV)
    ctx = macro_context(2024; path)
    gdpbill = ctx.series("gdp")
    gdibill = ctx.series("gdi")
    ticks = (log.([100, 300, 1000, 3000, 10000, 30000]), ["100", "300", "1,000", "3,000", "10,000", "30,000"])
    p = plot(
        ctx.years,
        log.(gdpbill);
        lw = 2,
        color = :black,
        label = "GDP",
        xlabel = "Year",
        ylabel = "Billions of dollars",
        title = "Gross Domestic Product and Gross Domestic Income",
        size = (700, 550),
        legend = :topleft,
        grid = false,
        framestyle = :box,
        yticks = ticks,
    )
    plot!(p, ctx.years, log.(gdibill); lw = 2, color = :red, linestyle = :dash, label = "GDI")
    p
end

function macro_model_values(year::Integer; path::AbstractString = MACRO_ACCOUNTS_CSV)
    ctx = macro_context(year; path)
    v = ctx.value
    sales_taxes = ctx.fill_before("sales_taxes", 1931)
    year_col = findfirst(==(year), ctx.years)
    stax = sales_taxes[year_col]
    dstax = v("pce_durable_goods") / v("pce") * stax
    ndstax = stax - dstax
    cddep = v("consumer_durable_goods_depreciation_current_cost")
    gcndef = v("federal_nondefense_consumption") + v("state_and_local_consumption")
    gindef = v("federal_nondefense_investment") + v("state_and_local_investment")
    iK = 0.04 * (v("government_fixed_assets_current_cost") + v("consumer_durable_goods_current_cost"))
    Y = v("gdp") - stax + iK + cddep
    C = v("pce") + iK + cddep + gcndef - v("pce_durable_goods") - ndstax
    X = v("gross_private_domestic_investment") + v("pce_durable_goods") + gindef + v("net_exports") - dstax
    G = v("federal_national_defense")
    W = v("compensation_of_employees")
    NOS = v("net_operating_surplus")
    RE = v("undistributed_corporate_profits")
    Div = NOS + iK - RE + v("taxes_on_production_and_imports") - v("subsidies") - stax
    Dep = v("consumption_of_fixed_capital") + cddep
    (; value = v, stax, dstax, ndstax, cddep, gcndef, gindef, iK, Y, C, X, G, W, NOS, RE, Div, Dep)
end

function macro_model_accounts_html(year::Integer = 2024; path::AbstractString = MACRO_ACCOUNTS_CSV, show_title::Bool = true)
    m = macro_model_values(year; path)
    f(variable) = macro_level_share_cells(m.value(variable), m.Y, "%Y")
    b(x) = macro_level_share_cells(x, m.Y, "%Y")
    title_block = show_title ? @htl("""
    <div style="text-align:center; margin-bottom:.5em;">
        <div style="font-size:1.2em; font-weight:bold;">
            Table 2. Model National Income and Product Accounts (\$ Billions)
        </div>
        <div style="margin-top:0.5em;">Year: $(year)</div>
    </div>
    """) : @htl("")

    @htl("""
    <div style="max-width:980px; margin:0 auto;">
    $(title_block)
    <table style="margin-left:auto; margin-right:auto; border-collapse:collapse; width:100%;">
    <thead>
    <tr style="border-top:2px solid #999; border-bottom:2px solid #999;">
        <th style="text-align:left; padding:8px 12px;">Model</th>
        <th style="text-align:left; padding:8px 12px;">Construction from NIPA and fixed asset tables</th>
        <th style="text-align:right; padding:8px 12px;">Level</th>
        <th style="text-align:right; padding:8px 12px;">%Y</th>
    </tr>
    </thead>
    <tbody>
    <tr><td rowspan="5" style="vertical-align:top; padding:10px 18px;"><i>Y</i><sub>t</sub></td><td><b>Gross Domestic Product</b></td>$(f("gdp"))</tr>
    <tr><td style="padding-left:30px;">Plus: Imputed capital services (FA 1.1)</td>$(b(m.iK))</tr>
    <tr><td style="padding-left:30px;">Plus: Durable depreciation (FA 8.4)</td>$(b(m.cddep))</tr>
    <tr><td style="padding-left:30px;">Less: Sales taxes (NIPA 3.5)</td>$(b(m.stax))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model output</b></td>$(b(m.Y))</tr>
    <tr><td rowspan="7" style="vertical-align:top; padding:10px 18px;"><i>C</i><sub>t</sub></td><td><b>Personal consumption expenditures</b></td>$(f("pce"))</tr>
    <tr><td style="padding-left:30px;">Plus: Imputed capital services</td>$(b(m.iK))</tr>
    <tr><td style="padding-left:30px;">Plus: Durable depreciation</td>$(b(m.cddep))</tr>
    <tr><td style="padding-left:30px;">Plus: Government consumption, nondefense</td>$(b(m.gcndef))</tr>
    <tr><td style="padding-left:30px;">Less: Durable goods</td>$(f("pce_durable_goods"))</tr>
    <tr><td style="padding-left:30px;">Less: Sales tax, non-durable and services</td>$(b(m.ndstax))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model consumption</b></td>$(b(m.C))</tr>
    <tr><td rowspan="6" style="vertical-align:top; padding:10px 18px;"><i>X</i><sub>t</sub></td><td><b>Gross private domestic investment</b></td>$(f("gross_private_domestic_investment"))</tr>
    <tr><td style="padding-left:30px;">Plus: Durable goods</td>$(f("pce_durable_goods"))</tr>
    <tr><td style="padding-left:30px;">Plus: Government investment, nondefense</td>$(b(m.gindef))</tr>
    <tr><td style="padding-left:30px;">Plus: Net exports</td>$(f("net_exports"))</tr>
    <tr><td style="padding-left:30px;">Less: Sales tax, durable</td>$(b(m.dstax))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model investment</b></td>$(b(m.X))</tr>
    <tr><td rowspan="4" style="vertical-align:top; padding:10px 18px;"><i>G</i><sub>t</sub></td><td><b>Government consumption and investment</b></td>$(f("government_consumption_and_investment"))</tr>
    <tr><td style="padding-left:30px;">Less: Government consumption, nondefense</td>$(b(m.gcndef))</tr>
    <tr><td style="padding-left:30px;">Less: Government investment, nondefense</td>$(b(m.gindef))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model government</b></td>$(b(m.G))</tr>
    <tr><td colspan="4" style="height:28px;"></td></tr>
    <tr><th style="text-align:left; padding:8px 12px; border-bottom:1px solid black;">Model</th><th style="text-align:left; padding:8px 12px; border-bottom:1px solid black;">Construction from income and fixed asset tables</th><th style="text-align:right; padding:8px 12px; border-bottom:1px solid black;">Level</th><th style="text-align:right; padding:8px 12px; border-bottom:1px solid black;">%Y</th></tr>
    <tr><td rowspan="6" style="vertical-align:top; padding:10px 18px;"><i>Y</i><sub>t</sub></td><td><b>Gross Domestic Income</b></td>$(f("gdi"))</tr>
    <tr><td style="padding-left:30px;">Plus: Statistical discrepancy</td>$(f("statistical_discrepancy"))</tr>
    <tr><td style="padding-left:30px;">Plus: Imputed capital services (FA 1.1)</td>$(b(m.iK))</tr>
    <tr><td style="padding-left:30px;">Plus: Durable depreciation (FA 8.4)</td>$(b(m.cddep))</tr>
    <tr><td style="padding-left:30px;">Less: Sales taxes (NIPA 3.5)</td>$(b(m.stax))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model income</b></td>$(b(m.Y))</tr>
    <tr><td rowspan="2" style="vertical-align:top; padding:10px 18px;"><i>w</i><sub>t</sub><i>H</i><sub>t</sub></td><td><b>Compensation of Employees</b></td>$(f("compensation_of_employees"))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model wages</b></td>$(b(m.W))</tr>
    <tr><td rowspan="7" style="vertical-align:top; padding:10px 18px;"><i>D</i><sub>t</sub></td><td><b>Net Operating Surplus</b></td>$(f("net_operating_surplus"))</tr>
    <tr><td style="padding-left:30px;">Plus: Imputed capital services</td>$(b(m.iK))</tr>
    <tr><td style="padding-left:30px;">Plus: Taxes on production and imports</td>$(f("taxes_on_production_and_imports"))</tr>
    <tr><td style="padding-left:30px;">Less: Sales taxes</td>$(b(m.stax))</tr>
    <tr><td style="padding-left:30px;">Less: Subsidies</td>$(f("subsidies"))</tr>
    <tr><td style="padding-left:30px;">Less: Undistributed corporate profits</td>$(f("undistributed_corporate_profits"))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model dividends</b></td>$(b(m.Div))</tr>
    <tr><td rowspan="2" style="vertical-align:top; padding:10px 18px;"><i>K</i><sub>t+1</sub>-<i>K</i><sub>t</sub></td><td><b>Undistributed Corporate Profits</b></td>$(f("undistributed_corporate_profits"))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model net investment</b></td>$(b(m.RE))</tr>
    <tr><td rowspan="3" style="vertical-align:top; padding:10px 18px;"><i>&delta;K</i><sub>t</sub></td><td><b>Consumption of Fixed Capital</b></td>$(f("consumption_of_fixed_capital"))</tr>
    <tr><td style="padding-left:30px;">Plus: Durable depreciation (FA 8.4)</td>$(b(m.cddep))</tr>
    <tr style="border-bottom:1px solid #bbb;"><td><b>= Model depreciation</b></td>$(b(m.Dep))</tr>
    </tbody>
    </table>
    </div>
    """)
end
