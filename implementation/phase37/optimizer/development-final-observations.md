# Final development execution: cast gains and remaining regressions

The final checked03 output improved numeric recurrence execution by **2.674×**
at 256 iterations and **5.165×** at 1024. It remains **7.38×** and **3.34×**
slower than the pinned TypeScript output on those points. The same run recorded
a consistent **4.65% median slowdown** for the 512-element list pipeline and a
smaller **3.15% median slowdown** for 256 closures. The list result has disjoint
sample ranges; it must remain an explicit regression in phase admission.

This analysis reads `development-final01/report.json`, SHA256
`5b4f75bae8e3bb798b58fb4b3d442e11a88954a84cc45876a19cbb1c6d5713a6`.
The run completed all ten development points and 150 fresh-process samples in
184.693 seconds. All executions passed their exact expected results. It used
five balanced rounds, three roles, CPU 3, Node 24.18.0, 600 ms warmup, 50 ms
calibration and a 250 ms timing target. Heap, process-tree RSS and free-memory
floor were respectively 1024, 2048 and 2048 MiB. Compilation and import are
excluded from execution medians. No holdout result is used here.

## Actual compiled numeric recurrence

These are clean checked03 emissions, not the earlier saved-output prototypes.
The selected API is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
Each time entry is the median in milliseconds, followed by the five-sample
minimum–maximum range.

| Iterations | Phase36 | Final candidate | TypeScript | Phase36/final | Final/TS |
| --- | --- | --- | --- | ---: | ---: |
| 256 | 0.039730 [0.039432–0.045501] | 0.014856 [0.014233–0.016105] | 0.002012 [0.001974–0.002067] | 2.674× | 7.382× |
| 1024 | 0.131576 [0.130105–0.157920] | 0.025473 [0.025065–0.028001] | 0.007632 [0.007617–0.007644] | 5.165× | 3.338× |

Every paired round improved. Candidate execution fell by 62.40–64.61% at 256
iterations and 80.64–82.27% at 1024. Baseline and candidate sample ranges are
disjoint in both cases. Within-sample half drift ranged as follows:

| Iterations | Phase36 half drift | Final half drift | TS half drift |
| --- | --- | --- | --- |
| 256 | −1.22% to −0.41% | −0.65% to +4.81% | −7.11% to +0.33% |
| 1024 | −2.55% to −0.58% | −1.88% to −1.21% | −0.30% to +0.64% |

The drift and run-to-run spread limit precision in the exact ratios, especially
the small 256-point TS timing. They do not obscure the direction or scale of
the observed cast gain. These results establish the improvement on these two
points; they do not establish general numeric-program parity.

## Closure and list shifts

| Point | Phase36 median [range], ms | Final median [range], ms | Median-time change | Final/TS |
| --- | --- | --- | ---: | ---: |
| Closures 256 | 0.181307 [0.180617–0.214154] | 0.187016 [0.184308–0.208257] | +3.15% | 8.332× |
| List pipeline 512 | 1.229343 [1.218371–1.242468] | 1.286510 [1.281832–1.292368] | +4.65% | 44.424× |

Positive changes mean the candidate took longer. Pairing each candidate with
the baseline in its balanced round gives:

| Round | Closures 256 change | List 512 change |
| --- | ---: | ---: |
| 0 | +3.54% | +4.00% |
| 1 | +2.58% | +5.59% |
| 2 | −12.58% | +5.68% |
| 3 | +1.66% | +3.48% |
| 4 | +2.28% | +5.13% |

For closures, the overall ranges overlap and one unusually slow baseline round
reverses the paired direction. Four of five pairs are slower, with a paired
median change of +2.28%. This is a small possible regression with visible
between-process variation; overlapping ranges alone do not establish no cost.
Half drift stayed between −0.31% and +0.42% for baseline and −0.74% and +0.65%
for candidate, so the broad spread is primarily between fresh processes.

For the list, **every candidate sample is slower than every baseline sample**.
All five paired changes are positive; their median is +5.13%. The baseline's
half drift was −1.35% to +1.19%, and the candidate's was −2.02% to +0.59%.
This is a consistent observed regression in this run, not a result that can be
dismissed as overlapping ranges. Five rounds are not a formal confidence
interval or a causal explanation, but the phase must retain this cost explicitly.

## Static list comparison rules out the obvious hot-loop explanation

The static Acorn analysis in `list-source-shape-v2.json` reads the two checked
modules as text; it imports or executes neither program. The analysis ran on
CPU 0 with a 256 MiB Node cap, away from the measurement CPU. Its initial v1
AST serializer refused BigInt literals; that harness failure and producer are
preserved, and v2 normalizes those literal values.

| Static observation | Phase36 | Final candidate |
| --- | ---: | ---: |
| Module bytes | 116,349 | 119,735 |
| AST nodes | 27,652 | 28,236 |
| Generated finite selector branches | 0 | 8 |
| Module call sites to `regionHostGuard` | 0 | 0 |
| Module call sites to `regionProofOpen` | 0 | 0 |
| Module call sites to `exactCode` | 0 | 0 |

The literal `G` dependency graph reachable from `bench` is exactly
`bench`, `p37.list`, `keep_gt1`, `keep_gt1.at`, `dbl` and `suma`, with no
unresolved named dependencies. All six emitted definition expressions are
**byte-for-byte and normalized-AST identical** between compilers. The candidate's
eight finite branches occur only in `anyeq2`, `allpos` and `main.out`; none is
reachable from this benchmark entry. There is no finite root in the module.

The shared `force`, `apply`, `invokeExact`, `get`, `ctor`, `scalarGuard` and
`localGuard` function bodies are also unchanged. `regionHostGuard` changed, but
the module contains no call to it. Consequently, the list slowdown cannot be
explained by this hot path directly paying the new DataView guard or evaluating
the new inactive finite branches. Correctness-required guard cost is not an
explanation for this particular observed regression.

Unused generated code increased module size by 2.91% and AST nodes by 2.11%.
Module layout, closure-context/JIT decisions, allocation/GC behavior or
measurement variation could still affect otherwise identical function bodies.
These are hypotheses, not findings. The planned final CPU/allocation profile
can check actual runtime frequency and behavior; static counts do not provide
those measurements.

A later cost model could restrict unprofitable scalar-only finite call-site
admission and reduce unused generated code. That is a future experiment; it
has not been implemented or demonstrated to fix this list regression. The
candidate remains frozen for holdout and final validation.
