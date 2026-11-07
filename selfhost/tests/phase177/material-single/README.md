# Phase177 materialization in one owner

Source-only candidate; no compiler or benchmark runs were launched by this
subtask. Root owns source checking, controls, native admission and measurements.
This does not edit `parser/material-summary.bend` or maintained compiler source.

Root's first source check rejected a helper that matched its second parameter
before its first. `single-rejected-v1.bend` preserves that source. The active
candidate orders the helper parameters in its actual match order; no source
success is claimed here.

Exact override: `f_context_materialize` only. Add `prelude.bend` and `single.bend`
with the existing Phase176 source transport. The original public
`f_context_higher`, `f_context_lower`, `f_context_material_children`,
`f_context_material_next` and `f_context_material_done` remain unchanged. The
new entry law is a forward type declaration, not a mathematical proof.

## Mechanism

The parser agent's summary reports `(completed higher term, pending deferred
work)` and omits lower when pending is false. This variant transports that pair
in `p177ms_loop` arguments. There is no result constructor per visited child.
Node frames retain parent state, and a Finish frame represents exactly one
`lower(higher(term))` boundary. Both passes and all nested demanded boundaries
stay in the same recursive owner. The original `f_sub` operation used by
`f_scope_app_span` remains unchanged.

State 0 enters the active pass, 4 detaches children into an empty shell, 5 scans
children, 6 completes a parent, 7 skips a deferred higher child, 8 visits an
ordinary child, 9 starts a demanded higher/lower region, 10 restarts higher after
beta, and 11 returns the completed term plus pending bit. States 1 and 3 return
the existing or newly produced stopping error.

The work-removal claim is narrow: a completed region with no deferred descendants
does not take a lower traversal. The execution hypothesis is separate: a single
recursive owner may gain private-worker admission and avoid generic recursive
continuations. Frames, empty shells, control transitions and child-list reversal
still cost work. Neither benefit is established until measured.

## Ordering and summary invariants

- A higher Node frame keeps the OR of already completed eager-child summaries.
  Skipping any deferred child sets it true without visiting that child.
- The existing deferred predicate is reused on the shell, untouched sibling
  tail and built prefix. It defers all Lam children, All children after the
  first, and the final Let child, including unusual arities.
- A Finish frame starts lower only after the entire demanded higher region
  returns. With pending false, lower is the identity and the term returns.
- Lower ordinary children enter lower directly. A lower deferred child pushes
  Finish and starts higher before its own conditional lower traversal.
- Parent frames restore their original pass and pending aggregate. A child's
  result cannot overwrite an earlier sibling's pending bit.
- Higher App/Lam completion restarts higher on the actual `f_scope_app_span`
  output with pending false. Summaries for discarded arguments do not survive.
- Any evaluated Error may return directly from the whole machine: all original
  enclosing higher, lower, child-next and finish paths propagate that exact
  Error. This does not evaluate errors in skipped or beta-discarded children.

Thus `App(Lam(error-A),error-B)` still returns eager error-B, while
`App(Lam(const),Lam(error-A))` still returns const. This is ordered high/low
materialization with selective omission of identity work, not eager lowering
of every child.

All original KTerm fields, KLambda quantity presence and KLiteral payloads
survive reconstruction. Empty nodes return their original value. FName still
selects child 1 with the outer span; literal `kind` strings do not affect tags.
Non-beta Apps retain their original metadata and arity, as the materializer
requires; the core substitution canonicalization rule is not applied here.

## Proposed finite gate

Common baseline/candidate modules:

```
selfhost/tests/phase177/parser/material-controls.bend
selfhost/tests/phase177/material-single/controls.bend
selfhost/tests/phase173/borrow-context-workload01.bend
```

Common exports:

```
f_context_higher
f_context_lower
f_context_materialize
f_context_material_children
p177cc_cases
p177cc_priority_actual
p177cc_priority_expected
p177msc_cases
p177msc_actual
p177msc_expected
p173cmw_result
```

`values.mjs --baseline REPORT --candidate REPORT --out FRESH` proposes 287
complete-value observations: seven baseline/candidate exported results, four
literal expectation comparisons, three public transformations on 32 cases, and
180 unchanged public partial-child states. Every direct case preserves an input
alias. The complete loader result includes six real inputs with imports and
expected failures. These are proposed controls, not claimed passes.

The six new literal cases target parent-summary restoration, parent-pass
restoration, nested eager error precedence, All/Let lower ordering and a beta
argument containing both eager-nested and directly deferred errors.

After source/value checks, inspect actual `p177ms_loop` private admission before
larger native acquisition. Compare complete real parsing/frontend requests on
the same source and image producer. Active-context samples are not inclusive
cost bounds, and reduced traversal counts alone do not establish a speedup.
