# B5K-M4C: `bend5k` From-Scratch `bend2 -o .c` Bootstrap & `-O0` 7-Family Baseline

**Date:** 2026-11-24  
**Evidence JSON:** [m4c_baseline.json](file:///home/ai/bend2_agy/research/agy/bend5k/m4c_baseline.json)  
**Benchmark Script:** [bench_b5k.py](file:///home/ai/bend2_agy/selfhost/bend5k/bench_b5k.py)

---

## 1. Zero-Prebuilt-Binary `bend2 -o bend5k.c` + `gcc-10 -O1` Measurement

Unlike the old 48k-LOC `compiler.bend` (which blew up monolithic `bend2 -o .c` to `> 270 s` and `> 20 GiB` RSS), `bend5k.bend` (`4,632` LOC at C-emit time) compiles cleanly through upstream `bend2` C emission and `gcc-10 -O1`:

| Step | Command | Wall Time | Peak RSS | Artifact | Status |
|---|---|---:|---:|---:|---|
| 1. `bend2` C emit | `locked_bun.sh bend5k.bend -o bend5k.c` | **12.192 s** | **2,850.2 MiB** | `3,306,611 B` (`88,474` lines) | **PASS** |
| 2. `gcc-10 -O1` (stripped `musttail`) | `gcc-10 -O1 -w bend5k_gcc.c -pthread -lm` | **18.209 s** | **550.4 MiB** | `1,913,936 B` (`stage0_from_c`) | **PASS** |
| **Combined Stage 0 build** | — | **30.401 s** | `2,850.2 MiB` | — | **PASS (build)** |
| 3. Run `stage0_from_c -> s1.o` | `stage0_from_c bend5k.bend bend5k_s1.o` | `0.184 s` (256M stack) | `268.3 MiB` | — | **FAIL (stack overflow)** |

### Root Cause & Exact Fix for GCC-10 `stage0_from_c`
- `bend2`'s C runtime uses a CPS worklist (`WL_JMP(F)` / `WL_DYN(F)` on lines 124–125 of `bend5k.c`) annotated with `__attribute__((musttail))`.
- On **GCC-10** (which lacks `musttail` and whose `-foptimize-sibling-calls` hangs `> 18 min` on the 88k-line monolithic file), stripping `musttail` turns every CPS transition into a real C stack frame, overflowing even a `256 MiB` stack in `0.184 s`.
- A naive macro-expanded 49-field `WL_PACK`/`WL_UNPACK` trampoline expanded code size `~50×` and timed out `gcc -O0` (`> 30 s`).
- **Clean fix (for follow-up):** Either compile `bend5k.c` with Clang (which supports `musttail` natively, giving a `~30 s` pure-source bootstrap), or use a compact `WLState*` pointer-in-body rewrite (no per-jump 49-field pack/unpack).

---

## 2. `-O0` 7-Family Proxy Suite + `terrain` Holdout (`bend5k_s1` on CPU 7)

Built `bend5k_s1` (`6,007` LOC including `opt.bend` + `regalloc.bend`) via `build_b5k.py --opt O0` (`26.37 s` compile, `0.07 s` link) → `s0 -> s1` (with `ulimit -s 262144`), and benchmarked on **CPU 7** (3-run median, `gcc-10 -O2` live reference):

| Benchmark | Group | `bend5k_s1 -O0` | `gcc-10 -O2` | Ratio | Compile | `.o` Size | Status |
|---|---|---:|---:|---:|---:|---:|---|
| `nbody` | upstream | **1,351.23 ms** | `88.87 ms` | **15.21×** | `219.1 ms` | `117,616 B` | **PASS** (`728502159`) |
| `gameoflife` | upstream | `> 25,000 ms` | `925.87 ms` | `> 27×` | `144.5 ms` | `99,872 B` | **TIMEOUT** (`rc=124`, compiled & linked OK) |
| `terrain` | holdout | `> 40.0 s` | `7.9672 s` | `> 5.0×` | `185.3 ms` | `117,920 B` | **TIMEOUT** (`rc=124`, compiled & linked OK) |
| `expression` | tuned | — | `6.25 ms` | — | `13.1 ms` | `0 B` | **PARSE FAIL** (`unexpected token in expression`) |
| `histogram` | upstream | — | `24.10 ms` | — | `27.7 ms` | `0 B` | **PARSE FAIL** (`unexpected token in expression`) |
| `editdist` | tuned | — | `9.69 ms` | — | `23.0 ms` | `0 B` | **PARSE FAIL** (`unexpected token in expression`) |
| `list` | tuned | — | `0.26 ms` | — | `14.2 ms` | `0 B` | **PARSE FAIL** (`unexpected token in expression`) |
| `bst` | tuned | — | `13.42 ms` | — | `11.9 ms` | `0 B` | **PARSE FAIL** (`unexpected token in expression`) |

### Actionable Findings for Milestone 4 Integration (`B5K-M4-INT`)
1. **Reusable Harness Ready:** `python3 selfhost/bend5k/bench_b5k.py --bend5k <bin> --opt-flag -O2 --cpu 7 --runs 3 --json-out <out.json>` runs the full 7-family + `terrain` suite with exact checksums and live `gcc-10 -O2` comparisons.
2. **Parser Gaps Blocking 5/7 Proxies:**
   - All 4 tuned proxies share `research/agy/wave4_bench/inputs/tuned/driver.bend`, which uses `Unit <- IO.print(...)` in `do IO<Unit>` and `case r <> w <> n <> s <> Nil{}:` cons-pattern syntax.
   - `histogram` uses reusable `+` bindings (`+kb = kbits(...)`, `(t, +n) = r`).
3. **Huge `-O2` Headroom:** `nbody` (`15.21×` at `-O0`), `gameoflife` (`> 27×` at `-O0`), and `terrain` (`> 5.0×` at `-O0`) all compile (`144–219 ms`) and link cleanly today, giving a clean baseline to measure `-O0 → -O2` speedups.
