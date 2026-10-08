# Bind allocating native values without transporting them through a continuation

Status: unexecuted source proposal, separate from the matcher-arity experiment
and ordinary-C-worker work. Candidate:
`selfhost/tools/performance/phase68/value-prefix/prefix-v1.patch`.
It changes three native modules by +64 physical lines, preserves the boxed ABI,
and introduces no new representation: `N_Emitted{code, word, fresh}` already
exists. Production changes and target execution remain root-owned.

## Mechanism

An allocating expression currently returns `NC_Code`, including `ne_ret` text,
even when its caller merely binds the result and continues. The caller saves
live words in a continuation, evaluates that code, returns one boxed word,
restores the saved words, and proceeds. `N_Emitted` already distinguishes the
operation prefix from its result; preserve that distinction until choosing the
consumer.

Extract the existing constructor and array implementations into
`nc_constructor_value`, `nc_array_value` and `nc_intrinsic_value`, each returning
`N_Emitted`. Existing return-position entrypoints remain tiny wrappers through
unchanged `nc_ctor_result`. Both consumers therefore share the same operation
implementation. No pattern replacement or parsing of generated C is involved.

The new local consumer emits this shape:

```c
/* existing sharing prelude */
Term v_id;
{
  /* exactly one operation prefix; private init/at/old/node locals */
  v_id = result_word;
}
if (!seq && err_seen(e.mem)) { return 0; }
/* existing lowered body, including drops for unused values */
```

An explicit scope is required: existing Array.new/get/swap producers reuse the
scratch names `init`, `at` and `old`. The result escapes the scope, scratch
variables do not. Heap tuples and constructors retain their old word layout and
field sealing. Fresh names start at the producer's returned `fresh` counter
before lowering the continuation body.

Reuse `nd_bind_scalar`'s argument-ordering algorithm as the generic
`nd_bind_value(tag, name, ...)`; retain the scalar wrapper. This normalizes
constructor fields and approved allocating primitive arguments left to right,
then binds their already evaluated result. Admission for source calls requires
an exact Base intrinsic identity, exact saturation, and a non-bang reference.
The first set is constructors, Array operations and Nat.divmod. Strings,
foreign calls, unknown/partial calls, and scheduler dispatch keep their existing
boundaries. Raw normalized `NCtr`/`NOp` nodes need bound variable operands;
malformed operands fall back to the old path.

## Obligations and limits

- Preserve each argument's evaluation order, even if its result is unused.
  Sequencing is shared with the existing scalar transformation rather than
  reimplemented independently for arrays.
- Preserve `nc_share_env` before consuming each staged value, and retain the
  existing body lowering so affine values and discarded results are dropped.
  Flattening the staged argument spine needs independent ownership review;
  internal keep/allocation scheduling is not a proof of identical OOM timing.
- Preserve each producer's field-store order and `rfc_seal`/`blk_keep`/swap/drop
  actions. Capture the result once before any later mutation can occur.
- Keep the nonsequential error observation after the produced value. On the CPU
  existing error posting fail-stops; the checkpoint also protects retained
  device/shared-error behavior. CPU mock checks are not GPU validation.
- Do not change public constructors, callback ABI, dynamic apply or effect
  dispatch. This removes frame transport, **not aggregate allocation**. The hot
  Array tuple allocations still require scalar replacement/flat return work.

The Phase67 immediate-let theorem is not a proof of this extension: allocation,
ownership and runtime effects lie outside its model. No new proof claim is
made. A future formal local rule needs an explicit heap/ownership transition
and the same observable trace on both sides before contracting transport.

## Smallest useful check and stopping rule

First build one checked B1 from the frozen candidate. Run the existing
`flat-fast` controls plus the small `prefix-scratch.bend` source beside this
candidate (hand golden 7071122), the ownership set, zero-divmod and Nat overflow.
Inspect generated C for separately scoped repeated scratch locals and reduced
continuation cuts. Preserve the native-only JS byte-identity check.

Then reuse the current native short loop for array, tree/closures and lexer;
compare to the immediately preceding matcher-arity compiler with the same
source, Clang and CPU settings. Count segment entries separately from clean
runtime. Confirm heap allocation/free balance and keep/drop observations; do
not label fewer static `WL_CASE`s a measured speedup.

The mechanical benefit is one removed continuation/return per eligible binding,
plus omitted builtin entry when an exact allocating primitive call is exposed.
A provisional 10–35% runtime reduction on transport-heavy cases and 0–15% lower
Clang time are hypotheses, not measured expectations for every program. Pure
numeric code already admitted by Phase67 may barely change. Allow one checked
build and focused screen, about 20–40 minutes including qualification; retain
the representation refactor only if it yields a useful measured result or is
needed by the independently qualified ordinary-C-worker consumer. Do not spend
another broad benchmark campaign rescuing a null result.

The ordinary-C-worker owner can consume the same `N_Emitted` producers using an
explicit destination, avoiding duplicate constructor/array implementations.
