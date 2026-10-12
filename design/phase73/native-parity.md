# Phase73: general native execution parity

Baseline: source1176262 / releasecd36146; checked B1 0ab62a7a, genuine B2
bd39db0d; upstream0592662. Phase72's twelve-family geometric mean is1.37488×
upstream. Parity needs27.27% less time, not another4% win. No subagents.

## Hypotheses before production changes

1. General non-tail recursion is rejected by `nf_call_local`, preventing ordinary
   workers for many producers and consumers. Measure a diagnostic compiler-image
   derivative allowing self calls on shallow existing programs. This is explicitly
   not a safe production compiler and is never installed. Measure independent
   list, AST and shared-ADT families before deciding whether bounded direct calls
   with an explicit-stack fallback deserve implementation.
2. Consumption followed by reconstruction loses node storage. Attribute dynamic
   allocation sites, then test generic unique-node reuse. Shared/static nodes,
   class changes and error order are refusal boundaries. Historical7% tree gains
   are not assumed additive to current results.
3. Producer/consumer composition still allocates intermediate collections.
   Investigate general fusion or destination passing only if counts show enough
   shared headroom after the simpler calling/ownership corrections.

Local gains must be translated to the fixed equal-family12 score. Never sum
estimates for overlapping transformations; no benchmark-name admission rules.

## Implementation and correctness

Select mechanisms only after controlled falsifiers. Keep algorithms in Bend.
Reuse the existing native lowering and runtime where practical. Non-tail C calls
must have a bounded stack with a tested explicit-stack fallback, including deep
input, shared values, error ordering, tail loops and threads1/4. Raw/device paths
remain conservative unless independently validated. Preserve JS output, pin B1
and B2, check self-hosting and exact B3 before installing a new default.

## Efficient loop

One guarded CPU3 process tree:2GiB RSS,4GiB available floor, Node1GiB heap.
Freeze baseline C and binary identities. First one-round correct-output screens;
then three rotated rounds >=100ms against baseline and upstream. Reuse the16-input
independent oracles and fixed workloads. Instrumented/profiled clocks are never
speed evidence. Slow gates run once a candidate has demonstrated broad gains.
Track elapsed time and account-level quota observations separately from billing.
Preserve failures and negative results, use fresh Phase73 paths, never modify
closed historical evidence. Commit design, validated progress and final report;
no PR comments. A disappointing measured result is reported rather than promoted.
