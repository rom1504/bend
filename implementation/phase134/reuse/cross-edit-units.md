# Reusing optimized private units across real source edits

**The lexer edit is a promising result; Map does not establish a gain.** In two
balanced hosted comparisons, the edited lexer backend takes 0.735× and 0.731×
fresh time with the cache. Both old and edited complete QBE products match their
independent references. Map initially appears 21.6% faster, but reversing order
makes it 27.5% slower; the balanced ratio is approximately 1.000. High cache hit
counts alone remain insufficient evidence.

This is an isolated checked Bend prototype, not selected compiler behavior,
native qualification, or a persistent cache. Its successful abstraction is a
pure optimization unit with explicit consumed context, rather than a source
lowering unit that implicitly consults the entire book.

## What is actually reused

The [Bend implementation](../../../selfhost/tools/performance/phase134/compact/units-v01.bend)
retains actual results before rerunning the two expensive private transformations:

- An inline unit is keyed by the exact complete original `P113DFunction` and
  every inlining-table lookup result consulted by original-body direct calls,
  recursively including conditional branches. Results retain complete transformed
  callees or explicit absence, not just names/signatures. The current ordered
  table is rebuilt, and a hit republishes its result with the original admission
  and eligibility rules.
- A range unit is keyed by its exact complete input function. The existing range
  transformation depends on that function and fixed implementation only. A
  changed input recomputes. Its prior-revision memo takes precedence over an
  eligible same-request inner-range memo; neither uses the output as its key or
  assumes idempotence.

Slots are aligned hints. Additions, deletions, reordering, changed IR, changed
callee bodies and changed availability cause misses. Each request still repeats
source checking, admission, generic lowering, candidate preparation and opening
verification. The existing final verification and complete rendering still run.
The prototype skips actual transformations before they execute; it does not find
hits after doing the work.

The cache is trusted state returned by this fixed producer inside one process.
An externally forged cache can supply a well-formed but semantically wrong
transformation result; structural final verification is not a proof of equivalence.
No serialized, cross-version or untrusted-cache API is claimed. The
[source audit](../../../selfhost/tools/performance/phase134/compact/units-audit.md)
records the current dependency argument and limits.

## Controls and actual revisions

Frozen source `units-source01/compiler.bend`, SHA-256
`873921c3fb13e69450d65800e8b13a0cc9803b7a9ad4886cee8446f37a8f0dcc`,
passes independent source checking. All **99 finite controls** pass, including
20 new cache tests for present/absent callees, same-signature changed callee
bodies, nested calls, irrelevant table changes, original-body mutations,
publication on hits, changed/reverted callees, added/deleted/reordered functions
and invalid boundaries.

The actual edited sources are independently parsed and checked under the same
semantic path as their originals:

- Lexer: `U32.shln(x, 13n)` → `U32.shln(x, 12n)` in `prng`.
- Map: `U32.mul(i, 31)` → `U32.mul(i, 29)` in the update computation.

Every cold old result matches the independently frozen native QBE. Every warm
edited result matches a fresh, uncached complete compilation of the edited source
and differs from the old result. The fresh reference already includes the
separate within-request verification optimization; it does not use the unit
cache. Exact products are 577,297 bytes for lexer and 1,028,294 bytes for Map.
Both are real behavior-affecting edits, but neither changes source structure;
the experiment does not establish reuse for arbitrary refactors or edits that
perturb generated identities.

## Timing, acquisition and failed apparent transfer

These are upstream-generated JavaScript APIs executing the compiler written in
Bend. They are hosted measurements, not native N1/N2 timings. Each pair compares
fresh old compilation with cache creation on old source, then independent fresh
edited compilation with a warm cache from old source. The next pair reverses
order. Both source revisions are checked afresh before the backend comparisons.

| Workload / order | Fresh old | Create old cache | Fresh edited | Warm edited | Warm/fresh |
|---|---:|---:|---:|---:|---:|
| Lexer, fresh first | 6.250 s | 5.135 s | 4.506 s | 3.312 s | 0.735 |
| Lexer, cache first | 4.258 s | 4.373 s | 4.165 s | 3.047 s | 0.731 |
| Map, fresh first | 9.546 s | 9.017 s | 7.309 s | 5.728 s | 0.784 |
| Map, cache first | 9.392 s | 9.546 s | 5.621 s | 7.169 s | 1.275 |

Lexer reuses **26/31 inline units and 26/31 prior range units**; five units miss
in each pass. Map reuses **34/34 in both passes**, yet has no robust speedup.
Its source edit changes the complete QBE while the admitted private optimization
units remain unchanged. Avoided calls and unchanged private units should not be
confused with the work dominating the complete request.

The lexer warm ratio is 0.733 geometrically, about 26.7% lower backend time.
Its second pair makes acquisition cost visible: creating the old cache adds
0.115 s versus fresh old compilation, while the next edited request saves
1.119 s. Adding the measured frontend costs to both paths gives **9.615 s versus
10.619 s** for the two revisions, a 9.45% reduction. These are component totals
using the measured frontend observations, not independently timed native CLI
sessions. The first pair has visible JIT/order bias and is retained.

For Map, the two warm ratios balance to approximately **1.000**. The first large
improvement also exceeded its earlier transformation-only cost ceiling, prompting
the reverse-order test. That test overturned the transfer claim. JIT, garbage
collection or order effects are plausible explanations, not established causes.
Do not present the initial 21.6% as a measured general compiler improvement.

One-time API acquisition costs 15.28 s guarded wall time. The lexer experiment
costs 39.82 s with a 593 MB process-tree peak; Map's two separate experiments cost
36.72 s and 36.86 s, peaking at approximately 652 MB and 643 MB. Base preparation
costs approximately 0.7–0.8 s once per process. Agent effort, compiler-image
acquisition, machine building and full qualification are not amortized by these
two-edit component totals.

The retained cache graph contains 61,551 unique host objects for old lexer and
19,224 for old Map. These are identity-aware graph counts, **not native heap-byte
estimates**. Key checking and cache construction are inside measured requests;
the graph census is separate and included in experiment elapsed time. Native
reference-counting and reclamation costs still require measurement.

## Hosted decision and next falsifier

Retain this as a reproducible prototype. It is stronger evidence than the earlier
generic-owner cache because it reuses expensive contextual transformations and
shows a consistent lexer effect. It is not yet evidence for broad native gains,
upstream parity, or faster full compiler self-builds. Its implementation adds
206 physical Bend lines and nine data types, in addition to the reused equality
and inner-range helpers; selection requires a benefit worth that complexity.

The next decisive experiment is a bounded **native two-revision session**:
prepare Base once, check both requests, retain only the typed cache between them,
stream each sealed emission, and compare cache-retained against cache-reset
sessions. Use the same source/output identities and alternate process order.
This tests native ownership/reclamation cost and removes the strongest hosted
JIT confound. Structural edits and a compiler-derived workload should follow
before broader integration. The session adapter is separate work; this report
does not claim it has been measured natively.

The Map result also agrees with the earlier stage ceiling: its actual inline and
range transformations occupied only about 2.9% of warmed hosted backend time,
while candidate preparation occupied about 26%. A high transform-cache hit rate
cannot remove that preparation. If Map remains a priority, investigate that
earlier expensive boundary and its consumed semantic facts instead of repeatedly
tuning this lower-ceiling cache.

Evidence: [checked API](phase111/p134-units-api01/report.json),
[99 controls](phase134/units-finite01/report.json),
[balanced lexer pairs](phase134/units-lexer01/report.json),
[Map forward pair](phase134/units-map01/report.json), and
[Map reverse pair](phase134/units-map02/report.json).
Exact commands, pins, revised sources and resource receipts are archived alongside
these reports. The unchanged default compiler remains outside this experiment.

## Native follow-up

The subsequent [native session experiment](../session/README.md) now executes
this falsifier. Two balanced pairs show Lexer B21.32% less time and complete
A+B9.08% less time; Map B6.12%/complete2.62%, with more variance. All16 complete
products match independent ordinary coreN2 output and5 refusal controls pass.
This is cache-retained versus cache-reset in the same experimental image, not
a no-cache adoption comparison or full-compiler incremental qualification. The
hosted evidence and its original limitations above remain unchanged.
