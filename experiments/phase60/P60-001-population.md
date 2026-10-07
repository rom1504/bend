# P60-001 — Broader source population changes the observed compiler-gap distribution

- Registration: 2026-10-06; design and exact population audit pending.
- Owner: Phase60 documentation/evidence owner; root alone executes targets; independent review required.
- Correctness: installed Phase58 last01 unchanged; no new compiler qualification or release.
- Measurement: planned only; no Phase60 result credited.
- Decision: information-only investigation; no optimization or PR comment.

## Claim and cheapest disproof

**Hypothesis:** The broad benchmark-source population exposes material compiler-cost variation missed by the two-case Lexer/Evening study.

**Invariant:** Audit point→source/module/export/adapter identities before measuring. The 45 runtime points are not45 distinct compilation inputs. The expected 23 unique sources is provisional; deduplicate only requests with identical source and compile mode/options/entry/export contract. Keep source-level distributions separate from any point-weighted summary.

**Falsification / stop condition:** The identity audit changes the population, required outputs/oracles are missing, or compile-request equivalence is assumed from filenames alone. Do not infer program execution speed from compiler clocks.

## Controlled setup

Root is preparing `design/phase60/broad-compiler-survey.md`. The measured compiler is unchanged genuine last01 B2 `a73daccf…` versus pinned TypeScript `018751270e800bc222a93dad7f257083ee53a5f7`; source `85454aab…`, installed checked B1 `641381f6…`. Existing benchmark catalog has 45 runtime points and provisionally 23 source inputs; the source/entry/adapter audit, not this expectation, defines compilation requests. No optimization, new image build, release or generated-program performance claim is part of this pass.

Root runs serial guarded targets on CPU3 with existing stack/heap/RSS/deadline policy and one guard. Agent source/data analysis uses CPU0. Fresh Phase60 private copies/caches/outputs preserve actual compiler/driver/runtime/Base/tool identities and complete output oracles. Closed Phase59 and earlier tools/raw stay unchanged. Exact commands and profiler admissions will be bound by the forthcoming reviewed method; this record grants no target launch.

## Gates and observations

Population and method are pending. Retain actual per-input preparation, requests, outputs and failures before any aggregate. A runtime-point observer is not a distinct compiler invocation. Profile durations, clean clocks and source-operation counters cannot be pooled as one performance measure.

## Independent audit

Challenge source/adapter deduplication, window equivalence, complete oracle scope, cache priming, sampler/attribution warnings and subset selection. No prior two-input result or checked compiler identity proves a new instrumented broad capture correct.

## Decision and next discriminating test

Complete the catalog/source/adapter audit first, then compare unchanged genuine last01 B2 and pinned TS over the exact admitted source-request population.

## Preservation

Initial registration precedes outcome entry; root checkpoint binds actual design/tool bytes. Preserve failed/partial runs and consumed methods in fresh Phase60 paths; no archive completion before explicit writer closure/member verification. The installed release remains Phase58 last01. Final conclusions will link canonical reports without duplicated numeric tables.
