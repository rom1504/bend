# Stop expanding the selector kernel; test one shared lowering graph

Read-only decision audit, 2026-11-06. No targets, new implementation or changes to
the selected compiler. The frontend composed-substitution investigation belongs
to a separate review and is not repeated here.

**Yes: further isolated selector/guard variants would now be overinvestment.**
Source15 has finally reached the intended execution path, so lack of coverage
is no longer a persuasive explanation for this workload's small gain.

| Complete native consumer, four balanced process pairs | Baseline | Source15 | Ratio |
| --- | ---: | ---: | ---: |
| Lookup plus complete digest |0.557612s|0.557376s|0.999576|
| Real verifier |0.421140s|0.415858s|0.987457|

These are the actual `descendant-find-pair15/report.json` and
`descendant-verifier-pair15/report.json` receipts under `selfhost/build/phase171`.
The independently audited [verifier guard observation](guard-coverage-verifier15.md)
derives **164,352 promotions out of165,120 calls (99.535%)**, with768 owned
fallbacks. It includes99,072 extra RFC-permitted promotions. These are diagnostic
coverage counts, not clean timing counters. All paired output gates pass.

The [result-permission argument](result-guard-delta-audit.md) and
[Source15 wrapper](../../selfhost/tests/phase171/descendant-v15/borrowed-selectors-entry.bend)
justify the bounded valid-Data experiment; they do not convert the1.25% verifier
gain into a compiler-wide forecast. Remaining cost includes the consumer,
construction and other traversals. General borrowing is not disproved, but this
particular selector is no longer a high-leverage lead. Preserve the work and stop
before another standalone compiler acquisition for it. The hygiene-sharing and
public-emitter intermediates also already have neutral complete-request screens;
their large enclosing stage durations are not their own removable costs.

## One architectural hypothesis to retain

**Lower each prepared source body once to a semantic function graph, and derive
direct or scheduled calling conventions from that graph without reconstructing
its semantic analysis.** Keep ordinary calls, locals, branches and explicit
suspend/resume edges in that graph. Liveness, arity/layout facts and continuation
capture facts belong to that exact graph. Actual emitted direct and scheduled
products still receive the existing independent final checks.

The concrete duplicated boundary remains:

- [`p168_selected`](../../selfhost/src/back/qbe/early-observers.bend#L340) constructs
  private/product candidates before dependency admission.
- [`p167l_family`](../../selfhost/src/back/qbe/early-demand.bend#L288) later lowers
  a demanded nonadmitted source body again; `p167l_dispatch` distinguishes genuine
  factories, families and adapters.
- Registry/public emission then reconstructs callable local regions from the
  scheduled product. Both source analysis and its temporary representations can
  survive even when candidate bodies are ultimately discarded.

This is a replacement of those producers, not another prepared-body cache:
`NativeStaticBody` is already shared, admitted direct owners already avoid generic
bodies, and output already streams. Nor is it the tested late frame-import bridge:
that bridge found **zero imports/zero added callers on the real verifier**
([result](checked-import-prototype.md#real-workload-falsifier)). A new graph must
represent the actually blocked recursive/call shape, rather than merely increase
that bridge's counters or turn an unchecked cycle into ordinary machine calls.

This is the largest concrete remaining backend hypothesis, **not evidence that
it will reach100s alone**. Current candidate diagnostic raw production, demanded
fallback, registry and render/exit sum to76.218s (24.985+8.508+12.271+30.454).
They contain necessary work. Even halving all four saves only38.109 diagnostic
seconds. The clean target needs80.677s from180.677s, and these diagnostic seconds
cannot be subtracted directly from that clean build. No honest single-stage
promise currently closes the gap. A100s route requires much broader elimination,
faster execution across stages, or the independent frontend improvement as well.

## Cheapest falsifier before committing to that rewrite

First use the existing real verifier request and current pending attribution to
identify a **nonadmitted ordinary function family that actually incurs both
lowerings and late region work**. Record the actual original body, raw candidate
and refusal, demanded family and final region plans. If such repeated work is a
small part of the complete backend on real compiler inputs, stop this hypothesis
before constructing a new graph. Source size or number of emitted wrappers is
insufficient evidence.

Then implement one vertical slice for that general function shape: one graph
producer, direct/scheduled projections and the existing final consumers. Reuse
exact fresh-ID/capture order so complete original IR products and complete QBE
can be compared. Include a required fallback and a distinct Map request. Charge
graph construction, retained storage, projection, verification, rendering and
destruction; do not time only the new graph's traversal. Keep factories, public
ABI, stack-safe non-tail returns, source-derived array/cold authority and original
failure order. No fake generic reference or verifier bypass.

A substantial speedup of that complete backend boundary plus measured removed
analysis/materialization justifies expansion. A faster micro-pass with a neutral
complete request rejects it. Do not spend on a full native candidate merely
because graph/IR counts are smaller. The current selector result is the concrete
reason to enforce this gate more strictly now.

Evidence: [candidate stage profile](candidate-profile.md),
[current physical-profile limitations](current-profile.md),
[two measured-scope ceilings](next-work-ceilings.md), and
[existing architectural boundaries/Phase164 negative](architecture-audit.md).
