# Phase171 follow-up: reject a weak optimization and expose runtime callers

The best measured complete cold build remains **180.677s versus188.620s**
(4.21% less time, one matched observation per role). The100s goal is not reached.
The new experiments below do not establish an additional full-compiler speedup.
The installed, qualified Phase170 compiler remains unchanged.

The useful new result is a falsification: a borrowed descendant optimization now
executes successfully on99.535% of calls to the selected `index_find` wrapper
in the real-verifier workload, yet changes its
complete native runtime by only1.25%. Low admission coverage no longer explains
this workload's remaining performance gap. We stopped expanding the prototype
and did not acquire another full compiler image for it.

[Exact evidence/cost inventory](followup-metrics.json) ·
[Prototype and negative history](../../experiments/phase171/borrowed-selectors.md) ·
[Reproduction](../../experiments/phase171/descendant-history/README.md) ·
[Runtime caller results](../../experiments/phase171/runtime-callers.md).

## What was implemented and learned

The experimental checked Bend transform preserves held owning roots while
read-only helpers inspect their descendants. It replaces intermediate keep/take/
sink traffic with verified reads and local aliases, then promotes a successful
result before releasing the roots. The unchanged owning computation remains the
fallback. Supported helper composition, bounded local buffers and compact scalar
joins were added after real generated code exposed initial coverage gaps.

A source audit caught an actual prototype defect: removing a sink also removed
its zero-valued destination assignment. The final version preserves that binding.
Another boundary was ownership: a raw non-RFC descendant cannot simply be kept
and then returned after its parent is dropped. The narrow result-only permission
admits a valid RFC-count-one child, increments the same cell before releasing
roots, and leaves root/helper admission unchanged. The exact delta argument is
[retained separately](../../experiments/phase171/result-guard-delta-audit.md).
This is a bounded valid-state argument plus finite tests, not a new BendTT proof,
all-error-state equivalence or parallel-runtime qualification.

Final source15 passes47 finite compiler-data controls, independently specified
complete18-record lookup values, the actual verifier's768 result and its three
complete diagnostic strings. The native machine products use the same pinned
runtime and machine toolchain. Four balanced process pairs, including startup
and teardown, give:

| Complete native workload | Baseline | Prototype | Candidate / baseline |
| --- | ---: | ---: | ---: |
| Lookup plus complete-record digest |0.557612s|0.557376s|0.999576×|
| Actual final-verifier computation |0.421140s|0.415858s|0.987457×|

The separate verifier coverage run records165,120 entries:164,352 successful
promotions,768 reader refusals, zero root or result refusals. Counts are derived
from authenticated call-site observations and the exact emitted predicate/CFG;
they are not physical CPU samples. High coverage plus small complete-runtime gain
rejects the idea that this selector permission alone can remove a major part of
the compiler's ownership cost. Hosted emission also adds analysis work (the
candidate lower/verify stage was17.197s versus13.512s in the retained ordinary
baseline; these are separate screens). The optimization is not adopted.

The unrelated list fixture declined with no actual direct owner. Earlier neutral
measurements, source-check failures, the sink defect and the non-RFC limitation
remain recorded. Intermediate source12–14 is reproducible from authenticated
38,399-byte deltas instead of committing148,702 bytes of duplicate source trees.
The original and final experimental modules remain explicit; production has one
unchanged implementation.

## Other small hypotheses were neutral

| Experiment | Complete hosted baseline | Candidate | Decision |
| --- | ---: | ---: | --- |
| Reuse liveness environment |29.032s|29.514s|No demonstrated gain; baseline was an earlier capture.|
| Reuse renderer hygiene facts |29.013s|29.176s|No demonstrated gain.|
| Fuse public body production with emission |28.937s|28.843s|Neutral single screen; render stage itself rose2.740→2.820s.|

All preserve the complete2,309,376-byte verifier QBE product. Their44,44 and48
finite controls respectively pass. None is promoted, assigned an upstream ratio,
or extrapolated into full-build savings. Details are in
[liveness](../../experiments/phase171/live-env.md),
[rendering](../../experiments/phase171/render-clean.md) and
[public emission](../../experiments/phase171/public-emission.md).

## The profiler now reveals one runtime caller

The previous caller table covered libc only: its227 recovered samples all led
to register copying. It provided no ownership-helper callers. The new sampler
uses exact unwind rules for30 runtime functions in the **same retained compiler
executable**. No compiler image or runtime rebuild was needed; only the sampler
was recompiled. Original stage identities and independent output checks remain.

The1ms pilot lost samples and is rejected for performance attribution. A32ms
pilot passed caller/output integrity with too few samples for quantitative
shares. The full32ms capture then passed exact97,488,970-byte QBE, stage ordering,
99.34% main-thread/process-CPU coverage and zero loss:5,429 samples,2,269 eligible
and successfully recovered callers (41.79%). Its175.011s is diagnostic compiler
execution, not a new complete source-to-executable result.

A recovered caller may be another runtime helper. Tail-erased calls and the
remaining unsupported samples stay unknown; this is not an inclusive source
stack, allocation-source census or an estimate that41.79% of time is removable.
The [separate analysis](../../experiments/phase171/runtime-callers.md) preserves
those denominators and distinguishes direct generated callers from runtime
intermediaries. Of all5,429 samples,966 recover a generated compiler caller,
1,303 recover only a runtime intermediary and3,160 have no supported caller.
Combining `String.append` leaf samples with its immediate runtime callees without
double counting identifies273 samples (5.03% of the full capture), including
183/960 rendering-window samples (19.06%). This exposes string materialization
as a concrete bounded target; it does not attribute every allocation to rendering
or explain the entire80-second remaining gap.

## Next decision toward100s

Stop extending the borrowed-selector, liveness and renderer experiments. They
have answered their immediate questions. The next implementation needs to remove
substantial repeated work across an actual producer and its consumers.

Two concrete alternatives remain:

1. **Defer pattern substitutions until a surviving branch is materialized.**
   First compare complete loader results, spans, binder identities and diagnostics
   on actual compiler source. Keep the old freshener as an independent boundary.
   A one-call fused substitution is a cheap mechanism gate, not evidence of a
   large speedup; the whole parse/load interval is only29.545 diagnostic seconds.
2. **Share one semantic function graph across direct/scheduled lowering and
   later region construction.** First select a real refused compiler family
   that pays for both paths and reconstructs information afterward. Measure its
   complete backend request, retaining final verification and generated-code
   quality. Another wrapper around already shared bodies does not test this idea.

The [independent decision audit](../../experiments/phase171/decision-audit.md)
and [work ceilings](../../experiments/phase171/next-work-ceilings.md) explain the
existing negative evidence and cheap falsifiers. No current measurement supports
promising100s from either alone. The key gate is meaningful complete-request
savings before another full image/qualification campaign, rather than counting
fewer allocations or successful admissions as speed gains.

## Cost and scope

The final follow-up inventory contains90 terminal guarded jobs, **882.393s
(14.71min)** in the controlled target lane, including9 nonzero attempts. All runs
are sealed; none remains active. This is additional to the original40-job
checkpoint's1,254.774s, not additional to the intermediate44-job follow-up
snapshot (which is a subset). Total recorded Phase171 guarded execution is
2,137.167s. These sums include checking, failed experiments, emission, small
machine builds, measurements and diagnostics; they are not total agent/research
elapsed time, exclusive CPU or quota usage. Those latter values are unavailable.

The new full caller capture cost177.328s guarded elapsed and peaked below786MiB
RSS. Jobs preserved the5GiB disk reserve and used the single CPU3 execution lane.
An initial guard CLI invocation used an invalid output location and started no
target; it is not included as a guarded job. Only source transport, measurement
and independent oracle comparison use host
scripts; the compiler transformation is Bend. No production/runtime/selector
change, new broad conformance campaign, full follow-up image acquisition or PR
comment occurred. The original four-overlay candidate remains available, and
its promotion gates are still open.
