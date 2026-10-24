# Phase136 — Explain full cold compilation before changing representation

Investigation starts2026-10-24 from`286fe9987e7bf79f6de6f7652e988f3148aff41c`.
The objective is to identify structural work worth eliminating on the ordinary
native compiler path.60 seconds, then20–30 seconds, are ambitions rather than
predictions. No selected compiler, proof, runtime behavior or backend policy is
changed by this investigation.

## Fixed workload and baseline

Use the qualified Phase134 N2, fixed Phase131 full compiler source at its actual
historical path, independently retained107MB QBE, pinned QBE/assembler/linker and
Phase128 runtime. This preserves the full-workload reference from Phase135 while
using the qualified ordinary compiler. A fresh process has no retained source,
edit or machine-object cache. The compact authenticated Base is an explicit
common preparation policy; this is not a live-Base or cold filesystem benchmark.

Measure through ordinary source-to-QBE, conventional monolithic machine build and
link. Report pipeline wall time, nested subprocess clocks, memory and semantic
checks separately. An overlapped pipe does not provide additive source/QBE times.
Keep every product's identity and require the complete independent QBE digest.

## Three bounded investigations

1. Add a separate checked diagnostic entry using the qualified compiler's exact
   pure computations. Split parse/import completion, checking, reporting,
   ownership, eligibility, context, annotation and erasure; split native admission,
   lowering, optimizer/verification and final rendering. Preserve the ordinary
   entry and mathematical proof bodies. Timings are separate from QBE output.
   Before acquisition, compare the diagnostic pure route and ordinary route on
   valid independent sources and error controls. Use evaluated data boundaries;
   account for changed lifetimes and instrumentation overhead.
2. Reuse the qualified native object and existing independently checked profiler
   runtime to obtain physical/active-context evidence without recompiling the
   compiler source. Bind the new executable, source map, runtime and sampler.
   Keep sample quality and exact-output gates. Active contexts are not inclusive
   call stacks or exclusive stage fractions. Full counters are optional only if
   their measured overhead is economical; prefer targeted queries.
3. Find a small source-grounded proxy for the dominant repeated work. Compare
   valid sizes, visited book entries/characters, allocations/destruction and
   indexing/borrowing alternatives where measured. Use existing ownership controls
   and exact source behavior. A hosted proxy is not a native whole-build speedup.

## Execution discipline

Aim for a30–45minute evidence-gathering cycle. One root-owned CPU3 target lane,
bounded4GiB large jobs,16GiB available-memory floor and256MiB output ceiling.
Three bounded agents handle instrumentation, profiler/source audit and baseline
provenance; the root runs targets and integrates. Quiet baseline timing has no
competing target jobs. Reuse old source/profile evidence; avoid another broad
runtime campaign or unrelated compiler literature survey.

Prefer at most one diagnostic compiler acquisition and one full timed diagnostic
request, plus one reusable-object physical capture if needed. Source checking and
small bridges precede expensive runs. Preserve failed attempts. Stop broadening
measurements once they distinguish the important hypotheses.

## Decisions and deliverables

Rank indexed identities/ownership facts, fewer traversals/intermediates, better
data ownership, compact storage and earlier reusable owner units against measured
costs. Record conditions, local ceilings, implementation difficulty and cheapest
falsifier. Do not select a universal IR rewrite or another cache layer by appeal.

Deliver baseline and stage tables, profile quality/attribution, scaling/proxy
evidence where economical, exact methods/compact receipts, rejected hypotheses
and a ranked next experiment. Retain source checking, final verifiers, ownership,
generated-code and native qualification obligations. Commit/push the investigation;
no PR comments or production promotion.
