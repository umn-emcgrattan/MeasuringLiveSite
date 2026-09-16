# Codex Handoff Notes

These notes describe the working pattern for `Lectures/MacroDataTheory`,
following the organization established in `Lectures/GrilichesDataWoes`.

## Collaboration Rule

The user controls the main Pluto notebook file, currently `MDT.jl`. Codex
should not edit the main notebook unless the user explicitly asks for a specific
patch.

Codex may maintain supporting files:

- `scripts/`: Julia source fetchers, transformations, plotting helpers, and
  HTML/table helpers.
- `source_csv/`: direct plain CSV extracts from public BEA source tables.
- `csv/`: derived lecture-ready data built from `source_csv/`.
- `originals/`: public source workbooks/PDFs, if any are used.
- `manifests/`: extraction recipes, if workbook sources are added.
- `docs/`: source notes, provenance, and mapping documentation.
- `visualize.jl`: terminal-side staging script for building and checking
  figures/tables before the user moves selected pieces into Pluto.
- `tmp/`: disposable local previews, such as rendered HTML tables.

When Pluto is open, avoid direct edits to `MDT.jl`. Pluto autosaves and can
conflict with filesystem edits. Give the user small cells or include snippets
to paste manually.

## Data Layout

Use this directory structure:

```text
originals/     public source files, unchanged
source_csv/    direct source-table extracts, one step from BEA/API/workbooks
csv/           lecture-ready derived data
scripts/       Julia transformations and plotting/helpers
manifests/     extraction recipes, if needed
docs/          source/provenance notes
old/           old local snapshots or deprecated lecture files
tmp/           disposable local previews
visualize.jl   terminal-side staging script for figures and tables
README.md      rebuild instructions and source interpretation
```

The intended pipeline is:

```text
public source -> source_csv/ -> csv/ -> visualize.jl -> Pluto notebook
```

For this lecture, the legacy `nipa.csv` files are not clean source data. They
are retained as replication checks while the new source-table pipeline is built.

## Current Legacy Files

Leave these files untouched unless the user asks:

```text
MDT.jl
nipa.csv
build_csvs/
```

`nipa.csv` and `build_csvs/nipa.csv` combine lines from NIPA and Fixed Assets
tables into one lecture convenience file. That is useful for checking old
results, but it is not the provenance layer students should inspect.

## Source Principle

Keep direct BEA tables separate in `source_csv/`. The Data Center can expose
selected direct tables, such as NIPA Table 1.1.5 and Table 1.10, while the
lecture can also use additional BEA and Fixed Assets tables needed to connect
theory and data.

Derived model-account objects belong in `csv/`, not in `source_csv/`.
