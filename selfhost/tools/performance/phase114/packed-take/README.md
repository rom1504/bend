# Shared packed unary take

This optional backend intrinsic recognizes the unchanged verified
`p111_rt_take(state, term, supportedScratch, 1)` at final statement emission.
It applies to generic segments, complete workers and table cases that visit
`p111q_stmt`. It changes no owning IR, planner or runtime bytes.

The fast path reproduces the pinned runtime's arity-one PAK branch:

1. Snapshot the full input word; require `((word >> 56) & 127) == 1`.
2. Extract its 16-bit CID and check it against the bound descriptor's
   constructor count at byte24.
3. Load exactly one unsigned byte from `p111_cid_arity[CID]`; require arity1.
4. Store `word & 0xffffffffff` to the original output, then assign U64 status1.

Every other path calls the original helper through the selected `p114t_stmt`.
The byte access is an explicit QBE `loadub`, because N111 has no byte scalar
type. It follows the unsigned bound check; there is no wide read from the compact
table. The full 40-bit payload remains intact, including values above 32 bits.
The tag mask matches the runtime, including its treatment of the RFC bit on a
PAK word. This path neither dereferences a Term payload nor changes ownership,
allocation, reference counts, or free lists. Heap-backed unary owners retain
the original helper.

The module uses the descriptor and arity table emitted for this same bound
program; their original producers and runtime binding stay pinned. Supported
buffers are the existing authenticated transport scratch origins and the exact
eight table-case scratch names. Name recognition is not a stand-alone pointer
provenance proof. The source factory remains mandatory.

Each expanded statement reserves a fresh shared counter site. Its private
temporaries and labels use `p114pk_`; original generic/direct definitions and
parameters cannot use that prefix. The original final verifier, transport guard,
and any bridge extension of that guard run before the additional namespace
check. The fallback never calls the new global hook recursively. Input/result
aliasing is safe because classification reads the snapshot and writes the
original destination only after storing the payload.

Append `model.bend`, `original.bend`, `namespace.bend`, `emit.bend`; apply
`entry.bend` as exact overrides of `p111q_stmt` and `p113a_verify`. First ablation
uses the pinned table01+transport parent. The original verifier alias is exact
for that parent. The optional bridge changes neither hook, and its namespace
extension remains visible through the preserved transport verifier; a combined
profile still needs its own exact source admission.

Export `p114pk_shape`, `p114pk_buffer`, `p114pk_stmt`, `p114pk_namespace`, and
`p111q_ids` for optional source-only emission inspection:

```sh
node selfhost/tools/performance/phase114/packed-take/controls.mjs CHECKED_API FRESH_PHASE114_OUT
```

After checking, `admit.py --compiler COMPILER --api-report CHECKED_API_REPORT
--runtime-source RUNTIME_C --runtime-object RUNTIME_O --out FRESH_PHASE114_OUT`
binds the complete parent admission, exact added declarations, unchanged runtime,
and checked API. It requires 6,396 declarations for this isolated table01 parent
and verifies the original final-verifier alias. It runs no synthetic mutations,
compiler, generated IR or native target. Other overlays require a new combined
receipt; this standalone receipt cannot be transferred to another parent.

The six groups check the actual byte instruction, metadata order, full payload,
status/store order, exact fallback text, destination alias and fresh sites.
They execute no generated IR or malformed native input. Independent native gates
reuse the four frozen ordinary packing fixtures: scalar values, Nat boundaries
at and above 40 bits, owning String aliases, and nested shared tree/List values.
Their sources and complete-output oracles are unchanged. Root additionally
compares the ordinary expression and tree workloads and confirms actual hot-path
selection. No target, semantic or performance result is claimed by this source
prototype. The earlier private Take2 measurements do not qualify this change.

Independent ABI source review found no concrete discrepancy in the tag mask,
byte metadata access, payload width, output/status ordering, fallback, counter or
verifier composition. That review did not execute a target.
