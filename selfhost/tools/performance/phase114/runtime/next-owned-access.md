Checked constructor identity is available at match lowering and is discarded specifically by `p111_take`. The next useful representation is an owned, constructor-specific extraction node that preserves that fact through planning; it should not be a flag permitting arbitrary U64 words to bypass checks. This is a source-only proposal, with no implementation or performance claim.

`phase111/segment/lower-control.bend:p111_match_apply` has the exact `Mat` constructor name, field count, owner local, and hit branch. Its current generic descendant is `phase112/word-pattern/original.bend:p112m_original_match_apply`; the selected product path is `phase113/nat-match/overrides-products.bend:p113pm_original_match`. Both remove the scrutinee binding from the hit environment and introduce field bindings before lowering the arm. The product path additionally retains the checked field mask through `p113df_field_env`. Then `phase111/segment/lower-value.bend:p111_take` uses the name only to select ordinary versus special extraction: an ordinary call retains `(state, owner, scratch, count)` and loses the constructor identity and field kinds. The preceding `p111_test` still contains `N111CtorId{name}`, but only as a separate comparison.

Consequently `runtime-products01/runtime.c:p111_rt_take` re-extracts CID, bounds-checks it, reads `cid_arity`, compares count, and checks PAK/CTR representation. The generic verifier (`phase111/segment/verify.bend:p111v_counted_call`) checks buffer/count capacity for Take, not constructor equality or a dominating match fact. Raw same-shaped N111 calls therefore cannot safely acquire the stronger contract merely by matching a symbol.

The mature native backend keeps this connection: `selfhost/src/back/native/bridge.bend:nc_match_apply_slow_to` calls `nc_destructure(name, word, count, n)` inside the exact constructor arm. That emits `ctr_take`/`spare_free` directly, with a PAK branch for unary fields and no descriptor revalidation. The pinned upstream generator (`selfhost/.bootstrap/upstream-phase66/bend2/comp.ts:node_fields`, around lines1582–1616, called by `emit_match` around2695) additionally carries `lay_node(k)`, packed layout, borrowed status, and hot/static classification. Those separate facts justify stronger choices there; a matched CID alone does not justify importing all of them.

A bounded sketch is a private `OwnedMatch{owner, exactCtorRow, hitFields, hitBody, missBody}` / `TakeKnown{owner, exactCtorRow, destinations}` facade. Its erasure must reproduce the existing test+Take+field-load sequence and pass the unchanged original verifier. Admission must bind the actual checked constructor table, exact arity, the owner consumed in this hit arm, full-word field order, supported scratch capacity/separation, and unchanged runtime. Preserve this node through renaming, fusion and recursive-table copying; do not encode its fact in local spelling or spare ID fields. A final private template can remove CID/count-table checks, use known count for field moves/free class, and eventually write directly to field destinations instead of scratch. Keep the original generic projection for unsupported provenance.

The first version should retain the unary PAK-versus-CTR branch and the existing unique/shared/static ownership behavior. Guarded unary packing does not prove every value with a particular CID is packed. Likewise a successful aux comparison does not itself prove CTR representation, unique ownership, sealed fields, or scalar fields; dropping those tests requires the checked ADT/producer and runtime representation closure separately. No RC or allocator check disappears merely because the constructor is known. Special Nat/Bool/Char/Word/Array and effect extraction stay on their existing paths.

An offline scan of the already-built table screen confirms ordinary extraction remains across the selected families:

| Program | All emitted Take calls by field count | Take calls inside functions containing H dispatch |
|---|---|---|
| tree-bitonic | 1: 12, 2: 33, 4: 3 | 1: 4, 2: 4 |
| coverage-expression-128 | 1: 3, 2: 26 | 1: 1, 2: 3 |
| coverage-list-pipeline-128 | 1: 2, 2: 26 | none |

For example, the tree table QBE at lines11062–11070 compares the owner’s aux with CID151 and immediately calls `p111_rt_take(..., 2)` in the hit arm; the constructor fact has not reached the callee. These are static occurrences, including library bodies and copied continuations, not reachable-hotness or savings estimates. The list’s zero H count means its takes reside in other emitted worker kinds, not that it lacks the opportunity. Removing table validation alone may be small; preserving owned extraction also makes constant-size direct field transfer possible, which is the broader hypothesis to measure later.

Method: read the exact `program.ssa` paths from `selfhost/build/phase114/table-screen01-jobs-reports.json`, count `call $p111_rt_take` by its literal final argument, and separately count functions containing `@p114h_dispatch`. No transformed QBE or target execution. Input SHA-256 pins:

- tree-bitonic: `0bd8c74e6bf40cb7494e8122d1a8b852ad86a78d1f71d14272510eae24ca8848` (617054 bytes).
- coverage-expression-128: `cb899d6042ba9ff3dc19b3ba690b235976add993ca2aa6e73eb941015fc60272` (455671 bytes).
- coverage-list-pipeline-128: `1ad41df68bcd4b90e8745eae94281d03ecb03d98a7fbf41859e5085f8ce08b2b` (454701 bytes).
