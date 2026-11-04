# P159-003 — bound the measured GC reuse search

Two worker-complete profiles of Phase157's identical sixteen-batch workload place
77–78% of CPU samples in bendc's gc_refill, chiefly the per-thread candidate-byte
loop over up to the whole heap. This is allocation/reuse search, not tracing.
The earlier collection-interval total therefore missed most of this cost.

Private runtime-only ablation: cap only the non-RC search at64 iterations,
retaining all candidate checks, ownership claims, deferred-GC handling and the
original partial-block/collection/new-block fallback. Do not advance the cursor
or clear unseen candidates. Independent audit: refill-audit.md.

Gate complete original173,582-byte oracle before/after, original generated C,
same Clang flags, bounded2GiB RSS, clean timing separate from profiles. Compare
one/four/sixteen batches with original, then require the hot search to disappear
in sampled machine code. More heap/collection work is a real tradeoff. This is
one workload's causal diagnostic, not a generally qualified allocator change
or a production compiler promotion. Stop on a correctness/resource failure.

Result: four balanced16-batch pairs13.8355s→2.5852s,5.3518×; medianRSS+0.23%.
Before/after exact oracle passes. Physical refill share77.77%→7.79%; accepted
candidate1,033 pooled8/13ms samples, zero loss/overruns. First2/3ms captures
rejected for overruns/delivery. Existing GC/RC checks remain; no broad runtime
qualification. Full report and metrics: implementation/phase159.
