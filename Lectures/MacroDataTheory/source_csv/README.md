# Source CSV Exports

This directory is for direct plain CSV extracts from public BEA source tables.

The files should represent source-table lines with provenance columns, not
lecture-specific derived combinations. Derived objects belong in `../csv/`.

For this lecture, the first source group is expected to be:

```text
source_csv/bea_nipa/
source_csv/bea_fixed_assets/
```

NIPA Table 1.1.5 and Table 1.10 are natural Data Center candidates because they
are direct published national-account tables. Other BEA and Fixed Assets tables
are still needed for the theory/data matching exercise, but they can remain
supporting sources rather than Data Center headline tables.
