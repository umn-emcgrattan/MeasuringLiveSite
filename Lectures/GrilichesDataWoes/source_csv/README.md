# Source CSV Exports

This directory contains plain CSV exports from public source workbooks. These
files are intended to be stable, easy-to-inspect inputs for lecture and website
builds.

The extraction is controlled by:

```sh
python3 scripts/extract_xlsx_sheets.py --manifest manifests/xlsx_sheet_exports.csv
```

The manifest has one row per sheet:

```csv
workbook,sheet,out_csv
originals/example.xlsx,Sheet Name,source_csv/example/sheet_name.csv
```

The extractor reads cached cell values from `.xlsx` files. It intentionally
does not preserve formulas, formatting, charts, styles, or merged-cell
semantics. For archival purposes this is usually the useful behavior: the CSVs
record the numeric/text values that downstream code will use.

Additional source subdirectories may contain public CSV extracts that did not
start as `.xlsx` workbooks. For example, `bea_fixed_assets/` holds the BEA
Fixed Assets Table 2.7 and 2.8 extracts used to put private R&D investment in
1972 dollars, and `uspto_patent_applications/` holds the domestic patent
applications source extract.
