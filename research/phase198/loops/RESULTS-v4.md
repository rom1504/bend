# Full-function no-spill certificate rejects the useful placement

V4 source checking passed first attempt, as did 35 structural controls and 802 unique independent C function comparisons per direct/assembly route. Four actual ELF objects emitted. The edit-distance loop matches incumbent instructions exactly; both fold loops remain the original 15-instruction/zero-frame-reference body rather than V1's winning 13-instruction body. The runner stopped at its explicit activation assertion before linking ordinary programs or timing. No runtime or full-program correctness claim is made for V4.

The rejected V1 allocation contains a concrete one-time setup spill: store of the heap base at 0x3cde to [rbp-0x8c8], reload at 0x3d4f. The original fold keeps that setup temporary in R14. V1's repeated body still has no frame operands. Thus requiring every function read candidate to remain registered blocks a beneficial trade of one-time setup traffic for a shorter recurrence. This is not a liveness failure; the independent validator passed in V1. The actual V4 fold body equals baseline (empty normalized diff).

A principled follow-up would certify coverage of repeated-path reads, using the existing x191 Again-reaching profitability walk, while allowing setup/exit-only spills. Oversized pools should still take the ordinary path, and failed hot-coverage certificates should restore original selection/coloring. This variant has not been implemented or checked here.

Guarded costs: API 15.25s, controls 29.07s, four-case emission 41.67s. All guards/retention closed, lane handed discovery_b. Evidence: v4-evidence-index.json, checked-evidence03.json, emission-evidence03/report.json. No maintained edits or commits.
