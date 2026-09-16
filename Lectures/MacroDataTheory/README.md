# Macro Data Theory Bundle

This directory contains source documentation, source-table extracts, and
lecture-ready derived files for the monograph chapter on comparing aggregate
data and theory.

## Current Direction

The Pluto notebook `MDT.jl` currently contains substantial Julia code for
loading NIPA data, formatting tables, plotting GDP/GDI, and constructing model
accounts. The goal is to move that machinery into supporting scripts while the
user keeps control of the lecture text and notebook edits.

The preferred structure is:

- `source_csv/`: direct plain CSV extracts from public BEA source tables.
- `csv/`: derived lecture-ready files built from `source_csv/`.
- `scripts/`: reproducible source fetchers, transformations, and helpers.
- `docs/`: source notes and provenance documentation.
- `tmp/`: disposable local previews.

The legacy root `nipa.csv` and `build_csvs/` directory are retained for
replication checks. They combine lines from multiple national-account sources
and should not be treated as clean source data.

## Intended Pipeline

```text
BEA source tables -> source_csv/ -> csv/ -> visualize.jl -> MDT.jl
```

The direct source extracts should keep table provenance visible. For example,
NIPA Table 1.1.5 and Table 1.10 can be shown directly in a Data Center, while
the lecture can also use additional BEA and Fixed Assets tables to build the
model-account adjustments.

## Planned Source Tables

The current lecture calculations use annual lines from:

```text
NIPA T10105   Table 1.1.5, Gross Domestic Product
NIPA T11000   Table 1.10, Gross Domestic Income by Type of Income
NIPA T30500   Table 3.5, Taxes on Production and Imports
NIPA T30905   Table 3.9.5, Government Consumption Expenditures and Gross Investment
FAAt101       Fixed Assets Table 1.1, Current-Cost Net Stock of Fixed Assets
FAAt804       Fixed Assets Table 8.4, Depreciation of Consumer Durable Goods
```

## Rebuild Pattern

The intended commands are:

```sh
julia scripts/fetch_bea_source_tables.jl
julia scripts/build_macro_accounts.jl
julia visualize.jl
```

`fetch_bea_source_tables.jl` requires BEA access through `BeaData.jl`, using
the local BEA configuration or `ENV["BEA_API_KEY"]`.

`visualize.jl` should write previews under `tmp/`.
