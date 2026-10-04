# Phase43: direct execution across complete operations

Prospective design, 2026-10-04. User authorized all recommendations after
Phase42: whole-operation Map/String lowering, a reusable typed call/layout
plan, fewer temporary products, known callbacks, cheaper entry checks and
further fusion. Implement useful general rules, preserve correctness, measure
against pinned TypeScript, document decisions, and push incremental commits.
No upstream migration or PR comment is part of this work.

## Baseline and objective

Start at commit `714c5f5`, installed Phase42 checked16,
API `63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`.
Pinned upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.
The maintained corpus has 45 points, 23 sources and 23 families. Phase42 takes
8.862 times TypeScript's execution time with equal point weighting, or 11.421
with equal source weighting. Only one point is faster than TypeScript.

| Family / point | Runtime / TS | Estimated allocated bytes / TS |
|---|---:|---:|
| Tree8 | 1.223 | 1.09 |
| List512 | 0.605 | 0.15 |
| BST64 | 6.651 | 2.77 |
| Map128 | 91.391 | 48.59 |
| Lexer8 | 90.808 | 56.52 |
| Raytrace | 19.763 | about 74 |

These are corpus observations, not general language guarantees. Allocation is
sampled; raytrace has only one completed profiled call. Source grew 1,158 Bend
lines in Phase42, to 20,056. Compiler request costs were mixed. Track these
separate costs instead of treating generated-program speed as the only metric.
See [the measured baseline](../../implementation/phase42/README.md) and
[profiles](../../implementation/phase42/profile-findings.md).

Target broad execution parity and selected cases below half TypeScript's time.
This is a target, not a predicted outcome or permission to weaken the contract.
Report every family, the aggregate weighting, regressions, and cases that still
use generic execution. Preserve all original inputs and comparison algorithms.

## Phase 0: controlled baseline and cheap falsifiers

Freeze identities and preserve the 103 unrelated starting files. Reuse the
published Phase42 current modules and pinned TS modules, rebinding role labels
with recorded provenance. Historical raw directories remain closed. Run fresh
comparisons under the same process, warmup, CPU and memory protocol; historical
ratios only supply context. Keep original failures and unsuccessful experiments.

Each owner first delivers a saved-JS experiment, a byte-identical control, an
ordinary-entry activation witness, complete result controls, and exact commands.
Do not build the compiler to discover whether removing an alleged cost helps.
Do not count added functions as useful admission unless the measured entry
actually executes them. Separate CPU/allocation diagnostics from clean timings.
Use a 20-second rejection screen, then 60-second confirmation for a survivor.
Preparation and semantic controls are outside these timing budgets.

## Phase 1: complete String and Map operations

Prove one enclosing operation's dependency identities, representations and
absence of unmodeled observers. Within it, use fixed-arity direct calls, direct
matches and explicit loops/continuations. Preserve public descriptors and exact
fallback for unsupported arguments, partial application and changed bindings.
Entry guards may be shared only while callbacks cannot invalidate the proof.

Lexer first needs exact String/Char handling, literal template dependencies,
Boolean native metadata and the complete gen/lex/step graph. String splitting,
construction and Unicode behavior must retain their checked boundaries and
mutable host-hook observations. Test direct but materialized execution before
any fusion of generation and consumption.

Map needs the entire relevant seek/put/ins/pop operation and supporting calls.
Keep the crit-bit algorithm, keys, ordering, reconstructions and aliases.
Never trust a returned mutable graph merely because it was once privately
allocated. An enclosing scalar operation with proved nonescaping graphs is a
possible first domain. Record exactly where any prototype relies on manual
knowledge, and replace it with a source proof before promotion.

Prior per-edge Map.bit guards regressed 30–44%; a comparator substitution gained
only 0.5–3.1%. Test guard amortization separately from whole-operation lowering.
Planning hypotheses: 2–5 times faster for a useful initial subset, potentially
5–20 times for most of a hot graph. High complexity and low numerical confidence;
even the upper range would not by itself close a 90-times deficit.

## Phase 2: reusable typed direct lowering

Evolve the existing typed term and request-local plan machinery. Record live
arguments, saturated known calls, exact constructor layouts, tail edges and
required return continuations. Separate source facts from invocation ownership
and host proof. Missing, malformed, fuel-exhausted or unsupported plans refuse
specialization. Cache keys retain all contextual identity and type information.

Use lexical private workers for complete admitted graphs. Unknown calls keep
generic handling; native String, parameterized ADTs and callback escapes have
explicit capabilities, not blanket purity whitelists. Two unrelated consumers
must justify a shared abstraction. Migrate existing consumers and delete replaced
walks/emission where possible; parallel machinery alone is not simplification.
Do not merge strict closed-container equality with legacy vector policy.

## Phase 3: temporary products and known callbacks

For BST, isolate residual generic build/insertion from temporary down-path and
product allocation. For raytrace/records, identify the actually executed generic
helpers and fields before choosing layout work. Compare unchanged data with
direct calls against direct calls plus local scalar slots. Keep fresh allocation,
sharing, returned layouts, floating-point rounding and deep stack behavior.
Hypotheses: 2–4 times on BST; 3–10 times on eligible ray/record work, lower confidence.

For known callbacks, capture values in direct arguments and lower known calls
without per-element dispatch. Preserve fresh captured bindings and real unknown
function values. Keep lists materialized for the first comparison. Earlier
callback experiments paid module-wide permission costs and regressed: isolate
that effect before repeating them. Hypothesis: 2–5 times on eligible closure work.

## Phase 4: equivalent entry checks and fusion

Remove duplicate per-invocation checks and temporary descriptor arrays while
retaining the same acceptance, property observations and fallback behavior.
No mutable facts are cached across public invocations. Error callbacks suspend
proof, and reentry must not inherit stale permission. Standard intrinsics at
module initialization are the existing contract, not a new exemption.
List512 spends about 56% of sampled CPU in host/scalar entry checks: this is a
specific 1.2–2-times hypothesis for affected short operations, not all programs.

Once direct execution works, eliminate measured nonescaping intermediate strings,
lists or records with producer/consumer fusion. Total operations or an exact
demand-order proof are required; source purity alone permits neither earlier
errors nor callback reordering. Compare against direct-unfused execution.
Hypothesis: 1.5–4 times on suitable pipelines, overlapping other estimates.

## Phase 5: integration and one usable release

Combine only supported winners. Build checked B1 after real source changes,
test each changed mechanism and every consumer of shared predicates immediately,
and retain the existing scalar-island selection priority. Inspect generated
activation and generic call counts as well as complete result agreement.

Freeze before broad qualification. Inherit Phase42's reviewed semantic owners,
3026 + 196 frontend observations, 81 backend outcomes, 154 application cases,
release/CLI checks and appropriate representation/guard/deep witnesses. Keep
shared failures and N/A distinct from successful executions. An unchanged
artifact's completed checks can be reused with exact bindings; never transplant
success to different source/runtime bytes. A checked B1 derivative is not a
new self-emitted fixed point.

Measure all 45 points with Phase42/candidate/TS roles using three serial batches
when the full protocol exceeds one 600-second ceiling. Report compiler request
latency, source lines/definitions, emitted bytes, memory, ranges and regressions.
Install only the qualified winner; preserve the previous usable release.
Publish portable benchmark bundles and commands, mechanism documentation linked
from README, full experiment outcomes, accounting and exact replay evidence.

## Ownership, resource limits and efficient execution

Root owns production integration, all heavy execution, installation and commits.
Seven independent roles cover String/lexer, Map, products, callbacks/fusion,
guards, validation and independent review. They own disjoint Phase43 folders
and supply patches; they do not edit shared production or historical evidence.
Initial concrete handoffs target 15 minutes, with blockers reported early.
Reuse owners for follow-up work and reviews instead of launching duplicate work.

Node24.18.0, normal CPU3, 1GiB heap, 2GiB aggregate process-tree RSS and at least
2GiB available memory. Heavy compilation, acquisition, profiling and timing stay
serial through existing supervisors. Stop agent target execution during timing.
Parallel static investigation is useful; concurrent benchmarks are not.

Keep an enclosing job ledger from setup onward. Distinguish executed tool time
from analysis/editing/review and unclassified wall time; do not label the latter
idle or model latency without evidence. Inspect decisive results promptly and
stop failed hypotheses before widening source complexity. Broad qualification
is a release gate, not the default inner loop.

Plans live here, hypothesis records in `experiments/phase43`, outcomes in
`implementation/phase43`, maintained tools in `selfhost/tools/performance/phase43`,
and new raw outputs in `selfhost/build/phase43`. Commit this design first, then
experiment checkpoints and validated changes, and push to `origin/selfhost/bootstrap`.

## Final integration resource clarification

Runtime comparisons, compiler experiments and all independent heavy jobs remain
serialized on CPU3 with the 2GiB tree limit. The inherited, reviewed full frontend
gate is an explicit exception: it uses its existing two-worker CPU3,4 pool,
1GiB heap per worker and3GiB combined tree-RSS supervisor, with5GiB prelaunch
headroom and the2GiB available-memory floor. No other heavy job runs alongside it.
This preserves the existing frontend/auditor protocol and avoids new validation
framework changes solely to change worker count; the host has about28GiB free.
