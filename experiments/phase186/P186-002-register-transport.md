# P186-002: verified fixed-count register transport

Hypothesis recorded during source and actual-machine inspection on 2026-11-09.
The coordinator owns all target execution. No result is claimed here yet.

The final Phase185 native tree ELF retains a roughly 27-instruction
`p111_rt_jump` and 23-instruction `p111_rt_return`, both calling
`p111_set_regs`, whose capability-4 path adds roughly 28 instructions and a
`memmove` call. The final map SSA has 154 jump and 278 return sites; tree has
57 and 95. These static totals include cold and fallback code. Historical
Phase185 baseline physical jump+return shares were 7.47% map and 7.78% tree;
that is about a 1.08x deletion-only ceiling for those helpers, not the current
image's measured budget. Unresolved library/memmove samples are not assigned
to this optimization. It does not remove scheduler dispatch.

The candidate in `selfhost/src/back/qbe/register-transport.bend` expands exact
post-verification jump/return calls with constant counts 0..8 and authenticated
ordinary/fusion/inlining scratch origins. The independent original verifier
proves jump target arity/incoming, return width, and buffer capacity. Numeric,
unknown, runtime-reserved FIDs and unsupported shapes decline. Runtime ABI11102
state layout is the same explicit qualification boundary used by existing
frame expansion. Capability 4 is checked dynamically; its absence invokes the
unchanged runtime helper, including trailing-register clearing.

All source words are loaded before the first register write, preserving
`memmove` overlap semantics. Transfers then preserve the runtime's `rn`,
`next`, continuation-stack pop, low-32-bit return FID, and zero status. Slow
calls render once through the previous pipeline. The shared `P114TExpansion`
is available to other renderers; initially only the QBE hook is enabled.

Controls: 30 structural/admission/verifier rows; 2,000 isolated QBE machine
observations across eight valid capability combinations, widths 0/1/2/8,
jump/return, five source-alias modes, full-state/tail-register equality, and
original fallback observation. The observer provides isolated runtime stubs,
not a production runtime provider. Ordinary source controls exercise nested
tree/closure continuations and values beyond 32 bits with an independent
closed-form output. Root must acquire checked source, execute these controls,
compare actual machine helpers/size, then measure the retained map/tree,
closures and numeric cases before any acceptance claim.

First falsifier: if the expanded machine retains transfer calls on the hot
capability-4 path or if code growth/branch work offsets their removal, reject
or narrow the candidate. The previous source/artifacts remain immutable.
