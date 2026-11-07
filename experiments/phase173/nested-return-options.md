# Phase173: owned state that survives a nested return boundary

Read-only architectural audit. No target, compiler image or new transformation
was executed for this note. Root's latest report is an approximately 8% clean
runtime improvement from direct arm jumps over the argument-bridge store, while
the complete store computation remains slower than the recursive-term reference.
These are extracted-workload runtimes, not whole-compiler speed claims.

The subsequent bounded source experiment is now prepared below. It changes only
experimental store modules; it does not implement a general compiler layout rule.

## The exact remaining representation limitation

The seven-field experiment is a useful falsifier: admitting flat **inputs** did
not remove the state representation on **returns**.

In `selfhost/tests/phase173/store-flat7.bend`, `P173Store` contains two affine
Array handles and five metadata words. `p173s_edge`, `p173s_node`, `p173s_size`,
`p173s_edges_end`, `p173s_add_node` and the import/compaction loops return a
`P173Store & T`. Its checked outer constructor is a two-field Tuple. Current
product layout treats nested records as opaque, so its two result lanes are:

```text
[owned boxed Store7, owned/immediate result]
```

The downstream flat worker expects Store's seven fields separately. Phase173's
argument bridge makes that call legal by consuming the boxed Store. It does not
prevent the producer from building that Store first. Likewise, a two-result
Tuple may already be virtual while its Store field remains materialized. Counting
outer Tuple elimination is therefore insufficient.

The source-level reason is explicit:

* `back/native/product-layout.bend:nq_layout_single` creates
  `NQShape(constructor, arity)`; its leaf check intentionally treats nested
  records/arrays as opaque.
* `back/native/product.bend:nq_width` uses that arity as the result word count.
  `nq_same` compares tag/name/count, with no nested layout identity.
* `qbe/flat-products.bend:p113p_constructor` requires the wanted shape's count to
  match the constructor's supplied words. For Tuple, that is two words.
* `p113pl_operation` sends bundle-valued arguments through `nq_opaque_args` before
  ordinary construction; that helper explicitly materializes a bundle with
  `NQBox`. An inner virtual Store cannot remain seven words inside the outer
  two-word result contract.
* `p113pl_bind_flat`, `p113pl_match`, `nq_entry`, `nq_remove_fields` and
  `p113df_bundle_env` assume each bundle child is a Var denoting one word. Merely
  placing nested bundles in `ks` is unsafe: some paths read the child's `ix` as
  a variable ID, or expect constructor arity to equal the flattened word count.

There are three different facts which the shallow shape currently conflates:
the runtime constructor's arity, the private ABI's word count, and the ownership
grouping of those words. A nested layout needs to distinguish them.

## What previous phases already established

[Phase123's report](../../implementation/phase123/README.md) records only
10–14% changed-source RLE ceilings. Its nominal outer-only/full variants actually
became the same four lanes, so they did **not** isolate two levels of product
flattening. The attempted strict-subterm layout rule failed on Pair/Sigma alias
normalization and was excluded. Do not repeat that experiment or cite it as an
implemented nested ABI.

[Phase126's product-observer work](../../implementation/phase126/product-observer-report.md)
successfully preserved a certified owning root plus observation through the
existing **shallow** product ABI. Source27 emitted unchanged code because its
shape decision ran too late; source32 recognized the product before the let
binding committed to boxing. `p126bp_flat` returns the known wrapper's Var fields
directly, but `p126bp_shape` intentionally excludes product-shaped inputs and
does not describe nested leaves.

The resulting lesson is useful here: choose a representation before the
constructor/let fallback materializes it, then carry that choice through calls,
matches and recursive edges. Adding a take-after-call adapter at the end does
not remove construction.

## Recommended smallest general capability

Start with **one nested owned singleton-product field**, not recursively flattening
every record. Permit two different, checked ordinary constructor identities,
nondependent fields and a total of at most eight result words. Other fields stay
opaque. Require the existing single-use/minimum-use admission for virtual shells;
unknown, shared, dropped or escaping shells retain their ordinary materialization.

For Store7, choose the first field of the two-field result:

```text
Tuple(Store7(nodes, edges, used, edgeUsed, nodeCap, edgeCap, ok), value)
    -> [nodes, edges, used, edgeUsed, nodeCap, edgeCap, ok, value]
paths = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 1]
```

Keep `value` opaque even when it is a three-field `P173Node`: flattening both
children would need ten result words and exceed the current independently
verified ABI. Store9 plus one result also cannot fit. Do not silently raise the
eight-result bound or change Array's representation.

A private QBE-only semantic descriptor could carry:

```text
NestedReturnPlan {
  outerConstructor, outerArity,
  selectedField, innerConstructor, innerArity,
  orderedLeafPaths, leafKinds,
  totalWords, matchingPrivateSignature,
  requiredSingleUseFacts, escapeMaterialization
}
```

This is a bounded two-level product descriptor, not a new general SSA IR. Its
identity must include constructor identities, selected path and ordered leaves;
`nq_same`'s shallow comparison is insufficient. Do not reuse an ordinary
`NQShape("Tuple",8)` to mean a two-field Tuple: that would falsify existing
constructor/ABI assumptions.

The first implementation can leave shared `nq_*` behavior and mature C unchanged
and use separate private QBE entries for the new layout. Existing
`P113DCall`/`P113DResult`, eight-word scratch result buffer, tail-SCC fusion and
final result/argument verification already support the resulting machine ABI.
No native runtime helper is inherently required.

### Required end-to-end seams

1. Derive the bounded descriptor from the checked result type before result and
   let binding shape selection. Reuse existing bounded alias/type resolution.
   Initially require **different constructor identities**; Store/Tuple,
   FParsed/FInput and Flow/Env qualify structurally without reviving the failed
   same-Sigma-instance normalization experiment.
2. Build the inner/outer result virtually from already evaluated leaf values.
   Preserve the original order of effectful argument evaluation; flattening is
   not permission to reorder producer computations.
3. At an immediate consumer, reconstruct virtual constructor structure from
   those leaf bindings. Matching the outer shell reveals the inner virtual shell;
   matching it transfers the same owned leaf tokens, without allocating or taking
   either shell. Existing one-word-child binding routines need a separate
   layout-aware path here.
4. Use the same private signature at producer, consumer and every relevant
   recursive edge. A result-only optimization followed by immediate reboxing
   would fail the purpose of the experiment. Keep the region's result vector
   uniform and its snapshot-before-assignment backedge discipline.
5. At a true boxed/public/unknown boundary, materialize the inner constructor and
   then the outer constructor using existing ownership-aware construction.
   Preserve the original boxed implementation as fallback and do not assume that
   a proposed private signature is already admitted.

This requires coordinated representation work; it is not a one-line change to
the flat-result limit. A rough implementation budget is 1–2 hours for a bounded
prototype after a successful source ceiling, plus native transfer/ownership
checks. Full qualification is a separate decision. This estimate is uncertain.

## Cheapest falsifier before implementing that machinery

Use one real store getter→consumer loop, including an Array read and a state
update, from the current store implementation. Preserve all input preparation,
reads, writes, bounds/growth behavior, final state and observed output.

Compare the existing `(Store7, value)` path with an explicitly declared ordinary
eight-field result record. Its producer returns the seven state fields plus one
opaque result; its immediate consumer destructures those fields and transfers
them directly to the next worker. Existing shallow product lowering can compile
that version without a new compiler feature. This is a changed-source **ceiling**,
not an automatic optimization, and must be labeled accordingly.

Before timing, inspect emitted code: do Store constructors/takes disappear from
the actual loop, do all recursive edges remain local, and are eight-word calls
actually used? Phase123 showed why source syntax is not enough. If both variants
still box, repair or reject the ceiling rather than report an inconclusive time.

Retain the exact state/result oracle, array growth and bounds controls, shared
payloads, returned payload observed after subsequent store mutation, and deep
stack-safe execution. For the automatic version also test escaping/shared
products, missing/recursive/dependent layouts and malformed ABI plans. The
independent final verifier remains compulsory.

Run the small ceiling first, then the frozen 101-body complete computation if
the dynamic construction/take reduction is substantial. Require a clear clean
runtime benefit after including wider calls and spills; a 15% reduction in this
pilot would be a useful decision threshold, not a prediction. Stop if only work
moves into reconstruction adapters or the wider ABI erases the gain.

## Concrete transfer into the compiler

There are real source structures beyond the store:

| Compiler representation | Current nested boundary | Bounded candidate leaves |
|---|---|---|
| `front/parser.bend:FParsed` and `front/lexer.bend:FInput` | `FParsed(term, FInput(tokens, context))` | term, tokens, opaque context: 3 |
| `back/qbe/verify-compact.bend:P147VFlow` and `P147VEnv` | `Flow(Env(schema, assigned), terminal, error)` | schema, assigned, terminal, error: 4 |
| Store getter/compactor | `Tuple(Store7(...), value)` | seven state words plus opaque value: 8 |

These are source-grounded candidate shapes, not demonstrated hot eligible sites.
For example, parser input/context can be shared across observations, and that
may force materialization or make field-level retains more expensive. A small
extracted parser or verifier computation should test the same representation
rule and complete output against an unchanged independent reference before a
full compiler image is rebuilt. There is no established whole-compiler gain
ceiling from these shapes alone.

## Alternatives and risks

**Preserve an unchanged owned root in read-only observers.** The existing
Phase126 borrowed-observer machinery may remove Store reconstruction in getters
without widening returns. This is cheaper if a verified Array-read observer can
retain its dominating Store owner and return the proper owned element. It does
not cover writers, counters/growth or arbitrary nested state. Array aliasing,
element retain semantics and effect ordering need explicit admission; Array is
not an ordinary immutable child. This is a competing bounded hypothesis, not
authorization to assume Array reads satisfy the current observer contract.

**Late P113D scalar replacement.** One could clone producers with expanded
results and cancel constructor/take pairs across calls after lowering. That
avoids changing source-level virtual bundles, but must reconstruct constructor
identity, owner credits, scratch buffers and escape information from lower-level
runtime calls. Many of those facts were already available earlier. It is not the
preferred first implementation unless the source ceiling reveals a very small,
already authenticated pattern.

**General recursive layout.** This could eventually express arbitrary nested
products and selective unboxing, but adds alias normalization, recursive layout
termination, dependent fields, proof-erased quantities, wider signatures and
profitability choices simultaneously. The current evidence justifies a two-level
experiment, not that architecture campaign.

Main risks are misidentifying two layouts as ABI-equivalent, dropping/duplicating
owned array or payload tokens, invalidating source evaluation order, extending
native stack use through incompatible SCC result vectors, and trading allocation
for register pressure and result-buffer traffic. The old eight-word return
buffer still entails stores/loads; eliminating a shell does not imply zero-cost
transport. Unknown/escaping paths must retain their original behavior.

A small Bend equality theorem about flattening and rebuilding two finite
constructors could document the value-level invariant with erased proof terms.
It would not prove runtime ownership, Array behavior, ABI integration or the
whole compiler. The optimizer still needs checked admission and independent
execution evidence for those obligations.

## Recommendation

First measure the explicit eight-field return ceiling and one unrelated
parser/verification product ceiling. If the relevant boxes actually disappear
and runtime improves, implement the bounded private nested-return descriptor
end to end through producer, immediate consumer and SCC. Keep larger layouts,
shared-layout generalization and whole-compiler promises deferred until that
single capability earns its cost.

## Prepared experiment: explicit eight-field source ceiling

Four alternative modules preserve the complete indexed computation, including
import, compaction, ordered reference discovery, export, structural validation
and final release:

| Existing module | Alternative |
|---|---|
| `selfhost/tests/phase173/store-flat7.bend` | `store-wide8.bend` |
| `selfhost/tests/phase173/store-compact.bend` | `store-compact-wide8.bend` |
| `selfhost/tests/phase173/store-controls.bend` | `store-controls-wide8.bend` |
| `selfhost/tests/phase173/vertical-store.bend` | `vertical-store-wide8.bend` |

Select the alternatives together, not alongside their original definitions.
For the current candidate, select `store-wide8-v2.bend` in place of
`store-wide8.bend`; the other three modules are unchanged. Revision 2 preserves
the original Tuple's default affine quantity on the payload field and pack
parameter. Revision 1 used `+value: T`, which is legal because `T: Data` but was
an unnecessary code-generation variable. The frozen revision 1 remains intact.
The external observation records and exported function names are unchanged.
The internal `Store & T` contract becomes:

```text
P173Return<T>(nodes, edges, used, edgeUsed, nodeCapacity, edgeCapacity, ok, value)
```

The two arrays remain affine. The result is one opaque Data value, including
when it is a three-field node. An immediate consumer matches the eight fields
and constructs `P173Store` only directly in the original call argument. The
current input-product lowering may preserve those seven fields virtually; that
is a testable hypothesis, not something the source spelling guarantees.

Producers already holding the fields construct the eight-field record directly.
Producers holding a Store use one generic `p173r_pack` that consumes Store and
returns the same fields plus the value. This helper is an explicit admission
gate: it must itself use the flat input/result ABI. Ordinary Array.get and
Array.size retain their original pair contracts. No Array algorithm, fuel,
capacity policy, traversal, value comparison, reference order or oracle changes.

The source accounting receipts are
[`wide-return-source.json`](wide-return-source.json) and
[`wide-return-source-v2.json`](wide-return-source-v2.json). They record 49 rewritten
pair results and 66 consuming matches. A mechanical inverse check restores the
old pair shell and field mapping and reproduces all four original modules'
lexical tokens (ignoring only whitespace outside string literals). This checks
the scope of the edit; it is not a formal semantic proof.

The parent's pre-snapshot review caught a rewrite defect: the word `store` inside
the refusal-message literal was initially replaced along with variable uses.
The inverse comparison could undo that substitution, so it did not catch it.
The generator was corrected to skip quoted strings. A separate exact comparison
now confirms that all four modules retain the originals' entire string-literal
sequences. No target was acquired from the faulty version. This is why the
existing full-output oracle remains a separate required gate.

Run the gates in this order:

1. Independently check the modified Bend modules and retain the existing finite
   complete-record/refusal controls. Compare their whole values, not hashes.
2. Inspect the checked raw/direct plans before a machine build. Require eight
   results, actual ready dependencies and bounded stack-safe SCCs. Distinguish
   refusal from a successful flat route; a generic fallback does not test the
   intended hypothesis.
3. Inspect emitted code for complete getter-to-consumer loops. Require the
   repeated Store constructor **and** its consuming take to disappear. Also
   check whether the new return shell stays virtual and whether field transfer
   merely introduced other boxes. Count entry/exit materialization separately.
4. Only if the shape gate passes, execute the frozen 101-body corpus against
   its existing 962,601-byte full-output oracle. Keep input, output, algorithm,
   runtime, policy and native toolchain fixed. Compare alternated clean runs
   with the corresponding flat7 source and the existing recursive-term baseline.
5. Attribute any runtime effect separately from compiler-request cost, code
   size, machine construction, register spills and validation cost. Eight return
   lanes can lose despite allocation removal. A negative result rejects this
   source ABI ceiling; it does not establish that all nested representations
   are unprofitable.

At preparation time no target or native benchmark was run by this agent. The
parent owns acquisition, independent execution and the controlled timing lane.

The parent subsequently acquired revision 1 successfully:
`selfhost/build/phase173/store-wide8-api01/report.json` records independent source
checking in 15.440 seconds, and `store-wide8-finite01/report.json` preserves 26
complete-value observations plus three refusal controls in 1.199 seconds. This
establishes the first source/finite gate only. It is neither native performance
evidence nor evidence that the Store boxes disappeared. Revision 2's payload
quantity correction still requires its own source/admission gate.

### Revision 2 machine-shape gate: incomplete elimination

The parent subsequently checked revision 2, passed the 29 finite controls and
101 actual complete-value controls, and emitted
`selfhost/build/phase173/store-wide8-emission02/program.ssa`. Static inspection
is preserved in [`wide-return-qbe-gate.json`](wide-return-qbe-gate.json).

The eight-result ABI itself works: the flat pack helper writes offsets 0 through
56 and contains no calls; the flat node/edge getters have no local Store
constructor/take. However, this does **not** compose through the complete
consumer. The compaction SCC still contains 11 Store7 construction sites and 15
seven-field take sites, along with boxed edge/emission helper calls. Its QBE text
is 575,177 bytes and carries 22 state lanes. Import, export and reference SCCs
likewise retain Store construction/take pairs. These are static site counts,
not measured dynamic frequencies.

The shape gate therefore fails. Do not pay for a native build merely to assume
that eight result lanes remove the entire category of work. The generic pack
helper is not the obstruction; other call/let boundaries still materialize the
source-level Store reconstruction. This is evidence that a nominally flat return
contract alone is insufficient, not evidence of runtime speedup or regression.
