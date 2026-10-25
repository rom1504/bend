# Phase138 — What it would take to build the compiler below20seconds

2026-10-25, starting at `9a89b4d`. [Design](../../design/phase138/README.md) ·
[Proof research](../../research/phase138/proofs-and-fast-compilation.md) ·
[Source/reuse audit](../../research/phase138/reuse-boundaries.md) ·
[Profile](profile.json) · [Timeline](timeline.md) · [Reproduction](../../selfhost/tools/performance/phase138/README.md).

**Prioritize a real incremental compiler rebuild before another isolated backend
optimization.** Fresh profiling confirms distributed costs; source inspection
identifies an exact checker-state checkpoint and existing erased-definition
products worth retaining. Recent software-proof work strengthens the case for
small reusable correctness contracts, but does not supply a cheap whole-compiler
proof or an automatic speedup.

The compiler, runtime, installed selection and generated-program optimization
policy are unchanged. No sub20s build or new theorem was implemented here.

## Fresh evidence from the actual selected native compiler

We relinked Phase137 N3's retained `program.o` with the previously authenticated
diagnostic runtime. No compiler source or runtime was recompiled. One ordinary
request compiled the exact historical Phase131 compiler-A source, using the same
prepared Base as the clean Phase137 build. The entire105,879,337-byte output
matches that clean run's retained digest. This confirms diagnostic-output
preservation, not a new independent proof of compiler semantics.

The capture contains10,785 samples at32ms, zero loss and99.66% main-thread CPU
coverage. Target wall346.535s/CPU346.426s are diagnostic times, not a new clean
speed measurement. The clean complete-build reference remains346.391s from
Phase137. Different work and instrumentation make their numerical proximity
unsuitable for inferring zero profiler overhead.

| Physical leaf | Current samples |
|---|---:|
| Reference drop (`term_drop`) |15.59%|
| Reclamation/reference handling (`span_fade`) |10.08%|
| Borrowed String equality |9.33%|
| Two-field take, hot path |4.40%|
| Unknown physical symbol |3.54%|

Drop/fade together are25.67%, versus29.74% in Phase136's historical profile.
These fractions are not paired causal speed measurements; they include required
ownership work and cannot all be removed. Even eliminating both leaves and the
listed equality leaf entirely would give only about1.54× in a fixed-other-work
model, not the17.3× needed for20s.

| Active context | Current share | Historical Phase136 share |
|---|---:|---:|
| `lookup` |5.64%|5.15%|
| `nc_ctor_owned` |4.92%|7.90%|
| `f_find` |3.22%|5.11%|
| `index_remove` |3.98%|3.77%|
| `p111v_get` |3.89%|4.02%|
| `has_name` |3.22%|2.90%|

Active contexts include synchronous private calls; they are not full inclusive
stacks. Their ownership intersections overlap physical costs. In particular,
`lookup`'s larger percentage does not establish a runtime regression.
The three original query contexts now cover13.78% of samples, with5.39% of all
samples in their drop/fade intersections. Eliminating those complete queries
would still be insufficient for a multi-fold gain.

The timeline adds useful direction: early windows contain parser scans and book
updates; middle windows contain name membership, constructor queries and term
walks; late windows contain verifier tables and rendering. `String.append`
accounts for25.9% and21.0% of the final two windows. These are approximate sampled
CPU windows, not fresh stage boundaries or proof that append alone dominates
rendering. We did not rebuild another stage-instrumented compiler.

## Three different goals

1. **Cold source-to-executable:**346.4→20s requires17.3× acceleration, or94.2%
   less elapsed time. It needs changes across preparation, lowering and emission.
2. **Local source edit to a runnable new compiler:** below20s can instead come
   from preserving unchanged work. This is the first development-loop target.
3. **Full independent qualification:** self-reproduction, broader conformance
   and runtime evidence remain separate integration costs. A warm-edit result
   cannot silently exclude them from total research accounting.

The last stage diagnostic measured44.7s parsing,53.1s checking,30.3s erasure,
59.4s initial lowering,77.7s optimization/verification and64.8s rendering/cleanup.
These are Phase136 observations, not updated Phase137 stage times. Each is large
enough to defeat20s if retained unchanged. The machine replay was about14–15s;
those clocks overlap parts of the complete pipe and are not added to it.
Perfect8-way parallelism of346s would still take43s, before serial work and
overheads. More cores complement work elimination; they are not the whole plan.

For a warm edit, use the planning model `T = F + D + M`: fixed validation/binding,
dirty semantic/optimization work, and changed machine construction/link. If the
fixed costs alone exceed20s, no cache hit rate can meet the goal. An illustrative
budget is3s change detection/checking,6s dirty lowering/optimization,3s verification
and emission,4s changed machine work/link,4s focused validation and slack. These
are acceptance targets, not measured stage forecasts. Charge acquisition and
periodic qualification separately and also report their amortized contribution.

## The next implementation sequence

| Priority | Experiment and stopping rule | Estimated first information cost |
|---|---|---|
|1|Capture exact `dg_check_events` state before a same-header body edit; replay the suffix and compare complete checking results/errors. Reject hidden global dependencies before adding caching machinery.|2–4h for the first source-connected checkpoint and controls; broader proof work extra|
|2|Retain `NativeErasedBody` and one named owner-lowering product before expensive preparation. Record every consumed fact; unknown dependencies rebuild. Demonstrate skipped work on a semantic edit, not merely renaming.|One focused1–2day prototype; major uncertainty in dependencies and identity repair|
|3|Give generated names owner-local identity and separate literal identity from placement; reuse verified unchanged rendered/object units. Fail the experiment if final rendering/binding still visits everything expensively.|Several subsequent focused iterations; sub20s remains a target, not a delivery promise|
|4|Reduce cold cost within the same boundaries: exact indexes, compact IDs/storage, fewer intermediate copies and shared immutable summaries.|First measured index experiment1–2h; compact storage is a larger change|

The first checkpoint does **not** by itself deliver20s. It establishes a safe
early boundary, then reuse must continue through erasure/lowering/output. Existing
Base-prefix admission cannot be widened casually. The source audit identifies
its native-definition, closed-prefix, empty-memo and exact-world constraints.

Use a suite of no-op, spelling-only, real private-body, reducible-body, type,
layout, insertion/absence, law-fill, policy and runtime changes. Freeze expected
outputs independently. Include failed-edit recovery and two successive edits;
report dirty units by **time saved**, not just counts. A cheap initial edit can
establish plumbing, but cannot establish general optimization-edit latency.

Keep builder A qualified and fixed while it compiles candidate-source revisions
B1,B2,... . Changing B's optimizer does not itself change A's producer identity.
Source dependencies and interprocedural decisions can still invalidate callers.
Adopt a new builder and discard/requalify incompatible caches at deliberate
integration points. This prevents needless epoch churn without hiding self-hosting
or qualification costs.

Generated-program quality remains a gate: unchanged artifacts should retain exact
QBE where identities permit; changed binding requires machine/semantic comparison
and relevant runtime tests. Do not attain the time target by silently disabling
optimizations or omitting checking. Structural IR acceptance alone cannot detect
a stale, semantically wrong cached result.

## What proofs add

The recommended first law is exact checkpoint replay under unchanged prefix and
header environment, connected to the real transition wrapper. A companion
first-match-index law supports cold speed. Later, prove that a unit cannot change
when all facts it observes are unchanged. Dependency completeness is the hard
obligation. Existing laws, source checking, admission checks and mathematical
proofs remain distinct.

The [announcement review](../../research/phase138/proofs-and-fast-compilation.md)
records the confirmed Anthropic result and the OpenAI announcement we could not
identify. Proof generation belongs outside the edit loop; cheap checking of
reuse premises belongs inside it. Full x86/QBE compiler correctness is a different,
much larger undertaking. No new proof or guarantee is claimed by this report.

## What to defer and how much this investigation cost

Defer another backend, global String redesign, a general autonomous proof/search
platform and another late cache campaign. Phase135 already showed92% optimizer
hits without a full-request win. A retained native host with alternative legal
policies could accelerate narrower research trials, but existing policy diversity
was weak and no general replaceable native-worker ABI exists.

There were two guarded jobs:1.864s relink and351.223s profile/analysis orchestration,
353.087s total (5.88min). Peak process-tree RSS was1.003GB, minimum available23.9GB;
no OOM or execution failures. Offline preparation/attribution, document work and
two bounded read-only agent audits are additional costs, not hidden inside a
claimed target-time saving. Agent token/quota expenditure was not measured.

Evidence retains raw samples, context/caller sidecars, exact method/input hashes,
owner map, capture/guard reports and attribution. Large existing objects, tools
and the unchanged full output are referenced by identity, not duplicated in git.
No production compiler source changes, broad benchmark rerun, native promotion,
new speed ratio or recursive-improvement claim. No PR comment was posted.
