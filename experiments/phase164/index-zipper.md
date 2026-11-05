# Stack-safe index insertion without one scheduled return per tree level

`src/core/index-queries.bend:p131i_insert` recursively updates a child and then
constructs its parent. The direct backend rejects non-tail self calls, so this
widely used map update remains scheduled. This additive experiment changes the
implementation of that complete operation, while preserving its physical tree
and all record fields. The maintained function is untouched.

`selfhost/tests/phase164/index-zipper.bend` exports
`p164x_insert(tree, record, hash) -> KDef`. Typed-node descent records the exact
stored hash, split mask, untouched sibling and direction in a path. It stops at
a leaf, join point, legacy KDef or zero-split node. The outer dispatcher applies
the unchanged `index_leaf`, `index_join` or
`p131i_original_set(subtree, record, hash, 32)` at that exact subtree. A second
tail loop reconstructs all ancestors from the path.

Stopping at every leaf/join is deliberate: collision removal itself remains
generic. Keeping it out of the traversal worker allows the descent and unwind
loops to have a closed direct dependency graph without rewriting collision or
legacy semantics. Verify actual emitted native workers before crediting that
mechanism. The wrapper can remain generic; its boundary cost is paid once per
update rather than once per tree level.

No canonical-tree or 32-level assumption is used. The current single-path
algorithm's precise `diff & (split - 1)` test is retained for non-power-of-two
and inconsistent masks. On a legacy or split-zero stop, the old two-pass helper
is invoked only where the current algorithm invokes it. Using that helper as
the whole-operation oracle would be wrong on some malformed inputs: for
example a stored-root hash0/split4 with a left hash1 leaf and insertion hash1
joins above the root in the current algorithm, whereas the older two-pass
algorithm descends. The oracle is a frozen clone of current `p131i_insert`.

`zipper-controls.bend` supplies 17 named checks, 16 exported full old/new root
pairs, and a seed/count/hash-mode/legacy matrix. Observe both the retained old
root and inserted root to check alias preservation. Cases include duplicate
replacement, full record payloads, collision buckets, legacy subtrees, unusual
masks and a noncanonical path 65 nodes deep. The named Bool checks are a quick
gate; host full-structure comparisons of the exported KDef values remain an
independent equality check.

`zipper-workload.bend` is the bounded native transfer workload. It provides:

- `p164xw_map(keys, mode, epoch, new) -> KDef`: construct all keys, then overwrite
  every key in reverse order with changed epochs/values. The complete physical
  result is available to the hosted oracle.
- `p164xw_run(keys, rounds, mode, new) -> U32`: repeat fresh complete maps and
  consume each through Phase163's full-field `p163r_digest`, including every
  constructor, scalar, String, nested term and list terminator. Fold all digest
  words and the epoch into the final result; this checksum is supplementary to
  full-tree oracle controls.

Use 4096 keys and 8–16 rounds initially. Mode 0 uses the actual String name hash;
mode 1 masks it to 256 buckets, giving about 16 records per bucket. Key count is
bounded at 65536 and never grows across rounds. Build, overwrite, hashing,
payload construction, path allocation, result traversal and reclamation are
charged. No result or terminal subtree is precomputed by the host. Include a
small/shallow case because new path/stop allocation may erase a benefit there.

This is not a new unchecked runtime operation, native recursive stack use, or a
general compiler speed claim. If the complete-operation screen wins, the next
step is the same change on an actual compiler request with existing independent
verification and output gates. The static dependency argument alone does not
establish a gain.

The first native full-operation screen was neutral: at 4096 keys and 8 rounds,
normal hashes measured 0.24517s old / 0.24398s new, while the collision-heavy
mode measured 0.51873s / 0.52387s. The receipt is
`selfhost/build/phase164/zipper-native01/report.json`. Native descent/unwind
admission alone therefore did not establish a useful gain. The extra path
representation remains a plausible cost, not a measured allocation attribution.

`index-zipper-fused.bend` is a separate 64-line alternative; never load it with
the first module. It replaces `List<P164XPath>` with one recursive path type:
Done, Left{stored,split,right,next}, Right{stored,split,left,next}. This removes
the separate List cell per level while retaining the exact predicates,
subtree stop and terminal operations. External controls and workloads are
unchanged. A four-field frame has the rebuilt node's width, but allocator reuse
and a runtime gain must be measured rather than inferred from that fact.
