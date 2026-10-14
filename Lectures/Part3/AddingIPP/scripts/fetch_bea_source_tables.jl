using BeaData
using CSV
using DataFrames
using Dates
using JSON

const ROOT = normpath(joinpath(@__DIR__, ".."))

function api_key()
    for name in ("BEA_API_KEY", "BEA_USERID")
        value = get(ENV, name, "")
        isempty(value) || return value
    end
    path = joinpath(homedir(), ".beadatarc")
    isfile(path) && return strip(read(path, String))
    error("Set BEA_API_KEY or BEA_USERID, or create ~/.beadatarc, to refresh BEA data.")
end

function fetch_io_use()
    query = Dict(
        "UserID" => api_key(), "method" => "GetData",
        "datasetname" => "InputOutput", "TableID" => "258",
        "Year" => "ALL", "ResultFormat" => "JSON",
    )
    # Use BeaData's HTTP dependency because its InputOutput parser does not
    # currently handle the vector-shaped Results response.
    url = getfield(BeaData, :API_URL) * "?" * join(
        [string(k, "=", BeaData.HTTP.escapeuri(v)) for (k, v) in query], "&")
    response = BeaData.HTTP.request("GET", url)
    response.status == 200 || error("BEA InputOutput request failed: HTTP $(response.status)")
    parsed = JSON.parse(String(response.body))
    observations = parsed["BEAAPI"]["Results"][1]["Data"]
    rows = DataFrame(
        Dataset = String[], Table = String[], Year = Int[],
        RowCode = String[], RowDescription = String[],
        ColumnCode = String[], ColumnDescription = String[],
        Unit = String[], Value = Union{Missing,Float64}[],
    )
    wanted = Set([("T005", "T001"), ("VABAS", "T001"), ("T018", "T001")])
    for x in observations
        pair = (string(x["RowCode"]), string(x["ColCode"]))
        pair in wanted || continue
        text = replace(string(x["DataValue"]), "," => "")
        value = isempty(strip(text)) || text == "---" ? missing : parse(Float64, text)
        push!(rows, ("InputOutput", "258", parse(Int, x["Year"]), pair[1],
                     string(x["RowDescr"]), pair[2], string(x["ColDescr"]),
                     "Millions of dollars", value))
    end
    path = joinpath(ROOT, "source_csv", "bea_io", "use_15_sector.csv")
    mkpath(dirname(path)); CSV.write(path, rows); println("Wrote $(path)")
end

function fetch_software()
    key = api_key()
    table = bea_table("NIPA", "T50605", "A", 1997, 2025; user_id = key)
    by_year = Dict(year(row.TimePeriod) => row for row in eachrow(table.data_values))
    specs = [("1", "Private fixed investment in intellectual property products"),
             ("2", "Software"), ("3", "Prepackaged software"),
             ("4", "Custom software"), ("5", "Own-account software"),
             ("6", "Research and development"),
             ("26", "Entertainment, literary, and artistic originals")]
    rows = DataFrame(Dataset=String[], Table=String[], Line=String[], Label=String[],
                     Unit=String[], Year=Int[], Value=Union{Missing,Float64}[])
    for (line, label) in specs, yr in 1997:2025
        col = Symbol("Line" * lpad(line, 2, '0'))
        value = haskey(by_year, yr) ? by_year[yr][col] : missing
        push!(rows, ("NIPA", "T50605", line, label, "Billions of dollars", yr,
                     ismissing(value) ? missing : Float64(value)))
    end
    path = joinpath(ROOT, "source_csv", "bea_nipa", "table_5_6_5_software.csv")
    mkpath(dirname(path)); CSV.write(path, rows); println("Wrote $(path)")
end

function fetch_government_ipp()
    key = api_key()
    table = bea_table("NIPA", "T50905", "A", 1997, 2025; user_id = key)
    by_year = Dict(year(row.TimePeriod) => row for row in eachrow(table.data_values))
    specs = [("57", "Government intellectual property products"),
             ("60", "Federal defense software"), ("61", "Federal defense R&D"),
             ("63", "Federal nondefense software"), ("64", "Federal nondefense R&D"),
             ("66", "State and local software"), ("67", "State and local R&D")]
    rows = DataFrame(Dataset=String[], Table=String[], Line=String[], Label=String[],
                     Unit=String[], Year=Int[], Value=Union{Missing,Float64}[])
    for (line, label) in specs, yr in 1997:2025
        col = Symbol("Line" * line)
        value = haskey(by_year, yr) ? by_year[yr][col] : missing
        push!(rows, ("NIPA", "T50905", line, label, "Billions of dollars", yr,
                     ismissing(value) ? missing : Float64(value)))
    end
    path = joinpath(ROOT, "source_csv", "bea_nipa", "table_5_9_5_government_ipp.csv")
    mkpath(dirname(path)); CSV.write(path, rows); println("Wrote $(path)")
end

fetch_io_use()
fetch_software()
fetch_government_ipp()
