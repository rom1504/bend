# Phase94: a law-backed native compiler optimization

The pilot works as a correctness method, but does **not** establish a compiler
speedup worth promoting. An independently checked law constrains the exact helper
called by an isolated compiler candidate. The helper takes **17.6–39.0% less time**;
the six-source native compilation screen is effectively unchanged at **0.99724×**
baseline request time. All **45 complete generated C products remain identical**.
The default compiler, installed images and production source are unchanged.

[Design](../../design/phase94/laws-backed-native-optimization.md) ·
[Experiment](../../experiments/phase94/P94-001-law-backed-environment.md) ·
[Proof guide](../../selfhost/proofs/phase94/README.md) ·
[Replay and evidence](../../selfhost/tools/performance/phase94/README.md) ·
[Machine-readable result](../../selfhost/tools/performance/phase94/evidence02/summary.json).

## What changed in the experiment

The baseline is commit `90f40c4`, upstream `0592662`, and native source D04
(`d04ad79c…`). Two native emitter paths, `nc_let_atom` and `nc_let_emitted`, filter
the old environment, append a new binding, then partition using the same liveness
predicate. This repeats membership tests for retained rows and allocates
intermediate lists. The candidate fuses that preparation into one pass while
preserving the ordered live environment and exact drop accumulator.

The safe helper has 31 lines; its separate reference has 30 and its proof 114.
Closed function templates with explicit reusable state make the generic helper
compatible with Bend's affine function rules. The integration recipe embeds the
exact checked helper bytes, removing only `import Base`, and supplies concrete
binding/liveness/string adapters. It changes only the two stated call sites;
`nc_let_cut`, ownership rendering and polling remain unchanged. The candidate
adds 50 lines / 2,230 bytes to the assembled compiler, with source hash
`6dafff83…`. The review patch and all four exact source splices are archived.

## What is proved, and what is tested

The theorem equates the full result of filter→append→partition with fused
extension for arbitrary finite ordered lists, typed pure total membership and
drop functions, and an arbitrary initial accumulator. It does not assume unique
binding IDs, sorted input or commutative accumulation. A dead prefix row remains
absent without being dropped again; a dead new binding contributes its drop once.

The upstream checker accepts the safe dependency closure. Its 12,833-byte BendTT
elaboration contains 36 definitions: 29 ordinary definitions and seven opaque
template constants. All helper/reference functions and six theorem bodies are
present. The unchanged upstream BendTT kernel, run by official Lean 4.34.0,
independently accepts it. Opaque constants model arbitrary parameters and cannot
be unfolded to manufacture the proof. No kernel patch or new axiom was used.

Independent positive and deliberately false-equality controls pass. Three bad
helper variants—reverse retained rows, omit a drop, retain dead rows—are rejected
by the frozen law at the **Bend frontend**, separately from independent checking.
Six executable production-adapter controls pass: empty/dead, empty/live,
duplicate IDs with different value kinds, duplicate new ID, only the new binding
dropped, and every prefix row dead. They compare the candidate, old production
operation and independently written expected strings.

The proof does **not** cover the unsafe adapters, correctness of liveness
analysis, equivalence of old unsafe code to the reference specification,
reference counting, generated C, runtime or scheduler. Callback purity and
termination for valid compiler values were reviewed, not mechanically proved.
The laws/reference are agent-authored, not an externally supplied specification.
This is a production-connected helper proof, not a verified compiler.

## Measured results

The helper benchmark is upstream-C-built native code, one CPU/thread, GPU off,
with validated order-sensitive checksums. Setup/startup is outside the clock;
the helper, checksum fold and one result print are inside. Both roles use the
same calibrated repetition count and at least 200ms per measured sample.
Three alternating rounds give 24 final measurements; pilots/calibration remain
separate. See [helper.csv](../../selfhost/tools/performance/phase94/evidence02/helper.csv).

| Environment size / mask / new binding | Baseline µs | Candidate µs | Time reduction |
| --- | ---: | ---: | ---: |
| 16 / 1 / 1 | 0.712 | 0.489 | 31.3% |
| 64 / 0 / 1 | 3.735 | 2.277 | 39.0% |
| 256 / 1 / 0 | 10.412 | 7.556 | 27.4% |
| 1024 / 3 / 1 | 33.693 | 27.754 | 17.6% |

Doubling repetitions on the first case gives 2.000× baseline and 2.004× candidate
elapsed time. This is a scaling control for that case, not all four workloads.
These are extracted-helper costs, not whole compilation or user-program speed.

The real compiler comparison swaps only the native B1 executable, using the
same benchmark input, prepared Base, runtime, providers and Clang O2 construction flags.
Four balanced rounds give 24 pairs in fresh processes. Every full C output agrees.
Request time excludes preparation; process time includes startup, preparation,
writing and teardown. See [compiler.csv](../../selfhost/tools/performance/phase94/evidence02/compiler.csv).

| Compilation request | Baseline median ms | Candidate median ms | Candidate / baseline |
| --- | ---: | ---: | ---: |
| Small | 58.0 | 57.0 | 0.983× |
| Numeric | 99.0 | 99.0 | 1.000× |
| Lexer | 354.0 | 354.5 | 1.001× |
| Map | 1389.5 | 1388.5 | 0.999× |
| Functions65 | 225.5 | 227.5 | 1.009× |
| Unicode | 57.5 | 57.0 | 0.991× |

Equal-case geometric means are **0.9972365× request** and **0.9995302× process
wall time**. Request milliseconds and the guard's 20ms process polling limit
small-effect interpretation. Retained outliers include a 389ms candidate Lexer
request. This is effectively neutral, not evidence of a 0.3% general speedup.

The candidate then emitted exact historical C for **all 45 Phase93 wrappers**.
This preserves artifact continuity with prior runtime measurements for those
programs; no new user-program execution/timing campaign was needed or claimed.
No candidate B2, full self-compilation or full conformance campaign was run.

An exploratory baseline Map profile collected 1,921 samples and two timer
overruns. Leaf samples concentrate in `term_drop` (~34%) and `span_fade` (~19%).
The environment routines themselves have few direct samples. This is not clean
inclusive attribution: shared cleanup may belong to many callers. It cannot
justify assigning that time to this helper or predict an allocation rewrite's
gain. The raw profile and its limitations are preserved.

## What remains true of the five metrics

| Metric | Outcome |
| --- | --- |
| Compiled-program speed | Exact C continuity on 45 wrappers; Phase93's 44 measurable ratios remain 1.115× upstream, or 1.139× with equal original-source weighting. No fresh timing claim. |
| Native B1 compilation | Candidate six-source screen neutral. No new full-self result; baseline remains 140.262s versus 48.394s TS/Bun. |
| Native B2 compilation | Not rebuilt or retimed; baseline remains 152.191s on full self. |
| Conformance | New helper proof, three mutation rejections, six adapter controls and 45 product comparisons. Existing native 69 positive + 3 rejection checks per stage and 31 import/provider exclusions are unchanged. |
| Simplicity | No production line/concept change. The unpromoted candidate adds 50 assembled lines; proof/research/tooling are counted separately. Production remains 32,692 physical lines in 132 modules. |

The [Phase91](../phase91/README.md) JS B2 diagnostic-fidelity gap also remains
open. Neither this proof nor exact C output closes it.

## Iteration cost, failed attempts and preservation

Building the reusable Lean kernel module once took **52.84s** with 1.19GiB peak
RSS. The final replay took 0.534s for source checking, 0.636s for elaboration,
0.370s for independent acceptance and 0.289s for independent rejection. Toolchain
download/extraction and full 12,695-file authentication are outside that hot loop.
Fast replay reuses the completed installation audit, checks key executable/module
identities and verifies the exact proof artifacts; it does not rehash every Lean
file each time. `--audit-toolchain` performs the expensive complete recorded audit.

Checked compiler acquisition took 59.98s, of which 56.38s was upstream C emission;
Clang took 177.34s. The helper runs occupied 12.94s, the accepted paired screen
21.96s, and the 45-product screen 39.33s. There were **220 serial guarded targets,
415.74s total guarded occupancy**, peak **4.00GiB RSS**, no overlaps, timeout or
memory stop. This is not total elapsed research time or a quota estimate. Two
agents helped with proof/integration and independent method review offline;
only root ran targets.

Preserved unsuccessful attempts include:

- Disk exhaustion during the first official Lean download. Only its incomplete
  bytes were removed. Byte-verified hardlinks for identical historical generated
  files recovered 1,635,281,268 logical bytes; paths/content/modes and old metadata
  are recorded. RAM-staged Lean was fully verified into persistent storage and
  the temporary RAM copy released.
- First kernel build missing `.olean.server` files; supplied from the same
  verified official archive without changing the kernel.
- First proof structure failing on distinct neutral accumulator expressions;
  explicit constructor-case lemmas repaired it, with helper/reference unchanged.
- Two microbenchmark source errors: wrong numeric conversion name and an affine
  variable reused without `+`. Both failures and corrected sources remain.
- First proof replay counting only ordinary definitions. Its complete file audit
  succeeded, but its overall verdict failed; the inventory now includes opaque
  definitions. Only that completed audit subresult is reused.
- First compiler screen's final audit catching a method edit during execution.
  Its initial method was recovered; all timings are excluded. The final screen
  repeated all 48 samples with a frozen method. This was avoidable coordination
  waste, costing 21.83s of target time.
- First receipt collector rejecting an external toolchain path. Its method and
  failure are retained; the repaired collector ran no new targets.

The [evidence capsule](../../selfhost/tools/performance/phase94/evidence02/archive.json)
verifies all **932 archived files** by exact byte readback, including failures,
proof elaboration/kernel module, candidate source/C/binaries and raw measurements.
The 24.4MB archive excludes the official Lean distribution itself and retains
its release identity and file manifests for restoration. No PR comment was made.

## Decision and next learning step

Retain the helper, law, proof and integration recipe as an isolated experiment.
Do not add 50 production lines or rebuild the self-hosted chain for a neutral
screen. Correctness laws made the transformation reviewable, but do not tell us
where performance matters. This pilot answers the feasibility question without
pretending it closes the native compiler's roughly 3× full-source latency gap.

Next, attribute native allocation/lifetime costs to specific callers on Map and
full compiler source, with a short reproducible profile and a bounded intervention
before another full build. Apply this same law/proof workflow to a helper only
after its inclusive cost and expected saving are demonstrated. Keep the 45 exact
products as a cheap program-speed continuity gate, and reserve the full native
chain for a candidate with a material measured benefit.
