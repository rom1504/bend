Shared-address revision 2
=========================

The initial eight-original-row matcher misses the actual hot fold. Preserve
`shared-address-controls.bend`, `controls.mjs`, snapshot05 and controls01 as
the first checked candidate and its negative structural evidence. Revision 2
changes only the hard selection-window cap to sixteen; read/write certificates,
effect barriers, address mutation checks and selected dependency rows are the
same. This cap change was explicitly authorized after the actual IR falsifier.

The exact parent diagnostic is
`selfhost/build/phase192/diagnostic01/local-fold/preselection.json`, emitted
from the Phase191 API at `x185_function_copied`. Its hoisted
`$product.fold.loop` contains this eleven-original-row sequence:

1. U64 multiply masked index by four.
2. Offset from the hoisted array base and scaled index.
3. U32 load.
4. U32 copy of the incoming accumulator.
5. U32 addition of the copied accumulator and loaded word.
6. U64 copy of the sum, preserving the next accumulator.
7. U32 copy of the incoming index.
8. U64 xor of the sum and copied index.
9. U64 self-copy of the xor result.
10. A second offset from the same base and scaled index.
11. U32 store of the xor result.

The scale has two matching reads; each offset has one matching access; none
of the active base/index names changes inside the sequence. The sixteen-row
certificate therefore admits this sequence. The accumulator copy between load
and add prevents the existing adjacent memory-ALU rule from fusing them. No
claim is made that this change removes the accumulator copies or closes the
whole runtime gap. Confirm the emitted hot multiply disappears before timing.

For the new checked API, append `shared-address-controls-v2.bend` instead of
the initial fixture and also append `shared-machine-controls.bend`. Export
`p192sa_controls` and `p192sm_emit`. Revision 2 has 25 flag-aware data controls:
the nine-row case now admits; exact sixteen-row admission and seventeen-row
refusal are added. The earlier eight-row admission remains.

`controls-v2.mjs` preserves the original harness and adds a `sharedmachine`
group. Its `shared` group uses the v2 fixture and 25 exact labels. The machine
group emits twenty functions: five shapes using joint allocation, explicit
legacy allocation, stack-only homes and oversized joint-allocation refusal.
The C observer checks zero-extended U32 results and every surrounding source
and destination word, including overlapping source/destination arrays. It
also checks U32 scaled wrap refusal, a changed index after address construction,
store-before-load ordering and high accumulator bits. Expected stdout is:

    phase192 shared machine controls: checks=2400 failures=0

No target runs were executed by this agent. Root owns checked acquisition,
direct-object/rendered-assembly execution and performance validation. The
unrelated ordinary source fixture and independent C oracle remain
`shared-array-transfer.bend` and `shared-array-transfer.c` (expected 8318258).
