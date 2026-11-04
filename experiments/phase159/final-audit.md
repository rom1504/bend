# Phase159 final claim audit

Read-only receipt/source review, 2026-11-04. No targets were run by this audit.
Finalized after the post-timing full-output gate and accepted pooled candidate
profiles. Rejected earlier captures remain part of the evidence.

## Strong result, narrow object

`selfhost/build/phase159/refill-time01/report.json` contains four alternating
clean pairs at16 repetitions: original GC median **13.835513s**, capped scan
median **2.585212s**, or **5.3518× faster /81.31% less elapsed time**. CPU closely
tracks wall time. Median peak RSS changes1,211,954→1,214,772KiB, about**+0.23%**;
this result is not obtained by a materially larger measured heap in these runs.
All eight benchmark processes exit0 and match their empty benchmark streams.
Those streams mean checked writes to`/dev/null`, not independently proven output.

The program is **the Phase157 five-owner captured compiler pipeline**, repeated
16 times. It includes captured-book loading/preparation,80 complete owner
computations, independent verification, rendering, consumption and teardown.
It is not our maintained compiler processing arbitrary source, a full compiler
request, its self-build or the45-program runtime suite. Correct headline:

> Bounding one optional reuse search makes this bendc-generated compiler
> workload about5.35× faster, with nearly unchanged measured peak memory.

Incorrect headline: “our compiler is now5× faster” or “we reached full compiler
parity.” No qualified/installed compiler or production algorithm was changed.

`refill-prepare01/report.json` binds the original196,009-byte runtime header and
the196,031-byte candidate. Its only change is
`b == NULL && n <= nw` → `b == NULL && n <= nw && (shared || n < 64)`.
Generated Bend workload C, original ABI adapter and machine optimization policy
remain fixed. This is substantially stronger causal evidence than comparing
unrelated compiler self-build times. It changes a reuse-search policy while
preserving the existing claim checks and allocation/collection fallback; see
[refill-audit.md](refill-audit.md) for the source argument and resource risks.

Four pairs do not establish confidence intervals, universal memory behavior or
general allocator correctness. The cap can defer reuse outside its fixed search
window. Similar RSS here does not prove that other programs cannot regress or
exhaust a tighter heap. The candidate remains a foreign-runtime experiment.

## Correctness and profile gates as inspected

`refill-control01/report.json` checks both original and candidate with the
independent173,582-byte oracle before the timing block; both pass exactly. Its
N4 screen also passes. The original source, captured book and oracle remain
unchanged. `common-control02/report.json` passes all three **original** roles
after the common-workload comparison; it is not the candidate's final oracle.
The subsequent `refill-control02/report.json` is complete and passes the original
and candidate full-output controls, each with exit0, empty stderr and the exact
173,582-byte oracle. It records no changed inputs. The paired candidate timing
block is therefore bracketed by complete independent output checks.

Original common16 GC profiles are the motivation for the change: root identified
about77–78% of physical CPU samples in`gc_refill`, with the dominant PC range in
the whole-heap candidate-byte scan. The whole function's sample share is not
automatically all removable loop cost, and sampling alone did not establish causality. The
one-line controlled ablation now supplies direct causal evidence of a major
policy cost in this workload.

**Preserve a profiling negative:** both candidate captures in
`refill-sample01/report.json` return correct benchmark output but fail quality.
The2ms/3ms periods incur timer overruns and delivered/expected ratios of about
0.50/0.747. Both have`profileUsable:false`; adequate thread CPU coverage and raw
sample count do not repair loss or implausible delivery. Do not report their
function percentages as qualified post-change attribution. The clean paired
speed result stands independently.

The separate `refill-sample02` follow-up has four admitted 8ms/13ms captures.
The finalized maintained comparison,
`analysis01/refill-pooled-final.json`, pools **1,033 accepted samples**, with zero
loss/overruns, adequate whole-child CPU coverage and `estimateAvailable:true`.
`gc_refill` falls to a period-weighted **7.7916%**, an approximate0.201s of clean
CPU. This supports the predicted removal of dominant refill work. It does not
make the earlier2/3ms captures usable or turn the cost estimate into exact CPU
accounting. The initial `analysis01/refill-pooled.json` is retained as superseded
by the comparison that explicitly binds argv0; measured bytes/timings did not
change and required no rerun.

The earlier main-only historical seed capture is another useful rejection:
the work runs on a child thread despite one Bend worker. Main-thread sampling
there did not measure the workload. The maintained thread-aware collector and
explicit argv0 support fix observability without changing the workload source;
its per-thread PC concatenation is aggregate physical evidence, not a global
chronological trace or logical compiler stack.

## What changes about Phase157's conclusion

Phase157 correctly measured the **original** GC configuration as slower and
more memory hungry than its upstream/QBE counterparts on this pipeline. Those
observations remain valid. A universal rejection of GC or bendc's architecture
based on them would now be untenable: one peripheral allocation-policy search
dominated the result, and bounding it changes the performance picture radically.

Conversely, this is not evidence that GC always wins or that we should replace
QBE. The new paired block compares original GC against capped GC. Candidate
times also lie below upstream/QBE observations in a separate common-workload
block, but those ratios are not a new balanced four-role comparison. The GC
image still uses roughly1.16GiB on N16, whereas the original other roles use
far less. A broader runtime decision must include complete compiler requests,
generated-program coverage, cold setup, memory and engineering complexity.

The useful transferable lesson is to inspect **algorithmic work inside runtime
helpers**, not only language-level optimizer passes or high-level memory-policy
labels. A pooled allocator can spend most of its time searching metadata, rather
than requesting memory from the OS or collecting garbage. This also explains
why Phase157's relatively short measured collection intervals did not account
for its large clean runtime gap.

## Historical self-emission is a separate observation

`stage-run01/report.json` instruments the historical **9c54842e** compiler seed
from Phase158, using upstream2.0.32. The scan ablation instead modifies the
**56edcc65** runtime that produced Phase157's GC workload image. They have
different source/runtime revisions and jobs. Do not claim the cap sped up
historical4.50s self-emission, or attribute the historical compiler's speed to
this exact newer search path.

Both historical observer variants reproduce the complete2,802,777-byte public
C seed. Their observed pipeline starts with3,406 declarations, produces3,461
after optimization and records2,023`Gen.def` calls. These are particular stage
items/calls, not necessarily unique emitted C functions or comparable units to
our QBE segments. The evidence contradicts “bendc only optimizes reachable
definitions” or “it uses no intermediate forms”: it performs whole-program
lowering/optimization, then reachable code generation. Nested stage intervals
are explicitly inclusive and must not be summed as disjoint time.

The allocation-enabled observer records327,833,144 allocation requests and
8,067,958,712 requested bytes. Those are cumulative requested words/bytes at its
specific hook, **not**327million system malloc calls, peak memory or a physical
allocation-traffic comparison with our compiler. Counters-off instrumentation
takes4.7888s; enabling allocation counts takes7.3997s, about54.5% longer. Neither
is the original clean seed timing; use counters for work attribution and the
separate clean measurements for speed. Fast historical emission despite many
small requests shows why allocation count alone does not identify allocation
cost—representation, reuse searches and per-request work matter.

No complete same-source/full-compiler backend matrix, new conformance result,
proof, installed speed score or public upstream comment follows from these
findings. The strong result is a measured runtime bottleneck and a small,
output-preserving diagnostic intervention on one real compiler workload.
