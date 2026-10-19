# Why bounded regions may leave the measured gap unchanged

This follow-up separates a compiler optimization hypothesis from generated-program
performance. The original compiler profile's U32→Word materialization represents
82.14% of its allocation-helper invocations. The six runtime workloads only execute
**two U32 special-takes per process** in lexer, ray and numeric; this is not the
compiler's allocation-heavy pattern-matching workload. Improving compiler execution
through scalar-pattern recovery therefore need not substantially improve these
six generated programs. A new compiler-image profile is the relevant test of that
hypothesis.

The word and region candidates also differ much less on the executed hot graph
than their private-definition counts suggest. The offline exact-QBE comparison in
[`region-source-shapes01.json`](region-source-shapes01.json) establishes:

| Program | Word private definitions | Region private definitions | Changed public bodies |
|---|---:|---:|---:|
| Lexer | 27 | 282 | 0 |
| Ray | 27 | 314 | 2 |
| Closures | 17 | 192 | 0 |
| Unicode | 18 | 208 | 0 |
| Map | 28 | 339 | 0 |
| Numeric | 19 | 217 | 0 |

In ray, both changed public bodies are continuations whose terminal call to
`clamp01` becomes a private call. The public bodies of `sx`, `sy`, `sz`, `sr`,
`isect.go2`, `isect.go`, `isect5`, `nearest` and `nearest.t` are unchanged. The total
number of runtime frame-call sites remains **357**. Ray QBE grows from **768,022**
to **902,653 bytes**. These are source-shape observations, not dynamic execution
counts or machine-code performance predictions.

All previously shared private bodies change text because region emission uses
different terminal snapshots/rebindings. Their runtime/private-helper call
histograms remain identical. Thus unchanged public bodies alone are not being
used as proof of unchanged execution. The new private definitions also include
unused admitted functions; counting admitted definitions is not sufficient
evidence that hot call boundaries disappeared.

The boundaries are explicit in
[`regions/README.md`](../../selfhost/tools/performance/phase112/regions/README.md):
eight worker arguments, eight callee arguments, eight captures, eight sites,
128 statements per copied continuation, six dependency ranks, and one-level
continuation fusion. `isect5` has ten arguments, `nearest` twelve, and `nearest.t`
ten. Region admission independently retains its eight-argument cap even when the
other private-worker experiment supports 32. Real returning-path frames and
longer continuation chains remain additional refusals. Raising one integer limit
cannot be assumed to eliminate all these barriers.

## Frozen diagnostic follow-up

The new plans
[`batch-word-plan01.json`](../../selfhost/tools/performance/phase112/profile/batch-word-plan01.json)
and [`batch-region-plan01.json`](../../selfhost/tools/performance/phase112/profile/batch-region-plan01.json)
bind the exact six already-built products and independent expectations, with one
repetition and zero warmups. They reuse the original diagnostic runtime and
independent counter control through the unchanged `profile/run.py`.

The source-only comparison tool `profile/compare.py` reports aggregate event
deltas plus stable decoded function/constructor/operation deltas. Anonymous
continuations are not individually matched across snapshots because their names
depend on fresh-variable allocation. An identity comparison against the existing
static profile passed without running targets.

**Dynamic comparison complete.** Both six-program profiles preserve their frozen
outputs. Five workloads have identical scalar counters and dispatch/public-call
totals. Ray removes exactly 512 `clamp01` dispatches and public jumps; frame
creation stays at 334,011 and allocation at 4,108. Public calls fall only from
6,694,462 to 6,693,950. Thus the current region boundary misses the dominant
executed work. A greater number of private definitions does not establish useful
call-path coverage. The separate compiler profile confirms a major reduction in
Word materialization, so these two hypotheses should not be conflated.

See the [measured comparison](profile-comparison.md) and its
[pinned evidence](profile-improvement-counts.json). A further uninstrumented
measurement must establish any speed gain; diagnostic counts do not provide
CPU-time shares.
