# Active frontier: Phase96 compiler law foundation

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
