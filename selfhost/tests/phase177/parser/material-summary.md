# Phase177 materializer: preserve the higher-pass completion fact

Unexecuted source overlay. Replace exactly `f_context_materialize` and
`f_context_material_children` using `material-summary-prelude.bend` and
`material-summary.bend`. No maintained source, image or runtime changes.

The real materializer evaluates `lower(higher(term))`. The higher walk visits
every eager child, while deferring all Lambda children, All children after the
first, and the final Let child. Lower then revisits every eager subtree, even
when higher has already fully resolved it. Phase173's neutral consuming-shell
experiment changed retention but retained both complete traversals. This
candidate tests actual redundant lower work instead.

The private result `P177CMaterial{term,pending}` is produced by a copy of the
existing higher traversal. `pending=False` proves `lower(term)=term`:

- A stopping Error is already a lower fixed point.
- FName delegates to the same span-adjusted selected child.
- An unresolved operator produces the same stopping Error.
- An untouched deferred child conservatively sets pending true.
- An eager child contributes its recursively computed pending bit.
- With no pending children, lower can only reconstruct an identical parent.
- App/Lambda beta reduction restarts the summary on the actual substituted
  result; discarded terms cannot leave stale facts behind.

`p177cm_finish` retains the original lower pass whenever pending is true. When
lower reaches a deferred child, it invokes the summarized materialize entry
instead of `lower(higher(child))`. This reaches the actual bodies beneath the
outer parameter lambdas; a root-only shortcut would rarely apply to functions.
The public standalone higher/lower contracts and malformed partial child-loop
states remain supported. No fact is inferred from a user-controlled KTerm tag,
stored in a generic metadata field, or guessed from the absence of one tag.

Higher still finishes before lower starts for each demanded region. This order
is semantic: in App(Lam(error-A), error-B), eager error-B wins. Beta reduction
can also discard an argument containing a deferred error. Eagerly fusing all
children into one bottom-up walk would change those results.

## Exact bounded validation API

Common baseline/candidate modules:

- `material-controls.bend`
- `selfhost/tests/phase173/borrow-context-workload01.bend`

Common exports:

```text
f_context_higher
f_context_lower
f_context_materialize
f_context_material_children
p177cc_cases
p177cc_priority_actual
p177cc_priority_expected
p173cmw_result
```

The candidate additionally exports `p177cm_higher` to expose the actual private
producer result. Prepare with Phase176's maintained-source extractor; acquire
both independently checked hosted APIs. Run `material-controls.mjs` with
`--baseline`, `--candidate`, and a fresh `--out` under the root-owned guard.

The 290 observations comprise 26 producer-fact checks, 78 complete direct
transform results, 180 arbitrary public partial-child-loop states, and six
complete workload/literal checks. Every producer result must equal unchanged
checked higher. Every false bit additionally requires unchanged checked lower
to return exactly that same complete term. Six real loader inputs come from
the retained Phase173 control module, including imports and expected failures.
Retained input aliases are compared after evaluation.

## Limits and decision gate

This minimal design retains one Bool result per higher computation. It does
not retain a parallel annotated tree. When a region reports pending true,
lower still revisits its eager children; only wholly completed regions skip
that work. Application-heavy expressions with many anonymous functions may
therefore benefit less than binder-free regions. Summary allocation and extra
helper calls can outweigh avoided visits. No private-worker benefit is assumed.

The retained profile has 54/921 `f_context_material_children` and 15/921
`f_context_material_done` active contexts, not inclusive costs. It supports
testing this family but supplies no removable-seconds estimate. Require the
complete-value gate, then compare actual real parse/load. A fall in calls or a
successful fact check is not a speed result. Keep the independent freshening
candidate separate; do not acquire a full compiler from this overlay alone.
