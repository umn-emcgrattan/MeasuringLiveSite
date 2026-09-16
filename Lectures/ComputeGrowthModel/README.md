# Compute Growth Model

This directory contains the lecture and supporting code for computing the
growth model introduced in `MacroDataTheory`.

The Pluto notebook `CGM.jl` is user-controlled. Supporting numerical routines
live outside the notebook so they can be edited in a text editor and run from
the terminal.

## Method I: Value Function Iteration

The first method iterates on the Bellman equation. Two versions are provided:

```text
scripts/vfi_continuous_z_driver.jl
scripts/vfi_markov_z_driver.jl
```

The continuous-shock version treats `log z` as continuous and approximates the
conditional expectation with Gaussian quadrature. The Markov-chain version uses
a finite-state approximation to the autoregressive process.

Both versions use the same model primitives and grid-search maximization in:

```text
src/vfi.jl
```

The student-facing code uses only Julia standard libraries:

```julia
using LinearAlgebra
using Printf
```

Run examples from the repository root:

```sh
julia ComputeGrowthModel/scripts/vfi_continuous_z_driver.jl
julia ComputeGrowthModel/scripts/vfi_markov_z_driver.jl
```

## Method II: Riccati Iteration

The second method maps the nonlinear problem to an LQ approximation and solves
the associated Riccati equation by direct iteration.

The generic implementation is:

```text
src/riccati.jl
```

The runnable example is:

```sh
julia ComputeGrowthModel/scripts/riccati_iteration_driver.jl
```

The code follows the lecture's maximization convention, so `Q` and `R` are
typically negative definite rather than positive definite as in a standard
cost-minimization LQR problem.

## Method III: Vaughan Eigenvalue Method

The third method solves the same LQ problem by forming the state-costate
generalized eigenvalue problem and extracting the stable invariant subspace.

The implementation is:

```text
src/vaughan.jl
```

The runnable example is:

```sh
julia ComputeGrowthModel/scripts/vaughan_eigen_driver.jl
```

The driver solves the same scalar LQ example as Method II and prints the
difference between the Vaughan solution and direct Riccati iteration.
