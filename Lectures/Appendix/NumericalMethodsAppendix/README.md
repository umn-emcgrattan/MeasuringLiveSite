# Numerical Methods Appendix

This appendix collects numerical preliminaries used by the computation and
simulation lectures.

The goal is to pair short, transparent Julia routines with write-ups that
explain why the methods work. These files should support the economics lectures
without turning the main model chapters into numerical-analysis lectures.

## Current Layout

```text
NMA.jl                       Pluto write-up, edited by the user
src/quadrature.jl            Gauss-Legendre quadrature routines
scripts/quadrature_driver.jl runnable quadrature example
src/autoregressive.jl        AR(1) Markov approximation routines
scripts/autoregressive_driver.jl runnable AR(1) example
tmp/                         disposable outputs
```

## Quadrature Example

Run from this directory or from the repository root:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/quadrature_driver.jl
```

The driver prints a Gauss-Legendre rule and approximates an integral using the
student-readable implementation in `src/quadrature.jl`.

The first conceptual example is the two-node Gauss-Legendre rule on `[-1,1]`.
The four unknowns, two weights and two nodes, are pinned down by requiring
exactness for `1`, `x`, `x^2`, and `x^3`. The resulting rule has weights equal
to one and nodes `-1/sqrt(3)` and `1/sqrt(3)`.

## Autoregressive Example

Run from this directory or from the repository root:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/autoregressive_driver.jl
```

The driver prints a three-state example matching the appendix notes and a
five-state Tauchen-style approximation. It also checks that each transition row
sums to one and compares the continuous conditional mean `rho*y_i` with the
conditional mean implied by the discrete Markov chain.
