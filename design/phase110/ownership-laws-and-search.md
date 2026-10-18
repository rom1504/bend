# Phase110: ownership-preserving IR, useful laws, and bounded search

Status: design frozen before candidate execution. Baseline `7fc45f3` on
`selfhost/bootstrap`. Authorized three-hour window: 2026-10-18 18:59:56–21:59:56
UTC. The 1×/10×/100× labels describe ambition and scope, not promised speedups.

## Question and starting evidence

Can retaining ownership, constructor constants and multiple-result transfers
across the direct native IR/runtime boundary remove overhead, while executable
laws and independent controls make further optimization cheaper and safer?

Phase109 admits real compiler List<String> reverse, Base String reverse and
checked discard/duplicate bodies. Its fused QBE reverse takes 1.386× the matched
production Clang worker time, versus 4.782× initially. That denominator is one
65,536-cell kernel, not upstream TypeScript, a complete compiler, or B1/B2.
QBE and Clang of the same imported-runtime graph differ little. Remaining calls
include a pure discriminant accessor, a general rebuild with constant descriptor
arguments, and a context scratch-field transfer. Production reverse already has
an ordinary loop. No trampoline-removal credit is available here.

The selected native frontend runs without JS/Clang/cproc on ordinary requests,
but its acquisition still uses C/cproc/QBE. General calls, arbitrary checked
layout admission, closures, effects and scheduling remain unimplemented. Keep
the full-language Phase108 route and production selection intact.

## Ambition ladder and evidence gates

### 1×: a useful, faster, law-connected ownership interface

Implement and compare three additive choices against unchanged Phase109 fused:
inline authenticated tag extraction; specialize constant descriptor/field roles;
and typed two-result consume/rebuild transfers. Preserve exact production heap,
reference counts, shared/static behavior and returned ownership handles. Inspect
QBE aggregate-return lowering rather than assuming it eliminates stack traffic.

Factor a safe Bend helper actually called by lowering. Prove complete result
laws, then a useful local consume/build/transfer equivalence preserving remaining
children and external aliases. Check well-typed semantic mutants: wrong field,
missing claim and unsafe static-spare reuse. Model laws are not a proof of the C
runtime correspondence; actual runtime controls remain a separate requirement.

Success: repeated faster worker timing, all independently expected observations,
meaningful mutant rejection, source/call-site provenance, and clear unsupported
boundaries. A negative result is useful if it isolates the real cost and rules
out a misleading architectural assumption.

### 10×: generalize and select composable policies

After the first gate, broaden beyond reverse: unchanged Base List.tail and
List.last.go are initial candidates with existing descriptors; inspect nt_append
or another ordinary-call computation as the next semantic extension. Reuse
checked frontend facts, avoid source-name optimization rules, and refuse facts
outside the admitted ABI.

Freeze independent training and held-out workloads before selection. Evaluate a
bounded twelve-choice space: fused/tagged/specialized/pair × QBE/Clang-O2/GCC-O2,
using the same cached GCC runtime. If a proposed candidate cannot be implemented
or admitted, record it as unavailable rather than silently changing the space.
Select on training geometric-mean worker-time ratio against the matched fused
backend. Record build, validation and search cost, code size, allocation/lifetime
checks and break-even work. Evaluate held-outs once after selection; retain the
incumbent when results are inconclusive or correctness fails.

Success: a policy that transfers to multiple real computations and input/alias
shapes, with laws guarding meaningful transformations and a cheap reproducible
search command. Source preparation, runtime acquisition, worker build and worker
execution must remain separate clocks.

### 100×: make the optimizer part of a measured improvement loop

If generalization is established early, use the typed effect/ownership interface
to enumerate legal local rewrite plans rather than manually named special cases.
Compose legality witnesses with a measured cost model; inspect resulting code to
distinguish removed work from work moved into another stage. Test whether a
winning policy can accelerate a real compiler operation or the search machinery.

The strongest extension is a frozen-builder versus updating-builder pilot with
the same candidate schedule, oracle and resource budget. Charge acquisition and
upgrade costs. Measure validated improvements per total wall/compute, not merely
faster standalone kernels. Fixed-source bootstrapping and policy search alone do
not establish recursive acceleration. Full direct self-hosting is an aspirational
extension, never a prerequisite for an honest useful result in this window.

Advance only when the earlier evidence supports the dependency. Failure of an
interface choice redirects effort to the strongest alternative; it does not
justify broad unsupported backend rewrites.

## Three-hour execution schedule

1. 18:59–19:15: authenticate baseline, record this design, freeze controls/search
   objective, reclaim only hash-verified archived duplicate artifacts, prepare
   additive candidates in parallel. Commit/push design before measured trials.
2. 19:15–20:00: root runs the smallest checked API and semantic controls; prove
   useful laws and test mutants; inspect assembly and perform paired timing.
   Reach the 1× gate or preserve a decisive negative and change approach.
3. 20:00–21:00: broaden source/alias coverage, qualify typed transfers, run the
   bounded policy search. Advance earlier when evidence allows. Rebuild a native
   frontend only after a smaller experiment justifies the acquisition cost.
4. 21:00–21:35: pursue the strongest supported 100× extension, or deepen the
   general IR/ownership integration if that is the actual limiting boundary.
   Freeze the final candidate in time for independent checks.
5. 21:35–21:59:56: consolidate usable commands/docs, exact evidence and rejected
   attempts, metric boundaries, complexity accounting and final report; commit
   and push. Do not start an unbounded campaign during consolidation.

## Execution and correctness discipline

Root owns assembly, target execution, timing and integration. Four agents prepare
disjoint source/interfaces, IR, laws and frozen controls; none independently runs
timed targets. All substantial target work is serialized on CPU3 under the
existing process-tree time/RSS/free-memory guard. Small checked API builds take
about 1.4s; semantic suites about 10s; paired screens about 19s. Cache immutable
runtime objects and binaries; do not reacquire the full compiler for each policy.

Disk starts at about 165MiB free. Authenticate archived generated C/object/member
hashes before deleting duplicates, preserve selected images and final sources,
and record cleanup. Do not delete unrelated work. Large acquisition requires a
4GiB tree cap and 16GiB available-memory floor. Keep failures and process receipts.

Preserve Phase109 history and human-written bend2/bend.ts. New compiler algorithms
and transformations belong in Bend; Python/JS may transport data, assemble exact
source and supervise experiments, with roles explicitly labelled. Keep evaluator
oracles/laws frozen relative to candidate selection; fixes require a new evaluator
version and replay, not retroactive success. Old thirteen-case controls are
regressions, not fresh held-outs. Validate empty/deep/unique/shared/static values,
retained aliases after dropping results, exact outputs and complete lifetimes.

Record source/tool/runtime/ABI hashes and machine-code changes. Timings use
alternating order, repetitions and multiple rounds; report dispersion and do not
select noise. No weakening production gates, no PR comments, no installation of
an experimental selected-library backend as the full-language compiler.

## Deliverables and claim boundaries

- Additive Bend IR/lowering/runtime interface, useful laws and semantic mutants.
- Frozen broader controls and a bounded, replayable search/measurement loop.
- Source-to-machine explanation of wins, failures, residual costs and transfer.
- Usable documentation linked from the ownership-native documentation.
- Report in implementation/phase110 with timing/resource accounting, source and
  concept deltas, evidence capsule, scope reached and next falsifiable experiment.
- Design, meaningful intermediate result and report commits pushed to the fork.

Track generated-worker speed, frontend/worker compilation speed, semantic coverage,
code size/complexity and research-loop cost separately. Phase105 remains the last
broad production B1/B2/upstream measurement unless explicitly remeasured. A local
law is not whole-compiler correctness; a kernel gain is not full-compiler parity;
a bounded autotuning result is not demonstrated recursive research acceleration.
