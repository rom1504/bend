# P128-002: eliminate repeated native preparation

Hypothesis: reuse an immutable raw candidate list across initial and late
closure, rather than reconstructing the checked request and candidates twice.
Preserve initially rejected candidates and apply SCC rewriting at its original
use; sharing only admitted or transformed candidates is not equivalent.

Selected implementation: `phase128/sharedprep/{raw-session,combination}.bend`.
One observer scan collects workers, summaries and retry plans. The separate
`reachability/plan.bend` builds an existing exact-name index once while preserving
definition order, payloads and duplicates.

Complete emitted QBE remains byte-identical on Map, RLE and tree. Three paired
same-request Map integrated measurements 5.323363 → 4.721370s save 11.31%; frontend
and initial preparation are outside that clock. Reachability has 20 finite
controls including Unicode and exact hash collision; no isolated native ratio
is claimed for it. The final composition passes native self-reproduction.

Negative result: late-flat-only skipping gives an inconclusive 1.42% hosted
request change, 0.51% integrated; excluded. Frozen failures and evidence:
`selfhost/build/phase128/sharedprep-pairs01.json`,
`preparation-hosted01/report.json`, and the Phase128 evidence capsules.

Cost boundary: retaining raw candidates can increase live memory. Final native
acquisition stays within the 6GiB guard, but different host runtimes prevent
isolating a memory improvement. See the [report](../../implementation/phase128/README.md).
