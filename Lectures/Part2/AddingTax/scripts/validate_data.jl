using DelimitedFiles

const ROOT = normpath(joinpath(@__DIR__, ".."))
const PATH = joinpath(ROOT, "csv", "government_receipts_expenditures.csv")

function main()
    isfile(PATH) || error("Missing $(PATH). Run scripts/build_government_accounts.jl first.")
    raw, header = readdlm(PATH, ',', Any, '\n'; header = true)
    names = strip.(string.(vec(header)))
    names == ["Variable", "Label", "Line", "Indent", "Bold", "Unit", "Year", "Value"] ||
        error("Unexpected derived schema: $(names)")

    variables = Set(strip.(string.(raw[:, 1])))
    for variable in ("current_receipts", "current_expenditures", "net_government_saving")
        variable in variables || error("Missing required variable: $(variable)")
    end

    years = sort!(unique(Int.(raw[:, 7])))
    first(years) == 1929 || error("Expected the series to begin in 1929.")
    issorted(years) || error("Years are not sorted.")

    function value(variable, year)
        idx = findfirst(i -> string(raw[i, 1]) == variable && Int(raw[i, 7]) == year, axes(raw, 1))
        isnothing(idx) && error("Missing $(variable) for $(year)")
        Float64(raw[idx, 8])
    end

    for year in years
        receipts = value("current_receipts", year)
        expenditures = value("current_expenditures", year)
        saving = value("net_government_saving", year)
        isapprox(receipts - expenditures, saving; atol = 0.2) ||
            error("Table 3.1 identity fails in $(year): receipts - expenditures != net saving")
    end

    println("Validated Table 3.1 for $(first(years))-$(last(years)) ($(length(years)) annual observations).")
end

main()

