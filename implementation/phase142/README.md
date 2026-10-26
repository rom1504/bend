# Phase142: incremental work proportional to the edit

Execution of the [committed plan](../../design/phase142/README.md), starting
2026-10-26 01:34UTC from `e093c3b`. The first checkpoint was committed as
`0466e0c`. Qualified Phase137 N3 and the installed selection remain unchanged.
The first three reuse prototypes did not establish a broad request-level gain.
A native warm-edit profile led to indexed visited names in layout validation
and reachability: **10.1% lower warm native latency,8.2% lower inclusive rebuild
estimate**, with identical generated QBE. This completes the initial experimental
block, not the whole10× plan. The native candidate remains unselected and has
not undergone a new N1/N2/full45 qualification campaign.

## Measured native result

[Exact candidate](candidate.json) · [native comparison](native-comparison.json) ·
[complete-build join](build-metrics.json).

One clean matched pair, same frozen Phase137 A→B product-policy edit, CPU3,
clean runtime and QBE/as/link settings. Both106MB products match the respective
independently qualified references; A and B differ, so this is a real edit.

| Boundary | Phase141 N2 parent | Indexed candidate | Change in time |
|---|---:|---:|---:|
| Cold seed native stages |357.428s|346.870s|−2.95%|
| Warm frontend |31.330s|20.798s|−33.62%|
| Warm raw lowering |13.377s|13.355s|−0.16%|
| Warm optimization/verification |40.112s|40.130s|+0.04%|
| Warm registry |10.031s|10.397s|+3.65%|
| Warm render/close |6.822s|6.754s|−1.00%|
| Warm native total |101.672s|91.434s|−10.07%|
| Available-executable subtotal |120.967s|110.756s|−8.44%|
| Inclusive estimate, all shared session overhead charged to B |125.227s|114.916s|−8.23%|

The frontend saves10.532s; later stages collectively offset0.294s. Reachability
and layout changes were tested together, so the native result does not assign
the saving separately to each walker. These are descriptive single-pair
observations, not confidence intervals or arbitrary-edit guarantees.

One actual13.917s machine build of the byte-identical B product is added equally
to both subtotals. Source IO and complete host reconstruction are included;
shared process preparation/teardown and host overhead are charged explicitly.
Outer guards, compiler acquisition, cold cache seeding and qualification remain
separate. The rebuilt B compiler passes Lexer, Map and closure requests against
frozen complete QBE in5.704s, giving candidate readiness estimate120.621s.

Relative to the **historical**, unrepeated346.960s fresh-B denominator,114.916s
is3.019× faster. The primary new result is the matched8.23% reduction, not a newly
measured3× cold/warm campaign.10× would require34.696s at that denominator;
we are still well short. Generated-program speed was not rerun broadly: identical
QBE/runtime preserves the tested products, with no new universal runtime claim.

## First result: a cache hit is not a useful-work saving estimate

Two checked Bend prototypes preserve complete Lexer/Map edited QBE and failure
recovery, but neither has established the plan's complete-request performance
gate. The first removes many equality comparisons; the second transports a
successful judgment through an unchanged representation. Both are retained as
experiments, not selected speed improvements.

| Experiment | Actual work removed | Measurement and disposition |
|---|---|---|
| Raw-owner witness |183/265 Lexer and641/666 Map first-boundary segment comparisons|Separate hosted APIs showed+6.56%/+3.70% median paired latency; an unchanged-path A/A control itself showed+5.56%. Causal attribution is unsafe.|
| Same-request raw/static judgment |Second raw-body scan and static-image validation after an unchanged original bundle|Shared-API screen: Lexer+3.63%, Map−2.57% median paired complete latency; order effects and inconsistent latency summaries remain. No broad win.|
| Completed-prefix freshening |Renaming and reconstruction of the retained prefix|On literal compiler prefixes, guarded freshening takes about0.68×/0.49×/0.34× at128/512/1024 declarations. Full requests are1.007× Lexer and0.975× Map; these small fixtures retain only3/2 declarations. No demonstrated native/full-compiler payoff.|
| Machine-auditor rewrite |Repeated host comparisons inside the existing auditor|Two unchanged-artifact checks save about0.280s combined. Eight negative controls retain identical outcomes. This does not explain the earlier multi-second machine floor.|

The same-request Map **ratio of median latencies** is slower, despite the lower
median paired ratio. Retain every pair; do not choose the favorable statistic or
subtract the A/A bias. All these measurements are hosted screens, not native
compiler performance or new full-build speed ratios.

## Implementations and correctness scope

The [witness](../../selfhost/tools/performance/phase142/witness/README.md) is
append-only and binds raw and verifier caches to one committed successful
revision. Diagnostic admission checks every retained claim with the original
comparator.25 new controls and25 original verifier controls pass. The original
second raw verifier remains; the final projected-worker verifier alone does not
independently check every raw body.

The [same-request prototype](../../selfhost/tools/performance/phase142/same-request/README.md)
changes only `p140b_lowered`. The original first verifier supplies the retained
raw/static bundle and metadata; that exact bundle reaches both the second check
and emission. Direct-function, array/transport namespace and final verification
remain.26 new controls and25 original controls pass. Do not silently compose
this with the first witness: their independent-check obligations differ.

Both complete screens compare fresh A, substantive B, warm B and reverted A;
parse/type errors preserve the previous successful session and recover exactly.
Existing proof declarations are byte-preserved. These are source checks,
construction arguments and finite differential tests, not a new equivalence
theorem or native qualification.

## Attribution and the next boundary

On the two hosted edited requests, the first complete verifier takes about
0.039/0.108s in diagnostic replay. The independent final projected verifier
takes0.367/0.132s. These overlap actual stage work and cannot be summed with it.
They do not establish the exclusive native floor in the historical40-second
optimization/verification stage. Immutable Base completion is only about9ms in
its own replay: a new cache for that alone is not justified.

The frontend still materializes and freshens the entire user prefix after a
parser hit. [The source audit](../../research/phase142/freshening-prefix-audit.md)
shows why parser identity alone is insufficient: relative foreign paths change
under a different logical source directory. The conservative prototype retains
normal completion/validation and guards the exact completed prefix plus the
actual starting fresh counter.61 finite controls,18 complete-loader cases and
two-family full A/B/revert/error-recovery checks pass. Its small-fixture full
request results remain approximately neutral; the source-prefix scaling probe
does not establish a native compiler speedup.

The [larger completion audit](../../research/phase142/completed-prefix-reuse-audit.md)
identifies an earlier boundary: completion is elementwise under a genuinely
fixed parser/completion context. Acceptance, duplicate-name checks and dependent
checking can still depend on the suffix. A future producer-owned prefix could
avoid materialization while retaining those gates; the present experiment does
not claim to implement that capability.

## Native evidence changed the priority

We reused the retained Phase141 N2 object and the existing context runtime to
profile the actual full compiler A→B edit. The relink cost1.64s; no compiler
rebuild was needed. Both complete106MB QBE products match their independent
oracles.24,594 samples were captured without loss, with99.44% main-thread CPU
coverage. The [profile analysis](../../research/phase142/native-context-findings.md)
preserves unknown samples and the limits of approximate stage windows.

| Warm stage | Instrumented stage seconds | Conservative interior finding |
|---|---:|---|
| Frontend |32.630|`has_name`42.62%; constructor existence11.13%.|
| Raw lowering |14.255|Only240 samples; exact-head and source-term comparison dominate that small interior.|
| Optimization/verification |45.385|Distributed lookup, constructor-ownership and deep-comparison costs; physical drop/fade together30.0%.|
| Registry |11.277|Only91 interior samples; insufficient for precise ranking.|
| Render/close |7.682|No conservative interior; no stage attribution claim.|

These are diagnostic timings, not clean speed comparisons. Active dispatcher
owners are not complete caller stacks, and ownership attribution is conditional
on the emitter's segment mapping contract. In particular,42.62% does not say
that the layout walker alone costs42.62% of frontend execution. Physical string
equality samples overlap owner samples and must not be added to them.

The important distinction: some expensive full-source comparisons happen
**before** the raw-IR witness boundary we first targeted. Removing many later
comparisons can leave those dominant costs untouched. The next reuse design
must carry exact producer identity across the earlier annotation/erasure boundary,
rather than reconstructing another identity by walking the whole product.

## Small algorithm change before another cache

The [indexed traversal experiment](../../experiments/phase142/P142-006-indexed-traversal-membership.md)
replaces growing linear visited-name searches using the existing collision-safe
name index. Layout validation retains its sentinel, stops and complete term
checks. Reachability retains the exact output list, including duplicates and
constructor-owner resolution order. No source-revision cache or verifier
exception is introduced. The production overlay changes two entry bodies and
adds13 private declarations (+79 physical lines net); all original proof declarations remain exact.

The independent, pre-override API passes26 layout and28 reach controls, including
real hash collisions, missing names, shadowing, cycles, aliases and stops. On
two real programs it preserves complete ordered outputs. The bounded512-definition
constructed graph takes0.116× the original layout time and0.080× reachability
time (median paired ratios). These are hosted scaling probes, not speedups of
the full compiler. Small real programs are mixed: the first layout screen showed
Lexer1.376× and Map1.015×; the repeated combined API showed0.948× and1.014×.
Keep both screens and their distinct code/JIT contexts.

The integrated source independently checks, and complete Lexer/Map fresh A,
edited B, warm B and reverted A QBE agree byte-for-byte with the independent
references. Parse/type errors preserve the previous session and recover exactly.
The [integration audit](../../research/phase142/indexed-visitors-integration-audit.md)
explains why independent differential controls must use the pre-override API;
after wiring, a call through the old entry can reach the candidate too.

One production-only native candidate was acquired with qualified Phase137
N3 in373.7s guarded emission plus16.35s guarded machine construction. The
focused native live-open-array refusal and dead/erased acceptance checks pass
against Phase141 N2, including exact diagnostics and positive QBE products.
The decisive native comparison above preserves identical stage reuse counts and
complete output products. No native qualification or promotion follows merely
from acquiring and testing this experimental executable.

## What to do next

The immediate target is the remaining40.1s optimization/verification stage,
which this algorithm change does not address. The strongest structural direction
is carrying exact owner-product identity from annotation/erasure into later
preparation and verification, before those consumers reconstruct or deeply
compare the same material. First isolate the dynamic cost of that exact boundary;
do not repeat the mistake of choosing a seam from hit counts alone.

The smaller next falsifier is indexed local membership in the active `dr_walk`;
its shared safe-result index already exists. It must preserve partial closures
and avoid publishing unsafe visits. The larger completion and direct-unit/object
directions remain open. See [remaining opportunities](remaining-opportunities.md)
for acceptance conditions and rejected shortcuts.

This is not evidence of recursive research acceleration. Acquisition alone was
about390s guarded; at the10.31s inclusive saving it would take roughly38 similar
updates to amortize, before additional qualification/research cost. The underlying
incremental mechanism already has a much larger benefit versus fresh builds;
this phase improves it modestly and identifies why the first reuse ideas missed.

## Evidence and reproducibility

The methods live under [phase142](../../selfhost/tools/performance/phase142/).
[Checkpoint evidence](evidence01/inventory.json) and
[final evidence](evidence02/inventory.json) freeze receipts and reproducer inputs
in byte-verified archives. The final capsule additionally retains the diagnostic
native executable and bound owner map for offline profile reanalysis. Each run records exact source/API/tool/input hashes, complete outputs or output
digests, setup costs and guard receipts. One CPU3 lane,3GiB process-tree caps
and16GiB available-memory floors were used. Failed source annotations and an
incorrect first API-export request are preserved. The initial attribution
observer's Bool-ABI reporting bug is corrected in `attribution-v02.mjs`; do not
interpret v01's false/zero diagnostic fields as compiler refusals. Other retained
failures include the attached-law signature mistake, synthetic2048 timeout,
transport wire-pin shape error in the first metadata comparator, and a nested
guard lock refusal before any readiness compiler ran. The retry uses the existing
readiness runner's own serial guards; no guard was bypassed.

[Cost receipts](costs-final.json) account for47 guarded jobs,48.17min total/union,
including8 failed guards totaling1.72min. Peak tree RSS was2.33GB and minimum
available memory22.47GB. Three bounded agents audited contracts, prepared controls
and observers, and synthesized profile/source findings; only the coordinator ran
compiler measurements. Agent work overlaps wall time and is not inferred from
guard totals. Token/quota consumption is unavailable. No full45 campaign or
second candidate acquisition was launched for these early experiments.

No changed default, new upstream comparison,10× build result or recursive
research acceleration follows from the present measurements. Preserve qualified
Phase137 N3, Phase141's existing qualification and all failed experiments.
