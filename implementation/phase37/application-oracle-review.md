# Phase37 application oracle review

This review is source inspection only. It does not report execution, timings or
holdout performance. Root owns the separate checked acquisition and untimed
correctness run. The reviewed inputs are the eight fixtures and `oracles.py`
under `selfhost/tools/performance/phase37/fixtures-new/`, the pinned `Base` source
at `018751270e800bc222a93dad7f257083ee53a5f7`, and the prepared-input worker.

No semantic discrepancy in the expected values was identified by inspection.
That conclusion is narrower than passing both compilers against the oracles.

## References

- **F32 recurrence.** The source computes `round32(round32(3.75*x) *
  round32(1-x))`. The Python oracle applies binary32 conversion at those same
  primitive boundaries, including the initial division and the multiplication
  before conversion to U32. Chosen values are positive and bounded, so neither
  unsigned conversion overflow nor NaN semantics are being approximated.
  Products of two binary32 operands fit within binary64 precision before their
  binary32 rounding. The test is not a claim about all transcendental or
  exceptional floating-point operations.
- **Unicode text.** The copied splitter uses code-point `Char` values and
  preserves the final empty segment after a trailing comma. Joining its results
  with `|` is therefore equivalent to replacing every comma with `|`, including
  the final delimiter. The complete output includes the supplementary-plane
  apple character; no UTF-16 code-unit count is used as its oracle.
- **Map churn.** Initial keys are distinct. The replacement count is
  `ceil(size/3)` and the deletion count is `ceil(size/4)`, matching Python ranges
  beginning at zero with steps three and four. Every deletion addresses an
  existing key. The Base map's presence-bit and code-point encoding orders
  shorter prefixes before their extensions; `Map.to_list` yields the low
  subtree before the high subtree. Python lexical ordering is appropriate for
  these ASCII keys. Wrapping multiplication and XOR match the content digest.
- **Record aggregation.** Generation uses sixteen Unicode-prefixed keys and
  nonnegative decimal amounts below1000. Parsing the generated decimal fields
  has no whitespace, sign or failure ambiguity. The common Unicode prefix and
  ASCII decimal suffixes produce the same ordering in the Base map and Python.
  The oracle observes the entire rendered report, not only a checksum.
- **BST.** The wrapper supplies `size+1` descent fuel, so the original constant
  eight does not truncate the new skewed case. For the frozen inputs, generated
  values and wrapped operations match the independent sort-and-fold oracle.
- **Expression tree.** The oracle folds the generating algebra from its deepest
  seed back to the outermost node. Each Add/Mul/Sub operation wraps at32bits;
  it does not build or interpret a matching Python AST.
- **Closures.** Applying all closures adds each integer from one through the
  dynamic size exactly once. The triangular-sum oracle therefore matches the
  complete chain and seed, modulo2^32.
- **List pipeline.** Filtering words at most one, doubling the remaining words
  and summing them matches the Python reference modulo2^32.

## Coverage qualification

The list generator observes only the low four bits of its LCG. These repeat
with period16, and both timed sizes128 and512 are complete periods. Changing
the seed changes ordering, but neither the value distribution nor final scalar
sum at those lengths. This is useful traversal/branch coverage, not random-data
diversity. A future version can add lengths that are not multiples of16. The
current frozen points should not silently change after acquisition.

Map keys have a shared prefix and sequential decimal suffixes; Unicode blocks
repeat a fixed template; record keys cycle through sixteen departments. These
are explicit controlled workloads, not samples from production distributions.
Scalar digests can collide. The independent reference languages and algorithms
reduce shared implementation mistakes but do not prove whole-state equivalence.

## Untimed prepared-input worker

`check-prepared.mjs` predeclares154 observations:45 finalized catalog points and
32 small application controls, each run once by both compilers. It validates
source, catalog, preparation, checked-emission, compiler and module identities.
The generic-row observer is linked through its adapter receipt to the checked
raw emission. Initial identity failures mark pending observations `not-run`;
individual execution errors remain `fail` rows while later points continue.

The worker contains no timing or profiling calls. Root's external resource
supervisor bounds the job. Holdout observations establish correctness only. The
baseline API is deliberately pinned to Phase36; a future compiler comparison
requires an explicitly versioned successor worker rather than modifying this
consumed record's compiler identity check.

## Optimizer review boundary

The saved-output tree prototype replaces calls whose original `callOwned`
boundaries fully materialize constructor fields. Its scalar-owned benchmark
consumes the complete result. This supplies a plausible local demand/order
argument; arbitrary public Data arguments would not supply the same ownership
or materialization guarantee. The optimizer owner was asked to add public
deferred-field/getter controls and nested sharing diagnostics before promotion.
Source-structural compiler admission remains a separate requirement.
