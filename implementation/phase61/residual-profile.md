# State04 broad screen and remaining compiler work

State04 reduces the exploratory 23-source combined-first geometric mean from
**2.436343× TS to 1.702067× TS**: **30.14% less time**, or **1.4314× speedup**.
All 23 candidate observations are lower than their paired old-B2 observations.
This is one fresh observation per source/role, not a repeated broad qualification
or a significance result. Installed Phase58 remains a distinct release.

The [data-only derivation](../../selfhost/build/phase61/state04-analysis01/receipt.json)
pins the producers, campaigns, selected worker receipts, source/image identities,
complete emitted modules and raw profiles. Its
[69-worker table](../../selfhost/build/phase61/state04-analysis01/broad23.json) and
[profile accounting](../../selfhost/build/phase61/state04-analysis01/profiles.json)
preserve unrounded values. Candidate B2 is `3358e1a7…`, source `c817ed03…`,
driver `30ec69e6…`; old B2 is `a73daccf…`. Both use the same pinned TS comparison.

## Broad screen: complete triples, preserved budget failure

| Equal-source geometric mean | Old B2 / TS | State04 B2 / TS | New / old |
| --- | ---: | ---: | ---: |
| Import + ordinary API load + first compile | 2.436343 | 1.702067 | 0.698615 |
| First compile only | 3.772993 | 2.549266 | 0.675662 |

Compilation-only excludes module loading; TS does substantial work during its
compiler import. Combined-first remains the principal end-to-end comparison.
Every source receives one weight; the 45 inherited runtime points are not 45
independent compiler inputs. Each measured request freshly compared its entire
raw emitted module with the qualified role reference after timing. The existing
45-point runtime qualification was inherited, not rerun here.
This one-round screen uses baseline/candidate/TS order within each source; it is
not position-balanced and cannot estimate run-to-run uncertainty.

The [240-second campaign](../../selfhost/build/phase61/state04-b2-latency01/broad240/report.json)
remains **failed by budget**: its first 20 complete triples passed; Map-churn's TS
worker hit the deadline, and Numeric/record aggregation were skipped. Its two
successful Map-churn Bend observations are excluded from this aggregate. All
three roles for Map-churn, Numeric and record aggregation instead come from the
separate [tail campaign](../../selfhost/build/phase61/state04-b2-latency01/broad-tail60/report.json),
which passed nine workers. There are no mixed-campaign triples or pooled repeats.
Observed whole-campaign walls were 242.269 s and 34.646 s; these include work
outside compiler windows and are not the aggregate latency metric.

Combined-first milliseconds; smaller new/old is better:

| Source | Old B2 | State04 | TS | New / old | New / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| mandelbrot | 1775.6 | 1231.1 | 685.8 | 0.693 | 1.795 |
| editdist | 1602.9 | 1126.7 | 643.7 | 0.703 | 1.750 |
| tree-bitonic | 1554.6 | 1044.6 | 620.5 | 0.672 | 1.684 |
| lexer | 1628.7 | 1206.6 | 661.7 | 0.741 | 1.823 |
| symreg | 1595.8 | 1134.9 | 640.4 | 0.711 | 1.772 |
| test-morning-program | 1940.7 | 1377.7 | 833.7 | 0.710 | 1.652 |
| test-evening-program | 2235.1 | 1670.2 | 1063.8 | 0.747 | 1.570 |
| test-rle-roundtrip | 1491.4 | 1016.8 | 622.3 | 0.682 | 1.634 |
| test-map-set-ops | 2684.8 | 2260.1 | 873.5 | 0.842 | 2.587 |
| raytrace | 2071.7 | 1577.9 | 820.2 | 0.762 | 1.924 |
| local-row | 1642.1 | 1153.0 | 647.4 | 0.702 | 1.781 |
| local-fold | 1309.3 | 819.7 | 600.3 | 0.626 | 1.365 |
| scalar-region | 1451.5 | 885.9 | 610.9 | 0.610 | 1.450 |
| mandelbrot-grid | 1866.1 | 1309.0 | 687.9 | 0.701 | 1.903 |
| raytrace-active | 2131.8 | 1582.5 | 818.2 | 0.742 | 1.934 |
| closures | 1325.6 | 824.6 | 598.2 | 0.622 | 1.378 |
| list-pipeline | 1874.0 | 1332.3 | 760.3 | 0.711 | 1.752 |
| bst | 1504.8 | 1044.7 | 626.7 | 0.694 | 1.667 |
| unicode-text | 1641.4 | 1208.8 | 665.7 | 0.736 | 1.816 |
| expression | 1382.4 | 877.1 | 597.5 | 0.635 | 1.468 |
| map-churn | 1940.1 | 1390.5 | 797.4 | 0.717 | 1.744 |
| numeric-recurrence | 1255.9 | 820.0 | 628.7 | 0.653 | 1.304 |
| record-aggregation | 1981.4 | 1380.9 | 768.5 | 0.697 | 1.797 |

## Separate first-window profiles

The [CPU](../../selfhost/build/phase61/state04-b2-latency01/cpu-map-numeric01/report.json)
and [allocation](../../selfhost/build/phase61/state04-b2-latency01/allocation-map-numeric01/report.json)
campaigns each passed six fresh workers. Each captures import, ordinary API load
and exactly one first compilation, with validation after capture. No warm requests
precede profiling. Inspector durations are not clean speed measurements.

Sampled cumulative allocation, decimal MB per captured first window:

| Input | Old B2 | State04 | TS | Reduction vs old | State04 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric | 179.786 | 74.149 | 57.513 | 58.76% | 1.289 |
| MapSet | 1238.813 | 586.671 | 123.646 | 52.64% | 4.745 |

These estimates include subsequently collected allocations; they are not live
heap or RSS. Candidate sample/tree totals differ by 608 bytes for Numeric and
150,976 bytes for MapSet; both have zero unattributed sampled bytes. These are
observed accounting differences, not sampling-error bounds. Every original
warning remains in the derivation.

Candidate CPU allocation to nonoverlapping ancestor groups:

| Group, priority in a sampled stack | Numeric CPU | MapSet CPU |
| --- | ---: | ---: |
| Host marshalling | 4.60% | 25.96% |
| Cache read/validation | 22.14% | 7.82% |
| Ordinary API loading | 11.91% | 4.09% |
| Exact-prefix comparisons | 10.25% | 3.34% |
| Everything else, including separate GC/harness roots | 51.10% | 58.78% |

The producer walks raw sample ancestry and counts each leaf once in the first
matching group. Generated functions require the exact candidate API URL.
Both candidate weighted views admit: Numeric has 587 samples, 851,001 weighted
microseconds and a retained 2-microsecond negative-delta correction; MapSet has
1,728 samples, 2,473,078 microseconds and no correction. Baseline Numeric's
weighted view was refused; its count view is retained and is not substituted
into this weighted table. Shared SCC labels do not identify unique members.

## What to optimize next

**Repeated specialized-type analysis is the clearest MapSet target.** Host
marshalling's raw ancestor union contains **328.756 MB**, or 56.04% of candidate
allocation. All **135.813 MB** of structural-key-family allocation and
**74.373 of 130.381 MB** of substitution-family allocation occur under that
same ancestor. These are nested descriptions of work, not additive savings.
The [State04 host emitter](../../selfhost/build/phase61/checked-state04/snapshot/src/back/js/direct/host.bend)
repeats normalization, specialized constructor traversal and serialized type keys
across signature, component and recursive marshalling queries. A request-local
type graph could share those facts while preserving exact binder/type identity,
field order and original budget/refusal behavior. Its cheap falsifier is a
qualified exact-output comparison plus host-query counts on contrasting types.

**Private JSON-tree validation is a separate common cost.** Numeric cache reading
allocates 25.925 MB; span validation's ancestor union accounts for 16.911 MB,
chiefly `Object.values` arrays and `WeakSet.add` storage. A private validator for
freshly decoded JSON trees could avoid those structures while retaining every
literal/Lambda/span check. Public arbitrary-object validation must preserve its
cycle, alias and getter behavior. Likewise, a private immutable prefix permission
may reuse an already established equality proof; a matching source hash alone
does not justify skipping public structural checks. These are proposals beyond
State04, not measured improvements in this report.

**Image shape offers a smaller startup experiment.** The
[static Acorn census](../../selfhost/build/phase61/state04-analysis01/image-census.json)
finds 29,095 `JD_REF` and 32,390 `JD_USE` comments totaling **1,269,967 bytes**,
32.13% of the 3,952,902-byte B2. Another 97,397 bytes are other comments.
Module parsing occupies about 99 ms in each candidate CPU profile. Removing
metadata only after all reach/demand consumers, or using a separately qualified
Node module code cache, could address startup; neither is a measured body-speed
gain. Cache creation and subsequent reuse need separate tests, as documented by
[Node](https://r2.nodejs.org/docs/latest-v24.x/api/module.html#module-compile-cache).
Do not strip marker strings used by the compiler's own emitter.

The hottest `subst$scc` and host-status functions already use direct switches
without `kc` calls or `run_loop`. The saved source does not establish another
generic trampoline problem. The new fused telescope materializer already exists
for its admitted beta-stable subset; remaining substitution outside that subset
requires its own proof, especially because `core_rebuild` may reduce applications.
The [Phase60 research map](../phase60/bottlenecks.md) remains useful for held-out
coverage, but its earlier profile shares cannot be pooled with this changed image.

Even deleting all Map host/cache/prefix bins would not by itself establish parity;
those bins total about 37.13% of this diagnostic. Their CPU shares are not causal
speedup predictions. Source-dependent parsing, normalization, text generation,
checking and other work remain. Broad qualification and repeated clean timing
must decide any subsequent candidate.
