# Source Notes

## Lecture Theme

This lecture compares aggregate national-account data with the accounting
objects in a simple growth model. The empirical table used in the lecture is
therefore not a single raw BEA table. It combines selected source lines from
NIPA and Fixed Assets tables.

## Source Versus Lecture-Ready Data

The legacy `nipa.csv` files are convenient for the current notebook, but they
are a mixture of lines from several BEA datasets. They should be retained for
replication checks while the cleaner pipeline is built.

The new organization separates:

- direct source extracts in `source_csv/`
- derived lecture-ready accounts in `csv/`
- previews and staging output in `tmp/`

## Data Center

The Data Center should highlight selected direct source tables, especially NIPA
Table 1.1.5 and NIPA Table 1.10. It does not need to expose every source used
to construct the model-account table. That distinction is part of the lecture:
matching theory and data requires additional measurement choices beyond reading
one published table.
