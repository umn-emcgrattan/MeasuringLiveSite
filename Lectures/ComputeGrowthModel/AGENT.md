# Codex Handoff Notes

These notes describe the working pattern for `ComputeGrowthModel`.

## Collaboration Rule

The user controls the main Pluto notebook file, currently `CGM.jl`. Codex
should not edit `CGM.jl` unless the user explicitly asks for a specific patch.

Codex may maintain supporting files:

- `src/`: model primitives, numerical routines, and reusable solver code.
- `scripts/`: runnable examples and checks for each computation method.
- `csv/`: computed outputs for lecture tables and figures.
- `docs/`: method notes and interpretation.
- `tmp/`: disposable diagnostics and previews.
- `visualize.jl`: optional terminal-side staging script.

## Student-Code Rule

For Method I and related numerical preliminaries, use only Julia standard
libraries needed for basic numerics and printing, especially `LinearAlgebra`
and `Printf`. Avoid packages such as `Optim`, `Interpolations`,
`Distributions`, and `QuantEcon` in student-facing code.

The point is to help students see the numerical method, not to hide it behind a
package.

## Current Method Files

```text
src/vfi.jl                         shared value-function-iteration code
scripts/vfi_continuous_z_driver.jl continuous-shock/quadrature example
scripts/vfi_markov_z_driver.jl     Markov-chain example
src/riccati.jl                     Method II Riccati iteration code
scripts/riccati_iteration_driver.jl runnable Riccati example/check
src/vaughan.jl                     Method III generalized-eigenvalue code
scripts/vaughan_eigen_driver.jl    runnable Vaughan example/check
```

`CGM.jl` can later include or call these routines, but the notebook remains
user-edited.
