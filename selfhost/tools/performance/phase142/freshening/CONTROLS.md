# Freshening finite controls

Source prepared independently; no execution or proof claim in this document.

Append `controls-v01.bend` to the exact Phase141 integrated source to expose
`p142ft_controls`: 24 rows. It depends only on selected existing definitions
(`f_fresh_defs`, `FFreshDefs`, `p140p_defs`,
`f_fresh_prefix_exact_defs`, `norm_defs_join`, `f_path_defs`, `p114st_row`,
`nt_choose`) and the ordinary Bool/U32/String/List operations.

After the proposed core module, append `direct-controls-v01.bend` too and expose
`p142ffd_controls`: 12 rows. Additional dependencies are `P142FFCache`,
`P142FFResult` and `p142ff_apply(book,start,cut,cache)`. All tested cache products
come from actual cold/warm core calls. These controls do not grant trust to
forged host objects or replace the producer/seed construction contract.

The composition tests compare entire `FFreshDefs`, including the final counter.
One manually constructed result checks the actual All/Lam/Var renumbering, in
addition to differential full-versus-split results. Nested constructor lists,
Let binders, quantities/presence, source spans and declaration flags are covered.
Path tests execute the original `f_path_defs` over Foreign/Path terms: changed
relative directories must invalidate while absolute paths remain unchanged.

`f_fresh_prefix_exact_terms` compares term variants, literal kind/number/text,
ids, quantities and explicit lambda-quantity presence, removed-name lists,
children/counts and both span coordinates. `f_fresh_prefix_exact_defs` compares
all plain source KDef fields and child-list structure, but uses accessor
projections and does not distinguish KIndexLeaf/KIndexNode from a plain KDef
manufactured with the same projections. The negative control demonstrates that
limit. The full result/guard comparator here is existing `p140p_defs`, which adds
the definition-variant check. Completed parser products should be plain KDef;
the stronger comparator avoids relying on that implicit domain restriction.

## Loader integration screen still required

Reuse the existing checked-API loader observer from
`phase140/parser/bridge-observe-v01.mjs`, with current producer pins and new core
hooks. Do not reproduce parsing or freshening in host code. Required sequence:

1. Seed Base once through `p88_cache_prepare`; retain the actual seed and source
   origin. Use `p140pl_reference` as the old complete loader oracle.
2. Cold-load a source with a completed prefix and a later edited function. Save
   only the real successful parser/completion/freshening capabilities.
3. Compare the entire warm loader product against a fresh oracle for no-op,
   changed suffix binder count, prefix edit, invalid suffix, then recovery.
   Compare error text and complete diagnostics; invalid completion must not
   publish a new freshening checkpoint or bypass original error handling.
4. On otherwise identical text, move the logical source path from
   `/a/main.bend` to `/b/main.bend`, keeping a relative foreign import in the
   retained prefix. The parser cache can hit while the freshening prefix guard
   must miss. Repeat with an absolute foreign path as the positive control.
5. Keep a law before the cut and its separate fill after the cut. Edit the fill
   body, then test changed imported-law context where supported. Count top-level
   declaration events, including separate laws/fills, not unique names or all
   nested constructor records.

Suggested invalid suffix: replace a valid `def main() -> U32: ...` after the cut
with `def main( -> U32:`. Preserve the same first `def` token so the test reaches
the completion/error gate rather than relying only on a parser-prefix miss.
Include UTF-16/non-BMP spans and the existing first-token operator-extension
negative. Exact full `FFreshDefs` equality must include changed final counters.

Full loader checks are deliberately separate from these finite IR controls:
constructing raw FResult errors by hand would not establish actual parser-cache
hit, error ordering or failure-recovery behavior.
