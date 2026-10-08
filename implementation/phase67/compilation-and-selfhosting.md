# Compilation and selfhosting protection

The selected native optimization passes the bounded compiler regression screen.
Actual B2 compilation is effectively unchanged on Numeric and Map: **0.99882×**
the previous selected B2's request time. B1 measures **0.95930×** its previous
selected image, but two sources and two samples per role do not establish a
causal compiler speedup. No new compilation optimization was selected; the
[bounded opportunity review](compilation-side-review.md) explains why.

The [verified qualification join](evidence/final-qualification01.json) checks
the actual receipts and binds both generations to `scalars-build01`. Its
[collector](../../selfhost/tools/performance/phase67/latency/collect-final.py)
performs data verification only; it does not run compilers or install a release.

## Fresh compilation measurements

Each number below is the median of two fresh processes, with the role order
rotated. Preparation creates private persistent Base caches outside the clocks.
The request uses the ordinary checked library interface and emits the complete
JavaScript module. Every measured module must match its pinned qualified output.
The two roles use the actual selected Phase66 and Phase67 images of the same
generation. There is no TypeScript timing role in this protective screen.

| Image | Source | Phase66 request, ms | Phase67 request, ms | Phase67 / Phase66 |
| --- | --- | ---: | ---: | ---: |
| B1 | Numeric recurrence | 249.39 | 238.67 | 0.95701× |
| B1 | Map/set operations | 1,214.35 | 1,167.73 | 0.96160× |
| Actual B2 | Numeric recurrence | 209.10 | 209.04 | 0.99972× |
| Actual B2 | Map/set operations | 966.99 | 964.98 | 0.99792× |

The equal-source geometric mean request ratios are **0.95930× B1** and
**0.99882× B2**. Including actual host and API import time gives **0.95999×** and
**0.99785×**, respectively. These are different clocks. B1's baseline samples
vary substantially: Numeric 239.51–259.26 ms and Map 1,166.98–1,261.73 ms.
That variability and the small sample size are reasons to treat the B1 result
as passing regression protection, without crediting a new 4% compiler gain.

All **16 measured workers** completed with exact raw outputs. Both preparations
and measurement campaigns together consumed **45.67 seconds** of controller
wall time: 27.52 seconds preparation and 18.15 seconds measurement. Peak sampled
process-tree RSS was below 153 MiB. These totals cover this two-source screen,
not the native campaign, selfhosting or release work.

Raw summaries are `selfhost/build/phase67/latency-b1-plan01/summary.json` and
`latency-b2-plan01/summary.json`. The qualification join pins both summaries,
their raw observations and methods. `prepare-screen.py` derives the earlier
method through counted path/profile-hash substitutions, preserves historical
admissions and binds the actual new image; each plan retains its exact command
arrays in `recipe.json`. The duplicate `scalars-b1-latency01` and preliminary
`atoms-b1-latency01` are data-only preparations and contributed no measurements.

## Fresh selfhosting and unchanged JavaScript evidence

The selected B1 API is `c76f111391e3…`, and its genuine self-emitted B2 is
`cbffd1f877b2…`. Both correspond to complete source `e4a4105ed91a…`; full hashes
are recorded in the join. Fresh gates establish:

- Strict36 has exact paired agreement on the selected checked source.
- B1/B2 agree on all eight ordinary driver observations, including emitted C
  bytes. That C comparison is emission evidence; native execution has separate
  controls and benchmarks.
- Actual B2 freshly accepts the complete compiler source's types. It also
  correctly refuses proof trust for its explicit unsafe declarations. This is
  a self-check, not a mathematical correctness proof of the compiler.
- Unsplit B2 emission produces B3 with exactly the same complete bytes as B2.
- Fresh B1 and B2 compile all 23 benchmark sources, giving identical raw modules
  and the unchanged 45-point observer mapping. New B1's 45 point modules also
  match the previously selected B1 exactly.

The independent source/data audit finds **1,403 frontend functions** and all
**3,066 functions reachable from 98 non-`nc_compile` public roots** unchanged,
with exact runtime/export wrappers and unchanged host, Base and non-native
source files. It supports retaining the prior finite frontend/JS conformance
outcomes and their exclusions. It does not qualify changed native output.
The join separately verifies ten raw native-control rows, eight paired native
probes, and four maintained fixtures at one and four threads. The mocked
shared-error control is a CPU diagnostic, not GPU execution evidence.

## What the phase does not remeasure

The last broad 23-source compilation results remain Phase66's **1.402× B1** and
**1.321× B2** relative to pinned TypeScript. Multiplying those historical ratios
by this two-source screen would invent a new broad result. Likewise, exact
unchanged JS23/45 bytes permit retaining the applicable earlier generated-JS
runtime observation; they are not a fresh generated-program speed campaign.
The full conformance suites, GPU behavior and unsupported native methods are
not newly qualified by these gates. Release installation is reported separately.
