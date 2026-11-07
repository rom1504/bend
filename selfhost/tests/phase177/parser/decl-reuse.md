# Phase177 exact declaration lookup reuse

Source-only overlay; no target has been run by its author. Replace exactly
`p140p_def_header` using `decl-reuse-prelude.bend` and `decl-reuse.bend`.
The original lookup and continuation functions remain unchanged. Six private
continuation copies carry the actual raw local `KDef`, resolved once through
the original `f_decl_local`. They also retain the original local-or-prior
result where needed. No index hit is assumed to be a local declaration.

## Removed work and why it is legal

A local forward-law fill normally looks up its identical raw declaration six
times: header resolution once; bare signature selection twice; signature
construction once; and template-count publication twice. `book`, `name`, and
the explicit outer `scope` do not change until final publication. Parsing the
parameters/body changes their `FInput` contexts, but the original continuation
calls still query that same outside book/scope. Carrying the actual result
therefore removes five list scans without adding an admission assumption.

The private `p177dr_taken` uses the captured local result and the exact original
two scope-index observations. `p177dr_base` reuses the captured combined result
instead of calling `f_decl_find` again on imported-law fallback. Foreign-body
parsing and final publication remain original functions. All alias ambiguity,
duplicate, template, parameter, missing-type, and body diagnostics stay in their
original sequence. The captured local is retained through ordinary ownership;
this may keep a small earlier declaration alive for longer, but does not retain
a new book version or alter external aliases.

Existing scope indexes cannot simply replace `f_decl_local`: `f_context_header`
clears bodies to Absent and qualifies names, and scope indexes also contain
prior/imported declarations. A header hit would misclassify filled definitions
and could return an imported row as a local row. This candidate avoids that
semantic boundary entirely, including deliberately inconsistent direct API
book/scope arguments.

## Static selection evidence, not measured runtime

A lexical census of the frozen Phase175 canonical source finds 7,385 defs, 698
laws and 378 types. The 698 local law/def pairs span a summed 999,190 prior
declaration rows. A six-query model therefore visits about 5,995,140 rows;
the one-query path removes roughly 4,995,950 modeled row visits. This is a
source-derived workload model, not a dynamic counter or seconds forecast.
The latest retained profile names `f_decl_local` in 24/921 parse contexts.

By comparison, 554 constructor rows induce about 2,175,709 modeled prior
book/constructor visits. An indexed constructor shortcut could remove them,
but needs a private coherent-publication invariant. New declaration misses
already use the existing index to avoid raw list scans; there are not 8,461
full scans simply because the source has that many top-level events.

## Exact validation API

Both variants include `decl-reuse-controls.bend` and export:

```text
p177dc_sources
p177dc_load
p177dc_imports
p177dc_books
p177dc_scopes
p177dc_headers
p177dc_direct
```

Prepare through the Phase176 maintained-source extractor. Candidate adds the
prelude/module and `--replace p140p_def_header`. Independently source-check both
hosted APIs, then run `decl-reuse-controls.mjs --baseline BASELINE_REPORT
--candidate CANDIDATE_REPORT --out FRESH_BUILD_OUTPUT` under root's guard.

The 565 full observations include 20 loader sources and eight imported-module
results, local/imported fills, template quantities, duplicate/shadow cases,
malformed signatures and bodies, foreign/unsafe headers, retained aliases, and
540 direct-header combinations over six books, five coherent/incoherent scopes,
nine source headers and two cut positions. The complete `P140PStop` result
includes cut-state contexts and raw declaration order. No hash substitutes for
these comparisons. Complete real parser/source comparisons remain the transfer
gate before any whole-compiler acquisition.
