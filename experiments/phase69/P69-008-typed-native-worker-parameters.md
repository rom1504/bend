# P69-008: typed scalar parameters in private native workers

Registered 2026-10-11 before source preparation or target execution. Root owns
execution; the tree lane only prepares source/data and legality analysis.

The cold-node experiment removed substantial allocation overhead. Remaining
hot `warp_leaf`/`warp_leaf.go` workers still accept generic `Term` arguments,
call generic `term_keep` on U32 values and retain heap-packing fallback even
for proven scalar Leaf payloads. Upstream's corresponding workers accept
`u32`, so its C optimizer sees the range and erases those paths.

Hypothesis: giving private native workers their checked scalar C argument types
removes meaningful surviving generic work and can improve many scalar-heavy
programs, independently of multiword return layout. This is not arithmetic
strength reduction and not removing generic raw demand checks.

First discriminator: exact compiler23 tree C, on the same BANGS0 + cold Node
stores baseline. Change only declaration/definition parameter types for the
known U32 arguments in two leaf helpers; retain the bodies, callers, polling,
branches, scheduling and all runtime helpers. A separate arm may also narrow
the canonical Bool argument. Compare baseline, U32-only, U32+Bool; original
and upstream clocks remain same-campaign controls. Pin all changed spans and
reverse replay to the original parent derivative.

Admission must be checked source layout, not parameter names. Native U32/F32/
Char representations fit 32 bits; trusted Bool emission is canonical 0/1.
Raw input or unknown foreign representations retain the generic entry path.
F32's bits must remain unsigned bits, not a numeric C float conversion. Char
validity is a source checker/runtime contract and narrowing must not introduce
a new validation assumption. Capture fields need their actual layout facts,
not inference from a closure worker name.

Require independent correct outputs, balanced qualified kernel clocks and
assembly/counter confirmation. Any larger patch must carry facts once from
checked function signatures and preserve raw fallback. If narrowing merely
moves overhead to adapters or gives no time improvement, record that outcome
and prioritize other representation changes.
