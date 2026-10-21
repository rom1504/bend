# P118-004: dead scalar cleanup exposes Boolean selection but regresses

Hypothesis: backwards liveness can remove unused scalar copies that block the
existing general Boolean-select rule, reducing instruction and branch cost.

The Bend prototype retains calls, memory, division, floating operations and
unknown nodes. Its24 finite checks pass. The first host driver wrongly expected
boxed Bool from the JavaScript API; the corrected driver requires literal true.
The actual15 structural outputs had already passed. Both attempts are retained.

Two new Mandelbrot select diamonds are recognized. QBE drops618→435 lines and
conditional branches9→7, but the hot native loop grows97→99 instructions:
setcc7→9, conditional moves5→3, conditional jumps3 unchanged, no calls/spills.
Five paired scale4 rounds give845→913ms (+8.05%). Lexer is833→830ms, effectively
neutral; its QBE shrinks6.1% while machine code is essentially unchanged.

Decision: exclude. The old adjacent-comparison identity cannot rescue the new
sites because the immediate producer is XOR1. No broader new pass is justified
by this negative result. Reducing textual IR is not an adequate profitability
criterion. Preserve this general liveness prototype for future measured needs.

Evidence: `selfhost/build/phase118/dce-finite04/report.json`, `dce-clean01/report.json`,
and the reproducible `selfhost/tools/performance/phase118/dead-scalars-machine.md`
audit with its pinned JSON and script. No production or selected compiler edit.
