# Phase125: eliminate reconstruction, then qualify native composition

Starting point: selfhost/bootstrap at06dea60, Phase124 checked source02. The
same-run original44 geometric runtime is1.92014× upstream;40 cases exceed1.1×,
24 exceed2×. Latest qualified native compiler remains Phase118. Parity is the
objective, not a predicted result of this experiment.

## Hypothesis and decision gate

RLE constructs a repeat spine, recursively expands the suffix, then consumes and
reconstructs the prefix in concat. Phase124 removes scheduler boundaries but keeps
both allocations. Test the category of unnecessary reconstruction, rather than
another generic allocation helper or benchmark-name recognizer.

First measure a pinned source-only repeat-into-tail ceiling with the original
timed wrapper, counts and independent output oracle. An unrelated varying-String
map/concat witness retains aliases and prints complete results. This ceiling
reorders pure bounded construction; it is not itself a legality argument for an
automatic exact-order transformation. Record actual allocation/take counts in a
separate diagnostic runtime; do not use instrumented timings as speed evidence.

The preferred exact-order prototype recognizes the checked semantics of append,
then attempts a read-only uniqueness/layout scan before attaching its suffix to
the final prefix cell. Shared, static or unknown representation must leave the
input untouched and select the original implementation. The operation owns its
input and suffix, preserves payload sharing and evaluation order, and must retain
bounded native stack use. Structural admission must be independent of names.
An authenticated private destination is an alternative only if the simpler test
cannot establish value. Generic cell-credit recycling remains rejected.

Spend at most about90minutes establishing a useful automatic transformation and
transfer. Stop weak variants early; preserve negative evidence. A source ceiling
alone is not a compiler improvement. A narrowly admitted implementation that is
safe but unused is not a performance gain.

## Execution and validation

1. Pin source, runtime and machine policy. Write source ceilings and independent
   controls, then measure construction counts and clean paired runtime.
2. If evidence warrants it, implement semantic admission in checked Bend and a
   minimal additive runtime operation. Keep legality separate from emitted QBE.
   Test empty/nonempty, retained aliases, heap-owned payloads, static values,
   long lists and conservative fallback using ordinary valid sources only.
3. Confirm unrelated transfer and inspect actual QBE/machine work removed. Check
   affected and unaffected hosted compiler cost before the one broad45 campaign.
4. Establish a new native checkpoint for the selected integrated source even if
   the new experiment is rejected: hosted→N1→N2 raw-QBE reproduction, focused
   ordinary gates, N2 original45, and matched native request/build timings.
   Explicitly preserve Phase123's assembler branch-boundary policy; old harnesses
   that silently use the default assembler are not valid adapters.
5. Report measured gains, failures, cost, complexity and remaining gap. Update
   documentation/frontier and commit/push scoped work. Installed production is
   unchanged unless a separate qualification justifies promotion.

## Metrics and research scope

Retain the frozen44-point geometric mean and45-program oracle. Also report mean
positive log slowdown, family weighting, fixed-batch sums/positive excess,
counts above1.1×/2× and worst regressions. Distinguish source ceilings from
original-source automatic gains, hosted emission cost from native compiler
throughput, and compiler improvements from recursive research acceleration.

1× scope is one general reconstruction-elimination capability plus native
qualification.10× ambition is a reusable ownership-preserving composition plan
that transfers to unrelated containers/compiler computations.100× ambition is
virtual intermediate computations across producer/consumer and continuation
boundaries. These are scope labels, not speed estimates; expand only after cheap
evidence. No universal IR rewrite or additional backend is authorized by this
design's hypotheses alone.

One root-owned CPU3 target lane; ordinary2GiB RSS,16GiB available floor,64MiB
file limit. Full image only after disk audit, with6GiB/16GiB/128MiB limits justified
by Phase118's measured5.385GiB peak. Fresh immutable evidence; exact byte-identity
dedup may recover space without deleting paths. Agents perform bounded disjoint
offline work. Account for target execution, failed attempts, wall time and agent
work separately; billing/quota is not inferred from wall time.
