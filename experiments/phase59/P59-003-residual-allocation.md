# P59-003 — Residual allocation has identifiable removable causes

- Owner: Phase59 evidence/documentation owner; root executes targets; independent method review required.
- Registered: 2026-10-06; evidence cutoff: initial information-only plan, no results credited here.
- Objective: explain the remaining compiler first-request gap before proposing optimization.
- Correctness: installed Phase58 last01 unchanged; completed diagnostics pass their prepared-output and instrumentation checks, not a new compiler qualification.
- Measurement: completed Phase59 clean/profile/stage/counter observations; final scope and limitations below.
- Decision: information gathered; future hypotheses ranked, no optimization or release change promoted.

## Claim and cheapest disproof

**Hypothesis:** After Phase58 reductions, first-window cumulative allocation concentrates in concrete reconstruction/serialization/index or metadata sites that can be mapped to source and generated spans.

**Invariant:** 128KiB sampling includes objects collected by minor/major GC and is separate from clean timing. Bytes are cumulative estimates, not RSS. Shared dispatcher frames do not identify an individual source member without additional PC-aware evidence. Retain warnings, unattributed samples and sampled-weight/tree discrepancies.

**Falsification / stop condition:** Sampling does not resolve a site, allocation differs by input with no common mechanism, or a high-weight frame cannot be linked to a removable operation. High bytes alone do not establish CPU savings, ownership permission or an optimization proof.

## Controlled setup

The [fixed design](../../design/phase59/first-request-attribution.md) pins selected source `85454aab…`, checked B1 `641381f6…`, genuine B2 `a73daccf…`, upstream `018751270e800bc222a93dad7f257083ee53a5f7` and Node24.18.0. Subject workloads are Lexer and Evening library compilation, not execution of the full45 program corpus. Private Base caches are prepared before measured workers; this is not a cold filesystem experiment. Derived [latency/profile methods](../../selfhost/tools/performance/phase59/latency/) and [counter methods](../../selfhost/tools/performance/phase59/counters/) must retain parent/output identities and genuine B2 lineage, with no fabricated checked sidecar.

Root runs one guarded target at a time on CPU3: 1GiB heap, 2GiB tree RSS ceiling, 4GiB available-memory floor and existing 4MiB stack. Analysis/data-only work uses CPU0. Preserve all failures and exact commands/configurations in fresh Phase59 outputs. No compiler builds, full-image regeneration or repeated full-program campaign are authorized by this hypothesis record.

## Gates and observations

The initial registration contained no outcome. Completed scoped results are recorded below; instrumentation scope and prepared-output equality are required before interpreting them. Clean timing, profiled allocation/CPU, nested wall intervals and operation counts retain distinct units and populations. Later results will link actual immutable report identities here instead of copying competing tables.

## Independent audit

Review should challenge omitted warmup, scope/nesting, trampoline forcing, shared-frame attribution, exact injection inversion and output validation. A static review or prior Phase58 semantic pass cannot certify a new diagnostic capture.

## Decision and next discriminating test

Compare fresh Lexer and Evening allocation/CPU profiles against actual source spans; rank a few source hypotheses by absolute estimated work and a cheap counter, without changing representation or runtime.

## Preservation

The design and these initial records are registered before results are added; the root checkpoint will bind their actual bytes. This is a new information-only campaign, not a retrospective Phase58 rewrite. Preserve consumed parent tools, failed/partial captures and closed Phase58 evidence; publish raw archival status only after explicit writer closure and member verification. The installed release remains Phase58 last01.

## Completed outcome and revised frontier

First-window cumulative sampling records B2 allocation of 246.094MB on Lexer / 898.285MB on Evening versus TS64.958MB / 123.968MB. These are sampled cumulative allocated bytes including collected objects, not RSS or exact object counts. Evening places much more mass in String search/scanner dispatchers and emitted-reach ancestry; those overlapping views must not be added. Lexer emphasizes checking/completion, substitution and persistent indexes.

The new primary hypothesis is **generic unchanged String head-plus-tail reconstruction elision**: actual generated String.contains and dependency scanner code extract a Unicode head and tail, then reconstruct the original string for subsequent inspection. Source shape plus profiles warrants a small falsifier, not a proven V8 copying/flattening model or speedup. Shared dispatcher attribution does not establish which member allocated every sample.

**Decision:** information gathered; next test should scale length and compare a provenance-preserving diagnostic rewrite with empty/astral/prefix-failure/overlap/effect controls before any compiler pass. [Counter/source findings](../../implementation/phase59/counter-findings.md) and [profiles](../../implementation/phase59/profile-stage-attribution.md) retain exact scope. No optimization promoted.

Across the campaign, 38 serial target processes consume 180.155 s recorded wall time; maximum observed process-tree RSS is 622.55 MiB. This excludes source/tool/review/publication work and does not classify all elapsed time as active thinking or waiting. Preservation passes closed Phase58's 30,169 files, installed 7 and protected 103. Raw writers are closed and streamed member verification passes. The [publication index](../../selfhost/tools/performance/phase59/artifacts/raw/publication.json) and [verified archive manifest](../../selfhost/tools/performance/phase59/artifacts/raw/archive.json) bind all preserved evidence; there is no new installed compiler. The [final report](../../implementation/phase59/README.md) owns canonical result tables, exact identities and reproduction links.
