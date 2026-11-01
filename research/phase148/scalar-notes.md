# Compact scalar consumer

Final disposition: the corrected consumer passed root-owned source, hosted and
native gates; its complete pipeline did not earn performance integration. See
the [final report](../../implementation/phase148/README.md). Statements below
about pending gates describe the implementation checkpoints, not current status.

`selfhost/tests/phase148/scalar.bend` implements
`p148o_function : P148Unit -> P148Unit`. The independent transformation oracle
is the actual maintained `p113k_function`, including `p113l_*` epochs/relations
and `p123p_*` predicate provenance. This is experimental code, not production
admission or a proof. Root owns checking, finite controls and native execution.
No target has been executed by this implementation agent.

## Representation and ownership

The instruction tape remains eight scalar words per instruction, with a
separate three-word value pool and the shared immutable exact-name dictionary.
The pass never calls `p148_unpack`, builds `N111Stmt`/`P113DStmt` trees, or stores
String-keyed `KDef` facts. Numeric name IDs index a contiguous `Array<U32>` with
16 words per name:

| Cells | Meaning |
| --- | --- |
|0..5|present, bit bound, exact flag, low word, high word, assignment epoch|
|6..10|relation present, subject ID, subject epoch, owner epoch, Boolean polarity|
|11..15|predicate present, root ID, root epoch, owner epoch, inversion|

Absent names have the original unknown64-bit fact and epoch0. A write increments
its epoch, including writes of unknown facts. Metadata remains stored but is
usable only when both captured epochs match, just as the original map records.
No dictionary ID alone establishes a fact, assignment or schema membership.

The ownership-correct successor passes raw array handles and scalar metadata,
never a shared Tape/Unit/Scan/Value wrapper. Writes consume and return arrays.
Before-mutation metadata is computed into
small scalar records before entering a helper that performs the write. In
particular, call operands are substituted before killing destination facts;
constructor-argument evaluation order is not used to impose that dependency.
Unknown conditional branches use `Array.clone`, which core guarantees returns
the original and a physically fresh copy. The tape threads sequentially through
disjoint branch ranges; fact state is private to each branch. Never pass a tape
whose backing arrays are expected to remain an independent immutable snapshot:
this is the consuming private-unit interface. Retain the original boxed input
as the independent oracle instead.

The only reused boxed arithmetic value is the existing four-field `P113KFact`.
It does not contain IR, names or a fact map. Existing pure arithmetic helpers
retain U32/U64 limits, known-one bits, comparisons, shifts and mask rules.
`Array<U32>` describes scalar storage, **not necessarily four-byte storage**:
the ordinary native compiler may use eight-byte Term cells. The physical probe
and generated operations must establish the actual layout and cost.

## Exact behavior retained

- Set substitutes its operand but applies the destination width only to its
  recorded fact. Bin preserves original mask/zero rewrites and comparison result
  types; exact arithmetic shares the original helpers.
- Runtime-call pointer arguments are untouched; other runtime arguments and all
  direct-call arguments substitute facts. All destinations are killed only
  afterwards. Loads, offsets and allocas kill their destination; store replaces
  only the stored value. Scalar Return stays unchanged and is not treated as a
  direct terminal by this optimizer, matching the original.
- Relation copies and eq/ne-to-Boolean-constant relations retain the original
  precedence and epoch checks. Predicate comparisons establish a new root;
  copies reject an overwritten root. Predicate tests inspect the original raw
  operands before ordinary fact substitution. Recognized scalar diamonds carry
  provenance from the original condition and re-anchor the surviving root epoch.
- Unknown branch joins intersect fact membership, combine the original fact
  lattice, reset joined epochs to1 and discard relation/predicate metadata.
  One continuing direct branch supplies its own state; both terminal branches
  terminate the outer sequence. Scalar branches do not acquire this direct
  terminal behavior.
- Constant branches use tag14 splices; terminal tails use tag15 omission.
  Original structured instruction order is preserved by decoding. The original
  optimizer chooses a known condition using its low word; this experiment
  preserves that behavior rather than introducing a separate semantic change.
- The original4096-statement threshold returns the unchanged unit. Counting
  includes nested scalar/direct instructions and excludes payload cells.

## Bounds and explicit refusal

The private codec creates a fresh value record for every original operand
occurrence; only names are interned. The scalar pass produces at most one new
three-word value for each original operand occurrence. Even the predicate
rewrite emits at most two records for the original two-input Bin. It appends
records, never overwrites an old shared value reference, and initially requires
capacity at least twice original `valueUsed`. Core reserves an even larger
bounded capacity. Names use16 fact cells, so the consumer refuses name counts
above65536 and original value-word counts above524288. These bounds keep all
address multiplication/addition within the codec's1,048,576-cell limit.

The original map shares ordinary-local keys with synthetic
`@condition:<name>` and `@p123predicate:<name>` keys. Numeric separate metadata
would change behavior on collisions. Therefore this first consumer explicitly
returns `P148Bad` if any dictionary spelling begins either reserved prefix.
This conservative refusal can include a harmless nonlocal spelling. The caller
must route a bad unit through the complete original optimizer/admission path;
it must not accept the unoptimized body as an equivalent optimized result.
Fresh private units from `p148_pack` are required; this is not an independent
validator for forged offsets, tags, aliases or array capacities.

## Check status and next useful evidence

Early source checks exposed the pinned language's matching and quantity
restrictions. Computed/local scrutinees and four computed tuple destructures
were replaced with result-parameter helpers. Tuple/result patterns follow
parameter order, and no local computation precedes a match. Array-bearing
products are `Type` with affine array/tape fields; scalar metadata products
remain `Data`. Unsafe function parameters retain explicit sharing where needed.
Each failed frozen attempt remains root-owned evidence. These admission fixes
establish no semantic success by themselves. The initial combined API passed
independent source checking (16exports/712declarations), then all81 hosted
controls:37admission errors,8literal optimized bodies,18actual admissions and
18actual full optimized-body/exact-QBE comparisons. Those passes belong to the
first ownership version, not automatically to its successor.

Require complete optimized-function equality against `p113k_function`, then
unchanged direct admission/rendering observations. Important negatives include
self-overwriting predicate roots, relation subject reassignment, Boolean
inversion copies, asymmetric terminal joins, scalar-return tails, U32 truncation,
mask simplification, metadata-key collisions and exact4096 cutoff behavior.
Native timing must include encoding, dictionary work, branch clones, scalar
optimization, the next compact consumer, decoding and destruction. In particular,
full-array branch copies and joins may erase any fact-lookup saving; no speed
claim follows merely from replacing the boxed map.


## Native ownership finding and successor

The initial native compiler-family fixture built and its old mode produced the
exact complete oracle. New mode failed before its first output. Root's smaller
pack-only probe reproduced the failure, so scalar arithmetic was not responsible.
The native runtime's `rfc_seal` seals constructor children, whereas raw array
handles remain affine. Sharing a Type wrapper containing such an unsealed array
then destructuring that wrapper reaches `span_fade`'s ERR_RFCS guard. Hosted
persistent-array evaluation did not expose this operational distinction.

The rejected source is preserved exactly at
`selfhost/build/phase148/method-history/ownership-v01/scalar.bend`, SHA-256
`ecfc8c1f464addb769b21907506ab68a56ddd339fb4457b71495c74d11288a32`.
The successor mechanically replaces each internal Tape parameter by
`words, values, names, used, valueUsed, nameUsed`. Only raw array handles and
immutable scalar metadata may be shared. Entry consumes Unit/Tape once; all
Value/Scan result wrappers are consumed once. Eight small affine adapters unpack
nested Tape-producing expressions immediately. There is no `+Tape`, `+Unit`,
`+Scan` or `+Value` parameter, no incidental reference-count normalization,
no fork/drop workaround and no runtime modification. The three leaf readers
receive only their actual array and index, avoiding six-argument transport for
single-field reads.

The exact source transformation is retained as `flatten-scalar.py` alongside the
old snapshot. Current initial successor:542lines/35,884 bytes, SHA-256
`25411f0e6a1bd42120595b865328bc175bf11e353bbc10390da622df1f3aa16b`.
Fact arithmetic, epoch/metadata rules, branching and refusal policy are unchanged;
source/value/native gates must nevertheless run again. Root's corrected codec
already passed small native pack/roundtrip/admission gates before this scalar
successor was submitted. Whole-compiler-family timing remains blocked until
complete native output parity succeeds.
