# Phase64: what the evidence establishes

The selected Phase64 State09 genuine B2 reduces compilation time by **12.47%**
against the frozen Phase63 State09 B2 in the final same-campaign comparison.
All **207 complete output checks pass** across 23 sources, three roles and three
balanced rounds. This establishes a useful bundle improvement; it does not
establish the contribution of each retained change.

| Clock | Baseline / TypeScript | Selected / TypeScript | Selected / baseline |
| --- | ---: | ---: | ---: |
| Compilation | 1.64387× | 1.43894× | 0.87534× (12.47% less time) |
| Host/API imports + compilation | 1.18920× | 1.06173× | 0.89281× (10.72% less time) |

These are equal-source geometric means of within-source median ratios. Both
clocks improve on all 23 sources; every candidate sample is faster than every
baseline sample on its corresponding source. Per-source median compilation
reductions range from **3.74% to 20.95%**. This breadth and sample separation
support the bundle result more strongly than the small B1 screens, while three
rounds still do not supply a robust statistical error bound.

The selected compilation ratios range from **0.87374× to 1.86289× TypeScript**;
two of the 23 sources are faster than TypeScript. Numeric is 330.07 → 260.93 ms,
against TypeScript's 298.64 ms; ray tracing is 936.83 → 901.75 ms, against
484.06 ms. Roughly another **30.5%** compilation-time reduction would reach
parity on this aggregate; that is arithmetic, not a forecast.

The inherited Phase63 headlines were 1.63275× and 1.15092×. Their absolute
difference from this campaign's baseline is a reminder to use the new
same-window comparisons above, not subtract ratios from separate campaigns.
The [verified summary](evidence/state09-b2-broad.json) and
[two-clock figure](compilation-ratios.svg) retain the actual selected results.

## Proposed gains versus measured work

| Proposal | Current evidence | Interpretation |
| --- | --- | --- |
| Retain completion/policy facts: planned 3–8% | TODO retention has a 1.86% three-source B1 point estimate; prepared context-bound reuse has a 1.06% incremental estimate | These implement smaller boundaries than the full proposal. Neither estimate establishes the proposed whole-request gain. |
| Share typed backend facts: planned 15–30% | Host-signature reuse estimates 1.37%; owned-definition filtering 1.87%; argument-rendering avoidance 2.54%. The discarded-child-type variant regresses 2.34% and was removed. | Less logical work can cost more. The surviving local changes do not demonstrate a unified typed pipeline or its proposed gain. |
| Change prepared Base representation: planned 6–15% | The isolated eager indexed reader measures 129.25 → 71.16 ms; integrated State09 versus State08 gives an 8.72% three-source B1 point estimate | Integration establishes a larger whole-request signal with identical compiler API bytes. The final B2 comparison establishes the combined bundle's benefit, not a separate B2 attribution for the reader. |
| Compact nodes/owned scratch storage: planned 8–20% | Annotation production is only 0.8–4.1% of sampled allocations; no broad compact-core or owned-arena speed result | No measured gain for this proposal. Allocation shares and static node counts are not removable-time estimates. |

The estimates are reductions in separately measured median ratios, not additive
components. They must not be added or multiplied into a cumulative release
speedup. The final candidate also changes interactions among cache loading,
object allocation, checking and backend work.

Actual demand further narrows the representation hypothesis: Phase63 State09 requests
read about **96% of decoded nodes**. A static count of nodes reachable without
bodies overstates the available lazy-loading benefit while full-book completion
and context scans still demand those bodies. The eager reader can help without
establishing that laziness or a general representation rewrite will help.

## Small differences need a direct final comparison

The identical-image State04 A/A experiment passes all 12 output checks but has
Map medians of **1422.94 and 1477.31 ms**, an apparent **3.82% difference** over
six balanced rounds. The same State04 image also differed by about **7.4%**
between two earlier campaigns. The staging audit found matching compiler,
driver, cache payload, source and output bytes; it did not establish the cause.

Consequently, the 1–3% incremental B1 estimates are screening signals within
demonstrated local variability, not established isolated speedups. State07's
Numeric improvement of 5.80% is larger, while Map is essentially unchanged.
The A/A result is neither a universal 3.82% error bar nor a correction to subtract
from every result. It provides a concrete reason to preserve samples, inspect
role/order effects and compare the selected bundle directly in one campaign.

The three sources were reused while selecting candidates. Even exact results on
them do not show how improvements transfer to the other 20 sources. A genuine
B2 also executes compiler code emitted by our compiler, whereas these checked
B1 screens execute upstream-generated compiler code; transfer is an empirical
question. All detailed clocks and the rejected State04 remain in the
[measurement record](measurement.md).

The integrated cache comparison is stronger than the earlier local screens:
State09 and State08 have identical B1 compiler API bytes, while the host cache
path changes. Numeric improves **17.59%**, Lexer **6.44%**, and Map **1.35%**;
all 24 complete outputs match their qualified oracle. This is consistent with
reducing a substantial fixed request cost, which matters more on short
compilations, but these three points do not isolate every allocation or JIT
effect. The small Map estimate retains the same noise limitation.

The selected bundle retains seven bounded changes: prepared TODO count,
host-telescope reuse, filtering native definitions before the existing ownership
queries, exact fixed-name classifiers, omission of discarded argument strings,
the checked-prefix maximum bound, and eager indexed cache decoding. These are
reuse and allocation changes at existing boundaries. The rejected child-type
guards, lazy per-node decoding, a general typed IR, compact core nodes and an
owned normalization arena are not evidence-backed achievements of this bundle.

## Qualification and interpretation boundaries

1. **Same-campaign speed:** the broad result above includes genuine selected B2,
   frozen Phase63 State09 B2 and pinned TypeScript on all 23 unchanged sources
   in balanced role rotations. The summary retains absolute medians and all
   samples. There is no excluded failure or surviving-subset headline.
2. **Clock and cache scope:** compilation excludes host/API imports; the combined
   clock adds those actual imports. Both use prepared persistent caches and
   fresh request processes. Cache preparation, a cache miss, CLI end-to-end
   process latency and persistent warm-request throughput are other measurements.
   Neither headline represents all of them.
3. **Behavior and lineage:** all 207 complete emitted modules match their admitted
   role-specific oracles. That does not by itself show equal outputs across roles,
   full language conformance or program execution correctness. Selection also
   needs the registered checked/B2 semantic gates, native controls, 45-point
   runtime checks, own-source type/trust result, exact B2/B3 reproduction, and
   ordinary/relocated release checks.
4. **Generated-program scope:** these clocks measure how fast a compiler emits
   code. They do not measure how fast the emitted code runs. Identical complete
   program modules and runtimes can establish unchanged artifacts; if either
   changes, execution qualification and the representative runtime benchmark
   must be rerun before claiming preserved or improved execution speed.

Three rounds per source give descriptive medians, not a strong significance
claim for a marginal change. A broad, consistent same-campaign improvement is
stronger evidence than multiplying local screens, but still applies to this
fixed corpus, machine, cache state and process boundary. The equal-source
geometric mean weights sources equally; it is not the time saved compiling a
particular production workload.

## Final figure

[The plotting tool](../../selfhost/tools/performance/phase64/latency/plot-broad.py)
consumes the measurement owner's verified compact summary. It requires a full
23-source, three-role campaign with genuine direct-image lineage, verifies all
sample medians and aggregate ratios, and draws baseline/selected ratios to the
same TypeScript denominator for both clocks. The final SVG and its
[receipt](compilation-ratios.svg.json) bind the source-summary and raw report
hashes. Independent recomputation directly from the 207 raw rows agrees with
the summary's medians, geometric means and source counts. Figure generation
and this analysis run only on CPU0 and execute no compiler or generated program.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase64/latency/plot-broad.py \
  --summary implementation/phase64/evidence/state09-b2-broad.json \
  --out /tmp/NEW-phase64-compilation-ratios.svg \
  --candidate 'Phase64 State09 B2'
```

The figure is a data rendering, not a replacement for output, lineage, semantic
or installation qualification.
