# Active frontier: Phase93 native generated-program runtime

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
