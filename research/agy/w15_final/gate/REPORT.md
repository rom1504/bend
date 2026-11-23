# Wave 15 Final Gate Report (`W15-GATE`): Native `n6_o2`

- **Date:** 2026-11-23
- **Compiler:** `selfhost/build/agy/wave15-native-mod/n6_o2` (`76,923,256 B`, pure-Bend modular native `-O2`)
- **Overall Verdict:** **FAIL / HOLD (BLOCKED ON `bst -O2` SIGSEGV)**
  - **Gate 1 (`158/158` Native Qualification + ELF Audit):** **PASS (`158/158`, `0` Observer violations, ELF audit PASS)**
  - **Gate 2 (7-Family Compiled-Program Scorecard, CPU `7`, 5-run median):** **FAIL (`6/7` PASS, `1/7` FAIL — `bst -O2` crashes with SIGSEGV)**
  - **Gate 3 (3-Holdout Scorecard, CPU `7`, 3-run median):** **PASS (`3/3` exact stdout, `2.4813× gcc-10 -O2` geomean, `1.3340×` faster than Wave 11)**
- **Artifacts:**
  - Combined JSON: [results.json](file:///home/ai/bend2_agy/research/agy/w15_final/gate/results.json)
  - Gate 1 Log & JSON: [qual.out](file:///home/ai/bend2_agy/research/agy/w15_final/gate/qual.out), [qual_results.json](file:///home/ai/bend2_agy/research/agy/w15_final/gate/qual_results.json)
  - Gate 2 & 3 Log & JSON: [bench.out](file:///home/ai/bend2_agy/research/agy/w15_final/gate/bench.out), [bench_results.json](file:///home/ai/bend2_agy/research/agy/w15_final/gate/bench_results.json)

---

## 1. Gate 1: Full `158/158` Native Qualification + ELF Audit (CPUs `0..6`)

Executed directly on `selfhost/build/agy/wave15-native-mod/n6_o2` with `ulimit -s 262144` and `timeout 60` per test (`67.04 s` total wall):

| Check | Mode | Result | Wall (s) | Compile Sum (s) | Notes |
| :--- | :--- | :--- | ---: | ---: | :--- |
| `64/64 native64` | `x86-object-fast` (`-O0`) | **64/64 PASS** | `10.06` | `60.02` | `1.49×` faster compile sum vs W11 `n4_o2` (`89.30 s`) |
| `64/64 native64` | `x86-object` (`-O2`) | **64/64 PASS** | `31.91` | `162.82` | `0` failures |
| `15/15` Observer Gate | `x86-object` (`-O2`) | **15/15 PASS** | `11.02` | — | `44+2` ABI; `normal`, `cap-no8`, `all-hot`; `0` violations |
| `15/15` Observer Gate | `x86-object-fast` (`-O0`) | **15/15 PASS** | `2.78` | — | `44+2` ABI; `normal`, `cap-no8`, `all-hot`; `0` violations |
| **Total Qualification** | — | **158/158 PASS** | **`67.04`** | — | **`0` failures, `0` violations** |

### ELF Section Audit (`readelf -SW` / `-sW`)
- **`n6_o2`-emitted `compiler_slice.bend` (`x86-object`, `-O2`):** `388,208 B` (`5,163.6 ms`) — **PASS** (`p111_cid_hot` in `.data (WA)`, `p111_cid_arity` in `.rodata (A)`, `p111_cid_names_0` in `.rodata (A)`).
- **`n6_o2`-emitted `compiler_slice.bend` (`x86-object-fast`, `-O0`):** `420,808 B` (`2,975.1 ms`) — **PASS** (`p111_cid_hot` in `.data (WA)`, `p111_cid_arity` in `.rodata (A)`, `p111_cid_names_0` in `.rodata (A)`).
- **`n6_o2` binary (`76,923,256 B`):** **PASS** — `.text = 69,281,361 B (AX)`, `.rodata = 201,536 B (A)`, `.data = 1,552,968 B (WA)`, `.bss = 1,148,552 B (WA)`.

---

## 2. Gate 2: Official 7-Family Compiled-Program Scorecard (CPU `7`, 5-Run Median)

Run strictly sequentially on `taskset -c 7` AFTER Gate 1 finished (zero CPU/cache contention). `clang-16` is not installed on this host; `clang-16` reference numbers are shown alongside live `gcc-10 -O2` timings.

| Family | Group | `n6_o2 -O2` (ms) | `gcc-10 -O2` (ms) | `× gcc-10` | `× clang-16 ref` | Speedup vs W11 | Direct Syms | Obj Bytes | Checksum |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| `gameoflife` | upstream | `436.1055` | `925.1525` | **`0.4714×`** | `1.8058×` | `1.0783×` | `27` | `62,416` | PASS (`3681094808`) |
| `expression` | tuned | `8.4504` | `6.2494` | `1.3522×` | `1.1677×` | `1.0816×` | `6` | `61,008` | PASS (`3393903617`) |
| `list` | tuned | `0.2653` | `0.2637` | **`1.0061×`** | **`0.9876×`** | **`1.4700×`** | `6` | `61,776` | PASS (`1904`) |
| `nbody` | upstream | `94.7366` | `88.7416` | `1.0676×` | `1.2682×` | `0.9865×` | `25` | `61,752` | PASS (`728502159`) |
| `histogram` | upstream | `29.5916` | `23.8618` | `1.2401×` | `1.2330×` | **`1.4322×`** | `61` | `270,584` | PASS (`3307081914`) |
| `bst` | tuned | **FAIL (SIGSEGV)** | `13.0823` | — | — | — | `10` | `79,992` | **FAIL (`rc=1`)** |
| `editdist` | tuned | `20.6250` | `9.8438` | `2.0952×` | `2.2373×` | `1.1215×` | `27` | `123,544` | PASS (`2065873279`) |
| **Geomean (6 passing only)** | — | — | — | **`1.1008×`** *(incomplete)* | `1.3923×` | `1.1812×` | — | — | **6/7 PASS (FAIL)** |

### Critical Findings on Gate 2
1. **`bst -O2` SIGSEGV (Blocking Bug):**
   - `bst` compiled with `n6_o2` at **`-O0` (`x86-object-fast`) PASSES** (`861157620`, `rc=0`).
   - `bst` compiled with `n6_o2` at **`-O2` (`x86-object`) CRASHES** even on minimal invocation (`bst_o2.bin +RTS --threads 1 --gpu off -RTS 1 0 64 17`) with `bend: memory fault (machine stack overflow?)`.
   - **`gdb` root-cause trace:**
     - Faulting instruction: `0x419589 <p113_rt_array_pair+217>: mov 0x0(%rbp,%rax,1),%r14d`
     - Call stack: `p113_rt_array_pair()` ← `p117v_FID_$direct.collect()` ← `p113d_FID_$direct.collect()` ← `p113d_FID_$direct.bench()`
     - Register state: `rbx = 0x7fffffffaff0` (a **stack address**), masked into `rdx = 0xffffffaff0` and indexed off `rbp = 0x200000000000` (`HEAP`). `p117v_$direct.collect` is passing a stack address (or corrupted value) where `p113_rt_array_pair` expects a tagged heap pointer.
2. **Missing W14-A Gains on `expression` & `editdist`:**
   - `expression` ran at `8.4504 ms` (`1.3522× C`) instead of W14-A's `5.896 ms` (`0.9434× C`).
   - `editdist` ran at `20.6250 ms` (`2.0952× C`, `123,544 B` obj) instead of W14-A's `15.703 ms` (`1.6210× C`, `110,440 B` obj).
   - This indicates either W14-A's passes were not active/wired on `expression`/`editdist` in `n6_o2` or were shadowed by another Wave 15 pass.

---

## 3. Gate 3: Official 3-Holdout Scorecard (CPU `7`, 3-Run Median)

Run strictly sequentially on `taskset -c 7` AFTER Gate 2 finished (`n6_o2 -O2` vs `gcc-10 -O2 -ffp-contract=off`):

| Holdout | `n6_o2 -O2` (s) | `gcc-10 -O2` (s) | `× gcc-10` | W11 `n4_o2` (s) | Speedup vs W11 | Direct Syms | Obj Bytes | Checksum |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| `terrain` | **`12.3272`** | `7.8668` | **`1.5670×`** | `21.731` | **`1.7628×`** | `71` | `995,248` | PASS (`2572468224`) |
| `hashmap` | **`5.8135`** | `1.1942` | `4.8681×` | `7.166` | **`1.2326×`** | `26` | `87,944` | PASS (`1307803744`) |
| `tree-radix` | **`10.7071`** | `5.3467` | `2.0026×` | `11.699` | **`1.0926×`** | `13` | `62,072` | PASS (`1998173798`) |
| **Geomean (3)** | — | — | **`2.4813×`** | — | **`1.3340×`** | — | — | **3/3 exact** |

*(Note: Gate 3 is a massive win — `terrain` hit the exact `~12.3 s` composed projection (`W12-D` + `W14-F`), `hashmap` dropped from `7.166 s -> 5.8135 s` (`1.23×` faster than W11), and `tree-radix` dropped to `10.7071 s`.)*

---

## 4. Hygiene
- `/tmp/agy_w15_gate/` removed cleanly.
- `/dev/md2` free space verified `>= 5.5 GiB` (`6.4 GiB` available).
- No compiler sources, `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, or `n6_o2` were modified.
