# Current frontier — Phase161 source/work audit; Phase156 integration pending

[Latest investigation](../implementation/phase161/README.md) ·
[Same-source execution comparison](../implementation/phase160/README.md) ·
[Phase153 investigation](../implementation/phase153/README.md) ·
[Headroom metrics](../implementation/phase153/metrics.json) ·
[Qualification](../implementation/phase152/qualification.json) ·
[Independent audit](../research/phase152/final-audit.md) ·
[Experiment ledger](ledger.md).

## Qualified compiler results

Phase152 integrates the scalar lexer, compact dispatch and authenticated nullary
constants; original admission and final verifier remain intact. Exact source:
66,399 lines/8,265 declarations;112 protected hashes unchanged. Cold screens:
259.302→254.613→249.222s across native generations, one observation each, no fresh
upstream ratio. Smaller requests improve2.56% across four balanced rounds.
All45 ordinary QBE/assembly/object products remain exact;44 resolved runtime
points are neutral (0.99896×). Details and finite gates are in the linked report.

## Qualified and installed identities

Phase152 N2 is the latest qualified ordinary serial native research compiler:
`selfhost/build/phase152/native-n2/program`, SHA256
`d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd`.
Use its [qualification receipt](../implementation/phase152/qualification.json)
and explicit assets. Maintained source assembly exactly matches the qualified
3,085,157-byte source, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
N2/N3 QBE, assembly and objects reproduce exactly; ELF files differ. N1 focused19,
N2 all64, 66 compiler-data controls, hosted JS8 and C6 spot checks pass.
These finite gates are not a new BendTT theorem or parallel/GPU qualification.

Installed JS/C/QBE releases remain the
[consolidated selection](../selfhost/manifests/current.json). Phase147 remains
available as the qualified parent. Use the one maintained source tree and
[workflow](../docs/self_hosted/workflow.md), not retired experimental overlays.
Metric definitions remain in the
[comparison guide](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md).

## Highest-value next experiment

[Phase161](../implementation/phase161/README.md) separates source inventory from
backend work. Fixed original Phase156 QBE executable/live Base: full3.085MB input
226.912s versus checked1.698MB native closure194.417s,14.32% less in one clean
observation each. Closure44,186 lines versus current bendc's six-module43,857:
raw source size is not an order-of-magnitude difference. Both QBE outputs still
have73,926 functions/56,649 dispatcher segments and about118MB. Closure changes
constructor/specialization identities and static data; it is NOT equivalent by
byte comparison or a qualified compiler. Do not promote it from source checking.

Fresh same-object diagnostic captures accept7,452/6,442 samples, zero loss,
99.43/99.35% CPU coverage. Stage totals239.794→207.461s;84% of savings comes
from parse/load, checking/publication and proof report. Both variants still walk
4,291 names through generic/signature/candidate enumeration. New full-source split:
generic body11.59s; private/direct candidates26.78s; signatures0.81s; SCC0.44s;
dependency admission0.51s. Initial optimizer23.67s, registry16.19s and render/
teardown40.21s remain substantial. Prepared-Base diagnostic clocks are distinct
from the clean live-Base request clocks; nested final verification is not added.

Prefer investigating which generic continuation bodies can remain unmaterialized
once a private implementation is admitted, while preserving actual fallback,
public/closure ABI, ownership, bounded stack and independent verification
obligations. First classify needs from verified metadata, not textual call grep;
prove one real owner/proxy before a broad refactor. Generic lowering alone is
only4.8% of staged time, so a large win needs downstream analysis, optimizer,
registry, emitted-body and destruction savings too. Gain remains unmeasured.

Do NOT add another common compacted-body cache: p112s_defs already prepares
NativeStaticBody for ordinary reachable definitions and both lowerers reuse it.
Two nc_compact_definition call sites do not prove duplicate compaction. Remaining
use/layout analyses need full producer/consumer evidence; Phase156's transported
use-set experiment was neutral. Typed checker Book/publication is a separate
promising structural simplification, starting with the already-measured Phase156
provenance improvement. bendc also has two frontend parsers and already-present
memoization/native intrinsics, not a magical single-pass/caching feature to copy.

Eight guarded jobs,15.30min target-lane time, two bounded source-audit agents.
No production/source/selection changes. Exact full and closure output gates,
rejected diagnostic-build attempts, source census and restoration/retention
receipts are preserved. Only obsolete authenticated Phase156 SSA/assembly/object
payloads were pruned; its request ELF and qualified compilers remain available.

## Prior runtime comparison — retained evidence

[Phase160](../implementation/phase160/README.md) now compares the **same complete
Bend compiler implementation** through QBE and bendc/C. Full3.085MB input:
223.237s QBE versus167.602s C; same118,227,421 independent QBE bytes. C with
only BEND_GC_FACTOR=1 takes138.383s:38.01% less than QBE, but peak RSS rises
from1043.4MiB QBE to4074.7/5057.3MiB C. One fresh observation per role, not a
qualified cold-build/TypeScript ratio or paired-median claim. Map and checker
pilots were2.55×/2.26× faster; they overstated full-source transfer.

The same compiler algorithms, live Base, checking, optimization, final verifier
and output/teardown execute in both roles. Source whitespace has an independent
exact structural parse bridge. C uses private bounded-search GC, no-local-free,
BEND_UNBOX=0, pinned Clang-O2 and nine effect adapters. This measures the bundle
of execution mechanisms, not Clang alone or default bendc. Default unboxing
failed Map: generated code passed a function list as an error String. Preserve
that counterexample; only the unboxed-off image passed complete output gates.

The accepted full C profile has1,672 samples,99.94% CPU coverage, zero loss:
55.62% tracing/collection/rescan,5.86% refill,7.95% generic apply.8ms was rejected
for36 overruns;100ms accepted. No pooling. Raising only allocation headroom
reduces full time17.43% and raises RSS24.12%, establishing cadence sensitivity.
Do not infer that a GC replacement or removal of every ownership operation is
sound/profitable. QBE's historical42.71% ownership/transport attribution overlaps
its stages and is not a matched physical subtraction from this new C image.

Next prioritize compact, lifetime-bounded complete compiler computations:
durable admitted IR/facts versus per-function temporaries, borrowed readers and
stack-safe direct returns. Output already streams; do not invent a retained
118MB String. Capture actual allocation/retention by owner before choosing a
region/representation change. Inspect the hot admitted worker, include setup,
conversion and teardown, then require transfer to full source. Preserve prior
negative evidence: local numeric/dense/use-set wins did not broadly transfer.

The native-main closure is now screened in Phase161 above. Its14.32% request
saving is not a qualified build gain or generated-program speed gain. Preserve
all maintained targets; target-specific assembly and semantic identity changes
need their own integration/qualification before promotion.

Current bendc self-emission separately reproduces its4.628MB seed C:
original runtime16.974/39.728s unchecked/checked; bounded-search runtime
5.981/11.374s. One observation each. Historical published9c54842e remains
4.499/8.810s medians from [Phase158](../implementation/phase158/README.md).
Different source, runtime, input, output and checking boundaries prevent using
these as an apples-to-apples ratio against ours. Both do whole-loaded-program
work; historical bendc is not allocation-free. See the source/work census.

Phase160 closes23 guarded jobs,28.30min target-lane time; two bounded agents.
Exact artifacts, failed acquisitions, wrong-code control and rejected profile
are preserved. No production edits or installed changes. Three already archived
Phase153 raw products were pruned with authenticated receipts; no broad deletion.

[Phase156](../implementation/phase156/README.md) remains the pending production
optimization: publication provenance skips redundant canonicalization only
after established coherent publication; childless inserts invalidate it. Two
reversed full-source pairs215.026→205.086s,4.62% less, identical QBE. The actual
checker slice is neutral; do not extrapolate from its static type adjacency.
Integrate compactly with original fallback/error/law scheduling and focused
controls, then qualify once. Shared-use lowering was neutral on actual requests;
its kernel win and initial nonrepeating Map regression do not justify promotion.
Dense storage needs snapshots/joins/old-state observations, not a naive mutable port.

[Phase153](../implementation/phase153/README.md) remains the complete QBE stage
profile:236.947s staged CPU; raw lowering39.27s, initial optimization23.55s,
output/cleanup38.63s, check/publication33.57s, parse29.64s. Nested final verifier
costs must not be double-counted. Reduce complete work, not just metric counts.

[Phase159](../implementation/phase159/README.md) demonstrated the original
bounded-search hypothesis on five captured owners:13.836→2.585s,5.35× in four
paired rounds, with roughly1.16GiB RSS. That kernel is not the complete compiler;
Phase160 supplies the larger transfer and exposes a different tracing bottleneck.
[Phase157](../implementation/phase157/README.md)'s original negative is therefore
not evidence against all GC/direct execution. Explicit RC failed its output gate.

Keep source checking, finite laws, structural admission and independently checked
BendTT proofs distinct. The [Phase129 audit](../research/phase129/selected-compiler-audit.md)
and [upstream assessment](../research/phase150/upstream-assessment.md) still apply.
No upstream migration, proof-strength claim or parallel/GPU qualification was
mixed into these experiments. Full self-reproduction/broad conformance is for
justified integration, not every early hypothesis.

## Resource, evidence and communication rules

One root-owned serial CPU3 target lane. Ordinary jobs use maintained process-tree
and disk guards,2GiB RSS,16GiB available floor and5GiB disk reserve. Larger image
campaigns need an explicit measured budget; the prior6GiB gate is not a default.
Separate-process parallel correctness pilots require an explicit disjoint CPU
mask, aggregate accounting and no concurrent performance target. QBE's qualified
runtime remains one heap mutator, one CPU worker, GPU off.

No unsafe/failure-runtime probes; do not resume Phase113 custom failure
reproductions. Use ordinary valid programs, finite compiler/data refusals and
frozen independent oracles. Never overwrite frozen artifacts or hardlinked
products. Close each run through maintained retention; preserve negatives and
exact evidence before optional pruning. No full image build without measured
benefit and disk admission. No PR comments unless explicitly requested.

Use bounded agents for independent work; root owns target execution. Track
compiler work, machine builds, validation, failures, agent effort and billing
separately. Guard seconds are not total research cost; unavailable quota data
must not be invented. Keep commentary updates during sustained work.

Recursive research remains an open question. Follow the
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Self-reproduction is not recursive acceleration.1×/10×/100× describe research
ambition, never established speedups.
