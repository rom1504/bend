# Branch-fact affine-use audit

Use `branch-facts-v2.bend`, unchanged `hook.bend`, and unchanged
`controls-v3.bend`. The v2 core changes only the `condition` and `rest`
parameters of `x195bf_if` to reusable bindings. This repairs the affine-use
source rejection from branch-api03 without changing its computation. Earlier
files and frozen acquisition inputs remain intact.

All four `nt_choose` sites in these three modules were inspected. Both closure
values are constructed at the call site, so capturing a binding in both
requires reuse even though only one closure is invoked. Counts below are
syntactic uses, not execution counts.

| Function | Captured or shared input | Uses and annotation |
|---|---|---|
| `x195bf_if` | `condition: N111Value` | One use in each closure; now `+condition`. |
| `x195bf_if` | `rest: List<&2,P113DStmt>` | One use in each closure; now `+rest`. |
| `x195bf_if` | `yes`, `no: List<&2,P113DStmt>` | Two uses in enabled closure plus one in fallback; both already `+`. |
| `x195bf_if` | `state: X190Values` | Three uses in enabled closure; already `+state`. |
| `p195bf_row` | None | Closures return string literals; `good` is used once by the guard and `name` once outside it. |
| `p195bf_branch` | `mode: U32` | Once in guard, twice in fallback closure; already `+mode`. |
| `p195bf_emit_at` | `mode: U32` | Once in guard, three times in recursive closure; already `+mode`. |

No other lambda occurs in these modules. Each closure's unit binder is unused,
which is permitted by affine use. The return types at all four sites are
explicit. The repeated core inputs use existing `Data` types (`N111Value`,
`P113DStmt`, `X190Values`) and the existing unrestricted `List<&2,...>` form;
no type, law or constructor representation is changed.

The audit also covers shared values outside closures. `x190_v_plain` already
marks `state` reusable where substitution and recursive processing both need
it. Its body and pattern-bound rows are consumed once within their selected
match arm. The kill/join helpers pass each input once within each match arm;
separate match cases do not construct competing closure captures.
`p195bf_body` marks its three-use `mode` reusable. All six locals in
`p195bf_controls` have explicit types and reusable bindings (`s`, `write`,
`call`, `nested`, `narrow`, `wide`); in particular `write` is used when building
`nested` and in later checks, and `s` is used when building `wide` and in later
checks. All other control-helper inputs are consumed once per selected match
case or once in their straight-line body.

The prior v3 parameter-scrutinee, local-type and delimiter audit still applies;
the new core changes only two `+` annotations. This is an offline source audit,
not a successful Bend source check, acquisition, emitted-machine test or
performance result. Root owns those guarded executions.
