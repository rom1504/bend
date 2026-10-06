# Three-role compiler latency

All **18 fresh checked-library requests passed**. B2 is approximately **1.79×
slower than its matching B1** on these two requests, and **5.08–5.55× slower than
TypeScript** when compiler import and request time are combined. This is compiler
latency, separate from [generated-program execution](performance.md).

The root agent executed this small screen using `checked-string01` and its
matching B2. The earlier unexecuted draft's host02 binding was replaced before
any latency acquisition. No old-B2 latency comparison or all-program throughput
claim follows from this result.

Median import + request time, with all three observations' range:

| Source | Role | Median s | Range s | Relative to TS |
| --- | --- | ---: | ---: | ---: |
| Evening | TypeScript | 0.8252 | 0.8194–0.8432 | 1.000× |
| Evening | B1 | 2.5665 | 2.5516–2.5749 | 3.110× |
| Evening | B2 | 4.5809 | 4.5741–4.5921 | 5.551× |
| Lexer | TypeScript | 0.5792 | 0.5788–0.5863 | 1.000× |
| Lexer | B1 | 1.6431 | 1.6288–1.6526 | 2.837× |
| Lexer | B2 | 2.9405 | 2.9280–3.2249 | 5.077× |

B2/B1 ratios are 1.7849× for Evening and 1.7896× for lexer. The separate timing
boundaries explain why request-only ratios would overstate the comparison with
TypeScript's eagerly imported compiler:

| Source | Role | Host import ms | Request ms | Process wall ms | Median peak tree RSS MiB |
| --- | --- | ---: | ---: | ---: | ---: |
| Evening | TypeScript | 224.38 | 603.76 | 1,694.12 | 265.55 |
| Evening | B1 | 4.04 | 2,562.43 | 4,387.80 | 422.73 |
| Evening | B2 | 4.05 | 4,576.83 | 6,416.74 | 432.42 |
| Lexer | TypeScript | 227.66 | 354.44 | 1,429.42 | 243.88 |
| Lexer | B1 | 4.02 | 1,639.12 | 3,467.92 | 412.38 |
| Lexer | B2 | 4.01 | 2,936.44 | 4,756.97 | 422.92 |

Each column is its own median; summing medians need not reproduce the median
combined time. Process wall and RSS include verification machinery. The complete
screen took 113.09 s: 30.71 s preparation and 82.02 s for the timed-request stage
including controller work. The 18 child process wall times sum to 66.93 s.
Untimed Base priming took 1.834 s for B1 and 3.298 s for B2.

Preparation passed all six full-output oracles. B1 and B2 emitted identical
103,867-byte Evening modules and identical 28,452-byte lexer modules; every timed
output matched those prepared bytes. TypeScript's checked modules were 62,658
and 14,110 bytes respectively. Output-size differences are recorded, not a claim
that size explains compiler latency.

The screen compares the same checked Evening and lexer sources using:

| Role in receipts | Compiler image | Provenance |
| --- | --- | --- |
| `source` | B1, `checked-string01` API `12861977…` | Genuine checked bootstrap attempt |
| `direct` | B2, own-source image `3f652f7d…` | Exact selected emission and eight ordinary-driver observations; no invented checked attempt |
| `typescript` | Pinned upstream `018751270e…` | Unmodified `bend.ts`, `comp.ts` and `base.bend` |

[The shared setup](../../selfhost/tools/performance/phase56/bootstrap/setup-v2.mjs)
validates the exact B1→B2 source and image lineage. It stages byte-identical
drivers and runtimes in two fresh, separate projects. Each Bend role runs
`prepareBase` once, outside the timed samples, creating its own API-keyed checked
Base disk cache. No cache is copied from B1 to B2, and B2 receives no synthetic
bootstrap sidecar. Preparation then compiles both sources and executes their full
catalog oracles: Evening's `main.out() == 81111`, and lexer's
`bench(8, 0) == 1822208108`. B1 and B2 must emit exactly identical module bytes.
TypeScript must check both sources, report no holes and satisfy the same oracles;
its emitted text need not equal Bend's.

The timed part makes **18 fresh-process requests**: two sources × three roles ×
three rounds. For each source, role order rotates `typescript, source, direct`,
then `source, direct, typescript`, then `direct, typescript, source`. Every Bend
request calls the ordinary driver with `{mode:'library', backend:'direct'}`.
Each emitted module must match its independently prepared checked output exactly.
The source, compiler, runtime, host tools, cache, preparation receipt and output
identities are checked around the samples. The existing serial ExecutionGuard
retains partial failures and process receipts; there is no retry or survivor-only
median.

The [worker](../../selfhost/tools/performance/phase56/latency/worker.mjs) reuses the
[Phase30 timing boundaries](../../selfhost/tools/performance/phase30/library-cost-worker.mjs),
while the [runner](../../selfhost/tools/performance/phase56/latency/run.py) reuses
the rotation and resource supervision of the
[Phase47 cost screen](../../selfhost/tools/performance/phase47/compiler-cost-run.py).
Their provenance checks are adapted explicitly: the historical verifier requires
a checked attempt and therefore cannot be applied to B2.

- **Import + request** is the primary comparison. TypeScript imports its compiler
  eagerly; the Bend driver loads its compiler API lazily inside `inspect`.
- **Request only** includes parsing/loading, ordinary checking and emission, plus
  Bend's lazy API import and checked Base-cache handling. It does not isolate
  emission or kernel throughput.
- **Host import** is reported separately so that eager versus lazy loading is
  visible. Both measures use `performance.now()` in the child.
- **Process wall** includes startup, provenance rehashes, output validation and
  report writing. Peak process/tree RSS similarly includes this machinery.
  Bend preflight rehashes additional image-lineage inputs; although excluded from
  the import/request clocks, this can leave different allocation and filesystem
  state. This diagnostic does not isolate startup memory or a pristine V8 heap.
- Preparation and its oracle execution are reported separately. TypeScript has
  no newly introduced persistent Base cache: the comparison is between each
  implementation's stated normal checked-request path, not identical checker
  work or a cold-filesystem experiment.

The report records three raw observations, median and range for every role/source;
there is no significance claim, whole-corpus compiler-throughput claim or
fixed-point claim. Two sources can reveal a useful large difference and justify
a broader follow-up, but cannot establish all-program latency parity.

The independently reviewed command used from the repository root was:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase56/latency/run.py selfhost/build/phase56/latency-string01 --image-pins selfhost/build/phase56/bootstrap-string01-plan/image-pins.json
```

The runner places target processes on CPU3, with a 1,024 MiB V8 heap, 2,048 MiB
tree-RSS ceiling, 4,096 MiB free-memory floor, 180-second child deadline and
1,200-second campaign deadline. Its controller runs on CPU0. The runner acquires
the existing shared execution lock; it must not be nested inside another owner
of that same lock. Use a fresh output directory for every attempt. Default input
is `bootstrap-string01-plan/image-pins.json`, which names the matching checked
attempt, source, B1, B2 and provenance receipts; no historical files are written.
Results are in `selfhost/build/phase56/latency-string01/report.json`, with plan,
preparation, request, output and process receipts alongside it. Report SHA-256:
`30a8c5c2bba6f0959fc2f91f7e792d1b2838d1d1a827efa86767e191a92d9e43`.
The data-only report review recomputed the medians from all 18 worker observations
and rechecked their receipt and emitted-output identities. It ran no targets.
