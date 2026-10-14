# Macro Data Theory with Taxes

This directory is a self-contained Pluto lecture bundle. `AddingTax.jl` is the
main lecture notebook; its supporting data and visual code live beside it so a
student can download this directory without downloading the other lectures.

## Included snapshot

The committed files under `source_csv/` and `csv/` let the notebook run
offline. They contain annual observations from BEA NIPA Table 3.1, Government
Current Receipts and Expenditures.

Source: U.S. Bureau of Economic Analysis, National Income and Product Accounts,
Table 3.1 (`NIPA`, `T30100`), billions of dollars.

## Refreshing the data

The preferred documented route uses a free BEA API key. Keep the key outside
the repository. `BeaData.jl` can also use its user-level configuration, which
likewise remains outside the downloaded lecture:

```sh
export BEA_API_KEY="your-key-here"
julia --project=scripts -e 'using Pkg; Pkg.instantiate()' # first refresh only
julia --project=scripts scripts/fetch_bea_source_tables.jl
julia scripts/build_government_accounts.jl
julia scripts/validate_data.jl
```

On PowerShell:

```powershell
$env:BEA_API_KEY="your-key-here"
```

Never put an actual key in `AddingTax.jl`, a script, a manifest, or a committed
`.env` file.

## Previewing the visuals

Run:

```sh
julia visualize.jl
```

This stages the Table 3.1 HTML preview under `tmp/` and constructs the
receipts-versus-expenditures figure. It uses the same packages declared by the
Pluto notebook and does not modify `AddingTax.jl`.

## Data layout

```text
BEA -> source_csv/bea_nipa/table_3_1.csv
    -> csv/government_receipts_expenditures.csv
    -> visualize.jl / AddingTax.jl
```

`source_csv/` preserves BEA line numbers, labels, units, years, and values.
`csv/` adds stable variable names used by the lecture helpers.
