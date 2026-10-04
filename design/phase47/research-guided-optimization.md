# Phase47: research-guided general optimization

Plan frozen before target execution, 2026-10-04. Parent: Phase45 worker23,
repository `da464d3`; pinned TypeScript compiler
`018751270e800bc222a93dad7f257083ee53a5f7`. Phase46 is closed evidence.

The objective is faster generated programs through reusable compiler mechanisms,
with correctness, compilation cost and complexity measured separately. Keep JS
primary. Phase46 found our C slower than our JS on five of six common workloads;
a target switch would carry the same missing transformations into a slower loop.
The maintained 45-point JS result remains 3.0787 times TypeScript runtime. The
new Bend batch has a different call context and cannot replace that result.

## Research applied to decisions

Use the pinned [source surveys](../../research/compilers_architecture_and_techniques/README.md),
[current inventory](../../docs/self_hosted/optimization-inventory.md), and
[comparison](../../docs/remaining_opportunities/comparison.md). These are specific
lessons to test, not an instruction to reproduce another compiler's architecture.

| Evidence | Application | Constraint |
| --- | --- | --- |
| Rust and LLVM cleanup after enabling transformations | Follow bounded known-call/inlining changes with aggregate and dead-value cleanup | Discarding an unused value does not authorize discarding its evaluation; bound code growth |
| Go known-target discovery, inlining and escape analysis | Keep finite function targets and captures visible to a shared analysis | Unknown calls, public escape and effects terminate proofs |
| Lean local functions and join points | Preserve local function identity; simplify before duplicating continuations | Avoid exponential duplication and preserve demand-sensitive arity |
| Zig staged representations and explicit lifetime | Use compact immutable facts scoped to the current checked context | Cache keys and retained memory count toward compilation cost |
| V8 optimization of recognizable JS | Try a saved-output causal ablation before extending the compiler | Source operations and native allocation counters do not prove JS runtime cost |
| Upstream Bend direct calls and scalar transport | Prefer known saturated calls and private scalar fields | Upstream host semantics are not permission to weaken our public ABI |

Existing special paths already inline, scalarize tuples and handle some known
closures. Reuse and consolidate these mechanisms. Do not add source-name or
benchmark-name recognizers, another broad pattern catalogue, or a complete SSA
framework before one consumer has established its value.

## 1. Freeze, census and cheap causal screen

Preserve worker23 API and runtime identities, all 103 unrelated starting files,
closed Phase45/46 raw evidence and the installed release. Snapshot current status.
Five independent agents prepare bounded work: array ablation, independent
controls, remaining outlier census, shared-fact interface and compiler-cost
census. Root owns execution and integration. Parallelize source investigation
and review; serialize builds, timings and profiles using the maintained global
ExecutionGuard, CPU3, 1 GiB Node heap, 2 GiB process-tree RSS and 4 GiB available
memory floor. No PR comment is authorized.

Start with Phase46's exact saved array JS. Produce original, helper-shell,
backing-view and length variants with parent and function hashes. Keep read and
write Number conversions separate and cache only at first demanded access.
Compare values and independent batch digests, then rotated fresh-process timing.
These are diagnostic derivatives, not production-safe compiler outputs. Test
zero iterations, alias writes, mutable Number, storage replacement/resize and
opaque callbacks. Existing descriptor guards do not establish private ownership.

Reject array work as the first production change if removing the proposed work
does not give a stable useful gain (roughly 5% or greater in confirmation), or if
the proof needed is disproportionate. Retain a null or adverse result. Do not
keep rerunning the full corpus while a local hypothesis remains unproved.

Census the six largest residual points independently: Morning, Evening, generic
row, Map/Set, RLE and scalar-zero. Distinguish unsupported graphs, existing worker
cost and fixed public entry cost. Prefer a mechanism useful across unrelated
programs. RLE is already a worker; scalar-zero is not a long-loop speed estimate.

## 2. One minimal shared analysis and a measured consumer

Choose the first compiler change from the screen and census. Candidate consumers
are private array view reuse, finite local-function normalization, or bounded
private call expansion followed by scalar aggregate cleanup. Record the choice
and exact falsification condition before building it.

Keep facts separated: known target/capture, value uses, escape, effect, stable
backing identity/length, and permission to discard/duplicate/move evaluation.
Facts belong to an immutable checked book and contextual instance graph; changes
invalidate affected facts. Source dependency and primitive capability scans must
cover the original graph even if later simplification removes calls. Unknown or
unproved behavior follows the existing path.

Implement the smallest reusable contract needed by the chosen consumer, in the
existing IR or typed lowering. Avoid parallel representations with overlapping
walkers unless the migration and retirement path is explicit. Bound traversal,
specializations and generated-code growth. Initially prefer a private scalar
result boundary; public composite identity and sharing require a separate proof.

Independent controls must include renamed programs and counterexamples which
exercise a mechanism beyond the benchmark that motivated it. Preserve evaluation
and error order, descriptor mutation, callback reentry, alias writes and the
existing host contract. An attractive timing does not compensate for a mismatch.

## 3. Compiler latency as a separate experiment

Measure repeated checking/planning stages and queries before introducing reuse.
ABI2 receives a validated Base prefix but cannot safely skip rechecking merely
because the argument exists: the serialized prefix does not restore live memo
and diagnostic state. Prior broad memoization had useful hit rates but regressed.

Consider only context-complete, bounded request-local query reuse with exact
identity and explicit lifetime. Include key construction, misses and retention
in measured request latency and memory. An unchanged-output counter derivative
can select a hypothesis; it cannot establish production correctness or speed.
Keep this investigation from blocking a proven generated-code improvement.

## 4. Gate, qualify and consolidate

Build checked B1 candidates with the documented development workflow, one active
candidate at a time. Run the five maintained canaries before feature timing:
local-pair, local-fold, scalar-region-0, scalar-region-8192 and generic-row32.
Stop on semantic failure or a material unexplained regression. Then measure
affected families and independent controls in rotated serial order. Preserve all
attempts, including malformed fixtures, regressions and null results.

Only a surviving integrated candidate proceeds to affected backend/frontend
qualification, host-boundary controls and the representative corpus. Freeze
source/API/runtime/Base/tool identities before timing. Keep compiler request
latency, generated runtime, startup, code size, source size and memory distinct.
Profiles run separately from clean timing. Do not claim a new aggregate score
from a subset or count shared failures as successful conformance tests.

Promote only the qualified scope; otherwise retain worker23 and report what was
learned. Write the actual decision, gains and tradeoffs in
`implementation/phase47/README.md`, preserve a file per hypothesis, update the
ledger and steering, and document any new compiler mechanism in the IR guide.
Commit and push the design, useful intermediate checkpoints and final report.
The user authorized the campaign, not an unlimited rewrite: review direction
after a decisive screen or two unproductive implementation attempts.
