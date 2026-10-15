# Environment fusion connected to a compiler candidate

The [safe helper](candidate01/helper.bend) implements one-pass ordered environment
extension. The [reference](candidate01/reference.bend) deliberately filters,
appends a new binding and partitions separately. The [proof](candidate01/proof.bend)
states and proves that their complete results are equal, including the ordered
live list and arbitrary drop accumulator.

All three files were frozen after the first successful source check and before
compiler performance measurements. Their exact hashes are in the Phase94 evidence.
The reference and laws were agent-authored; their adequacy is reviewed and tested
with deliberately wrong implementations, not claimed as a human specification.

The upstream checker and the unmodified BendTT kernel both accept the theorem.
The independent kernel is built using the official Lean 4.34.0 release. Its
positive/false-equality controls pass. The new elaboration contains all 36
definitions, including all helper/reference functions and six theorem bodies;
there are no omitted or unsafe proof dependencies. Seven opaque template
constants represent arbitrary parameters, with no algebraic assumptions about
membership or drop accumulation. They are not executable assumptions introduced
to make a particular compiler output pass.

## What the theorem says

For any finite ordered input list, any typed pure total membership predicate,
any reusable predicate state, any drop operation and any initial accumulator:

1. Filtering the prefix, appending a suffix and then partitioning is equal to
   partitioning that suffix once and extending its result with the live prefix.
2. For a singleton suffix, the new binding is retained or dropped exactly once.

Duplicate identities, an empty list, both Boolean outcomes, and arbitrary row
contents are included. There is no sortedness, uniqueness or commutativity
assumption. The optimized helper performs one membership call per input row
plus one for the new binding. The reference repeats membership for retained
prefix rows and builds intermediate lists.

## Production connection and its boundary

The [integration recipe](../../tools/performance/phase94/integration01/prepare.py)
embeds these exact helper bytes into an isolated copy of the actual native
compiler source. Only its leading `import Base` is removed by assembly. Both
`nc_let_atom` and `nc_let_emitted` call it through the concrete
`nc_env_extend` adapter. This is an actual compiler candidate, not a separate
illustrative implementation.

The generic theorem does **not** prove the unsafe adapters, NU_Set liveness
analysis, correspondence of the old unsafe routines to the reference,
reference-counting semantics, emitter, generated C, scheduler or runtime.
Production callbacks are reviewed as deterministic terminating operations on
valid compiler values; that premise is not mechanically proved here. Exact
generated products and independent edge controls test these additional
boundaries. Their results and the promotion decision belong in the
[phase report](../../../implementation/phase94/README.md).

## Fast verification

With the prepared toolchain and kernel module:

```sh
python3 -B selfhost/tools/performance/phase94/proof-check.py \
  --out selfhost/build/phase94/proof-NEW
python3 -B selfhost/tools/performance/phase94/mutations.py \
  selfhost/build/phase94/mutations-NEW
```

The first command binds the exact source, elaboration, imported kernel module,
and matching toolchain files. It checks source, elaborates all definitions,
requires independent acceptance and requires independent false-equality
rejection. The second command checks that the frozen law rejects reordered
retained rows, missing drops and incorrectly retained dead rows. It records
frontend rejections separately from kernel checks.

The reusable kernel module takes about 53 seconds to build once; each kernel
verdict took about 0.3 seconds in the initial run. Source checking, elaboration
and file authentication are additional work. This is not a whole-compiler proof
or a promise of constant proof-check time for larger developments.

The [tool guide](../../tools/performance/phase94/README.md) explains restoration,
the full toolchain audit and fast replay's narrower file reauthentication. The
isolated candidate is **not promoted**: its helper saves 18–39% time, but the
compiler-wide screen is effectively unchanged. All 45 compared C products and
six production-adapter controls pass.

`attempts/01` preserves the first failed proof structure. Its reference and
optimized helper were unchanged when explicit constructor-case lemmas repaired
the proof. Historical Phase67 failures also remain preserved.
