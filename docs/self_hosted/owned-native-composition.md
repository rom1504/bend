# Owned native composition

Phase125 adds three small capabilities to the experimental direct-QBE compiler.
They compose with the Phase124 complete-helper/local-resume path. The compiler
decisions are implemented in checked Bend; the native runtime operations are C
functions linked from a cached object. Python and JavaScript transport artifacts,
invoke compilers, and measure results. They do not implement these optimizations.

Read the [design](../../design/phase125/owned-composition.md),
[results](../../implementation/phase125/README.md), and
[reproduction instructions](../../selfhost/tools/performance/phase125/README.md).
Qualification and installed selection are separate decisions; consult the results
for their exact status.

## Reuse an owned list prefix

The checked source recognizer proves the structural append equations for a closed
two-constructor type: empty has no fields; nonempty has an opaque head and a tail
of the same type. Both operands and result have that type. Names are irrelevant.
Admission is bounded and requires the existing private forwarding worker.

The new worker first calls a typed runtime operation. It scans the left spine
without changing it. Every cell must be dynamically allocated and exclusively
owned. An RFC wrapper must have an acquired count of exactly one, and its resolved
payload must also be dynamic: a dynamic wrapper can still point at static data.
If any check fails, neither argument has been consumed or mutated; the original
worker executes. If the whole scan succeeds, the runtime attaches the already
evaluated right operand at the final tail slot and returns the original left
owner. Empty returns right. It uses the original publication/sealing rule.

This removes reconstruction, consuming takes, and corresponding allocation on
success. It preserves head values, wrappers, source evaluation order, and bounded
native stack use. Retained aliases and sharing retain the original behavior.
The helper is qualified only for the existing sequential runtime contract;
there is no new concurrent ownership or GPU claim.

The interface returns the owning result directly. Zero indicates refusal because
the exact admitted constructor representation cannot use zero as a valid result.
The source proof is essential: this is not a general-purpose unchecked list API.

This capability does **not** fuse an arbitrary producer with its consumer. A
repeat producer still constructs its first list and performs its existing
destination work. That distinction explains why eliminating the same number of
cells can yield less benefit than a source-level repeat-into-tail ceiling.

## Preserve primitive identities

Two exact singleton-argument intrinsics, `u32_to_nat` and `f32_bits`, already use
the required value representation in this backend. Their lowering snapshots the
evaluated operand with an ordinary typed IR assignment instead of allocating a
scratch result slot and calling a conversion helper. Other intrinsics and shapes
retain their previous lowering. This is representation preservation, not a change
to arithmetic, precision, or evaluation order.

## Consume verified constructor facts

The structured IR continues to contain the original constructor/take operations.
The unchanged verifier checks their operands, metadata and buffer capacities.
Only after successful verification does emission select a small sized ABI for
arities one through four.

For construction, the verifier establishes the constructor ID and arity, constant
field count, and valid field buffer. The sized runtime operation can omit repeated
metadata/buffer checks and the redundant count argument. Allocation, fields,
ownership and publication remain unchanged.

For destruction, that verifier does **not** establish the actual input value's
constructor. The sized take operation retains the dynamic tag/constructor/arity
checks, RFC behavior, static-value handling, and reclamation. Only proved count
and buffer checks disappear. A future matched-constructor witness could justify
more, but the current interface does not carry that proof.

## Facts worth retaining across backend work

These changes identify three useful boundaries without introducing another IR:

- A source equation certificate admits a guarded ownership transformation.
- A typed value preserves a representation identity across lowering.
- A verified call contract permits a cheaper runtime ABI during emission.

Legality belongs to those facts, while QBE instruction selection and runtime
profitability remain separate. The next composition experiment should preserve a
private destination across a whole producer/consumer computation. It must show
that work disappears on unrelated programs before the interface is generalized.
