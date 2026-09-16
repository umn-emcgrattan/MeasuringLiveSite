# Codex Handoff Notes

These notes describe the working pattern established in
`Lectures/GrilichesDataWoes`. Use this as the model for organizing the next
lecture directory.

## Collaboration Rule

The user controls the main Pluto notebook file (`GDW.jl`). Codex should not 
edit the main notebook unless the user explicitly asks for a specific patch.

Codex controls supporting files:

- `scripts/`: Julia transformations, plotting helpers, HTML/table helpers, and
  narrowly scoped source-extraction utilities.
- `csv/`: derived lecture-ready data.
- `source_csv/`: plain ASCII extracts copied from source workbooks or APIs.
- `originals/`: public source workbooks/PDFs, kept unchanged for provenance.
- `manifests/`: CSV manifests telling the XLSX extractor which sheets to export.
- `visualize.jl`: terminal-side staging script for building and checking
  figures/tables before the user moves selected pieces into Pluto.
- `tmp/`: disposable local previews, such as rendered HTML tables.
- `README.md`: source notes, rebuild commands, and conceptual caveats.

When Pluto is open, avoid direct edits to the notebook file from Codex. Pluto
autosaves and can conflict with filesystem edits. Give the user small cells or
include snippets to paste manually.

The user likes to build figures and tables outside Pluto first, using `vi` and
terminal-run Julia code. Codex may help maintain `visualize.jl` and supporting
helpers for this staging workflow. The main Pluto lecture remains user-edited.
`visualize.jl` should write temporary previews under `tmp/` so they can be
cleared without touching source data, derived CSVs, or the lecture notebook.

## Data Layout

Use this directory structure for each lecture:

```text
originals/     public source files, unchanged
source_csv/    ASCII sheet/API extracts, one step from originals
csv/           lecture-ready derived data
scripts/       Julia transformations and plotting/helpers
manifests/     XLSX sheet-extraction recipes
docs/          optional source/provenance notes
old/           old local snapshots or deprecated lecture files
tmp/           disposable local previews
visualize.jl   terminal-side staging script for figures and tables
README.md      rebuild instructions and source interpretation
```

The intended pipeline is:

```text
public source -> originals/ -> source_csv/ -> csv/ -> Pluto notebook
```

Python should be used only for generic source extraction from XLSX to CSV.
Julia should do all analytical transformations, classifications, splicing,
derived variables, plotting, and HTML/table rendering.

## XLSX Extraction

The generic extractor in this lecture is:

```sh
python3 scripts/extract_xlsx_sheets.py
```

It reads a manifest with:

```csv
workbook,sheet,out_csv
originals/example.xlsx,Sheet Name,source_csv/example/sheet_name.csv
```

It writes cached cell values from selected workbook sheets. It intentionally
does not preserve formatting, formulas, charts, styles, or merged-cell
semantics. The goal is stable ASCII input that can live longer than the
workbook format.

Useful command:

```sh
python3 scripts/extract_xlsx_sheets.py --list-sheets originals/some_file.xlsx
```

For a new lecture, copy or recreate this extractor and keep the manifests
lecture-specific.

## Pluto Pattern

Load helper files once near the top of the notebook:

```julia
begin
    include("scripts/some_helper.jl")
    include("scripts/some_table_compare.jl")
end
```

For Pluto `@bind` controls, keep controls and output in separate cells. A
selector variable bound in a cell does not reliably force recomputation of
output inside the same cell.

Controls cell:

```julia
begin
    tab1a = @bind left_year Select(example_years(); default=first(example_years()))
    tab1b = @bind right_year Select(example_years(); default=last(example_years()))
    @htl("""
    <div>
        <div>First year: $(tab1a)</div>
        <div>Second year: $(tab1b)</div>
    </div>
    """)
end
```

Output cell:

```julia
begin
    example_compare_html(left_year, right_year; show_title=false)
end
```

If included helper files change and Pluto reports duplicate/imported variable
errors, restart the Pluto Julia process and run the notebook again.

## GrilichesDataWoes Current State

This lecture was reorganized around public data. Digitized AER figure data are
not publication-facing sources.

Active source organization:

- `originals/`: BEA-BLS/KLEMS workbooks, BEA fixed-assets sources, USPTO PDF
  and workload workbook, BEA NIPA archive workbook.
- `source_csv/`: extracted sheet CSVs and API outputs.
- `csv/`: derived lecture-ready data.
- `scripts/`: Julia builders and Pluto helpers; one generic Python XLSX
  extractor.

Important active derived files:

```text
csv/bea_bls_griliches_groups_productivity_1947_1990.csv
csv/bea_bls_griliches_groups_productivity_spliced_1947_2024.csv
csv/bea_bls_tfp_growth_rd_intensity.csv
csv/uspto_patent_applications_per_bea_rd_1972_dollars.csv
csv/bea_bls_klems_sector_distribution_1963_2024.csv
csv/bea_fixed_assets_ipp_investment_distribution.csv
csv/bea_nipa_table6d_sector_distribution_1948_2023.csv
csv/bea_nipa_table68_persons_engaged_sector_distribution_1929_2022.csv
```

Important helper files:

```text
scripts/griliches_historical_productivity.jl
scripts/griliches_klems_sector_distribution.jl
scripts/griliches_klems_sector_compare.jl
scripts/griliches_fixed_assets_ipp_distribution.jl
scripts/griliches_fixed_assets_ipp_compare.jl
scripts/griliches_table6_sector_distribution.jl
scripts/griliches_table6_persons_engaged_distribution.jl
scripts/griliches_table6_sector_compare.jl
scripts/extract_xlsx_sheets.py
visualize.jl
```

## Conceptual Choices Made Here

For Griliches-style measurable/unmeasurable sector summaries, `Information` is
classified with other/unmeasurable sectors. Modern `Information` includes
publishing/software, motion picture/sound, broadcasting/telecom, and
data/internet/other information services; it is broader than old
communications.

The main value-added/hours table uses BEA-BLS/KLEMS production-account sources:

```text
Value added:
1963-1996  historical KLEMS 1963-2016 sheet, VA = go. - ii.
1997-2024  current BEA-BLS ILPA Value Added sheet

Hours:
1963-1986  historical KLEMS 1963-2016 sheet, hrs
1987-2024  BLS detailed industries hours/employment workbook, hours worked
```

The BEA NIPA Table 6 files are retained as reference aggregate data, not as the
main Griliches replacement. They are useful checks for broad aggregates such as
manufacturing.

The IPP table uses BEA Fixed Assets:

```text
FAAt307I    Table 3.7I, private IPP investment by industry
FAAt307ESI  Table 3.7ESI, private fixed investment by industry
FAAt105     Table 1.5, government fixed investment and IPP
```

## Next Lecture Setup

For the next lecture directory, start by copying the organization, not
necessarily all data:

```text
manifests/
scripts/extract_xlsx_sheets.py
source_csv/
csv/
originals/
tmp/
visualize.jl
README.md
AGENT.md
```

Move or rename the notebook only when the user is ready and has identified the
active Pluto file. Keep notebook edits user-controlled. Codex should build
standalone Julia helpers, maintain `visualize.jl` for terminal-side previews,
and provide include/cell snippets for Pluto.

When cleaning old files, preserve public originals and derived CSVs until the
new pipeline can regenerate them. Remove old one-off Python builders only after
their Julia replacements and source-extraction manifests are in place.
