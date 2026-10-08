# Phase64: typed facts and compact compiler state

Started October 7, 2026 at 22:49:46 UTC from `fd01066`.
The user authorized the [proposal](../../design/phase64/typed-facts-and-compact-state.md).

**Measured result: 12.47% less compilation time**, from 1.64387× to **1.43894×
TypeScript**, using genuine B2 images in the same balanced 207-worker campaign.
Including imports, the ratio improves from 1.18920× to **1.06173×**. Every one
of the 23 sources improves. Complete emitted modules and runtime bytes remain
unchanged; this is a compiler-speed result, not a new program-speed claim.

The selected Phase64 State09 passes full checked/B2 semantic gates, fresh
own-source type acceptance and exact B2/B3 reproduction. It is **installed and
verified**, including legacy42/default24 and five helper-integrity controls.
Read the [final report](state09-results.md), [chart](compilation-ratios.svg),
[performance receipt](evidence/state09-b2-broad.json),
[compiler qualification](evidence/state09-qualification.json),
[release receipt](evidence/state09-release.json) and [size audit](size.md).

Root serializes guarded CPU3 targets; independent agents own Base facts, backend
facts, cache/representation probes, measurement tools and semantic review.
The baseline campaign records and verifies all 110 inherited unrelated files
and seven installed artifacts before any production edit.

Results distinguish diagnostic evidence, clean compiler time, correctness,
generated-program execution and promotion. Closed Phase63 raw evidence remains
unchanged; fresh outputs live under `selfhost/build/phase64/`.

The checkpoints below preserve what was known at each intermediate stage. Their
pending statements and local B1 estimates are superseded by the final report.

## First checkpoint: isolate work before changing representation

The fresh State09 B2 three-source baseline passes all 12 exact-output workers.
Compilation is 1.118× TS on Numeric, 1.933× on Lexer and 1.873× on Map.
These three sources are a fast discriminator, not the previous 23-source
headline. CPU/allocation/stage profiles agree that backend planning, source
completion and cache loading deserve attention; parsing is not the main target.

Two independent checked-B1 experiments have small clean benefits:

| Increment | Numeric | Lexer | Map | Equal-source geometric mean |
| --- | ---: | ---: | ---: | ---: |
| Original Base TODO count retained (State01 vs State09) | −3.02% | −1.36% | −1.20% | −1.86% |
| Reuse host telescope heads (State02 vs State01) | −1.41% | −1.89% | −0.79% | −1.37% |

The first comparison has 27 workers, three roles and three rotating rounds.
The second has 18 workers and two roles; its odd round count is not fully
position-balanced. These modest B1 changes do not establish a B2 improvement
or justify multiplying gains from separate campaigns.

Base completion, host telescope and cache admission controls pass. Two initial
diagnostic controllers failed preflight because their expected private helpers
were absent from generated images; corrected successors use the actual
reachable paths and pinned reference helpers. Both failures are preserved.
No production semantic failure was observed in those controls.

The next experiments remove type derivation immediately discarded by annotated
children and replace two allocation-heavy constant name searches with exact
classifiers. Full fallback semantics remain. Compact annotations are deferred
pending evidence: their producer accounts for only 0.8–4.1% of sampled
allocations. An isolated eager indexed cache reader is being tested before any
production format change. State09 remains installed.

See [measurement evidence](measurement.md), [Base facts](base-facts.md),
[typed facts](typed-plan.md), and [focused controls](controls.md).

## Second checkpoint: reject removed work that costs more

The discarded-child-type candidate passed 259 complete consumer comparisons
and two full-module comparisons, but its paired B1 screen was 2.34% slower
overall and 6.58% slower on Map. It was rolled back in State06. Fewer
normalization/substitution calls did not establish a speedup; added guards and
trampolines are a source-level explanation to investigate, not proven causation.

The two name classifiers retain a small beneficial direction after that
rollback: State06 versus State03 is 1.56% faster across the three B1 sources,
with all 24 outputs exact. Absolute timings also drift between campaigns;
an identical-image A/A control and final direct B2 comparison are required
before interpreting the small incremental estimates as release gains.

The isolated indexed reader passes 18 graph/corruption controls and eight fresh
decode workers. Four alternating pairs give median 129.25 ms for frame3 versus
71.16 ms for the indexed representation. This roughly 58 ms saving includes
read/hash/validation/materialization, but excludes driver/API import and
semantic admission. Production integration and whole-compilation measurement
remain pending.

State07 removes argument rendering whose strings were discarded by tail-call
admission. Its checked build and focused output controls pass. State08 retains
the exact maximum ID of checked Base output so context construction can scan
only the actual assembled suffix. Its strict checked build passes with the
source-backed 95th private export; focused context and host-admission controls
remain pending at this checkpoint. No new compiler is installed.
