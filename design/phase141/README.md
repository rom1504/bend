# Phase141: a bounded architectural simplification experiment

Started2026-10-25 21:49:22UTC from`0b6957a`; one-hour decision at22:49,
campaign closure by2026-10-26 00:49UTC. The user approved a three-hour trial,
with a firm first-hour stopping/reselection gate. The long-term10,000-line
compiler is an architectural hypothesis, not this session's promised output.

## Objective and boundaries

Replace one complete, materially duplicated compiler subsystem with a smaller
implementation while preserving its supported semantics, generated-code quality
and practical compilation cost. Target a2–3× reduction in that subsystem's
maintained implementation, including new helpers/adapters. Actual global deletion,
retired mechanisms, tests, generated source and research tooling are separate
counts. Formatting, narrower functionality and moved host logic earn no credit.

Qualified Phase137 source has58,569 physical /42,433 code-only lines; unqualified
Phase140 source18 has64,408 /46,808. Start from the qualified source unless the
chosen replacement specifically targets the experimental incremental adapter.
Keep Phase137 N3 and installed production selection intact during this trial.
Do not change human-written`bend2/bend.ts`, historical pins, frozen oracles or
the independent final verification gates. Preserve exact protected proof bodies.

## First20 minutes: establish the actual deletion budget

Bounded independent audits compare:

1. Checked-output ownership: current checked bodies versus annotation, erasure
   and repeated representation reconstruction. Revisit the Phase7 experiment's
   missing forms using the current implementation rather than port old code.
2. Shared native optimization recognition/plans: identify duplicated semantic
   grammars and admission machinery, retaining genuinely different policies and
   backend operations.
3. Source/reachability accounting: exact declarations, callers, public/internal
   roots, controls and supporting machinery. Native-main reachability alone
   does not justify removing supported JS/C APIs.

The coordinator selects one replacement with a concrete retained/deleted list,
complete contract and cheap falsifier. Audits do not run competing targets.

## First-hour decision

By22:49UTC require a source-checked prototype for the selected complete slice,
independent old/new results on real inputs and critical rejection cases, and a
credible net deletion budget including its adapters. Prefer actual removal of
one duplicated representation or algorithm over cosmetic line reductions.

Reject or redirect a design that simply adds another representation, requires
permanent old/new paths for the claimed domain, breaks semantic/error/ownership
obligations, or adds a generic runtime traversal whose cost outweighs its value.
Preserve negative results. A partial slice does not earn full-pass deletion credit.

## Remaining two hours

Cover hard cases and real compiler/benchmark inputs, delete the superseded
implementation in an isolated candidate, measure whole-request cost and preserve
exact outputs where emission behavior should not change. Count before/after
physical/code lines, bytes, declarations and independently maintained contracts.
Perform one native acquisition/integration block only when the cheap gates show
a useful replacement. Full native qualification is required for adoption, not
for honestly retaining an experimental result. Do not launch an unneeded broad
runtime campaign if complete output identity supplies the relevant evidence.

Use existing checked Bend APIs and20–60s focused controls;60–180s real request
screens when justified. Pure source packaging/measurement stays in host tools;
compiler semantics stay in Bend. Keep one heavy CPU3 lane, at most4GiB process
tree RSS, at least16GiB available memory, and bounded disk use (about7GB free at
start). Reuse qualified artifacts and exact reference receipts. Acquisition,
failed attempts, validation and unmetered research time stay visible.

## Deliverables

- Current-source deletion/caller inventory and the chosen contract.
- Working candidate and reproducible small evidence, including failures.
- Net code/concept/performance result with correctness and promotion scope.
- Updated assessment of whether10k is plausible and what would have to vanish.
- Committed/pushed design, implementation and report; no PR comments.
