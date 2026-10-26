# Phase144: remaining opportunities after the final measurements

The latest clean final04 request takes **231.682 s**, followed by **15.318 s**
of machine compilation/linking: **247.000 s** of measured target work. The
matched Phase143 parent request was304.534 s. These are actual fixed-input
observations, not estimates from sampled profiles. The input is unchanged
Phase142 source (`15f5cada…7dac1`); final04 ELF is `e2f6317b…e5d13` and its
115,914,052-byte output is `62fe55f1…adcf0`. The native-request receipt is
`selfhost/build/phase130/p144-final04-fixed-cold01/report.json`. Qualification,
program-quality gates and the installed selection are recorded separately in
the main implementation report.

The most recent complete **profile is final03**, not final04. It shows exactly
bound stage markers,8,681 samples, zero dropped/overrun samples and99.497%
CPU-window coverage. Its279.524-second diagnostic execution compares with its
own251.861-second clean execution. Do not scale its individual clocks by the
new whole-request ratio or credit final04 changes again. There is no reason to
pay for another full profile merely to restate the current opportunity list.

## What remains large

Final03 diagnostic intervals include parse/load33.411 s, checking/publication
33.826 s, raw lowering37.578 s, initial optimization37.352 s, first independent
verification18.895 s, and render/output/teardown49.962 s. Registry adds17.651 s;
other frontend and observer stages account for the balance. The optional final
verifier's10.081 s is nested in observer work and must not be added again.

No single observed partition can supply a50-second compiler. The earlier
`f_find` and constructor-ownership scan removals have already happened. The
serial runtime already reduced measured drop/fade work from24.53% to17.04% of
samples. The remaining take, reconstruction, string and register costs overlap
these stages; they are not independent percentages to add or multiply.

## Ranked next experiments

The times below are **bounded research allocations**, not commitments to a
successful implementation or forecasts of production speedup.

| Priority | Structural change and useful scope | Evidence / gain ceiling | Decisive experiment and budget |
| --- | --- | --- | --- |
|1|Carry producer-owned local IDs and compact semantic facts through verification **and one optimization consumer**.|Initial optimization plus first verification occupies56.247 diagnostic seconds. Existing compact-verifier native slice improves11.06%, but transferring only that improvement to the sampled14.08% verifier family would save roughly1.6% overall, conditionally. A larger gain requires removing repeated names, wide-record projection and allocation across consumers, not merely copying the prototype.|Spend45–90 min on one complete real-function path, then one unrelated function family: include ID creation, first-error diagnostics, joins, consumer updates and teardown. Keep original independent final verification. Integrate only after net native gains and comparable machine quality; allow2–4 h for a narrow integration, not a universal IR rewrite.|
|2|Write existing typed output fragments through a bounded generic UTF-8 sink, preserving Bend formatting.|Registry plus output occupies67.614 diagnostic seconds, an upper budget containing much work the sink will not remove. Final03 output still performs destination extension, take, fill and reclamation. Its guarded concat helper accounts for147 physical samples,133 inside rendering; final04 already changes that policy, so this is not a fresh4.7-second gain to claim.|Spend45–90 min replaying complete real generated bodies, including conversion, buffering, final output hash and destruction. Test short writes, second-write failures, Unicode and ownership. A successful full producer-to-sink prototype may justify2–4 h integration. Avoid one IO operation per fragment or another whole-string batch join.|
|3|Make inner range-analysis effort conditional on actual downstream use.|Omitting the outer pass already measured4.74% less cold compiler time and is part of the later composition. Three small wrappers had identical machine code; the full compiler still had three genuinely changed worker instruction sequences. Thus QBE removes some, not all, range-derived improvements.|Spend30–60 min recording actual changed-body publication,node/stack admission and subsequent substitutions on retained real requests. Reject removal if it changes helper availability or hot machine quality. Do not assume the remaining inner pass is redundant because the outer one was often redundant.|
|4|Use the constructor-existence result to guide further shared-fact work; the measured prefix-disjoint adapter is already included in final04.|Four hosted pairs on actual256/1,024-declaration prefixes reduce complete disjoint-consumer inclusive time to about0.159/0.134 of original. Rebuilding per-event facts instead loses about11%/8%; that branch is rejected. Profile exposure is only a few diagnostic seconds, not the whole34-second checker.|No additional gain is credited for the integrated adapter. Spend20–40 min only if an unrelated complete batch with repeated queries is found. Preserve per-parent first-match/Absent/cache semantics; reject per-event rebuilding. The hosted result is not an isolated native or full-compilation gain.|

Final04 source `865cff6a…745c4ed` overrides `base_prefix_ctor_disjoint`,
`p114s_ranges` and `p125p_admitted`; those three changes are already in the
231.682-second result. Its ordinary-route and incremental-session optimization
policies differ. Historical cross-route byte equality failed and incremental
qualification remains false; the ordinary result does not erase that limitation.

The first row is the best next architectural discriminator. A local number
assigned once is useful only if later passes consume it without reconstructing
strings or9-field `KDef` records. Keep a name table for diagnostics, exact
constructor/global context and the existing independent verifier. Test a full
sequence such as producer → local verification/state join → optimization
consumer, not isolated map lookups. Measure allocation/reclamation and total
execution with preparation included. Retire the losing representation rather
than maintaining a second whole verifier indefinitely.

This also addresses the strongest lesson of the compact experiment: its first
representation lost eligible direct workers and saved only1.9%; explicit
sum-shaped entries restored the workers and yielded11.06%. Representation,
compiler admission and resulting machine execution must be tested together.
Production hot helpers already have direct workers, so missing specialization
cannot be assumed to explain the entire remaining deficit.

For output, keep the compiler and renderer in Bend. The proposed runtime
boundary is general bounded byte marshalling, not a second compiler or a
host-language QBE printer. Registry itself includes several continuation-region
analyses; eliminating output materialization cannot remove all its17.651 s.

## What the larger ambition requires

Against final04, compiler-only50 s requires another **4.63×** improvement.
If50 s includes the measured15.318-second machine/link tail, the compiler gets
34.682 s and must become another **6.68×** faster, assuming that tail stays
fixed. Neither is an evidence-backed forecast.

Getting there would require several broad removals: avoiding repeated semantic
reconstruction through multiple passes, preserving compact facts across those
passes, and emitting without full linked-string materialization. Parallel owner
work is a later possibility, after measuring serial preparation, largest-owner
cost, transport and memory. Previous cold unit partitioning was slower; simply
adding workers is not a demonstrated solution. A new backend or another cache
framework does not yet have a better measured case than the bounded experiments
above.

Do not repeat full native acquisition for every idea. Reuse the retained real
IR/body inputs and original semantic/error oracles; reject weak ideas in the
small native loop. One integrated full request and changed-program runtime
gates are appropriate after a slice removes measurable work and transfers to
an unrelated family. Preserve failed attempts, conversion costs and code growth.

## Evidence and accounting

- [Final03 profile and overlap limits](final-profile.md), with [pinned derived data](final-profile.json).
- [Compact-verifier positive and negative results](verifier.md).
- [Range policy, machine differences and generated-compiler check](range-policy.md).
- [Constructor-existence semantic contract](constructor-existence.md); executed consumer results are `selfhost/build/phase144/existence-summary01/report.json`. The source-only audit predates those measurements.
- [Cost-ledger method](cost-ledger-method.md). Version02 counts failed host smokes, the deadline-stopped partial program campaign and its successful resume separately; it only corrects their categories from `unknown`.

This document performs no new compiler, workload or profiling runs. Final04
clean timing is current; the detailed stage and physical-owner evidence remains
explicitly final03. The50-second goal is a requirement for future experiments,
not the sum of optimistic local estimates.
