# P5-005 — Conservative diagnostic application anchors

- Owner: lexer-analysis; root reviews any promotion.
- Started: 2026-09-22, Phase5. Initial bounded falsifier, no performance claim.
- Correctness: selected gates pass; decision: REJECT the tested overlay for repeated rejection-path work.
- Scope: rejection-only diagnostic origins; no KTerm/Book ABI, parser, scoper,
  kernel, normalizer, freshener, emitter or accepted-program changes.

## Why not store positions in App.id?

`core_rebuild`/`core_apply` canonicalize App metadata. `core_subst_stable` requires
id0 on canonical Apps, so using that field for positions would disable the
accepted telescope fast path. `norm_exact`, `exact_term`, `term_key` and
`norm_max_walk` also observe ids. Freshening preserves an ordinary App's id, but
that alone does not establish an operationally inert position field.

Naively using a leftmost Ref's token as every App ancestor's origin is unsafe.
`(x => x)(f)(bad)` can leave a Ref obtained from an argument as the application
head. `(x => x)(f(1))(bad)` defeats a mere following-parenthesis check. A literal
argument on another line lacks a leaf origin, so an unconditional head anchor
can add the wrong source excerpt. A substituted argument in `(x => f(x))(bad)`
also defeats an arity-only check. These are explicit falsifiers, not edge cases
to waive to obtain a lower difference count.

## Narrow candidate and stop condition

Reuse the existing lexer/parser/scoper, rather than implementing a source parser:
find an App's retained Ref head token in its owning source; parse that actual
call suffix with `f_expr(tokens,13)`; reconstruct it with existing
`f_scope(parsed,Nil{},Nil{})`; require `norm_exact` with the unchanged App. Require
the source expression to remain on one physical line and the head token's name
to match. Unknown, variable-headed, substituted, qualified or unsupported forms
must omit the new origin whenever this equality cannot establish the relation.
No changes to `dg_origin_scan` or its ambiguity refusal are allowed.

The reported span is the actual head token anchor, not an invented complete App
span. The current snippet renderer uses its starting line. Existing origins keep
their precedence. Reject the route if exact prior diagnostics regress, an anchor
crosses a definition/module boundary, or implementation grows into new parsing/
scoping/provenance machinery. A small useful subset is sufficient; full location
coverage would require a separate provenance design.

## Planned correctness gate

- Named simple/multiple arguments, repeated heads and nested calls.
- Single-line and multiline literals; type and non-function application errors.
- Both beta/substitution counterexamples above, including differing source lines.
- Bound variable heads, imports/aliases, imported errors and multiline wrappers.
- Unicode/non-BMP before calls, missing positions and ambiguous exact terms.
- Original checked B1, checked overlay and live pinned TypeScript observations;
  preserve exact diagnostics, statuses/phases/checked flags and all failures.
- Sample retained missing-excerpt cases only after counterexamples pass; preserve
  all existing exact diagnostic passes. No claim that 147 cases are repairable.

No compiler jobs during root's reserved broad validation window. CPU2 correctness
only after explicit release, Node24 with4MiB stack/4GiB heap. Source ownership is
only an isolated copy of `src/diagnostic/frontend.bend`; root alone integrates.

## Outcome — 2026-09-22

The genuine checked overlay passed 18 custom cases plus four scope/long-spine
controls. Across 147 missing-excerpt and 82 previously exact negative-check
fixtures, four diagnostics became exact, 143 were unchanged, and all 82 prior
exacts stayed unchanged. There were no changed mismatches or acceptance/phase
changes. The standard harness retains its failing fixture verdicts for the 143
remaining diagnostic mismatches.

The ordinary 128-argument rejection observation increased from 2.855 s / 402,104
KiB to 4.845 s / 406,852 KiB. This is an unpaired observation during concurrent
correctness work, not a benchmark claim. Together with repeated per-prefix
parsing/scoping it falsifies this implementation's cost tradeoff for four
upstream repairs. No promotion, parent-App shortcut, arbitrary token budget or
production mutation followed.

[Detailed report and retained evidence](../../implementation/phase5/application-origins.md).
A parse-once-per-token provenance index is a separate, unimplemented follow-on.
