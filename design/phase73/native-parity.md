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

## Decisions after the falsifiers

Unrestricted C recursion failed on all three initial families. Allocation counters
instead identified thousands of avoidable reference-count wrappers per input
cycle. The selected implementation therefore combines three general mechanisms:

1. A bounded sharing analysis over the checked book proves which constructor
   fields never need shared storage. Reuse prepared native bodies; retain full
   instantiated types, transitive fields, provenance and conservative refusal.
2. Extend existing observers to scalar results and guard every recursive root,
   including at loop backedges. Admit unsealed children of shared roots only when
   all reachable consumers obey borrowing, with no partial-call or worker bypass.
3. Preserve the existing scalar word kinds in ownership bindings and continuation
   parameters. One specialized telescope field mask serves constructor macros and
   captured match fields. Remove the later reconstruction pass.

These are type/ownership rules, never benchmark-name selectors. Raw, device and
unknown-effect routes retain conservative behavior. Nat range narrowing and
blanket inline-policy changes were rejected after conflicting measurements.
Storage reuse and fusion remain future experiments, not shipped optimizations.

Candidate14 is the selected consolidation. The final runtime campaign was
increased to six rotated rounds per role/family after timing drift appeared in
earlier screens: 216 independently checked intervals over twelve fixed families.
Keep the original six and additional six scores visible alongside the optional
equal-family total. Forty-five paired old/new B1/B2/TypeScript requests measure
compilation independently. Fresh source acceptance, B3, twelve B2 C identities,
raw/native/ownership controls and installed CLI checks determine release status.
The [implementation report](../../implementation/phase73/README.md) records actual
outcomes and remaining gaps.
