# P68-016: scalar array storage and proven unshared access

Registered before diagnostic derivation or execution, 2026-10-08. Root owns
all C compilation, generated-program execution and timing. This lane reads
saved source/binaries on CPU0 and prepares isolated source artifacts only.

Hypothesis: after private product workers remove temporary Tuple shells,
generic element ownership and generic array-location lookup explain a large
remaining native array cost. Test two independent mechanisms before selecting
compiler changes: packed U32 storage/access, and location lookup for a proven
unshared array. A combined diagnostic measures their interaction.

Evidence is already concrete, not a performance measurement. Actual products15
has a reachable Q loop/cell/step graph with zero Tuple allocations or takes per
recurrence. Its optimized inner loop still uses eight-byte element slots,
checks an array handle's RFC bit three times, and checks retained/replaced
elements. Upstream's checked saved C selects four-byte U32 slots and
`BLK_SHR 0`; its optimized loop has fifteen instructions for two elements,
without element ownership or array RFC branches. Exact source/binary identities
and read-only disassembly are retained in
[the audit](../../research/phase68/array-after-products15.md).

The first intervention edits only the exact products15 saved array C. The
packed arm changes the active producer to `blk_new(..., 0, ...)`, its selected
getter to a 32-bit read, and its selected setter to a 32-bit write without
generic old-element destruction or new-element sealing. The unshared arm
changes only the three location lookups at those accesses to `term_loc`.
The combined arm applies both. Original runtime helpers, scheduler fallback,
worker signatures, product transfer, error checkpoints and compiler images
remain unchanged. Worker names select diagnostic sites only; they must never
be production admission criteria.

This intervention's finite correctness argument uses the actual closed
producer-to-consumer flow: the selected array starts from a U32 seed, is only
read and updated with U32 arithmetic, is never duplicated or passed to a
foreign/dynamic call, and is ultimately dropped. The existing runtime already
allocates, frees and copies packed `TAG_BUF` blocks. This does not authenticate
arbitrary raw terms or establish that every public Array operation handles
both layouts. Independent iteration/seed oracles and active assembly inspection
are required before interpreting timings.

Freeze the original C/emission receipt, recipe/toolchain, transformation script,
every exact replacement, derived C and benchmark plan. Use the existing saved-C
method, common fixed work and alternating order. Only samples of at least100ms
qualify for ratios. Preserve all failures and compare all four arms separately;
do not attribute the combined gain to either axis alone.

Production scope, if justified, must be general and conservative. Preserve the
uniform Term fallback for unknown/raw/foreign values. A typed annotation alone
does not authorize narrower storage, an early unbox, removed ownership or
unshared lookup. Admissible routes include a proven scalar producer and a
closed graph of compatible uses, or a runtime-guarded representation whose
operations all dispatch correctly and widen safely on an incompatible write.
Sharing facts need an independent proof or a runtime guard; scalar elements
do not imply an unshared array. Full packed-array integration must account for
get/set/swap/new/size/clone, leaf/node matching, joins/splits, atomics, printing
and foreign ABI. A saved-C win alone is not promotion.

Falsifiers: oracle mismatch, an active old-layout consumer of a packed array,
a reachable sharing edge invalidating direct location lookup, no active machine
code change, or negligible qualified gain. Stop or narrow the proposal on any
of these outcomes. No runtime, whole-program, GPU or parity claim is registered.


## Outcome: 2026-10-11 investigation

Executed the frozen four-arm plan: all16 smokes and12 timed observations pass.
Packed alone3.38×, direct-unshared alone1.20×, together5.43× faster than products15.
A separate three-arm balanced saved-binary comparison measures188ms combined
versus187ms upstream and1022ms unchanged (5.44×). This supports implementing
general scalar representation and independent sharing facts; no compiler or
release was changed. The selected C-only flow is not broad API conformance.
[Report and limits](../../implementation/phase68/c-target-opportunities.md).
