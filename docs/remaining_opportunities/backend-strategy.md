# Backend strategy: retain JavaScript, evaluate the existing C path

Decision note, 2026-10-04. Baseline: selected Phase45 worker23; architecture
survey committed in `8961ca3`. This records a recommendation and proposed
experiment, not a target migration, implementation change or new measurement.

**Follow-up:** the bounded [Phase46 experiment](../../implementation/phase46/README.md)
is now complete. All72 fixed-work timing samples pass. Our C is slower than our
JS on five selected workloads and roughly tied on closures, while upstream C wins
on all six. Allocation/continuation diagnostics support improving high-level
lowering first. Native IO.args has a reproduced compatibility gap. Keep JS primary;
these six batch workloads do not replace the maintained45-point JS result.

**Keep JavaScript as the maintained primary target. Evaluate the existing C
backend in a bounded comparison before reallocating the optimization effort.
Defer direct LLVM IR and machine-code generation until a measured limitation
justifies their additional engineering and maintenance.**

The [ranked optimization proposals](README.md) remain recorded and applicable.
Shared value/use/effect facts, known function flow and aggregate elimination
address language-level work that can matter across output targets.

## Three decisions that must remain separate

1. **Where the compiler runs.** A native executable of the compiler written in
   Bend could still emit JavaScript. This might accelerate checking/emission and
   validation without changing user-program output semantics.
2. **What user programs target.** JavaScript versus native changes deployment,
   runtime representation, interoperability, compilation stages and performance.
3. **Which optimizer generates native machine code.** C through Clang already
   uses LLVM. Emitting LLVM IR directly changes our interface to that optimizer;
   implementing a machine backend makes more of its responsibilities ours.

Current host orchestration calls a generated JS compiler library through
[`typed-driver.mjs`](../../selfhost/tools/typed-driver.mjs). Running the compiler
itself natively needs a validated request/FFI/driver interface; it is not just an
output flag. Historical native compiler experiments exist, but their old
artifacts and restricted input protocols do not establish current compiler speed.
See the [retained Phase1 run](../../implementation/phase1/rapid-evidence/native-compiler/o1-runs/compiler-parity-600.json)
for an example with its own scope and identities.

## What each option would buy

| Target | Useful properties | Costs and limitations for this project | Recommendation |
| --- | --- | --- | --- |
| JavaScript | Existing API, qualification, fast source-to-run path, V8 optimization and host tools; direct comparison with reference JS | GC/object representation, JIT startup/variability, mutable public descriptors and host observations | Continue as primary while broadening the shared optimizer |
| C through Clang | Existing backend/runtime, native layouts and explicit ownership, mature machine optimizer, CPU/native deployment | Separate segment/runtime path; external compile/link cost; native semantic and memory obligations; current quality unmeasured on the full corpus | First native alternative to test |
| LLVM IR | Explicit low-level operations, attributes, layout and control; direct access to LLVM passes and target code generation | New lowering and verifier obligations, LLVM compatibility, runtime/ABI/debug integration; optimization/codegen costs remain | Consider after C exposes a specific limitation |
| Direct assembly or object code | Potentially cheap predictable code generation and fine control of incremental output | Instruction selection, register allocation, calling conventions, relocations/object format or assembler integration, debug/unwind support, portability and optimization quality | Poor next investment for our current runtime-speed gap |

These are engineering judgments, not measured speed rankings. Native code can
be faster or slower depending on representation and workload; no credible
universal multiplier follows from the target name. A simple direct machine
backend can compile quickly while producing slower code than an optimizing
backend. Text assembly delegates encoding to an assembler, but still leaves
most machine-lowering and ABI decisions to us.

C is not a detour that forfeits LLVM optimization: our
[`native-build.mjs`](../../selfhost/tools/native-build.mjs) invokes Clang with
`-O3`. Direct LLVM IR could express information differently and avoid C parsing,
but neither stronger optimization nor shorter total compilation is automatic.
It must also preserve exact arithmetic/errors rather than accidentally introduce
undefined behavior or invalid attributes. LLVM specifies these obligations in
its [IR reference](https://releases.llvm.org/21.1.0/docs/LangRef.html).

## What our current code and measurements imply

Our current 3.0787× equal-point slowdown compares **selfhost-generated JS with
upstream-generated JS on the same runtime**. That gap cannot be attributed simply
to choosing JavaScript. It reflects different emitted shapes and execution
protocols. It also does not prove that JavaScript is the best ultimate target.
[Current results](../../implementation/phase45/results.md)

The native backend is substantive: `nc_compile`, type-directed erasure,
`N_Segment` lowering, closures, ownership keep/sink operations, arrays, direct
calls and parallel segments feed a C runtime. It does not invoke the upstream
TypeScript native emitter. However, it is **separate from JW** and does not
automatically receive the recent private-worker optimizations. Generic boxing,
dispatch and incomplete reproduction of upstream layout/borrow/static-data
optimizations remain possible costs even after Clang optimization.
[Architecture](../self_hosted/architecture.md#native-backend-and-external-optimization-boundary),
[native source guide](../../selfhost/src/back/native/README.md)

Existing CPU qualification is scoped evidence, not native performance parity or
proof of GPU behavior. The historical origin in the native source guide is not
a new upstream pin. Physical Metal/CUDA execution remains unestablished here.

Native programs need not implement the JavaScript library's mutable descriptor
protocol, because their host ABI is different. That can remove costs for native
applications, but abandoning the JS API is a product-scope change rather than a
like-for-like conformance optimization. Compare shared source-language behavior
and backend-specific interoperability independently.

## What Zig actually demonstrates

The source survey uses a pinned historical Zig release; a follow-up check read
the official **0.16.0 release notes** for this decision. They describe the x86
backend as the Debug default, with faster compilation and lower machine-code
quality than the LLVM backend. They also describe incremental support for the
LLVM backend while noting that LLVM object emission is still a separate cost.
This supports separate development-latency and release-code-quality strategies;
it does not imply that direct assembly is the fastest route to our program-speed
target. [Official release notes](https://ziglang.org/download/0.16.0/release-notes.html#x86-backend),
[LLVM/incremental discussion](https://ziglang.org/download/0.16.0/release-notes.html#incremental-compilation)

The transferable lesson is to measure and avoid repeated work, preserve compact
per-function representations and choose optimization effort by use case.
Its release figures are not Bend speed estimates. Our
[Zig source study](../../research/compilers_architecture_and_techniques/zig.md)
records the relevant storage, liveness and dependency mechanisms.

## The smallest fair experiment before switching

Choose 6–10 existing representative source programs covering scalar numerics,
lists/trees, records/Map, strings, higher-order functions and arrays. Use only
the common supported language/FFI domain and retain unsupported cases explicitly.
Start with one CPU thread and fixed affinity; multicore/GPU performance is a
different experiment. No source-program or backend implementation changes are
needed to define the comparison.

| Producer | JavaScript output | C output through the same pinned Clang |
| --- | --- | --- |
| Pinned upstream compiler | Existing JS reference | Native reference |
| Selected selfhost compiler | Existing selected JS | Existing native candidate |

The selfhost-JS/upstream-JS and selfhost-C/upstream-C ratios measure backend
quality within a target. The two cross-target ratios inform deployment choices.
Beating upstream JS with selfhost C would be useful, but would not establish
native parity if upstream C is much faster still.

Validate full values, errors and relevant alias/effect observations first.
Match useful work, thread count and observation boundaries; do not compare a
native checksum-only loop with JS full-result validation. Separate:

- Bend parsing/checking/emission;
- C compilation/optimization/linking;
- startup, data conversion and JS warmup;
- warmed execution of equivalent validated work;
- peak RSS, allocation where measurable and output size;
- full edit-to-result latency, including cold and cached cases.

Native batch loops must consume results and prevent whole-loop constant removal
without adding asymmetric observer costs. Timings stay serial and isolated;
the proposed throughput scheduler applies to non-timing work only.

For an execution workload repeated N times, compare the complete cost:
`check + emit + toolchain + startup/warmup + N × execution + observation`.
For the compiler itself, compare frozen compiler requests separately and account
for the cost of rebuilding the native compiler during development. Faster
steady execution can lose on short iterations; cached native artifacts can
change that tradeoff. Measure both rather than assuming either outcome.

## Conditions for changing direction

- Expand native investment if the existing C route wins repeatably across useful
  independent families, has acceptable semantic coverage, and improves the
  relevant end-to-end workloads rather than only a favorable inner loop.
- If current native output is slow because of boxed values/dispatch, first test
  shared semantic optimizations and native representation improvements. Merely
  printing the same runtime operations as LLVM IR will not remove that work.
- Consider direct LLVM IR only after identifying a concrete C-lowering limit:
  missing useful attributes/operations, measured C frontend overhead, or a
  required feature whose correct C expression is materially worse.
- Consider a custom machine backend only if native code generation/linking
  becomes a dominant development cost and we are prepared to maintain target
  ABIs and code quality. That is a larger strategic investment than the next pass.

Keep future shared semantic operations independent of JS spelling where useful,
but do not force a wholesale IR unification before an actual second consumer.
The next justified code work remains the bounded optimization plan; the native
comparison is a proposed decision experiment, not an instruction executed here.
