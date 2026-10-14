# Adding Intellectual Property Products

This lecture's supporting pipeline builds an interactive, year-selectable
illustration of how capitalizing software changes the input-output accounts.
The notebooks remain presentation layers; committed CSV data allow offline
use.

## Rebuild

From this directory:

```sh
julia --project=scripts -e 'using Pkg; Pkg.instantiate()'
julia --project=scripts scripts/update_data.jl
julia visualize.jl
```

Refreshing requires a BEA API key in `BEA_API_KEY`, `BEA_USERID`, or the
user-level `~/.beadatarc` file. The key is never stored in this directory.

## Interpretation

The current BEA accounts already capitalize software. The builder reconstructs
the corresponding "before capitalization" production account:

- prepackaged and custom software are moved from intermediate inputs to final
  investment; gross output is unchanged;
- own-account software adds equal amounts to gross output, value added, and
  final investment.

This is an economy-wide accounting bridge, not an allocation of software use
to individual industries. Values are annual current-dollar billions.

The companion benchmark matrix uses the detailed BEA use tables for 2007,
2012, and 2017. It aggregates IPP-producing industries and related commodities
separately from the rest of the economy and retains BEA's explicit IPP final
demand columns. The labels deliberately say "IPP-producing" and "IPP-related"
because an industry's complete output is not identical to IPP investment.

