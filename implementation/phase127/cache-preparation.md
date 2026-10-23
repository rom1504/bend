# Prepared Base ablation and profiling overhead

The existing prepared-Base route saves **1.65–1.70 seconds per request** against
live Base parsing/checking/preparation in this campaign. This is a measured
benefit already present in the compiler, not a new optimization gain. It is the
net difference between two preparation routes, not the absolute time spent
decoding the prepared carrier.

Evidence: [`cache-preparation-summary.json`](cache-preparation-summary.json),
derived offline from
`selfhost/build/phase127/cache-live01/report.json` and
`selfhost/build/phase127/full-comparison01.json`. The summary pins its raw reports,
manifest, analysis method, binary, source inputs, output oracles and captures.
No compiler execution or general-tool change was performed while writing it.

## Controlled cache/live comparison

The campaign used the same live-register-bank N1 executable throughout:
`selfhost/build/phase111/p127-live-bank-same-source01-n1/program`, SHA256
`7d74f5254509970f53ceda6f5305dc195afbb38bf8486005ffab8f1c62c61734`.
For each fixture the only changed argument was `cache` versus `live`.
The Base, source path, carrier and stamp remained fixed. Both routes had to
match the same independently retained Phase126 whole-QBE stdout oracle,
empty stderr and successful exit status.

All **30 observations passed**: three clean repeats and two sampled executions
(8 ms and 13 ms periods) for each of six fixture/mode combinations. There were
no changed inputs. Execution was pinned to CPU 3. Complete campaign elapsed
time, including offline profile analysis and checks, was **96.53 seconds**.
These are native source-to-QBE requests; no assembler, linker or QBE machine
build is included.

| Fixture | Cache wall median | Live wall median | Net saved | Live/cache | Cache CPU / live CPU |
|---|---:|---:|---:|---:|---:|
| lexer | 2.232 s | 3.886 s | 1.654 s | 1.741× | 2.231 / 3.885 s |
| closures | 0.624 s | 2.323 s | 1.699 s | 3.720× | 0.621 / 2.322 s |
| Map churn | 3.502 s | 5.198 s | 1.696 s | 1.484× | 3.501 / 5.180 s |

Wall ranges across the three clean repeats were 2.222–2.264 / 3.886–3.902 s
for lexer, 0.615–0.637 / 2.318–2.377 s for closures, and 3.486–3.515 /
5.152–5.210 s for Map (cache/live). These ranges describe these observations;
three repeats do not establish confidence intervals.

The nearly constant savings agree with the earlier
[invariant decoder event counts](preparation-findings.md): each request prepares
the same Base before handling the fixture. The source trace confirms the switch
in [`p111_compile_source`](../../selfhost/tools/performance/phase111/entry.bend#L35).
The observation does **not** identify the remaining decoder cost. Algebraically,
`T_live - T_cache` measures approximately
`live preparation - carrier read/decode`, plus any downstream consequences of
different allocation histories. Decoding, I/O, teardown and shared helper costs
remain in the cached request.

There is also a memory tradeoff. Clean median peak RSS was **49.93 versus
36.12 MiB** for lexer and **47.93 versus 28.15 MiB** for closures (cache/live).
Map was nearly unchanged at **52.06 versus 52.28 MiB**. The retained text
carrier and reconstructed products can cost memory even when they save time;
these RSS measurements do not by themselves identify which object retains it.

## Sampling adequacy

All captures had zero drops/overruns, accepted delivery and thread coverage,
and captured process-CPU windows covering at least 99.56% of sampled-child CPU.
Low-count captures were pooled within their exact fixture/mode identity;
cache and live samples were never pooled together.

| Fixture/mode | Pooled samples | Quantitative CPU-cost threshold met? |
|---|---:|---|
| lexer cache | 447 | No |
| lexer live | 789 | Yes |
| closures cache | 123 | No |
| closures live | 465 | No |
| Map cache | 703 | Yes |
| Map live | 1,041 | Yes |

The 500-sample gate permits approximate aggregate CPU attribution; it is not a
confidence statement about individual small buckets. Descriptive fractions
remain available below that gate. Most individual captures are below 500, so
counting only the runner's per-capture `usableCaptures` would discard useful
pooled evidence. Sampled/clean median wall ratios range from **0.991 to 1.009**.
Ratios slightly below one indicate ordinary run variation, not negative
profiling overhead. No dispatch-counter runtime instrumentation was enabled
for this cache/live campaign.

## Full-compiler profiling cost

The full-source campaign supplies a useful separate scale check on the same
live-bank compiler. Each row below has **one observation**, not repeated
medians:

| Route | Wall time | Relative to clean | Samples | Peak RSS |
|---|---:|---:|---:|---:|
| clean native request | 444.823 s | 1.0000× | — | 2,675.48 MiB |
| physical sampler, 8 ms | 446.541 s | 1.0039× | 55,761 | 2,677.07 MiB |
| context-instrumented runtime + sampler, 13 ms | 471.331 s | 1.0596× | 36,220 | 2,676.78 MiB |

Both full-scale profiles have zero recorded loss and pass the lifetime and
sample-count checks. Physical sampling adds an observed **1.72 seconds
(0.39%)**; runtime context attribution plus sampling adds **26.51 seconds
(5.96%)** relative to the clean observation. Different sampling intervals and
single-run variation prevent isolating the precise cost of context stores
from this comparison alone. The context run has event counters disabled, so
its 5.96% difference must not be described as counter-collection overhead.

For routine broad cost localization, the physical sampler gives much cheaper
observability at full scale. Use context instrumentation selectively when the
question requires a dispatcher owner. The cache/live experiment strengthens
the evidence for reusing preparation, but does not justify replacing the
decoder or expanding the cache without a measured residual-cost experiment.
