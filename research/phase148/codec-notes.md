# Phase148 private function codec

Final disposition: root-owned corrected hosted/native controls pass; complete
pipeline timings do not justify integration. The implementation-time notes below
are retained; the [final report](../../implementation/phase148/README.md) records
the actual gates, failures and results.

Source: [`core.bend`](../../selfhost/tests/phase148/core.bend).
Protocol: [`unit-interface.md`](../../design/phase148/unit-interface.md).
This note describes the implementation; root-owned source checking, differential
controls and native measurements are separate. No targets were run in this lane.

## Storage and lifetime

`p148_pack` counts one complete `P113DFunction`, allocates power-of-two arrays,
then writes the frozen eight-word instruction / three-word value protocol.
Runtime-call payloads use type/ref pairs; direct calls use destination IDs followed
by argument refs. Branch children are adjacent half-open spans. `next` skips the
complete instruction including its payload or both child spans. Scalar branches
contain only scalar statements; direct branches contain direct statements.

Each original operand occurrence receives its own three-word record. Values are
not interned. This allows the scalar consumer to append at most one replacement
per original occurrence without invalidating other operands. Reserved value
slots are `2*originalValueWords + 3*statementCount + 16`, rounded up by the array
allocator. `valueUsed` records only initialized value words. The consumer must
check its append bounds and advance `valueUsed`; it must not overwrite a shared
original value record.

The dictionary interns exact Strings through the existing collision-safe
`P147VTable`, not a hash-only identity or a repeated linear insertion scan.
IDs0/1 are always `state`/`scratch`. ID2 is always `xor`, needed by the scalar
provenance rewrite even when the original body contains no xor. Parameters are
interned before the body. Local names, symbols, runtime imports, binary operators,
function references and constructor references share spelling IDs; distinct value
tags and instruction fields retain their namespaces. An interned ID does not
establish a local declaration or definite assignment.

`Array<String>` is intentionally cold, ordinary dictionary storage. It can
prevent global scalar-array admission; this implementation makes no four-byte
packing claim. The scalar arrays remain contiguous even with eight-byte native
Term cells. The original parameter list and function metadata are retained
unchanged; statement/value/list objects are reconstructed only by final unpack.

Mutable builder arrays are threaded through one affine builder. Metadata queries
consume and reconstruct that builder: `p148c_position` returns its owner together
with the old position, and `p148c_header_here` reads the position while unpacking
the owner once. No `P148Tape`, `P148Build`, `P148Ref` or `P148Unit` is shared.
One header write updates all eight slots before reconstructing the builder,
rather than creating eight intermediate builder records. Index lookup is
immutable. The packed tape is frozen until its explicit scalar consumer takes
ownership. `p148w_clone` consumes an array and
returns `(original,fresh physical copy)` using `Array.clone`; it is not an alias
or a copy-on-write promise.

## Bounds and private invariant

Each requested array is limited to1,048,576 slots. Census additions saturate at
limit+1, so their operands never approach U32 overflow. Encoding runs only after
word/name/reserved-value counts fit. This also bounds subsequent payload
multiplication and offset addition. Reservations and writes check their logical
limits. Header writes check room for all eight words; value writes check room
for all three. Final word and value counts must exactly equal the census or
packing returns `P148Bad`.

Array indexing itself deliberately wraps modulo physical capacity. Raw
`p148w_get/set/new`, `p148n_get` and the decoder rely on the private producer
invariant and bounded callers. They are not an admission API for an arbitrary
forged `P148Good`. There is no redundant whole-tape validation pass before each
consumer. The optimizer must preserve forward ranges, valid IDs and refs,
scalar/direct child kinds, initialized used lengths, and its append capacity.
If external tape ingestion is introduced, it requires a separate structural
validator before any of these accesses.

Whole-function overflow/refusal is `P148Bad`; the caller must retain the original
function for fallback. `p148_unpack` is valid only for `P148Good`. Its required
total `P148Bad` arm produces an empty invalid-signature function, never a success
or reconstructed fallback.

## Decoding and shared helpers

All nine `N111Stmt` forms and five `P113DStmt` forms preserve original constructors,
field order, Strings, U64 low/high words, argument types and parameter metadata.
The decoder handles optimizer tag14 by splicing the selected child span into the
containing block and tag15 by omitting the instruction, then follows `next`.
These operations work independently for scalar and direct blocks; they do not
introduce a direct statement into a scalar branch.

Additional helpers for the consumers:

- `p148c_find_name(names,used,name)` is a bounded cold dictionary lookup returning
  `used` when absent, useful for the at-most255 parameter names.
- `p148c_stmt_count(words,values,names,used,valueUsed,nameUsed,start,end)` counts structured output statements,
  including nested branches but excluding payload words; splices/omits reflect
  their decoded output. The scalar pass can use it for its original size gate.
- `p148c_at`, `p148c_field`, `p148c_name` expose private bounded reads with the
  same six-argument prefix. Decoder walkers also use that prefix. The public
  unpack entry consumes its unit and tape once, then passes raw array handles
  and scalar metadata; it never retains an enclosing Type record.

The compact verifier's branch rule is independent of the codec: when both arms
continue and assign an ID, unequal capacities retain assignment with capacity0.
This corrects the earlier investigation's mistaken suggestion to drop that ID.

## Native ownership failure and successor

The first codec passed the root's hosted controls but failed the root's valid
native constant-result pack probe. The generated `p148c_vector_done` retained a
Build to call the old position getter, then destructured Build and its shared
Tape. In the pinned runtime, `rfc_seal` seals constructor fields but leaves raw
array handles unsealed. Taking a shared constructor calls `span_fade`, which
rejects a nontrivial unsealed child with `ERR_RFCS`. Consequently, sharing a Tape
containing fresh arrays violated the runtime ownership invariant. This was an
unsafe prototype assumption, not evidence of a production conformance defect.

The exact prior source is preserved in the ignored experiment history at
`selfhost/build/phase148/method-history/ownership-v01/core.bend`. The successor
keeps all array-containing records affine and exposes raw buffers to repeated
readers. It makes no runtime change and adds no incidental fork/drop operation
to force reference-count normalization. Native qualification and complete timing
must be repeated; the hosted result does not qualify this successor.

## Required evidence before adoption

Root-owned checks must cover every statement/value/type tag, empty bodies and
argument vectors, duplicate exact names, reserved and invalid names, nested
scalar/direct branches, non-ASCII spellings, maximal U32 constant halves,
capacity refusal, unchanged metadata, and splice/omit behavior. The decisive
first oracle is exact original structured equality after pack/unpack; optimizer
equivalence and admission/error ordering are additional independent controls.
Charge counting, interning, array initialization, conversion, both consumers,
decoding and destruction in complete native timings. This source alone provides
no measured speedup or correctness qualification.
