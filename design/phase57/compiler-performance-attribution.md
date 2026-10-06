# Phase57: explain the compiler execution gap

## Objective and scope

Identify where time goes when the same Bend compiler source executes as an
upstream-generated image, the optimized checked B1, or the self-emitted B2.
Compare those results with the handwritten pinned TypeScript compiler. Gather
profiles, source comparisons and discriminating measurements before selecting
another production optimization. The installed Phase56 compiler remains intact.

Phase56 found B1 at 2.84–3.11× TypeScript time and B2 at 5.08–5.55× on two fresh
library requests. B2/B1 is about 1.79×. Those measurements combine compiler import
and first request; B1 also has equality/choice/tail-choice image transformations.
The warmed 45-point program corpus does not include this full compiler workload.
None of these ratios is an inherent language-speed ratio.

## Frozen comparison

All three Bend images implement the exact source
`5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244`.
Use the existing genuinely checked attempt; no new bootstrap is needed.

| Role | Image | What the comparison can separate |
| --- | --- | --- |
| raw | Original checked upstream-generated API from checked-string01 | Upstream code generation without the reviewed extra image transforms |
| source | Derived B1 API `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea` | Equality/choice/tail-choice transformations as a group |
| direct | Qualified direct B2 `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e` | Our emitted representation, calls and runtime behavior |
| typescript | Unmodified upstream at `018751270e800bc222a93dad7f257083ee53a5f7` | Different source implementation, algorithms and normal pipeline |

Keep Node 24.18.0, CPU3, exact fixture source and output semantics fixed. The
three Bend roles must emit identical complete library bytes. TypeScript's output
must satisfy the same value oracle, not match another compiler's text. Record
each role's image/runtime/driver/Base provenance separately. A B2 is not a new
checked attempt and must never acquire a counterfeit bootstrap sidecar.

## Hypotheses and falsifiers

1. **Startup and tiering dominate the B2 gap.** Separate actual API import, first
   request and repeated ordinary requests in one process. A persistent warmed
   gap falsifies startup as the complete explanation.
2. **B1's extra transforms account for most of the gap.** Compare raw upstream
   output, derived B1 and B2 on the same source. If raw and derived have similar
   cost while B2 remains slow, these transforms are not the main explanation.
3. **Generated representation/calls cause extra work.** Correlate hot CPU and
   sampled-allocation frames with matching emitted functions. Static closure,
   wrapper and object counts alone do not establish this claim.
4. **The Bend port performs more work than the handwritten compiler.** Compare
   source representations, indices, substitution, checking and backend stages.
   Require concrete source paths and a proposed counter or ablation; unlike B1
   versus B2, these implementations do not have identical algorithms or pipelines.

## Measurement sequence

### A. First request and repeated requests

Reuse the Phase56 Evening and lexer fixtures. Three rotated fresh-process rounds
per input and four roles give 24 fresh workers. Each worker separates host import,
actual compiler API load, first checked library request and three subsequent
ordinary requests. Keep individual observations, medians and ranges; do not call
three repeated requests proven steady state.

Prime each Bend role's own API-keyed Base disk cache in a separate preparation
process. Record cache contents and verify no input changes. Repeated library
requests use the ordinary driver; replacing it with the persistent parse/check
interface would change the work. TypeScript retains its normal checked path.
Report these cache-policy differences explicitly. Preflight hashing and all
output-oracle work remain visible and outside clean request clocks.

### B. Stage timing and CPU sampling

Use the existing driver phase trace for coarse stage windows in separate
diagnostic runs. Distinguish discovery/Base handling, checking (including current
ABI specialization), annotation, source/emitted reachability, layout and emission.
Trace boundaries do not necessarily name every operation within a window.

Capture short Inspector CPU profiles of matched requests, after separately
recorded imports/warmup. Preserve self and inclusive weights, GC, Node and harness
frames and unmapped samples. Do not sum inclusive costs as disjoint time. Use
sampling rather than instrumenting every recursive call. Do not use the full
offline V8 log processor that exceeded its heap allowance in Phase56.

### C. Allocation and V8 decisions

If CPU profiles suggest allocation or dispatch costs, collect sampled allocation
profiles including collected objects, in separate runs. Report estimated bytes
per completed request, not retained memory or exact allocation counts. Inspect
optimization, deoptimization and inlining only for the identified hot functions.
Bound logs and use filtered graphs/assembly only where they answer a concrete
question. Diagnostic durations never become clean speed ratios.

### D. Generated code and source algorithms

Map hot names/locations across raw/B1/B2. Compare corresponding function bodies,
tail-call/control-flow forms, closures, argument handling, native operations,
public conversion wrappers and allocation sites. Inspect the actual B1 transform
inventory; do not assume a missing identical source rewrite means B2 lacks an
equivalent optimization. Compare the handwritten compiler's source only where
the operations are semantically comparable.

Confirm leading findings on the complete compiler's source check or a focused
real compiler stage. Avoid repeatedly spending 251 seconds on self-reproduction.
If necessary, use a privately instrumented, hash-bound diagnostic derivative and
prove its uninstrumented outputs against the original. Any ablation is an
experiment, never an installed optimization or universal correctness result.

## Execution and publication

Root owns all target execution. Heavy work runs serially with a 1 GiB Node heap,
2 GiB process-tree RSS limit and 4 GiB available-memory floor. Agents prepare
admission, timing, profile analysis, generated-code analysis, upstream comparison
and independent review in parallel. Individual workers have deadlines; failures
and partial captures are preserved, with fresh versioned successors when needed.

Start with one valid preparation/sample per role before the full matrix. Stop
expanding a diagnostic once it no longer discriminates plausible causes. The
first useful ranking should fit roughly 30–60 minutes; additional information
gathering follows evidence rather than a fixed exhaustive profiler matrix.

Write new tools under `selfhost/tools/performance/phase57/`, raw receipts under
`selfhost/build/phase57/`, and findings under `implementation/phase57/`. Preserve
all 103 unrelated workspace files, the installed release, and closed Phase54–56
raw trees. Freeze consumed methods; amend via new versions after execution.
Commit and push designs, results and durable evidence using existing user
authorization. No upstream PR comment is authorized.

The final report must distinguish measured cost, structural observations,
plausible causes and demonstrated causes. Deliver a role/stage cost table,
profiles and hot-function comparisons, remaining uncertainty, a cheap repeatable
investigation loop, and ranked next optimization experiments with likely scope.
