# Performance baseline before compiler changes

Measured 2026-09-21 against upstream `6018e28ecc67cf1fffc0c20c64b11023474c2df8`. All 45 samples passed their checks; all 27 emitted JavaScript programs produced the expected output. The distribution manifest was verified before and after measurement: no existing source or shipped artifact changed.

[Raw measurements and provenance](../benchmarks/baseline-2026-09-21.json) · [Harness and reproduction instructions](../tools/performance/README.md)

## Controlled conditions

Node v24.18.0, Intel Xeon E3-1245 V2, Linux x86-64. Each implementation used a fresh Node process, logical CPU 2, a 4 MB JavaScript stack and a 4 GB old-space ceiling. Three samples per workload and implementation ran serially in balanced rotating order. There were no JIT warmups or persistent Base/check-prefix caches; every Base sample parsed and checked the same complete Base file. Filesystem caches were not flushed. This is a cold compiler-process comparison of full work, not cached CLI or steady-state JIT performance.

## Compiler pipeline time

Seconds, median of three. Imports, Node startup, output-file persistence and execution of generated programs are excluded. Ratios divide each port median by the corresponding upstream median. “Bootstrap” is the supplied upstream-emitted typed Bend API; “self-emitted” is the verified self-hosting seed. The legacy prototype is not measured.

| Workload | Upstream TS | Bootstrap | Self-emitted | Bootstrap / TS | Self-emitted / TS |
|---|---:|---:|---:|---:|---:|
| Tiny datatype (check) | 0.006 | 0.049 | 0.110 | 8.2× | 18.3× |
| 256 declarations (check) | 0.019 | 1.363 | 4.065 | 72.6× | 216.6× |
| Base + U32 (JS) | 0.358 | 8.031 | 43.057 | 22.5× | 120.4× |
| Tree + IO (JS) | 0.359 | 8.316 | 44.495 | 23.1× | 123.8× |
| List sort (JS) | 0.446 | 9.460 | 50.366 | 21.2× | 112.8× |

Check-only cases omit declaration-report formatting on both sides. JS cases load, fully check and emit a program, then independently validate its execution outside timing. Upstream output runs as CommonJS and port output as ESM, without rewriting emitted bytes.

## Range and process overhead

Measured minimum–maximum pipeline seconds; these are observed ranges, not confidence intervals.

| Workload | Upstream TS | Bootstrap | Self-emitted |
|---|---:|---:|---:|
| Tiny datatype (check) | 0.006–0.006 | 0.049–0.049 | 0.110–0.111 |
| 256 declarations (check) | 0.019–0.026 | 1.344–1.366 | 4.044–4.170 |
| Base + U32 (JS) | 0.356–0.366 | 8.003–8.120 | 42.777–43.440 |
| Tree + IO (JS) | 0.355–0.366 | 8.286–8.318 | 44.072–44.798 |
| List sort (JS) | 0.412–0.454 | 9.457–9.469 | 50.103–50.697 |

Total process time includes Node startup, module imports, output persistence and exit. It matters for small inputs:

| Workload | Upstream TS process (s) | Bootstrap process (s) | Self-emitted process (s) |
|---|---:|---:|---:|
| Tiny datatype (check) | 0.328 | 0.147 | 0.251 |
| Tree + IO (JS) | 0.693 | 8.431 | 44.680 |

## Memory and phase attribution

Median process peak RSS in MiB, including module imports. This is neither minimum heap requirement nor phase-specific allocation.

| Workload | Upstream TS | Bootstrap | Self-emitted |
|---|---:|---:|---:|
| Base + U32 (JS) | 126.0 | 256.9 | 326.6 |
| Tree + IO (JS) | 128.6 | 259.6 | 343.1 |
| List sort (JS) | 138.6 | 274.7 | 376.1 |

Largest measured public API costs in the self-emitted tree compilation (median seconds). Upstream and port phase boundaries differ, so these are attribution, not like-for-like phase speed ratios.

| Entry point | Seconds |
|---|---:|
| `check_book` | 16.063 |
| `f_load_graph` | 11.900 |
| `f_parse` | 8.488 |
| `j_stops` | 4.717 |
| `annotate_selected` | 0.873 |
| `specialize_book` | 0.609 |

The source-discovery pass calls `f_parse`, and graph loading parses sources again. Together with `check_book`, these are concrete profiling targets. The bootstrap/self-emitted gap also warrants separating generated-code/runtime overhead from algorithmic cost. Phase timings alone do not establish a specific optimization or its safety.

The adapter also rejects the supplied invalid-type fixture for all three implementations, with no output emitted. See [the negative validation record](../benchmarks/harness-negative-validation.json).

## Limits and next step

This selected five-workload baseline does not establish full-corpus performance, a self-rebuild time, interpreter speed, native/GPU performance, cached CLI latency or steady-state throughput. Three samples support a preliminary local baseline; no statistical confidence interval or cross-machine claim is made. The host was shared and CPU affinity does not isolate its SMT sibling. No compiler optimization has been applied.

Use the recorded artifacts as the control for the next change. Profile frontend discovery/loading and checking first, then compare a separately identified candidate with the same inputs, flags, cache policy and output checks. Preserve checking and conformance gates when evaluating any speedup.
