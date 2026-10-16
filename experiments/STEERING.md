# Active frontier: Phase102 composable native lowering

[Design](../design/phase102/ambitious-native-campaign.md) ·
[Report](../implementation/phase102/README.md) ·
[Compiler guide](../docs/self_hosted/phase102-native-lowering.md).

General constructor loops and scoped direct workers now recover large text wins
on the existing representation. Owning-observer forwarding and a measured inline
budget make the large source-index application about twice as fast as installed
B2 and close to upstream; private unique-cell reuse further improves rendering.
Three actual Bend-produced apps pass50 inputs/165 executions; focused controls
pass144 executions. Keep the distinct per-workload ratios and finite scope.

The425-line source-profile candidate is reproducible and its upstream-built
native B1 has emitted its own C with exact independent diagnostics. Native B2 and
full image gates are in progress. Do not equate API/application evidence with
native release admission. Phase98 native and Phase90 JS remain installed.

Continue the serial guarded queue, reuse exact products, and qualify the frozen
candidate once. Probe remaining observer-result allocation separately. Global
chunk storage, identifier compression and PCH have not earned integration. Keep
the failed/inactive variants and avoid repeated self-build timings without a
decision they would resolve.

# Previous frontier: Phase101 ambitious native text prototype

[Ambitious agenda](../design/phase101/ambitious-native-agenda.md) ·
[Report](../implementation/phase101/README.md) ·
[Fast experiment loop](../selfhost/tools/performance/phase101/README.md).

Keep the architectural goal: useful applications faster than upstream and short
complete development loops. The first CPU-only chunk String/append prototype
makes full rendering take 0.585×/0.603× baseline time at one/four workers and
0.763×/0.894× upstream time, with about one-third the memory. These are generated-C
interventions on saved installed-B2 output, not a new compiler or native chain.

Do not promote globally: indexing is 1–3% slower and graph planning 4–6% slower.
Storage alone was insufficient; sparse chunks regressed badly; bounded prefix
packing and removing append continuations produced the gain. Final controls pass
90 independent String executions, all 50 app inputs in 165 executions, and 108
repeated-screen executions. Full U32 Char, aliases, arrays, Unicode and parallel
output are covered finitely, not proved universally. GPU is explicitly excluded.

Accepted unchanged-program profiles identify renderer append/reconstruction and
indexing's large saved continuations. Next test cached typed cursors/adaptive
small strings, and ablate iterative append on old storage. Then connect winning
operations through certified Bend emitter lowering; pursue whole-function typed
state to address indexing. The two-application speed gate is unmet, so no full
compiler rebuild or new compiler-latency claim is justified yet. Keep the Phase98
native and Phase90 JS releases unchanged and preserve Phase99 separately.

Root owns serial guarded targets; offline reviewers prepare/review. Reuse pinned
fixtures and checked baseline products. All variants, rejected captures and
failures are in the verified evidence capsule. No PR comment was posted.

# Previous frontier: Phase100 useful native applications

[Applications](../selfhost/apps/README.md) ·
[Report](../implementation/phase100/README.md) ·
[Fast application loop](../selfhost/tools/performance/phase100/README.md).

Usefulness and complete application workflows now take priority over a bootstrap
parity score. Three standalone safe Bend apps cover source indexing, complete
image rendering and dependency planning. Fifty distinct inputs pass 318 executions;
all three native B1/B2 C pairs agree. On selected inputs, graph planning takes
0.33–0.36× upstream C time, text indexing about 2.15×, and rendering about 1.35×
sequentially with about 2× acceleration on four physical cores. These are different
applications and clocks, not one universal performance ratio.

Clang builds take 2–3.5× upstream time for the larger emitted C. Prioritize native
application imports/error-status usability, profile text-heavy applications before
general String/ownership work, and investigate generated-code/build cost. Keep
the graph win and exact parallel image output as constraints. Indexed graph
algorithms are a separate app-level opportunity. Frozen-input/oracle replay gives
a roughly 10-second substantial renderer comparison; avoid repeating Python
oracle generation or rebuilding a compiler for ordinary iteration.

Phase98 remains the installed native release and Phase90 the separate JS release.
The Phase99 candidate's 105.2-second self-compilation versus 146.5-second matched
baseline remains experimental, with broad qualification deferred. Phase100 changes
no compiler source/image/selection and makes no new whole-language or formal proof
claim. Read the report for all timings, limits, retained failures and evidence.

# Previous frontier: Phase98 native optimization and useful laws

[Report](../implementation/phase98/README.md) ·
[Machine-readable results](../implementation/phase98/results.json) ·
[Native usage](../docs/self_hosted/NATIVE_PHASE98.md) ·
[Next cycle](../implementation/phase98/next-cycle.md).

The selected native profile combines held String equality, fused tag comparisons,
scoped observer permission and a lazy ancestry refusal that repairs divergence.
Native B1 full self-compilation falls 135.465→104.821s (one comparison); native B2
paired medians fall 150.471→140.988s. Four balanced six-source screen rounds give
request ratios 0.81067 and 0.93924 respectively. The native entry defaults to B2;
public CLI, complete self-C and actual missing executable restoration pass.

Both stages pass 69 native conformance cases and three exact rejections; 31 native
exclusions remain. Broad45 behavior passes. All 45 Phase93 runtime-batch C products
are unchanged, preserving the prior 44 measurable-point 1.115× upstream-C result
without claiming a new timing campaign. Canonical source and installed JS remain
unchanged. The selected native profile adds 79 lines; the +525-line neutral dispatch
rewrite and unmeasured planning-cache/redirect variants are excluded.

Thirteen distinct accepted statements (eight public/five support) connect actual
selected helpers to frozen contracts. The wider historical Phase98 catalog has
56 names, not 56 final-image obligations. Independent bad-helper challenges and
a valid-refactor proof repair demonstrate useful contracts with explicit limits:
the stronger internal-result law catches a fault outside the public-Bool finite
suite's scope; this is not evidence of a missed identical public contract. The
actual eager-recursion failure required native controls and physical profiling.

Fresh complete zero-loss B1/B2 profiles show more absolute ownership work in B2
despite a lower share. Exact append/reconstruction mapping rises 4.86→13.44 sampled
CPU seconds; kc cleanup is roughly unchanged. Next tests should recover scalar
and continuation information, borrowed tag projection and sound equality boundary
ownership before assuming another broad source rewrite will help. Keep runtime
atomic-protocol changes separate. Frozen old failures and hypotheses remain.

The complete conformance loop now checks historical provenance per suite and
actual execution inputs per case: B1 finishes 68.63s and B2 finishes 79.69s, with
unchanged fixtures, oracles and guards. All compiler/program targets remain
root-owned, serial and guarded; collaborators prepare/review source and data.
No PR comment was posted.

# Previous frontier: Phase97 usefulness experiments complete

[Report](../implementation/phase97/README.md) ·
[Evidence/methods](../selfhost/tools/laws/phase97/README.md) ·
[Experiment](phase97/P97-001-law-usefulness.md).

Frozen independent challenge selection: five semantic detections, one affine
admission refusal, two helpers absent from extraction, two equivalent controls
accepted. Preserve that original score. Two pre-frozen gap witnesses plus the
separate separator typing repair yield228 JS/34 native baseline passes and three
follow-up semantic counterexamples. One independent payload fault also fails
unchanged span_put_back after standalone safe helper admission.

Four public laws+three support lemmas prove a temporary retain/read/release
replacement in arbitrary contexts of an immutable single-cell model. Independent
BendTT accepts26 bodied definitions, zero opaque; three admitted bad protocols
fail. Separately, removing an actual generated-C child retain compiles then fails
at runtime. The model omits individual handles and escaping child ownership;
prove those and the actual lowering correspondence before using it to justify
native lifetime optimizations. No runtime/parallel/GPU or whole-compiler proof.

f_find consume-once candidate passes24 complete-value JS/native controls and five
caller-mutant checks. Six extracted workloads take0.318–0.345× time; real nativeB1
screen is only0.990332× request/0.991748× process,48 exact C/diagnostic comparisons.
Some baseline timings vary; do not call this a material gain or promote its+17
lines. No fullself, candidateB2, broad45/runtime campaign or installed change.

Next useful work if requested: attribute inclusive cost before another helper
rewrite/build; target shared observation/ownership across callers. Add focused
contracts for parent/child transfer, first-match/cache correspondence and binding
semantics. The roadmap scopes whole-compiler correctness as a separate long-term
project, while optimization continues under explicit local obligations.

All targets root-owned and serial; offline preparation/review only. Preserve
source/method failures and the micro repetition-cap correction. No PR comment.

# Previous frontier: Phase96 compiler law foundation

[Report](../implementation/phase96/README.md) ·
[Law guide](../docs/self_hosted/COMPILER_LAWS.md) ·
[Experiment](phase96/P96-001-law-foundation.md).

31 public universal laws and seven support lemmas have complete nonopaque bodies
accepted by unchanged upstream BendTT/Lean. Exact representation helper extraction
and actual Base/Phase94 algebra dependencies are explicit; the Phase94 helper is
still unpromoted. 226 finite JS production cases and32 selected generated-C cases
pass;16 proof rejection controls and10 executable semantic mutants are detected.
Fast replay15.48s, full audit90.72s with existing authenticated toolchain/images.

Follow upstream's specification/executable bridge pattern. Preserve full payloads,
metadata, duplicate/order semantics and the exact production connection. Weak
identities need semantic anchors; absent-ID substitution may still beta-reduce.
No whole-compiler, unsafe runtime, native-chain or parallel/GPU proof claim.
No production optimization, image rebuild or new performance measurement; the
five established metrics remain unchanged. The suite can constrain the next
measured optimization, but a local proof alone is not a reason to promote it.
Three offline agents, root-only serial guarded targets, no PR comment.
Phase96 is complete; next optimization remains unstarted.

# Previous frontier: Phase95 native ownership attribution

[Report](../implementation/phase95/README.md) ·
[Methods and evidence](../selfhost/tools/performance/phase95/README.md) ·
[Experiment](phase95/P95-001-native-ownership.md).

Accepted unchanged-B1 Map profiling attributes56.44% of request samples to
cleanup, including branch closures, string comparison and term projections.
Full self emits exact38.6MB C but has two timer overruns: keep that profile
exploratory. Its physical equality leaf+cleanup bucket is31.88%, membership3.51%,
kc8.41%. These are not removable-time estimates, allocation counts or a complete
logical call tree. Static B2 source has similar consuming patterns; no B2 profile.

Two-line membership delegation to existing has_name makes early hits much faster,
but misses regress5.9%. Real six-source nativeB1 request0.996642× is neutral;
one same-D04 full-input pair138.029s→136.418s gives0.988329×. All48 screen outputs,
both full C outputs/unsafe diagnostics and45 original program C outputs match.
Do not promote or rebuild B2/JS release for this small difference. No new formal
proof of the unsafe helper, program-runtime campaign or broad conformance claim.
Production, installed images and the five established metrics remain unchanged.

Next bounded tests: cache repeated term-tag projection in infer_node and consume
definition fields once during f_find. Larger opportunity: sound read-only
projection/comparison lowering and closure-capture disposal. Use extracted native
controls and code-shape falsifiers before another~228s image acquisition/build.
Prior Bool-first equality variants failed checked recursion/match order; do not
retry them blindly. Two offline agents, root-only serial targets, no PR comment.
Phase95 is complete; no further optimization automatically started.

# Previous frontier: Phase94 law-backed native optimization pilot

[Report](../implementation/phase94/README.md) ·
[Proof and method](../selfhost/proofs/phase94/README.md) ·
[Experiment](phase94/P94-001-law-backed-environment.md).

The exact generic helper embedded in an isolated native compiler candidate has
an independently checked equivalence proof under the unchanged BendTT kernel
and official Lean4.34.0. Three bad helpers fail the frozen law; six adapter cases
and all45 exact C comparisons pass. Unsafe adapters, analysis and runtime remain
outside the proof. No whole-compiler correctness claim or new runtime timings.

Extracted helper time falls17.6–39.0%, but24 nativeB1 pairs are neutral:
request0.99724×, process0.99953×. Do not promote the +50line candidate or rebuild
B2/fullself on this evidence. Production, installed images and all prior metrics
remain unchanged. Initial compiler-screen method drift is excluded and preserved.

Next learning step: attribute native allocation/lifetime costs to actual callers
and test a bounded intervention before another full build. Reuse the proof method
once inclusive cost supports the target; generic cleanup leaf samples are not
enough. Fast cached kernel verdicts~0.3s; accepted compiler screen22s and45-product
continuity39s target time. Two offline agents;220 serial guarded jobs,415.74s
occupancy,4.00GiB peak, no overlap/OOM/timeout. Raw932files preserved and verified.
No PR comment. This pilot is complete; no next optimization automatically begun.

# Previous frontier: Phase93 native generated-program runtime

[Report](../implementation/phase93/README.md) ·
[Method](../selfhost/tools/performance/phase93/README.md) ·
[Experiment](phase93/P93-001-native-program-runtime.md).

All45 original fixed-input batch programs compile through actual native B1/B2
and upstream C; the native stages emit identical C. All264 final timing samples
pass. The44 measurable points take1.114840× upstream time with equal-point
weighting,1.139377× with equal weight per original source (23 sources).
The zero-work scalar control is optimized away by both and has undefined ratio;
retain its failed calibration and explicit exclusion, never assign parity.

Active rays3.45–3.49×, RLE2.60×, symbolic regression1.68× and expressions1.61×
are profiling priorities if optimization is next authorized. Closures0.30×,
Map churn0.64–0.66× and Unicode0.68–0.69× are gains to preserve. Root ran targets
serially; two agents prepared/reviewed offline. No compiler/image change or PR
comment. Saved-product six-point screen16.7s; all44 timings99.9s; acquisition
316.6s. Preserve compiled products and the verified evidence capsule.

This completes the requested benchmark. Compiler latency and finite conformance
remain as in Phase91/92 below; no optimization is automatically started.

# Previous frontier: Phase92 source-matched native chain

[Report](../implementation/phase92/README.md) ·
[Experiment](phase92/P92-001-native-chain.md) · [Metrics](../docs/self_hosted/METRICS.md).
Current native source D04 is unchanged. Upstream-C native B1 `6bb07e94…` emits
exactly the38,614,882-byte C used to build native07 `d7c7a479…`; native07 again
reproduces it. Existing native07 is reused, not claimed as a fresh ELF rebuild.

Native B2/B1 request ratio is1.203× on six sources and1.085× on full self.
Full self remains140.3s/152.2s versus48.4s TS/Bun:2.90×/3.14×. Small prepared-Base
process ratios0.465×/0.672× TS are workflow-specific; without the carrier,
Small is3.257×/3.684×. Native Base decode pooled medians59ms/139ms expose an own-C
hotspot; full-source costs shared by both native images need profiling too.
Do not infer allocator/string/dispatch causality or general parity from ratios.

All45 complete products agree across stages and independent oracles;45 shared
program executions pass. Both native stages pass69 golden fixtures+3rejections;
31 native100 import/provider exclusions remain. Native entry cannot expose
full frontend observations or JS modules. The canonical132 modules/32,692 lines,
installed JS release and public native selection remain unchanged.

Use the33s same-source screen after images exist, then selective product checks.
A native B1 rebuild still costs about255s; full self and broad correctness are
integration checks. Preserve the disk-stop failure and89 reused requests; no
OOM, timeout, overlap, source change, PR comment or quota-percentage claim.
The JS rich-diagnostic issue below remains open. No automatic optimization is
started by this completed qualification.

# Previous JS-hosted frontier: Phase91 scoreboard and B2 diagnostic gap

[Report](../implementation/phase91/README.md) ·
[Metrics guide](../docs/self_hosted/METRICS.md).
Installed Phase90 stays unchanged: B1 `6bf8e093…`, genuine B2 `284f6e9b…`.
Fresh original JS23 request ratios B1/B2 **1.408445×/1.306596× TS-Node**;
C3 **1.453748×/1.230042×**. Imports+API+request are separate:
JS0.969726×/0.981387×, C1.167128×/1.039948×. All234 timed outputs pass.
Do not mix these with Phase90's six-source TS/Bun/native-host screen.

All46 current JS modules equal historical bytes; all24 C outputs have exact
historical-Clang O3 preprocessing. Thus historical program ratios JS1.049× and
C1.067× have current-release artifact continuity, but are not fresh timings.
Manifest census remains32,692physical/26,693code lines in132modules; no source
or concept simplification this phase.

Fresh B2 frontend: **3173/3174 exact observations**, one diagnostic fidelity gap
at `page/deep_list_walk.bend`. The invalid proof is rejected everywhere. B1/TS
print12119chars; old/current B2 both catch `Maximum call stack size exceeded`
and return57chars. This predates Phase90. Preserve the failed strict collector;
do not call current broad conformance3174/3174 or substitute B1 for B2.
Fresh selected C100/100 passes; verified historical reference remains93/100.
Thirteen native APIs, historical JS exceptions and GPU/native-host scope remain.

First fix the diagnostic printer with this tiny control, then validate both
compiler generations. Compilation work should retain the measured native07
Map/Base and same-source backend comparison plan below; current JS Map/raytrace
requests also expose gaps. No blind full rebuild or broad runtime rerun needed.
Root-only guarded targets remain serial; offline agents may prepare/review.
No PR comments without explicit user instruction.

# Historical investigations

The detailed Phase90 and earlier frontier history remains in the
[previous committed steering](https://github.com/rom1504/bend/blob/c32fc32/experiments/STEERING.md).
Read the [Phase90 report](../implementation/phase90/README.md) for native07's
source, build/runtime repair, self reproduction and installed JS release lineage.
Older experiments remain indexed in [the ledger](ledger.md) and their phase
reports. Current benchmark evidence above does not rewrite those results.
