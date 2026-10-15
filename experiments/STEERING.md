# Active frontier: Phase90 native self-hosting and release complete

[Phase90 report](../implementation/phase90/README.md) and
[verified summary](../implementation/phase90/summary.json): native07, built from
unpatched native-emitted C, reproduces all38,614,882 C bytes exactly in164.322s.
Independent genuine JS B2 agrees, taking51.672s on the same frozen source/runtime.
The native image is d7c7a479…, source d04ad79c…, C dae071f0….
This is a C fixed point for that tuple, not ELF equality or a compiler proof.

Installed JS is refreshed genuine B2 284f6e9b…, checked B1 6bf8e093…, source
4ffae2a3…. Fresh frontend36, driver8, own-source check, exactB3, release integrity,
legacy42/default24 installed/relocated pass. The old source/release mismatch is
resolved. Native8live/cache,2negative,4program execution,6publicCLI gates pass.
The public native entry remains canonical-path single-Base/nineeffects/oneCPU;
use the [native guide](../docs/self_hosted/NATIVE_HOST.md) and restoration capsule.

Linear builders, indexed fork closure, stack-safe traversals and removing final
body indentation close the self-emission stall. All45 formatting preprocessing
comparisons pass. LLVM callgraph expansion of the39,642-entry dispatch table
at15,296 return sites caused the optimized build memory explosion. A pure host
noinline accessor for FID_ENTER>=4096 fixes it: finalO2 builds308.201s,3.886GiB.
Keep small/GPU dispatch unchanged; O0 attributes now follow upstream's guard.
All45 O2 runtime preprocessing comparisons and4threshold/O0/O2 controls pass.
Do not retry memory increases, O1 no-inline flags, or redundant template scans.

Final six-source/two-round screen:36complete-C checks pass. Native GM0.678x TS-Bun
process /0.380x request; JS B2 1.367x process /0.891x request. Native wins5/6;
Map remains1.706x process/1.642x request, Base decode~135ms. Prepared Base and
worker overhead differ; no broad/algorithmic/publicCLI parity claim. Screen46.958s
including setup/final verification. Full native self remains3.180x JS B2 from
separate observations. No new generated-program timing campaign; retained C
preprocessing identity protects45selectedpoints.

Next: native07 Map and Base-decoder profiles with tiny complete-product controls;
then a controlled same-source upstream-C versus own-C native build comparison.
The older native B1 used upstream C lowering; do not call old~58ms Base timings
or0.492x process ratio a matched comparison to current native07. Improve measured
regions before another large rewrite. Extend portability/imports/effects under
separate qualification. Production32,692physicalBendlines/132modules (+101),
runtime+7netlines. Finite historical conformance/API gaps remain.

All targets ran serially under guards; agents prepared/audited offline. Initial
legacy smoke hit sandbox-dependent Node pipe EPERM; unchanged approved replay
outside sandbox passes and both diagnostics remain. Evidence01–05 plus separate
native request assets/CLI capsules retain completed inputs and failures. Preserve
unrelated Phase6/68 work. No PR comments without explicit user instruction.

# Historical Phase89 frontier

[Phase89](../implementation/phase89/README.md) qualifies native B1 `8bacae26…`
with consume-once NC_Code and ordered body chunks. Map cold/fifth request time
falls28.0%/33.7% in paired native trials; append work39.8%, allocation calls29.4%.
Eight live/cache gates,45 exact-C points and10 launcher controls pass. The nine
providers include file IO without broadening scalar/array permission. Use the
[versioned native launcher](../docs/self_hosted/NATIVE_HOST.md).

Final six-source cold process screen versus TS/Bun wins5/6, geomean0.4924×,
Map1.385×. Native prepared Base differs from TS source preparation; no backend-only
or broad parity claim. Fifth Map/Lexer remain3.625×/2.152×, Numeric0.548×.
Use Bun for upstream reference, Node for our JS B2. Same native changes regress
ordinary JS B1 requests4.11% combined/1.15% owned-only, so canonical modules and
installed Phase82 B2 remain unchanged. Production32,591physical lines/132modules.

Full native self-emission hit600.022s/noC at1.01GiB RSS, not OOM. No native B2.
A60s prefix has one overrun and remains strictly unqualified: exploratory physical
samples identify30.42% shared-string equality ownership,9.40% definition-name
projection, only two append leaves. Start with tiny shared-observation/lookup
scaling controls, not another output builder or blind600s attempt. A False-first
string helper already failed upstream match-order checking in0.921s; preserve it.
True borrowing needs a lowering/representation change, not argument shuffling.

All installed16 Phase82 artifacts match and ordinaryCLI smoke prints42, but
explicit release verification fails on three Phase88 source changes. Read the
[release audit](../implementation/phase89/release-status.md); do not call current
checkout release verification passing or silently rewrite the old manifest.

Root runs targets serially under RSS/memory/disk guards; bounded agents only
prepare/audit. Use immutable evidence01/02/03, including rejected attempts and
native restoration selection. No PR comments without explicit user instruction.

# Historical Phase88 frontier (superseded below)

[Phase88](../implementation/phase88/README.md) repairs Map with shareable Data
observer frames and integrates the linear builders. All45points/23sources match
independent B2 C and expected execution. Consuming native compiler equality
cuts live request time22.4–32.3%; prepared Base falls~3.1s→58–59ms. This is a
separate usable native B1, not native B2 or full host support. Current source
32,591physical lines/132modules; installed JS Phase82 remains unchanged.

Six-source paired cold process medians beat TypeScript in5/6cases; Map is1.76×.
Repeated Map request5 remains6.46× TS; Lexer1.85×. Native02 physical profiles
identify30.7% append/ownership,11.6% retained child NC_Code body destruction,
7.7% discarded choice closures. These are cost budgets, not additive forecasts.
Start with owned NC_Code field consumption at the measured general match
composer; complete-product and exact-C controls precede another full build.
Then test output chunks flattened once, and operation counts to distinguish
repeat work from locality. Do not claim a leak or tweak the allocator without
causal evidence. Preserve fuel/error/fresh/order and both JS/native execution.

Use the [native launcher](../docs/self_hosted/NATIVE_HOST.md),
[fast-loop methods](../selfhost/tools/performance/phase88/README.md) and sealed
failed attempts. Root alone runs targets serially under RSS/free-memory/disk
guards; bounded agents audit independent source/mechanisms. General imports,
foreign effects, relocation and native B2 reproduction need separate gates.
No PR comments without explicit user instruction.

## Historical Phase87 frontier (superseded by Phase88 above)

### Phase87: make the native compiler safe and linear; Phase82 installed

[Phase87](../implementation/phase87/README.md) profiles the exact Phase86 native
B1 and demonstrates a general linear-text candidate in an isolated source image.
Native means the compiler request itself runs as C machine code, with no JS
runtime bridge; it is still upstream-built B1, not a native self-produced B2.
Production132 modules, upstream and installed JS-hosted Phase82 stay unchanged.

Five-request Lexer profiling:67.39% String.append leaf samples,10,983 samples,
zero overruns/drops and essentially100% process CPU coverage. Linked native
strings make growing-prefix indentation/join/segment builders quadratic. The
isolated two-module patch makes those builders linear;21 edge assertions pass
in raw JS/native and complete output C is checked against independent B2.
Use the report for measured paired results and limits; no failed-family-excluding
aggregate establishes parity. Base remains~3s and startup-dominated sampling
has62.55% term_drop/span_fade leaves. Profile actual request phases/callers before
changing the runtime allocator or assigning those samples to a particular pass.

Map's failure is now minimized: eager closures duplicate an affine continuation
in unsafe observer source. Law/inline-signature pairs emit identical C/JS;
signatures do not repair it. Direct match/threading works for exclusive use,
but symbolic analysis genuinely reuses the continuation. The scoped repair is
8 Data frame constructors plus a dispatcher in observer-analysis.bend, preserving
fresh/fuel/first-error/recursive-tail behavior. The full repair is **not yet
implemented**. Never relax rfc_wrap's closure/task rejection. Tiny controls run
in~23s versus~259s to acquire/build a full compiler image.

Next: repair observer continuations with exact analysis-product controls; integrate
linear builders with broader native/JS conformance; then native prepared-Base
persistence and ownership caller profiling. Native full host/import/effect support
and native B2 self-reproduction remain separate gates. Repeated Lexer slowdown
is reduced but not proven to be an allocator locality bug; no cumulative nested
redirect or linear free-list search exists in the inspected runtime. Do not
claim a memory leak/OOM from timing growth. Preserve Phase86 baseline/capsule,
its exact emitted runtime chunks, and the installed JS development path.

Root runs targets serially. Ordinary2GiB RSS guards; full Clang only6GiB with
16GiB available-memory headroom. Two bounded source-audit agents, no PR comment.
Read the [methods](../selfhost/tools/performance/phase87/README.md), exact retained
failures and [Phase86 feasibility report](../implementation/phase86/README.md).

## Phase85 findings retained

[Phase85 report](../implementation/phase85/README.md) directly attributes first
request CPU by V8 thread, beyond inspector samples. Extra compilation CPU explains
96.1%/64.6% of Numeric/Functions65 observed gaps in single instrumented pairs:
main first-use compilation and TurboFan dominate the excess; Maglev is similar.
This is not a removable-time forecast. B2 still benefits greatly from optimizing
tiers. Prioritize general generated-JS first-use cost: function work, bytecode,
temporary lifetime and optimization-unit shape, with complete-request falsifiers.

Three-round four-source cold/fifth ratios1.394×/0.989× demonstrate process reuse,
not steady-state or every-source parity. Maglev ceiling cuts B2 cold time21.5%
but worsens fifth17.5%; upstream benefits more cold. Lexer-only TF exclusion saves
only3.3%, despite large elapsed job durations. Largest measured SCC bytecode20,700
is below61,440; do not raise the size limit or revive legacy descriptor guards.

Paired CPU3 versus CPU2,3 cuts first-request time38.8% B2/34.7% TS; fair relative
ratio remains1.334×. Use explicit two-CPU development diagnostics for faster
iteration while retaining declared one-CPU qualification. Cold compilation
parity still requires a compiler improvement, not unmatched hardware or warmup.

Reject the lexer-only IIFE→ternary saved-image prototype: common-path80-byte
context allocation disappears and all120 C comparisons pass, but cold ratio
0.9951/fifth1.0485. Bytecode/register usage grows; allocation reduction alone
is insufficient. No production source/image change. Overall623 C outputs pass,
160 serial guarded jobs use761.8s, peak480.3MiB; no timeout/OOM. Raw failed filter
selectivity and initial missing timeline marks remain preserved. Three bounded
research/offline agents, root-only targets, no PR comments or quota claim.

The following Phase84 conclusions remain relevant counterexamples to speculative
opportunity budgets and small added-product rewrites.

[Phase84 report](../implementation/phase84/README.md) tests four actual Bend
prototypes. Paired annotation/erasure adds278 lines and is neutral on B2
(1.0043× baseline); reject. Its Numeric profile removes33.5 ms from preparation
but adds14.9 ms to the producer:18.6 ms net, not a25% mechanism. Full annotated
definitions and NR_Request values match on four sources; six focused owned
comparisons pass. This was partial fusion, not removal of Ann/its consumers.

Defer fail-fast/refusal-binding/report reuse: four-source B1 screens show only
0.5%/2.2%/2.1% savings with variation and local effects. Binding preflight hits
28/4116 Map checks,1/338 Numeric, zero on simple held-outs.17 report controls
pass. Do not repeat these small shortcuts or pair construction as a claimed
parity architecture. A future representation experiment must replace actual
world/preparation/consumer work and demonstrate a complete-request budget.
88 clean C outputs remain exact. Four checked B1/frontend36 builds, one genuine
experimental B2/eight-driver comparison, two profiles and counter diagnostics
complete.120 guarded jobs take618.6 s, peak1.60 GiB; four source/harness failures
are preserved, no OOM/timeout. Production is restored and release verification
passes. [Phase83 investigation](../implementation/phase83/README.md) remains
relevant background; its379 ms Map opportunity ceiling was not a measured gain.

Installed genuine B2 `098320e8…`, checked B1 `8a400725…`, source commit `070064e`.
[Report](../implementation/phase82/README.md), [qualification](../implementation/phase82/qualification.json),
[release](../implementation/phase82/release.json), [usage](../docs/self_hosted/NATIVE_COMPILATION.md).
Paired45 fresh C requests improve5.10% B1/6.15% B2 against simultaneous Phase78:
1.76295×→1.67299× B1 and1.41542×→1.32836× B2 upstream. Historical Phase78's
qualified1.732×/1.382× remains a separate run. Imports, explicit Bend Base,
Clang and execution are excluded; reports enabled, no reused process.
Held-out small/functions65 B2 improve20.7%/15.1%, to0.826×/1.483× upstream.
Cold parity still needs24.7% less B2/40.2% less B1 time on the three-source loop.

Keep canonical runtime chunks produced by the Bend scanner and host-verified by
exact asset/runtime hashes. Prefix/payload marker fallbacks and raw/custom API
behavior stay intact. The owned annotation merge carries its exact source bound
instead of scanning the mirror index/declaration list again. No semantic host
compiler or new optimizer framework. +69 physical/+53 code Bend lines,132 modules:
32,540/26,576 lines. Source/driver equal selected compiler04; compiler05 deferred.

Reject the extra private erasure consumer despite exact preparation products:
only1.68% B1/1.38% B2 over compiler04. Preserve both patches and actual B1/B2
images. Full per-function representation replacement remains open; do not label
this small consumer experiment a completed IR fusion. Two selected B2 profiles
show no template-scanner samples; source processing, report/index work,
normalization and native planning remain. Read the current report before a rewrite.

All159 clean experimental requests retain C/reports. Renderer250/transport5,
frontend36/native100/raw31/new14/word10/heldout2/threads28, B2 driver8,
self-check/B3 and installed/relocated42/24/session5 pass. Both stages emit all12
benchmark C files exactly; all23 JS sources (45points) remain byte-identical.
Reuse prior native1.067× upstream execution evidence, not a new runtime clock.
Seven reference native failures/thirteen broader native API gaps remain explicit.
264 guarded jobs take1,363.5s; peak RSS1.61GiB, no OOM or timeout. No quota claim.

Prior Phase79–81 findings follow; those phases left Phase78 installed at their
completion. Their raw evidence and rejected prototypes remain historical inputs.

[Phase79 report](../implementation/phase79/README.md): whole-library and selected-worker
prepared products pass exact-C screens but save only 3.49%/5.15% against their
ordinary modes, below the 15% discriminator. Added preparation is 3.3 s and the
artifact is 2.94 MB. Two profiles confirm annotation/erasure savings offset by
decode, GC and context work. Non-IO held-outs are unchanged. Reject both, stop
observer-cache expansion, and restore exact Phase78 production source. Release
verification passes after rollback. All prototypes/failures remain preserved.

[Phase80 report](../implementation/phase80/README.md): whole/live-only checker type
retention saves0.6–1.3% on the IO-based B1 screen but the live-only variant regresses
small17.4%/functions65 8.9%; reject and restore. Exact-argument counters expose
repeated different-binder occurrence walks. List and integer-set body summaries
pass15,678 generated comparisons each; final set summary saves2.15% on45 fresh
requests, with small unchanged/functions65 1.31% slower on18 held-outs. Defer
both summary patches. All147 clean requests and four diagnostic requests preserve
C. Five checked-B1/frontend36 builds pass; no prototype B2 or release claim.
Production source/driver/dist are unchanged and final release verification passes.

[Phase81 investigation](../implementation/phase81/README.md) adds54 clean requests,
15 CPU profiles,3 allocation profiles and5 internal-region requests; all77 outputs
remain exact. Unchanged-source fresh ratios1.722x/1.309x are a new diagnostic
screen, not an improvement over the qualified1.732x/1.382x. Functions65 stays1.72x.
B2 final native-stage time is near upstream emission on IO sources, but has large
fixed cost on small sources. Template scans cost43–66ms, five freshness-bound
queries25–50ms and three final-book constructions17–19ms in separate diagnostics.
These overlap other stages and are not additive savings. Numeric sampled
allocations:B1 538MB,B2 138MB,TS148MB. B2 text helpers account for about50MB.

The Phase81 recommendation was fixed text/book/report removal, then a per-function
native representation that replaces annotation/erasure/reconstruction and feeds
multiple consumers. Resolve symbols once where measured. Cold parity still needs
about42% less B1 /28% less B2 time on the qualified three-source loop. Combined
25–35% B2 reduction is a target to falsify, not a measured forecast; held-outs may
need more. Whole typed graphs, eager products, generic memo tables and node IDs
alone have no demonstrated large net gain. Read Phase79/80 before repeating them.
New primary-source research compares V8, Cranelift, Go, Zig, LLVM and Lean. No
production edits, candidate promotion or implementation gain in Phase81.

One guarded CPU3 tree,2GiB RSS/4GiB available floor,Node1GiB heap/4MiB stack.
Phase83 agents were explicitly authorized; no PR comments. Preserve unrelated inherited Phase6/68 work and all
sealed historical evidence. Phase78–80 evidence is sealed and linked from the respective reports.
Historical frontiers remain in Git history and the linked Phase73–77 reports;
consult them before repeating a rejected hypothesis.
