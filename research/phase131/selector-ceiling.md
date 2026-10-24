# Scalar selector source ceiling: a useful limitation

Pushing a scalar consumer through lookup results gives a small improvement on a
one-entry leaf, but almost no benefit on a long bucket. The experiment supports
preserving producer/consumer information; it does **not** establish that source
fusion alone removes the important ownership work.

This is an extracted compiler computation using ordinary checked Bend. It is
not an automatic optimization, a new compiler selection or a full compiler
speedup. [The bounded summary](selector-ceiling-summary.json) retains raw rounds,
artifact identities and the analysis method.

## What was compared

Both variants use the exact final-Phase131 `index_find`/`index_bucket` algorithm
and KDef getters. The original computes `dx(index_find(...))`. The alternative
pushes the scalar projection through selector returns, retaining all legacy and
current representation branches. Both compile with the same final checked API,
runtime and aligned QBE toolchain. Both algorithms remain present in each binary
for ordinary differential controls; only the timed query selects one variant.

The one-entry leaf isolates a common bucket shape. The 64-entry forced-collision
bucket is explicitly a stress case, not a representative verifier distribution.
Each repetition performs a late hit and a miss. Hashes are supplied identically;
hash computation is outside this experiment. Results must not be extrapolated
to the complete `p111v_get` context, which includes hashing and other work.

All four native binaries passed the independently frozen 34-line ordinary oracle
before timing. It covers 16 cases through both algorithms, then observes held
roots. Cases include legacy/current maps, collisions, first-match order,
Unicode, mask-zero nodes, missing keys and an empty key that selects KIndexNode
and returns its mask 99. The earlier missing-forward-law and affine-scaffold
preparation refusals remain preserved.

## Clean measurements

Three paired/interleaved rounds ran on CPU3 with the unchanged runtime. These
are whole-process wall times; internal kernel milliseconds provide an additional
check that process startup is not the entire effect.

| Workload | Repetitions | Original median wall | Fused median wall | Wall reduction | Median internal time |
| --- | ---: | ---: | ---: | ---: | ---: |
| One-entry leaf |183,921|113.095 ms|106.014 ms|6.26%|111→104 ms|
|64-entry collision stress |17,050|471.032 ms|468.595 ms|0.52%|469→467 ms|

Median CPU reductions are 6.29% and 0.51%, respectively. RSS is effectively
unchanged (around 9.6 MiB per process).

For one entry, original wall rounds range 113.076–117.413 ms and fused rounds
105.755–107.384 ms. Paired reductions are 6.26%, 8.54% and 6.47%. Internal rounds
are 110/115/111 ms versus 104/105/104 ms. Thus the small improvement appears in
both process and kernel measurements and every pair; it is not just a single
slow baseline. The minimum internal duration is 104 ms, so none of these loops
falls below 100 ms, although the short kernel remains close to that minimum.
Three rounds do not supply a precise confidence interval.

For 64 entries, original wall rounds range 469.916–471.480 ms and fused rounds
467.717–470.017 ms. Paired reductions are 0.52%, 0.31% and 0.47%; the ranges partly
overlap. Internal timings are 469/470/468 ms versus 467/468/465 ms. Treat this as
approximately neutral for deciding on broad optimization machinery. A half
percent result on this small campaign is not evidence of an important general
speedup.

The pilot attempted to select about 500 ms of faster-variant work. It included
process/setup cost at only 1,024 repetitions, so linear scaling undershot badly
for the one-entry case. The actual 104 ms minimum is reported rather than
claiming the target was reached. More precision is unnecessary to conclude
that this is not the hoped-for large ownership-elimination gain.

## What actually changed in generated code

The timed wrapper shrank from 111 to 7 machine instructions. But the scalar
projection's owning work moved into the bucket: that function grew 272 to 376
instructions. The selector changed 595 to 594. The sum of these three static
function bodies is 978 versus 977 instructions; this is an illustration of moved
work, not a dynamic instruction count.

Both selector bodies retain the same 14 generic constructor and 43 sink sites
across their mutually exclusive branches. The fused bucket still takes and
releases KDef fields. Source return type and consumer placement changed;
borrowed descendant access and shared field knowledge were not introduced.
This explains why the large wrapper reduction did not become a large runtime
improvement. It also prevents the static local-code gain from being presented
as evidence of broad allocation removal.

## What the law established

The separate proof task checked exact bucket projection/fusion over all
`List<KDef>` and String inputs, with concrete `dn`, `dx`, equality and missing
semantics. The source bridge authenticates the candidate's exact definitions,
including the empty-key node case. Evidence is in
`selfhost/tools/performance/phase131/laws/bucket-evidence.json`.

This is a useful source-semantics certificate for the producer/consumer rewrite.
It does not prove the entire recursive tree algorithm, native ownership,
backend code generation or a performance claim. Native ordinary controls
remain necessary, and the retained qualified compiler is unchanged.

## Highest-value follow-up

Before adding a borrowed-result ABI, test composition with the separate wider
record capability. The fused scalar bucket has two roots, `List<KDef>` and a
String key, and a self-tail list recursion. If width-nine KDef access lets the
existing observer inline `dn`/`dx` while retaining their borrowed field origins,
it could remove ownership work that this source-only experiment merely moved.
Eligibility, actual emitted reader calls and dynamic behavior must each be
checked; no admission or speedup is claimed yet.

If that fails, the next missing capability is the checked scalar-consumer
selector region described in [the boundary audit](verifier-boundary.md), with
held map/key roots, virtual missing results and unchanged owning fallback.
Do not generalize a helper-return interface before a small experiment shows
that it eliminates actual traversal/reclamation work.

## Evidence

- Sources, oracle, rejected preparations, source/static receipts and reproducible
  analysis: `selfhost/tools/performance/phase131/regions/selector-ceiling/`.
- Successful integrated emission: `selfhost/build/phase118/p131-selector-ceiling03/report.json`.
- Clean calibrated report: `selfhost/build/phase131/selector-ceiling-timed02/report.json`.
- Timing manifest: `selfhost/build/phase131/selector-ceiling-timing02/manifest.json`.
- Pilot: `selfhost/build/phase131/selector-ceiling-pilot01/report.json`.

No new target execution was needed for this analysis.
