# Phase64 measurement record

The frozen starting compiler is Phase63 State09 at `fd01066`: genuine B2
`e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003`, generated
from checked equality-derived B1
`4a208bffcf47b5d19f8ff18be1fc01b2faf988b37d38e7f5db9e6bd42d79905f`.
The previous completed broad campaign measured 1.63275× TS compilation time
and 1.15092× imports-plus-first-compilation time. These are inherited Phase63
results, not new Phase64 observations.

The first Phase64 loop is Numeric, Lexer and MapSet. It separates clean fresh
process timings from exclusive stage clocks, CPU samples and allocation samples.
All use exact qualified raw-module output checks and the same pinned upstream
TS source, Node24.18.0 and CPU3 guard. Root alone executes targets. Measurement
agents prepare and analyze files on CPU0.

The [method and commands](../../selfhost/tools/performance/phase64/latency/README.md)
reuse frozen Phase63 runners. Method01's derivation SHA256 is
`3f631cd26cc6086be7b16e1dd224bebb2a577e50955b648d415c4e3a9897a958`; baseline
recipe SHA256 is
`9ab02ba7a7e011e3281067920a750a36721d0fb1e9cbc6fc341827f7e6adf5fd`.
Only Phase64 output paths and immutable audit bindings change. Selected driver
and API bytes, timing boundaries, cache preparation, profile sampling and raw
oracles remain unchanged. Source agents can edit live compiler files while
baseline audit imports remain bound to State09's checked snapshot.

The candidate build/export factories preserve the 94 selected checked exports;
additional exports require explicit source-backed admission. Root froze and
built the isolated TODO-world State01 candidate, then supplied its completed
94-export reference. The State01 B1 recipe compares actual State09 B1 against
the new checked B1 and pinned TypeScript. Its binding records are ready; no B1
timing result is claimed yet. No compiler target has been executed by this
report's author.

## Fresh State09 baseline

The first Phase64 baseline completed 12 clean workers: three sources, two roles,
two balanced rounds. Every worker reproduced its role's complete qualified module
bytes. The comparison uses prepared persistent Base caches and a fresh process
per request; preparation is excluded from these clocks.

| Source | State09 B2 compilation | TypeScript compilation | B2 / TS | Import + API + compile ratio |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 378.50 ms | 338.66 ms | 1.118× | 0.783× |
| Lexer | 780.59 ms | 403.73 ms | 1.933× | 1.297× |
| Map/set operations | 1201.52 ms | 641.46 ms | 1.873× | 1.437× |

These medians establish this campaign's three-source baseline, not a replacement
for the inherited 23-source result. The clean campaign took 13.99 seconds and
its maximum process-tree RSS was 156.08 MiB.

The six CPU profiles passed their raw-output gates. Exact named ancestry assigns
each sample once to a semantic stage. On Numeric/Lexer/Map, sampled plan-selection
cost was 53/169/411 ms, source completion 36/192/203 ms, and prepared cache work
100/109/110 ms. Map also sampled 112 ms in host wrappers, 111 ms in annotation,
and 54 ms in layout proof. This makes plan construction and definition lowering
the largest variable backend target; wrapper fusion alone cannot explain the
whole deficit.

The later [property-demand investigation](demand-findings.md) explains why a
cache-only lazy decoder is unlikely to deliver a large gain in the current
pipeline: each request reads about 96% of the 46,757 eagerly decoded nodes.
Whole-book TODO handling and context reconstruction account for much of that
demand. Context construction visits bodies of the same 503 definitions on all
three inputs. Reducing those traversals must precede a serious selective-decoding
proposal; the proxy counters themselves are not timing or allocation estimates.

The [CPU census](evidence/baseline-state09-cpu.json) keeps CPU counts independently
of timestamp weights. TypeScript Map's signed timestamp policy refused weighted
times, so that row has counts only. The other five profiles admit weights. These
are instrumented first-window samples including imports, not clean latency or
direct estimates of removable work. Shared SCC dispatcher names are not treated
as proof that a particular member function caused the cost.

The [allocation census](evidence/baseline-state09-allocation.json) estimates
32.35/70.22/160.09 MB for Numeric/Lexer/Map, versus 55.81/66.03/109.78 MB for
TypeScript. The ratio is therefore 0.58×/1.06×/1.46×, despite all three having
slower Bend compilation. Allocation volume alone does not explain the deficit.
For Map, disjoint plan selection, layout proof and host-wrapper scopes account
for 30.5%, 14.1% and 8.5% of sampled allocations. Lexer constructor-lookup
ancestry accounts for 15.5%; that independent union overlaps semantic scopes.
All six allocation profiles retain the discrepancy between sampled bytes and
tree self-size accounting. We use `samples[].size`, never mix the two totals,
and do not translate allocation shares directly into predicted time savings.

The [stage observer](evidence/baseline-state09-stages.json) passed all six
complete output comparisons. On each Bend input it observed one prepared-world
checker call, one frontend-ready seed call, and one plan selection followed by
one plan-library call. Positional ABI encode/invoke/decode clocks are zero for
this named-layout image. Instrumented Map compilation breaks down into 349.65 ms
plan selection, 190.18 ms source completion, 160.25 ms checking, 113.45 ms cache
admission/decoding, 88.92 ms annotation, 78.48 ms final library and 53.29 ms layout
proof, plus the remaining stages. These exclusive scopes do not double-count
their children. Their instrumentation and one-sample scope make them diagnostic;
the separate clean medians above remain the performance comparison.

The clean summary, all profiler rows and all stage rows verify saved full module
bytes against the existing role-qualified output references. This is a strong
compilation-output check, not a new execution of every generated program or a
complete conformance run.

## State01 isolated TODO-world candidate

The [same-generation B1 comparison](evidence/state01-b1-three.json) passed all
27 complete module comparisons: three sources, State09 B1, State01 B1 and
TypeScript, over three balanced role rotations. State01 changes prepared-world
TODO handling while retaining the baseline host-wrapper implementation.

| Source | State09 B1 | State01 B1 | Change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 384.15 ms | 372.56 ms | −3.02% |
| Lexer | 727.72 ms | 717.79 ms | −1.36% |
| Map/set operations | 1475.18 ms | 1457.52 ms | −1.20% |

The equal-source geometric mean of median ratios is 0.98136 for compilation and
0.98918 for imports plus compilation. This is a small encouraging B1 result,
not evidence that the eventual genuine B2 has improved by the same amount.
The next candidate can use the explicit-baseline factory to compare against
State01 directly, isolating host-signature fusion without repeatedly running
TypeScript for each prototype.

## State02 isolated host-signature fusion

The [State02 versus State01 B1 comparison](evidence/state02-vs01-b1-three.json)
passed all 18 complete module comparisons. Both roles are actual checked images;
TypeScript was omitted from this incremental attribution loop. It ran three
rounds per source, so role positions are not perfectly balanced over those
three rounds.

| Source | State01 B1 | State02 B1 | Change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 375.49 ms | 370.17 ms | −1.41% |
| Lexer | 777.75 ms | 763.04 ms | −1.89% |
| Map/set operations | 1478.74 ms | 1467.02 ms | −0.79% |

The equal-source median ratio is 0.98633 for compilation and 0.98786 for combined
imports and compilation. These small point estimates need confirmation in the
selected genuine B2; they do not establish that host fusion closes a substantial
part of the deficit. State03's next loop uses four rounds and 24 workers, giving
each of the two roles equal early and late positions. The source selection and
raw output checks remain unchanged.

## Subsequent incremental B1 screens

The following screens use four balanced rounds, three sources and the preceding
candidate as baseline: 24 fresh workers each. Figures are changes in median
compilation time, with negative values meaning less time. Each summary retains
individual samples; small changes remain provisional until a selected B2 is
compared directly against the frozen State09 B2 and TypeScript. Ratios from
different campaigns are not combined into a claimed cumulative speedup.

| Candidate / baseline | Change | Numeric | Lexer | Map | Equal-source ratio | Exact outputs |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| [State03 / State02](evidence/state03-vs02-b1-three.json) | Filter already-owned definitions | −4.01% | −0.76% | −0.81% | 0.98128 | 24/24 |
| [State04 / State03](evidence/state04-vs03-b1-three.json) | Avoid constructing discarded child types | +3.75% | −3.06% | +6.58% | 1.02344 | 24/24 |
| [State05 / State04](evidence/state05-vs04-b1-three.json) | Name-membership rejection guards | −1.25% | −1.73% | −2.07% | 0.98320 | 24/24 |
| [State06 / State03](evidence/state06-vs03-b1-three.json) | Membership guards after removing State04 | −0.56% | −1.40% | −2.71% | 0.98439 | 24/24 |
| [State07 / State06](evidence/state07-vs06-b1-three.json) | Skip discarded argument values in tail selection | −5.80% | −1.79% | +0.06% | 0.97460 | 24/24 |
| [State08 / State07](evidence/state08-vs07-b1-three.json) | Reuse the prepared bound for context construction | −1.63% | −1.68% | +0.14% | 0.98944 | 24/24 |
| [State09 / State08](evidence/state09-vs08-b1-three.json) | Indexed frame4 cache decoding | −17.59% | −6.44% | −1.35% | 0.91281 | 24/24 |

For State03, Numeric's source medians are 389.88 → 374.26 ms, with overlapping
sample ranges. Lexer changes 705.61 → 700.23 ms and Map 1449.64 → 1437.90 ms.
The combined import-plus-compilation ratio is 0.98319. This supports retaining
the candidate for further evaluation without treating the point estimate as a
precise standalone gain.

State04 is **rejected by the current B1 performance gate**: Numeric and Map
regress, and the equal-source combined ratio is also worse at 1.02374. The
independent structural controller's substantial avoided substitution and weak
head normalization queries do not override the measured regression. The effect
on a genuine B2 has not yet been measured, so this is not a claim that the idea
must regress every generated compiler image. Any State05 measurements built on
State04 must be rechecked after removing State04 before selecting that bundle.

For planning a possible B2 ablation, the closed Phase63 State09 bootstrap guards
took 27.63 seconds for tiny equivalence, 55.39 seconds for the full image, and
26.84 seconds for both driver probes: 109.86 seconds total. Two earlier Phase63
candidates took 122–123 seconds. Thus two genuine images from existing checked
B1 attempts plus a short comparison should take roughly four to five minutes,
not a full broad qualification campaign. This is a cost estimate from historical
receipts, not a new target execution or a guarantee for changed source.

State05's membership point estimate is encouraging but was measured on the
rejected State04 base. State06 removes the discarded-type change; its direct
comparison with State03 reproduces a small beneficial direction, with a
compilation ratio of 0.98439 and combined ratio of 0.98513. Absolute timing also varies
across campaigns: the same State04 B1 Map image measured 1555.05 ms in the
State04 comparison, then 1440.51 ms as State05's baseline. That 7.4% difference
is larger than several incremental point estimates. We do not know its cause
from these receipts. It strengthens the need for paired same-campaign comparisons
and a direct final B2 comparison, and argues against multiplying small successive
ratios into an asserted cumulative improvement.

The [State04 staging audit](evidence/state04-staging-audit.json) rehashed both
108-file prepared projects. API, driver, cache helper, source, runtimes and Base
are identical. The book segment (917,613 bytes) and prepared segment (280,034
bytes) are byte-identical and match their header digests. The only header
difference is the generation timestamp; source inspection shows that admission
does not test that field. All four Map source/oracle/output joins on each side
also match. Physical module paths differ, as recorded. These facts rule out
different recorded compiler/cache/source contents; historical clean workers did
not instrument optional API paths, so the audit does not invent such observations
or establish the cause of the timing shift.

The [fresh same-State04 A/A comparison](evidence/state04-aa-b1-map.json) then
passed all 12 complete output checks over six balanced Map rounds. Its identical
images nevertheless measured medians of **1422.94 and 1477.31 ms**, an apparent
3.82% difference; combined imports plus compilation differed by 3.66%. Most
candidate-role second-position samples were about 1490 ms, while first-position
samples were 1414–1466 ms. Both positions were represented equally. Within this
run, several slower samples also had lower peak RSS, while API import times
stayed close to 52 ms; that correlation is not proof of a GC cause and does not
explain the earlier cross-campaign shift.

This A/A result places the 1–3% B1 point estimates within demonstrated local
variability. They are useful screening signals and retain their exact output
checks, but are **not established isolated speedups**. State07's Numeric
improvement is larger, while its Map result is essentially unchanged. Final
selection must use a direct genuine-B2 comparison against the frozen baseline,
with broader repeated coverage, rather than a product of these small B1 ratios.

State09 provides the clearest B1 result: it has **the identical compiler API
bytes as State08**, while replacing the staged cache encoding/decoding path with
frame4. Compilation medians change 368.16 → 303.39 ms for Numeric, 665.47 →
622.62 ms for Lexer and 1431.76 → 1412.43 ms for Map. The equal-source ratio is
0.91281, and imports plus compilation gives 0.92456. Numeric's 17.59% reduction
is substantially larger than the observed A/A difference; Map's 1.35% change
remains within that variability. The 24 complete output checks all pass. Root
selected State09 for genuine B2 generation and full qualification; those later
results are not inferred from this checked-B1 screen.

## Selected genuine B2: final 23-source comparison

The [completed direct B2 campaign](evidence/state09-b2-broad.json) compares
Phase63 State09 B2, Phase64 State09 B2 and pinned TypeScript in one balanced
campaign. All **207/207** fresh workers reproduce their complete role-qualified
output modules: 23 sources, three roles and three rounds. Each source has equal
weight in the geometric mean of its within-source median ratios.

| Clock | Previous B2 / TS | Selected B2 / TS | Selected / previous B2 | Sources improved |
| --- | ---: | ---: | ---: | ---: |
| Compilation after imports | 1.64387× | **1.43894×** | 0.87534× (−12.47%) | 23/23 |
| Host import + API import + compilation | 1.18920× | **1.06173×** | 0.89281× (−10.72%) | 23/23 |

The [source-by-source plot](compilation-ratios.svg) shows both clocks. On all
23 sources, the slowest of the three candidate samples is faster than the
fastest of the three baseline samples, for both clocks. This is a descriptive
property of the saved sample ranges, not a confidence interval.

Compilation reductions range from **3.74% to 20.95%**, while combined reductions
range from 3.49% to 16.45%. Candidate compilation relative to TypeScript ranges
from 0.87374× to 1.86289×. Numeric recurrence is faster than TypeScript in this
campaign; local-fold is essentially at parity (0.99856×). The other 21 sources
remain slower. Five sources are below TypeScript on the combined clock.

| Source | Previous B2 | Selected B2 | TypeScript | Selected B2 / TS |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 330.07 ms | 260.93 ms | 298.64 ms | 0.874× |
| Lexer | 694.14 ms | 580.86 ms | 351.34 ms | 1.653× |
| Map/set operations | 1096.65 ms | 1034.93 ms | 581.38 ms | 1.780× |
| Local fold | 379.72 ms | 309.87 ms | 310.32 ms | 0.999× |
| Active raytrace | 936.83 ms | 901.75 ms | 484.06 ms | 1.863× |

This directly measured bundle result replaces any attempt to compound the small
B1 screens. It is stronger evidence of a broad gain: every source improves, and
the aggregate change exceeds the earlier A/A discrepancy. It does not establish
a precise independent contribution for each retained change or turn the
three-round sample into a confidence interval. The largest remaining relative
deficits occur on larger compilation workloads rather than Numeric's small
fixed-cost case.

The campaign completed in **218.52 seconds** (3 minutes 38.5 seconds), excluding
persistent-cache preparation. Maximum worker process-tree RSS was **166.18 MiB**.
Every measured request starts a new process with an already prepared persistent
Base cache; this is neither a cache rebuild nor a long-running warm compiler.
Compilation excludes host/API imports; the combined clock adds those two actual
imports, not shell launch or process shutdown. These results measure compiler
latency, **not generated-program execution speed**. Full emitted-output equality
preserves the tested artifacts; fresh semantic, generated-program and release
qualification are separate gates.

Both measured images are genuine Bend-emitted B2 artifacts. The selected image
is `b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`;
the baseline is `e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003`.
Method02 admits frame4 cache filenames while retaining the selected frozen
driver's decoder as the authoritative validator, along with all timing and
output checks. The compact evidence pins the original campaign, config, method
and actual image lineage, and retains every sample used in the medians.

## Time accounting, interim

The [closed-guard account](evidence/time-account-interim01.json) covers the
campaign start at 22:49:46 UTC through 23:37:10 UTC on 2026-10-07. The cutoff is
an intermediate observation, not phase completion. Of 47 minutes 24.6 seconds
elapsed, the union of 294 closed target guard intervals occupied 20 minutes
27.8 seconds, or 43.16%. Two receipts failed. Nested guards and reused receipts
are not double-counted.

The remaining 26 minutes 56.8 seconds is unclassified time, including source
implementation, tool preparation, analysis, review and activity not represented
by these guards. It is not a measurement of waiting, idle time or CPU utilization.
Data analysis used CPU0 while root alone ran guarded targets on CPU3. The phase
used short three-source B1 screens to avoid generating a genuine B2 and running
a broad campaign for every proposal, and an A/A falsifier to expose the limits of small
timing deltas before final selection.

## Final target accounting and preservation

After all selected compiler, semantic, release and helper-integrity targets
closed, the [final guard account](evidence/time-account-final.json) records the
interval from 2026-10-07 22:49:46 UTC through 2026-10-08 00:04:59 UTC:
**75 minutes 13.5 seconds**. The union of 669 closed guard receipts occupies
**36 minutes 22.6 seconds (48.36%)**. Two failed receipts remain recorded; there
are no unfinished, later-finished or unreadable guard receipts at this cutoff.
The remaining **38 minutes 50.9 seconds** is unclassified implementation,
analysis, review and other unobserved work. It is not measured waiting or CPU
utilization. Documentation, evidence archival and Git publication after this
cutoff are outside this time account.

The [preservation verification](evidence/closed-evidence-preservation.json)
rehashed all **16,691** files in closed Phase63 against its published archive
manifest: 521,756,245 bytes, with no missing, additional, changed or symbolic-link
entries. The published 78,204,174-byte archive also retains its recorded hash.
All **110** inherited protected files match the Phase64 baseline, covering
58,178,385 bytes. The verification made no changes to Phase63 or protected files;
its compact raw receipt and tracked copy are byte-identical. Final Phase64 raw
closure and archival remain root's separate publication step.
