# Codex Handoff Notes

## Collaboration Rule

The user controls the Pluto notebook `AddingIPP.jl`. Do not edit the notebook
unless the user explicitly requests a specific patch. Keep
data acquisition, transformations, and HTML rendering in supporting files.

## Standalone Lecture Contract

`Part3/AddIPP/` must run as a self-contained lecture bundle. A
student who downloads this directory should be able to open the notebook and
use the committed CSV files without an API key or network access. An API key
and network access are required only to refresh the source snapshots.

## Active Data Pipeline

The first input-output remapping visual uses:

- BEA Input-Output Table 258, the 15-sector use table, for economy-wide
  intermediate inputs, value added at basic prices, and gross output.
- BEA NIPA Table 5.6.5, lines 3--5, for prepackaged, custom, and own-account
  software investment.
- BEA detailed benchmark Use Tables (Supply-Use Framework) for the 2007,
  2012, and 2017 IPP/non-IPP matrix. The official detailed archive does not
  yet contain a compatible 2022 sheet.

```text
BEA API
    -> source_csv/bea_io/use_15_sector.csv
    -> source_csv/bea_nipa/table_5_6_5_software.csv
    -> csv/software_io_remapping.csv
    -> scripts/ipp_io_helpers.jl
    -> visualize.jl
    -> Pluto notebook
```

The committed derived file is long by year so a Pluto `Select` control can
redraw the table. The initial visual isolates software because BEA reports its
purchased and own-account components separately. Do not silently describe
the software amounts as all IPP. Extend R&D and artistic originals only when
their purchased/own-account split has a documented, comparable source.

The benchmark matrix classifies codes 511200, 512100, 512200, 541700, and
711500 as IPP-producing industries/related commodities. Its IPP final-demand
columns are the four published private, federal-defense, federal-nondefense,
and state-and-local IPP investment columns. Preserve the distinction between
an IPP-producing industry and a pure IPP asset: the industry rows also include
related current production.

