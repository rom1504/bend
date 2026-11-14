# Eleven-color pool prototype

Authored, unqualified and not integrated. Root owns all checks and target jobs.
Use the frozen Phase194 source parent, with these files:

- `allocator-v2.bend`: overrides `x190_j_solved,x190_l_abi`.
- `physical-hooks.bend`: overrides `x185_transient_reg,x185_physical_transient,x186_call_slot,x186_float_home,x186_p_word_home`.
- `allocator-controls-v1.bend`: export `p195p_controls`; require all23 labels=1.
- `physical-controls.bend`: export `p195ph_controls`; require all13 labels=1.

Keep original candidate selection,32-bit IDs, fixed-point fuel,256-row gate and
statement semantics. Physical emission uses the new validated homes. Do not compose the budget or hybrid
overrides into the first screen. The new colors are9=RCX/Transient5 and
10=R12/Register0. Existing colors0..8 retain their meanings.

RCX uses original caller call-interference and incoming-position>=3. An exact
suffix-liveness walk additionally excludes live-out values and destinations of
variable shifts. Constant shifts do not clobber RCX. Independent final coloring
validation rechecks uniqueness, graph interference, calls, ABI and this shift
mask. Every refusal takes the complete original legacy allocator.

Only if a candidate receives R12, canonical state is moved from Register0 to
one aligned8-byte slot appended to the original frame. Its original slot must
be exactly Register0/width8; frame/call capacity is checked before installation.
All other offsets remain intact. Existing frame-based incoming/state reads and
save-mask discovery cover the transaction. If R12 is unused, state and frame
size remain original. The physical hook forbids literal state as an Again
destination while admitting ordinary R12 local destinations.

These36 compiler-data controls do not replace independent machine observers,
call/shift/parallel-transport stress, real product oracles, or timing. Inspect
hot instructions and frame references first; do not infer speed from allocation
counts. Exact static predictions and limitations are recorded in
`research/phase195/hybrid/hot-row-pressure.md`. No target was run while authoring.

V1 remains frozen after its source check rejected a reused linear `color`
argument. V2 marks that argument and the state-capacity check's reused `calls`
field with `+`; no allocation or legality rule changed. The24 allocator
definitions and14 allocator-control definitions were audited for repeated
arguments, match fields and closure captures. Allocator controls remain v1.
