using Downloads
using ZipFile

const ROOT = normpath(joinpath(@__DIR__, ".."))
const URL = "https://apps.bea.gov/industry/release/zip/SUPPLY-USE.zip"
const OUTPUT = joinpath(ROOT, "originals", "bea", "Use_SUT_Detail.xlsx")

mkpath(dirname(OUTPUT))
archive = Downloads.download(URL)
reader = ZipFile.Reader(archive)
try
    entry = only(filter(f -> f.name == "Use_SUT_Detail.xlsx", reader.files))
    open(OUTPUT, "w") do io
        write(io, read(entry))
    end
finally
    close(reader)
end
println("Wrote $(OUTPUT)")

