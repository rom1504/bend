# Phase42: direct generated programs, toward TypeScript parity

Prospective design, 2026-10-03; campaign starts18:12:27 UTC. Authorized task:
write a comprehensive roadmap, use parallel agents efficiently, execute the
experiments and implementation, write a report, and commit/push checkpoints.
Starting commit5ec82b3a92d92f46547215eca274c5bfecf47796, installed Phase41
checked01 API9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b.
The TypeScript target remains018751270e800bc222a93dad7f257083ee53a5f7. No upstream
migration, PR comment, or persistent Goal is part of this campaign.

## Outcome and honest targets

Primary goal: remove the large residual cost of generated JavaScript. Reach
parity, or half the execution time of the pinned TypeScript backend, on eligible
real programs while retaining public behavior and bounded-stack obligations.
Parity is a target, not an assumption or permission to alter the workload.
The current9.33–12.18× deficit describes three tree points, not the whole
language. Recent controls range1.14–2.58×; lists have separate older comparisons.
Halving TypeScript time from a10× deficit requires20× additional speedup.

Track per-point same-run Phase41/candidate/TypeScript ratios, paired ranges,
warmup/drift, complete values, allocation and generated shapes. Label any
aggregate by its exact corpus and denominator; retain family-level results so
several input sizes do not masquerade as independent program diversity.
Report compiler request cost and source/concept complexity separately. The last
phase added35 source lines and9.46% tree compilation cost; further runtime wins
must make their development cost and maintenance cost explicit.

## Evidence already established

Phase41 tree CPU samples put apply+invokeExact at19.46% of self time. Sampled
allocation is4.78MB/call versus1.39MB for TS, while GC self time is4.71%.
These are instrumented observations, not independent additive cost partitions.
Dispatcher cleanup alone cannot credibly promise a10× recovery. Larger direct
components may unlock JIT optimization that local sample shares cannot predict.
TS emits named saturated calls, direct field accesses and tail-cycle loops;
selfhost also retains descriptor application, tagged field arrays, generic
scalar helpers and explicit continuation storage. We will isolate each cost.

Narrow structural workers and acyclic wrappers already shipped. Phase39 guard
scope sharing and numeric countdown lowering also already exist. Do not
relabel them new work. Phase41 transfer-tuple scalarization was noise and is
rejected. Prior callback specialization regressed. Numeric host guards do not
cover String hooks. These results constrain new experiments.

## Sequential phases, parallel investigation

### 0. Freeze baseline and expose the remaining costs

Commit this design before source integration. Preserve the installed compiler,
all45 prepared points/23 source files, pinned TS modules, tools and input hashes.
Keep the103 unrelated starting files byte-identical; closed Phase41 and older
raw trees are immutable. Capture the baseline once, then compare fresh timing
roles in the same serial job; old timing numbers are context only.

Four independent owners prepare saved-output ablations: direct calls, compact
continuations, private representation, and total producer/consumer fusion.
Each must identify exact original bytes and mutations, create a byte-identical
noise control, separate instrumented and clean modules, and provide a complete
oracle/boundary test before timing. First discriminators should arrive in15–25
minutes; report a precise blocker at10 minutes rather than silently expanding.

A bounded direct-recursion variant may estimate a diagnostic ceiling. It cannot
be promoted if it abandons supported deep-stack behavior. A handwritten fused
loop may estimate headroom but is not a compiler optimization until a general
source rule emits it. Every prototype gets explicit eligibility limitations.

### 1. Complete the direct private component

Extend known-call lowering through the entire proved computation, especially
warp_leaf/key/Boolean helpers and existing tree workers. Keep original tagged
values first. Known saturated calls use fixed-arity workers; tail transfers use
existing loops; non-tail transfers keep an appropriate stack-safe plan. Complete
host/dependency proofs dominate the admitted region. Remove redundant proof
membership work only after proving that every internal caller supplies coverage.

Compare leaf-only, leaf+scalar helper, proof-check-only, and combined variants.
The planning hypothesis is1.3–3× on affected tree work, low confidence. Zero gain
or regression is possible. Any favorable result must survive ordinary export
entry and hostile public descriptors, not only direct private helper calls.

### 2. Reduce continuation and representation cost

First keep data fixed and replace repeated argument snapshots/rematching with
continuation labels and only live saved values. Verify both child orders, saved
parent fields, one-child cases, constructor and combiner continuations. Preserve
30000-depth behavior, alias identity, fresh nodes and reentrant separate stacks.
This is not the already rejected cosmetic $next scalarization.

Separately test one-object private Tree/Stat layouts, destination slots, and
range-proven numeric coordinates that still use BigInt. Keep the same algorithm
and intermediate values initially. Public representation, host getters, deferred
fields, identities and overflow/error timing remain unchanged. Count conversion
cost at real boundaries; a fast private kernel with expensive marshalling is not
a useful whole-program win. Conditional first-probe hypotheses are1.1–2× each,
low confidence and overlapping with direct-call/JIT changes.

### 3. Share facts and prove transfer

Analyze one compact set of live signatures, callees, constructors, demand,
control edges, host dependencies and ownership facts over existing typed terms.
Reuse request-local facts only with complete contextual keys. Start with exact
emission-preserving elimination of redundant planner walks. This helps reverse
compilation regressions and prevents every optimization adding another graph
walk. Introduce no general optimizer IR before a concrete shared consumer needs
it. Existing runtime protocols stay distinct where their semantics differ.

Require a second independently shaped fixture/workload for each generalized
rule, e.g. another tree mapping/sorting shape, lists, or Map/BST. Broader host
and String support is conditional on its own complete proof; do not claim
transfer from a tree-only result. Delete superseded analysis/emission paths once
all owner controls map to the replacement. Retaining both indefinitely does not
count as simplification.

### 4. Eliminate work beyond TypeScript's lowering

After direct execution, inspect allocations/traversals whose results never
escape. A narrow total U32 producer/filter/map/fold component can become one
loop. A destination-passing tree worker can avoid a measured temporary. Affine
or uniqueness facts may permit reuse only if all surviving host/source aliases
and observation points are covered. Purity alone never permits reordering errors
or callbacks. Start with total non-hooking operations over proved domains.

Compare fusion against the new direct-unfused control, not an old slow compiler.
Vary0/1 lengths, nonperiodic lengths, seeds, selectivity, overflow edges and
retained aliases; preserve all demanded callback/error order. Generalize by
source structure, never names or expected checksums. Potential1.2–3× improvements
are exploratory and eligible-workload-specific. Tree sorting is not assumed to
be a stream pipeline. This phase is the most credible path to0.5× TS on selected
programs because it removes work TS still performs; no universal forecast.

### 5. Freeze, integrate and publish one usable release

Combine only independently justified changes, measuring interactions. Preserve
stronger existing scalar admission priority: a previous broad Nat rule caused a
ray regression. Freeze source before full preparation and semantic integration.
Run changed modules with unaffected controls; byte identity justifies not
retiming every unchanged module, but does not create fresh whole-catalog data.

Mandatory release scope: checked B1, actual-emission mechanism controls,
independent heldouts, inherited semantic owners,154 expanded observations,
3026+196 exact frontend observations, retained81 backend outcomes, primitive/
worker/guard/component/HVM groups, ordinary release verification and42 relocated/
ordinary CLI checks. Keep4 shared main failures and backend69pass/8N/A/4fail
visible. These tests do not establish full GPU or independent proof conformance.
No new full fixed point is required for a checked B1 derivative.

Final reports link exact source/API/runtime/Base/Node/pin/module identities,
raw commands, failures, paired timings, profiles and archives. Freeze portable
baseline/current bundles with20/60/300/600-second instructions. Update the
compiler guide and README; install and push the selected validated release.

## Team, queue and efficiency

Root owns production files, integrating patches, heavy-job execution, admission,
release and commits. Up to eight independent owners work on disjoint paths:

| Owner | Deliverable | Model preference |
|---|---|---|
| Calls | Saved-JS call ablations, generic source rule, entry tests | Sol6.1 medium |
| Frames | Compact continuation ablation, stack/alias/order proof | Sol6.1 medium |
| Layout | Private representation and numeric ablations | Sol6.1 medium |
| Fusion | Total pipeline/destination prototype and refusal proof | Sol6.1 medium |
| Facts | Planner cost map and identical-emission reuse patch | Sol6.1 medium |
| Validation | Rebound current recipe, focused and final owner gates | Sol6.1 medium |
| Independent reviewer | Counterexamples and patch review | Sol6.1 medium |
| Evidence/profile support | Compact results, accounting, corpus coverage | Luna medium or root |

An inherited errored agent may occupy a slot. Use seven productive workers plus
root if so; do not spend campaign time manipulating concurrency for its own sake.
Agents own only phase42 subdirectories and submit patches. They do not modify
shared production files, old evidence, release artifacts or each other's tools.
After an investigation closes, reassign its owner to review a survivor. Heavy
compilation, benchmark, profiling, hashing and archive jobs are root-serialized.
Small syntax/oracle checks may run on a separate CPU under explicit30-second/
1GiB limits before the timing freeze; stop all such execution during clean runs.

Each handoff includes command, expected duration, inputs, proof limitations,
mutation list, output schemas, and the exact next decision. Root should run a
ready discriminator while other investigations continue. Avoid waiting for all
owners or repeating broad gates on prototypes. Capacity failures get one retry
or reassignment; unused slots are not a reason to invent more work.

Initial campaign planning allocation: roughly30–45min hypothesis discrimination,
60–120min surviving source changes/focused checks,30–45min frozen integration,
and15–30min preservation/publication. Larger supported breakthroughs may extend
that schedule; user permits several hours. Reassess after every decisive result
and at least every30min. A failed idea gets a documented stop, not an endlessly
expanded framework. Pursue the target ambitiously while keeping the best valid
release usable and preserving all evidence.

## Resources and admission

Node24.18.0; normal target jobs CPU3,1GiB heap,2GiB process-tree RSS and2GiB free
memory floor. Two-worker correctness may useCPU3,4 with aggregate3GiB RSS and
at least5GiB available at launch. Use fresh directories and deadlines; never
nest shared-lock owners. External process sandbox restrictions may require the
normal authorized local-execution escalation. Record failures and original logs.

Use20s discovery,60s confirmation and300/600s selected/full protocols. Include
independent complete values, not just catalog checksums. Profiles/counters run
separately. Record all samples and drift. A new selected-case runtime regression
requires correction, rejection or a specifically documented tradeoff; never
silently discard it. Compiler cost is a separate admission axis: measure and
explain a tradeoff instead of promising cost neutrality. Mechanism improvement
must be larger than observed noise before expanding source complexity.

Do not promise multiplication of speculative ranges. A parity claim names the
actual points, input range, protocol and uncertainty. A0.5× claim requires fresh
same-run evidence and the same semantics, workload and resource constraints.

## Research foundation and deliverables

[Phase38 architecture](../phase38/architecture.md), [TS backend](../phase38/research/bend-typescript.md),
[MLton](../phase38/research/mlton.md), [stream fusion](../phase38/research/stream-fusion.md),
and [Koka/Perceus](../phase38/research/koka.md) provide already researched ideas.
[Phase41 profiles](../../implementation/phase41/profile-findings.md) provide the
current measured starting point. Use primary-source literature when a new proof
or technique needs it; do not repeat broad research instead of running a probe.

Owners add calls.md,frames.md,layout.md,fusion.md,facts.md,validation.md and
review.md here. Hypotheses live in experiments/phase42; outcomes in
implementation/phase42; replay tools in selfhost/tools/performance/phase42;
all new raw jobs in selfhost/build/phase42. Root records wall/process intervals
and distinguishes unclassified orchestration from idle time or model latency.
Commit design first, concrete experimental findings next, validated source and
release/report last. All commits are pushed to origin/selfhost/bootstrap.
