# Optional machine-width rendering

This renderer consumes the original verified direct IR. It does not change its
types, definitions, control flow, public ABI, source ownership facts or verifier.
It recognizes two structural patterns while emitting complete direct bodies:

```
x:U64 = op(a,b)
x:U64 = and(x,0xffffffff)
```

For `add`, `sub`, `mul`, `and`, `or` and `xor`, the pair becomes a fresh QBE word
operation followed by an explicit `extuw` into the original U64 destination.
Taking low32 bits commutes with these operations, even for arbitrary raw64
inputs and U64 wraparound. Same-destination adjacency makes the intermediate
wide result unobservable. Operand/destination aliasing is safe because both
operands are read before the original destination is assigned.

A standalone U64 `and(value,0xffffffff)` becomes word-copy plus `extuw`.
No shift, division, comparison or signed operation is narrowed. Different
destinations, intervening statements and branch boundaries do not combine.
Embedded scalar `N111If` bodies keep their existing emitter; ordinary direct
branches recurse through the selected body renderer.

Each rewrite consumes one `P111QCode.next` value and uses
`%p113_width_<next>`, distinct from `%v_` source locals, `%t_` scalar temporaries
and the other direct namespaces. Counter overflow keeps the original rendering.
The exact original error/terminal checks remain in front of lookahead.

Compose `emit.bend`, `controls.bend`, `cases.bend` after the original direct
emitter; replace only `p113e_stmts` with `overrides.bend`. The branch23 analysis
hooks are disjoint. Source admission must pin the selected original verifier,
the original `p113e_stmt_emit`/branch renderer, all four files here, and that
exact one-declaration override. This is a backend arithmetic expansion after
verification, not a new ownership proof for arbitrary caller-supplied IR.

`p113_width_control_report` has22 structural controls. Sixteen small original
IR functions are produced and verified in Bend by `p113_width_case_error` and
rendered by `p113_width_case_qbe`. `prepare-controls.py --out FRESH` freezes
128 independent arbitrary-precision integer expectations and a C transport
harness. `emit-controls.mjs API PREPARED FRESH_OUT` checks API/prepared receipts,
runs the Bend controls, and writes their QBE. Root owns compiling/linking that
QBE and comparing the harness output with `expected.stdout`; no runtime object
is required because these scalar cases never dereference state or call helpers.

Cases include high bit31,2^32,2^40,2^63,UINT64_MAX, wrapping add/sub/mul,
input/destination alias, both operands alias, a live unmasked intermediate,
intervening observation, shifts32/40, near/high masks and downstream upper-bit
inspection. Full U64 decimal outputs ensure zero extension is actually tested.

Offline source counting in identity21 and ranges19 scalar-region QBE finds16
adjacent ring-op/mask pairs in direct functions, nine inside `mit` (four mul,
four add, one sub). This is a structural opportunity count, not a performance
claim. It cannot by itself remove call overhead, branch joins or native stack
spills. The baseline source stays frozen; select this profile only after the
finite machine controls and matched workload checks.

Independent laws review found no concrete source defect in the finite rule,
ordering, namespace or counter handling. Native checks remain root-owned.
