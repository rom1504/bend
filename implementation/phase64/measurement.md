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
