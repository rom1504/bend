# Current frontier — Phase166 execution boundaries; Phase152 remains qualified

[Report](../implementation/phase166/README.md) ·
[Metrics and receipts](../implementation/phase166/metrics.json) ·
[Native profiles](../implementation/phase166/evidence/lookup-profile-summary02.md).

Identical compiler-derived lookup/complete-consumer source runs in 0.54148s QBE,
0.35772s mature C and 0.15649s bendc C, four balanced runs at 10,000 rounds. Separate
clean/profile lanes confirm the gap. This is a tiny-book kernel, not compiler
throughput. 120 output-checked sampled captures pass pooled quality gates. QBE's
four constructor/take helpers account for 46.73% physical CPU; equality 5.57%.

Replacing lookup/index construction with independently specified complete records,
retaining the digest consumer, gives 0.28461/0.12483/0.11678s. Mature C approaches
bendc in this control; QBE still has a 2.44× gap. Sharing, reachability and inlining
change, so subtraction is not exclusive lookup time. Next test QBE unique-cell
constructor/take fastpaths with exact fallbacks, and a real compiler consumer
that preserves the borrowed lookup result through its use. Keep stack/alias gates.

Hosted backend census matches six complete C/QBE products and preserves ordered
stage admission. It exposes 19.27M Map Tuple events in comparisons, but native
borrowed comparison already eliminates per-character reconstruction. Do not sell
hosted events as native allocation savings. Prepared body reuse and indexed
verifier getters already work; another general cache/linear-lookup rewrite is
unsupported. The 2.132B native allocation residual remains unattributed.

Eleven guarded jobs used 235.08s. 108 complete raw record controls and 156 native
output checks pass; no production change, full acquisition or new cold-build gain.
All new runs are archived/verified. One old archived Phase149 SSA reclaimed 115.3 MiB;
qualified images remain hot. Read the report's fixture and runtime-policy limits.

# Previous frontier — Phase165 source bisection; Phase152 remains qualified

[Latest report](../implementation/phase165/README.md) ·
[Causal metrics](../implementation/phase165/metrics.json) ·
[Reciprocal transfer](phase165/transfer-note.md).

Same-executor bendc checker ablations now preserve complete outcomes on our
182 KB checker and full 3.085 MB compiler input. Removing native memo is neutral.
Portable Map alone costs 1.15× on full checking/reporting; portable Map+String
costs 1.76×. Crucially, transplanting our exact safe three-function equality into
bendc costs only 1.015×. Our existing algorithm already avoids Base's reconstructed
String pairs; do not infer a large new native-equality win for our compiler from
the Base fallback slowdown. All 72 observed outcomes agree with fixed oracles.

Complete shared-request backend screens put QBE at 1.26–1.57× mature C on Map and
1.77–2.04× on a verifier slice, two execution orders with exact complete products.
Both generated backends pass their independent IO points. Hosted diagnostic
clocks and warmup differences are explicit; these are not native/full-build ratios.
The source-sized verifier fixture executes an empty-program control, not a large
runtime verification workload.

Next measure ownership/call/representation cost around the existing predicate
and complete lookup under QBE, and bisect semantic production/private preparation/
verification/output from one checked request. The residual 2.132B allocation
count remains unattributed. No new cold-build speedup, production changes or
five-second forecast. Prefer explicit Phase152 N2 image+receipt: the default
asset named qbe-n2 is an older source and caused a preserved comparison refusal.

# Previous frontier — Phase164 mixed-route limits

[Latest report](../implementation/phase164/README.md) ·
[Mixed evidence](../implementation/phase164/mixed-metrics.json) ·
[Index experiment](../implementation/phase164/zipper-metrics.json).

Mixed direct-first lowering now executes ten original IO fixtures and compiles
its own native source. N2 self-emission exactly reproduces the predecessor QBE.
However, same-source full acquisition is201.931→201.271s: no meaningful cold
gain established. This1.556MB private source differs from the3.085MB maintained
source behind the249.222s qualified observation. N2 small native requests improve
about5% on two cases but regress5.6% on Map. Do not promote this route yet.

A100-line imports-only interface reproduces the clear Mandelbrot/Unicode runtime
gains (15.0%/12.4%, two pairs) while retaining all original lowering and checking;
editdist is neutral. No new broad score or native imports-only qualification.
Explicit index reconstruction passes356 complete host comparisons per variant
and17 fused native controls. List-plus-frame state is neutral; a fused recursive
frame saves5.37%/1.55% on two complete4096-key map workloads, four pairs. This is
not a whole-compiler speedup and does not justify another acquisition alone.

Next identify the exact existing local-region refusal on insertion/typed verifier
reconstruction and measure a complete checker request. Existing non-tail regions
already provide stack-safe execution; bendc's ordinary recursive C calls instead
rely on large guarded virtual stacks. Preserve that distinction. Generic fact
records, repeated hashing and semantic work remain separate measured leads.
No credible five-second full-build forecast, production change or recursive
acceleration claim. All30 target jobs sealed,18.6min target wall; exact failures
and source snapshots retained. See report for resource and validation boundaries.

## Previous direct-first experiment

[Latest architectural experiment](../implementation/phase163/README.md) ·
[Measured limits](../implementation/phase163/metrics.json) ·
[Hybrid follow-up](phase163/hybrid-direct-first.md).

Phase163 builds verified direct QBE workers without first constructing their
generic continuation bodies. Optimized native source→QBE requests on actual
compiler reversal/lookup workloads take 22.6%/34.7% less time; generated runtime
is 0.993×/1.070× the qualified reference. A same-policy hosted ablation emits
byte-identical QBE with 29.8%/16.4% less lowering time, two samples with visible
variance. These are bounded workloads, not full compiler or upstream ratios.

Only two of eight unrelated pure transfer computations are admitted; six refuse.
The restricted native CLI cannot compile its own IO entry. Compact-App controls
pass but native parse+check is 4.7% slower on the 182KB checker workload, so that
overlay is not promoted. The next architectural gate is mixed generic/direct
adapters with an independently checked direct-import registry. Preserve genuine
fallbacks and cold/ownership facts; do not claim all continuation segments can
disappear. No production source/selector change, new qualification, 5× full-build
gain or recursive acceleration. Phase156 publication integration remains pending.

[Latest investigation](../implementation/phase162/README.md) ·
[Source/work audit](../implementation/phase161/README.md) ·
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

## Phase162: controlled frontend explanation

Same exact3.085MB source and75KBBase, original bendc check-only63.111s versus
private bounded-search runtime17.153s, identical122,602-byte unsafe verdict.
This3.679× effect changes runtime policy, not frontend algorithms. Do not treat
our prior66.52s prepared-Base diagnostic versus17.15s as a checker-algorithm ratio.
Counter controls confirm both complete parses,8761jobs and successful body checking;
an ill-typed @unsafe body fails before proof reporting.

Actual same-source C02 observations: checking613.60million allocations and
4.320billion requested words versus bendc224.19million/998.16million. Existing
Phase156 publication-only policy reduces ours to254.70million/1.708billion,
canonicalizations370→76, with all118,227,421 output bytes unchanged. Diagnostic
check31.543→12.344s; complete streamed C request178.990→148.379s. These are NOT
new clean QBE gains or production qualification; prior clean native gain4.62%
remains the relevant measured integration result. Runtime/GC changes the benefit.

Source-to-generated-C trace finds a concrete representation tax: generic KTerm
application plus child lists needs3objects/15words; typed bendc TApp needs1/4,
given existing operands/span. Cached tags are not new allocations. This is a
local cost, not a3.75× compiler-speed prediction. First count hot constructors
and test a compact typed term through a complete computation, retaining spans,
quantities, errors, ownership and exact checked outcomes; avoid conversion at
every consumer. Whole request still allocates2.132billion objects outside its
measured frontend, including Base and backend/output. Publication and compact
terms do not by themselves explain the remaining whole self-compilation gap.

No production changes. Two bounded audit agents, root-only guarded lane, exact
outputs and negative observer findings preserved. See
[operation metrics](../implementation/phase162/operation-metrics.json),
[representation trace](phase162/representation-note.md) and
[causal audit](phase162/causal-audit.md). Do not multiply incompatible ratios into
a purported explanation of the advertised100× comparison.

## Previous backend work frontier

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
