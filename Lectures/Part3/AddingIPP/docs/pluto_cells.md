# Pluto cells for the software remapping visual

The notebook owner can paste these as separate cells. They deliberately keep
the notebook thin and use only files inside this lecture directory.

```julia
include(joinpath(@__DIR__, "scripts", "ipp_io_helpers.jl"))
ipp_io_data = ipp_read_io()
```

```julia
@bind io_year Select(
    reverse(ipp_io_data.years),
    default = 2024,
)
```

```julia
ipp_io_table_html(io_year)
```

## Benchmark IPP/non-IPP matrix

The first include above also loads the benchmark matrix helper. Add these as
two more cells:

```julia
ipp_matrix_data = ipp_read_matrix()

@bind ipp_benchmark_year Select(
    reverse(ipp_matrix_data.years),
    default = 2017,
)
```

```julia
ipp_benchmark_matrix_html(ipp_benchmark_year)
```

The selector uses newest-to-oldest display order, while the committed data
remain sorted chronologically. No API call occurs when a student opens the
notebook.

