# Generic terminal calls to complete workers

This candidate removes a residual public handoff to a function that already has
an admitted complete private implementation. It builds on the exact checked
combined01 source: scaling, catalogue, ordinary packing, recursive04/G02 and
fixed transport. Existing compiler modules and runtime bytes remain unchanged.
Root owns all checker/native/timing execution.

Append `model.bend` and `emit.bend`, then override with `entry.bend`. The only
overrides are `p113e_public_chunk` and `p114t_local_name`. Export `p114b_scan`,
`p114b_target` and `p113e_signatures` for the15 structural control groups.
The original final verifier is unchanged; its existing namespace scan now also
rejects `p114b_` local definitions. `modules01.json` binds the complete parent
compiler/admission, all three modules, runtime source/object, census and controls.

The parent chooses existing complete-public, narrow recursive and general
recursive paths first. In the generic fallback, existing continuation fusion,
self-tail planning and legacy-private-call selection still run in their original
order. The bridge scans the resulting public worker plan and replaces only a
terminal pair:

```
reply = rt_jump(state, knownTargetFID, supportedScratch, literalCount)
return reply
```

The exact closed complete-function catalogue must contain that target with
`public=True`, result width1, the same parameter count, and at most32 parameters.
Private-only flat-product signatures and multiple results are excluded.
State, argument buffer and return destination must match the exact template.
Nonterminal calls, unsupported buffers, mismatched signatures and all other
instructions retain their original behavior. No source-function names are
special-cased. Already-selected self loops, R/G paths and legacy private-call
markers are not reconsidered.

The replacement loads every full U64 argument into a distinct fresh local before
calling the existing `p113d_` worker. It then stores the scalar result in the same
scratch buffer and invokes the unchanged `p111_rt_return(state,buffer,1)`, followed
by the matching Reply return. All earlier argument stores, keep/sink calls,
effects and pending continuation frames remain in their original order. Branch
traversal threads one site counter through yes, no and following statements.

The original public target wrapper already calls this exact private worker and
then `rt_return`. The omitted operations were `rt_jump`'s temporary argument-bank
copy/clear, the runtime dispatch, and wrapper register loads. The final return
still installs the result, clears every inactive logical register, sets `rn`,
pops the same pending continuation FID and returns Reply zero. Physical high-bank
words remain governed by the unchanged runtime. This does not remove return
clearing or invent a smaller valid-prefix bank contract.

The private verifier excludes reads/writes of `rn`, `next`, or the register bank,
pointer aliases of state, runtime transitions and generic foreign reentry. Its
closed worker call graph has bounded acyclic calls plus explicit self loops.
Consequently the worker cannot observe the omitted intermediate transport state,
and this bridge does not turn arbitrary recursive segment handoffs into growing
native calls. Owning argument/result words are transferred once through the same
private ABI; stale scratch words are transport copies, not extra owning roots.
Checked source-factory scratch separation remains a premise, as in fixed
transport. Source/runtime correspondence is not an arbitrary reflected-IR proof.

The offline frozen candidate31 census found470 residual static jumps across34
of45 programs. Local-pair has27 sites/12 target identities, edit-distance15/10,
and lexer7/4; these include real `cell`, `row`, `dp`, `step` and `lex` edges.
Tree-bitonic, list-pipeline128 and expression128 have zero matching edges and
serve as scope controls. These counts are not dynamic cost attribution and do
not predict a speedup. The evidence is pinned in
`../transport/direct-bridge-census01.json`.

After root's API check:

```
node selfhost/tools/performance/phase114/complete-bridge/controls.mjs CHECKED_API FRESH_PHASE114_OUT
python3 selfhost/tools/performance/phase114/complete-bridge/admit.py \
  --compiler COMPILER --api-report API_REPORT \
  --runtime-source selfhost/build/phase113/runtime-products01/runtime.c \
  --runtime-object selfhost/build/phase113/runtime-products-build01/runtime.o \
  --out FRESH_PHASE114_ADMISSION
```

Structural controls inspect scalar/result/arity gates, argument ordering at
0/2/9/32 fields, exact return protocol, unchanged effects/stores, fusion scratch,
fresh branch sites and fallback. They execute no generated IR. Independent
ordinary source `controls/generic-bridge/fixtures/dynamic-owned-arguments.bend`
keeps String owners across a dynamic application before a known terminal helper,
covering both outcomes, argument swaps, external aliases, empty text and Unicode.
Root also reuses ordinary programs and matched real kernels. A broader
composition with the continuation-table hook requires a separate final adapter
and exact conjunctive admission; this receipt is not transferable.
