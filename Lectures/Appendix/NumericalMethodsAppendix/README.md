# Numerical Methods Appendix

This appendix collects numerical preliminaries used by the computation and
simulation lectures.

The goal is to pair short, transparent Julia routines with write-ups that
explain why the methods work. These files should support the economics lectures
without turning the main model chapters into numerical-analysis lectures.

## Current Layout

```text
NMA.jl                       Pluto write-up, edited by the user
src/numerical_differentiation.jl finite-difference routines
scripts/numerical_differentiation_driver.jl lecture differentiation example
src/quadrature.jl            Gauss-Legendre quadrature routines
scripts/quadrature_driver.jl runnable lecture quadrature example
src/autoregressive.jl        AR(1) Markov approximation routines
scripts/autoregressive_driver.jl runnable lecture AR(1) example
src/root_finding.jl           bisection and Newton routines
scripts/bisection_driver.jl   runnable lecture bisection example
scripts/newton_driver.jl      runnable lecture Newton example
src/dynamic_programming.jl    steady-state and growth-model routines
scripts/growth_model_driver.jl runnable normalized growth example
tmp/                         disposable outputs
```

## Numerical Differentiation Example

Run from this directory or from the repository root:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/numerical_differentiation_driver.jl
```

The driver applies forward, backward, central, and second differences to the
lecture example `f(x) = x^2` at `x0 = 1` for several step sizes.

## Quadrature Example

Run from this directory or from the repository root:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/quadrature_driver.jl
```

The driver prints the two-node Gauss-Legendre rule and applies it to the cubic
lecture example on `[-1,1]` using the student-readable implementation in
`src/quadrature.jl`.

The first conceptual example is the two-node Gauss-Legendre rule on `[-1,1]`.
The four unknowns, two weights and two nodes, are pinned down by requiring
exactness for `1`, `x`, `x^2`, and `x^3`. The resulting rule has weights equal
to one and nodes `-1/sqrt(3)` and `1/sqrt(3)`.

## Autoregressive Example

Run from this directory or from the repository root:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/autoregressive_driver.jl
```

The driver prints the three-state numerical example used in the visualization.
It checks that each transition row sums to one and compares the continuous
conditional mean `rho*y_i` with the conditional mean implied by the discrete
Markov chain.

## Dynamic Programming Example

Run:

```sh
julia Appendix/NumericalMethodsAppendix/scripts/growth_model_driver.jl
```

The driver uses the general steady-state conditions in
`src/dynamic_programming.jl` for the full-depreciation log/Cobb-Douglas growth
model. It compares the numerical steady state with the analytical result and
prints the raw and normalized capital grids.
