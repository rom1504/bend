# Reuse the mature literal-combinator plan

This optional candidate removes known closure construction/application work
before structured lowering. It reuses `nd_comb_try`, `nd_comb_closed`,
`nd_comb_linear`, `nd_comb_fresh`, `nd_comb_rename` and `nd_comb_fill` from the
selected mature compiler. It does not interpret C output or recognize a
particular user function name.

Admission requires a non-bang reference to a checked user definition, a complete
leading live-lambda telescope of one through eight parameters, one through that
many actual arguments, and at least one literal lambda actual. The mature plan
then requires a closed App/Var body, exactly one use of every formal, bounded
syntax depth and no fresh-ID collisions. Native/foreign/missing/dynamic heads,
overapplications, repeated/discarded formals, arbitrary callee bodies and
overflowing fresh counters retain the prior route.

The mature partial-call path already uses this semantic plan. Here the same
closed-linear plan also accepts the saturated case: each formal is replaced
once, and nonliteral actuals remain ordered outer lets. Literal lambdas are
values whose captured ownership is handled by the existing lowerer after
substitution. Partial applications still create the necessary residual closure;
unknown escaping closures still use the generic ABI. Neither native recursion
nor stack-depth admission changes.

The concrete existing witness is the recursively constructed closure chain.
Its `compose(f,g,x) = g(f(x))` body satisfies the gate, and one actual is the
literal addition closure. The residual closure can capture the addition's
scalar plus the dynamically computed `g`, perform the addition directly, and
apply `g` once. The generic compose factory and intermediate application of the
literal addition closure are unnecessary. Dynamic closure calls that remain
unknown still dispatch normally.

Composition order is `plan.bend`, `generic.bend`, `direct.bend`,
`products.bend`, optionally `controls.bend`, after the corresponding selected
selector modules. Apply the three `overrides-*.bend` files after those selector
hooks. Their fallback calls are the unchanged `p112b_ref_app`,
`p113db_ref_app` and `p113pb_ref_app`. A scalar-only profile omits the product
module/override. Export `p113_closure_control_report` for 18 reflected controls
and `p113dc_plan` for untimed diagnostics.

`manifest01.json` pins two independent actual source fixtures: complete values
including a shared captured String, residual closures and unknown partials;
and a strict nonliteral Nat overflow that must fail before a literal body can
discard the argument. It also pins the existing dynamic closure benchmark and
its complete-value oracle. These fixtures are prepared, not executed.

Source admission must bind the complete selected `nd_comb_*` semantic helper
closure, `nc_erase`, live-arity/leading-lambda queries, the checked frontend,
the three prior selector routes, and normal ownership lowering. Raw KTerms and
reflected definition records are not source certificates. The public entry
constructs this plan from its checked request.

Cheap gates are: all reflected controls; both actual fixtures; existing
closure-chain output; fewer compose factory/application sites along the chain
route while a residual owning closure remains; then matched native timing.
Global static helper totals include unreachable fallback segments, so inspect
the reachable chain bodies as well as totals. No speed gain is claimed before
that gate. Preparation ran only source inspection and delimiter checks.
