# Griliches Data Constraint Bundle

This directory collects source documentation, public-data extracts, and
lecture-ready CSV files for the monograph chapter that starts from Griliches'
1994 AEA/AER address, "Productivity, R&D, and the Data Constraint."

## Current Direction

The lecture and website build should move away from digitized AER figure data
and toward public BEA/BLS source data. The digitized Griliches figure files are
still useful as historical/provenance material, but they should not be the
publication-facing data source.

The preferred structure is:

- `originals/`: public source PDFs and workbooks, retained for provenance.
- `source_csv/`: plain CSV exports from public source workbooks.
- `csv/`: derived lecture-ready CSVs used by Pluto notebooks and figures.
- `manifests/`: machine-readable instructions for extracting source sheets.
- `scripts/`: reproducible conversion and extraction scripts.
- `docs/`: source notes and provenance documentation.

## XLSX Sheet Extraction

The new intermediate tool is:

```sh
python3 scripts/extract_xlsx_sheets.py
```

It reads:

```text
manifests/xlsx_sheet_exports.csv
```

The manifest format is:

```csv
workbook,sheet,out_csv
originals/example.xlsx,Sheet Name,source_csv/example/sheet_name.csv
```

The extractor writes cached cell values from selected `.xlsx` sheets to CSV.
It does not preserve formulas, formatting, charts, styles, or merged-cell
semantics. That is intentional: `source_csv/` is meant to be stable ASCII input
for later Julia/lecture code.

Useful helper:

```sh
python3 scripts/extract_xlsx_sheets.py --list-sheets originals/some_file.xlsx
```

## Historical BEA-BLS 1947-2016

The historical public BEA/BLS source is:

- BEA page: https://www.bea.gov/data/special-topics/integrated-industry-level-production-account-klems
- Article/document: "Toward a BEA-BLS Integrated Industry-Level Production Account for 1947-2016"
- Underlying data XLSX: `KLEMS-Research-Tables-Underlying-Data_0.xlsx`
- Summary tables XLSX: `KLEMS-Research-Tables-BEA-BLS-Integrated-Industry-Level-Production-Account-1947-2016_0.xlsx`

The local file currently present is:

```text
originals/KLEMS-Research-Tables-Underlying-Data-1947-2016.xlsx
```

It is the historical underlying-data workbook, renamed locally for clarity.
The current extraction manifest exports:

```text
source_csv/historical_1947_2016/underlying_data/notes.csv
source_csv/historical_1947_2016/underlying_data/1947_1963.csv
source_csv/historical_1947_2016/underlying_data/1963_2016.csv
```

The summary/tables XLSX should also be added under `originals/` and exported
once the desired sheet names are selected.

## Current BEA-BLS ILPA/KLEMS

The current BEA-BLS integrated industry-level production account page is:

https://www.bea.gov/data/special-topics/integrated-industry-level-production-account-klems

The current local workbook is:

```text
originals/BEA-BLS-industry-level-production-account-1997-2024.xlsx
```

The existing figure-building scripts use only these sheets from that workbook:

- `Value Added`
- `VA_Quantity`
- `Labor Hours_Quantity`
- `Integrated TFP Index`
- `Capital_R&D Compensation`
- `Gross Output`

Those sheets are now exported to:

```text
source_csv/current_bea_bls_ilpa/
```

The BEA/BLS website appears to publish the current production-account data as
XLSX files, so the update path will still need an XLSX ingestion step. The
downstream lecture code can use `source_csv/` instead.

## BEA-BLS/KLEMS Sector Distribution

The main Griliches-style sector distribution table now uses the
BEA-BLS/KLEMS production-account family rather than BEA NIPA Table 6. This
keeps value added and hours closer to the production-account concepts used in
the productivity figures.

The retained sources are:

```text
originals/KLEMS-Research-Tables-Underlying-Data-1947-2016.xlsx
originals/BEA-BLS-industry-level-production-account-1997-2024.xlsx
originals/hours-employment-detailed-industries.xlsx
```

The BLS hours/employment workbook is extracted with:

```sh
python3 scripts/extract_xlsx_sheets.py --manifest manifests/bls_productivity_exports.csv
```

The Julia transformation is:

```sh
julia scripts/griliches_klems_sector_distribution.jl
```

It writes:

```text
csv/bea_bls_klems_sector_distribution_1963_2024.csv
```

The value-added series uses the historical KLEMS `1963-2016` sheet through
1996, where nominal value added is `go. - ii.`, and the current BEA-BLS ILPA
`Value Added` sheet from 1997 onward. The hours series uses historical KLEMS
`hrs` through 1986 and the BLS detailed industries hours/employment workbook
from 1987 onward.

The broad sector list follows the Table-6D-style categories used elsewhere in
this directory, but `Information` is classified with other/unmeasurable sectors.
Modern `Information` includes publishing/software, motion picture/sound,
broadcasting/telecom, and data/internet/other information services, so it is
broader than the communications sector Griliches discussed.

For Pluto/GDW, load:

```julia
include("scripts/griliches_klems_sector_compare.jl")
```

and use:

```julia
griliches_klems_va_compare_html(klems_left_year, klems_right_year)
griliches_klems_hours_compare_html(klems_left_year, klems_right_year)
```

## Patent Applications per R&D Dollar

The planned replacement for the digitized Griliches Figure 4 data uses public
source extracts:

```text
source_csv/bea_fixed_assets/fa_table_2_7.csv
source_csv/bea_fixed_assets/fa_table_2_8.csv
source_csv/uspto_patent_applications/patent_applications_by_origin.csv
```

The BEA files should be Fixed Assets Table 2.7 and Table 2.8. The Julia code
uses line 82, research and development, and converts private R&D investment to
millions of 1972 dollars with the Table 2.8 quantity index. The USPTO file
should contain annual domestic patent applications.

The BEA source files can be refreshed with:

```sh
julia scripts/fetch_bea_fixed_assets.jl
```

The USPTO source file was parsed from:

```text
originals/USPatentActivity1790toPresent-printed-2024-02-13.pdf
```

and can be refreshed with:

```sh
julia scripts/extract_uspto_patent_activity_pdf.jl
```

The dashed post-2020 extension uses the official USPTO FY2024 workload tables:

```text
originals/USPTOFY24WorkloadTables.xlsx
source_csv/uspto_patent_applications/workload_tables_fy_utility_applications.csv
```

and can be refreshed with:

```sh
julia scripts/extract_uspto_workload_tables.jl
```

The Julia call will be:

```julia
plot_griliches_patents_per_real_rd()
```

The BEA API requires an active key. `BeaData.jl` reads it from
`ENV["BEA_USERID"]` or `~/.beadatarc`. The current USPTO extract has utility
applications, not domestic applications. If domestic applications are added
later, the Julia plotting code will use them automatically. The 2021-2024
extension uses fiscal-year workload data and is drawn as a dashed segment.

## BEA NIPA Table 6 Sector Distribution

The archived BEA NIPA Table 6.1 and 6.8 files are retained as reference
aggregate series, useful for checking broad aggregates such as manufacturing.
They are not the main production-account sector-share table. The retained
source workbook is:

```text
originals/BEA-NIPA-archive-2024-Q1-third-Section6all.xlsx
```

It comes from the BEA National Accounts archive for the 2024 Q1 Third estimate,
released June 28, 2024:

```text
https://apps.bea.gov/HistData/Files/Releases/GDP_and_PI/2024/Q1/Third_June-28-2024/Section6all_xls.xlsx
```

The archived workbook contains annual Table 6.1B, 6.1C, and 6.1D sheets. It
does not contain an annual Table 6.1A sheet. The sheet extraction is controlled
by:

```sh
python3 scripts/extract_xlsx_sheets.py --manifest manifests/bea_nipa_archive_table6_exports.csv
```

The student-facing Julia transformation is:

```sh
julia scripts/griliches_table6_sector_distribution.jl
```

It writes:

```text
csv/bea_nipa_table6d_sector_distribution_1948_2023.csv
```

The CSV maps the old SIC tables into a Table-6.1D-style sector list. Before
1998, legacy electric/gas/sanitary services are mapped to `Utilities`, legacy
communications are mapped to `Information`, and legacy transportation is
computed as transportation/public utilities less communications and
electric/gas/sanitary services. The `Services` total is retained for the whole
period; the four Table 6.1D service-detail rows are intentionally `missing`
before 1998.

The same archive also contains persons engaged in production by industry,
Table 6.8A/B/C/D. These sheets are exported by the same manifest and the Julia
mapping is:

```sh
julia scripts/griliches_table6_persons_engaged_distribution.jl
```

It writes:

```text
csv/bea_nipa_table68_persons_engaged_sector_distribution_1929_2022.csv
```

For a two-year comparison table, include:

```julia
begin
    include("scripts/griliches_table6_sector_compare.jl")
    left = @bind table6_left_year Select(table6_sector_years(); default=1948)
    right = @bind table6_right_year Select(table6_sector_years(); default=last(table6_sector_years()))
    griliches_table6_sector_compare_html(table6_left_year, table6_right_year; left_selector=left, right_selector=right)
end
```

For the persons-engaged version, use:

```julia
begin
    include("scripts/griliches_table6_sector_compare.jl")
    left = @bind table68_left_year Select(table68_persons_engaged_years(); default=1929)
    right = @bind table68_right_year Select(table68_persons_engaged_years(); default=last(table68_persons_engaged_years()))
    griliches_table68_persons_engaged_compare_html(table68_left_year, table68_right_year; left_selector=left, right_selector=right)
end
```

## BEA Fixed Assets IPP Investment

The Griliches Table 3 analogue uses intellectual property products investment
instead of computer investment. The source tables are BEA Fixed Assets:

```text
FAAt307I    Table 3.7I, private IPP investment by industry
FAAt307ESI  Table 3.7ESI, private fixed investment by industry
FAAt105     Table 1.5, government fixed investment and IPP
```

They are refreshed with:

```sh
julia scripts/fetch_bea_fixed_assets.jl
```

The Julia build is:

```sh
julia scripts/griliches_fixed_assets_ipp_distribution.jl
```

It writes:

```text
csv/bea_fixed_assets_ipp_investment_distribution.csv
```

`Information` is classified with other/unmeasurable sectors in the summary rows
because the modern BEA information sector is broader than communications.

The total IPP numerator is private Table 3.7I plus government Table 1.5 IPP.
The total fixed-investment denominator is private Table 3.7ESI plus government
nonresidential fixed investment from Table 1.5. Table 1.5 line 17 is not used
as the denominator because it is not additive with the Table 3.7ESI private
industry-owner total.

For a two-year comparison table, include:

```julia
begin
    include("scripts/griliches_fixed_assets_ipp_compare.jl")
    left = @bind ipp_left_year Select(ipp_investment_years(); default=1947)
    right = @bind ipp_right_year Select(ipp_investment_years(); default=last(ipp_investment_years()))
    griliches_ipp_investment_compare_html(ipp_left_year, ipp_right_year; left_selector=left, right_selector=right)
end
```

## Removed Legacy Material

Digitized `aer94_*` figure files, `sic_2_3_digit_labels.csv`, older BLS
workbook extracts, and the old Python builders have been removed from the
active lecture bundle. They were superseded by the public BEA, BEA-BLS, BEA
Fixed Assets, BEA NIPA archive, and USPTO workflows documented above.

Python should now be used only for source workbook sheet extraction:

```sh
python3 scripts/extract_xlsx_sheets.py --manifest manifests/xlsx_sheet_exports.csv
python3 scripts/extract_xlsx_sheets.py --manifest manifests/bea_nipa_archive_table6_exports.csv
python3 scripts/extract_xlsx_sheets.py --manifest manifests/bls_productivity_exports.csv
```

All derived lecture data should be generated by Julia scripts.
