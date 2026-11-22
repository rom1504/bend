# Wave 3B Campaign — Runtime Draining + Fast-Proxy Self-Compile Blitz (30-min Sprint)

- **Window**: `2026-11-22 03:26 UTC → 03:56 UTC` (30-min sprint)
- **Starting Checkpoint**: `f93fc305` (`origin/selfhost/agy`)
- **Core Rules**:
  - **Fast 1–5 s proxy iteration inside all workers** — zero 500 s self-compiles during exploration!
  - **Drain `runtime.c` into Bend-emitted x86-64** — measure exact `%` of `SIGPROF` runtime samples eliminated against unchanged `unified/runtime-agy.o`.
  - **Preserve `0.4527×` C `native45` fixed-work batch** and **`0` `observer.c` live-metadata violations**.

## 3 Parallel Track Results

| Track | Deliverable | Key Result (Fast Proxy) | Verification | Report |
|---|---|---|---|---|
| **B1 (`Runtime Drainer`)** | `research/agy/wave3b_rtdrain/apply_rtdrain.py` | **`runtime-agy.o` `SIGPROF` share: `38.8% → 8.5%` (−78.1% relative drain!)** against **unchanged** `runtime-agy.o`; every targeted C helper drained to **`0.0%`** (`borrow_scalar_safe`, `sink`, `span_fade`, `keep`, `term_drop`, `special_ctor`); **`1.328×`** interleaved speedup (`986.1 ms → 742.7 ms`) on AST/ADT/String/RFC proxy | `19/19 focused19`, `15/15 observer_wave2_gate` (`0 violations`), `6/6` catalog proxies, upstream diff exact match | `experiments/agy/wave3b-rtdrain.md` |
| **B2 (`Native String & Hash x86`)** | `research/agy/wave3b_strhash/apply_strhash.py` | 2,082 `String.eq → p88_string_eq` rewrites + dual-seed 64-bit AST pin + native x86-64 loops (`1.05×` on `direct_bench`, `1.02×` on `lexer`; fast/slow hit-rate tuning deferred to Wave 3C) | `19/19 focused19`, 3-way diff (`upstream == w2 == w3b == cid_hot`), `0` observer violations | `experiments/agy/wave3b-strhash.md` |
| **B3 (`Parallel Sharded Codegen`)** | `research/agy/wave3b_parcg/apply_parcg.py` + `par_compile.py` | Pure-Bend `x181`–`x188` round-robin sharding + `STB_GLOBAL` ELF linking (`0.03–0.05 s` link); **`1.53×–1.71×`** isolated `x181`–`x188` speedup at `N=4`; identified `fork()`-after-`agy_enrich_cursor` as the zero-serialization path for full self-compile | `19/19 focused19`, `4/4 N=1` bit-exact vs `wave2_unified` | `experiments/agy/wave3b-parcg.md` |

## Composed Wave 3B Unified Qualification (`compose_wave3b.py`: `B1 + B3 + S1`, unchanged `unified/runtime-agy.o`)
- **Build & Typecheck**: `selfhost/build/agy/wave3b_unified/compiler.bend` (`2,514,380` B) → `api.mjs` (exit 0).
- **Live-Metadata Observer Gate (`observer_wave2_gate.py`)**: **`44 + 2 / 46`** ABI/observer + **`15 / 15`** Wave 2 live-metadata probes **PASS (`0 violations`)**.
- **Full 64-Case Native Qualification (`qualification-catalog.json`)**: **`64 / 64 PASS`** (`19/19 focused` + `45/45 broad`, with `--stack-size=65536` on `broad/lexer`).
- **`native45` 8-Case Zero-Regression Benchmark (`wave3b_unified` vs `wave2_unified`, CPU 2, unchanged `runtime-agy.o`)**: **`8 / 8` EXACT MATCH**, **`0.9625×` geomean (`-3.75%` faster than Wave 2!)** — `coverage-bst-64` `0.8808×` (`-11.9%`), `coverage-map-churn-32` `0.8954×` (`-10.5%`), `lexer` `0.9376×` (`-6.2%`), `mandelbrot` `0.9757×`, `symreg` `0.9856×`, `raytrace` `1.0077×`, `editdist` `1.0108×`, `coverage-record-aggregation-256` `1.0170×`.
