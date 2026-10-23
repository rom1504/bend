# Phase131 independent strategy audit

2026-10-23; source-only investigation against `9f7ab43b4152afc93dd408084922bc53e738ae3e`.
Selected Phase130 source SHA256:
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
Source line numbers below refer to the decompressed
[qualified source archive](../../implementation/phase130/compiler-source01.bend.gz).
No targets, benchmarks or new web survey were run. The coordinator owns the
execution lane. The registry probe described below is unexecuted source.

## The parity target is larger than the headline suggests

The separate qualified N1 comparison is 1.79493× upstream. A uniform reduction
of `1 - 1/1.79493`, about44.3%, would reach geometric parity. But the controlled
parent/candidate block's individual ratios are approximately2.59× lexer,
0.90× closures and2.51× Map. Closing the broad deficit therefore needs much
more than accelerating the already-fast short closure request.

| Phase130 controlled case | Native seconds | Upstream seconds | Remaining time reduction for individual parity |
| --- | ---: | ---: | ---: |
| lexer |1.988855|0.767332|61.4%|
| closures |0.485468|0.539487|Already faster|
| Map churn |2.898721|1.153824|60.2%|

Source: [native-results.json](../../implementation/phase130/native-results.json).
These ratios are one block; do not combine its timings with the independent
N1/N2 block. They concern cold source-to-IR requests with the existing prepared
Base policy, not machine construction or generated-program execution.

For an affected fraction `p` improved by a factor `s`, ignoring overhead, the
total time removed is `p*(1-1/s)`. A threefold faster component must cover about
66.4% of current time to remove44.3% overall. Coverage of30% gives only20% total
reduction even with a threefold local win. Reclamation and register-copy samples
overlap source-owner buckets; adding them to lookup/use percentages is invalid.

## Do not count solved preparation work again

The qualified source already threads `P128RawLowering{lowered,raw}` through
initial and late private closure (lines56416–56547). The old late
`p113pl_inspect_request` remains defined, but the selected route does not call it.
The Phase129 event archive confirms:

| Entry-segment event | lexer | closures | Map |
| --- | ---: | ---: | ---: |
| `p112s_prepare` |1|1|1|
| `p113pl_inspect_request` |0|0|0|
| `p113pl_candidates`, including list terminator |46|16|73|
| `nc_bangs_names`, including list terminators |138|48|219|
| `p111_verify_program` |2|2|2|
| `p114s_commit` |2|2|2|
| `p112c_scan` |9,748|1,556|44,027|

These are existing diagnostic events, not newly measured Phase130 counts.
Phase130 changed the Base decoder, not these source algorithms. Confirm hot
costs against the refreshed image before promoting a performance claim.
The original records are linked by
[Phase129 measurements](../../implementation/phase129/measurements.json), in
`selfhost/build/phase129/context-summary01/*-events.json`.

One very small duplicate remains: `p128raw_prepared` (56427–56434) computes
`nc_bangs_names(book,names)` separately for ordinary lowering and raw private
candidates. One local binding can supply both because the exact prepared book
and names are identical. The third walk is in `p128raw_br_prepare` on the
request's book; that is not automatically the same semantic snapshot.
Expect a small gain; do not sell this as the parity mechanism.

`nc_constructors(source,source)` is likewise computed before `p112s_prepare`
(56444) and again inside `p111_finish` (40091). It could be threaded through the
same preparation boundary, but its provenance/order and the static-preparation
constructor list must remain exact. It is a secondary cleanup, not a reason
to add a new catalogue cache.

## Independent opportunity A: stop constructing a fusion result that is identity

The current emitter builds a legacy worker registry through `p112c_index_with`
before selecting direct wrappers (`p113e_segment_chunks`,45290). Each eligible,
not-yet-ready candidate goes through `p112c_scan`, reconstructing statement and
branch lists, then `p112c_plan`, then admission and registry insertion.

Later, `p113e_old_private` (45264–45270) may emit only a forwarding wrapper to an
already-ready direct function. This looks redundant, but blindly skipping its
legacy plan is unsound as an exact-output cleanup: legacy eligibility, params,
rank, symbols and ready-set evolution affect other callers' fusion decisions.
The existence of a direct function alone does not establish those invariants.

A smaller unconditional fact is useful:

```
no exact p111_rt_frame call anywhere in body
  => p112c_scan(body,index,ready,site) = P112FusionBody(body,0,site)
```

`p112c_frame` (43857–43865) needs that exact call before any successful fusion.
The remaining scan just copies statements; `p112f_prepend` and
`p112f_scan_rest` preserve order and site count. This implication does not need
a direct-worker assumption or a new ownership model. Unknown, malformed and
potentially successful frame paths can keep the complete original algorithm.

The isolated [registry probe](../../selfhost/tools/performance/phase131/registry/README.md)
overrides only `p112c_add`, adds a recursive no-frame guard, and returns the
identity fusion product on success. All original planning, admission, rank,
ready-set, insertion and final-verification operations remain. Fourteen finite
controls were written but not executed. Emitter observations in those controls
are not a universal structural-equality proof.

**Cheap discriminator:** run the checked controls, compare complete QBE for
lexer/Map and a real successful-fusion program, then time the actual registry
stage with its inputs and cleanup included. Count no-frame versus fallback
candidates and body nodes traversed. Do not reacquire the compiler to learn
whether the extra guard is profitable.

**Falsifier:** frame-containing candidates pay an extra traversal; repeated
rounds pay again. If that outweighs avoided reconstruction, reject the probe.
If it wins, carry the fact from the existing cleanliness/candidate scan, rather
than keeping redundant repeated guards or adding an open-ended memoization cache.
The safe law would connect this actual guard to the original scan's identity;
it would not prove every registry optimization or final heap operation.

**Scale:** aggregate active contexts for `p112c_`, `p112r_`, `p112w_`, `p112f_`
and `p112t_` are1.84% lexer,1.54% closures and4.53% Map in retained Phase129
captures. Dispatched library helpers are outside those buckets, so this is not
a strict inclusive ceiling. It is nevertheless evidence against forecasting a
large whole-request win. Conditional expectation is low single-digit request
improvement; no improvement or regression is plausible. This is an economical
additional discriminator, not the main aggressive campaign.

## Independent opportunity B: avoid rechecking unchanged intermediate private IR

The transformation boundary already retains the immutable original and IDs:
`P114SBoundary`, `p114s_open_original`, `p114s_commit` (48750–48801). It performs
an initial ordinary/static verification, checks private functions, checks the
whole private function list after inlining, checks it again after range work,
and later runs the public final verifier. Map also verifies projected observer
functions on composition. Private-list verification repeatedly reconstructs
the ready index and checks local declarations, branches and names.

Observed whole ordinary/static verification occurs twice. The initial gate
protects transformations; the final independent gate must remain. Merely
deleting one or trusting producer metadata is not the proposed optimization.
Likewise, checking only changed functions without their dependency/ordering
context is not equivalent to `p113e_functions`.

The narrow candidate is an explicit **unchanged result** from a transformation:
retain the already-accepted boundary when no body changed, rather than rebuild
an identical list and run `p113e_functions` over it. Preserve per-pass rollback
and the final independent verifier. If a pass changes almost every request,
there may be little payoff. A deep equality scan that costs as much as the
verification it replaces is not a solution; propagate the fact while performing
the transformation, or test it offline first.

**First measurement:** inspect unchanged/changed lists in the current hosted
API on actual compiler-derived units; charge each intermediate verifier using
the existing profiler recipe. No new profiler framework is needed. Include
bad-intermediate cases showing fallback/error order remains unchanged.

Historical context buckets for verifier-prefixed functions total13.28% lexer,
3.07% closures and7.72% Map. This grouping includes final checks that must remain,
and excludes separately dispatched library helpers. It is not an obtainable
speedup. The more ambitious route is reusable, versioned verification facts
with proven dependency conditions, but that overlaps the current resolved-ID
work and is unjustified before no-op/changed-cost measurements.

## How this fits the active experiments

Resolved identity and reusable use facts remain the larger compiler-only bet.
They can remove repeated algorithms with exact generated QBE as a strong
regression gate. The registry experiment removes an independent temporary
computation; it must not absorb the budget if it has little dynamic coverage.
Generic borrowed-query regions are a separate generated-code-quality hypothesis
and should not be silently bundled into the first identity/use experiment.

The existing [fast-compiler survey](../compilers_architecture_and_techniques/phase128-fast-compilers.md)
supports bounded per-function work reuse and stable facts, not another global
cache or backend switch. The concrete lesson from Go's reusable per-function
state and Zig's phase identities is to preserve a useful established fact
across the next consumer. Here that can be as small as “this scan is identity”
or “this transformation changed no private body.” These are more falsifiable
than announcing a new universal compiler representation.

No set of measurements read here justifies promising parity during this phase.
If all successful discriminators still cover only20–30% of total current time,
the honest next step is a larger measured representation/ownership boundary,
not multiplying local speedups or treating the remaining work as free.
