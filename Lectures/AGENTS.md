# Codex Handoff Notes

This repository contains lecture materials for the Econometric Society
Monograph project. Each lecture directory should keep the Pluto notebook as a
thin presentation layer and move reproducible data, computation, plotting, and
table-building work into supporting files.

## Core Collaboration Rule

The user controls the main Pluto notebook file in each lecture directory.
Codex should not edit a main notebook (`GDW.jl`, `MDT.jl`, `Lecture*.jl`,
or similar) unless the user explicitly asks for a specific patch.

Codex may maintain supporting files:

- `scripts/`: fetchers, extractors, transformations, solvers, simulations,
  plotting helpers, and table helpers.
- `src/`: shared model primitives, numerical routines, simulation engines, and
  reusable code for computation-heavy chapters.
- `source_csv/`: direct source-table extracts or other plain source data.
- `csv/`: derived lecture-ready data and computed outputs.
- `originals/`: public source workbooks/PDFs or other source files, unchanged.
- `manifests/`: machine-readable extraction recipes.
- `docs/`: source notes, method notes, provenance, and interpretation.
- `visualize.jl`: terminal-side staging script for building and checking
  figures/tables before the user moves selected pieces into Pluto.
- `tmp/`: disposable local previews, diagnostics, and scratch outputs.

When Pluto is open, avoid direct edits to the notebook file from Codex. Pluto
autosaves and can conflict with filesystem edits. Give the user small cells or
include snippets to paste manually.

## Common Chapter Skeleton

Most lecture directories should have:

```text
AGENT.md       local collaboration and pipeline notes
README.md      rebuild instructions and source/method interpretation
visualize.jl   terminal-side staging script
tmp/           disposable local previews and scratch outputs
scripts/       executable helpers and builders
csv/           derived lecture-ready data or computed outputs
docs/          notes and provenance
old/           old local snapshots or deprecated lecture files
```

Add type-specific directories as needed.

## Data Chapters

Examples: `GrilichesDataWoes`, `MacroDataTheory`.

Use:

```text
originals/     public source files, unchanged
source_csv/    direct source extracts, one step from originals/APIs
manifests/     extraction recipes for workbook/PDF/API sources
csv/           lecture-ready derived data
scripts/       fetch/extract/build/table/plot helpers
```

The intended pipeline is:

```text
public source -> originals/ or API -> source_csv/ -> csv/ -> visualize.jl -> Pluto
```

Keep `source_csv/` provenance-facing and `csv/` lecture-facing. Direct BEA,
BLS, USPTO, or other public source tables belong in `source_csv/`. Joined,
classified, spliced, or model-ready files belong in `csv/`.

Python should be used only for generic source extraction when Julia lacks a
simple local tool, such as converting cached XLSX sheet values to CSV. Julia
should do analytical transformations, classifications, splicing, derived
variables, plotting, and HTML/table rendering.

## Computation-Method Chapters

Example: a chapter showing several ways to compute the growth model introduced
in `MacroDataTheory`.

Use:

```text
src/            model primitives, calibration, shared numerical routines
scripts/        run scripts for each computation method
csv/            computed outputs for lecture tables and figures
figures/        durable generated figures if they are lecture inputs
tmp/            disposable diagnostics and previews
docs/           numerical notes, method comparisons, parameter notes
```

Prefer explicit method names in files:

```text
src/growth_model.jl
src/calibration.jl
src/reporting.jl
scripts/solve_value_function.jl
scripts/solve_linear_quadratic.jl
scripts/solve_shooting.jl
```

Keep reusable model objects in `src/`. Keep executable workflows in `scripts/`.
Keep temporary diagnostics in `tmp/`.

## Interactive Simulation Chapters

Use:

```text
src/            model and simulation engine
scripts/        batch runs and validation checks
csv/            benchmark paths or canned examples
assets/         stable visual/media assets, if needed
tmp/            disposable simulation outputs
docs/           scenario definitions and interpretation notes
```

Interactive Pluto controls should call small, stable helper functions. The
simulation logic itself should live outside the notebook.

## File Naming

Use names that reveal the role:

```text
fetch_*.jl      downloads or extracts public/source data
extract_*.jl    converts source files into plain source data
build_*.jl      creates derived CSVs or lecture-ready outputs
solve_*.jl      computes model solutions
simulate_*.jl   creates model/data simulations
*_helpers.jl    Pluto/visualize rendering helpers
visualize.jl    staging script run by hand from the terminal
```

## Local AGENT.md Files

Each lecture directory may have its own `AGENT.md`. The local file should name
the main notebook that Codex must not edit, describe the active pipeline, and
record chapter-specific conceptual choices.

If root `AGENTS.md` and a local `AGENT.md` conflict, follow the local
`AGENT.md` for files inside that lecture directory.
