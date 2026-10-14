root = normpath(joinpath(@__DIR__, ".."))
project = joinpath(root, "scripts")

run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "fetch_bea_source_tables.jl")) $(ARGS)`)
run(`$(Base.julia_cmd()) $(joinpath(root, "scripts", "build_government_accounts.jl"))`)
run(`$(Base.julia_cmd()) $(joinpath(root, "scripts", "validate_data.jl"))`)
