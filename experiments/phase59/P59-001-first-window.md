# P59-001 — First-request attribution differs from warmed attribution

- Owner: Phase59 evidence/documentation owner; root executes targets; independent method review required.
- Registered: 2026-10-06; evidence cutoff: initial information-only plan, no results credited here.
- Objective: explain the remaining compiler first-request gap before proposing optimization.
- Correctness: installed Phase58 last01 unchanged; completed diagnostics pass their prepared-output and instrumentation checks, not a new compiler qualification.
- Measurement: completed Phase59 clean/profile/stage/counter observations; final scope and limitations below.
- Decision: information gathered; future hypotheses ranked, no optimization or release change promoted.

## Claim and cheapest disproof

**Hypothesis:** A profile spanning import, explicit API load and exactly one first compilation has a materially different cost distribution from Phase58 profiles captured after warmup.

**Invariant:** CPU and cumulative-allocation capture starts before compiler import, without API load or compilation in that process. Stop before output verification; prepare caches and complete output oracles in separate processes. Imports and first request are one primary window, while the three later requests remain a separate statistic.

**Falsification / stop condition:** Comparable fresh profiles show the same distribution, or any hidden pre-import/request warmup invalidates the capture. Never compute a clean timing ratio from instrumented durations or infer first-request shares from warmed percentages.

## Controlled setup

The [fixed design](../../design/phase59/first-request-attribution.md) pins selected source `85454aab…`, checked B1 `641381f6…`, genuine B2 `a73daccf…`, upstream `018751270e800bc222a93dad7f257083ee53a5f7` and Node24.18.0. Subject workloads are Lexer and Evening library compilation, not execution of the full45 program corpus. Private Base caches are prepared before measured workers; this is not a cold filesystem experiment. Derived [latency/profile methods](../../selfhost/tools/performance/phase59/latency/) and [counter methods](../../selfhost/tools/performance/phase59/counters/) must retain parent/output identities and genuine B2 lineage, with no fabricated checked sidecar.

Root runs one guarded target at a time on CPU3: 1GiB heap, 2GiB tree RSS ceiling, 4GiB available-memory floor and existing 4MiB stack. Analysis/data-only work uses CPU0. Preserve all failures and exact commands/configurations in fresh Phase59 outputs. No compiler builds, full-image regeneration or repeated full-program campaign are authorized by this hypothesis record.

## Gates and observations

The initial registration contained no outcome. Completed scoped results are recorded below; instrumentation scope and prepared-output equality are required before interpreting them. Clean timing, profiled allocation/CPU, nested wall intervals and operation counts retain distinct units and populations. Later results will link actual immutable report identities here instead of copying competing tables.

## Independent audit

Review should challenge omitted warmup, scope/nesting, trampoline forcing, shared-frame attribution, exact injection inversion and output validation. A static review or prior Phase58 semantic pass cannot certify a new diagnostic capture.

## Decision and next discriminating test

Repeat clean Lexer/Evening old-window boundaries with selected B2 and pinned TS, then run the separate first-window pilot pair; retain a resource refusal instead of widening limits.

## Preservation

The design and these initial records are registered before results are added; the root checkpoint will bind their actual bytes. This is a new information-only campaign, not a retrospective Phase58 rewrite. Preserve consumed parent tools, failed/partial captures and closed Phase58 evidence; publish raw archival status only after explicit writer closure and member verification. The installed release remains Phase58 last01.

## Completed outcome and revised frontier

The clean repeat completes 12 fresh processes / 48 ordinary requests. Import + API load + first compilation is 2.604× TS on Lexer and 2.400× on Evening; compile alone is 4.169× / 3.204×. B2 startup is faster than TS, so import optimization does not explain the gap's direction. Later requests still warm. Separate CPU/allocation captures start before import and contain exactly one compile; prepared-output checks pass.

This establishes the requested first-window population and prevents using prior after-warmup shares as its attribution. It does not quantify a controlled causal difference between warmed and first-window profiles: they are separate processes/windows. Original TS Evening weighted CPU attribution was refused; valid count-only evidence and a separate retry remain preserved, without clipping deltas or pooling away the refusal.

**Decision:** information gathered; prioritize compilation work rather than startup. No compiler/runtime/release change. See [measurements](../../implementation/phase59/measurements.md) and [method review](../../implementation/phase59/method-review.md).

Across the campaign, 38 serial target processes consume 180.155 s recorded wall time; maximum observed process-tree RSS is 622.55 MiB. This excludes source/tool/review/publication work and does not classify all elapsed time as active thinking or waiting. Preservation passes closed Phase58's 30,169 files, installed 7 and protected 103. Raw writers are closed and streamed member verification passes. The [publication index](../../selfhost/tools/performance/phase59/artifacts/raw/publication.json) and [verified archive manifest](../../selfhost/tools/performance/phase59/artifacts/raw/archive.json) bind all preserved evidence; there is no new installed compiler. The [final report](../../implementation/phase59/README.md) owns canonical result tables, exact identities and reproduction links.
