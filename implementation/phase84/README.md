# Phase84: four native work-replacement prototypes

**This round did not establish a route to compilation parity.** Four actual Bend
prototypes were built and measured. The larger annotation/erasure fusion is
neutral under genuine B2 despite exact semantic products; reject its278 added
lines. Three small shortcuts produce only local or uncertain gains; defer them.
Production source and the installed Phase82 compiler are restored and verified.

[Design](../../design/phase84/replace-native-work.md) ·
[Methods](../../selfhost/tools/performance/phase84/README.md) ·
[Qualification](qualification.json) · [Preserved evidence](evidence.json).

## Baseline and unchanged user metrics

Baseline source before this phase: `7352a00`; installed genuine B2
`098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092`, checked B1
`8a4007259794bdf0bca9616bc106423f227436013442e9a9ced78659bf6f374c`. Upstream remains
`059266225b77c8ca256ac6b25ee5c21449bab151`.

The qualified three-source compilation ratios remain **1.673× B1 /1.328× B2**
upstream. They measure fresh JS-hosted Bend-to-C requests, including source
loading, checking, ordinary Bend reporting and emission. Imports, explicit
prepared Bend Base, Clang and native execution are separate. The inherited
upstream comparator loads/checks Base but does not invoke its CLI proof-report
helper; this asymmetry remains explicit. No process reuse or omitted candidate
work is used to claim a gain.

Earlier compiled-C execution evidence remains1.067× upstream. No new execution
speed claim, conformance improvement or installed release is made. Known seven
reference failures/thirteen broader native API gaps remain. Maintained Bend
source stays32,540 physical lines/132 modules; no production complexity increase.

## Controlled prototype results

Each source attempt gets a fresh snapshot. Four checked B1 builds pass the
36-case frontend equality profile; one initial build fails and is retained.
Each initial speed screen has two rotated fresh-request rounds on Numeric, Map,
Functions65 and Small. All64 B1 clean outputs are exact prior C. These are short
screens, not confidence intervals, and their medians include every sample.

| Prototype | Numeric time change | Map | Functions65 | Small | Four-source geometric mean | Decision |
|---|---:|---:|---:|---:|---:|---|
| Actual-refusal fail-fast |+3.0%|−7.4%|−0.1%|+2.8%|−0.5%|Defer: local benefit only|
| Owned report/world reuse |−4.9%|+3.4%|−2.1%|−4.5%|−2.1%|Defer: small mixed screen|
| Coupled annotation/erasure |−3.0%|−2.9%|+1.1%|+1.6%|−0.8%|Reject: extra complexity|
| Binding-boundary refusal |−4.7%|−4.0%|+1.5%|−1.6%|−2.2%|Defer: narrow, noisy benefit|

[Screen1](screen01.json) · [Screen2](screen02.json) · [Screen3](screen03.json) ·
[Screen5](screen05.json). In screen5, one Numeric baseline sample is1346 ms while
its other baseline and both candidate samples are about1227 ms. Do not interpret
that row as a robust4.7% optimization. Map baseline also varies between campaigns;
compare simultaneous roles rather than cherry-picking older absolute times.

### 1. Stop after actual private-worker refusal

[Patch/record](../../experiments/phase84/P84-001-refusal.md) ·
[Notes](refusal-notes.md). Eighteen added Bend lines skip subsequent match rows
and avoid constructing some parent C text after the existing lowerer reports an
error. Scheduler lowering stays unchanged. Bound values still lower both sides
where needed to preserve existing first-error precedence.

This is real discarded work, but the screen is essentially neutral overall.
Phase83's379 ms spent constructing eventually-unready Map workers was an
**opportunity ceiling**, not time this small patch could automatically recover.
Much analysis and construction happens before the first refusal or in candidates
that only fail dependency admission later.

### 2. Reuse the exact owned report world

[Patch/record](../../experiments/phase84/P84-002-report-world.md) ·
[Notes](report-world-notes.md). Seventeen Bend lines plus a small driver dispatch
reuse the already-certified fresh Base index with the actual fresh source suffix.
The existing safe-closure/report algorithm and ordinary fallback remain intact.
This does not use parser terms before their FGlobal-to-Ref conversion.

Seventeen focused cases pass: thirteen complete old/new DR_Report comparisons,
three direct false-readiness fallback controls, two explicit-API comparisons,
unsafe imported definitions, mutual cycles, type/field dependencies, law fills,
inequality freshening and parse/check refusals. The mixed2.1% B1 screen does not
justify another full release campaign in a phase targeting20–25% savings.

### 3. Produce annotation and erasure together

[Patch/record](../../experiments/phase84/P84-003-fused-native.md) ·
[Notes](fused-native-notes.md) · [Independent review](fusion-review.md).
The278-line producer handles literals, lambdas, applications/spines, constructors,
matches and lets, with ordinary fallbacks. It carries erased bodies into the
existing request cache so runtime closure traversal avoids recursive re-erasure.
It **still retains annotated trees** for layout, scalar and sharing consumers;
this is partial fusion, not completed removal of the annotation representation.

Four benchmark controls compare complete annotated definitions and complete
NR_Request values, including private indexes, bodies, arities, closure order,
foreign scope and bounds. All match. Six focused controls compare complete owned
inspect results with fusion enabled/disabled: erased fields, open-array layout
refusal, dependent arrays, rewrite binders, partial closures and erased-field calls.
Five successful cases retain complete C; the rejected case retains its diagnostic.

Because B1 and B2 differ in allocation/code shape, a bounded genuine B2 build was
worth testing despite weak B1 results. Tiny split/unsplit emission and eight
ordinary driver observations pass. Its24 clean requests include baseline B2,
fused B2 and upstream, rotated across the same four sources:

| Source | Baseline B2 ms | Fused B2 ms | Upstream ms | Fused/baseline | Fused/upstream |
|---|---:|---:|---:|---:|---:|
|Numeric|969.8|953.6|755.6|0.983×|1.262×|
|Map|1793.4|1863.5|1238.8|1.039×|1.504×|
|Functions65|626.5|627.1|402.5|1.001×|1.558×|
|Small|277.7|276.2|335.6|0.995×|0.823×|

The four-source candidate/baseline geometric mean is **1.0043×**, effectively
neutral. Map has one noticeably slower candidate sample; both are retained.
[Every sample and identity](screen04.json). This exploratory four-source set is
not substituted for the qualified three-source headline.

A separate Numeric profile explains why the expected breakthrough failed:

| Public stage | Baseline B2 | Fused B2 |
|---|---:|---:|
|Annotation /paired producer|81.4 ms|96.3 ms|
|Request preparation|113.6 ms|80.1 ms|
|Combined|194.9 ms|176.4 ms|
|Final native compilation|423.3 ms|417.8 ms|

The later stage loses about33.5 ms, but producing paired results adds about14.9 ms:
only18.6 ms net in that instrumented region. The old world/annotated source,
request construction and consumer passes remain. The new paired return values
and body index also cost work; profiles do not isolate their individual shares.
[Raw stage clocks](fusion-stages.json). These instrumented numbers explain a
mechanism, not a clean speed claim. Even the entire old annotation/preparation
region is only about18.5% of this profiled request; a realistic replacement saves
less. Eliminating one traversal could not supply25% on this input.

**Reject this implementation.** This falsifies this paired-product prototype,
not every possible native IR architecture. A future rewrite must replace the
remaining consumers and representations, with an explicit cost budget, rather
than add another producer while preserving their work.

### 4. Refuse before constructing a binding continuation

[Patch/record](../../experiments/phase84/P84-004-binding-refusal.md) ·
[Routing proof and consumer audit](refusal-binding-notes.md). Twenty-three added
lines recognize a saturated, non-bang self Ref/App at an actual reached binding
boundary. The target owner must be an ordinary non-native/non-foreign definition,
and its own product signature must be absent. That value must use a non-tail
local destination, so the ordinary worker cannot be admitted. Unknown routes
retain the existing lowering; there is no recursive syntactic classifier.

The skipped private failed-worker error/body/freshness/dependency payload may
differ. Admission, retry, emission, host planning and observer consumers were
statically audited: failed workers cannot become ready or contribute C/public
errors; their names remain available for collisions. This finite source audit
and exact C screen are not a broad correctness proof or release qualification.

An instrumented derivative observes the actual predicate decisions:

| Source | Predicate calls | Successful shortcuts |
|---|---:|---:|
|Numeric|338|1|
|Map|4116|28|
|Functions65|195|0|
|Small|3|0|

All four diagnostic C outputs remain exact. Map hits include the recursive
helpers identified in Phase83, but the gate checks thousands of bindings and
cannot bypass candidate work still eligible for product routing or later
blocked by dependencies. This explains its narrow applicability; it does not
establish the cost of each hit. [All owner/tag counts](refusal-counts.json).
Do not promote the noisy2.2% B1 screen or project it to B2.

## Failures retained and corrected

- compiler02 fails the bootstrap type check: the report context's local Con
  needs an explicit List type. compiler03 corrects it.
- report-controls01 uses Type where a constructor field requires Data. V2 fixes
  the generated fixture and passes; this was a harness failure.
- fusion-focused01 selects an upstream proof fixture without `import Base`.
  All compared routes correctly reject it before fusion. V3 narrows to runnable
  Base+main fixtures; no dependent-pair positive coverage is claimed.
- fusion-focused02 wrongly expects explicit/raw API file lists to equal owned
  loader lists. The full owned fusion-disabled comparison already passed.
  V4 removes that unrelated contract and all six intended controls pass.

No failed attempt is relabeled successful. Versions, outputs, errors, patches,
checked snapshots and the actual experimental B2 image remain preserved.

## Efficiency and disposition

There are **88 clean requests with exact C**, four successful checked-B1 builds
(36 frontend cases each), one genuine experimental B2/eight-driver comparison,
four complete benchmark-product comparisons, six focused fusion controls,
seventeen report controls, two CPU profiles and four refusal-count requests.
Correctness, speed and release decisions remain separate.

The120 guarded jobs consume **618.6 seconds of target occupancy** (10.3 minutes).
The first-to-last guard span is28.9 minutes, excluding planning before the first
guard and reporting/archival afterward. Peak aggregate RSS is1.60 GiB; there is
no OOM or timeout. Four guards fail for the retained source/harness issues above.
Three reused agents prepare patches, focused controls and static reviews; root
alone applies changes and runs targets serially. No quota consumption is inferred.
[Resource receipts](resources.json).

All production source, host driver and tracked dist files match the prior state.
The installed release verifies as genuine Phase82 B2 `098320e8…`. Unrelated
inherited Phase6/68 changes remain untouched. No PR comment was posted.

The useful outcome is a much tighter negative result: the removed recursive
work was smaller than its enclosing stages, and neither pair construction nor
local refusal bypasses removes the remaining native planning machinery. General
parity still needs24.7% less qualified B2 request time. This phase does not
establish an implementation with that gain; expanding these same shortcuts or
promising a multiplier from an IR name would disregard the measurements.
