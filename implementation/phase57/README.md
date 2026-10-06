# Phase57: where compiler execution time goes

This investigation keeps the Phase56 compiler installed and unchanged. It
compares four implementations, gathers CPU/allocation/V8 evidence, and separates
existing bootstrap transformations before choosing another optimization.
The [design](../../design/phase57/compiler-performance-attribution.md) was
committed before measurement. No upstream PR comment is posted.

## First findings

The apparent regression from B1 to B2 is not evidence that the direct backend
generates slower code than upstream. **B2 beats the unmodified upstream-emitted
Bend compiler on both measured inputs.** Installed B1 is a separately optimized
image with equality and branch transformations that the other images do not all
share. It remains faster than B2.

| Ordinary compiler request | Evening | Lexer |
| --- | ---: | ---: |
| Handwritten TS, import + first request | 0.936 s | 0.647 s |
| Raw upstream-emitted Bend, import + first | 6.132 s | 3.437 s |
| Optimized B1, import + first | 2.933 s | 1.831 s |
| Direct B2, import + first | 5.100 s | 3.209 s |
| B2 / optimized B1, later request | 1.830× | 1.807× |
| B2 / raw upstream-emitted Bend, later request | 0.704× | 0.766× |

These are three-process medians, not language constants. The 24-process screen
checks all 96 requests against prepared output oracles. Later requests continue
warming up; they are not claimed steady-state throughput. The Bend images emit
identical complete JavaScript for both inputs. See [latency](latency.md) for
individual sequences, timing boundaries, cache differences and exact receipts.

API loading is about 0.10 s for B2, only 2–3% of its first-request total. Its
continued disadvantage on later requests rules out startup as the complete
explanation. All three measured Bend images expose the named API and bypass the
old `G` conversion adapter.

## Evidence map

- [Compiler latency and reproducible commands](latency.md).
- [Allocation/CPU profiling method](profiling.md), including preserved failures.
- [Generated code shapes and exact corresponding functions](code-shapes.md).
- [Bend versus handwritten TypeScript algorithms](implementation-comparison.md).
- [Bounded V8 diagnostics](v8-plan.md).

CPU profiles, transformation ablations, full-source checks and the final
recommendation are being collected. Diagnostic times will remain separate from
the clean comparison above. No production optimization or fresh generated-program
speed claim is made by this information-gathering phase.
