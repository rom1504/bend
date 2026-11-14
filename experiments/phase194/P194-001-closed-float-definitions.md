# P194-001 — closed float definition identity

Hypothesis: overwritten mutable destinations cause distinct F32 values to lose their identities before XMM placement. A bounded, pure, closed-region definition renaming can remove conversions without changing published full-word values.

Prediction: remove three observed numeric round trips and transfer to ray code. Reject if actual runtime does not improve or frame/spill growth dominates. Existing canonical-word admission remains authoritative; branches/calls/backedges cut the region. This is not global SSA.

Implementation: `selfhost/tests/phase194/float-value-experimental.bend`, exact hook, checked API `selfhost/build/phase194/float-api02/report.json`. Independent controls `float-controls01` pass20 structural checks and28,880 observations per direct-object/rendered-assembly route. Finite evidence, not a theorem. Initial forward-declaration fixture failure `float-api01` remains retained.

First causal screen: `ablation-runtime01/report.json`, six programs and five balanced roles. Numeric takes0.8607×baseline, ray0.9748×. Four nonfloat .text sections are identical and runtimes stay within1%. These are development observations; full-suite transfer and native qualification remain separate gates.

Machine evidence: `research/phase194/float-machine.md`. Numeric removes all three targeted round trips. Ray removes94 static instructions overall but grows frames and adds four stack references in isect5. Static counts are not dynamic cost estimates.

Integrated into `float-identities.bend` after independent audit and the final
checked-source gate. Exact N1/N2 products and N2/N3 compiler-object reproduction
pass. Twenty structural controls and28,880 observations per route, plus the
combined controls, retain the stated finite boundary. Final ordinary-program
transfer is reported in `implementation/phase194/runtime-summary.md`; diagnostic
closed-F32 time falls23.5% in the separate two-feature screen.
