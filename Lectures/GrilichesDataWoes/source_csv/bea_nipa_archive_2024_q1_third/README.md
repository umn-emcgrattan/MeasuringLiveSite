# BEA NIPA Archive, 2024 Q1 Third Estimate

This directory contains plain CSV extracts from the BEA National Accounts
archive vintage:

```text
National Accounts (NIPA)
2024 Q1, Third estimate
Release date: June 28, 2024
Archive ID: 13127
```

The source workbook is:

```text
originals/BEA-NIPA-archive-2024-Q1-third-Section6all.xlsx
```

It was downloaded from the BEA archive file:

```text
https://apps.bea.gov/HistData/Files/Releases/GDP_and_PI/2024/Q1/Third_June-28-2024/Section6all_xls.xlsx
```

This vintage is retained because it includes discontinued NIPA Section 6
industry tables that are no longer exposed cleanly in the current live tables.

The sheet extraction is controlled by:

```sh
python3 scripts/extract_xlsx_sheets.py --manifest manifests/bea_nipa_archive_table6_exports.csv
```

For Table 6.1, the archived workbook includes 6.1B, 6.1C, and 6.1D annual
sheets. It does not include a 6.1A annual sheet.

For Table 6.8, persons engaged in production by industry, the archived workbook
includes 6.8A, 6.8B, 6.8C, and 6.8D annual sheets.

The derived historical sector-distribution file is built by:

```sh
julia scripts/griliches_table6_sector_distribution.jl
```

and written to:

```text
csv/bea_nipa_table6d_sector_distribution_1948_2023.csv
```

That Julia script performs the classification mapping used in the lecture:
legacy electric/gas/sanitary services are mapped to utilities, legacy
communications are mapped to information, and legacy transportation is
computed by subtracting those two components from transportation and public
utilities. It also keeps a total services row for all years while leaving the
Table 6.1D service-detail rows missing before 1998.

The parallel persons-engaged file is built by:

```sh
julia scripts/griliches_table6_persons_engaged_distribution.jl
```

and written to:

```text
csv/bea_nipa_table68_persons_engaged_sector_distribution_1929_2022.csv
```
