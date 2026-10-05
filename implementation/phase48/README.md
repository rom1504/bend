# Phase48: efficient values across calls and public boundaries

The selected compiler is RNFA04 (`checked-combined-rnfa04`), combining composite result boundaries (R),
native String values (N), finite F32 literals (F), typed array effects (A), and
bounded rejection of unprofitable zero/one-trip literal entry. All focused gates
and all eight maintained suites pass. The fresh backend census agrees on all
81 outcomes: 69 execution passes, eight N/A and four shared failures.

The live source exactly matches the frozen checked snapshot; H/V prototypes are
preserved separately. Installation, release verification, all 42 ordinary/relocated CLI
checks and the three-point/27-sample portable replay pass. The
[selected qualification](../../selfhost/tools/performance/phase48/evidence/selected-qualification.json)
joins the exact installed image and independent evidence. The [RNFA04 checkpoint](rnfa04-checkpoint.md),
[compiler costs](compiler-cost-final.md) and [accounting](accounting.md) record
measured benefits and costs without claiming parity.

## Final generated-program comparison

All **669 fresh samples pass across 45 points and 23 sources**. The unchanged
three-batch protocol took 1,132.24 seconds (18m52s). Compilation, profiles and
instrumented counters are excluded from these execution medians.

| Geometric weighting | Fresh array06 / TypeScript | RNFA04 / TypeScript | Speedup |
| --- | ---: | ---: | ---: |
| Equal point | 2.9024× | **2.6789×** | **1.0834×** |
| Equal source | 3.9789× | 3.6793× | 1.0814× |
| Equal family | 4.4797× | 3.9121× | 1.1451× |

The point result is **7.70% less execution time**, or an 8.34% speedup. Generic
row improves **13.467×** (55.728× → 4.138× TypeScript), Unicode16/64 improve
**1.257× / 1.462×**, and numeric1024 improves **1.062×**. Generic row contributes
72.1% of the net equal-point logarithmic gain; the other 44 points collectively
improve **1.0231×**. This concentration matters: it is not a large speedup for
most programs, despite the general source/type-based mechanisms.

Twenty-three medians improve and 22 regress; these signs are not significance
tests. The largest regression is closures64, **3.25%**, followed by lists512
**2.49%** and tree-bitonic **2.31%**, all with byte-identical output. The short
fold has changed output and regresses **2.12%** (14.191 → 14.491 µs). Its ordinary
fallback guard gained an `arrayViewHostGuard` check; that static difference does
not prove the check ran in the timing path. No regression is silently discarded.

The candidate beats TypeScript on three points. Morning, scalar-zero, RLE,
Map/Set and Evening still cost approximately **49–62× TypeScript time**.
Maximum half-window drift reaches 36.15% for the baseline and 47.87% for the
candidate on Evening; small effects require care. The
[complete results](results.md) retain all medians, ranges, drift, identities and
weightings. This corpus informed development; it is not an untouched holdout or
a claim of typical-program or universal parity.

The [initial design](../../design/phase48/composable-representations.md) was
committed and pushed as `bb9480c` before new target execution. Root integrates
and runs guarded jobs; workstream owners prepare source, controls and reviews.
The [composition receipt and source review](combined-rnfa-integration.md) identify
the exact frozen inputs and 14 changed files. Runtime fragments are unchanged.
[Mechanism explanation](../../docs/self_hosted/phase48-representations.md)
connects these source changes to their proof and representation boundaries.

## Preserved baseline and measurement boundaries

The original full baseline is **2.919418× equal-point / 3.995808× equal-source**
pinned TypeScript execution time, over 45 points / 23 source programs / 669
fresh samples. Those are historical context, not denominators for isolated
fresh screens. The maintained corpus informed development and is not an
untouched holdout or universal parity test. Six severe outliers have different
causes; isolated gains cannot be multiplied or averaged into a campaign result.

Baseline API is
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`;
runtime is
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. Public descriptor
mutation, partial application, demand/errors, aliases and bounded-stack
contracts remain. No target migration or upstream repin is planned.

## Completed isolated outcomes

| Slice | Executed qualification | Fresh isolated screen / limit |
| --- | --- | --- |
| R: composite results | Checked composite01; 30 independent values, 6 boundary traces; maintained row.probe executes 1 fast / 0 fallback | Generic row 385.457→30.6253 μs, 12.586×; local pair neutral. Three-round row drift remains explicit. |
| N: String.append | Checked native01; 7 ordinary points, 1372 complete values, 18 boundaries; maintained Unicode executes 178/706 concats | Unicode16/64 gain 1.215×/1.520×; Morning executes zero and is neutral. |
| F: finite F32 literals | Checked float01; 22 bit-pattern controls, 408 scalar observations, 17 host/view boundaries; numeric executes 769/3073 specialized writes | Numeric1024 gains 1.081×; Numeric256 nearly neutral. Mandelbrot/Symreg emit identical baseline modules and do not activate this slice. |
| A: typed effects and literal handles | Arrays02: 115 values / 14 boundaries / 16 entry-refusals; literals02: 40 / 26 / 29; old U32 allocator mutation repair executes. Loop-qualified arrays03 literals: 96 / 41 / 47 pass. | Initial acyclic Evening literal entry regressed 34.91%; successor requires existing loop work and refuses those acyclic entries. No broad typed-array speed gain claimed. |

Canonical source identities and host guards remain part of each slice.
“Private” or fewer emitted constructor expressions does not guarantee zero
machine allocations. Public handles, final result shells, string storage,
arrays, generic fallbacks and some continuation state remain necessary.

Exact source/image identities, sample ranges, drift and limitations are in
[composite results](composite-results.md), [native values](native-values.md),
[private F32 literals](private-f32-literals.md),
[typed array effects](typed-array-effects.md), and
[loop-qualified literal handles](literal-array-handles.md).
The prior saved-output numeric experiment remains preserved as motivation;
its 1.180× large-point result is not the checked production screen and is not
pooled with it. Original fixture/parser and controller failures also remain.

## Excluded or deferred work

Higher-order H02 passes 26 complete oracles / 39 boundary observations with
six ordinary fixture entries. Its measured-corpus reach is weak: Morning needs
an unsupported matched recursive factory, while the existing closure points
already select the older specialized path. A fixture pass does not justify
406 lines of broad integration. See [function flow](higher-order.md).

Private aggregate V03 passes synthetic and source controls and actually removes
RLE tuple constructions. Its four-point screen is mixed and mostly flat or
slower; fewer shells carry wider scalar transport and continuation frames.
It is excluded from RNFA, along with the separately measured flat-vector
alternative, which also failed to demonstrate useful gains. See [aggregate transport](aggregate-transport.md).

The allocation-free raw-entry guard passes its audit, but gains only 1.039× at
128 steps, is adverse at 4096 (0.993×), and is nearly neutral at 8192 (1.002×).
It is deferred. Optimized-body-only host-footprint narrowing is rejected because
the original generic call/forcing path may observe the omitted hooks. No mutable
host permission is cached and no input-specific threshold is introduced.
See [entry outcome](entry-profitability.md).

## Preserved combined acquisition failure

The combined RNFA02 checked build passed, but its first maintained local-row
corpus acquisition failed with a Node 1 GiB heap OOM after 35.78 seconds.
The process reached approximately 1.19 GB RSS while system available memory
remained approximately 26.8 GB. This was a bounded compiler-process heap OOM,
not a system/session OOM; the campaign nevertheless includes a real OOM attempt.
The installed compiler remained unchanged at that checkpoint. No combined corpus pass followed from
the successful build or the isolated component controls.

The corrected RNFA03/04 source rejects non-array/non-erased calls before type
normalization. The same local-row acquisition now completes in 6.13 seconds under
the unchanged heap limit, and direct rejection controls preserve the distinction.
The failed RNFA02 build product and empty-trace diagnostic are retained in
[array admission cost](array-admission-cost.md). This was a bounded subprocess
heap failure, not a system/session OOM.

## Selected semantic qualification

RNFA04 retains selector precedence and original fallbacks. Two narrow F32 leaf
admissions let the proved array graph compose with finite literals. The
[selected semantic receipt](../../selfhost/tools/performance/phase48/evidence/semantic-qualification.json)
now joins all 28 planned qualification entries. It explicitly reuses the earlier count control
executed on the same selected image; it does not relabel another image's result.

All focused controls and all eight maintained suites pass. The fresh backend
census agrees on 81 outcomes: **69 execution passes, eight N/A and four shared
check failures**. The full 3,026-main / 196-broader frontend inventory remains
historical unchanged-frontend evidence. These overlapping inventories are not
added into a fabricated conformance total. Native IO.args remains a known gap;
GPU execution and independent proof validity remain unestablished. This is a
checked B1 derivative, not a new self-emitted fixed point.

The [source reconciliation](source-reconciliation.md) preserves all 16 affected
live preimages and restores the exact 188-file selected source tree. Installation,
42 ordinary/relocated CLI checks and portable replay follow the separate
[release recipe](release-plan.md).

## Costs and lessons

The selected compiler contains **23,660 physical / 19,489 code Bend lines,
2,673 definitions, 87 types and 92 modules**. Relative to array06 that is +406
physical lines (1.75%), +314 code lines and six modules; declared types are
unchanged. The runtime remains byte-identical. Generated libraries change on
16/45 points from seven sources; summed bytes across the 24 distinct source/output
pairs grow 0.72%. See [accounting](accounting.md).

All 18 [compiler requests](compiler-cost-final.md) produce the expected output.
Median requests regress **3.27% for Evening and 4.41% for lexer**. Those two-source
compilation costs are separate from emitted-program execution and establish no
self-compilation speed improvement.

The [RNFA04 literal-loop diagnostic](rnfa04-checkpoint.md) gains **16.372× at 128
iterations and 71.831× at 8,192**. Zero/one calls still regress **30.63% / 18.64%**,
or 0.412 / 0.931 microseconds. The severe prior regressions were reduced, not
eliminated. This additional fixture uses three short rounds and does not change
the primary corpus or its weighting.

The central finding is that a representation must remain useful across calls
and at its public result boundary. Composite-result adaptation unlocks the
existing fast region for generic row; the whole result, including all four
arrays, remains observed. The aggregate-transport experiments also show why
constructor counts alone are insufficient: fewer tuple constructions did not
produce a useful runtime gain after transport and continuation costs.

The admission failure supplies a separate compiler-speed lesson: reject wrong
shapes before expensive normalization. Bend's eager Boolean conjunction did not
provide the short circuit the original predicate assumed. The explicit branch
repair retains the same admitted type contract and passes direct rejection and
positive controls.

The [remaining opportunities](remaining-opportunities.md) prioritize bounded
matched recursive factories with actual hot-entry witnesses, then a demonstrated
aggregate consumer and admissible entry-cost reductions. Broader speculative
passes remain preserved experiments rather than maintained source.

Consumed inputs and failed attempts are retained with the raw campaign.
Compiler source growth, generated-program execution, compiler request cost and
elapsed work are reported separately. The final protection audit confirms all
103 unrelated files remain unchanged and unstaged. No PR comment was posted.

## Published compiler, evidence and time use

RNFA04 is installed with checked API
`6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`
and unchanged runtime
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
The [selected qualification](../../selfhost/tools/performance/phase48/evidence/selected-qualification.json)
joins the exact source/image, semantic gates, 45/669 comparison, 18 compiler
requests, source accounting, 42 CLI checks and portable replay. This remains a
checked B1 derivative, not a new self-emitted fixed point.

The [benchmark guide](../../selfhost/tools/performance/phase48/README.md) provides
20/60/300-second selections, full-corpus batches and separate profiling/static
analysis commands. Both published bundles reopen for all 45 points; the actual
published pair passes the three-point/27-sample smoke.

The [time report](time-use.md) accounts for 3h09m through the final measurement
cutoff, including 60.37 minutes of recorded process occupancy. Unclassified time
includes source work, review, orchestration and documentation; it is not a
waiting-time estimate. Final archive/publication work follows that cutoff.

All raw writers stopped at `2026-10-05T05:10:45.526361+00:00`. The
[verified archive and recovery guide](../../selfhost/tools/performance/phase48/evidence/README.md)
preserve **18,935 files / 454,085,159 logical bytes** in an 84,284,137-byte gzip
stream published in three parts. Every member and the complete original
inventory were rehashed; the ordered parts reproduce the original stream.
The [evidence index](../../selfhost/tools/performance/phase48/evidence/index.json)
binds the immutable receipts, portable bundles and predecessor evidence.
New experiments must use fresh directories, never append to this closed phase.
