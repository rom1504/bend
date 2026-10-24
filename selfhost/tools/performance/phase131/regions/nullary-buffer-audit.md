# Independent scratch-buffer audit

This is a source and frozen-QBE audit, not a compiler change or a runtime
qualification. The selected combined compiler remains unchanged.

## Runtime contract

The exact retained implementation is
`selfhost/build/phase128/runtime-borrow01/runtime.c`, SHA256
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.

- Lines 4350–4364 define special-constructor arities. IDs 1/2/3 are
  False/True/Zero and require zero fields.
- Lines 4367–4390 load the environment, check the supplied count, then return
  0/1/0 for those constructors. These branches neither read nor retain `args`.
- Therefore replacing only the `args` actual with a null pointer for a call
  with a proven constant ID 1/2/3 and count 0 preserves the call, environment
  access, arity validation, result and effects. It does not authorize rewriting
  nonnullary calls, unknown IDs, arbitrary imports or runtime implementations.
- Lines 4624–4637 implement `p118_rt_borrow_fields`. It validates the shape,
  copies heap fields into `out` and returns count. It never reads prior `out`
  contents, stores that pointer elsewhere or mutates `state`.

The foreign/fallback branch must remain. A successful held-root borrow is not
proof that arbitrary external or corrupted Term words are valid. This audit
uses the existing checked Bend value and runtime memory invariants.

## Actual pointer escape and dead-store evidence

The source03 `p98_tag_eq` reader has one private `alloc8 2048`, with 53 statically
known scratch/offset aliases. The source07 unrelated packet reader has 11.
Every pointer use in the two frozen readers was inspected: allocation, constant
aligned offset, scratch load/store, or one of the two runtime imports above.
There is no address stored into `state`, the Bend heap, a retained object or a
returned scalar. Other private reader calls receive state and tagged Terms,
not this native scratch address. All scratch aliases have classified uses.

The first KTerm branch copies 8 fields and subsequently needs only field 0.
Unused local field loads can be removed. The other 7 scratch stores have no
semantic reader: a later nullary special constructor accepts the pointer but
ignores it. Across mutually exclusive branches the proposed ceiling removes 24
field stores in the compiler reader and 5 in the packet reader. These are static
sites, not per-query counts.

The `field-mask/ceiling.py` analysis reaches a scratch-slot liveness fixed point
in 2 iterations for these inputs. Its `borrow_fields` write-kill set and nullary
constructor empty read-set match the runtime implementations. Every import,
shape/RFC guard, branch and fallback remains byte-identical in the dead-field
variant. Dead heap loads are removable only under the existing valid-object
invariant; no claim is made about preserving a fault from corrupted memory.

The script is a frozen-source experiment. It is not a generic alias analysis:
for example, copied pointers or a pointer stored as a value require additional
escape checks. The actual two readers contain neither. Ordinary native output
checks and controlled timing remain separate requirements.

## Existing compiler gates and implementation choice

In `regions-source03/compiler.bend`, `p111v_value` at 40217 already permits a
null pointer constant, and `p111v_buffer` at 40340 accepts capacity 0 for count 0.
However, the independent direct-function contract
`p113e_nonstate_pointer` at 44953 accepts only a nonstate local pointer. Putting
`N111Const{0,0}` into the direct IR would therefore fail that existing gate.
Do not weaken it to run this experiment.

If the frozen ceiling proves useful, two conservative implementation choices
are an exact nullary-call rendering rule after the existing gates, or a checked
nullary scalar-constant lowering rule. The latter removes the call entirely and
needs its own semantic/effect controls. No such production implementation is
part of this audit. Nullary-pointer rendering alone may fail to unlock QBE dead
stores because the remaining fallback `borrow_fields` call still makes scratch
appear to escape to QBE. Measure both ceilings independently.

## Combined-source preservation check

Final combined source `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`
emitted the compiler occurrence proxy in
`selfhost/build/phase118/p131-combined-literals-transfer01/`.
Its complete `p98_tag_eq` borrowed reader, 17-line guarded adapter and 138-line
`nq_uses` caller are byte-identical to the measured source03 candidate.
`p128br_arguments`, `p128br_held`, `p131rv_value`, `p131rv_arguments`,
`p118b_reads` and the inspected original verifier predicates remain identical
apart from comments/whitespace. The final combination retains the measured
capability without source07's duplicated preparation.
