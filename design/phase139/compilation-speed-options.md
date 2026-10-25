# Options for at least5× faster compiler development

2026-10-25, starting at `df803e9`. These are conditional architectural estimates,
not measured gains. The selected Phase137 native compiler remains unchanged.
The [Phase138 investigation](../../implementation/phase138/README.md) supplies
the current profile and346.391s complete cold-build reference.
The [intermediate validation gates](validation-gates.md) define the fast loop,
2×/5× milestones, generated-program tolerances and expensive integration triggers.

Fivefold improvement means less than69.3s. A20s complete cold build needs17.3×.
Keep cold compilation, local-edit rebuilding, policy experiments and full native
qualification as separately reported clocks. The purpose is faster validated
compiler research with generated-program quality preserved.

| Option | Estimated potential | Boundary | Main uncertainty |
|---|---|---|---|
| Stable reusable checked compiler units |5–20×|Localized source edits after initial acquisition|Affected work, global binding and unavoidable validation cost|
| Fine-grained semantic incrementality |10–50×|Small edits with narrow consumed dependencies|Complete dependency recording and invalidation overhead|
| Compact indexed representations and fewer traversals |3–8×; target5×|Cold and incremental compilation|Whether reductions reach most stages rather than one small hotspot|
| Structural reductions plus parallel compilation |5–10× combined|Cold and incremental compilation|Serial checking dependencies, real parallel fraction and memory bandwidth|

The first two are alternative depths of reuse. The last two overlap and cannot
be multiplied as independent forecasts. A wide range is uncertainty, not evidence
that its upper endpoint is likely.

## 1. Stable reusable checked compiler units — investigate first

Retain checked/prepared definitions, lower only affected owners or dependency
groups, preserve verified output and reuse unchanged objects. Source authoring
modules are useful organization, but are not automatically semantic compilation
units. Establish the boundary from actual dependencies and generated workers.

Keep qualified builder A fixed while it builds candidate revisions B1,B2,... .
Candidate optimizer edits do not change A's producer identity. Their actual
source/interprocedural dependencies can still invalidate callers. Adopting a new
builder is a separate qualification event with a new cache epoch.

Illustrative accounting: if fixed overhead is10s and remaining dirty work is15%
of a336.4s avoidable baseline, a rebuild is60.5s, or5.7× faster. This is a budget,
not measured locality. A changed function representing15% of declarations need
not represent15% of build time.

First test: a real compiler function edit, unchanged header constraints, exact
checkpoint reuse, complete fresh-reference output and diagnostics. Extend reuse
through erased/lowered/output units before making an end-to-end speed claim.

## 2. Persistent fact-sensitive incremental compilation

Retain parsed syntax, checker states, typed/erased definitions, summaries, admitted
plans and output units. Recompute a dirty fact and propagate only if the result
its consumer observes changed. Record body dependencies, absence, shadowing,
constructor/ownership facts, specialization and helper readiness—not only types.

This is the stronger Zig-inspired architecture already researched in Phase133.
The first coarse safe boundary can evolve into it. Do not prebuild a general
query framework before a real unit proves profitable. Global policy/runtime/type
edits may legitimately remain broad rebuilds.

## 3. Physically compact compiler data and less work per stage

Keep compiler logic in Bend. Use interned identifiers, compact scalar/indexed
storage, exact lookup indexes, reusable immutable summaries, explicit unit
lifetimes and fewer intermediate traversals. Merely storing separately boxed
records inside an Array is not a compact representation.

Fresh profiling attributes25.7% of samples to drop/fade and9.3% to borrowed String
equality. Removing those named leaves alone cannot deliver5×. The ambitious gain
requires eliminating the comparisons, repeated analysis, reconstruction and
traversals that cause work throughout the pipeline. Prototype one substantial
preparation-to-lowering unit; charge construction, query and destruction together.

## 4. Structural savings plus real parallel compilation

Once units are independent, execute balanced analysis, lowering, verification
and machine construction concurrently. Preserve deterministic diagnostics,
names, artifacts and semantic gates. Keep memory bounded and measure speedup
against the same single-core algorithm as well as the historical baseline.

An illustrative2× reduction in sequential work followed by2.5–4× effective
parallel acceleration yields5–8×. More cores alone are insufficient: perfect8-way
parallel execution of346.4s still takes43.3s. Parallelizing the approximately15s
machine tail alone has little effect on the current complete build.

## Selection and constraints

Choose option1, investigate its early semantic boundary in detail, and use that
work to enable options2–4 where evidence supports them. The dedicated
[checked-unit investigation](../../research/phase139/reusable-checked-units.md)
records findings, blockers and the proposed first experiment.

Preserve source checking, ownership, effects, error behavior, supported semantics,
stack safety and generated-program optimization quality. Proofs should justify
specific reuse rules; they do not replace unproved backend/runtime obligations.
Do proof search offline and account for its cost. No broad rewrite, compiler
promotion or performance campaign follows from these estimates alone.
