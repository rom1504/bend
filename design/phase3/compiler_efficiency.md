# Phase 3: efficient compiler, generated programs and development loop

## Objective and scope

Make the compiler written in Bend substantially cheaper to develop, validate and
run, and improve the runtime performance of programs it emits. Preserve language
semantics, complete checking gates, diagnostic behavior and reproducible evidence.
The user authorized implementation of all six proposed workstreams, parallel
agents, comprehensive reporting and the existing commit/push workflow. There is
no new three-hour cutoff: the earlier phase 2 window has ended. Work continues
through implementation, integration and appropriate final validation.

An optimization is successful only when a controlled experiment demonstrates its
benefit and its correctness gates pass. Do not ship speculative rewrites merely
to claim that every idea was implemented. For a falsified hypothesis, retain the
experiment and pursue a materially different bounded alternative. Document any
remaining limitation precisely. Full language conformance remains a separate
objective; existing negative-diagnostic mismatches and hardware gates cannot be
converted into passes by making the implementation faster.

Commit this design before production changes. Freeze the phase 2 sources,
compiler artifacts, runtime and host tools first. Keep the implementation and
running evidence under `implementation/phase3/`, with executable recipes in a
repository document linked from both READMEs. Commit and push coherent tested
milestones throughout, then complete a consolidated report.

## Measured baseline and interpretation

The exact phase 2 revision is `f92d922`. Pinned upstream remains
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Never modify the human-written upstream
`bend2/bend.ts` or its fixture oracles.

* Checked bootstrap B1: API SHA `794cbf5f00a0a3a29f53821d530d27211c217a0636da14082adcbb18f4e5f2b6`.
* Proven self-emitted H: SHA `0b2b86aba15cda5ff7536b870f5ad3f372c7b159b8c77225e03715e5a969b7c3`.
* Compiler source: SHA `266933eb2ee6aa0d406a48b19f5bbe0250c6685e9f5f2d9fe276bc38bac31784`.
* A fresh checked bootstrap plus 21 live differential cases took 40.467 seconds;
  the bootstrap itself took about 22 seconds.
* Cached small-workload process medians: B1 1.60–1.81 seconds, H 3.16–3.45 seconds,
  pinned TypeScript about 0.69 seconds. H's first Base cache build cost 14.9 seconds.
* Full compiler-source emission: B1 784.367 seconds, H 2,921.261 seconds, native
  compiler execution about 312 seconds, pinned TypeScript process 48.261 seconds.
  These full-source runs are separate observations, not interleaved medians;
  export contracts differ between the port and upstream as documented in phase 2.
* One rejected Base fixture took 10.378 seconds with reporting and 0.738 seconds
  with presentation exports removed experimentally. Detailed checking replay cost
  about 4.7 seconds and source-origin reconstruction about 4.9 seconds. This
  experiment did not preserve diagnostic output and is not a production fix.
* The full frontend sweep took 68 minutes; checker-rejected observations consumed
  about 34 minutes. A 10x gain only in those observations cannot make the entire
  sweep 10x faster.
* H's full trace intervals include checking/post-check work 617 seconds,
  annotation 604, layout/foreign preparation 546 and emission 948. These include
  host work and GC and are not inner-function CPU measurements.
* On one successful 500-row fixture, H application/forcing/global helpers account
  for 49.4% of sampled time. Earlier guarded direct-call and positional-worker
  interventions yielded only 1.03x and 1.05x. Do not repeat those unchanged or
  interpret a profile percentage as an achievable speedup.
* A prior guarded scalar specialization saved about 9% in a disposable experiment.
  Three generated B1 `String.cmp` workers account for 17.3% of the recent sampled
  successful fixture; this is a concrete component-probe candidate.

The baseline manifest records copied sources, tools, runtime and actual B1, H and
native binaries before edits. Historical reports retain their original meaning;
never rewrite their hashes or retroactively add stronger provenance claims.

## Workstreams, expectations and ownership

| Workstream | Planning target, not promised result | Initial ownership |
|---|---|---|
| Exact diagnostic reuse | 5–10x on slow rejected cases; perhaps 1.4–1.8x on the frontend sweep | Diagnostic agent |
| Native large-build workflow | Reuse the already demonstrated approximately 9x full-source advantage over H; include build cost separately | Root |
| Persistent validation workers | 1.5–3x on small batches if startup/decoding dominates | Root |
| Analysis, annotation and layout | Remove measured repeated traversals/normalization; phase gains must be converted to end-to-end gains | Analysis agent |
| JS scalar/string operations and generated-code performance | Confirm the prior scalar opportunity and isolate comparison work; no universal percentage assumed | Codegen agent |
| Emission and compiler-owned representations | Integrate only causally demonstrated improvements; coordinate across analysis/codegen | Analysis and codegen agents |

Agents own disjoint production files. Diagnostic agent owns `src/diagnostic/`,
necessary `src/load/` changes and `tools/typed-driver.mjs` integration. Analysis
agent owns `src/check/` and `src/back/native/`; codegen agent owns `src/back/js/`
and the JS runtime fragments/build output. Root owns harness worker changes and
native workflow orchestration. Shared interfaces must be agreed before edits.
Only root commits. Source changes should be atomic and buildable before another
agent captures a combined snapshot.

Reserve physical CPUs 0/1/2/3 for root/diagnostic/codegen/analysis work. Do not run
timed workloads on sibling hyperthreads of another experiment. Every timing
records affinity, resource limits, cache policy, source/tool/artifact identities
and shared-host limitations. Release CPUs explicitly when jobs finish.

## 1. Reuse authoritative work while preserving exact diagnostics

The current host has an authoritative checker verdict, then calls
`check_book_diagnostic`, which checks the whole book again and walks declarations
again to locate the failure. It subsequently calls `f_load_origins_for`, which
reloads the graph. Preserve the authoritative verdict and eliminate those
redundant operations.

Add a rejection-only diagnostic entry consuming the book and, when available,
the validated exact Base prefix. It must independently reproduce the first suffix
error, including final open-law checks, rather than echoing the authoritative
error supplied by the host. Verify exact prefix identity; rebuild
precisely the same prefix context and normalization bounds; start detailed event
replay at the unchecked suffix. Preserve event guards, declaration order,
`signature_mode`, first-error behavior and detailed failure fallback. Keep the
old public entry available. A mismatch must take the conservative original path,
never turn rejection into acceptance or skip a language rule.

Capture the actual graph's result and dependency/declaration-event order during
loading, rather than reconstructing that graph after failure. The proposed
`FLoadTrace` contains the final `FResult`, internal loaded-module trace and source
snapshots. Trace-aware seeded and unseeded APIs coexist with old loading APIs.
Internal entries retain declaration-event counts so freshened definitions align
with original module positions, including repeated law/fill events. Derive only
the failed definition's origins, lexing the necessary source where required;
never deduplicate declarations by name or use a regex parser in the host.

The host renders a detailed result only when its error equals the authoritative
error. Add ABI metadata for the new trace shape. Do not cache per-request graphs
across requests in this workstream. Preserve exact diagnostics, context, source
path, span, line/column and phase. Test missing/changed prefixes, Base as main,
imports, aliases, repeated declarations, first/middle/late failures and edited
source files. Compare production output with the frozen original implementation,
not with the presentation-disabled experiment. Measure negative and positive
controls with alternating fresh processes and include cold/warm cache costs.

## 2. Make native compiler execution a reliable reusable workflow

Provide a documented entry point that prepares immutable source snapshots,
performs the existing checked pinned compilation and native build, validates its
provenance, and reuses a matching verified artifact on subsequent invocations.
Keep build time, compiler execution time and generated-program runtime separate.

Reuse is an explicit artifact contract: match all compiler modules, graph/bundle
entry source, manifest, runtime, upstream pin/inputs and relevant host/build
options. Verify the binary and build report bytes before executing. Record the
actual toolchain, flags, environment allowlist, target and canonical paths; do
not claim a hermetic toolchain cache if dependencies are not fully captured.
A stale, incomplete, corrupt or ambiguously identified artifact must fail closed
or trigger a fresh checked build. Never substitute a JS compiler silently.

The supported compilation boundary is an explicit module/asset manifest. Retain
canonical module identity, required-only foreign reads, logical foreign binding
names, input/output alias protection, drift detection, bounded transport and
atomic output publication. Automatic discovery may be added only through Bend
compiler facilities; do not implement import parsing in host JavaScript.

Test cache hits/misses, changed modules/runtime/entry source, corrupt reports or
binaries, symlinks, failed builds and concurrent publication. Compare native and
JS output bytes when the same emitter/source/runtime applies, execute the emitted
programs, then repeat the full compiler-source parity milestone. Native execution
emitting matching JS is not a native-output fixed point.

## 3. Amortize compiler startup without weakening test isolation

Extend the existing conformance runner with an explicit persistent-worker mode.
The isolated mode remains the reference behavior and exact selected/full-suite
verdicts remain unchanged. Begin with adapter-declared parse/check support;
program execution, unknown/stateful adapters and unsupported modes stay isolated
or reject the requested mode explicitly. No silent capability relabeling.

Each worker handles one request at a time, imports the identified compiler once,
and may retain immutable compiler/validated Base data whose identity is checked.
Every request gets fresh graph/context state and its own request, response and
bounded logs. A worker cannot retain a previous fixture's declarations, verdict,
source origins or foreign state. Do not trust a cache just because its mtime is
unchanged. Request input identities and before/after artifact checks continue.

Use a framed bounded protocol. Enforce per-request deadlines from the parent;
kill the worker's entire process group on timeout, overflow or protocol failure,
then restart for the next request. Distinguish startup time, request time and
restarts in reports. Recycle workers after a bounded request count and/or memory
limit. Ensure late messages cannot complete a later request.

Retain both a fresh isolated replay command and enough session context to replay
a persistent sequence where necessary. A cached result must never replace a real
request evaluation. Freeze new worker/protocol tools in immutable paired attempts
and include their identities in reports. Support both candidate and reference
only where the adapter contract permits safe reuse.

Test reordered mixed positive/negative cases, duplicate requests, edited modules,
Base changes, malformed protocol, timeout/overflow recovery, process cleanup and
long sequences for memory/state growth. Compare exact observations with isolated
runs. Benchmark the same selections in alternating isolated/persistent mode with
identical resources and report cold startup separately from steady-state time.

## 4. Eliminate measured redundant analysis and layout work

Build bounded phase/component probes from frozen compiler books, with the same
book identity and checking prerequisites. Separate algorithm time, ABI transport,
startup, output serialization and GC where measurable. Count operations in a
separate untimed run; instrumentation timings are not speedup measurements.

Concrete read-only hypotheses to validate:

1. `ka_node(App)` asks for the type of an entire function prefix and recursively
   annotates that prefix again. A single application-spine traversal may avoid
   repeated inference while preserving dependent substitutions and exact `Ann`
   structure. Measure depth scaling and normalization/substitution counts first.
2. Native telescope helpers normalize the same unchanged telescope two or three
   times per step. Bind the normalized value once, preserving evaluation order,
   failure behavior and ownership; compare emitted C byte for byte.
3. `nc_context_defs` repeatedly searches an uncached annotated definition list,
   sometimes twice for a hit. Build the existing persistent index once without
   changing first-match semantics, returned order or context selection.
4. `signature_mode(d,later)` queries a raw suffix for each law. An indexed reverse
   pass could precompute the nearest later declaration while preserving event
   order and exact duplicate/unsafe-law/first-error semantics. This is elimination
   of suffix scans, not another replacement of the already improved index.

Do not memoize type results across different contexts, substitutions or ownership
states without a precise key and proof argument. Preserve all checker gates.
Use exact checked/annotated representations and emitted bytes where these changes
do not intentionally alter code generation. Include positive and negative proof,
affine, shadowing, repeated declaration and fresh-binder cases.

## 5. Improve generated code with semantics-preserving runtime operations

Measure compiler throughput and emitted-program runtime independently. Preserve
full checking while compiling benchmark programs. Include representative scalar,
string, comparison, closure, application, ADT and allocation workloads; retain
negative and boundary controls so a fast wrong result cannot pass.

Start with a production string-comparison implementation after the pinned Base
API establishes exact semantics. A single-pass code-point comparison may replace
recursive character splitting/reconstruction. `String.cmp` returns the original
strings and a comparison constructor; retain that exact shape and values. Preserve
BMP versus astral ordering and malformed UTF-16 demand/error order: an invalid
suffix after an earlier mismatch must not become an eager whole-string error.
Test empty/prefix cases, partial application, overapplication and user definitions
with the same name. Only eligible Base-origin definitions may become intrinsics.

Then reconsider the previously measured scalar specialization on fresh artifacts.
For known saturated non-tail primitives, evaluate the live callee before operands,
preserve left-to-right evaluation and guard the actual primitive identity, code,
arity, environment and bound arguments. Retain generic fallback for mutation,
partial/overapplication and higher-order calls. Tail trampoline semantics and the
public argument-copy contract remain intact unless separately proved and tested.
Do not repeat a broad guarded positional-worker rewrite justified only by a large
runtime profile share.

Runtime source fragments are canonical; regenerate `src/runtime.mjs` with the
existing builder and test runtime equivalence. Actual optimized emitted text may
intentionally differ from the old emitter. In that case require identical program
behavior and semantic/ABI oracles, not old code-byte identity. New self-emitted
compiler stages must still reproduce exactly after the candidate is frozen.

## 6. Emission and representation experiments

The full-source emission interval is large, but that alone does not establish
its cause. Profile a bounded emitted-code workload and scale expression depth,
output size and definition count separately. Distinguish AST/type traversal,
layout work, output construction and runtime dispatch. Avoid repeating the
unsupported claim that right-recursive definition emission appends to a growing
prefix; prior inspection found no such evidence.

If repeated child-output copying is demonstrated, test fragment accumulation or
an equivalent linear builder with exact fully consumed output. If repeated type
facts dominate, reuse them within the immutable compilation context. Production
changes must follow a successful isolated intervention and realistic benchmarks.
A component speedup is not multiplied by another speedup without measuring their
combination. Record null results and pursue the next measured bottleneck.

## Experiment and integration sequence

1. Freeze and hash the baseline; commit this design and evidence manifest.
2. Run independent short baseline/prototype/correctness probes on reserved CPUs.
   Use checked B1 builds and component capsules for source edits. Do not invoke
   a 49-minute self-build for every experiment.
3. Integrate only production candidates that preserve their semantic contracts
   and show useful measured benefit. Retain temporary ablations separately.
4. Build one combined checked candidate, run component, frontend, host and backend
   tests, then compare the combined performance with the frozen baseline and
   live pinned TypeScript. Include generated-program runtime and output size.
5. Freeze the combined source/API/runtime/host before broader frontend, JS/native
   execution selections and the checked JS self-reproduction chain. Keep the
   experimental native full-source parity check separate.
6. Review failures rather than expanding timeouts or weakening diagnostics. Any
   optimization-induced regression blocks promotion until fixed or reverted.
7. Publish complete evidence, runnable documentation, a candid comprehensive
   report and the final pushed commit. Do not promote default artifacts merely
   because selected tests pass; document the exact tested distribution choice.

Each experimental subprocess has an explicit deadline, output cap and immutable
attempt directory. Meaningful tests should validate observable semantics and
trust boundaries, not mirror implementation details. Report exact workload and
cache scope beside every speedup, including unsuccessful experiments and costs
moved into preparation. Keep whole-language conformance, selected coverage,
artifact reproducibility and performance as distinct claims.
