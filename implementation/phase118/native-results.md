# Phase118 native qualification and compiler speed

The Bend-written compiler now self-hosts through direct QBE as safe-source03.
N1 and N2 each pass16 ordinary focused executions and3 expected refusals; N2
passes all45 original one-shot programs. Hosted and native self-emitted QBE match
in all **85,831,654 bytes**, SHA256
`a0b668b4d2804d1167014dd9e612e045a68e51989dc45e94516caa632586cb26`.
No generated C translation unit or cproc step is used; the C runtime object is
cached and linked. Initial hosted API acquisition uses pinned TypeScript/Bun.

[Exact identities and receipts](native-results.json) ·
[Native reproduction method](../../selfhost/tools/performance/phase118/native-qualification.md) ·
[Benchmark method](../../selfhost/tools/performance/phase118/native-timing.md).

## Compiler-request comparison

Two consecutive CPU3 screens use the same three source definitions, three rotated
rounds and independent complete outputs. The second reruns qualified Phase114
with its own exact runtime, avoiding mixed ABI/policy artifacts. All54 observations
pass. Names `phase111`/`phase112` in the old runner mean N1/N2 in these manifests.
These native generations are separate from the installed production B1/B2 release.

| Source | N1 request s | N2 request s | Upstream request s | N1 ready s | N2 ready s | Upstream ready s |
|---|---:|---:|---:|---:|---:|---:|
| lexer | 2.219 | 2.221 | 0.724 | 2.300 | 2.303 | 1.383 |
| coverage-closures-256 | 0.585 | 0.599 | 0.525 | 0.625 | 0.639 | 1.087 |
| coverage-map-churn-128 | 3.019 | 3.027 | 1.127 | 3.179 | 3.185 | 2.898 |

Geometric request ratios: **N1 2.09187× / N2 2.10976× upstream**.
Ready-executable stage-sum ratios: **1.01626× /1.02441×**. Ready time is request
plus QBE/as/link or C/Clang child time; it excludes harness overhead and execution.
This is near upstream ready-time parity on this small screen, not evidence of
whole-corpus compiler-throughput or generated-program parity.

The contemporaneous Phase114 ratios are request2.87824×/2.89711× and
ready1.35829×/1.36700×. Directly comparing native medians across the two screens,
N1/N2 requests use **25.70%/25.55% less time**, and ready stages24.70%/24.58% less.
Upstream request medians drift2.24% and ready medians0.64%; ratio-of-ratios alone
would overstate the native improvement. Three rounds retain individual samples
and outliers, not statistical confidence intervals.

Native requests use authenticated prepared Base and a cached runtime. Upstream
loads/checks source Base, emits C, and compiles its runtime with Clang-O2 each time.
These are configured workflow comparisons, not identical-work backend benchmarks.
Acquisition, semantic qualification and cache creation are outside request clocks.

## Acquisition cost and generation boundary

Successful qualification costs **1,286.036s (21.43min)**, peak **5.385GiB** under
an explicit6GiB process-tree limit and16GiB available-memory floor. Hosted
acquisition totals701.258s, including264.100s frontend and433.881s integrated
lowering/verification/optimization/rendering. N1 machine construction takes10.98s.
The native self-request is406.614s; its request plus N2 build is417.338s.
These nested clocks must not be added to the guard wall.

The native self-request is cheaper than hosted execution of this compiler in this
acquisition, and produces identical QBE. It is not a comparison with the upstream
TypeScript compiler algorithm. The old Phase114 self-request466.724s is historical
and compiles a different, smaller source; use the matched ordinary request screen
above for a controlled compiler-speed improvement.

Earlier attempts remain costs: float01 failed after589.625s without an exception
stack; safe02 failed after259.211s with the exact `nc_pack_foreign` trace. Neither
was an OOM/deadline. The DFS repair preserves its predicate and passes40 finite/
scale controls. The successful run's hosted process alone reaches5.37GiB: ordinary
2GiB benchmark guards are not sufficient for this full image acquisition.

N1/N2 executable hashes differ; only raw QBE reproduction is established. There
is no ELF fixed point, N2-to-N3 emission, parallel/GPU qualification or production
installation. The runtime benchmark3.00893× remains the separate hosted-produced
batch-program campaign. The native full45 here is one-shot correctness.

## Recursive improvement

This establishes a faster qualified compiler tool relative to Phase114 on the
three measured requests. It does not demonstrate accelerating discovery of
optimizations. Such a claim must include failed acquisition, qualification and
agent effort, and measure whether adopting this tool improves later validated
experiments per total budget. The new native image and exact identities make
that experiment possible; automatic unchanged-source recompilation is not it.
