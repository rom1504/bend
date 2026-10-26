# Phase144 — a measured path toward a 50-second cold build

2026-10-26, starting at `63dd41d`. User authorizes the ambitious cold-build
campaign and explicitly requests using and improving the profiler. Preserve the
Phase143 qualified ordinary-native compiler, Phase137 fallback and incremental
experiments. No installed/default change is implied.

## Baseline and ambition

Phase143's same-source request compiles the frozen Phase142 source in296.541s.
Machine construction takes15.218s; complete supervised operations315.310s.
The input, prepared Base, runtime, complete QBE oracle and CPU policy stay fixed
for causal comparisons. Fresh process/no previous-source semantic or object
reuse; OS caches are not flushed. Compiler acquisition is a separate cost.

50s is an architectural target, not a forecast. With an unchanged15–18s machine
and supervision tail, a single-core50s build needs roughly9× faster compiler
execution. A conditional multicore budget is297/4/2.5 +15+5≈50s: fourfold less
sequential work and2.5× effective parallel acceleration. Neither factor is
established. Report single-core and multicore clocks separately.

The current detailed profile is of Phase142, before78s of work disappeared.
It cannot establish Phase143's residual costs. Refresh attribution first.

## Time and decisions

Approximately six hours available for this campaign. Root owns one resource-
intensive CPU3 lane. Bounded agents may inspect source, prepare independent
prototypes and review semantics; they do not launch competing target campaigns.

1. First30min: authenticate selected artifacts; refresh the retained-object
   profile. Extend exact native milestones through backend/rendering where
   real dispatch entries support them. Validate a small request before full
   capture. Measure overhead and preserve unknown/lost attribution.
2. Next60min: obtain independent structural ceilings and one cheap candidate.
   Inspect constructor/ownership facts across preparation→erasure→lowering;
   assess a same-source C/Clang execution arm, with bounded acquisition and
   explicit argv/runtime identity. No old-source C ratio may stand in for it.
3. Protect about2h for the strongest substantial representation experiment:
   compact typed identities/data with bounded lifetime, reusable semantic facts,
   or fragment/byte-oriented emission. Select by the new residual profile.
   Charge conversion, preparation, querying, output and destruction together.
4. Use the following90min to extend demonstrated wins to another consumer or
   unrelated workload, compose compatible changes, and measure an actual cold
   request. Investigate parallel units only after identifying real independence
   and a low-cost measurement; do not assume Bend source runs concurrently.
5. Reserve the final hour for one justified native integration/qualification,
   same-source measurements, evidence/cost accounting and commit/push. Stop weak
   hypotheses after20–40min of decisive evidence rather than broaden them.

The order may change when evidence identifies a materially better experiment.
No duration or ambition level justifies a speculative rewrite or weakened gate.

## Competing hypotheses

H1: Generic linked terms, repeated names and temporary objects dominate several
passes. A compact scalar/index representation carried through an entire private
computation can remove allocations, lookup, traversal and reclamation together.
An array of unchanged boxed records is not this transformation. First test one
real compiler unit including adapters; require transfer before broad rollout.

H2: Multiple consumers independently reconstruct the same immutable book or
function facts. A checked request-local summary can remove that preparation
without cross-request invalidation machinery. Preserve first-match/shadowing,
first-False, exact errors, source provenance and final verification.

H3: Rendering builds and destroys linked String intermediates before writing
bytes. Preserve fragments or use a generic byte-oriented runtime boundary while
keeping QBE semantics in Bend. Existing streaming and linear nt_text_finish
already exist; per-line writes and prior batching failures are not new ideas.

H4: The compiled compiler is limited by generated QBE/runtime execution rather
than only algorithms. An identical-source C/Clang image offers a diagnostic
ceiling. Its acquisition, memory and failed attempts count; no backend migration
or generated-program speed gain follows merely from using another builder.

H5: Checked owner/function groups can execute independently. Identify serial
checking, deterministic symbols, global summaries, diagnostics and ownership
boundaries before a parallel prototype. Report work, critical path, actual core
count, peak memory and complete output; never present warm reuse as cold speed.

## Profiler improvements

Reuse the generic sampler, ownership map, retained object and runtime relinking.
Add exact phase-boundary observations and, only if needed for a decision, bounded
allocation/query counters. Separate physical samples from active Bend owners;
these overlap. Dispatch owners are not inclusive source stacks. Attribute work
to exact source/image identities and distinguish diagnostic time from clean
timings. Missing/duplicate markers invalidate the associated interval, not the
correctness of otherwise independently checked output.

## Gates and resource discipline

- Small checked controls compare complete old/new semantic products, including
  failures, collisions, sharing, ownership and arithmetic boundaries.
- Native extracted workloads include the real consumer and cleanup. Preserve
  every failed or neutral variant, not only the fastest sample.
- Exact full QBE and runtime identity permit reusing generated-program evidence.
  Changed products need relevant independent semantics and runtime comparisons.
- Do not remove or weaken the independent final verifier. Source laws/proof
  declarations remain unchanged unless separately justified and checked.
- Acquire a new compiler only after a plausible measured useful-work gain.
  Then independently source-check, use qualified native→N1→N2, compare complete
  self-emissions, focused19 on both and ordinary45 on final N2 when adopting a
  new explicitly qualified checkpoint. Default selection is a separate decision.
- Ordinary lane:3GiB tree RSS,16GiB available-memory floor, CPU3. A C acquisition
  may use a separately recorded larger RSS bound if memory availability permits;
  never disable the guard or run simultaneous heavy jobs.
- Preserve disk headroom by byte-verified deduplication of immutable generated
  artifacts. Record path/hash evidence; do not remove source or unrelated work.

## Deliverables

Commit the design, per-hypothesis files, actual compiler/profiler changes,
reproducible controls and source/image identities. Report complete cold clocks,
generated-code quality, native qualification, memory/source complexity, guarded
experiment cost and failures. Distinguish demonstrated gains, conditional50s
budget and rejected hypotheses. Do not claim recursive acceleration merely from
successive commits or self-reproduction.
