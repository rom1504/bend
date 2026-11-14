# P193-002: limit continuation growth without weakening legality

The first integration improves full native45 runtime4.67% and native compiler
requests10.3%, but N1→N2 acquisition rises18.6% relative to the previous phase's
single observation and compiler text grows16%. Public continuation copying
accounts for99.45% of text growth, with some owners expanding6–16×.

Hypothesis: a consumer-side2×original+16 IR statement budget preserves useful
small compositions while refusing disproportionately large copies. Count only
nonzero fusion plans with existing linear counters. Acceptance uses the original
complete plan; rejection uses ready-tail lowering on the original segment.
This changes profitability only. It does not save original planner construction
work, so emission savings must repay the two additional traversals.

Pure boundary controls7/7 pass. The real compiler kernel retains a6.96%
runtime reduction versus7.53% for the uncapped candidate, while object bytes fall
218,048→200,552. Four unrelated development programs are within1% of uncapped.
Final source02 is selected for larger acquisition and qualification; source01
remains immutable and its full results remain visible. No general theorem or
unmeasured full-build saving is inferred.

Evidence: research/phase193/composition-cost-filter.md, fusion-budget-audit.md,
implementation/phase193/README.md and the exact budget-* receipts.


Final selection: compiler executable24.804MB, versus26.805MB uncapped;
N1→N2 acquisition278.214s versus302.204s uncapped (single observations).
Native requests improve9.32% against Phase192; the full runtime campaign improves
4.16%. N2/N3 objects reproduce exactly and the independent finite gates pass.
The cap trades a little observed runtime benefit for materially smaller code;
separate campaigns are not a precise paired estimate of that tradeoff.
