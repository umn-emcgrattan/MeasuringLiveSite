# BEA Fixed Assets Source Extracts

This directory is for public BEA Fixed Assets source CSVs used to build the
patents-per-R&D-dollar figure.

Required files:

```text
fa_table_2_7.csv
fa_table_2_8.csv
fa_table_1_5.csv
fa_table_3_7esi.csv
fa_table_3_7i.csv
```

`fa_table_2_7.csv` should contain BEA Fixed Assets Table 2.7, "Investment in
Private Fixed Assets, Equipment, Structures, and Intellectual Property Products
by Type." The BEA API reports this table in billions of dollars. The Julia code
uses line 82, research and development, and converts it to millions of dollars.

`fa_table_2_8.csv` should contain BEA Fixed Assets Table 2.8, "Chain-Type
Quantity Indexes for Investment in Private Fixed Assets, Equipment, Structures,
and Intellectual Property Products by Type." The Julia code uses line 82 and
rebases the quantity index to 1972.

The figure denominator is:

```text
real R&D investment in millions of 1972 dollars =
    1972 nominal R&D investment in millions
    * R&D quantity index in year t
    / R&D quantity index in 1972
```

The reader accepts either the BEA API long format with `LineNumber`,
`TimePeriod`, and `DataValue` columns, or a wide table with year columns and a
line-82 research-and-development row.

The BEA API table ids are:

```text
FAAt207  Table 2.7
FAAt208  Table 2.8
FAAt105  Table 1.5
FAAt307ESI  Table 3.7ESI
FAAt307I  Table 3.7I
```

The BEA API currently requires an active `UserID`, so these files are kept as
explicit source CSVs rather than generated silently by the Julia plotting code.
They can be refreshed with:

```sh
julia scripts/fetch_bea_fixed_assets.jl
```

The IPP-investment analogue to Griliches' computer-investment table uses:

```text
fa_table_3_7i.csv    private IPP investment by industry
fa_table_3_7esi.csv  private fixed investment by industry
fa_table_1_5.csv     government nonresidential fixed investment and IPP
```

The derived file is built with:

```sh
julia scripts/griliches_fixed_assets_ipp_distribution.jl
```

and written to:

```text
csv/bea_fixed_assets_ipp_investment_distribution.csv
```

The total denominator is constructed as Table 3.7ESI private fixed investment
plus Table 1.5 government nonresidential fixed investment. Table 1.5 line 17 is
not used as the denominator because it is not additive with the Table 3.7ESI
industry-owner private total.
