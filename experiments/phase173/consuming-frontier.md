# Where early consuming decomposition can transfer

Read-only audit at `5a6baaa`, 2026-11-07. No target executions or implementation
changes. [The census](consuming-frontier-census.json) records the source screen
and exact retained profile identity. The Phase173 pattern/layout gains motivate
this investigation; they are not transferred to the full compiler as estimates.

**Prioritize the contextual materializer, then the native compaction/erasure
walkers.** They retain the original parent across recursive child rewriting,
and retained profiles observe them in real full-compilation stages. The tiny
`f_sub` analogue is the cheapest extra source experiment. Do not apply the same
story to the hot `subst_node`: it already decomposes the parent before recursion.

## Ranked candidates

| Priority | Actual source path | Lifetime mismatch | Retained evidence and limit |
|---|---|---|---|
| 1 | `front/literals_arrays.bend`: `f_context_higher/lower`, `f_context_material_children/next/done` | Both entry functions pass `term` and `ks(term)`. The original parent persists across every recursive child, deferred branch and accumulator update, until `k_with_children` reconstructs it. | Latest full caller capture: material-children has 51/952 active-context samples in the 30.522s parse/load region, material-done another 12. This is an observed hot computation, but dispatch context is not an inclusive stack; 30.522s is the entire loader envelope, not removable cost. |
| 2 | `back/native/bridge.bend`: `nc_compact_plain`, `nc_compact_ctor` | General paths invoke `k_rebuild(t, nm(t), ix(t), qt(t), nc_compact_list(ks(t)), ...)`. The whole parent outlives the recursive result, including old children. | Static-preparation region is 4.219s: active contexts plain 12, compact 4, list 3, ctor 2 out of 130 samples. Descriptive only; fewer than the 500-sample admission threshold. Other invocation regions may exist, so this is not a global helper-time bound. |
| 3 | `back/native/erase.bend`: `nc_erase`, `nc_erase_app` | General non-erased branches similarly retain parent plus extracted getters while `nc_erase_list(book, ks(t))` runs. | Erasure/request-preparation region is 5.923s: erase 12, annotated 12, app 4 out of 183 active contexts. The annotated helper is context evidence, not itself an identical rewrite. No inclusive function cost is known. |
| 4 | `front/elaborate.bend`: `f_sub` | Almost the exact tested `f_pattern_sub` fallback: `k_with_children(t, f_subs(ks(t), id, v))`. | Very cheap source-level transfer, but no direct physical sample or retained top-context entry establishes a material full-build contribution. Preserve its distinct replacement-origin rule. |
| 5 | `check/env-substitution.bend`: `env_subst_term` | Non-Var/nonliteral branch uses `k_with_children(t, env_subst_terms(ks(t), bindings))`. | Real checker functionality, source-only opportunity in this audit. Zero observed direct-frame samples is not proof of zero execution. Preserve ordered dependent bindings and the empty-binding fast return. |
| 6 | `check/specialize.bend`: `sp_shift`; `load/paths.bend`: `f_path_term`; `back/native/word-pattern.bend`: `nw_restore_children` | Each extracts parent fields, recursively transforms `ks(t)`, then calls `k_rebuild`. | Exact structural analogues, unquantified runtime contribution. Preserve tag-specific ID changes, path/name changes and word-pattern replacement semantics respectively. |
| Larger follow-up | `front/fresh_work.bend`: `ffw_walk_existing`, `ffw_kids`, `ffw_frame` | `FFKids{term, env, rest, built}`, `FFAllA/FFAllB` and `FFLambda` retain original parents while transformed children accumulate. | Real source and actual frame symbols occur, but only three direct/nearest frame samples were recovered across the named walker/frame family. Requires a frame/interface change; do not replace its explicit bounded-stack worklist with recursive native calls. |

The already demonstrated `nq_layout_subst` is independently observed in raw
candidate production (31/764 active contexts in 24.501s) and demanded fallback
(17/269 in 8.688s). This strengthens relevance, not a runtime estimate: those
windows contain many other functions. The earlier independent 5,584-sample
capture saw 45 whole-capture layout contexts and 39 pattern contexts; keep those
separate from the later 5,429-sample capture used above.

## Count and false positives

A reproducible lexical screen across maintained `selfhost/src/**/*.bend`
finds **36 functions** containing both a `k_with_children`/`k_rebuild` call and
a `ks` call, **19 outside JS backend modules**. Manual inspection identifies
**11 direct recursive child-rebuild functions** outside JS: `sp_shift`,
`env_subst_term`, `f_sub`, `f_pattern_sub`, `f_path_term`, `nw_restore_children`,
`nc_erase_app`, `nc_erase`, `nq_layout_subst`, `nc_compact_ctor`,
`nc_compact_plain`. Two are the already tested pattern/layout functions, leaving
nine additional syntactic sites. These are sites, not nine independent hot
workloads. The materializer and freshener are additional multi-function cases
that the single-body screen misses.

The other hits include leaf field changes, list-head insertion, partial-child
rewrites and consuming an independently computed checker result. A lexical hit
does not prove the parent remains live through expensive recursion. JS modules
cannot be counted as executed QBE compilation work merely because their source
is present in the compiler executable.

Important exclusions:

- `core/term.bend:451` **`subst_node` already matches KTerm/KLambda and recurses
  directly on the bound `kids` field**. Its 65 active contexts in the earlier
  full profile make it hot, but not an unimplemented instance of this change.
  Its KTerm leaf fast return and `core_rebuild` beta reduction also differ from
  the two tested substitutions.
- `nc_uses_term` is a getter-driven observer that returns a use set and does not
  reconstruct its parent. Its large context count cannot be assigned to this
  particular retained-parent mechanism.
- General `k_rebuild`/`ks` physical counts cannot be attributed to their source
  callers from one recovered frame. The later capture observes 39 samples in
  `ks`/its immediate callees, 7 for `k_rebuild` and 5 for `k_with_children`; these
  are not the inclusive cost or benefit ceiling of eliminating a composition.

## Why no reliable whole-build gain forecast follows yet

The profile's exact nearest-generated-frame counts are small for these walkers
(materializer family 10, layout family 9, compaction family 3, erasure family 2,
pattern family 3). Most of their work can occur below runtime intermediaries or
in continuation bodies whose source ancestry is unresolved. Conversely, active
dispatch contexts can persist across direct calls. Neither observation supplies
an inclusive cost, and they must not be added together.

The parse/load interval is a useful generous ceiling **for an optimization
restricted to parsing**. The compaction/erasure intervals are primary observed
contexts, not independently proven global call boundaries. Applying a measured
20% traversal improvement to every second in those intervals would be an
unsupported forecast. The earlier profile's 25.5% lifetime/reclamation share
likewise includes necessary ownership work unrelated to retained parents.

The key result from the new experiment is narrower and valuable: allocation
counts did not predict runtime; keeping a dead parent can create shared child
credits that make an otherwise ordinary recursive rewrite substantially more
expensive. It is a compiler programming-practice problem as well as a possible
optimizer transformation. We do not need a new runtime ABI to test the next
instances.

## Cheapest next decisive steps

1. For near-term additional transfer, make the exact `f_sub` decomposition and
   one `nc_compact_plain/ctor` variant in experimental source. Preserve every
   KTerm/KLambda/KLiteral field and arbitrary valid compiler-data behavior.
   Compare unchanged complete results, same producer/runtime, actual captured
   compiler bodies and all cleanup costs. Do not build a complete compiler just
   to discover admission or synthetic-tree throughput.
2. For the highest measured remaining candidate, carry the materializer's
   **parent metadata without its original child list** through the existing
   child loop. Retain deferred Lam/All/Let behavior, first-error ordering, empty
   child identity, higher/lower phase distinction and beta reduction. Avoid
   merely storing the original parent inside a newly named shell record.
   Measure the complete real loader, not only a selected child walker.
3. If the automatic decomposition pass proves useful, broaden its semantic
   scope deliberately: the current prototype refuses File/IO requests and
   eight-argument setters, so it cannot yet deliver the full compiler or the
   observed `nq_layout_subst` transfer. Manual source rewrites and a generalized
   compiler pass answer different cost questions. Preserve that distinction.

No large full-build or 100s claim is warranted until these changes affect the
actual complete request under matched acquisition and generated-code gates.
