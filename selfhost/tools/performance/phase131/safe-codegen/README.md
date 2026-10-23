# Phase131 scalar-returning selector probe

This is an unqualified compiler overlay, not a source rewrite of the proven
summary algorithm. Prefer `selector-literals-v02.bend`: replace `nbc_closed`
and `nbc_definition`; add `p131sc_definition_body`. Version 1 is preserved as
experimental evidence. No production selection changes.

The existing Phase99/112/113 known-lambda path already fuses the safe merge's
three literal callbacks. It refuses the lookup selector containing `U32 0`:
`nbc_closed` accepts nullary constructors but no scalar literal. This leaves a
closure allocation, continuation and indirect application in each recursive
lookup. The unsafe source instead becomes a direct tail-SCC worker.

The probe permits canonical `NWord` leaves after bounded compaction of the
callee's erased body. It preserves the old saturation, node budget, closedness,
one-use literal callback, freshness and ordered evaluation gates. It does not
compact the substituted callback bodies or recognize usage-summary names.

Append `controls.bend` and `controls-v02.bend`; run `p131sc_controls_v02` through
the checked compiler API, then use that compiler
on the **unchanged** `usage-safe-proxy02/main.bend`. Keep the ordinary independent
output oracle and inspect the actual QBE. First falsifier: max/min must lose
their closure and become locally recursive direct workers. If the resulting
code still uses generic dispatch, do not claim closure elimination is enough.

Required transfer/semantic evidence: literal-returning unrelated ordered search;
all `Cmp` arms; strict nonliteral actuals; delayed literal callbacks; owned shared
captures; unknown callback; freshness collision; escaping callback; deep
stack-safe recursion. The frontier forbids unsafe/failure-runtime probes: the
two overflow fixtures here are **source-only review obligations, not runnable
jobs**. Do not launch them. Use ordinary valid programs and existing semantic
reasoning to assess ordering. Retain refusals for fields, arbitrary references,
primitives and noncanonical raw words.

The two existing proxy sources also differ in merge ownership/reconstruction,
so the complete 2.56x observed gap cannot be attributed to the lookup selector
without an ablation. This overlay isolates compiler behavior while keeping the
safe proof source byte-identical. Root owns target execution and measurements.

Version 1 passed 14 finite controls and independently verified QBE emission:
`selfhost/build/phase118/p131-selector-proxy01/report.json`. Safe max/min changed
from generic closure dispatch to 107-line direct local loops, while safe merge
stayed unchanged. Version 2 excludes String/unknown literal kinds before
compaction, because one String literal node can otherwise expand without a
size bound. Native runtime and broader qualification are separate gates.

Version 2 passes 19 finite controls and emits byte-identical QBE to version 1
for the unchanged safe proxy; see `selector-finite02/report.json` under
`selfhost/build/phase131/` and `p131-selector-proxy02/report.json` under
`selfhost/build/phase118/`.
