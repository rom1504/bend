# Checked Bool array admission v2: source-only successor

P70-007 proposes adding trusted Base `Bool` to `ns_scalar`'s existing
`U32/F32/Char` allowlist. No runtime representation changes. No compiler source
was edited and no target was executed in preparing this directory.

The source audit supports the change **under the existing checked-entry
preconditions**. It is not a machine-checked proof of the compiler, nor a claim
about arbitrary callers of the exported raw API. The patch and controls still
require the baseline check gate, candidate emission and execution gates below.

## Source-gate correction

The preserved v1 baseline gate accepted five controls and rejected two during
parsing. This successor replaces invalid negative literal spellings with
`F32.neg(1.5)` and `F32.neg(0.0)`, and renames the user `Pair` type to `BitPair`
to avoid its Base name collision. Other Bend fixtures, the independent Python
oracle, C/JS foreign handlers, admission harness and compiler patch are byte
identical. The -1.5 IEEE binary32 oracle stays **3217031168**. No target was run
while preparing v2; it still needs its own source gate. `derivation.json` pins
the observed v1 failure receipt and all original/successor file identities.

## Invariant and admission boundary

For successfully checked, specialized, annotated and layout-validated source,
with the trusted Base/runtime and permitted foreign handlers, a runtime value
whose resolved type is the Base `Bool` has native bits exactly `0` or `1`.
The producer cases below establish the invariant; the transport cases preserve
it. Thus a packed array's 32-bit write followed by zero-extending read is exact,
and a Bool element carries no heap ownership requiring retain/release.

`ns_scalar` first resolves a finite syntax alias using `nq_layout_type`, then
requires an ADT with trusted Base provenance and the exact allowlisted name.
An alias to Base Bool may qualify; a user enum, unknown/open layout, exhausted
alias search or user-shadowed Bool does not. The checked runtime layout gate
also rejects reserved native ADT impersonation. `nc_ctor_identity` encodes
non-Base constructor identities before erasure, so a user's constructor name
cannot acquire Base True/False lowering by spelling alone.

The whole reachable-program certificate checks every ordinary definition.
Every Array constructor/pattern needs a resolved scalar element type; generic
new/get/set/swap/size/clone calls need a scalar type argument; unsaturated array
primitives and `Rwt` decline. Therefore this proposal does not narrow all arrays
merely because one Bool array exists. A live Array of a user enum, String,
nested Array or another opaque element keeps the whole program generic.

`nc_compile_checked` is an internal trusted entry with a caller-supplied
`effects_safe` permission, not an authentication boundary for hostile API users.
The maintained driver typechecks and validates layouts, pins Base's SHA and
requires exact audited `args.c`, `print.c`, `now.c` source hashes and paths before
granting permission. `ns_definitions` independently refuses ordinary user
foreign definitions. These permitted effects do not return arbitrary Bool
terms or expose mutable immutable-root identity. Raw `nc_compile` never grants
the certificate. Direct callers forging a checked book or permission violate
the precondition; this patch does not make such calls safe.

`native_bool` intentionally accepts both immediate `1` and tagged `CID_TRUE`
for the generic/raw ABI. That broader domain is not the claimed invariant.
Arbitrary foreign code stays generic even when a particular handler happens
to return canonical 0/1. Do not widen its whitelist as part of this change.

## Producer and transport audit

| Case | Evidence and invariant |
| --- | --- |
| Literal/dynamic constructors | `nc_constructor_value` in `bridge.bend` emits False as `0`, True as `1`; constructor identity is already resolved. |
| Static constructor graphs | `ns_static_scalar_fields` in `static.bend` turns exact nullary True/False into NWord 1/0. They are not boxed static nodes. Parent graph fields retain those words. |
| U32 comparisons | `ni_template` emits `U32_BIN` C comparisons for eq/ne/lt/le/gt/ge/is_zero; C comparison yields 0/1 and conversion preserves it. |
| F32 comparisons | All six comparison templates cast the C comparison to u64; even NaN comparisons produce C 0/1. |
| Nat comparisons | Native `nat_is_lt` is a C comparison. Other Bool predicates compose comparisons and ordinary Base Bool constructors/functions. Native `nat_cmp`/`u32_cmp` return Cmp, and `nc_intrinsic_value` wraps the Cmp constructor; checked types prevent using it as Bool. |
| Bool native operations | `bool_or`/`bool_xor` combine the C bool results of `native_bool`, so produce 0/1. There are no other Bool-producing native templates. `nc_native_def` requires trusted Base provenance. |
| Ordinary Base/user code | Bool.not/Cmp predicates construct canonical Bool; Bool.and/or/pick, user branches, identity and recursive calls return already typed inputs or values produced by these cases. There is no admitted numeric-to-Bool bit reinterpretation. |
| Structural U32/F32 word view | `native_word` stores each WCon head as `(x >> shift) & 1`; extracting the Bool field preserves 0/1. The word chain itself is not a scalar array element. |
| Constructor fields | `ne_stores`/`rfc_seal` preserve immediate values. `ctr_take` reads the same Term. A packed single-field user constructor extracts `term_loc`, preserving a Bool payload 0/1. The enclosing constructor value is not itself a Bool. |
| Ordinary/private workers | `nf_scalar_kind` already admits trusted Base Bool as N_W32. NF_SCALAR is u32 only under checked permission, otherwise Term. Conversion between u32 and Term preserves 0/1. Flattened product components remain full Terms; no new field narrowing is proposed. |
| Closures, scheduler, products | Captures, task/frame slots, argument/result buffers and product transport copy Terms. All closure/function inputs and returns remain checked Bool at their use sites. No arithmetic transformation is applied to a transported Bool. |
| Ownership | 0/1 are trivial terms: `rfc_seal`, `term_keep` and sinking do not turn them into RFCs or heap handles. Skipping element refcount work is valid for these immediate values. |

Source anchors: [scalar certificate](../../../../../src/back/native/scalar-array.bend),
[constructor/field lowering](../../../../../src/back/native/bridge.bend),
[intrinsics](../../../../../src/back/native/intrinsic.bend),
[constructor identities](../../../../../src/back/native/identity.bend),
[type aliases](../../../../../src/back/native/product-layout.bend),
[private worker ABI](../../../../../src/back/native/flat.bend),
[static graphs](../../../../../src/back/native/static.bend),
[term/closure emission](../../../../../src/back/native/emit.bend),
[word view and Bool helper](../../../../../src/back/native/book.bend),
[runtime](../../../../../src/runtime/native/runtime.c),
[checked host boundary](../../../../typed-driver.mjs).

## Array operation audit

| Operation | Packed Bool effect |
| --- | --- |
| Array.new / ALeaf | `blk_new` stores each canonical initial value with 32-bit `blk_write`; exactly 0/1 survives. |
| Array.get | `blk_read` zero-extends one packed u32 cell. The returned array handle retains existing sharing/redirection logic. Element retention is unnecessary for 0/1. |
| Array.set | The new typed Bool is 0/1. The old cell has no ownership to sink. Address lookup and array ownership remain unchanged. |
| Array.swap | The old u32 cell becomes Term 0/1, the replacement is written exactly, and the unchanged result shell still transports the array and old Bool. |
| Array.clone | `blk_copy` copies the appropriate packed word span into an independent buffer. It does not alias the original. Each 32-bit lane remains 0/1. |
| ANode / pattern / Array.size | `blk_node` packs adjacent 32-bit leaves or copies child word spans; `blk_half` extracts the corresponding half. `blk_leaf` reads the correct lane. Size depends on depth, not element representation. Checked Array typing keeps each node homogeneous. |
| Array.fork and mutable aliases | Scalar permission does not imply unshared permission. `ns_unshared_definitions` must still see duplicated Array handles and retain the sharing protocol. Fork aliases observe the same writes; clone buffers do not. |
| Mixed U32/F32/Char/Bool arrays | Each array remains homogeneous; the program-wide common 32-bit storage width preserves each type's already-audited bits. Atomic APIs remain typed U32/F32; no new Bool atomic or unchecked cast is introduced. |

The checked `packed` permission also gates Phase70 immutable-root observers.
Adding another immediate scalar element does not add root identity, mutation,
foreign access or borrowed-handle escape. Existing effect-source and observer
shape proofs remain required. The observer implementation still needs its own
control gate; this proposal is not evidence that it passed.

## Independent controls and oracle

`catalog.json` pins all fixture inputs and records literal expected stdout.
`selection.json` uses seven unique native case IDs and `#|` goldens. Source
patterns only destructure parameters or fields; no computed-call destructuring.

| Case | Independent expected values | Candidate scalar / unshared |
| --- | --- | --- |
| update | false→true returns old 0/new 1 => 1; true→false returns old 1/new 0 => 10 | 1 / unconstrained |
| clone | sum(original)×100 + old×10 + sum(copy): 1 and 413 | 1 / unconstrained |
| shared | old×100 + sum(left)×10 + sum(right): 11 and 133 | 1 / **0** |
| mixed | three true cells; max u32; IEEE binary32 -1.5 bits; Unicode U+1F642 => 3, 4294967295, 3217031168, 128578 | 1 / unconstrained |
| producers | literal truth table, ordered comparisons, NaN inequality, Bool operations, one/two-field constructors, finite type alias, bang/closure call and zero/all-one word bits; goldens listed in source | 1 / unconstrained |
| enum-refusal | Bool true 1 + user Signal.On score 10 => 11 | **0 / 0** |
| foreign-refusal | well-behaved foreign true initializes two true cells => 2; arbitrary handler still refuses permission | **0 / 0** |

`admission.mjs` emits these seven cases and checks actual flags, then sends the
same checked `mixed` source through raw `nc_compile` and an explicitly false
effect-permission checked wrapper. Both must have scalar/typed/unshared flags
zero. It saves emitted C and exact method/API/host/Base/runtime/source hashes
under one fresh Phase70 output. It does not compile or execute C. The baseline
mode expects all seven Bool-containing programs to be generic, while candidate
mode requires the listed admissions/refusals. Its flag reader takes the initial
permission before the runtime's guarded zero defaults, matching current output.

A source-only oracle is weaker than measured execution. First run the existing
cheap baseline source checker on `selection.json`; keep any failure rather than
editing a consumed version. Then build the one-line candidate through the
checked bootstrap. Use the maintained bounded native controls runner for both
roles, checking every output above, followed by admission emission. Reuse the
existing boxed-array, nested-array and atomic/race regressions to verify the
fallback and sharing paths when running the broader native gate.

For speed, require `NATIVE_SCALAR_ARRAYS=1` on the unchanged coverage Array-map
batch before timing. Acquire the candidate once, then compare saved binaries
using the frozen common-work plan, rotated roles and the 100ms sample floor.
Report incremental change from the observer-only candidate as well as Phase69;
do not conflate their effects. Recheck the original six families only after the
small loop has shown a repeatable gain with all correctness controls passing.

## Expected value and uncertainty

The earlier one-sample calibration was **861ms B1 / 250ms upstream = 3.44×**;
it was a calibration, not a qualified timing estimate. B1's generated C denied
all scalar flags because Bool was absent from this allowlist. Upstream used
packed arrays. Separate B1 per-element Tuple allocation/ownership traffic also
remains, so this patch cannot be assumed to close the whole gap.

Planning hypothesis: **1.2–2.0× faster Array-map**, conditionally moving 3.44×
to about 2.87–1.72× if the old baseline reproduces. This is unmeasured and is
not a bound or promise; zero gain is possible. No broad-suite gain estimate.
Implementation is one allowlist edit; validation is expected to cost much more
than the edit and should reuse the frozen fast loop. Stop if admission remains
generic or if the warmed native improvement does not reproduce.

See [registered hypothesis](../../../../../../experiments/phase70/P70-007-checked-bool-arrays.md),
[emitted-C comparison](../../../../../../implementation/phase70/native-array-map-opportunity.md)
and [baseline limitations](../../../../../../implementation/phase70/native-coverage-baseline.md).
