# Codex Handoff Notes

These notes describe the working pattern for
`Appendix/NumericalMethodsAppendix`.

## Collaboration Rule

The user controls the main Pluto notebook file, currently `NMA.jl`. Codex
should not edit `NMA.jl` unless the user explicitly asks for a specific patch.

Codex may maintain supporting files:

- `src/`: student-readable numerical routines.
- `scripts/`: runnable examples, checks, and demonstrations.
- `docs/`: method notes and derivations that support the notebook.
- `tmp/`: disposable outputs from checks and visualizations.
- `visualize.jl`: optional terminal-side staging script.

## Appendix Purpose

This appendix collects numerical preliminaries used by the computation and
simulation chapters. The goal is not cookbook code. Each topic should explain
why the method works, what approximation is being made, and how the Julia code
implements the idea.

## Current Topic

Gaussian quadrature introduces the idea that an integral can be approximated by
a weighted sum of function values:

```text
integral -> sum of weights times values at nodes
```

The first student-facing example should stay simple: Gauss-Legendre quadrature
on `[-1,1]`, where `n` nodes integrate polynomials up to degree `2n-1`
exactly.

The autoregressive-process section introduces a finite-state Markov
approximation to

```text
y[t+1] = rho*y[t] + epsilon[t+1]
```

using an equally spaced grid and normal CDF bin probabilities. Keep the code
plain and inspectable before optimizing or generalizing it.

## File Roles

```text
NMA.jl                       user-controlled Pluto write-up
src/quadrature.jl            student-readable quadrature implementation
scripts/quadrature_driver.jl runnable example/check
src/autoregressive.jl        student-readable AR(1) Markov approximation
scripts/autoregressive_driver.jl runnable AR(1) example/check
tmp/                         disposable outputs
```

Use `joinpath(@__DIR__, ...)` in scripts so they run correctly from any working
directory.
