# Application-spine annotation validation

The candidate produces exactly the frozen B1 annotations for **34 checked core
cases and five checked source fixtures**. The five source fixtures also emit
identical JavaScript, and their generated libraries execute the expected result.
[Full evidence](evidence/annotation-spine.json) records API, source, worker and
output hashes. No Bend source was changed during this review.

The suspected reference-unfolding regression is not present. `core_beta` has no
book argument: it recursively reduces applications only when the resulting
function is a syntactic `Lam`. It does not unfold `Ref`, or follow a `Var` cell's
payload. A direct witness confirms that an alias application's reference survives
`core_beta` while the separate `wnf` operation unfolds that same reference.
The comment in `annotate.bend` describes this restricted beta operation, not
arbitrary normalization of global definitions.

The fast path infers the Ref/Var head's type once, normalizes each successive
function type, annotates its argument, and substitutes that original argument
into the remaining telescope. This preserves the old nested `Ann` structure.
An `Ann` encountered in a function prefix is deliberately ineligible and follows
the old path; explicit lambdas first go through the existing `core_beta` step.
The tests cover aliases in function types, dependent erased type parameters,
partial application, variable function heads, annotated function prefixes,
beta reduction exposing a reference, lambda-valued arguments, Var payloads, and
arities 1–20 with erased, affine and unrestricted binders.

Separate instrumented copies count operations; timing uses unchanged,
uninstrumented compiler workers. Each synthetic book and application is checked
before annotation. Two untimed warmups precede three alternating samples on CPU2.
All timed/instrumented annotations match exactly.

| Arguments | Old `ka_type` calls | New calls | Old median | New median |
| --- | ---: | ---: | ---: | ---: |
| 8 | 36 | 1 | 3.019 ms | 0.692 ms |
| 16 | 136 | 1 | 6.468 ms | 1.276 ms |
| 32 | 528 | 1 | 46.045 ms | 4.202 ms |
| 64 | 2,080 | 1 | 279.452 ms | 7.597 ms |
| 128 | 8,256 | 1 | 2,256.099 ms | 24.421 ms |

At 128 arguments, `core_beta` calls fall from 366,273 to 258 and recursive
`subst` calls from 1,389,888 to 16,383. This removes repeated prefix inference;
it does **not** make all annotation work linear. Substituting through the
remaining telescope still produces quadratic work in this synthetic family.
These are annotation-only scaling measurements, not a whole-compiler speedup.

Reproduce from the repository's `selfhost` directory with a checked candidate API:

```sh
taskset -c 2 node --stack-size=4096 \
  tools/performance/rapid/annotation-spine.test.mjs \
  build/phase3/baseline/api/b1.mjs CANDIDATE_API.mjs \
  build/phase3/annotation-review/NEW_RUN --measure
```

The runner appends test exports to copies of existing workers. It preserves all
original worker bodies; counter copies are separate from the timed copies.
The baseline layout must retain `baseline/src/runtime.mjs` for generated-code
execution. First exploratory attempts caught an incorrect harness expectation
that `driver_todos` returned an empty string; its successful result is numeric
zero. That harness correction required no compiler change.
