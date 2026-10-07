# Compact index-node proposal (private; not applied)

The batch overlay was qualified separately. This proposal targets persistent
trie construction/traversal across checked compiler requests, without replacing
ordinary declaration records or the BookCache sentinel. It is source-only and
has not been built, imported or timed here.

`compact-index-v2.patch` adds two alternatives to KDef:

- `KIndexLeaf{hash, bucket}` stores the original exact-name collision bucket.
- `KIndexNode{hash, mask, left, right}` stores direct persistent child references.

Name/kind/hash/mask/native/unsafe getters return the previous virtual values.
Type/value getters materialize Absent terms; `dc` materializes the previous child
list when an observer asks for it. These views preserve values, not old private
placeholder/list-cell identity. Leaf buckets, ordinary KDef references and
untouched subtree references remain shared. The old KDef constructor and raw
IndexLeaf/IndexNode records still work; no global conversion or new cache-carrier
is added. BookCache bound/flags/type/value/child-root schema remains unchanged.

Typed find, tip and insertion branches consume node fields directly. Ordinary
lookup/update does not call the virtual `dc` on compact nodes. Existing old-node
algorithms remain as fallback, including mixed old/compact trees; zero-mask raw
compact nodes use the old virtual leaf interpretation. Hash function, lowest
set-bit split, branch ordering and collision equality remain unchanged.

Static payload headroom: an old internal node constructs nine KDef fields,
two eight-field Absent KTerms and two two-field list cells (29 declared payload
slots). A compact node has four. A leaf has two instead of 27 such slots. This
is a source-construction comparison, not measured object bytes, eliminated
allocations or expected speedup. Virtual observation can still allocate.

Integration requirements:

1. Root applies the exact term/index patch only after static review and rechecks
   before hashes. No additional caller or BookCache/max-bound seam is needed.
2. The maintained positional `createCompilerAbi` registry needs
   `KIndexLeaf:['hash','bucket']` and
   `KIndexNode:['hash','mask','left','right']` when loading a module.G image.
   Direct named-field/noG images already bypass that adapter. Coordinate this
   small host-only seam; do not rewrite historical adapters.
3. Use controls-v2.mjs, preserving consumed controls-v1. It compares full virtual
   node metadata, event order/lookups, collisions, stale/surrogate fallbacks,
   retained definition identities, original empty-book identity, legacy/mixed
   trees, U32 max-bound and JSON round trips; it requires actual compact tags and
   ordinary selected-context activation. Only new private node tags normalize.
4. Actual checked source/API/runtime output gates remain mandatory. Private probe
   equivalence does not grant unchanged raw node-tag representation or release.

Root-only focused command after a genuine candidate build:

```sh
NODE selfhost/tools/performance/phase61/index/controls-v2.mjs \
  selfhost/build/phase58/checked-last01 NEW_CHECKED_ATTEMPT \
  selfhost/build/phase61/compact-index-controls01
```

First falsifier: reject immediately on metadata/lookup/order/alias/legacy/wire
failure or actual compiler-output mismatch. Then compare clean first/later
requests and separately sampled CPU/allocation on numeric recurrence plus Lexer
before the 23-source matrix. Index is visible in all 23 Phase60 profiles; this
is broader motivation, not permission to project a percentage saving. Preserve
both a regression and a neutral outcome. Full source/selfcheck/B2/release gates
remain separate.

This follows the scoped typed-handle/representation lesson in
[the Zig source study](../../../../../../research/compilers_architecture_and_techniques/zig.md),
not a port of a global intern pool. Persistent book scope, current definitions,
ordered declaration events, mutation dependencies and source spans stay intact.
