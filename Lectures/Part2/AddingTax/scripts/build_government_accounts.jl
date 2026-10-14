using DelimitedFiles

const ROOT = normpath(joinpath(@__DIR__, ".."))
const SOURCE = joinpath(ROOT, "source_csv", "bea_nipa", "table_3_1.csv")
const OUTPUT = joinpath(ROOT, "csv", "government_receipts_expenditures.csv")

const VARIABLES = Dict(
    "1" => "current_receipts",
    "2" => "current_tax_receipts",
    "3" => "personal_current_taxes",
    "4" => "taxes_on_production_and_imports",
    "5" => "taxes_on_corporate_income",
    "6" => "taxes_from_rest_of_world",
    "7" => "government_social_insurance_contributions",
    "8" => "social_insurance_contributions_from_persons",
    "9" => "social_insurance_contributions_from_rest_of_world",
    "10" => "income_receipts_on_assets",
    "11" => "interest_and_miscellaneous_receipts",
    "12" => "interest_receipts",
    "13" => "rents_and_royalties",
    "14" => "dividends",
    "15" => "current_transfer_receipts",
    "16" => "current_transfers_from_business_net",
    "17" => "current_transfers_from_persons",
    "18" => "current_transfers_from_rest_of_world",
    "19" => "current_surplus_government_enterprises",
    "20" => "current_expenditures",
    "21" => "consumption_expenditures",
    "22" => "current_transfer_payments",
    "23" => "government_social_benefits",
    "24" => "government_social_benefits_to_persons",
    "25" => "government_social_benefits_to_rest_of_world",
    "26" => "other_current_transfers_to_rest_of_world",
    "27" => "interest_payments",
    "28" => "interest_payments_to_persons_and_business",
    "29" => "interest_payments_to_rest_of_world",
    "30" => "subsidies",
    "31" => "net_government_saving",
    "32" => "social_insurance_funds_saving",
    "33" => "other_government_saving",
    "34" => "total_receipts",
    "35" => "addenda_current_receipts",
    "36" => "capital_transfer_receipts",
    "37" => "total_expenditures",
    "38" => "addenda_current_expenditures",
    "39" => "gross_government_investment",
    "40" => "capital_transfer_payments",
    "41" => "net_purchases_nonproduced_assets",
    "42" => "consumption_of_fixed_capital",
    "43" => "net_lending_or_borrowing",
)

function csv_escape(x)
    s = string(x)
    occursin(r"[,\"\n]", s) ? "\"" * replace(s, "\"" => "\"\"") * "\"" : s
end

function main()
    isfile(SOURCE) || error("Missing $(SOURCE). Run scripts/fetch_bea_source_tables.jl first.")
    raw, header = readdlm(SOURCE, ',', Any, '\n'; header = true)
    names = strip.(string.(vec(header)))
    required = ["Dataset", "Table", "Line", "Label", "Indent", "Bold", "Unit", "Year", "Value"]
    names == required || error("Unexpected source schema: $(names)")

    mkpath(dirname(OUTPUT))
    open(OUTPUT, "w") do io
        println(io, "Variable,Label,Line,Indent,Bold,Unit,Year,Value")
        for row in eachrow(raw)
            line = string(row[3])
            variable = get(VARIABLES, line, "")
            isempty(variable) && continue
            fields = (variable, row[4], line, row[5], row[6], row[7], row[8], row[9])
            println(io, join(csv_escape.(fields), ','))
        end
    end
    println("Wrote $(OUTPUT)")
end

main()

