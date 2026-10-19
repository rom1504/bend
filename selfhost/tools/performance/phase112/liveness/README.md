# Phase112 backwards suffix liveness

Hypothesis: repeated `nc_uses` of shrinking let continuations makes long
sequences quadratic in term visits. Reusing each complete suffix set through
let lowering should preserve exact QBE while reducing lowering work beyond the
duplicate-analysis reuse in `../uses.bend`.

`continuation.bend` is an isolated source-composition candidate against frozen
Phase111 `full-source05`. It adds a separate continuation datatype and overrides
only `p111_lower` and `p111_lets`. It neither changes KTerm fields nor adds a
global cache. `p112_liveness_terms` scans each binding head once backwards and
shares mature `NU_Set` tries between suffixes. The sets retain the actual
`nc_uses` contract: every Var occurrence counts, including occurrences beneath
binders; binder identifiers are never subtracted.

Constructor and primitive argument normalization constructs equivalent
continuation nodes while retaining the existing suffix. This avoids losing the
analysis when `nd_bind_value` would create extra nested lets. Argument order,
fresh IDs, segment construction, body-before-value lowering, environment order,
keep/drop placement and error precedence follow the original helpers. Nested
terminal Let/NSeqLet wrappers are flattened in the analysis only; duplicate
partitions of the same already-live environment emit no additional operations.

Expected work is one term traversal per original binding plus persistent set
insertions (at most 32 trie levels per key), rather than one traversal for every
suffix. Nested lets inside binding values still undergo their own analysis when
lowered. Environment filtering, generated segment-list appends and other passes
retain their existing complexity. Sharing all suffix roots introduces retained
set nodes and must be checked for real memory cost.

## Qualification handoff

No target execution, timing or correctness result is claimed by this directory.
Root owns serial CPU3 target jobs. Compose with the existing `prepare.py`:

```
python3 selfhost/tools/performance/phase112/prepare.py \
  --out selfhost/build/phase112/liveness-source01 \
  --module selfhost/tools/performance/phase112/liveness/continuation.bend
```

Use the existing checked full-source API workflow. Compare exact QBE and isolated
lowering using `../compare-lowering.mjs`, first on the 64/128/256 chains under
`../uses`, then on constructor, primitive, duplication/discard, nested-let,
non-tail call, closure and match cases and the frozen five-source loop. Compare
against both frozen Phase111 and the simpler `uses.bend` candidate. Algorithm-only
qualification requires complete QBE identity; source inspection is not evidence
of that result. Full native acquisition follows only a useful smaller result.

Potential counterexamples to inspect: malformed raw binding heads with extra
children, zero/singleton sequences, a terminal nested Let, and generated native
argument sequences where bound IDs also occur in the later continuation.

`controls.mjs BASE_API CANDIDATE_API FRESH_OUTPUT` supplies finite raw-term
controls for these boundaries. It compares complete `P111Code` (including fresh
IDs, error and segment order), and compares mature/candidate occurrence sets
with an independent all-Var oracle. The candidate API must export `p111_lower`,
`p112_liveness_term`, `p112_liveness_uses`, `p112_liveness_args` and `nu_has`;
the baseline must export `p111_lower`, `nc_uses` and `nu_has`. These controls are
additional semantic checks and do not replace source-to-QBE qualification.
