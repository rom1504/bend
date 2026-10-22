# Phase125 producer/concat source ceiling

Prepared at HEAD`06dea60`, with no compiler, generated-target or machine-build
execution. `manifest01.json` pins the source, original catalog, exact unified diff,
generator and independent expectations. This is a diagnostic source change, not
an automatic optimization or a frozen-benchmark improvement claim.

`rle-spine01.bend` changes only the expansion composition and adds one preceding
helper. The original Phase93 timed wrapper, result oracle11, runtime arguments,
repetition count, warmups and input stay unchanged. The frozen source is not
modified. RLE encoding/state, its nested products and its digest are unchanged;
this does not repeat Phase123's state-lane experiments.

```bend
# Original:
lconcat(lrepeat(U32.to_nat(n), v), expand(t))
# Ceiling:
p125.repeat_into(U32.to_nat(n), v, expand(t))
```

The new helper starts from the final suffix and tail-recursively prepends `n`
copies of the same U32 value. Reversing the order of equal copies has no observable
list-order effect. It constructs only the final output spine.

For run counts n1…nk, let S=sum(ni). At source constructor level, original expansion
constructs S temporary Cons cells in repeat and S replacement cells in concat;
concat additionally consumes/traverses S cells. The ceiling constructs S cells,
with no repeat-spine concat traversal. For the fixed input, counts3,1,2 give
S=6:12→6 Cons constructions and6 fewer concat Cons visits per `main.out`.
Encoded-pair/list traversal, state allocation, result consumption and the number
of output values are unchanged. These are **source-operation counts**, not malloc
counts, a50% whole-program allocation reduction, or a speed prediction.

Phase124 already removed the scheduler edges around the two helpers. Its preserved
`ready-call/evidence/rle01/README.md` identifies their remaining TRMC loops:
repeat extends a temporary spine; concat takes that spine and extends another.
Thus the ceiling tests a remaining representation cost, not another transport
rewrite. Inspect the candidate's actual selected helper and construction loops
before attributing any runtime change to this mechanism.

## Evaluation order and generalization limits

The original strict expression constructs the repeated list before recursively
expanding the tail, then concatenates. The ceiling evaluates count/value and
expands the tail before filling its repeated prefix. All relevant operations in
this finite benchmark are pure and terminating, and the copied value is U32.
The complete list is unchanged; allocation order, peak liveness and native helper
selection can change. No claim is made about resource-exhaustion behavior.

This source identity is **not** an unrestricted rewrite across effects, divergence,
foreign calls or errors. A general automatic transformation must either prove
that evaluation can commute or preserve original producer-before-tail order using
an authenticated pending destination/continuation. An incomplete destination must
not escape or become observable. Preserve single ownership of the final suffix,
the original payload sharing, exact constructor/field order and explicit-stack
safety. Reusing an already escaping/shared intermediate is outside this proof.

## Independent transfer witness

`producer-concat-control01.bend` decorates varying heap-owned String values and
then concatenates an existing suffix. Its second implementation decorates directly
onto that suffix. Four cases cover empty containers, empty strings, noncommuting
ordered values, duplicates, overlapping equal payloads and retained external
aliases. Both complete results, the original input and the original suffix are
printed, yielding16 expected lines. This is a different producer from scalar
repeat; it exercises payload lifetime as well as spine order.

The host oracle constructs expected strings by an independent list comprehension
and concatenation; it does not evaluate Bend or use either candidate as oracle.
Decoration's string allocations are unchanged: only the intermediate outer list
spine is absent. Source checking and target results remain pending.

For the existing parent emission harness, set `P118_CASE_MANIFEST` to
`selfhost/tools/performance/phase125/ceilings/cases.json`, selecting
`test-rle-roundtrip-p125-spine` and/or `p125-producer-concat-control01`.
`rle-cases.json` and `controls.json` separate the two if needed. Reproduce the
pinned variants/oracles with `python3 .../ceilings/prepare.py`; it refuses changed
existing output and never executes a compiler. Keep this source ceiling separate
from the eventual original-source automatic-pass measurement.

## Compiler-source transfer to investigate, not an established hotspot

`selfhost/src/back/native/text.bend:46` defines generic `nt_append` as
`nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)`. It visibly constructs an intermediate
reversed spine before reconstructing the forward output. A one-pass append/TRMC
worker could remove that intermediate, but the tail-accumulator reverse structure
is a distinct recognition problem from ordinary constructor-tail map/repeat.

`selfhost/src/back/native/direct.bend:151` appends the freshly reversed accumulated
arguments to entry arguments. Here `append(reverse(acc,[]),tail)` can become
`reverse(acc,tail)` under the same exact ownership/type/evaluation obligations.
These are concrete compiler source patterns, not measured inclusive hotspots.
Do not infer compiler-throughput gains from their existence or run a full image
build before a bounded admission/count experiment establishes useful transfer.
