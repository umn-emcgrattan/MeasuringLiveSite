# USPTO Patent Applications Source Extract

This directory is for the public USPTO annual patent-application source CSV
used in the patents-per-R&D-dollar figure.

Required file:

```text
patent_applications_by_origin.csv
```

Required columns:

```csv
year,domestic_applications
```

Optional columns such as `total_applications`, `foreign_applications`, or
`source_note` may also be present. The Julia code uses `year` and then prefers
`domestic_applications` when populated, otherwise `utility_applications`.

The intended source is the USPTO historical annual patent activity table,
commonly cited as "U.S. Patent Activity, Calendar Years 1790 to the Present."
The current source extract was parsed from:

```text
originals/USPatentActivity1790toPresent-printed-2024-02-13.pdf
```

Refresh it with:

```sh
julia scripts/extract_uspto_patent_activity_pdf.jl
```

The PDF contains utility patent applications, but not domestic applications.
For now, the source CSV leaves `domestic_applications` blank and uses
`utility_applications` as the numerator. If a domestic-applications source is
found later, add those values to the `domestic_applications` column and the
Julia plotting code will prefer that column automatically.

The post-2020 extension is parsed from the official USPTO FY2024 workload
tables:

```text
originals/USPTOFY24WorkloadTables.xlsx
```

Refresh it with:

```sh
julia scripts/extract_uspto_workload_tables.jl
```

The workload-table extract is written to:

```text
workload_tables_fy_utility_applications.csv
```

Those observations are fiscal-year utility application counts. The plotting
code uses only the years after the PTMT calendar-year series ends and draws
them as a dashed extension.
