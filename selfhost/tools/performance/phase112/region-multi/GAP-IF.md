# Optional structured pure gaps

The frozen word compiler output has an applicable inner gap in
`$direct.p88_digits`: at `p112-word-full-emit01/program.ssa:21973`, a frame is
followed by two U32 comparisons before argument stores and an already private
`Bool.and` call. `scalars.bend` constructs each comparison as three numeric
binary statements followed by `N111If{condition,[Set 1],[Set 0]}`. Including
operand and result copies, the complete gap contains 18 IR statement nodes.
The qualified flat gap gate rejects the `N111If`. This is source-construction
and emitted-output evidence, not an executed admission result for this profile.

Append `gap-if.bend` and override only `p112g_split` with
`gap-if-entry.bend`. The frozen gap01 implementation is unchanged. The new
checker accepts its existing pure Set/Bin leaves and recursively pure If nodes.
One remaining-budget value is threaded through the If node, its yes branch,
its no branch and the following statements. Every node in both branches counts
towards the same total limit of 32; an unselected effect still refuses the gap.
Recursion terminates at the budget, and no source branch is flattened or moved.

Conditions may be safe locals or constants with high word zero. Mandatory
original `p111v_stmt` verification proves every condition is a definitely
assigned U32. The new gate additionally excludes state, scratch and symbol
values, while preserving the exact verified condition and local definitions.
It does not pretend to infer a local's type from its name.

The existing splice retains the order: capture snapshots, zero frame result,
the unchanged structured gap, then argument snapshots and the private call.
Branch-local overwrites therefore retain their original control dependence,
and cannot change the already saved capture values. Calls, memory operations,
pointer operations, frames and transfers are forbidden in every gap branch.

The copied-continuation bound remains independently 128 statements. Global
fusion sites remain eight and immutable private admission remains six ranks.
Outer frames separated by keeps or further frames still block private region
admission. Matching this inner gap does not establish full `p88_digits`
admission or a measured compiler speedup.

`gap-if-modules01.json` records the exact optional overlay. Separate conjunctive
admission and independent controls are required. `gap-if-p88-digits.bend` copies
the actual compiler helper definitions into a bounded source witness with
expected result `123456789`. `diagnose-p88.mjs` prepares and verifies that source
through the checked API, then reports actual frozen ranks and planner predicates
for those helpers; it can compare gap01 and this profile without emitting native
code. The coordinator owns all executions.
