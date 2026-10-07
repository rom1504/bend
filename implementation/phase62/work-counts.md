# Phase62 work-count investigation

Status: four-input screen and all-23 diagnostic pass; no production change or
speed claim.

The question is whether the remaining compiler cost reflects extra semantic work
or the cost of executing necessary work. Broad source inspection found one
particularly concrete difference: State08 computes `jd_arity`, `jd_domains`,
`jd_raise`, `jd_live_arity` and `jd_params` repeatedly through call-graph analysis,
emission and host wrappers. Upstream packages related function information in
`fun_of` and memoizes it in `FUNS`; its backend telescope decomposition is cached
in `TELES`. Its `OPENS` and `SPINES` caches have shorter lifetimes and are cleared
per definition. This observation motivates counters; it is not evidence of a
specific wall-time gain or a safe context-independent cache key.

[Diagnostic runner](../../selfhost/tools/performance/phase62/work-counts/README.md)
records a small group of term, checker, index and backend queries. B2 counters
track logical tail-recursive and mutually recursive entries, grouped by public
API root. TS counts ordinary function entries and actual cache misses separately
from requests. Full raw output equality is required for each compiler. No source
optimization, rebuild or installed-image change is needed.

Interpretation must preserve the different abstractions: `jd_domains` counts
telescope steps, not just top-level signatures, whereas `fun_of` entry counts
include cheap cache hits. Comparing those numbers directly would exaggerate
work amplification. `jd_arity` versus signature cache requests/misses, together
with the phase profile, is a better initial test. Counts of `subst` do not reveal
how many reconstructed nodes are structurally identical or prove those nodes
could be reused safely.

## First four inputs

The [compact counter evidence](evidence/work-counts01.json) preserves all nonzero
counts and probe definitions from the [raw report](../../selfhost/build/phase62/work-counts01/report.json).
All 29 Bend, 10 theory and 18 TS backend probes were found. All four inputs pass
complete raw-byte comparison for both compilers. The [guard receipt](../../selfhost/build/phase62/work-counts01-supervisor/run.json)
records 10.150949 seconds supervised wall and 657,526,784 peak tree RSS bytes
(627.07 MiB), including setup and derivative-cache preparation. This is the cost
of collecting evidence, not a compiler speed measurement.

| Input | Bend `jd_arity` entries | TS `fun_of` requests | TS `FUNS` misses | TS `FUNS` hit rate | TS `TELES` hit rate |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric recurrence | 53 | 53 | 12 | 77.36% | 72.03% |
| Map/Set | 1,453 | 2,868 | 108 | 96.23% | 67.85% |
| Lexer | 406 | 579 | 41 | 92.92% | 76.14% |
| Active raytrace | 1,275 | 2,146 | 54 | 97.48% | 83.31% |

Upstream often makes **more signature requests**, but performs the expensive
`fun_of` body far less often. Bend's uncached `jd_arity` entries are 4.42, 13.45,
9.90 and 23.61 times the TS `FUNS` misses respectively. These are counts of related
queries on potentially different retained definitions and contexts, **not speed
ratios or a proof that all these entries can share a result**. They support
investigating one per-context function-signature bundle rather than a generic
global normalization cache. At this granularity, the much lower `SPINES` hit
rates (5.37–18.10%) make that particular TS cache a less compelling first copy;
hit rates alone still do not measure avoided cost.

The substitution distribution separates two different problems:

| Input | Logical `subst` visits | Checking | Annotation | Emitted reach + final library | Layout validation |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric recurrence | 1,888 | 5.77% | 5.35% | 77.65% | 0.90% |
| Map/Set | 376,325 | 1.26% | 12.59% | 73.58% | 12.51% |
| Lexer | 16,943 | 15.19% | 14.37% | 55.22% | 14.08% |
| Active raytrace | 54,874 | 31.14% | 31.99% | 33.82% | 2.70% |

The unlisted remainder is native-stop preparation. Map's two emission-related
passes account for 276,917 substitution visits; optimizing only its checker
would miss most of this observed repetition. Raytrace's checking and annotation
instead account for 63.13% of its visits. These are **logical visits, not CPU,
allocation or avoidable-time shares**. A signature fact cache will not necessarily
remove all substitution within its containing phase. The independent sampled
profiles must establish which counted work consumes meaningful time.

Additional boundary observations:

- All five signature-related helpers (`jd_arity`, `jd_domains`, `jd_raise`,
  `jd_live_arity`, `jd_params`) run in both emitted reachability and final library
  production for all four inputs. Their work is not confined to one benchmark.
- Fused `env_subst_term` executes 6,447 times in Map/Set (6,251 in annotation,
  196 in checking) and zero times in the other three. That identifies the current
  route's observed activation, not the amount of substitution eligible for it.
- TS theory counts include parsing/checking Base, while B2's request reuses its
  prepared checked prefix. Whole-request theory entry totals therefore should
  not be compared as equally normalized user-program work. Phase-specific counts
  are retained for analysis.
- Both instrumentation and reused module processes change execution behavior.
  No wall-time improvement or clean latency result is inferred from these data.

## All 23 inputs

The unchanged runner then passes [all 23 inputs](evidence/work-counts02.json),
again with complete raw-byte equality for both compilers. The separate
[supervisor](../../selfhost/build/phase62/work-counts02-supervisor/run.json)
records **19.796725 seconds** and 636,801,024 peak tree RSS bytes (607.30 MiB).
The four overlapping rows match the first screen exactly, including every
counter and emitted-output identity, despite the changed case order. This is
useful observed reproducibility, not a guarantee for arbitrary request orders.

The repeated-signature pattern holds for **all 23 inputs**: every one invokes
all five signature helpers in both emitted reachability and final library
production. TS `FUNS` hit rates range from **77.36% to 97.61%**; pooling requests
across this specific corpus gives 95.43%. Bend `jd_arity` entries divided by TS
actual `FUNS` misses range from 4.42 to 24.62. These remain counts of related
queries, not normalized operation-cost or speed ratios.

Additional cases confirm that Map/Set was not an isolated observation:

| Input | Bend arity entries | TS signature requests / misses | `subst` visits | Reach + final share of visits |
| --- | ---: | ---: | ---: | ---: |
| Morning | 880 | 1,702 / 78 | 218,953 | 69.6% |
| Evening | 1,243 | 2,283 / 110 | 334,375 | 71.2% |
| List pipeline | 710 | 1,322 / 66 | 167,657 | 68.5% |
| Map churn | 856 | 1,566 / 70 | 218,694 | 70.0% |
| Record aggregation | 826 | 1,576 / 69 | 215,076 | 70.3% |
| Mandelbrot grid | 575 | 879 / 34 | 26,439 | 48.2% |

Reachability plus final emission accounts for more than half of logical
substitution visits in **19 of 23 inputs**. The exceptions are Mandelbrot and its
grid variant (about 48%) and the two raytraces (about 34%). Fused
`env_subst_term` activates in nine inputs; the other fourteen report zero. This
supports investigating a broadly applicable backend signature bundle, while
retaining a distinct term-representation/annotation investigation for programs
whose work concentrates elsewhere.

No production change, new derivative instrumentation or additional compiler
build was required to extend the screen. The detailed counts, output identities,
derivation schemas and exact parent-report hashes are retained in the two
separate evidence summaries. Instrumented request times are not used as clean
performance data.

## Next discriminating checks and falsifiers

The leading implementation hypothesis is a **per-context signature record**
containing arity, domains, live parameter information and raised-body facts,
computed once and consumed by the relevant backend passes. Its immediate
falsifiers are:

1. The counted helpers have little exclusive or inclusive cost in current
   profiles, so eliminating repeated entries cannot materially reduce requests.
2. The repeated queries mostly have distinct relevant contexts or signatures;
   recording the dependencies leaves few safe hits.
3. Building, looking up and retaining records costs as much as recomputation,
   particularly on small inputs or the compiler's many short definitions.
4. Shared results cross an annotation/pruning boundary where a referenced type
   or definition changes. Existing finite output equality does not prove context
   invariance; unsafe cross-context reuse remains excluded.

An accepted prototype needs a clean request comparison, unchanged full output,
and semantic boundary checks. A decline in these diagnostic counts alone is
insufficient for selection.
