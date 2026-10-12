# Typed10 residual representation facts

P69-010 is a source-only causal preparation. No result is implied by these
edits. All three C arms are under `selfhost/build/phase69/result-facts-prep01/`;
`plan.json` pins the successful checked emission, recipe and every changed
span, and reverse replay recovers typed10 exactly.

Root subsequently completed the discriminator; see
[the recorded outcome](../../../../../experiments/phase69/P69-010-native-result-layout-facts-result.md).
Twenty-five qualified correct timings and nine correct controls give medians
448ms typed10, 446ms scalar results and 444ms packed inputs, versus 246ms
upstream. The 0.45%/0.89% differences do not justify implementation. Both
mechanisms are deferred; no production patch was prepared or applied.

## What differs from upstream

The pinned upstream lexer `spin_13` takes five `u32` values: Mode discriminator,
Mode payload, character class, character and accumulator. It returns three
words, then its callers cast scalar result reads to `u32`. The self-hosted
typed10 `$product.step.at` takes two full `Term` values for Mode/class and two
`NF_SCALAR` arguments for character/accumulator. It returns two full words
for packed Mode and accumulator. This is already allocation-free for Mode
under checked packing, but C cannot assume that representation at entry.

At typed10's private `lex` loop, a pair constructor is still unpacked and
rebuilt every character. That is a known, distinct P69-004 result. Expanding
the public state parameter fails the existing demand proof because malformed
String tags can drop the unopened state; the proof currently recognizes only
runtime-unconditional scalar guards and exact Nat/Bool complements. A private
loop entered after an actual constructor is safe, but needs more compiler
machinery. Do not turn source annotations into unconditional raw exhaustivity.

Two smaller missing facts are isolated here:

| Arm | Exact change | Potential eliminated work |
| --- | --- | --- |
| `typed10` | Byte-identical explicit baseline | Attribution reference |
| `scalar_results` | 33 post-success output-slot casts to u32 | Scalar seals and generic range/packing branches surviving opaque result transport |
| `packed_inputs` | Five private worker entries assert canonical PAK/no-RFC on seven Mode/Cls slots | Heap/RFC field extraction, generic ownership paths and error-path drops |

The old compiler23 role is not the baseline for these two increments. The
method may include it and upstream as control roles, but typed10 must be an
explicit source arm in every attribution comparison. Keep arms separate to
avoid attributing packed-input effects to scalar result narrowing.

## Correctness argument and exclusions

The scalar arm is justified by pinned checked function result types. Functions
`prng`, `seed`, `salt`, `mix`, `fnv`, `flush`, `lex`, `line`, `batch`, and expected
checksums return U32; `op.pick` returns Char; the second result of the product
step workers is U32. Casts occur only after successful calls, preserving failure
polling and out-array ABI. No constructor term or Nat is truncated. No local
arithmetic expression is narrowed before a widening operation.

For the finite packed arm, Cls constructors are nullary, and Mode constructors
are nullary or have exactly one U32 field. In this actual checked emission,
`NATIVE_TYPED_SCALARS` and `NATIVE_PACK_CTORS` are both one. Runtime creation
uses PAK for every U32 payload; the constant Gap is nullary. PAKs are trivial
and never acquire RFC wrappers. The assumption preserves every source term bit
and asserts both tag and absent RFC flag; masking only `term_tag` would not
establish the latter. No polling, call graph, scheduler behavior or recursion
is changed.

This is not a general permission to insert C undefined behavior based on a
source type name. A production fact must describe actual emitted layout:

- Base Bool uses 0/1, not the tagged enum representation.
- User enums need their high tag/constructor bits and cannot use `NF_SCALAR`.
- Checked scalar permission alone is insufficient: an unreachable user foreign
  declaration can still disable all constructor packing.
- Foreign values, raw input, dependent or malformed telescope alignment and
  user-enum payloads must refuse the fact.
- Static-image representation must agree for every admitted field kind. The
  current static packer admits an immediate `NWord`; extending the dynamic
  proof to F32/Bool/Char without checking their static lowering is unsound.

The smallest conservative general packed rule is non-Base ADTs with all actual
constructors nullary or one *trusted U32* field, actual constructor identities,
exact erased arities and both existing permission gates. It would need a new
nonheap word kind (kept as C Term), a bounded layout query and entry-fact emitter,
roughly 40–70 lines plus controls. This is only a scope estimate. Scalar result
facts need metadata on both ordinary and product result layouts; retaining them
without changing the public ABI is preferable to redesigning return structs.
No production patch should be started before the saved-C timing shows useful
gain relative to this added proof/metadata complexity.

The completed timing did not meet that condition. Preserve this design as a
negative result and keep the final typed10 source unchanged.

Independent reviewer identified the dead-foreign packing counterexample before
any target execution. Successful probes still require broader raw/foreign,
static scalar, enum-tag and widening controls before integration.
