# P60-003 — A small measured subset can test the next general hypotheses quickly

- Registration: 2026-10-06; design and exact population audit pending.
- Owner: Phase60 documentation/evidence owner; root alone executes targets; independent review required.
- Correctness: installed Phase58 last01 unchanged; no new compiler qualification or release.
- Measurement: planned only; no Phase60 result credited.
- Decision: information-only investigation; no optimization or PR comment.

## Claim and cheapest disproof

**Hypothesis:** A few audited inputs selected from distinct measured bottleneck groups retain useful falsification coverage while reducing iteration cost compared with rerunning the whole survey.

**Invariant:** Select the subset from the completed broad evidence by an explicit cost/coverage rule, not a desired speedup. Keep one negative/opposite-group input and expose the selection rationale. A fast subset cannot replace broad correctness or claim whole-corpus compiler parity; any future transform needs its own semantic proof.

**Falsification / stop condition:** The subset drops a dominant group, relies on benchmark-name selectors, or predictions fail held-out inputs. Small/microbench gains alone cannot justify general optimization or release.

## Controlled setup

Root is preparing `design/phase60/broad-compiler-survey.md`. The measured compiler is unchanged genuine last01 B2 `a73daccf…` versus pinned TypeScript `018751270e800bc222a93dad7f257083ee53a5f7`; source `85454aab…`, installed checked B1 `641381f6…`. Existing benchmark catalog has 45 runtime points and provisionally 23 source inputs; the source/entry/adapter audit, not this expectation, defines compilation requests. No optimization, new image build, release or generated-program performance claim is part of this pass.

Root runs serial guarded targets on CPU3 with existing stack/heap/RSS/deadline policy and one guard. Agent source/data analysis uses CPU0. Fresh Phase60 private copies/caches/outputs preserve actual compiler/driver/runtime/Base/tool identities and complete output oracles. Closed Phase59 and earlier tools/raw stay unchanged. Exact commands and profiler admissions will be bound by the forthcoming reviewed method; this record grants no target launch.

## Gates and observations

Population and method are pending. Retain actual per-input preparation, requests, outputs and failures before any aggregate. A runtime-point observer is not a distinct compiler invocation. Profile durations, clean clocks and source-operation counters cannot be pooled as one performance measure.

## Independent audit

Challenge source/adapter deduplication, window equivalence, complete oracle scope, cache priming, sampler/attribution warnings and subset selection. No prior two-input result or checked compiler identity proves a new instrumented broad capture correct.

## Decision and next discriminating test

After group analysis, rank two or three concrete general hypotheses and their cheapest counterexamples; name a fast subset and held-out checks without implementing a compiler change.

## Preservation

Initial registration precedes outcome entry; root checkpoint binds actual design/tool bytes. Preserve failed/partial runs and consumed methods in fresh Phase60 paths; no archive completion before explicit writer closure/member verification. The installed release remains Phase58 last01. Final conclusions will link canonical reports without duplicated numeric tables.
