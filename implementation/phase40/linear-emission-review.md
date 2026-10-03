# Independent linear emission correction review

Static inspection during checked05 build; no compiler or target execution by
reviewer. [Identity record](linear-emission-review.json) binds inspected source
and both exact failed reports. This is a source review, not a passing successor
gate or universal soundness statement.

Checked04 actual list and Nat fixtures fail with `ReferenceError: $u2 is not
defined` in their generated make worker. Preserve
[list-actual-controls01](../../selfhost/build/phase40/list-actual-controls01/report.json)
and [tree-nat-controls04](../../selfhost/build/phase40/tree-nat-controls04/report.json)
as complete:false/pass:false. Checked bootstrap success and correct saved-JS
prototypes did not discharge these actual emitted-program gates.

Analysis environments record @child origin; lexical emission environments carry
ordinary names/types. Reusing analysis j_component_self during emission therefore
returned sentinel32 instead of the proven child argument position, producing
undeclared temporary references. The correction keeps analysis unchanged and
uses j_linear_emit_self/j_linear_emit_child only to recover the saturated self
shape in the already admitted immutable syntax.

The planner still requires one syntactic self reference, an exact saturated
self call with proper descendant first argument, complete pure dependency graph,
no mutual backedge, typed body and admissible scalar/owned boundary. Worker
declaration revalidates j_component_plan; callers still require an active proof
covering its entire graph. The weaker emission-only predicate is not an admission
route and is not called by the planner. On that scope, no admission weakening was
identified by inspection.

Arguments preceding the child are evaluated before descent and saved; arguments
after the child remain in the resumed expression. Frame restoration/rematching
uses inert private prefix reads. Only inert sequential aliases may be repeated.
Constructor resumes use the specialized field telescope and original tagged ctor;
known combiners retain generic callOwned fallback when finite emission is absent.
Direct tail transfer keeps the existing continuation stack. These obligations
still require actual before/child/after value/error/getter and alias/deep controls.

The emission finder assumes the same stripped AST and unique saturated self
shape that analysis proved; it does not return a proof witness. A future change
that transforms bodies between analysis and emission would need to revisit this
assumption. Sentinel32 must not become ordinary emitted code for a valid plan.
The immediate remaining check is checked05 actual list/Nat emission plus focused
linear-order witnesses, followed by the existing inherited owner gates.
