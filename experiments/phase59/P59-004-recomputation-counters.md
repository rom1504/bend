# P59-004 — Narrow counters distinguish repeated work from useful work

- Owner: Phase59 evidence/documentation owner; root executes targets; independent method review required.
- Registered: 2026-10-06; evidence cutoff: initial information-only plan, no results credited here.
- Objective: explain the remaining compiler first-request gap before proposing optimization.
- Correctness: installed Phase58 last01 unchanged; completed diagnostics pass their prepared-output and instrumentation checks, not a new compiler qualification.
- Measurement: completed Phase59 clean/profile/stage/counter observations; final scope and limitations below.
- Decision: information gathered; future hypotheses ranked, no optimization or release change promoted.

## Claim and cheapest disproof

**Hypothesis:** Bounded operation counters reveal genuinely repeated primitive metadata construction, render/use/ref scanning or immutable reconstruction beyond existing stable/memo paths during one ordinary first compile.

**Invariant:** Counters live only in private diagnostic copies with exact injection inversion and unchanged prepared complete output. Aggregate counts once per request; avoid per-node logs or serialized keys. Separate generic/stable calls and successful/useful changes where proven; no context-incomplete cache or compiler-source change.

**Falsification / stop condition:** Existing caches eliminate the suspected repetition, counts are too small to explain measured absolute cost, injected scope is incomplete, or output/forcing order changes. Variable absence is insufficient when core_rebuild can canonicalize or beta-reduce.

## Controlled setup

The [fixed design](../../design/phase59/first-request-attribution.md) pins selected source `85454aab…`, checked B1 `641381f6…`, genuine B2 `a73daccf…`, upstream `018751270e800bc222a93dad7f257083ee53a5f7` and Node24.18.0. Subject workloads are Lexer and Evening library compilation, not execution of the full45 program corpus. Private Base caches are prepared before measured workers; this is not a cold filesystem experiment. Derived [latency/profile methods](../../selfhost/tools/performance/phase59/latency/) and [counter methods](../../selfhost/tools/performance/phase59/counters/) must retain parent/output identities and genuine B2 lineage, with no fabricated checked sidecar.

Root runs one guarded target at a time on CPU3: 1GiB heap, 2GiB tree RSS ceiling, 4GiB available-memory floor and existing 4MiB stack. Analysis/data-only work uses CPU0. Preserve all failures and exact commands/configurations in fresh Phase59 outputs. No compiler builds, full-image regeneration or repeated full-program campaign are authorized by this hypothesis record.

## Gates and observations

The initial registration contained no outcome. Completed scoped results are recorded below; instrumentation scope and prepared-output equality are required before interpreting them. Clean timing, profiled allocation/CPU, nested wall intervals and operation counts retain distinct units and populations. Later results will link actual immutable report identities here instead of copying competing tables.

## Independent audit

Review should challenge omitted warmup, scope/nesting, trampoline forcing, shared-frame attribution, exact injection inversion and output validation. A static review or prior Phase58 semantic pass cannot certify a new diagnostic capture.

## Decision and next discriminating test

Start with the repeated89-entry primitive table and text-analysis counters; use stage/profile evidence to admit only one further counter question. Counts motivate a future bounded transform, not a speedup extrapolation.

## Preservation

The design and these initial records are registered before results are added; the root checkpoint will bind their actual bytes. This is a new information-only campaign, not a retrospective Phase58 rewrite. Preserve consumed parent tools, failed/partial captures and closed Phase58 evidence; publish raw archival status only after explicit writer closure and member verification. The installed release remains Phase58 last01.

## Completed outcome and revised frontier

Both narrow diagnostic first requests pass exact prepared-module bytes. The actual primitive table has **90** rows, correcting the initial 89-entry expectation above. It is reconstructed 711 / 2,595 times (Lexer / Evening). This identifies repeated executed record-literal sites and linear lookup comparisons, not proof that V8 physically allocates each row or that removing them yields a proportional speedup.

Persistent index_remove reconstructs 329,274 / 374,623 retained event-list links. Generic substitutions and nonliteral rebuilds are numerous, while the existing stable proof already succeeds; duplicating it is not a fresh solution. Quantity get/delete visits average about 2.83 per merged left entry here, making quantity merging lower priority on these two inputs without claiming good wide-scope scaling.

The [counter report](../../implementation/phase59/counter-findings.md) separates actual source operations, table sites, String scanning, substitutions, trie nodes and retained lists; no sampled-bytes/count division is used as an exact allocation cost. The insertion-only derivative has explicit entry scope, unchanged output and independent review.

**Decision:** bounded recomputation opportunities observed. After the higher-ranked String test, consider primitive dispatch/table reuse and index-event copying with exact precedence/context proofs. No cache, data-structure rewrite or performance gain promoted.

Across the campaign, 38 serial target processes consume 180.155 s recorded wall time; maximum observed process-tree RSS is 622.55 MiB. This excludes source/tool/review/publication work and does not classify all elapsed time as active thinking or waiting. Preservation passes closed Phase58's 30,169 files, installed 7 and protected 103. Raw writers are closed and streamed member verification passes. The [publication index](../../selfhost/tools/performance/phase59/artifacts/raw/publication.json) and [verified archive manifest](../../selfhost/tools/performance/phase59/artifacts/raw/archive.json) bind all preserved evidence; there is no new installed compiler. The [final report](../../implementation/phase59/README.md) owns canonical result tables, exact identities and reproduction links.
