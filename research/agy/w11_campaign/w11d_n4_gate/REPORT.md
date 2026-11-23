# W11-D Official Promotion Gate Report: Native `n4_o2` (`158/158` Qual + 7-Family & 3-Holdout Runtime Scorecard)

**Verdict: PROMOTED — ALL GATES PASSED (`158/158` Native Qualification, `0` Observer Violations, ELF Audit PASS, `10/10` Exact Runtime Benchmarks, `1.386x` 7-Family Geomean vs `gcc-10`, `3.040x` 3-Holdout Geomean vs `gcc-10 -O2`).**

- **Compiler under test:** `selfhost/build/agy/wave11-native-mod/n4_o2` (`67,862,728 B`, native modular `-O2` self-reproduced compiler)
- **Runtime & Linker:** `selfhost/build/agy/unified/runtime-agy.o` linked with `/usr/bin/x86_64-linux-gnu-gcc-10 -O2 -no-pie ... -lm -pthread`
- **Isolation:**
  - Qualification: 4-way parallel on dedicated CPUs `0, 1, 2, 3` (`taskset -c 0..3`, `ulimit -s 262144`, `timeout 60` per test)
  - Runtime Scorecard: strictly single-core on CPU `0` (`taskset -c 0`, `ulimit -s 262144`, `timeout 60` per compile/link/run, 3-run median)
- **Artifacts:**
  - Combined JSON: [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/results.json)
  - Qualification runner & JSON: [run_w11d_qual.py](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/run_w11d_qual.py), [qual_results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/qual_results.json)
  - Runtime runner & JSON: [run_w11d_bench.py](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/run_w11d_bench.py), [bench_results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/bench_results.json)
  - Experiment receipt: [wave11d-n4-gate.md](file:///home/ai/bend2_agy/experiments/agy/wave11d-n4-gate.md)

---

## 1. `158/158` Native Qualification Gate (CPUs `0..3`, Total Wall `118.12 s`)

| Gate | Mode | Result | Wall Time (4c CPUs 0..3) | Compile Sum (`n4_o2` vs `n3_w10`) | Notes |
|---|---|---|---:|---:|---|
| **`64/64 native64`** | `x86-object-fast` (`-O0`) | **64 / 64 PASS** | **24.95 s** | `89.30 s` vs `100.57 s` (`1.13x` faster) | 61/61 exact stdout/stderr/rc + 3/3 exact refusal diagnostics |
| **`64/64 native64`** | `x86-object` (`-O2`) | **64 / 64 PASS** | **44.93 s** | `157.82 s` vs `245.92 s` (`1.56x` faster) | 61/61 exact stdout/stderr/rc + 3/3 exact refusal diagnostics |
| **`15/15` Live-Metadata Observer** | `x86-object` (`-O2`) | **15 / 15 PASS** | **17.03 s** | — | 5 probes × `{normal, cap-no8, all-hot}`, **0 violations** |
| **`15/15` Live-Metadata Observer** | `x86-object-fast` (`-O0`) | **15 / 15 PASS** | **4.27 s** | — | 5 probes × `{normal, cap-no8, all-hot}`, **0 violations** |
| **ELF Section Audit** | `x86-object` & `x86-object-fast` | **PASS (both)** | — | — | `p111_cid_hot` in `.data` (`WA`), `p111_cid_arity` & `p111_cid_names_0` in `.rodata` (`A`, `LOCAL`) |

### Observer Probes Detail (All 5 Probes Match Upstream `locked_bun.sh`, 0 Violations)

| Probe | Upstream Ref | `-O2` Compile (ms) | `-O2` `.o` (B) | `-O0` Compile (ms) | `-O0` `.o` (B) | Modes (`normal`/`cap-no8`/`all-hot`) |
|---|---:|---:|---:|---:|---:|:---:|
| `map_set_del_get` | `4008146603` | 16,980.1 | 481,224 | 4,211.7 | 535,912 | **PASS / PASS / PASS** |
| `bst_zipper` | `382401606` | 2,061.4 | 67,816 | 2,848.6 | 83,152 | **PASS / PASS / PASS** |
| `flow_native` | `49913905` | 3,019.8 | 55,056 | 2,802.3 | 63,728 | **PASS / PASS / PASS** |
| `perceus_reuse` | `3114` | 1,642.4 | 33,184 | 1,574.4 | 38,528 | **PASS / PASS / PASS** |
| `listapp_arrlist` | `3905793128` | 1,773.0 | 43,384 | 1,734.1 | 53,400 | **PASS / PASS / PASS** |

### ELF Section Audit (`readelf -SW` / `readelf -sW` on `compiler_slice.bend`)

| Mode | Compile (ms) | `.o` Bytes | `.text` (`AX`, Ndx 1) | `.rodata` (`A`, Ndx 2) | `.data` (`WA`, Ndx 3) | `p111_cid_hot` | `p111_cid_arity` | `p111_cid_names_0` |
|---|---:|---:|---:|---:|---:|---|---|---|
| `x86-object` (`-O2`) | 10,170.5 | `375,080` | `0x027fb6` | `0x008cdd` | `0x003779` | `.data` (`WA`, Ndx 3, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 5 B, `LOCAL`) |
| `x86-object-fast` (`-O0`) | 13,517.9 | `438,184` | `0x038747` | `0x008cdd` | `0x003779` | `.data` (`WA`, Ndx 3, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 5 B, `LOCAL`) |

---

## 2. Full 7-Family + 3-Holdout Runtime Scorecard (CPU `0`, 3-Run Median)

### Suite A: 7-Family Proxy Suite (`7/7` Exact Checksums, Live Paired on CPU `0`)

| Benchmark | Group | C (`gcc-10`, CPU 0) | C (`clang-16` ref) | Wave 8 `n1` (CPU 0) | Wave 10 `n3_w10` (CPU 4 ref) | **`n4_o2` (`-O2`, CPU 0)** | **`n4_o2 / C`** | **`n4_o2 / W8`** | **`n4_o2 / W10`** | Direct Syms (`W8 -> n4`) |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **`histogram`** | upstream | 23.09 ms | 24.00 ms | 44.22 ms | 356.03 ms | **42.38 ms** | **1.835x** | 0.958x | **0.119x** (`8.40x` faster) | `61 -> 61` |
| **`gameoflife`** | upstream | 964.59 ms | 241.50 ms | 1,348.36 ms | 1,419.35 ms | **470.25 ms** | **0.487x** | **0.349x** (`2.87x` faster) | **0.331x** (`3.02x` faster) | `27 -> 27` |
| **`nbody`** | upstream | 91.06 ms | 74.70 ms | 97.21 ms | 516.56 ms | **93.46 ms** | **1.026x** | 0.961x | **0.181x** (`5.53x` faster) | `25 -> 25` |
| **`list`** | tuned | 0.269 ms | 0.269 ms | 0.274 ms | 0.531 ms | **0.390 ms** | **1.451x** | 1.424x* | **0.735x** (`1.36x` faster) | `7 -> 6` |
| **`expression`** | tuned | 6.60 ms | 7.24 ms | 10.02 ms | 16.51 ms | **9.14 ms** | **1.384x** | 0.912x | **0.554x** (`1.81x` faster) | `7 -> 6` |
| **`bst`** | tuned | 13.25 ms | 10.84 ms | 29.73 ms | 107.89 ms | **30.58 ms** | **2.308x** | 1.029x | **0.283x** (`3.53x` faster) | `11 -> 10` |
| **`editdist`** | tuned | 10.00 ms | 9.22 ms | 22.81 ms | 93.75 ms | **23.13 ms** | **2.312x** | 1.014x | **0.247x** (`4.05x` faster) | `28 -> 27` |
| **7-Family Geomean** | — | — | — | `1.561x C` (`2.001x C16`) | `3.439x C` (`5.985x C16`) | **`1.386x C`** (`1.776x C16`) | **1.386x** | **0.888x** (`1.13x` faster) | **0.297x** (`3.37x` faster) | — |

*\*Note on `list`*: raw samples on `n4_o2` were `[33, 51, 47] ms` (first sample `33 ms` identical to Wave 8's `[33, 33, 33] ms`).

### Suite B: 3 Blind Holdouts (`3/3` Exact Stdout, CPU `0`, 3-Run Median vs `gcc-10 -O2`)

| Benchmark | Expected Stdout | C (`gcc-10 -O2`, CPU 0) | Wave 8 `n1` (CPU 4 ref) | Wave 10 `n3_w10` (CPU 4 ref) | **`n4_o2` (`-O2`, CPU 0)** | **`n4_o2 / C (-O2)`** | **`n4_o2 / W8`** | Direct Syms |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| **`terrain`** | `2572468224` | 8.294 s | 39.660 s | `TIMEOUT (>120 s)` | **21.731 s** | **2.620x** | **0.548x** (`1.83x` faster) | `70` |
| **`hashmap`** | `1307803744` | 1.212 s | 15.273 s | 19.274 s | **7.166 s** | **5.914x** | **0.469x** (`2.13x` faster) | `26` |
| **`tree-radix`** | `1998173798` | 6.451 s | 15.612 s | 14.978 s | **11.699 s** | **1.814x** | **0.749x** (`1.33x` faster) | `13` |
| **3-Holdout Geomean** | — | — | — | — | — | **3.040x** | — | — |

---

## 3. Key Takeaways
1. **Wave 10 `$product.*` regression completely eliminated:** All direct specializations (`histogram` 61, `terrain` 70, `hashmap` 26, `nbody` 25, `gameoflife` 27) are restored in `n4_o2`, turning Wave 10's `3.439x C` (`terrain` timeout) into **`1.386x C`** on the 7-family proxy (`3.37x` faster than Wave 10) and **`21.73 s` (`2.62x C`)** on `terrain`.
2. **Wave 8 `gameoflife` regression completely recovered:** `gameoflife` drops from `1,348.36 ms` (Wave 8) to **`470.25 ms` (`0.487x gcc-10`, `2.87x` faster than Wave 8)**, and all 3 holdouts (`terrain`, `hashmap`, `tree-radix`) are `1.33x–2.13x` faster than Wave 8.
3. **Compiler throughput:** Native `n4_o2` compiles the full `64/64` `-O2` catalog `1.56x` faster (`157.82 s` sum vs `245.92 s` on `n3_w10`) and completes the entire `158/158` qualification + ELF audit in `118.12 s` wall on 4 cores.

## 4. Hygiene & Disk Verification
- Strictly isolated to CPUs `0..3` (qual) and CPU `0` (bench); CPUs `4..7` untouched.
- `/tmp/agy_w11d/` removed and verified absent.
- `/dev/md2` free space: **`6.6 GiB`** (`>= 5.0 GiB`).
- Read-only paths (`bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, `experiments/STEERING.md`, `experiments/ledger.md`, `/home/ai/bend2/build/publish/bend`) untouched.
