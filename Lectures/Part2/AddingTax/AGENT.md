# Codex Handoff Notes

## Collaboration Rule

The user controls the main Pluto notebook, `AddingTax.jl`. Do not edit it unless
the user explicitly requests a specific notebook patch. In particular, do not
replace its embedded Pluto environment or rearrange its cells while Pluto may
be open.

Codex may maintain the supporting data pipeline and visual staging files in
this directory.

## Standalone Lecture Contract

`Part2/AddingTax/` is a self-contained lecture bundle. Nothing required at
runtime may be loaded from `../../Part1/Baseline`, another lecture directory, or
a repository-level shared directory. Small amounts of duplicated fetching or
formatting code are acceptable when they keep the lecture independently
downloadable.

The committed CSV snapshot must let a student open the lecture without
network access or an API key. Network access is needed only to refresh source
data.

## Active Data Pipeline

The government-accounts material uses annual BEA NIPA Table 3.1, Government
Current Receipts and Expenditures (`NIPA`, `T30100`).

```text
BEA NIPA Table 3.1
    -> source_csv/bea_nipa/table_3_1.csv
    -> csv/government_receipts_expenditures.csv
    -> scripts/macro_data_theory_helpers.jl
    -> visualize.jl
    -> AddingTax.jl
```

File roles:

- `manifests/bea_tables.toml`: machine-readable table and line selection.
- `scripts/fetch_bea_source_tables.jl`: source acquisition only.
- `scripts/Project.toml`: reproducible dependencies for the refresh script.
- `source_csv/`: provenance-facing direct BEA observations.
- `scripts/build_government_accounts.jl`: lecture-facing transformation.
- `csv/`: stable inputs consumed by the visual helpers.
- `scripts/macro_data_theory_helpers.jl`: chapter-specific table and plot code.
- `visualize.jl`: terminal-side preview and validation staging.
- `tmp/`: disposable previews; never a notebook dependency.

## Conceptual Boundary

Keep source acquisition generic, but keep tax-chapter transformations and
visuals local. Later chapters may use the same BEA tables while making
different economic adjustments. Do not make this lecture depend on their
derived data or interpretation.
