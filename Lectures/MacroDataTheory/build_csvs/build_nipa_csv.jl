using BeaData
using CSV
using DataFrames
using Dates
using Printf

const START_YEAR = 1929
const DEFAULT_END_YEAR = 2025
const DEFAULT_OUTPUT = joinpath(@__DIR__, "nipa.csv")
const ROOT_OUTPUT = normpath(joinpath(@__DIR__, "..", "nipa.csv"))

struct NIPAItem
    variable::String
    label::String
    long_label::String
    dataset::String
    table::String
    line::String
    unit::String
end

function item(variable, label, dataset, table, line;
              long_label=label,
              unit="Millions of dollars")
    NIPAItem(String(variable), label, long_label, dataset, table, line, unit)
end

nipa_item(variable, label, table, line; long_label=label) =
    item(variable, label, "NIPA", table, line; long_label)

fa_item(variable, label, table, line; long_label=label) =
    item(variable, label, "FixedAssets", table, line; long_label)

blank(variable, label) = NIPAItem(String(variable), label, "", "", "", "", "")

const ITEMS = [
    nipa_item(:gdp, "Gross domestic product", "T10105", "01"),
    nipa_item(:pce, " Personal consumption expenditures", "T10105", "02"),
    nipa_item(:pce_goods, "   Goods", "T10105", "03",
              long_label="Personal consumption expenditures: Goods"),
    nipa_item(:pce_durable_goods, "     Durable goods", "T10105", "04",
              long_label="Personal consumption expenditures: Durable goods"),
    nipa_item(:pce_nondurable_goods, "     Nondurable goods", "T10105", "05",
              long_label="Personal consumption expenditures: Nondurable goods"),
    nipa_item(:pce_services, "   Services", "T10105", "06",
              long_label="Personal consumption expenditures: Services"),
    nipa_item(:gross_private_domestic_investment, " Gross private domestic investment", "T10105", "07"),
    nipa_item(:fixed_investment, "   Fixed investment", "T10105", "08"),
    nipa_item(:nonresidential_fixed_investment, "     Nonresidential", "T10105", "09",
              long_label="Nonresidential fixed investment"),
    nipa_item(:structures_investment, "       Structures", "T10105", "10",
              long_label="Nonresidential structures investment"),
    nipa_item(:equipment_investment, "       Equipment", "T10105", "11",
              long_label="Nonresidential equipment investment"),
    nipa_item(:intellectual_property_products_investment, "       Intellectual property products", "T10105", "12",
              long_label="Nonresidential intellectual property products investment"),
    nipa_item(:residential_fixed_investment, "     Residential", "T10105", "13",
              long_label="Residential fixed investment"),
    nipa_item(:change_in_private_inventories, "   Change in private inventories", "T10105", "14"),
    nipa_item(:net_exports, " Net exports of goods and services", "T10105", "15"),
    nipa_item(:exports, "   Exports", "T10105", "16",
              long_label="Exports of goods and services"),
    nipa_item(:exports_goods, "     Goods", "T10105", "17",
              long_label="Exports: Goods"),
    nipa_item(:exports_services, "     Services", "T10105", "18",
              long_label="Exports: Services"),
    nipa_item(:imports, "   Imports", "T10105", "19",
              long_label="Imports of goods and services"),
    nipa_item(:imports_goods, "     Goods", "T10105", "20",
              long_label="Imports: Goods"),
    nipa_item(:imports_services, "     Services", "T10105", "21",
              long_label="Imports: Services"),
    nipa_item(:government_consumption_and_investment, " Government consumption expenditures and gross investment", "T10105", "22"),
    nipa_item(:federal_government_consumption_and_investment, "   Federal", "T10105", "23",
              long_label="Federal government consumption expenditures and gross investment"),
    nipa_item(:national_defense, "     National defense", "T10105", "24",
              long_label="Federal national defense consumption expenditures and gross investment"),
    nipa_item(:federal_nondefense, "     Nondefense", "T10105", "25",
              long_label="Federal nondefense consumption expenditures and gross investment"),
    nipa_item(:state_and_local_government_consumption_and_investment, "   State and local", "T10105", "26",
              long_label="State and local government consumption expenditures and gross investment"),
    nipa_item(:gdi, "Gross domestic income", "T11000", "01"),
    nipa_item(:compensation_of_employees, " Compensation of employees, paid", "T11000", "02"),
    nipa_item(:wages_and_salaries, "   Wages and salaries", "T11000", "03"),
    nipa_item(:wages_and_salaries_to_persons, "       To persons", "T11000", "04",
              long_label="Wages and salaries: To persons"),
    nipa_item(:wages_and_salaries_to_rest_of_world, "       To the rest of the world", "T11000", "05",
              long_label="Wages and salaries: To the rest of the world"),
    nipa_item(:supplements_to_wages_and_salaries, "   Supplements to wages and salaries", "T11000", "06"),
    nipa_item(:taxes_on_production_and_imports, " Taxes on production and imports", "T11000", "07"),
    nipa_item(:subsidies, " Less: Subsidies", "T11000", "08"),
    nipa_item(:net_operating_surplus, " Net operating surplus", "T11000", "09"),
    nipa_item(:private_enterprises_net_operating_surplus, "   Private enterprises", "T11000", "10"),
    nipa_item(:net_interest_and_miscellaneous_payments, "     Net interest and miscellaneous payments", "T11000", "11",
              long_label="Net interest and miscellaneous payments, domestic industries"),
    nipa_item(:business_current_transfer_payments, "     Business current transfer payments (net)", "T11000", "12"),
    nipa_item(:proprietors_income, "     Proprietors' income", "T11000", "13",
              long_label="Proprietors' income with inventory valuation and capital consumption adjustments"),
    nipa_item(:rental_income, "     Rental income", "T11000", "14",
              long_label="Rental income of persons with capital consumption adjustment"),
    nipa_item(:corporate_profits, "     Corporate profits", "T11000", "15",
              long_label="Corporate profits with inventory valuation and capital consumption adjustments, domestic industries"),
    nipa_item(:taxes_on_corporate_income, "       Taxes on corporate income", "T11000", "16"),
    nipa_item(:profits_after_tax, "       Profits after tax", "T11000", "17",
              long_label="Profits after tax with inventory valuation and capital consumption adjustments"),
    nipa_item(:net_dividends, "         Net dividends", "T11000", "18"),
    nipa_item(:undistributed_corporate_profits, "         Undistributed corporate profits", "T11000", "19",
              long_label="Undistributed corporate profits with inventory valuation and capital consumption adjustments"),
    nipa_item(:current_surplus_of_government_enterprises, "   Current surplus of government enterprises", "T11000", "20"),
    nipa_item(:consumption_of_fixed_capital, " Consumption of fixed capital", "T11000", "21"),
    nipa_item(:private_consumption_of_fixed_capital, "   Private", "T11000", "22",
              long_label="Private consumption of fixed capital"),
    nipa_item(:government_consumption_of_fixed_capital, "   Government", "T11000", "23",
              long_label="Government consumption of fixed capital"),
    blank(:main_addendum, " Addendum:"),
    nipa_item(:statistical_discrepancy, "   Statistical discrepancy", "T11000", "24"),
    blank(:bea_addenda, " Addenda from other BEA tables:"),
    nipa_item(:sales_taxes, "   Sales taxes", "T30500", "20",
              long_label="State and local sales taxes"),
    fa_item(:government_fixed_assets_current_cost, "   Government fixed assets, current cost", "FAAt101", "09",
            long_label="Current-cost net stock of government fixed assets"),
    fa_item(:consumer_durable_goods_current_cost, "   Consumer durable goods, current cost", "FAAt101", "15",
            long_label="Current-cost net stock of consumer durable goods"),
    fa_item(:consumer_durable_goods_depreciation_current_cost, "   Consumer durable goods depreciation, current cost", "FAAt804", "01",
            long_label="Current-cost depreciation of consumer durable goods"),
    nipa_item(:federal_national_defense, "   Federal national defense", "T30905", "17",
              long_label="Federal national defense consumption expenditures and gross investment"),
    nipa_item(:federal_nondefense_consumption, "   Federal nondefense consumption", "T30905", "26",
              long_label="Federal nondefense consumption expenditures"),
    nipa_item(:federal_nondefense_investment, "   Federal nondefense investment", "T30905", "27",
              long_label="Federal nondefense gross investment"),
    nipa_item(:state_and_local_consumption, "   State and local consumption", "T30905", "34",
              long_label="State and local government consumption expenditures"),
    nipa_item(:state_and_local_investment, "   State and local investment", "T30905", "35",
              long_label="State and local government gross investment"),
]

function parse_args(args)
    end_year = DEFAULT_END_YEAR
    output = DEFAULT_OUTPUT
    update_root = false
    check_root = false
    allow_schema_change = false

    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "--end-year"
            i == length(args) && error("--end-year requires a value")
            end_year = parse(Int, args[i + 1])
            i += 2
        elseif startswith(arg, "--end-year=")
            end_year = parse(Int, split(arg, "=", limit=2)[2])
            i += 1
        elseif arg == "--output"
            i == length(args) && error("--output requires a value")
            output = args[i + 1]
            i += 2
        elseif startswith(arg, "--output=")
            output = split(arg, "=", limit=2)[2]
            i += 1
        elseif arg == "--update-root"
            update_root = true
            i += 1
        elseif arg == "--allow-schema-change"
            allow_schema_change = true
            i += 1
        elseif arg == "--check-root"
            check_root = true
            i += 1
        elseif arg == "--help" || arg == "-h"
            println("""
            Usage:
              julia build_nipa_csv.jl [--end-year YEAR] [--output FILE] [--check-root]

            Defaults:
              --end-year $(DEFAULT_END_YEAR)
              --output   $(DEFAULT_OUTPUT)

            The generated CSV stores values in millions of dollars, matching
            the existing Lecture1.jl convention.
            """)
            exit(0)
        else
            error("Unknown argument: $(arg)")
        end
    end

    end_year < START_YEAR && error("end year must be at least $(START_YEAR)")
    return (; end_year, output, update_root, check_root, allow_schema_change)
end

function fetch_bea_table(dataset, table, start_year, end_year)
    freq = "A"
    key = get(ENV, "BEA_API_KEY", "")

    if isempty(key)
        return bea_table(dataset, table, freq, start_year, end_year)
    else
        return bea_table(dataset, table, freq, start_year, end_year; user_id=key)
    end
end

function table_cache(items, start_year, end_year)
    cache = Dict{Tuple{String,String},Any}()
    for spec in items
        isempty(spec.table) && continue
        key = (spec.dataset, spec.table)
        if !haskey(cache, key)
            @printf("Fetching %s %s, %d-%d\n", spec.dataset, spec.table, start_year, end_year)
            cache[key] = fetch_bea_table(spec.dataset, spec.table, start_year, end_year)
        end
    end
    return cache
end

function line_values(table, line, years)
    colname = "Line$(line)"
    col = Symbol(colname)
    colname in names(table.data_values) || error("Column $(colname) not found.")

    values_by_year = Dict{Int,Union{Missing,Float64}}()
    for row in eachrow(table.data_values)
        yr = year(row.TimePeriod)
        x = row[col]
        values_by_year[yr] = ismissing(x) ? missing : Float64(x)
    end

    missing_years = [yr for yr in years if !haskey(values_by_year, yr)]
    if !isempty(missing_years)
        @printf("  Missing observations for Line%s in years: %s\n",
                line, join(missing_years, ", "))
    end

    return [get(values_by_year, yr, missing) for yr in years]
end

function millions_from_bea_billions(x)
    ismissing(x) && return missing
    return round(Int, 1000 * x)
end

function csv_cell(x)
    ismissing(x) && return "....."
    return string(x)
end

function build_nipa_dataframe(items, start_year, end_year)
    years = collect(start_year:end_year)
    cache = table_cache(items, start_year, end_year)

    variables = [spec.variable for spec in items]
    length(unique(variables)) == length(variables) ||
        error("Variable names must be unique.")

    out = DataFrame(
        Variable = String[],
        Label = String[],
        LongLabel = String[],
        Source = String[],
        Table = String[],
        Line = String[],
        Unit = String[],
    )

    for yr in years
        out[!, string(yr)] = String[]
    end

    for spec in items
        vals = if isempty(spec.table)
            fill("", length(years))
        else
            table = cache[(spec.dataset, spec.table)]
            csv_cell.(millions_from_bea_billions.(line_values(table, spec.line, years)))
        end
        push!(
            out,
            (
                spec.variable,
                spec.label,
                spec.long_label,
                spec.dataset,
                spec.table,
                spec.line,
                spec.unit,
                vals...,
            )
        )
    end

    return out
end

function write_csv(df, path)
    mkpath(dirname(path))
    tmp = path * ".tmp"
    CSV.write(tmp, df)
    mv(tmp, path; force=true)
end

function compare_csvs(old_path, new_path)
    isfile(old_path) || error("Could not find old CSV: $(old_path)")
    isfile(new_path) || error("Could not find new CSV: $(new_path)")

    old = CSV.read(old_path, DataFrame; types=String)
    new = CSV.read(new_path, DataFrame; types=String)

    year_column(name) = occursin(r"^\d{4}$", name)
    shared_cols = [name for name in intersect(names(old), names(new)) if year_column(name)]
    isempty(shared_cols) && error("No shared columns found.")

    row_count = min(nrow(old), nrow(new))
    differences = String[]

    for col in shared_cols
        for row in 1:row_count
            old_value = old[row, col]
            new_value = new[row, col]
            if !isequal(old_value, new_value)
                push!(
                    differences,
                    "row $(row), column $(col): old=$(old_value), new=$(new_value)"
                )
            end
        end
    end

    if isempty(differences)
        @printf("Old and new CSVs match on %d shared rows and %d shared columns.\n",
                row_count, length(shared_cols))
    else
        @printf("Found %d differences on shared rows/columns.\n", length(differences))
        for diff in differences[1:min(end, 10)]
            println(diff)
        end
        length(differences) > 10 && println("...")
    end

    extra_new_cols = [name for name in setdiff(names(new), names(old)) if year_column(name)]
    if !isempty(extra_new_cols)
        println("New CSV has additional columns: ", join(extra_new_cols, ", "))
    end
end

function main()
    args = parse_args(ARGS)

    @printf("Building NIPA CSV through %d\n", args.end_year)
    df = build_nipa_dataframe(ITEMS, START_YEAR, args.end_year)

    write_csv(df, args.output)
    @printf("Wrote %s\n", args.output)

    if args.check_root
        compare_csvs(ROOT_OUTPUT, args.output)
    end

    if args.update_root
        if !args.allow_schema_change
            error("""
            The generated CSV uses the new keyed schema:
            Variable,Label,LongLabel,Source,Table,Line,Unit,...

            The current Lecture1.jl loader expects the old schema:
            Item,1929,1930,...

            Update the lecture loader first, or rerun with --allow-schema-change
            if you deliberately want to replace the root CSV.
            """)
        end

        backup = ROOT_OUTPUT * ".backup"
        if isfile(ROOT_OUTPUT)
            cp(ROOT_OUTPUT, backup; force=true)
            @printf("Backed up existing root CSV to %s\n", backup)
        end
        cp(args.output, ROOT_OUTPUT; force=true)
        @printf("Updated %s\n", ROOT_OUTPUT)
    else
        @printf("Root lecture CSV was not changed. Use --update-root to replace %s\n", ROOT_OUTPUT)
    end
end

main()
