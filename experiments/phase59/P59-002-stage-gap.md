# P59-002 — Absolute stage costs explain the first-request gap

- Owner: Phase59 evidence/documentation owner; root executes targets; independent method review required.
- Registered: 2026-10-06; evidence cutoff: initial information-only plan, no results credited here.
- Objective: explain the remaining compiler first-request gap before proposing optimization.
- Correctness: installed Phase58 last01 unchanged; completed diagnostics pass their prepared-output and instrumentation checks, not a new compiler qualification.
- Measurement: completed Phase59 clean/profile/stage/counter observations; final scope and limitations below.
- Decision: information gathered; future hypotheses ranked, no optimization or release change promoted.

## Claim and cheapest disproof

**Hypothesis:** A small set of disjoint stages, including private Base-cache processing, explains a substantial absolute share of the selected B2 versus TS first-request difference.

**Invariant:** Diagnostic stage clocks preserve the ordinary request and exact prepared output. Record import, API load, cache handling, discovery/checking and emission sub-stages. Nested clocks are inclusive; only disjoint exclusive intervals plus residual can be summed. Unlike TS/Bend stages are described separately.

**Falsification / stop condition:** Stage residual remains large, instrumentation changes the output/order, or a stage is small in absolute milliseconds despite a high percentage. A persistent in-memory cache cannot be credited to the fresh-process primary window.

## Controlled setup

The [fixed design](../../design/phase59/first-request-attribution.md) pins selected source `85454aab…`, checked B1 `641381f6…`, genuine B2 `a73daccf…`, upstream `018751270e800bc222a93dad7f257083ee53a5f7` and Node24.18.0. Subject workloads are Lexer and Evening library compilation, not execution of the full45 program corpus. Private Base caches are prepared before measured workers; this is not a cold filesystem experiment. Derived [latency/profile methods](../../selfhost/tools/performance/phase59/latency/) and [counter methods](../../selfhost/tools/performance/phase59/counters/) must retain parent/output identities and genuine B2 lineage, with no fabricated checked sidecar.

Root runs one guarded target at a time on CPU3: 1GiB heap, 2GiB tree RSS ceiling, 4GiB available-memory floor and existing 4MiB stack. Analysis/data-only work uses CPU0. Preserve all failures and exact commands/configurations in fresh Phase59 outputs. No compiler builds, full-image regeneration or repeated full-program campaign are authorized by this hypothesis record.

## Gates and observations

The initial registration contained no outcome. Completed scoped results are recorded below; instrumentation scope and prepared-output equality are required before interpreting them. Clean timing, profiled allocation/CPU, nested wall intervals and operation counts retain distinct units and populations. Later results will link actual immutable report identities here instead of copying competing tables.

## Independent audit

Review should challenge omitted warmup, scope/nesting, trampoline forcing, shared-frame attribution, exact injection inversion and output validation. A static review or prior Phase58 semantic pass cannot certify a new diagnostic capture.

## Decision and next discriminating test

Use two saved inputs and explicit interval nesting to distinguish cache/read/decode work from language and emission work; compare clocks with the independent clean window, without treating them as interchangeable timings.

## Preservation

The design and these initial records are registered before results are added; the root checkpoint will bind their actual bytes. This is a new information-only campaign, not a retrospective Phase58 rewrite. Preserve consumed parent tools, failed/partial captures and closed Phase58 evidence; publish raw archival status only after explicit writer closure and member verification. The installed release remains Phase58 last01.

## Completed outcome and revised frontier

Stage clocks and exact-ancestor profile partitions pass output and arithmetic checks. Cache handling is material but not most of the gap; checking/completion is more prominent on Lexer, while emitted dependency discovery/rendering weighs more heavily on Evening. TS book validation and whole library generation have different work boundaries from B2's bundled checking/completion and individual emission stages.

The [canonical report](../../implementation/phase59/README.md) retains absolute diagnostic stage means; [ancestor attribution](../../implementation/phase59/profile-stage-attribution.md) assigns each sample to one nearest exact boundary, including an unassigned bin. Inclusive parent and child weights are never added. Clock means are not clean medians, and neither these partitions nor matching stage names prove a removable fraction of the clean B2/TS gap.

**Decision:** supported as diagnostic localization. Audit generated String reconstruction first, then repeated completion/cache work if a bounded question remains. No stage-based optimization or equivalent-TS-stage claim is promoted.

Across the campaign, 38 serial target processes consume 180.155 s recorded wall time; maximum observed process-tree RSS is 622.55 MiB. This excludes source/tool/review/publication work and does not classify all elapsed time as active thinking or waiting. Preservation passes closed Phase58's 30,169 files, installed 7 and protected 103. Raw writers are closed and streamed member verification passes. The [publication index](../../selfhost/tools/performance/phase59/artifacts/raw/publication.json) and [verified archive manifest](../../selfhost/tools/performance/phase59/artifacts/raw/archive.json) bind all preserved evidence; there is no new installed compiler. The [final report](../../implementation/phase59/README.md) owns canonical result tables, exact identities and reproduction links.
