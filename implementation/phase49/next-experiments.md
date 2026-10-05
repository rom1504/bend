# Phase49: the next experiments

Prioritize private-entry permission: validation dominates this small RLE call.
The transport experiment removes real allocation sites, but these findings
do not establish that any guard can safely be removed.

## What the measurements establish

The following clean medians use five fresh rotated processes per role, the same
six-element RLE input and exact result `11`. Warmup/measured call counts are
524,288/1,048,576 for TypeScript, 16,384/32,768 for untouched Bend roles,
131,072/262,144 for full bypasses, and 16,384/65,536 for String omission.
Times include public dispatch, result checks and the checksum.
Raw evidence is `selfhost/build/phase49/guard-clean01/report.json`;
sampled allocation comes from the separate `allocation02/report.json` run.

| Role | Clean µs/call | Estimated allocated bytes/call |
| --- | ---: | ---: |
| Pinned TypeScript | 0.589424 | — |
| Retained array06 RLE baseline | 39.343444 | 33,262 |
| Unselected Phase48 V03 scalar-transport candidate | 39.365123 | 32,600 |
| Baseline, full entry-guard bypass | 0.804281 | 2,549 |
| Candidate, full entry-guard bypass | 0.835517 | 1,770 |
| Baseline, String guard omitted | 22.369606 | 24,847 |

The retained array06 RLE module is byte-identical to installed RNFA04 RLE output.
`selfhost/build/phase49/installed-rle-identity.json` proves program-byte identity, not compiler identity.

Bypass modules are unsafe diagnostic copies. They retain exact-entry/null-region
checks and the same private computation, but remove fresh host/dependency
validation. They neither relax the supported contract nor qualify installation.
Their gains are not mathematical upper bounds: altered guards can change V8
optimization decisions. Allocation estimates include collected objects and are
not exact allocation counts. Do not pool instrumented timing with clean timing.

The [V8 graph analysis](v8-ir.md) finds that the candidate really removes tuple
allocation sites. It also introduces six context loads and six context stores,
lexical-initialization checks and write-barrier paths. Its worker grows from
2,448 to 2,516 instruction bytes and from 16 to 17 safepoint stack slots. This
explains why fewer tuple sites are insufficient evidence of a faster convention;
it does not attribute a precise runtime cost to each retained operation.

## 1. Derive the required guard set, then try to falsify it

Build one proposed effect summary from the **complete original source graph**,
including both branches, erased-call provenance and demanded helpers. Add the
runtime operations that generic forcing, matching, constructors, errors and
public entry can observe, then compare that set with the proposed private path.
The set concerns semantic dependencies, not just the names emitted by a worker.
Unknown calls, escaped storage or unclassified runtime operations retain the
full fence. Existing immutable proof facts can carry this summary eventually;
the first experiment needs only a bounded diagnostic specification.

The 17 RLE dependency names contain no String operation. That is a hypothesis
generator, **not** proof that `stringHostGuard()` is redundant. A dynamically
unvisited operation or a hidden runtime observation may still require it.
Likewise, the roughly 1.76× String-omission diagnostic gain is not a promised
production gain or evidence for pruning every String guard.

Before any compiler pass, use saved-output variants and independent renamed
fixtures to challenge one proposed omission at a time. Compare exact values,
errors, getter/event order and reentry against the original path after mutations
to String, numeric/reflection hooks, source descriptors, `.code`/`.call`, and
prototype forcing markers. Include untaken branches and mutations between
successive calls. Any observation difference rejects that proposed proof.
Passing finite controls supports the design; it does not replace its proof.

Keep admission fresh on **every entry**. Do not cache permission across public
calls, assume host objects remain unchanged, or hoist checks across a possible
callback. Establish trusted reflection before inspecting mutable dependencies;
self-restoring hooks must not leave an accepted stale proof. Preserve the
existing public fallback and demand/error behavior.

## 2. Measure cheaper checks without deleting their coverage

Inspect sampled allocation attribution before rewriting the guard itself.
The baseline profile attributes 61.68% of sampled bytes exclusively to
`getOwnPropertyDescriptor`; changing a few temporary arrays alone cannot be
assumed to remove that cost. A cheap saved-output experiment can compare a
semantically reviewed implementation of the same ordered checks, or remove a
provably redundant inspection within one entry after a fresh host fence.
Never replace a descriptor check with a getter-triggering property read merely
because the clean-host benchmark becomes faster. Stop if the clean improvement
is immaterial or exact hostile-host observations differ.

## 3. Revisit transport after entry cost is accounted for

The guard-bypassed candidate still takes about 3.9% longer than the bypassed
baseline despite lower sampled allocation. Test a bounded saved-output variant
that expresses the step's branch results as caller-local scalar assignments and
a local control-flow join, preserving persistent list construction and evaluation
order. Unlike shared lexical result channels, these locals may become ordinary
SSA values. V8 already inlines the step helper here, so ordinary call inlining
alone is not the missing mechanism.

Require the new graph to lose the context-slot/barrier transport and compare
fresh clean timings before designing a general result-convention pass. Keep
recursive/reentrant behavior, escaping products and unknown callers outside
that first experiment. If costs do not fall, retain the simpler original tuple
convention. None of these RLE observations predicts the whole 45-point corpus.
