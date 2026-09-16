# Building `nipa.csv`

The lecture already includes `../nipa.csv`. You do not need to rebuild it to run
`Lecture1.jl`.

This directory contains a reproducible builder for the NIPA CSV used by Lecture 1.
It pulls annual data from BEA NIPA Table 1.1.5 and Table 1.10, plus selected
addenda from other BEA tables.

The generated CSV now uses unique variable names:

```text
Variable,Label,LongLabel,Source,Table,Line,Unit,1929,1930,...
```

`Variable` is the stable lookup key for Julia code. `Label` is what can be shown
in the lecture.

## Build A New CSV

From this directory:

```bash
julia build_nipa_csv.jl
```

By default this writes:

```text
build_csvs/nipa.csv
```

The root lecture file `../nipa.csv` is not changed.

## Add A Later Year

For example, to build through 2027:

```bash
julia build_nipa_csv.jl --end-year 2027
```

If BEA has not yet published an annual observation for one of the addenda, the
script writes `.....` for that missing value and prints a note.

## Check Old And New

To compare the generated file with the existing lecture CSV:

```bash
julia build_nipa_csv.jl --check-root
```

This compares `build_csvs/nipa.csv` with `../nipa.csv` on shared years. If you
are adding a new year, the new year will be reported as an additional column.

Because the generated CSV has the new keyed schema, do not replace the lecture
CSV until the lecture loader has been updated to use `Variable` keys.

## Replace The Lecture CSV

The current `Lecture1.jl` loader expects the old CSV format:

```text
Item,1929,1930,...
```

Do not replace `../nipa.csv` until the lecture loader is updated for the new
keyed format. Once that loader is updated, replacement can be forced with:

```bash
julia build_nipa_csv.jl --end-year 2027 --update-root --allow-schema-change
```

This backs up the existing root file as:

```text
../nipa.csv.backup
```

and then replaces `../nipa.csv`.

## BEA API Key

If your machine does not already have BEA access configured, register for a free
BEA API key and set it before running the script:

```bash
export BEA_API_KEY="your-key-here"
```

On Windows PowerShell:

```powershell
$env:BEA_API_KEY="your-key-here"
```

## Units

BEA returns these tables in billions of dollars. The generated `nipa.csv` stores
values in millions of dollars, matching the existing Lecture 1 convention.
