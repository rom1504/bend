# Registry metadata reuse discriminator

`registry-v03.bend` is a versioned replacement for `registry-v02.bend`, not an
additional overlay. It adds105 physical lines. It is source-only until the
coordinator acquires and checks the composed API. Append
`metadata-controls-v01.bend` and export `p140gm_controls` (16 controls).
`native-controls-v03.bend` replaces v02 solely to make its pure cache observer
exhaustive for the new metadata cache variant. Frozen native v02/v03 adapters
otherwise transport the cache opaquely.

## Observed dependencies

Inspected selected Phase137 source
`selfhost/build/phase137/integrated-source03/compiler.bend`:

- `p111q_ids`40755 consumes ordered function names and ordered constructor
  names/arities. It does not inspect segment bodies.
- `p111q_tables`40873 and `p111q_descriptor`40859 consume ordered segment
  name/arity/result/incoming/flags, constructor name/arity/hot, show words,
  show names, effects and pure. Segment bodies do not contribute labels/data.
- `p112s_tables`42492 additionally consumes complete ordered static nodes,
  including offsets, constructor names and every tagged field word.
- `p117p_tables`50519, `p118z_tables`51832 and `p118c_tables`51637 transform
  only their supplied tables; arrays/live decide the first two wrappers.
- Current function-list emptiness determines mode separately; the candidate
  recomputes mode and invokes unchanged `p134e_registered` for every request.

The candidate compares these complete inputs with existing exact comparison
helpers. It retains actual typed IDs/tables and only reuses them on equality.
The entire current program and static image remain cache keys; no hash substitutes
for structural equality, source identity or the existing verified producer epoch.
The original registration/worker admission/final verifiers are unchanged.

## Fusion index update

`p112f_index_bucket_add`42894 is FIRST-WINS. Calling `p112f_index_add` with a
changed same-name segment silently keeps its old body, so that tempting shortcut
is incorrect. Patricia structure depends only on the ordered names/hashes.

After exact ordered-header equality, the candidate compares complete bodies
positionally. At most16 changed positions become patches. Each patch resolves
its name to the FIRST segment in the current list, then replaces that exact-name
bucket entry without altering any hash, Patricia mask, branch, bucket position,
or collision neighbor. This also handles duplicate names correctly, even though
successful verified programs generally disallow them. Unchanged entries are
retained actual old segments with exact equal fields. More than16 changes or
length mismatch uses the original `p112f_index`; metadata mismatch uses the
original complete metadata/index construction. The bounded patch path costs
O(N + changed*N + changed*tree-depth); it is aimed at one/few changed bodies,
not arbitrary bulk revision. It never changes original index helper semantics.

## Gates and limitations

The16 finite controls compare full fresh/index structure, cover real FNV
`costarring`/`liquid` collision, duplicate-first/later/all replacement, bounded
fallback, metadata changes, and whole emitted text after body edit/reordering.
All existing registry controls should run unchanged. Actual composed native
source still needs checked acquisition and same-revision cold/warm product
comparison before any speed claim. Add full-API controls for constructor/static
node/arrays/live mutations if the candidate proceeds to native measurement.

This does not eliminate registry rebuilding itself: `p112c_candidates`, per-pass
ready/symbol comparisons, `p112c_freeze`, registry tables and `p134e_registered`
still execute. The measured12.805s warm registry time is an upper ceiling for
this experiment, not a predicted saving. Cache retention adds a reference to
previous program/static metadata and tables/index, increasing live memory;
cache publication remains the native adapter's successful-file-close boundary.
