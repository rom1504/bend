# Phase81: identify a sufficiently large compilation-speed change

Investigation only. Keep Phase78 production and historical evidence unchanged.
Read the Phase74 structural survey and Phase75–80 results before proposing work.
No agents. Use the same CPU3, 2 GiB tree cap, 4 GiB available-memory floor and
Node 1 GiB heap / 4 MiB stack. No new compiler image or broad qualification.

1. Freeze current B1/B2 and pinned TypeScript across Numeric, Array, Lexer,
   small and functions65. Collect three fresh clean samples per role/source.
2. Separately measure the optional no-report API on the three-source screen;
   keep the official report-producing comparison intact.
3. Collect separate CPU profiles for all fifteen role/source combinations and
   sampled allocation profiles for Numeric. Require exact previously qualified
   C in every request. Allocation estimates include collected objects and are
   diagnostic, not latency savings. Public stage clocks are inclusive.
4. Inspect the current source and generated compiler code under the residual
   hotspots. Compare upstream typed terms, memoization, lowering and emission.
5. Refresh primary-source research on compact representations, staged lowering,
   lazy module products, functional evaluators and cheap compilation tiers.
6. Rank changes by whole-request impact and time to a falsifiable prototype.
   State overlapping gains, correctness risks, evidence limits and retirement
   of superseded representations. A new IR or cache is not itself a speedup.

Archive methods, fresh profiles, clean timings and exact-output receipts. The
report must distinguish cold B1, cold B2, generated-program speed and warm/edit
latency. Do not claim implementation gains from this investigation.
