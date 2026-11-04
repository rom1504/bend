# Phase156: actual flat-binding use-set sharing

Prepared against maintained commit `209f2df`. This is the actual-declaration
transfer of Phase155 ID15, whose constructed keep/live kernel measured 0.569×
new/old. That number is not a prediction for compiler requests. At preparation
time no targets were executed. The completed [Phase156 report](../../../implementation/phase156/README.md)
now records source checking, controls, acquisition and actual requests. No
production edit was made; balanced Map requests are neutral (1.00130×).

The exact [overlay](../../../selfhost/tests/phase156/uses.bend) replaces only
`p113pl_bind_flat` in `selfhost/src/back/qbe/flat-products.bend`. The production
proposed delta is **one added code line, zero new declarations/types**. It binds `uses`
once after lowering the original value, supplies it to the unchanged `p111_keep`,
and replaces `nc_live_env(env,body)` with `nc_live_uses(env,uses)`.

The binding is guarded by `List.is_empty(env)`: an empty environment produces
`NU_Empty` without scanning `body`. Since `value_env = nc_live_env(env,value)`,
empty `env` also implies empty `value_env`; both keep/live consumers then return
empty lists independently of the set. For nonempty environments, both consumers
observe exactly the same `nc_uses(body)` set as before. Existing first-to-last
binding order, repeated/shadowed IDs, full U32 identity, nonowning kinds and the
rule that a Var is a leaf remain unchanged. This avoids adding summary work to
the old `nc_live_env([],body)` early exit.

No callee admission is broadened. Shape recognition, `p113p_bindable`, bundle
substitution, ordered fresh IDs, value/body lowering, keep policy and final
independent verifier calls remain original. The shared summary describes the
**original** continuation body, exactly as both old consumers did; it must not
be reused for the substituted body. Actual callers include `p113px_known`,
`p113pl_let` and the scalar-permitted `p126dp_original_let` path. Existing boxed
liveness and Phase144 constructor/bangs sharing are not counted as new work.

## Controls and assembly

For the candidate request compiler, splice only `uses.bend`'s declaration into
the maintained assembly and leave ordinary API/entry selection unchanged. Do
not append a duplicate definition. There are no additional production module
dependencies: all called declarations and types already belong to the compiler.

For a separate controls API, also append
[uses-controls.bend](../../../selfhost/tests/phase156/uses-controls.bend) and
export `p156u_controls` and `p156u_controls_ok`. The former returns 11 named rows;
the latter must return true. It relies only on existing compiler declarations,
including the maintained `p134v_list`, `p134v_stmt`, `p134v_scalar` and
`p134v_binding` structural comparators from `tests/compiler/native-controls.bend`.
No Phase155 experiment module is required.

The reference `p156u_original` is the original declaration with only its name
changed. Six controls compare complete keep/live fields: empty environments,
empty value environments, mixed ownership/order/shadows, maximum IDs, no uses,
and Var-with-child behavior. Five complete flat-binding controls compare every
statement, fresh counter, error and called target. They include empty inputs,
owned fields, a retained shared owned field, an unsupported-value error and a
result-shape error. Valid controls explicitly require known shape, bindability
and an empty reference error, preventing two matching refusals from passing as
success. Refusals use independently spelled expected diagnostics.

These complete local controls call the current lowerer recursively in both
roles; they isolate this declaration's delta. Separate old/candidate compiler
requests must still establish entire QBE equality, including successful flat
binding and unrelated/refused requests. Keep the final independent verifier
enabled. The coordinator should charge complete acquisition and compilation
cost, and inspect actual dynamic exposure before claiming a lowering-region or
whole-compiler gain. A neutral real-request result is a valid stopping outcome.
