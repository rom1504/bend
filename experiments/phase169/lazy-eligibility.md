# Lazy borrowed-scalar eligibility: independent ablation

The maintained `p128bs_eligible` constructs parameter bindings and evaluates
every Boolean conjunct, including `nc_error(no_emit(...))`, before returning
false. That emitter recursively validates the residual and constructs C text;
the predicate then discards everything except its error string. An error plan,
an unsuitable wrapper or an invalid root count does not need that work.

`selfhost/tests/phase169/lazy-eligibility.bend` changes only this predicate and
adds four private stages. The stages require, in order:

1. Empty original plan error.
2. The same `Var` wrapper, result identity and observation name.
3. The same inclusive root-count range, computed once.
4. The same `nol_scalar` classification against the original immutable book.
5. Absence of the same generated reader and owned-worker names, in that order.
6. Empty error from the exact original emitter call, parameters and layouts.

All original acceptance conditions remain. Root counting moves before scalar
classification; neither modifies the book, plan or compiler state. The emitter
produces an `NC_Code` value containing text, calls, fresh counter and error; it
does not execute its generated text or perform IO. Early rejection changes
allocation and evaluation order, not an externally reported diagnostic: this
helper returns only `Bool`. Subsequent fallback selection, worker construction,
consumer lookup and independent verification are unchanged.

This is a source equivalence argument for the terminating immutable input domain
used by these compiler helpers, not a new universal BendTT proof. It does not
assert that skipping an unsafe divergent computation preserves divergence on
arbitrary forged values. The root must still check actual source admission,
complete generated products and native execution. Different sharing and release
order may also affect performance; their cost belongs in the measurement.

## Frozen controls and preparation

`lazy-eligibility-controls.bend` retains an exact renamed copy of the maintained
predicate. The preparer compares its full definition body against
`selfhost/src/back/qbe/borrowed-regions.bend`, allowing only the declaration name
change and exterior whitespace, and refuses drift. Sixteen cases compare both
implementations to explicit expected Booleans. They cover one/two/duplicate roots,
the error, wrapper, result, observation, count, scalar and name-collision gates,
plus invalid emitted residuals. Duplicate roots deliberately preserve the old
predicate's count-only behavior; this experiment adds no new admission rule.

The independent preparation method supports separate `--lazy`, `--admission`
and `--publication` flags. Earlier cache source/API02 and consumed methods remain
unchanged. Data-only preparation performed here:

```sh
taskset -c 0 python3 -B experiments/phase169/tools/prepare-native-variants.py \
  --api --lazy --out selfhost/build/phase169/lazy-api-source01
```

The frozen compiler is 1,618,381 bytes with 4,754 declarations, SHA256
`749b758ba18e8bac222c691890d2323f0744ea99138cf16b8bd4666b049f9c4c`.
Its manifest/inputs authenticate the old predicate and source preparation;
`p169e_controls` is the new control export. No compiler or native target was run
by this lane. Source/type checking and all sixteen observed outcomes are pending.

## Expected leverage and falsifier

This changes five small definitions without a cached plan product or extra scan.
It can save one emitter reconstruction for every rejected predicate invocation,
including calls that the independent eligibility cache does not remove. It can
also save parameter/layout lists, scalar classification and name lookups according
to the first refusal. Successful candidates still pay the exact emission check.

Actual full-compiler plan counts, first-refusal frequencies and exclusive elapsed
time are **unmeasured**: the retained Phase169 JSON receipts available at
preparation time do not contain a serialized observer-plan catalogue. Segment
counts from the unrelated import-metadata audit are not a proxy. No numerical
whole-request gain or profile ceiling is claimed for this ablation.

The cheap falsifier is the existing hosted exact-product screen with only
`--lazy`, following source admission and the sixteen controls. Compare it with
the unchanged baseline and cache-only API; include real accepted scalar workers,
not only rejected plans. If whole-request cost is neutral, avoid adding the
stages merely because a synthetic refused-plan loop improves. A favorable hosted
screen still requires native transfer before promotion.
