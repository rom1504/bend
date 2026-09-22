# P5-001 — Shared binder validation and decorator placement

- Owner: compact-index; independent reviewer: root or delegated reviewer.
- Started: 2026-09-22, Phase5 campaign 21:39:36–03:39:36 UTC.
- Initial scope/timebox: fresh witnesses and first checked overlay within 60 minutes; no job longer than three minutes or broad gate without coordination.
- Correctness: design only; prior Phase2 witnesses identify gaps, but current baseline must be freshly observed.
- Measurement: none. CPU1 correctness probes, Node24, 4MiB stack, at most4GiB heap; concurrent independent work makes elapsed times workflow observations only.
- Decision: investigate. No compiler source edit until the initial campaign design is committed.

## Claim and cheapest disproof

The compiler accepts some bindings and decorator placements rejected by pinned TypeScript. The ordinary-local pattern validator already has useful binder/constructor rules; parallel scoping bypasses it. Top-level dispatch carries an unsafe flag into law/type parsing without rejecting the decorator. Reusing validation at these missing boundaries should repair acceptance without changing legal scope or the checker.

Pinned `bend.ts:2404` adds a rule specific to parallel bindings: every pattern must be a Var before ordinary `parse_patt` validation. Braced constructor destructuring is valid for a single local binding, but invalid in a parallel list. Therefore blindly sharing all local-pattern acceptance is insufficient. Share binder validation underneath a names-only parallel shape gate, preserving left-to-right first error and the incremental declaration book. Values keep the enclosing scope; the body receives all new binders together.

Pinned `parse_book` consumes one `@unsafe`, then immediately requires `def`. Probe law/type/import/EOF/repeated or unknown decorators as separate cases, plus valid unsafe definitions. Rejecting a trailing decorator must happen before the normal end-of-file success branch. Keep definition filling and declaration order unchanged.

Stop or revise for any legal-control rejection, changed scope/ownership behavior, unexpected error ordering, fresh reference disagreement, or inability to check the small overlay within the resource limit. Exact diagnostics and acceptance/rejection phase are separate: matching parse rejection alone does not establish identical intended-rule diagnostics.

## Controls

Parallel: existing bare constructor name; constructor declared later; renamed binders; two/three ordinary binders; marked binders; braced constructor and function-shaped patterns; duplicate names; malformed first pattern with invalid value/body. Keep equivalent single-local destructuring positive controls. Invalid fixtures must be confirmed against the live pinned reference before being relied on as an oracle.

Decorators: before law, type, import, EOF, another decorator and an unknown declaration; valid unsafe def with whitespace/comment and ordinary undecorated law/type/def. Existing 21 frontend-rule witnesses and the subsequent grammar controls remain regression inputs rather than being silently redefined.

## Setup and ownership

Baseline: Phase4 final source `34c6ef63…`, genuine checked B1 (explicit selected API/report), runtime `26f5eee2…`, pinned upstream `6018e28…`, canonical Base. Use frozen host/helper/harness inputs and capture all exact identities before/after. Preserve fresh baseline mismatches, each candidate overlay, checked source/API report, fixture bytes and all observations.

Owned initial source modules: `src/front/parallel.bend`, `src/front/validate.bend`, and `src/front/declarations.bend` (root confirmed). Keep compiler source changes in isolated overlays until review/promotion. Do not edit parser, lexer or diagnostic modules without coordination. In particular, semicolon consumption inside operator RHS is a separate, broader grammar issue and is not folded into this first repair.

Use the existing selected paired harness or a narrow witness driver with real upstream parsing/checking and genuine checked-B1 provenance. No fabricated bootstrap metadata for overlay APIs. A selected pass is not full conformance. Root coordinates broad frontend and full self-reproduction only after the focused candidate survives review.

## Evidence, independent review and preservation

Pending fresh observations. Outcomes will be recorded in `implementation/phase5/frontend-*.md` with exact retained manifests and fixtures under `selfhost/tests/frontend/phase5-*`. Preserve failed attempts and disputed fixture expectations; record the corrected expectation separately. No performance claim or promotion follows merely from consolidating a validation call.

## First repair outcome — 2026-09-22

Fresh baseline witnesses confirmed eight acceptance/phase gaps among22 cases. The isolated three-module candidate repairs them and preserves46 prior rule/grammar controls. Execution probes then exposed pre-existing duplicate-name shadowing: parallel bindings, local destructuring and match rows return1 instead of the reference2. Root authorized the narrow shared body-environment fix after fresh baseline reproduction. It reverses only newly collected binders for lookup, preserving source-order patterns/values and simultaneous value scope.

The final source/API is recorded in [frontend-bindings.md](../../implementation/phase5/frontend-bindings.md). All109 selected paired observations pass:79checks,15interpreter,15JS;12 intended-rule diagnostic assertions and first-error controls pass. Exact diagnostic differences and the unrelated raw brace-parsing obstruction remain visible. The source is integrated after independent review, with broader combined gates handled separately by root. No performance claim follows.

Retained unsuccessful attempts include unsupported persistent execution configuration, invalid reused Pair fixture names, the genuine wrong-result baseline, and the valid ungrouped-value program blocked by an existing parser discrepancy. Separate corrected controls isolate each intended rule without overwriting those observations. An auxiliary README-version archive refusal and its precise correction are also preserved.
