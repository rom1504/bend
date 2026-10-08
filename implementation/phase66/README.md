# Phase66: upstream migration and five-metric qualification

**Final07 is installed and verified, October 8, 2026.** The upstream migration
closes all five measurement axes, with no TypeScript-passing JavaScript fixture
that fails Bend in the observed corpus. The complete Node census and scoped Bun
replay yield 1,045 distinct golden passes. Compiler, generated-program runtime,
selected native/Base and installed-release gates pass. The complete raw campaign
is sealed and its [five-part archive](../../selfhost/tools/performance/phase66/artifacts/README.md)
has passed full member verification.
Source freeze `f9667c2` selects checked B1 `bb6c6e2a…`, assembled source
`1b29d5c4…` and actual B2 `0067736c…`. B1/B2 emit identical modules for all 23
benchmark sources, with exact byte mapping for all 45 observer points. The explicit final07
frontend reuse receipt retains all 3,174 exact new-reference observations.

The active upstream is `059266225b77c8ca256ac6b25ee5c21449bab151`, merged at
`af6dfc1` from prior reference `018751270e800bc222a93dad7f257083ee53a5f7`.
Attempt04 compiler timings remain valid for their measured images; they are not
a final07 speed claim. All failed06 and attempt04/05 evidence is retained.
The [compiler qualification](evidence/compiler-qualification07.json) verifies
11,601 input identities; the separate [installed-release qualification](evidence/installed-release07.json)
verifies 594 inputs and installs the selected checked B1. Phase65 release files
remain a preserved prior baseline. Final07 contains 28,490 physical Bend lines
(+94 versus Phase65).

Started October 8, 2026 at 05:02:20 UTC from `ef7c657`. The initial upstream
inventory spans 95 commits. The [design](../../design/phase66/upstream-and-five-metrics.md)
specifies baseline → names/Base/runtime → checked B1 → focused compatibility →
genuine B2 → broad metrics → release. The
[experiment record](../../experiments/phase66/P66-001-upstream-migration.md)
retains the original registration. No new PR comments are authorized.

## Five-axis scoreboard

| Axis | Phase65 historical evidence | Phase66 final07 evidence |
| --- | --- | --- |
| Generated-program execution | No new execution-speed claim in Phase65; retained prior program qualification is separately scoped | 669/669 samples over 45 points/23 sources pass: **1.049282× new TS** with equal-point weighting, **1.046987×** with equal-source weighting. Updated/old Bend is 1.000377× and 1.003712× respectively. Exact B1/B2 emitted-module equality transfers these independently executed output results; equality alone is not timing. |
| Checked B1 compiler latency | Equality-derived checked B1 `3a7fedb7…`; B1 and B2 are different roles | Final07 `bb6c6e2a…` passes 207 exact-output workers across 23 sources: **1.402065× new TS** for compilation and **0.982634×** including imports/API loading. Compilation is +0.530% versus the paired Phase65 B1 baseline. |
| Genuine B2 compiler latency | `239f7970…`: 1.28945× old TS compilation; 0.969256× old TS imports plus compilation, in the final historical 23-source campaign | Final07 `0067736c…` passes 207 exact-output workers across 23 sources: **1.321100× new TS** for compilation and **0.990389×** including imports/API loading. Compilation is −0.230% versus the paired Phase65 B2 baseline. |
| Conformance | Full selected checked/B2, self-reproduction, host and release gates passed; scopes overlap | All 3,174 frontend outcomes agree with new TS. Across 1,170 JS-eligible fixtures, Node plus exact-module Bun evidence yields **1,045 distinct golden passes**, 123 unprintable-main exemptions, one shared Process.run failure and one graphics deferral; zero TS-pass/Bend-fail cases remain. B2 self-check/reproduction and 23-module/45-point byte equality pass. |
| Simplicity | 28,396 physical Bend lines, 23,284 code lines, 115 modules, 3,269 defs, 642 laws, 119 types | Final07 has **28,490 physical / 23,353 code lines**, 3,282 definitions and 115 modules: +94 physical (+0.331%), +69 code and +13 definitions versus Phase65. All 313 frozen/live source files match; see [final census and scope](simplicity.md). |

The historical 23-source numbers retain the old TypeScript pin and the prepared,
fresh-process request scope in the [Phase65 report](../phase65/README.md).
The final07 [B1](evidence/b1-07-broad.json) and
[B2](evidence/b2-07-broad.json) campaigns each have 23 sources, three rotated
rounds, three compiler roles and 207 successful exact-output workers. Ratios are
geometric means of per-source median first-request compilation times with
prepared inputs. Including imports/API loading uses a different clock;
neither measures generated-program execution. The +0.530% B1 and −0.230% B2
paired old/new differences indicate broadly maintained compilation speed; these
small descriptive deltas are not established optimization gains or regressions.
The [selected performance join](evidence/selected-performance07.json) also closes
the separate generated-program runtime campaign: 669 samples over all 45 points
and 23 sources. Execution excludes compilation, imports, first call and warmup.
The approximately 5% aggregate gap to new TS hides source ratios of 1.619× for
Mandelbrot grid, 1.522× for historical Mandelbrot, 1.503× for historical raytrace
and 1.337× for active raytrace; every other source is at most 1.090×. This finite
corpus does not predict the speed of every Bend application. The near-zero
updated/old aggregate changes indicate retained speed, not a new optimization.

Attempt04's [B1](evidence/b1-04-broad.json) and
[B2](evidence/b2-04-broad.json) campaigns remain historical intermediate results.
Their earlier four-source screens remain [B1](evidence/b1-04-four.json) and
[B2](evidence/b2-04-four.json). Final07 changed compiler bytes to repair full-JS
failures and is measured afresh. Per-source medians, flags and image roles are
in the [measurement report](measurement.md).

The [closed conformance summary](evidence/conformance-final07.json) preserves the
runtime split. Node alone gives Bend 991 passes, 56 platform/oracle failures and
123 exemptions; the TypeScript reference gives 990 passes, six failures, 51
unsupported and 123 exemptions. Exact emitted-module/runtime reuse of the
focused Bun run adds 54 paired golden passes, yielding 1,045 distinct Bend
passes and 1,044 reference passes. The extra Bend pass is the retained NaN-bit
fixture (expected `40`, reference `1`). The shared Process.run failure and
graphics deferral are not passes. This closes the observed reference-passing
candidate gaps without claiming every backend, fixture or proof obligation is
complete.

## Migration checkpoints

| Stage | Required evidence | Current status |
| --- | --- | --- |
| Frozen baseline and upstream inventory | Exact old/new closures, protected paths, source compatibility and short baseline screen | Frozen 299-file source baseline; before-change screen passed 36 exact outputs. Updated-reference screen passed 64. |
| Name/Base/runtime migration | Changed contract list, focused witnesses and prepared-data invalidation | Integrated namespace/Base/direct-runtime changes; 35-provider contract verified. Legacy deadline/half-close corrections and ordinary native ABI repairs have scoped controls; remaining unsupported effects are explicit. |
| New checked B1 | Strict checked build, image/source/runtime/Base/host/export identities | Attempt07 freezes raw checked API `ee717187…` and selected profile7 derivative `bb6c6e2a…`; strict36 and focused Min/wide-record/printability controls pass. |
| Focused compatibility and B1 screen | Complete reference/candidate outcomes and bounded clean latency | Earlier focused frontend 19+54, bootstrap IO19, Base-host11, profile7 and host16 gates pass at their identified images; legacy runtime34 passes. Final07 B1 broad timing and all four actual B1/B2 Base-product/fallback gates pass. Compiler latency, generated-program execution and selected native/Base admission joins are complete. |
| Genuine B2 and reproduction | Checked-parent lineage, own-source acceptance and exact B2/B3 boundary | Actual `bootstrap-b2-07` image `0067736c…` passes fresh own-source checking and exact B2/B3 reproduction. Earlier bootstrap03/04 and checked06 failures remain preserved. |
| Broad five-axis qualification | Fresh measurements, conformance denominator and size/contract audit | Final07 frontend 3,174 exact; 1,045 distinct mixed-runtime golden passes with zero TS-pass/Bend-fail gaps; B1/B2 emitted bytes exact for 23 modules/45 points. All 669 runtime samples pass; selected performance and compiler qualification joins are complete. Source grows 0.331%; no broad simplification claim. |
| Release and preservation | Installed CLI/integrity gates, unchanged protected inputs and recovered evidence | Final07 installed; five release jobs, legacy42/default24/helper5, seven prior installed files and 110 inherited files verified. Root sealed the raw tree; prior evidence preservation and complete new archive verification pass. |

Correctness, measurement and promotion are separate statuses. Failed and
interrupted attempts retain their original receipts; later retries must cite
new identities. An old prepared Base annotation product cannot be used with the
new Base until the exact new content and producer/consumer contract are qualified.

## Closed observations and preserved failures

The [first checked build](../../selfhost/build/phase66/checked-b1-01/build.json)
failed while parsing the native namespace helper; a fresh helper split fixed
that source issue. The [second build](../../selfhost/build/phase66/checked-b1-02/build.json)
completed with checked API SHA-256
`abccec43b566aca2a544b2f2023fe6fbc0f2eb86684061a2b9373643f36671ab`.
Its bootstrap child took 12.295 seconds. This single build duration is distinct
from controlled B1 compilation latency. Its frozen attempt records the exact
new Base, source closure, Node and runtime identities. Preparation of the new
mandatory Base cache succeeded. At that first checkpoint, optional annotation
products were disabled pending the separate qualification now recorded below.

The subsequent [strict-validation receipt](../../selfhost/build/phase66/checked-b1-02/validation-001/report.json)
is incomplete and failing: the selected child exited 1, and the workflow then
reported the missing `selected/candidate.json`. It supplies no passing selected
conformance result. The repaired workflow ran a fresh successor: [attempt03 strict validation](../../selfhost/build/phase66/checked-b1-03/validation-001/report.json)
is complete and passing, with 36 paired observations and zero exact differences.
The [attempt03 build](../../selfhost/build/phase66/checked-b1-03/build.json) binds
raw checked B1 `5f5cd64579eeb6dc24559bd4f00c42c116c8cff489d0740e74207fa9620e5875`
and selected profile7 B1
`1ed7deccc250732402fb3aebda4c0852adacdf983a8bcfe12b12658dfda23094`.
Its bounded build/validation command took 29.283 seconds and peaked at 1.50 GB
process-tree RSS. This is a gate observation, not a controlled latency result.

Closed focused evidence is deliberately scoped:

- [Frontend controls](../../selfhost/build/phase66/frontend-controls01/report.json):
  19 source rows and 54 namespace/display helper observations pass, using an
  append-only diagnostic export of the identified B1. These establish neither
  whole-language checking nor runtime conformance.
- [Bootstrap IO controls](../../selfhost/build/phase66/bootstrap-io-controls01/report.json):
  19 synthetic typed-book observations pass against actual upstream term
  normalization; this is export classification, not parsing/checking.
- [Base-host controls](../../selfhost/build/phase66/base-host-controls01/report.json):
  11 host-unit rows pass, with 35 provider identities pinned. Actual network
  execution and emitted-source behavior require separate controls.

The [host-runtime controller](../../selfhost/build/phase66/host-runtime-controls01/report.json)
preserves 13 passing runtime/wrapper observations, followed by a failure while
loading/checking `marshal_array_depth.bend`: `Maximum call stack size exceeded`.
Its full 16-case gate is incomplete. The failure precedes execution of the deep
marshalling program. Its trace localized recursive `String.cmp`/`String.cmp.fin`
in the raw checked image during prefix loading. The separately identified
profile7 attempt02 derivative `758d9d3c…` passed the complete successor
[16-case host/runtime gate](../../selfhost/build/phase66/host-runtime-controls02/report.json),
including that source fixture. This closes the focused converter gate for that
image; attempt03 qualification must bind any reused evidence explicitly. The
[host report](host-runtime.md), [bootstrap report](bootstrap.md), and
[conformance report](controls.md) track these separate boundaries.

The [profile7 controls](../../selfhost/build/phase66/profile7-controls01/report.json)
pass 151,084 primitive comparisons, six exact historical replays, 19 refusal
controls and 42 actual choice cases. Profile7 retains native string equality
and literal choices without applying the historical array-argument tail rewrite
to the new unary deferred-call runtime. These focused results do not substitute
for full selected-image semantics or genuine self-reproduction.

The old installed B1 and old TypeScript reference agree on all 3,026 normalized
frontend observations. Four expected later-stage fixture errors occur identically
at the checking-only boundary. This establishes the frozen old baseline, not
new-reference conformance; see the [checked checkpoint](checked03-checkpoint.md).

Independent review of the legacy-effect successor found and corrected overdue
channel matching, overflowing large Node timeout delays, and automatic TCP
half-close. The resulting v3 runtime passed all
[34 controls](../../selfhost/build/phase66/legacy-effects-controls01/report.json),
including three real local TCP/UDP loopbacks. Runtime-unit, mocked-network and
real-network cases remain separately classified; this is not a complete source
emission or backend conformance result. Four timed send APIs and asynchronous TCP failures with an
unknowable unsent suffix retain explicit refusals. These boundaries must remain
visible in backend conformance totals; see [backend report](backend.md).

## Qualified new-Base product permission

The initial denied permission remains visible in the failed/early snapshots.
The selected checked03 API then passed the actual
[owned/product controls](../../selfhost/build/phase66/base-annotations-owned-checked03-01/report.json)
and [custom-Base fallback controls](../../selfhost/build/phase66/base-annotations-custom-checked03-01/report.json).
The producer independently selected 12 products; all matched ordinary annotation
across 99,261 compared pairs. The Map request reused seven decoded products and
matched the full ordinary/public output (101,907 compared annotation pairs).
Numeric and Lexer requested no product body. The comment-only custom Base
created no optional artifact and retained ordinary behavior.

The [integration receipt](../../selfhost/build/phase66/integration-base-annotations01.json)
therefore enables only Base SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`
in host driver `e093483d…`. It preserves request/stop/parent-graph guards and does
not change the product algorithm or cache formats. Explicit preparation can now
create the new-Base optional artifact; ordinary inspection still uses
`backendProducts:false` on a miss. These correctness controls do not measure the
product's speed benefit or transfer Phase65's ablation ratios to the new Base.
Attempt04 freezes the qualified host snapshot. Its genuine B2 `9ded6e94…` repeats the
[owned/custom-Base controls](evidence/base-annotations-b2.json) successfully,
with independent lineage, input and result auditing. The final07
[four-way Base audit](evidence/base-host07.json) independently rehashes 735 inputs
and closes actual owned/custom controls on both selected B1 `bb6c6e2a…` and
genuine B2 `0067736c…`. Both reproduce all 12 products exactly, reuse seven Map
products, avoid Lexer/Numeric body reads, and fall back without optional calls
for custom Base. These are correctness gates, not an H2 speed attribution.
Installed-release admission is separately complete; its receipt is linked below.

## Selected native and installed-release admission

The [selected native admission](evidence/native-backend07.json) passes fresh
native3 execution on final07. Earlier source19/native16/mock7 controls retain
attempt05 provenance and transfer only through exact unchanged emitter,
frontend and native-host closures plus separately checked common-entry evidence.
Thirteen native methods remain explicitly unsupported. This is scoped CPU
backend admission, not full native/GPU coverage or new timed-effect support.

The [installed-release receipt](evidence/installed-release07.json) passes all
five release jobs, legacy42, default24 in ordinary and relocated layouts, and
helper5. It binds selected B1 `bb6c6e2a…`, source `1b29d5c4…`, the direct runtime,
graph helper and 48 frozen native files. Before/after installed identities,
seven previous release files in both history and raw copies, and 110 inherited
files are verified. The genuine B2 remains a separately qualified image;
installation selects the equality-derived checked B1. This receipt does not
stand in for historical-tree preservation or final archive verification.

## Recorded campaign time

The [final time account](evidence/time-account-final.json) spans 05:02:20 to
08:32:27 UTC: **3 h 30 min 7 s** through root-declared release-target closure.
It retains 2,173 closed supervisor receipts, including 20 nonzero or incomplete
receipts, and counts overlapping/nested intervals once. Recorded target-tree
occupancy is 110.53 minutes (52.60%); the remaining elapsed time is unclassified,
not measured idle time or model work. Later reporting, archival, commit and
push work are outside this cutoff. Archive verification finished at 08:46:39 UTC,
**14 min 12 s after release-target closure** (3 h 44 min 19 s after campaign start).
That later documentation/publication interval is outside the 3 h 30 min account;
subsequent commit/push time is not included. This is campaign accounting, not a
compiler speed benchmark.

## Reproduction contract

All new acquisition, builds, controls and timing outputs belong under
`selfhost/build/phase66/`; historical raw trees stay closed. Completed build and
control receipts above identify their command inputs. The final command index
and durable archive must retain the exact baseline and target commits, checked
attempt directories, B1/B2 roles, source manifests, host/runtime/Base hashes,
helper closures, Node binary, configuration files and every output directory.

Root alone starts supervised target executions, serially on CPU3 with a 1 GiB
heap, 2 GiB target-tree RSS limit and 4 GiB available-memory floor. Review and
source/data work use CPU0; no diagnostics overlap clean timing. The final evidence
index preserves generated bytes and failed attempts and identifies explicit
durable prerequisites. The archive was verified by reopening all members; reports separate
preparation/import/request/program-runtime clocks.

## Closed evidence and archive

The [prepared closure method](../../selfhost/tools/performance/phase66/CLOSURE.md)
keeps final simplicity, protected-input verification, installed-release admission,
writer acknowledgements and archival as separate steps. Its archive successor
uses parts of at most **50 MiB**, reopens every member, preserves empty
directories and permission modes, and rejects traversal errors and symlinks.
Independent source review also corrected the inherited single-part assumption
for Phase65's split archive and absolute-only assumption for previous installed
paths. The [prior-evidence receipt](evidence/closed-evidence-preservation.json)
verifies all 17,894 Phase65 raw files, both old archive parts and every member,
110 inherited files, seven prior installed copies and 299 baseline-source copies.
The initial ordering-check failure and its traceback remain preserved; the
reviewed one-line successor passed without changing historical bytes.

Root then sealed all raw writers. The [final archive manifest](../../selfhost/tools/performance/phase66/artifacts/manifest.json)
passes with **119,393 regular files**, **22,049 directories** and
**1,159,498,010 uncompressed bytes**, captured in **241,587,423 compressed bytes**
across five parts of at most 50 MiB. Every member was reopened and verified for
path, type, mode, size and content; original inventories and protected inputs
were rechecked. The complete compressed stream SHA-256 is
`8fac8f978921e4e932e40f714a75ade5058f4a4cc2200b8bded16c6cb76c90ec`.
The [artifact guide](../../selfhost/tools/performance/phase66/artifacts/README.md)
provides verified restore instructions and links the reviewed
[archive-v2 derivation](../../selfhost/tools/performance/phase66/archive-v2.derivation.json).
No target was rerun during preservation or archival.

The [prerequisite inventory](../../selfhost/tools/performance/phase66/archive-prerequisites.json)
binds historical capsule metadata and recorded external Node/upstream/Clang
requirements. Those dependencies remain explicit; no self-contained replay claim
is made. All failed attempts, full outputs and earlier closed raw trees remain
preserved. The [compiler guide](../../docs/BEND-IN-BEND.md) also trims 61 lines
of duplicated historical Phase53/56/61 prose into linked reports while retaining
current operational guidance, headings and command blocks.

## Current limitations

Compilation alone remains 40.2% slower than new TS for checked B1 and 32.1%
slower for genuine B2 in these prepared fresh-process campaigns. Generated
programs average about 5% slower in the measured corpus, with larger renderer
gaps. These are separate optimization opportunities. Maintained Bend source
grew by 94 physical lines; the migration does not establish lower concept count.

Selected07 native admission is complete, with 13 methods still explicitly
unsupported. Legacy effects retain four timed-send refusals and the ambiguous
asynchronous TCP suffix limit. JavaScript conformance retains one shared
Process.run golden failure, one graphics environment deferral and 123 upstream
unprintable-main exemptions. The scoped counts do not establish universal
language/backend conformance or mathematical proof validity. Historical-tree
preservation and the complete new archive pass their separate integrity gates;
they do not extend semantic coverage.

The [final07 frontend reuse receipt](../../selfhost/build/phase66/conformance-final07-frontend-reuse.json)
binds 3,174 exact outcomes and a fresh strict36 gate. The actual attempt07
[fresh own-source check](../../selfhost/build/phase66/selfhosting07/self-check/report.json)
and [exact reproduction](../../selfhost/build/phase66/selfhosting07/fixed-point/report.json)
are separately complete B2 gates. The [source census](evidence/simplicity-final07.json)
and [313-file source audit](evidence/source-freeze-final07.json) establish counted
bytes and identities. Final evidence retains earlier attempt04/05, failed06,
all failed attempts and full outputs, and the captured Bun toolchain. Final07 is
installed, raw writers are closed, and the reviewed archive is complete.
