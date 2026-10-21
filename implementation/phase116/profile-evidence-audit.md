# Phase116: profile evidence audit and next measurements

Read-only audit from Phase115 `e096a46`, 2026-10-21. This note ran no compiler,
benchmark, target program, hardware profiler, or new correctness campaign. It
identifies reusable evidence and recommends root-owned measurements. New Phase116
measurements, if collected, belong in their own receipts and supersede the
historical profile hypotheses below.

## Main finding

The qualified broad runtime gap is real, but its **current dynamic attribution is
missing**. Phase114 records 405 successful complete outputs and a 5.3861× equal-
point geometric runtime ratio to upstream C across 44 timed points. Current
machine-code audits identify plausible waste; reliable allocation and dispatch
censuses mostly describe Phase112, before whole functions, flat products and
local recursive regions changed the executed graph substantially.

Therefore, another current profile is more informative than searching the four
Phase115 policies or treating the 2,974 all-refusal sites as hot. Those counts
measure optimization admission during compilation, not generated-program cost.

Three different comparisons answer different questions:

1. **Current QBE vs mature self-hosted C:** work lost at our newer lowering and
   runtime boundary, plus QBE versus Clang machine optimization. The historical
   mature C route is already near upstream on this corpus; Bend is not inherently
   condemned to the current QBE gap.
2. **Current QBE vs pinned upstream C:** complete remaining practical deficit.
   This combines frontend/lowering, representations, runtime and machine backend;
   it does not isolate QBE's instruction selection or register allocation.
3. **Current QBE vs JS:** useful evidence about representation and control-flow
   mechanisms that the mature JS emitter/V8 optimize away. JS GC, warmup and
   startup make it a separate runtime measurement, not an interchangeable native
   cost attribution. A native PC sampler cannot symbolize JIT code as Bend source.

The historical C score is context, not a new matched comparison: Phase102's
candidate03 broad result is 1.06279906× upstream equal-point, while its current
candidate04 adds a separately qualified inline-hint correction. Installed Phase98
continuity recorded 1.115×. Do not divide either historical aggregate into the
Phase114 aggregate and report a freshly measured backend multiplier.

## Exact current anchors

- [Phase114 broad results](../phase114/results.json) and
  [per-program medians](../phase114/broad-runtime.csv).
- `selfhost/build/phase114/final45-audit01-binding.json`: full 45 product map with
  source/QBE/object/runtime/binary/toolchain receipt pins.
- `selfhost/tools/performance/phase112/benchmark45/manifest01.json`: unchanged
  Phase93 input sources, runtime arguments, upstream C/binaries and independent
  complete stdout oracles. Use the separate frozen 50-ms timing profile for its
  own timing series; the manifest retains older approximately 250-ms repetitions.
- `implementation/phase114/selection.json`: runtime-measured source01 versus
  native-qualified source02, explicitly separate. The namespace-walker repair in
  source02 passes three exact-QBE witnesses; that is not a fresh broad runtime
  equivalence proof for every source.
- Current native compiler N1:
  `selfhost/build/phase111/p114-native-final02-n1/program`.
  N2: `selfhost/build/phase111/p114-native-final02-self/build/program`.
- `selfhost/build/phase114/native-final02-transport-manifest.json`: three already
  validated native requests, their exact Base/carrier, image and upstream pins.
  These are one-shot compiler inputs, distinct from the Phase93 runtime batches.

## Highest-information program selection

| Case | Phase114 / upstream C | Question to resolve | Evidence already available |
| --- | ---: | --- | --- |
| `variation-local-fold-128-0` | 11.53× | Is time concentrated in the guarded array loop, allocation/cleanup, or repeated batch invocation? | Selected `$product.fold.loop` already has no product ctor/take; it retains repeated array representation/scalar guards. |
| `variation-ray-active-256-2240` | 8.50× | How much is arithmetic/float transport versus calls and runtime? | `isect5` has 49 GPR/XMM moves; Hit products are already flat. Local F32-lane prototype gives 12.77% on this case, showing opportunity but not an 8.5× explanation. |
| `lexer` | 7.30× | Does tagged `Mode` traffic or String construction/ownership dominate? | Outer product already flat; `step.at` still constructs/takes tagged state. |
| `coverage-map-churn-128` | 8.68× | Is the dominant cost generic owned-tree traversal, RC/allocator work or continuation transport? | `Map.set.go` remains an owned-tree path; old heap counts establish plausible mechanisms, not current CPU shares. |
| `tree-bitonic` | 6.65× | How much survives the successful local recursive region: boxed `Stat` results, owned extraction, or live capture transport? | Recursive `scan` still returns one boxed Term for four U32 fields; all captures cannot simply be removed. |

These five cases distinguish three broad mechanisms rather than merely selecting
five worst ratios. Add `scalar-region-8192` as a cheap control if time permits:
its 2.18× gap remains after calls/ownership disappear, so an allocator-only
explanation cannot cover the whole corpus. For compiler transfer, collect one
ordinary current native lexer-compilation request, using its prior exact QBE
output as the instrumentation-transparency oracle. Do not begin another full
self-compilation merely to collect a profile.

Exact current products for the selected cases live under `selfhost/build/phase111`:

- `p114-final45-variation-local-fold-128-0-{emit,build}`.
- `p114-final-screen01-variation-ray-active-256-2240-{emit,build}`.
- `p114-final-screen01-lexer-{emit,build}`.
- `p114-final-screen01-coverage-map-churn-128-{emit,build}`.
- `p114-final-screen01-tree-bitonic-{emit,build}`.

`emit/program.ssa`, `build/program.s` and `build/program` support a direct
source → structured QBE → machine-function audit without regeneration.

## Reliable old evidence, and what it does not mean now

[Phase112 profiles](../phase112/profiles.md) and
[their controlled comparison](../phase112/profile-comparison.md) are successful
source-level event censuses with complete-output checks. They revealed the large
compiler U32-to-Word representation cliff and its removal: 124,677,389 allocation
helper calls fell to 16,515,651; 1,625,654 materializations disappeared. This is
strong evidence that preserving source facts can remove whole categories of
work. It is not an 86.75% CPU-time measurement, and the cliff is already fixed.

The last Phase112 facts compiler profile records 18,976,168 heap allocations,
7,690,273 frames and 435,465,555 requested register-word clears for a lexer request.
These are historical baselines, not current Phase114 counts. Its latest receipt
is `selfhost/build/phase112/profile-facts-compiler01/report.json`.

Counters overlap: ctor → allocation → seal can describe the same operation.
`public_calls_fid` attributes to the last dispatched segment, not an exclusive
native stack. Source copy/zero counters do not prove actual machine memory
traffic after optimization. Whole-process benchmark counters include two
workload evaluations at repetition1/warmup0, plus parsing/setup/readback.

The counter materializer `phase112/profile/prepare.py` is pinned to runtime04
SHA256 `c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50`.
Current Phase114 uses the Phase113 product runtime object SHA256
`c0f6f2ca5b5a58418f326794e97a29cc21a68f32e924ce5974ad4ffccfc9c9f9`.
The old diagnostic runtime must not be substituted unchanged: new product ABI
helpers and emitted fast paths require explicit coverage review. Even a correct
port of runtime-only counters can miss fast paths now emitted directly into QBE.
Reusing the old census blindly would undercount the very categories optimized.

## Small root-owned profiling recipe

Use unchanged authenticated ELF products; no QBE emission or compiler acquisition
is needed. One serial CPU3 lane, 2 GiB tree cap, 16 GiB available-memory floor,
short per-run deadlines and bounded fresh logs are sufficient for ordinary cases.

The existing ordinary process sampler is
`selfhost/tools/performance/phase68/parity-survey/sample-preload-v2.c`;
a retained built copy is `selfhost/build/phase108/profiler01/sampler.so`.
Authenticate it against its build receipt before use. It preloads into the
current process, records sampled instruction pointers and mappings, and does not
patch the generated compiler. Its protocol is:

```text
LD_PRELOAD=<authenticated sampler.so>
BEND_SAMPLE_OUT=<fresh bounded sample file>
BEND_SAMPLE_PERIOD_US=8000
<binary> --threads 1 --gpu off -- <repetitions> <warmups> <arg0> <arg1>
```

Use a separately declared diagnostic repetition count large enough for roughly
4–8 seconds of CPU per role, then another period (for example13ms) on the most
important case to check timer aliasing. The same source/workload arguments must
remain fixed. Repetition scaling for profiling is not a new timing benchmark and
must be recorded explicitly; complete result, warmup and repetition counts must
still match. With8ms periods,4s yields approximately500 samples. A few hundred
samples can identify a large bottleneck but cannot resolve a 1% effect reliably.

`selfhost/tools/performance/phase101/profile.py:analyze` is the better analysis
pattern than the old Phase108 wrapper. It normalizes PCs through mapped ELF load
segments, uses `addr2line` against the actual binary, checks CPU coverage and
keeps unknown/library mappings explicit. The Phase108 wrapper expects an old
compiler-to-C request protocol, so do not invoke it unchanged for current QBE.
Map sampled PCs into emitted machine function ranges and inspect the instructions
at those PCs. Symbols can give function attribution without rebuilding for DWARF;
source-line absence must remain explicit.

Require intact handler, complete END marker, zero dropped/overrun counts and at
least95% sampled-thread/process CPU coverage. Keep failed captures as exploratory
and lower the sample frequency if needed. If upstream uses other worker threads
despite its one-worker flag, the main-thread profile is not a whole-process
profile; the retained `sample-preload-threads.c` provides lifecycle/coverage
accounting. Never derive clean performance ratios from the sampled clocks.
Measure uninstrumented products separately with the unchanged timing/output gate.

Current native request sampling can reuse the already successful focused request
arguments under `p114-native-final02-n1-focused/*-native/report.json`, or the
transport-manifest command derivation. Change only the sampled executable/env,
write fresh output, and compare every emitted QBE byte with the earlier request.
This checks diagnostic transparency, not independent compiler semantics.

For JS, use the established JS runner and engine's own CPU profile, retaining
engine/version, warmups, generated JS hash, complete output and GC/JIT categories.
Do not interpret `[unknown]` JIT PCs from the native sampler as source cost.
A native-versus-JS ratio needs identical source, input and measured kernel scope;
old compiler-request numbers are not generated-program performance.

## Profiling failures that must not become quantitative claims

- Phase108 `profile-v201/report.json` requested2ms but delivered1,204 samples
  with1,202 overruns. It suggests small helper/RC overhead, but it is not a
  loss-free CPU-share estimate; current direct QBE is also a different route.
- Phase111's24 ptrace stops were qualitative. Pausing perturbs execution, deeper
  frame chains are heuristic, and the first mapper assigned nearest `nm` symbols
  even outside the image. The corrected mapper keeps unknowns explicit, but
  [sampling interpretation](../phase111/sampling-interpretation.md) still rejects
  using13/24 register-copy hits as54% of CPU time.
- Old successful Phase98/101 C profiles are evidence about mature C machinery,
  not direct QBE. They are useful to locate cross-backend mechanisms and design
  controlled comparisons, not substitute for current captures.
- Historical `perf` absence/permissions do not justify changing system security
  settings. The existing user-space sampler is enough for this bounded survey.

## What parity would actually require

For one program, eliminating work occupying fraction `f` of current runtime
cannot exceed `1/(1-f)` speedup under the simple fixed-work Amdahl model. Moving
5.386× to1× would require81.4% less time; reaching0.5× would require90.7% less.
These percentages contextualize ambition, not an additive decomposition of a
geometric benchmark aggregate. A helper with20% leaf share cannot by itself
explain a5× speedup, and ownership costs spread across callers must not be counted
twice. Cache/layout/control interactions can change the simple model, so only a
controlled intervention establishes the realized gain.

The likely route is several general categories, chosen by current dynamic evidence:

1. Certified array handle/layout facts across loops, eliminating repeated guards,
   address reconstruction and buffer joins rather than adding more inlining.
2. Owned constructor extraction and flat recursive products that remove allocation,
   sealing, take and scratch round trips together.
3. Float and scalar representations retained across private calls, plus generic
   Boolean/signed-shift simplification where ownership is already absent.
4. Closed tagged-state or constructor-spine representations where profiles show
   repeated allocation/continuation work, preserving ownership and stack safety.

No multiplier is established for these proposals. The first next experiment
should choose the category occupying a measured hot region in at least two
unrelated workloads, require the corresponding machine work to disappear, then
measure complete outputs and clean execution time. The mature C route is an
especially valuable reference for what semantic facts our structured route lost;
its success does not imply copying C text or replacing the direct backend.
