# S10-G Report: Compiler-Mode `--nodrop` Codegen Flag + Balanced `K=16`/`K=24` Zero-Tail Splitter

## 1. Executive Summary
- **Multiplier 1 (`apply_s10g.py` — Opt-In Compiler-Mode `--nodrop`):**
  - Clean, idempotent, 100% pure-Bend patch self-contained in `m09.bend` (0 new types, 0 C, 0 JS; composable with S10-A & S10-B).
  - Adds opt-in `--nodrop` prefix flag (`--nodrop x86-module`, `--nodrop x86-module-fast`, `--nodrop x86-object`, `--nodrop x86-object-fast`, `x86-module-nodrop`, `x86-module-fast-nodrop`) that strips `p111_rt_sink` calls from `P134Cursor` before x86 emission.
  - **Zero-Regression Gate (`n7_s10g` normal mode vs `n6_o2`):** **`3/3` 100% SHA-256 `.o` BIT-IDENTICAL** (`slice_O0`, `slice_O2`, `histogram_O2`), exact stdout (`34`, `122845198`). User programs compiled normally keep 100% Perceus/RFC `term_drop`.
  - **`--check-only` (`bend2/main.ts`):** **PASS** (`0` type/linearity errors across `8,956` `@unsafe` defs).
  - **`.o` Size Reduction:** **`-7.1%` to `-12.4%`** (`k10_m09`: `7,669 -> 6,717 KB` = `0.876×`; `k24_m00`: `4,940 -> 4,456 KB` = `0.902×`; `slice_O0`: `411 -> 382 KB`; `slice_O2`: `379 -> 350 KB`), omitting 150-byte `w13c_sink_tpl_bytes` / `agy_rt_sink_skip_text` blocks and shrinking compiler `.text` / link work.
  - **Peak RSS:** Well below the `1.5 GiB` worker ceiling (`k10_m09` `362.6 MiB`, `k24_m00` `290.4 MiB`, `slice` `8.7 MiB`, `histogram` `69.6 MiB`).
- **Multiplier 2 (`split_kN_balanced.py` — Strictly Balanced `K=16` & `K=24` Zero-Tail Splitter):**
  - Exact binary-search painter's partition over Tarjan SCC topological order (`main` pinned to `m{K-1}`), emitting `types.bend`, `m00.bend..m{K-1}.bend`, `m00.exp..m{K-1}.exp`, `manifest.txt`, `manifest.json` — 100% ready for S10-A2's zero-`.p130` `gen_stubs.py`.
  - **`K=16` (`compiler_pruned.bend`):** `avg = 205.2 KB`, `min = 175.6 KB`, `max = 209.3 KB`, **`max/avg = 1.020×`** (`0` cycles, `0` lost/dup). Full 16-module build with `n6_o2` succeeded cleanly (`max_rss = 412.9 MiB`, `94.80 MB` linked binary).
  - **`K=24` (`compiler_pruned.bend`):** `avg = 136.9 KB`, `min = 135.3 KB`, `max = 137.6 KB`, **`max/avg = 1.005×`** (`0` cycles, `0` lost/dup; `1.004×` on `compiler_s10ag.bend`). With S10-A stubs: all 24 modules are `198–257 KB` (`max/avg = 1.09×`), eliminating `K=10`'s `639 KB` straggler tax (`1.88× -> 1.005×`)!

## 2. Measurements (Pinned to CPUs `5, 7`)

### A. Balanced `K=16` & `K=24` Split Quality
| Split | Source | Modules | Avg KB | Min KB | Max KB | `max/avg` | Largest SCC | Cycles / Lost / Dup |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `K=16` | `compiler_pruned.bend` | 16 | 205.2 | 175.6 | 209.3 | **1.020×** | 52.7 KB (244 decls) | 0 / 0 / 0 |
| `K=24` | `compiler_pruned.bend` | 24 | 136.9 | 135.3 | 137.6 | **1.005×** | 52.7 KB (244 decls) | 0 / 0 / 0 |
| `K=16` | `compiler_s10ag.bend` | 16 | 205.8 | 180.7 | 209.3 | **1.017×** | 52.7 KB (244 decls) | 0 / 0 / 0 |
| `K=24` | `compiler_s10ag.bend` | 24 | 137.3 | 135.7 | 137.9 | **1.004×** | 52.7 KB (244 decls) | 0 / 0 / 0 |

### B. `--nodrop` Codegen & Runtime Verification (`n7_s10g`, CPUs `5, 7`)
| Workload | Mode | Normal Bit-ID vs `n6_o2` | Normal `.o` | `--nodrop` `.o` | `.o` Ratio | Normal Run / RSS | `--nodrop` Run / RSS |
|---|---|---|---:|---:|---:|---|---|
| `compiler_slice` | `-O0` | **YES** (`out=34`) | 411 KB | 382 KB | **0.93×** | 7.1 ms / 8.7 MiB | **6.8 ms** (`1.04×`) / 8.7 MiB |
| `compiler_slice` | `-O2` | **YES** (`out=34`) | 379 KB | 350 KB | **0.92×** | 6.1 ms / 8.7 MiB | 10.9 ms / 8.7 MiB (startup noise) |
| `histogram` | `-O2` | **YES** (`122845198`) | 264 KB | 254 KB | **0.96×** | 7274 ms / 70.0 MiB | 7677 ms (`0.95×`) / 69.6 MiB |
| `k10_m09` | `-O0` mod | N/A | 7,669 KB | 6,717 KB | **0.88×** | compile 56.7 s / 350.7 MiB | compile 59.4 s / 362.6 MiB |
| `k24_m00` | `-O0` mod | N/A | 4,940 KB | 4,456 KB | **0.90×** | compile 32.3 s / 294.9 MiB | compile 48.8 s / 290.4 MiB |

## 3. Integration Notes for Wave 16 (W16-INT)
1. **Use `split_kN_balanced.py --k 24` directly** on the unified Wave 16 `compiler.bend` (after S10-B tree-shaking) to get `1.005×` balanced modules + canonical `.exp` files ready for S10-A2 `gen_stubs.py` (3 even waves of 8 cores = zero tail!).
2. **Use `apply_s10g.py` on the unified compiler source** to expose `--nodrop` (`x86-module-nodrop` / `x86-module-fast-nodrop`). Because `n7_o2` spends `20.28%` in `term_drop` (`W14-C` profile), compile the Wave 16 `-O2` compiler binary with `--nodrop` and compare full 8-core self-compile wall time + peak RSS against normal `-O2` (keeping user `x86-object` / `x86-object-fast` 100% normal!).
3. **Important observation:** On tight array/reuse loops (`histogram`), skipping `p111_rt_sink` slightly reduces `rc == 1` in-place reuse (`0.95×`) — confirming our design rule that `--nodrop` MUST remain strictly opt-in for batch compiler binaries only, never for user programs.

## 4. Artifacts
- [apply_s10g.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/apply_s10g.py)
- [split_kN_balanced.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py)
- [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/results.json)
- [s10g-nodrop-k24.md](file:///home/ai/bend2_agy/experiments/agy/s10g-nodrop-k24.md)
