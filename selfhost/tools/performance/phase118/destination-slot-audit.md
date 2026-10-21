# Phase118 private destination-slot audit

**Conclusion:** feasible as a small private representation change; no input-cell
reuse or additional formal is needed. However, an all-cold gate covers the two
list workers and excludes the observed lexer/map String builders. Treat a first
cold-only experiment as a mechanism test, not evidence of compiler-wide transfer.
This audit is source/static evidence only. No implementation or target run.

## Evidence and exact integration boundary

`trmc-v4.bend:83` creates each node with a literal constructor and prefix count,
then carries the returned node Term as the last hidden backedge argument.
The same module's `p118t_finish:37` passes that hidden parent to terminal finish;
`p118t_call_result:66` preserves it through ordinary self-tail steps. Hidden root
and parent are absent from the source environment. The parent is used only as a
private cursor, not an additional source owner.

`runtime-u32-01/runtime.c:4583` reconstructs the pending field on every fill:
decode parent tag/RFC/CID/location, check arity2..8 and dynamic location, compute
`location+arity-1`, check the hole, then look up the **parent** cold policy.
This work repeats information known when that same node was allocated.

Static whole-worker coverage in exact existing artifacts:

| Artifact | TRMC worker | Extended constructor | All cold? |
| --- | --- | --- | --- |
| `extend-emit01/coverage-list-pipeline-128.ssa` | `p37.list` | Con, CID18 | Yes |
| same | `dbl` | Con, CID18 | Yes |
| `extend-emit01/lexer.ssa` | `ident`, `num` | SCon, CID25 | No |
| `combined-emit01/coverage-map-churn-128.ssa` | `String.append` | SCon, CID25 | No |
| `combined-emit01/tree-bitonic.ssa` | none | — | — |

Artifacts are beneath `selfhost/build/phase118`; module paths are this folder.
CID/hot facts come from each artifact's own `p111_cid_hot` and constructor-name
tables, not from matching numeric IDs between programs. Site counts do not imply
dynamic coverage. The earlier combined list profile assigns66/562 leaves to
`p118_destination_fill` (11.7%); it precedes the newer bank/divmod/sized changes.
Its full cost cannot disappear because the hole check and actual store remain.

## Proposed private interface

Keep the two hidden words and public zero/zero initialization:

```
root: owned unpublished constructor chain, or zero
pendingSlot: borrowed heap word index inside root, or zero

node = extendColdSlot(state, pendingSlot, cid, prefix, count)
nextRoot = root == 0 ? node : root
nextSlot = (node & LOC_MASK) + count
Again(originalArguments, nextRoot, nextSlot)

finishColdSlot(state, root, pendingSlot, result)
```

The node is still returned as a normal raw Term, so root initialization and the
published result ABI remain unchanged. `count` is prefix count, hence the exact
final field offset even when consecutive constructors have different arities.
An ordinary tail step preserves the slot; a base-only call has root=slot=0.
No pointer cast, heap-wide lookup, new allocation or additional stack parameter
is required. Existing bounded-stack and evaluation-order properties remain.

Run the gate **after request-bound cold derivation**, before final machine
emission. `p118e_cold`/`p118e_permitted` already bind the checked request, sharing
analysis and program. `p118t_ready` alone is too early: it does not have the final
source-derived cold set. Do not treat a caller-supplied hot table or name prefix
as certificate authority. The scalar-false observer-only route must retain its
original representation and sealing behavior.

## Necessary proof obligations

1. Authenticate a complete factory-produced TRMC worker, including wrapper
   initialization, final hidden-parameter positions, every backedge and every
   terminal finish. Scan both structured and scalar branches conservatively.
   Require at least one extend and every extend to use a literal ordinary CID
   with verified arity=count+1, count1..7, and cold status from the same request.
   Any unknown use or escape of hidden parent/root refuses the whole worker.
2. Transform all extend/finish uses and backedges together. Preserve node Terms
   used to initialize root; replace only the cursor value. Do not replace a node
   globally with its slot, since that would corrupt the owned result.
3. Maintain the inductive invariant: nonzero pendingSlot points to the unique
   uninitialized last field of a freshly allocated cold constructor reachable
   from the unpublished root. That root remains live across ordinary nested
   calls. The slot does not escape to source values, observer views, runtime
   scheduler arguments or unrelated workers. Source ownership alone does not
   prove an arbitrary integer is a writable slot.
4. Preserve new-node CID/arity/prefix checks, initialize all prefixes and the
   hole before linking, then fill the prior slot. Retain the actual `TERM_HOLE`
   check and dynamic-index bounds. A conservative bound is
   `HEAP_OFF <= slot < HEAP_OFF + (H_CAP << PAGE_BITS)`, with the existing atomic
   heap-capacity read discipline; also retain the40-bit location constraint.
   These bounds establish address range, not ownership or same-allocation
   membership. The factory invariant supplies the latter. Avoid adding checks
   whose ordering changes existing allocation-error handling.
5. Slot stores skip sealing only under capability8 plus the same cold proof.
   In the first implementation each newly extended CID can retain a runtime
   cold assertion as a fail-closed cross-check. Terminal fill has no CID and
   relies on its private protocol certificate. A shared/hot child may still be
   stored in a cold parent: store policy belongs to the **parent**, not child.
   Existing runtime and proof already permit transferring an RFC child there.
6. Original program/reference verification remains independent. The derived
   slot projection needs its own exact structural contract and runtime identity;
   do not claim the old parent-Term helper verifier proves the slot protocol.
   Legacy descriptors, hot workers and unknown patterns keep the existing path.

Mixed cold constructor arities, skipped construction steps, zero-step/base
execution, nested independent builders, static suffixes and live/shared children
are the useful ordinary controls. A mixed cold/hot worker must refuse entirely
in this first version. Existing mixed-construction and shared construction
fixtures cover the relevant source behaviors; additionally inspect admission
and representation so a fallback pass is not mistaken for testing the new path.

## Value and a conservative next decision

The conceptual win is preserving a known destination address rather than
reconstructing it from a tagged owner at each use. Estimated source work is one
bounded worker scan/rewrite plus two additive helpers, roughly30–60min including
focused qualification; broad integration is additional. A5–10% list gain is a
hypothesis, not a prediction supported by current measurements. The directly
addressable profile share is only about12%, and required checks/stores remain.

Cold-only admission is not yet a compelling compiler optimization: compiler
String builders use SCon, which is hot in the measured lexer/map programs, and
compiler datatype sharing must be measured from its actual request. Prioritize
the current integrated compiler acquisition/smoke and its own residual profile
over a full new runtime campaign justified only by list performance.

If the cold-slot mechanism wins decisively, a small generalization may preserve
one **seal-policy bit alongside the slot** in the same opaque word. That records
the creator's parent policy once, so hot/cold/mixed workers can avoid CID/arity
reconstruction while hot stores still call `rfc_seal`. It does not require all
constructors to be cold or another hidden formal. That is a separate hypothesis
with bit-encoding, descriptor-capability, mixed-policy and legacy obligations;
do not fold it into the first experiment or infer it is free from complexity.
