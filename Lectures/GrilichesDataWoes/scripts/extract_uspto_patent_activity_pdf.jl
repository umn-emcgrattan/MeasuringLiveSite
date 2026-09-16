# Extract annual utility patent applications from the USPTO/PTMT patent
# activity PDF into a stable source CSV.
#
# This uses the command-line `pdftotext` utility with layout preservation.

include(joinpath(@__DIR__, "griliches_historical_productivity.jl"))

function parse_utility_applications_from_pdf_text(text_path::AbstractString)
    rows = NamedTuple[]
    seen_years = Set{Int}()

    for line in eachline(text_path)
        m = match(r"^\s*(\d{4})\s+((?:\d{1,3},)*\d+|n/a)\b"i, line)
        isnothing(m) && continue

        year = parse(Int, m.captures[1])
        if year in seen_years
            continue
        end
        push!(seen_years, year)

        value_text = lowercase(m.captures[2])
        value_text == "n/a" && continue
        utility_applications = parse(Float64, replace(value_text, "," => ""))

        push!(
            rows,
            (
                year = year,
                utility_applications = utility_applications,
            ),
        )
    end

    sort(rows; by = r -> r.year)
end

function extract_uspto_patent_activity_pdf(
    pdf_path::AbstractString = joinpath(@__DIR__, "..", "originals", "USPatentActivity1790toPresent-printed-2024-02-13.pdf"),
    out_path::AbstractString = joinpath(@__DIR__, "..", "source_csv", "uspto_patent_applications", "patent_applications_by_origin.csv"),
)
    isfile(pdf_path) || error("Missing USPTO patent activity PDF: $(pdf_path)")
    text_path = tempname() * ".txt"
    try
        run(`pdftotext -layout $(pdf_path) $(text_path)`)
        rows = parse_utility_applications_from_pdf_text(text_path)
        isempty(rows) && error("No annual utility patent application rows found in $(pdf_path)")

        header = [
            "year",
            "utility_applications",
            "domestic_applications",
            "source_note",
        ]
        body = [
            [
                r.year,
                r.utility_applications,
                "",
                "USPTO/PTMT, U.S. Patent Activity, Calendar Years 1790 to the Present; PDF printed 2024-02-13.",
            ]
            for r in rows
        ]
        write_csv_rows(out_path, header, body)
        out_path
    finally
        isfile(text_path) && rm(text_path)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    println(extract_uspto_patent_activity_pdf())
end
