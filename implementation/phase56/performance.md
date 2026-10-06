# Generated-program performance preservation

The checked `string01` compiler produced **44 of 45 benchmark points with exactly
unchanged module bytes**. The only changed point, `test-map-set-ops`, passed fresh
paired timing and was **1.1891× faster than host02** by median, a 15.90% execution
time reduction. There is no new whole-corpus timing or aggregate speed claim.

The full acquisition covers the existing 45 points / 23 source files. The
[data-only comparator](../../selfhost/tools/performance/phase56/performance/compare.py)
joined the source receipts to `checked-string01`, checked complete raw modules,
and reproduced the unchanged complete-row observer. It compared those outputs
with Phase55 host02 and independently verified that the host02 final bytes match
the published Phase53 current bundle. Exactly one source changed; the other 22
raw source outputs and the 44 corresponding benchmark points retain exact bytes.

That establishes continuity of the **dated Phase53 evidence** for unchanged
artifacts. It is not a fresh measurement of those points or a new conformance
run. The [comparison and reproduction instructions](../../selfhost/tools/performance/phase56/performance/README.md)
preserve the raw-versus-observer distinction and emit timing commands only for
changed modules.

Fresh results for `test-map-set-ops`, invoking `main.out()` and checking the full
expected result `11111` on every invocation:

| Role | Median µs/call | Range across five processes, µs | Relative to TS |
| --- | ---: | ---: | ---: |
| Pinned TypeScript | 20.5952 | 20.0837–23.1278 | 1.0000× |
| Phase55 host02 | 20.8518 | 18.7032–21.0900 | 1.0125× |
| Phase56 string01 | 17.5360 | 17.5235–19.5360 | 0.8515× |

All **15 fresh process samples passed**, in five rotated three-role rounds. The
existing 600-second preset was used as a ceiling, with 1,000 ms warmup windows,
50 ms calibration and 300 ms target windows. Actual acquisition-free timing took
24.97 s on Node 24.18.0 / CPU3, with a 1,024 MiB heap, 2,048 MiB tree-RSS limit and
4,096 MiB free-memory floor. Import and first-call times remain separate from
the displayed execution medians.

Maximum absolute within-sample half drift was 2.12% for TypeScript, 3.10% for
host02 and 7.14% for string01. These are warmed finite-input observations, not a
stationarity or statistical-significance claim. Individual sample ranges overlap;
the five-round median improvement should not be generalized to other Map/Set
workloads or arbitrary programs.

The changed module shrank from 134,707 to 134,132 bytes (575 bytes). All other
corpus modules retain their complete bytes, including runtime and observer code.
Independent semantic and release gates remain separate from this performance
preservation check. [Compiler request latency](latency.md) is also a separate
measurement: the new B2's slower compiler requests must not be confused with
the execution speed of the two test programs that B1 and B2 emitted identically.

The following raw receipts identify the data used here; paths are relative to
the repository root. No raw evidence or target was modified during reporting.

| Receipt | SHA-256 |
| --- | --- |
| `selfhost/build/phase56/string01-full/manifest.json` | `6fd08b9b05a7c4d3afeb1c05e34e18ca6c1f9501bfb83fe2cfbca4b76af2056c` |
| `selfhost/build/phase56/string01-performance/report.json` | `36886a4cca24eae00cff73db7c9ce6e14a1306ad168a8609eef4572eb704f052` |
| `selfhost/build/phase56/string01-performance/timing-0/report.json` | `8d06e7e0e1c42f35c1b9d1e1ec940d49267bd7566b223d1f991e81c95cebec56` |

The report review recomputed all three runtime medians from the 15 saved samples.
Historical and fresh samples were not pooled, and no mixed geometric mean was
presented as a new controlled corpus result.
