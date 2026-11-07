# Consuming pattern substitution: a source-level architectural falsifier

Experimental source: `selfhost/tests/phase173/borrow-consuming-pattern01.bend`.
Replace only the executed workload's `f_pattern_sub` definition, keeping its
signature and the original `f_pattern_subs`, `f_pattern_value` and all compiler
and runtime code. The installed compiler and protected declarations are untouched.

The original nonmatching path retains `t` while computing
`f_pattern_subs(ks(t),id,value)`, then passes both parent and new children to
`k_with_children`. An owned result from `ks(t)` coexists with the parent-owned
old list. That can create genuine shared child credits throughout recursion,
even when the input root had no external alias.

The candidate destructures each parent first and sends its owned child list
through the same recursion. It rebuilds the complete parent afterward. This
does not reuse the parent allocation, but can eliminate accessor work, retained
parent credits, and additional child sharing without a new runtime ABI, custom
memory operation or call-summary machinery. Existing shared inputs must remain
shared correctly; the ordinary Bend ownership lowering supplies that behavior.

## Extensional equivalence argument

This is an equational argument over finite KTerm values, not a BendTT proof.
The independent executable oracle remains the unchanged source under upstream.

* `KTerm`: `tg(t)` is its actual tag and `ix(t)` its actual ID. If and only if
  tag is `"Var"` and ID matches, both versions return
  `f_pattern_value(value,begin,end)`. A matching Var's children are deliberately
  not traversed, including arbitrary valid compiler-data children. Otherwise
  `ks(t)` is exactly the matched child list; `k_with_children` reconstructs
  exactly the eight fields emitted by the candidate. Apply induction to the
  original `f_pattern_subs` child traversal. Unknown tags and KTerm-tagged
  `"Lam"` remain KTerm values; no normalization is introduced.
* `KLambda`: the original `tg(t)` is always `"Lam"`, independently of the binder
  name or ID. It never performs replacement at the binder itself. Both versions
  recurse through the same children and retain name, ID, quantity, removed
  notes, both origins, and `quantityPresent` exactly.
* `KLiteral`: the original `tg(t)` is always `"Lit"` and `ks(t)` is empty.
  `f_pattern_subs([])` returns empty and `k_with_children(t,[])` returns `t`.
  The candidate returns that same value. Arbitrary literal kind strings,
  including `"Var"`, cannot turn it into a substitution site.

The matched-origin rules, including begin0 and preexisting replacement origins,
remain entirely in unchanged `f_pattern_value`. Replacement values are not
recursively substituted again. Source quantities, constructors and return type
are unchanged; the candidate obtains no stronger uniqueness assumption.

The transformation changes allocation/destruction timing and may change which
runtime fast paths are profitable. Those are measured consequences, not semantic
equivalence claims about pointer identity or allocation exhaustion. KTerm carries
immutable compiler data, and these functions perform no IO or user callback.
The ordinary backend still owns recursion/continuation lowering. Inspect actual
generated code and retain a deep-input gate before broad qualification.

## Bounded comparison

1. Freeze the original extracted workload and independent upstream complete
   output. Build the candidate source by one exact named-definition replacement.
   Use the **same compiler producer/runtime/toolchain** for both source variants.
   Changing only the compiler-host API would not change a function whose old
   source is still supplied as the generated workload.
2. Run existing small unique/shared/present/absent controls, plus
   `borrow-consuming-controls01.bend` and its main. The extra complete-value
   cases cover arbitrary literal kinds, matching and nonmatching Var with kids,
   legacy KTerm Lam, both KLambda quantity-presence states, origins, notes and
   unknown tags. Compare complete results to unchanged upstream, not hashes.
3. Run the existing eight-iteration varied-seed pattern digest with independently
   upstream-checked scalar output. Record clean complete runtime separately from
   runtime counters, and compare source/acquisition/IR size as costs.
4. Inspect whether allocation/take/keep/sink counts decrease across the complete
   traversal. The compiler may still reconstruct matched literal returns or
   preserve temporary owners; source spelling alone does not demonstrate removal.
5. If beneficial, test an actual captured compiler-body corpus and deep inputs.
   A broad compiler build is warranted only after this general traversal passes
   those cheaper transfer gates. Neutral or worse performance is useful evidence
   against retained-parent sharing as the dominant cost for this workload.

This source experiment is independent of wide05 profitability and borrow04
emission. First isolate it; combine only if individually measured effects justify
the extra comparison. No target was run by the author of this note.

## Root-owned observed result and backend transfer

The complete-value gate passed. The eight-iteration digest comparison measured
103.032→82.282ms over four balanced process pairs, ratio0.798605, with exact
independent output (`consuming-pattern-digest-pair01/report.json`). The previous
borrow04 comparison on the original pattern traversal was neutral:
115.695→116.178ms. These comparisons have separate acquisitions/measurement
blocks; do not subtract their medians across blocks to infer composition gains.

The authenticated event pair demonstrates the main finding: allocation requests
were essentially unchanged (1,386,511→1,386,503), while keeps fell27.8%, sinks62.8%,
drop entries90.7%, constructor takes9.7% and dispatcher entries10.8%. Frame pushes
were identical. The speed gain comes with less ownership/transport work despite
almost no allocation-count improvement. Event capture costs are diagnostic;
the clean paired measurements above supply the performance result.

The next bounded transfer is actual `nq_layout_subst` from
`back/native/product-layout.bend`. It appears in the measured raw-candidate and
fallback contexts and reconstructs syntax through `k_rebuild` after many getters.
`borrow-consuming-layout01.bend` preserves its original entire Var branch and
changes only the non-Var path to consuming field decomposition. This distinction
matters: unlike `f_pattern_sub`, a **nonmatching Var with children must return
unchanged**, without descending into those children. The forward law is in
`borrow-consuming-layout-prelude01.bend`; the original recursive list helper
is unchanged. KTerm/KLambda fields and literal returns are preserved, and no
`core_rebuild` or beta reduction is introduced.

The new layout full-value controls explicitly cover that Var distinction,
arbitrary literal kinds, both lambda representations, quantity presence, origins,
notes, unknown tags, replacement aliases and shared original input. A separate
eight-iteration digest uses the same complete-field observer. These transfer
files have not been target-executed by their author and make no new performance
claim. `f_context_material_children` remains a possible later application, but
its deferred Lam/All/Let children, error short-circuiting and beta reduction make
it a larger semantic change than this exact backend analogue.
