# Phase134 execution, cost discipline and handoff

[Plan](README.md) · [Validation](validation.md).
The current task produces the plan only. Implementation starts under a separate
execution instruction; no compiler change or benchmark was performed for this design.

## How to spend the time

The first useful checkpoint should take hours, not require completing the entire
incremental architecture. Estimates below include local coding and focused checks,
but remain uncertain; failures may expose a larger dependency than the estimate.
Do not interpret the ambition levels as guaranteed speedups or completion dates.

| Stage | Planning range | Concrete result for the time spent |
|---|---:|---|
| A: baseline and accounting | 0.5–1 h | Frozen references, edit suite and reusable validation recipes. |
| B: bounded emission | 2–4 h | Exact output with measured bounded rendering; one full-scale memory check. |
| C: owner boundary / compact IDs | 3–6 h | Reusable named unit; locality and representation evidence. |
| D: genuine lowering reuse | 4–8 h | A real edit skips expensive owner work and passes fresh-reference checks. |
| E: binding and object reuse | 3–6 h | Reuse survives to a complete executable, without a global text partition scan. |
| F: persistent preparation | 4–8 h for first covered domain | Transactional repeated requests and bounded state with fewer preparation passes. |
| G: integration and qualification | 1–3 h | Native-qualified checkpoint, documented supported edits, honest cost report. |

The sum is roughly **18–36 engineering hours for the staged initial scope**, not
a promise of a fully general industrial incremental compiler. Work can overlap
only where the dependency contracts are already stable. A strong early result
can justify accelerating the next phase; a failed result should shrink or redirect
it. Cross-process state restoration, incremental linking and general checker
reuse are outside this estimate.

The first 3–4-hour session should aim to finish A/B, not partially implement six
systems. Allocate roughly 20–30 minutes to contracts and frozen controls, 90–120
minutes to the emission boundary and local evidence, 40–60 minutes to native
acquisition/full-size measurement if controls pass, and 20–30 minutes to review,
documentation and a reversible checkpoint. If the first gates fail, use the
reserved measurement time to fix or reject the hypothesis rather than launching
a known-invalid full build. All acquisition costs stay in the ledger.

## One main integration lane, bounded independent tasks

The coordinator owns interfaces, integration, candidate freezing and performance
campaigns. Use up to two or three bounded assistants when they have independent
work: emission equivalence/law audit, dependency-invalidation falsification, or
analysis of an already captured profile/machine product. Assign disjoint files
and a time-boxed question with a concrete output. Do not run competing compiler
implementations or duplicate broad research. Additional agents do not make a
serialized benchmark faster.

Maintain one controlled heavy execution lane. Reading code, reviewing proofs and
writing reports can overlap it. Avoid parallel compiler builds or memory-heavy
analysis during comparative timing. A separate correctness job may overlap
acquisition only if the guard's memory floor and CPU isolation permit it; label
acquisition timings as contended and do not reuse them as controlled gains.

Use the existing process-tree guard and inspect its limits rather than relying
on a shell timeout alone. Full requests historically need about 2.9 GB: a roughly
4-GiB request cap and the existing 16-GiB available-memory floor are initial
policies to check against the actual host. Failures retain logs; never blindly
raise limits or launch more jobs after an OOM. Keep the frozen qualified compiler
and evidence. Remove only explicitly identified disposable attempt artifacts
when storage needs attention; avoid destructive broad cleanup.

## Limit validation cost by preserving identities

Before every expensive job, write the question it answers, the frozen candidate,
the expected discriminating evidence and a stopping condition. Reuse the result
if all relevant identities match. A changed proof comment does not require
rebenchmarking unchanged binaries; a changed binding layout does.

Use the smallest checked API exports needed for local controls. Historical
planners sometimes hardcode earlier parent identities or output directories;
add a small Phase134 metadata adapter rather than altering frozen receipts or
assuming unsupported flags. Keep performance oracles outside candidate edits.

The immediate comparison parent is the selected Phase131 source/image/products.
`phase131/native/timing-codegen-plan.py` inherits Phase130 parent assumptions;
the Phase131 program planners/screens inherit a Phase128 baseline. The Phase134
adapter must explicitly bind Phase131 roles, source/image/runtime and products
and assert those identities before execution. Preserve frozen fixtures, counts
and output oracles. Phase128 may remain a historical control, not silently replace
the immediate parent in a regression comparison.

Do not wait idle for native acquisition: review the next dependency boundary,
prepare negative controls, inspect the last complete profile or write the report.
Do not mutate files used by an in-flight job. Candidates and inputs are immutable
snapshots; the next edit creates the next attempt.

Use full self-builds at most when a new scalable hypothesis needs them or a
checkpoint is ready for qualification—not after every local refactor. Attach
memory/output observation to an already-required run where overhead is measured;
use separate clean timing for performance claims. Do not repeat all45 program
timings when exact product identity establishes preservation.

As a heuristic, aim to spend 60–70% of active engineering on implementation and
falsifying experiments, 15–25% on validation/review, and the rest on evidence and
consolidation. Record actual machine wait separately. If redundant validation or
image acquisition consumes over a third of two consecutive work blocks, inspect
the workflow before adding optimizations. This does not authorize skipping gates;
it may mean a smaller API, unchanged-product reuse or fewer candidate rebuilds.

## Cost model and break-even

For a fixed producer epoch and a declared distribution of edits:

```text
total_cost(N) = producer_acquisition + initial_state_build + qualification
              + sum(edit_detection + invalidation + checking + lowering
                    + verification + render + machine_build + link
                    + required_validation + cache_maintenance)
              + failed_experiments + agent_work
```

Compare cold one-shot, warm local edit, warm broad edit, failed edit/recovery and
producer adoption separately. Report both end-to-end wall time and total CPU;
parallel work cannot be counted as a compute saving. Report agent elapsed effort
and tool/model usage when available; do not infer quota spend from wall time.

With one-time added cost `A`, full validated edit cost `F` and incremental validated
cost `I`, simple break-even is `N > A / (F - I)` when `F > I`. Measure the terms;
do not insert 369 seconds as `F` while excluding its checking/validation or use
the 6-second object build as `I`. Account for cache invalidation after adopting a
new compiler: experimental edits under one fixed producer can amortize reuse,
whereas an optimization that replaces that producer starts a new epoch initially.

Expose the dirty fraction and remaining fixed floor. With baseline time `T`,
fixed fraction `f`, dirty variable fraction `d` and new overhead `H`:

```text
warm_time = T * (f + (1 - f) * d) + H
```

This is an accounting model, not a fitted forecast. Getting 350 s to 10 s requires
removing over 97% of time if overhead is negligible. A retained ~5.5-s independent
check plus ~6-s machine step already exceeds 10 s; neither can be hidden. First
target 10–30 s, then attack the measured floor if worth its cost.

## Decision checkpoints and ambition

**1× scope:** Phase B plus one compact owner boundary. Deliver exact output,
less live materialization and a cold-time result. This stands alone if caching
proves harder than expected.

**10× scope:** Phases D–F make work follow changed facts through executable
construction. Target a real local-edit suite, not no-op cache hits. Retain the
full existing optimization policy and charge independent validation.

**100× scope:** Only after measurements show global checks/linking dominate,
investigate reusable verified checking units or incremental linking for subsecond
local edits. A source-connected proof and independent mutation controls must
justify each reused obligation. Do not build this speculative layer in the first
session or claim it accelerates arbitrary optimizer changes.

Stop or redirect an experiment when:

- Buffer retention still scales with the whole output despite a streaming API.
- Cache hits occur after the expensive work, or lookup costs exceed saved work.
- Stable binding requires hot runtime indirections that regress generated code.
- A monolithic dependency component prevents useful reuse; investigate the
  actual consumed facts rather than claiming every owner independent.
- A cold-time regression remains unexplained or persistent memory grows across edits.
- Added abstractions cannot replace an existing path or supply a measured capability.

## Evidence, commits and final usability

For each phase, add a small hypothesis file under `experiments/phase134/`, an
implementation report under `implementation/phase134/`, exact source/producer/
tool receipts, positive and negative results, and an explicit next decision.
These directories are planned destinations, not claimed completed results.

Commit useful boundaries separately: sealed plan, bounded renderer, owner IDs,
one query/owner reuse capability, binding/object reuse, persistent updates, then
qualification/consolidation. Each commit describes its coverage and limitations;
push completed work under the user's standing authorization. Do not post PR
comments. Keep the qualified fallback runnable throughout.

Every checkpoint report answers:

1. Which materialization or repeated work was removed, and where counters prove it.
2. Cold compiler request, warm validated edit and native N1/N2 results separately.
3. Generated-program identity/runtime, all significant regressions and conformance.
4. Live output/IR, peak RSS, cache/disk growth and invalidation breadth.
5. Added/removed source lines, concepts and superseded paths.
6. Acquisition, validation, failed attempts and agent/machine effort.
7. Whether a new phase is justified and what remains unqualified.

The final documentation must offer one obvious default development route, a
fresh rebuild for comparison, a recovery path through the qualified compiler and
an explanation of unsupported edits. Do not leave a collection of experimental
scripts as the only way to obtain the measured benefit.
