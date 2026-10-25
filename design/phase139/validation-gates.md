# Intermediate gates for reusable compilation units

2026-10-25. Applies to the [Phase139 proposal](../../research/phase139/reusable-checked-units.md).
These are prospective decision rules, not executed gates or new performance
results. Reuse the existing harnesses from [Phase134 validation](../phase134/validation.md).
The narrower gate selection and explicit tolerances below govern this campaign;
the existing independent correctness and native qualification obligations remain.

The objective is faster compilation and development with little generated-program
regression. Validation escalates when evidence justifies it. A foundation can be
committed as experimental without passing a later performance milestone, but it
must not be described as a qualified speed improvement.

## Freeze the comparisons once

Use one qualified incumbent, fixed tools/runtime/Base, current benchmark wrappers,
and a predeclared edit suite. Freeze references and harness identities separately
from candidate implementation. Reference production is a charged one-time cost;
reuse its outputs only while the exact source and environment identities apply.

For each edited revision B, distinguish:

1. Incumbent ordinary build of B: the actual adoption baseline.
2. Candidate cold build of B: the overhead introduced by the new machinery.
3. Candidate warm build of B after acquiring revision A: actual edit performance.

Warm/cold within the candidate isolates reuse; warm/incumbent establishes useful
adoption speed. A versus B timing is not a speed comparison. Do not use a slower
candidate miss path to inflate the claimed gain. Charge seeding, parsing, dependency
validation, binding, emission, machine work and linking to their real intervals.
Never subtract required work merely because it runs in a persistent process.

Define `Tbuild` from submitting the revision until a complete runnable compiler
is available, and `Tready` through the focused independent smoke of that compiler.
Report both. The eventual 20s development target applies to `Tready`; complete
native qualification remains separately reported and amortized.

## Gate ladder

Budgets below are planning caps for **ready harnesses and fixtures**. Acquiring a
checked API or a native candidate is a separate, explicit cost; it must never be
hidden behind a 20-second label. An overrun ends with a recorded partial result
and revised selection/scheduling, not a silently weakened test or a false pass.

| Gate | When | Evidence and acceptance | Budget / next decision |
|---|---|---|---|
| G0: frozen baseline | Once per contract/epoch | Exact source/edit/reference identities, current stage clocks, expected invalidations and supported edit classes; independent oracles remain fixed. | Metadata in seconds; reference acquisition priced separately. |
| G1: contract correctness | Every changed reuse rule or implementation | Affected small controls pass, fresh/reused complete state and diagnostics match, intended stale hits reject, failed-edit recovery works, and the actual expensive producer is skipped on admitted hits. | 20s narrow loop, up to 60s expanded loop. Any mismatch stops performance escalation. |
| G2: useful work disappears | One coherent passing implementation | At least 2× faster affected stage including reuse overhead, and at least 10% faster complete small edited requests on two distinct relevant cases. Cold small-request screen stays within 5%. | 60–180s selected screen. Without a net win, continue cheap work or reject; don't acquire/qualify a full compiler solely for a hit count. |
| G3: real compiler milestone | G2 passes and combined boundaries plausibly remove substantial whole-build work | Actual edited compiler builds and runs independent compiler requests; warm `Tbuild` is at least 2× better than incumbent on the same B. Record candidate cold cost and all remaining floors. | About 6min per unavoidable full request; run one deliberately selected edit initially. Price the complete block before launch. |
| G4: fivefold target | G3 identifies a credible scalable path | At least 5× better warm `Tbuild` on **each** of three predeclared substantive supported compiler edits; report `Tready`, worst edit and unsupported/global fallbacks too. | Reuse trusted references; escalate to this full edit set once, then only for relevant changes. 20s `Tready` is a later stronger milestone. |
| G5: qualified checkpoint | Useful integrated milestone ready for adoption, or changed runtime/ABI/semantic boundary | Source/proof checks in scope, established native reproduction, focused19, ordinary45 and the appropriate generated-program identity/runtime checks all pass. | Full acquisition and qualification priced explicitly. One campaign per coherent useful checkpoint, not per local tuning edit. |

G2 thresholds are engineering selection criteria, not statistical guarantees.
Choose real calibrated cases large enough that startup does not hide the stage
under test. The micro mechanism and complete-request benefit must both appear;
if only the mechanism works, label it a foundation and combine the next necessary
boundary before G3. Do not retune fixtures after observing a disappointing result.

A useful 2× integrated checkpoint can undergo G5 while the 5× objective remains
open. Conversely, passing G4 never excuses a missing correctness or quality gate.

## Frozen positive and negative controls

The positive suite contains a no-op overhead control, the retained spelling edit,
a real numeric/operator policy edit, and a body rewrite in a different owner.
Only substantive implementation/policy edits count toward G4. Include early,
middle and late owners where supported; publish exactly which class is admitted.
Do not silently generalize a 5× non-binding-edit result to arbitrary source edits.

The negative suite covers new binders; balanced binder changes with an unchanged
final bound; changed children/quantities/flags/Foreign bodies; later law fills;
name insertion/deletion/order; changed reducible bodies with unchanged types;
helper absence becoming presence; changed layouts/literals and static capacity;
wrong producer/runtime/verifier epoch; corrupt/truncated artifacts; failure then
recovery; edit/revert; and repeated updates with eviction.

Run only affected controls during G1, with their declared dependencies, then the
complete small matrix before G3/G5. A deliberately omitted known dependency must
be caught by an independent stale-output challenge. Also require an irrelevant
edit to retain a valid hit. Always rebuilding is safe but fails the speed goal.
Unsupported edits must produce correct fresh fallback, even if their slow path
is tested on a small fixture between integration milestones.

For native milestones, the newly built B executable must actually compile
independent programs and affected rejection cases. Check that the intended edit
is present. Returning old A's successful output can hide a dropped edit. Compare
with fresh **B**, not automatically with A when the edit deliberately changes
optimization decisions. Candidate cold and warm paths share code, so also retain
incumbent/independent semantic witnesses; their agreement alone is not sufficient.

## Generated-program performance guardrails

Aim for zero regression. For this campaign, default promotion limits relative
to the preserved incumbent in a matched block are:

- Generated-program geometric mean: at most **2% slower**.
- Each predeclared workload family's geometric mean: at most **2% slower**.
- Any individual timed workload: at most **5% slower**.
- Cold compiler-request/full-build overhead: at most **5%**. Report smaller
  regressions too; an intended larger warm/cold tradeoff needs an explicit revised
  decision and break-even evidence, not an implicit exception.

Family/per-case limits prevent large wins elsewhere from hiding losses. Keep
fixed-batch total, worst cases, positive log-slowdown, counts above 1.1×/2× upstream
and the historical 44-point geometric metric in complete reports. Measure actual
N1/N2 compiler requests separately, naming the real generation; these also use
the 5% compiler-request limit. No source-line/IR-byte reduction substitutes for a
speed result. Report added code, cache schemas and retained-memory complexity.

These limits are decision thresholds, not confidence intervals; a tiny sample
just below a threshold does not prove non-regression. This campaign does not
change benchmark definitions or erase prior negative evidence.

Start with three alternating/rotated paired rounds in the selected screen. If a
threshold is crossed or a sensitive case looks suspicious, run five additional
paired rounds **only for the affected cases**, with the same products, warmup,
repetition wrappers, CPU and resource policy. Preserve the original block and
report confirmation separately. A confirmed breach blocks promotion; a noisy
borderline remains inconclusive. Do not keep rerunning until a favorable pass.

Small screens cover affected families and at least one unrelated control. Retain
Lexer, Closures256 and Map128 for compiler-request screening, plus witnesses for
the boundary being changed. A selected screen cannot establish a broad quality
pass; full or identity-bridged coverage is required for adoption.

## Reuse validation evidence instead of repeating runtime campaigns

For canonical, behavior-preserving changes, establish exact complete generated
QBE against the frozen references. Identical QBE plus identical runtime, tools,
flags and build policy can reuse authenticated existing machine products and
their runtime evidence. Record this as **reused evidence**, not a fresh timing.
Perform the candidate's emission/identity pass once per relevant integrated
image, then share its receipts across later gates. A changed candidate image
does not inherit output identity merely because a previous image passed.

Changed linkage, literal placement, addresses, calling conventions or runtime
requires corresponding machine and execution checks. Equal instruction counts
or `.text` bytes alone are insufficient. Use the existing ELF/relocation gates;
retain the established build-ID metadata exception only where justified.

For fewer than 23 changed runtime wrappers, use the existing changed-only screen
plus an unrelated control. At 23 or more changed wrappers, or when the affected
set cannot be established safely, run the frozen complete corpus at a milestone.
A changed-only subset does not create a new broad geometric score. Broad runtime
work may be avoided when the complete identity bridge genuinely preserves it.
Proofs may justify specific reuse, but don't replace still-unproved runtime,
ownership or ABI checks.

## Control the cost of validation

- One coordinator owns heavy timing; source audits and test preparation can run
  independently. Avoid competing heavy processes during paired measurements.
- Work on small checked modules or extracted actual implementation paths first.
  Native compiler acquisition is a G3/G5 event, not an automatic per-edit action.
- Full requests currently cost roughly 6min. An initial G3 block can take 25–40min
  if candidate acquisition, seed and fresh comparisons are all missing. Declare
  that cost before starting; reuse exact existing references and receipts where
  applicable. Do not describe that whole block as a six-minute check.
- Once the candidate is fast, repeat warm updates cheaply; do not repeat unchanged
  six-minute baselines for every local policy tweak. Refresh baselines when their
  source, image, environment or measurement comparability changes.
- Cap the first full milestone at one real edit. Broaden only after it passes.
  A failed or unexpectedly slow gate returns to the cheapest diagnostic that can
  explain it; it does not trigger the entire qualification suite again.
- Set a 15min discretionary validation budget per ordinary development hour as
  a **stop-and-review trigger**, not permission to omit mandatory checks. Acquisition
  and declared qualification blocks are scheduled separately. If validation
  consumes that budget without resolving a decision, stop repeating it and improve
  the fixture, artifact reuse or hypothesis before spending more.
- Keep current/pending cache state bounded. Check failure recovery and eviction
  in small loops; check actual peak memory on the first large request. Retain the
  4GiB process-tree limit, 16GiB available floor and explicit disk budget.

Every milestone receipt records source/producer/environment identities, admitted
and fallback edits, which gates ran or were reused, clean stage/end-to-end clocks,
runtime ratios, peak/retained memory, failed attempts and the next decision.
Account for total research cost as acquisition + seeding + updates + failures +
qualification. A 20s warm update is not 20s amortized research if those other costs
dominate. This procedure reuses existing harnesses; CLI adapters are documented
only after implementation, not invented here.
