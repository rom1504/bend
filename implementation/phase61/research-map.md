# Phase61 research map

**Registered before outcomes, 2026-10-07.** The user now authorizes ambitious
compiler-speed improvements implemented in Bend with maintained correctness.
This supersedes Phase60's information-only investigation scope for new Phase61
work; it does not rewrite Phase60 results or authorize unchecked promotion.
Installed Phase58 last01 and closed Phase58–60 remain preserved. Root owns the
[architectural design](../../design/phase61/architectural-compiler-speed.md),
source integration, target scheduling and release decision.
This map and the four hypothesis records add no source edit, target or raw write.

## Evidence and ranked proposals

[Phase60](../phase60/README.md) finds a 2.461× B2/TS combined-first equal-source
ratio on 23 inputs/45 inherited runtime points, every source slower 2.103–3.049×.
These clean windows and the stage/sample observations are different measurements.
TS also checks Base; the relative gap is not explained merely by Base rechecking.

| Priority / registered proposal | Existing evidence and prior boundary | First useful falsifier |
| --- | --- | --- |
| [P61-001 checked shared frontend state](../../experiments/phase61/P61-001-shared-frontend-state.md) | Check/completion largest on 22/23; ABI2 ignores validated source prefix. Phase5 memo reuses decoded parsed IR, not a checked world. | Exact full-check versus seed-extension books/diagnostics, including changed cache/API/Base, fresh IDs and live specialization. |
| [P61-002 compact owned contexts](../../experiments/phase61/P61-002-compact-owned-contexts.md) | Index CPU/allocation names recur 23/23; substitution allocation 22/23. Phase57 identifies first-order reconstruction and first-event lookup constraints. | Actual node/width counters and checker fixtures that preserve affine quantities, beta reduction, aliasing, spans and failed-request isolation. |
| [P61-003 structured code/dependency transport](../../experiments/phase61/P61-003-structured-emission.md) | String allocation 18/23; refs/uses 8/23. Phase58 dedup/shared SCC solve only part of render/scanner/copy work. | Typed refs/fragments versus exact emitted code on opaque calls, captures, dead/live FFI and cycles; counters prove eliminated work. |
| [P61-004 fast iteration](../../experiments/phase61/P61-004-fast-iteration.md) | Prior fixed contrasting screens cost 17.53 s / 49.51 s, excluding preparation. | New candidate truthfully bound, focused gate first, then same screens with held-out Lexer/Evening and eventual all 23 gate. |

## Source contracts that constrain the designs

`driver/api.bend::check_program_diagnostic` calls `dg_check_world(book)` despite
receiving `validated`. `diagnostic/produce.bend::dg_check_seed` builds a fresh
world/declaration context and `dg_check_events` checks original events. The
[Phase60 audit](../phase60/common-frontend.md) traces this path through
`check/kernel.bend::check_definition_world` and `driver_program_checked` to
`check/specialize.bend::sp_assembled`. A reusable prefix needs checked output,
world visibility, specialization/active-instance state and source/fresh-name
provenance. Skipping Base events from the source-only cache is not an equivalent
implementation. Whole-book fresh-ID reservation can affect seed-generated names.

`core/term.bend::subst_node` traverses children and calls `core_rebuild`; Apps can
beta-reduce even with no occurrence of the substituted variable. The
[Phase57 comparison](../phase57/implementation-comparison.md) therefore rules out
an unproved unchanged-subtree shortcut or term-only serialization cache. Parser
scope headers and original first declaration events also differ; an index hit
cannot silently replace first-event lookup. Compact contexts need their own
quantity, binder, alias and diagnostic proof, not just a smaller generated object.

`back/js/direct/reach.bend::jd_reach_definition` renders a definition and scans
physical `JD_REF` lines; `direct/core.bend::jd_definitions` renders selected code
again. Shared SCC bodies amplify transport if repeatedly reconstructed. Phase58
[P58-005](../../experiments/phase58/P58-005-reach-dedup.md) retains scanner authenticity,
first-occurrence/order and 4,096-definition/65,536-queued-edge/2,097,152-character
bounds; its preserved earlier budget failure is not a reason to raise caps.
[P58-006](../../experiments/phase58/P58-006-shared-scc.md) replaces duplicated switches
with shared workers while preserving per-entry ABI/capture/reentry. A structured
result may target remaining work, but must retain those boundaries and `JD_USE`
demand facts. Legacy/native paths remain live.

Phase53's [conformance](../phase53/qualification.md) includes preserved native
call-order and capture-hygiene counterexamples. Pending expressions cannot be
forced early just to make a builder convenient. Underapplication, genuine
overapplication, thrown effects, coercion demand, erased fields and shared public
values remain semantic obligations. Phase58's literal-field tradeoff shows why
allocation or image-size reductions alone cannot select a representation; the
installed last-live-key rule preserves measured program behavior.

## Evaluation order

Register one changed factor, freeze source/API/runtime/Base/driver/method identities,
then use checked B1 plus the smallest independent semantic/state falsifiers.
Counters and private saved-image variants are diagnostics, never genuine checked
artifacts. Compare a real emitted B2 only after provenance/ordinary-driver joins;
profile shares and inspector times are not clean speedups. Keep exact output
comparison where algorithmic semantics and code shape should be unchanged; a
reviewed changed emitter requires complete value/effect/alias/order qualification.

Use the [tested fast-loop method](../phase60/fast-loop.md) for early rejection,
then two-round contrasting confirmation and held-out sources. Broad source 23 /
point 45 evidence, self-source type acceptance with explicit unsafe trust failure,
B2→B3 reproduction and applicable native/legacy/release tests qualify the selected
candidate, not every prototype. Source/point weighting, compiler/request/process
clocks and generated-program execution remain separate. No promoted result is
recorded here; records stay pre-outcome plans and implementation reports carry
subsequent results/failures.

Preserve the 103 unrelated files, installed artifacts and closed 58–60 capsules.
Use fresh Phase61 paths/private caches; no historical evidence edits, TypeScript
fallback, fake checked-B2 sidecar, goal creation or PR comments. Root serializes
heavy targets under existing guards. Larger representation work is authorized,
but a demonstrated semantic mismatch or unmet ownership/state invariant blocks
promotion regardless of timing.
