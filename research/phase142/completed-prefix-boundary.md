# What completed-prefix reuse would actually remove

Source-only follow-up on Phase141 integrated-source02 and the Phase142 hosted
freshening probe. No new implementation or target run in this note.

**Replacing only `f_graph_finish_indexed` misses an earlier full-prefix pass.**
On a parser hit, `p140p_resume_lexed` still executes
`f_context_result(fpe_finish_indexed(...,f_top(...)))`.
`f_context_result` calls `f_context_defs` across the entire parsed user book;
for successful ordinary definitions it recursively lowers every type using
`f_context_lower`. Bodies are retained there, but nested declarations and type
terms are visited again. This is inside the current `p140pl_parse` timer, before
`f_graph_finish_indexed` begins.

## Specific repeated work and the smallest earlier boundary

| Current function | Prefix work that a retained product could replace |
|---|---|
| `f_context_defs` / `f_context_lower` | Reconstruct definition wrappers and lower unchanged type terms. |
| `f_graph_fill_defs` | Traverse unchanged definitions/constructor lists and resolve imported-law fills from the fixed prior Base scope. |
| `f_context_modules` | Requalify unchanged declaration names. |
| `f_path_defs` | Rebuild unchanged definitions and resolve unchanged relative Foreign paths. |
| `f_graph_finish_module` → `fpe_defs` | Search the completed prefix for a first frontend error despite previous successful qualification. |
| `f_prefix_names_extend`, `f_prefix_ctors_extend` | Reinsert the complete old prefix into the same initial indexes. |
| `f_prefix_ready_validate` | Rewalk error/name validation over the complete user prefix. |
| `f_fresh_defs` | Rename/reconstruct the unchanged completed prefix (the current prototype addresses this last row). |

A coherent next experiment would retain the **actual successful completed and
freshened prefix at the parser cut**, then process only the newly parsed suffix
through those maps. Intercept after the resumed top parser returns raw events but
before its unconditional full-book `f_context_result`; a boundary introduced only
at `p140pl_parsed` is too late to remove type lowering.

This does not require a new universal IR or independent cache registry. It can
extend the same private seed/parser/freshening capability. The original raw
parser continuation still owns the authoritative cut. Cold preparation should
produce each retained product once, rather than recompute separate prefixes for
several caches.

## Why the completion maps can be separable

Their current readsets are favorable:

- `f_context_defs` is a per-definition transform of type terms, controlled by the
  whole parse's success flag. It does not consult a later declaration book.
- `f_graph_fill_defs` receives the same `imports` and `prior` for every element.
  In this one-source prepared-Base route, `prior` is the Base graph, not a growing
  user declaration book. `f_graph_fill_alias` consults that fixed scope only for
  imported-law fills. A later law fill is a new declaration event, not mutation
  of the earlier raw prefix.
- Module qualification depends on the fixed namespace. Foreign-path resolution
  depends on the logical source path/directory and native flag.
- The original parser hit already establishes unchanged source prefix, source
  origin, complete first resumed token and initial scope/aliases. Those facts
  are stronger than an edit offset or matching declaration names.

Therefore a private capability can justify unchanged completed prefix only when
those exact dependencies remain bound. A changed logical path must invalidate
relative Foreign results even when parser reuse succeeds. On parse/completion
failure, preserve the original whole-result/error route: `f_context_defs` treats
an unsuccessful parse differently, and old successful prefix output must not
silently replace its diagnostic input.

This is a source-derived feasibility argument. The current prototype deliberately
pays `p140p_defs` completed-prefix comparison. Removing that comparison requires
an explicit producer/continuation bridge and the existing independent whole-load
oracle, including imported law fills, relative paths, errors and recovery.

## Validation state must not be confused with parser scope

There are two name-validation passes with different inputs:

1. `f_graph_finish_indexed` checks parsed declaration names against Base names.
2. `f_prefix_ready_validate` checks the completed fragment against Base names.

Imported-law filling may change declaration names/kinds between them. The
existing parser scope is not automatically a certificate for either validation
pass. `f_graph_fresh_name` has an explicit ordered law→fill exception and checks
native flags; replacing it with generic unique-name membership would be wrong.

The first bounded completion experiment should leave these name checks intact,
or retain their actual successful ordered index state at the cut. Similarly,
only a previous successful, unchanged prefix can supply an "Absent first error"
summary. Error precedence and current suffix validation remain unchanged. These
are small existing fold states; avoid building a generalized fact engine merely
to store them.

## Work that remains after skipping completed prefix terms

- Current source loading, width/origin calculation, header/import admission and
  exact source-prefix comparison. Full-source submission is still authenticated;
  an edit hint alone is not authority.
- Parser-scope/initial-context admission and current suffix lexing/parsing.
- Whole prefix list reversals/joins in `f_result`, graph assembly and final load
  assembly, unless their representations change separately. Skipping term
  reconstruction does not remove those list-spine costs.
- Any original validation not explicitly given a reusable successful prefix state.
- Checker admission (`p140cp_admit` still checks full bounds/prefix/remaining
  headers), remaining suffix checking, driver-report work and ownership checks.
- Owner dependency analysis, annotation/erasure reuse and full request construction.
- Raw lowering, optimization, independent final verification and output/machine work.

A freshener's final `next` is not automatically a replacement for every
`norm_max_book` calculation: preserved unbound IDs and other term fields must be
covered by an exact invariant before removing those scans.

## What the measurements support

The coordinator's actual pre-fresh probe completed in17.21s, with all tested
full definitions, final counters and complete original loader products equal.
At the1,024-declaration compiler prefix (192,456 source bytes), full freshening
had median0.1018s; exact-guarded splice had median0.0345s. The no-comparison
ceiling was about0.00013s. Those numbers show both removable reconstruction and
the cost of re-establishing prefix identity.

However, its original whole-loader observation was0.6513s, and pre-fresh B
preparation was0.5934s in a separate ordered call. These cannot be summed or
subtracted as clean exclusive costs, but they clearly warn against treating
freshening alone as the complete parser/completion cost. Lexer/Map have early
cuts and tiny freshening costs, so they remain correctness/overhead screens.

The next high-information measurement is a subdivision of `p140pl_parse`,
contextual result lowering, indexed completion, ready validation and freshening
on the same late compiler-prefix workload. If completion and full-prefix type
lowering are substantial, retain their actual products together. If exact source
comparison, checker work or list assembly dominates, moving the cache earlier
without addressing that floor will not yield a large complete-build gain.
No native saving or route to10× is demonstrated by these hosted observations.
