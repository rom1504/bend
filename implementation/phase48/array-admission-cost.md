# Lazy Array admission: a new candidate bug caught before promotion

The combined RNFA02 compiler exhausted its 1 GiB Node heap while compiling the
first actual corpus source, `local-row.bend`. The root retained the failure.
RNFA03, differing by the isolated Array-effect admission overlay, compiles that
same input under the same limits in 6.126 seconds at 553,205,760 bytes peak RSS.
RNFA02 failed after 35.784 seconds at 1,190,522,880 bytes peak RSS. Failure time
is not a valid throughput baseline; the useful result is restored completion
within the unchanged resource budget.

This is a regression introduced by the Phase48 typed-array candidate. It is
separate from the historical U32 allocation-hook correctness bug and must not
be credited as an improvement over the installed compiler.

## Concrete cause and correction

Bend `Bool.and` evaluates both operands. The new `j_array_effect_native` joined
cheap Call/name/arity tests to `j_array_effect_definition` with `&&`. Its emitted
checked API therefore invoked the definition proof unconditionally. That proof
immediately normalized the first call argument as an erased element type—even
for an ordinary helper whose first argument is a live computation. A call such
as `dist(dp(...))` can make compilation reduce program work instead of simply
rejecting native Array admission. The previous local-native predicate used `kc`
to delay that proof until the cheap shape tests passed.

The isolated `array-effects-lazy-v1.bend` overlay restores explicit lazy gates:

- Call kind, known Array operation and exact arity precede definition checking.
- A native definition and erased All header precede element normalization;
  a same-named user helper must not expose its live argument to that operation.
- Canonical Array ADT shape/owner precedes child normalization. `array_of` checks
  element equality only after Array admission.

Every native owner/type/arity/result condition remains; no runtime guard or
permission is removed. Two small helpers stage the header and element checks.
The overlay adds 630 bytes. Parent source SHA is
`bbae40d6a1929b83189d5ad8942a66857a967a305aa1f5d87bcbfe16e6d3b04d`;
overlay SHA is `e74844cc241cc3185363ccea6c477a3fcd6c58012a59244aaad805c6c1b41abd`.
The exact full file, patch and derivation receipt are preserved under
`selfhost/tools/performance/phase48/proposals/array-effects-lazy-v1.*`.

The initial 20-second stage trace had no typed-driver records, so static
inspection alone did not establish where that run spent its budget. The later
same-input, same-limit, one-file RNFA03 success provides much stronger causal
evidence. It still does not establish that every compile-cost issue has this
cause or justify loosening resource bounds.

## Bounded regression control

`array-native-rejection-controls-v1.mjs` takes historical-eager and corrected
checked attempt directories. Its saved-API derivative wraps `wnf` with a sentinel
for one exact live AST object. The six negative probes cover an ordinary scalar
call, a same-named nonnative Array call, wrong arity, a native live telescope and
unrelated type/array-of children. The historical predicate must reach the
sentinel once; the corrected predicate must return false without reaching it.
This prevents the test itself from reducing an expensive recursive payload.
Two structural U32/F32 Array/new positives prevent a blanket-rejection fix.

The v1 controller failed to parse because a comment contained unescaped backticks
inside a template string; no predicate execution occurred. The preserved v2
successor fixes only that comment and its version label. It passed on RNFA03 and
was freshly renewed on selected RNFA04 in
`final-qualification04/native-rejection/report.json`. All six negative paths
reach normalization once in the eager image and zero times in the corrected
image, while both positive facts still pass. The selected semantic receipt
binds that actual execution to the final API and runtime.

The companion source is a renamed ordinary scalar consumer of
`fern.dp(12n,seed)`. Its optional checked acquisition point is `bench(3)==36865`,
from the independent binary-recursion sum. The internal predicate tests use the
corresponding AST shape and minimal native-header facts; they are not presented
as a replacement for the complete Base/host correctness suites. The optional
companion source acquisition was not run. Root owns all target execution.

The preserved process receipts are under `selfhost/build/phase48/`:
`combined-rnfa02-full/emit-00/process.json` and
`combined-rnfa03-full/emit-00/process.json`. The latter acquisition's checked
source/compiler/output join is `combined-rnfa03-full/modules/local-row.mjs.json`.
No historical attempt or failed controller was rewritten.
