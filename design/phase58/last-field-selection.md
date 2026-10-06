# Phase58: qualify the final-field constructor rule

The final bounded syntax experiment restores the three reviewed program points
to their Phase56 performance range. Across five fresh rounds per role, the
diagnostic/Phase56 median ratios are 0.971641 for Map/Set, 1.001941 for edit-distance
and 1.010915 for Morning. All 45 samples pass their full oracles; none crosses
the inherited descriptive spread/drift thresholds. This is a three-point screen,
not a representative aggregate or a proof that every program improves.

The compiler tradeoff is explicit. Against the otherwise identical all-literal
shared01 B2, first-request medians increase 13.06% / 13.94% and later medians
16.91% / 17.34% for Lexer / Evening. This misses the approximate 10% compiler
screen in the preceding design; do not relabel it as passing that screen.
Nevertheless, it preserves much more compiler benefit than uniform computed
fields, whose measured increases were 48–52% first and 56–68% later. It also
avoids a field-count or record-name exception. Qualification is justified as a
measured compromise to recover program speed while retaining the phase's larger
allocation and self-hosting improvements. The actual source build must establish
those retained gains afresh; multiplying ratios from different experiments is
not a selected-release measurement.

Implement one rule for ordinary direct constructors: emit quoted keys for the
prefix, and a computed key for the last live field. Every `__proto__` key remains
computed wherever it occurs. Host marshalling spread objects retain the existing
literal-key rule because their complete record layout is not represented here.
Tags, value expressions, property order and native representations stay unchanged.

Share a small field-join helper between normal and ordered construction. The
rendered suffix determines whether a field is last, so erased trailing arguments
do not affect the decision. Preserve each value's position and every ordered
prefix. Cover zero/single/multiple fields, trailing/all-erased fields, early/final
`__proto__`, callbacks, throws and host conversion with genuine checked fixtures.
The prepared patch adds one helper and five physical lines across three modules;
no new analysis, runtime cache, compiler flag or program-specific selector is
introduced.

Freeze `checked-last01` after application. Run the focused field controls and
fresh checked integration, actual own-source B2 generation, own-source check,
B2→B3 equality, B2 semantic matrix and 23-source/45-point emitted-byte equality.
Compare the real three diagnostic-point modules with the saved derivatives.
Reacquire and measure the full representative program set, then repeat selected
compiler latency/allocation and clean full-emission measurements with the existing
methods and explicit baseline. Preserve all earlier successes, regressions and
rejected derivatives as separate results.

Admit installation only after the selected compiler's gates complete. Report
the final compiler/program tradeoff, cumulative allocation versus peak memory,
source size, self-hosting scope and remaining gaps. Keep the older installed
release and protected evidence intact until promotion. No additional speculative
record-syntax search is part of this consolidation.
