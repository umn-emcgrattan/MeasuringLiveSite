root = normpath(joinpath(@__DIR__, ".."))
project = joinpath(root, "scripts")
run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "fetch_bea_source_tables.jl"))`)
run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "build_software_io_remapping.jl"))`)
run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "fetch_bea_benchmark_use.jl"))`)
run(`python3 $(joinpath(root, "scripts", "extract_bea_benchmark_xlsx.py")) $(joinpath(root, "originals", "bea", "Use_SUT_Detail.xlsx")) $(joinpath(root, "source_csv", "bea_io_benchmark"))`)
run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "build_ipp_io_matrix.jl"))`)
run(`$(Base.julia_cmd()) --project=$(project) $(joinpath(root, "scripts", "build_ipp_capitalization.jl"))`)

