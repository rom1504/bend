# W14-C Report: Native `n5_o2` `m11` Zero-Loss Profile (`20.3 s -> <= 14 s` Levers) & `K=8` vs `K=14` True-Cold Pipelining Experiment

**Date:** 2026-11-23  
**Binary:** `selfhost/build/agy/wave13-native-mod/n5_o2` (`72,280,920 B`, full `14/14` `-O2`)  
**Isolation:** Dedicated CPUs `2, 3`; read-only on `wave13_unified/`, `n5_o2`, `/tmp/agy_k14_w13_cache/`  
**Artifacts:** [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/results.json), [m11_profile.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/m11_profile.json), [split_k8_w13.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/split_k8_w13.py), [run_w14c.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/run_w14c.py)

---

## 1. Executive Summary & Verdicts

1. **`K=8` vs `K=14` True-Cold Verdict: `K=14` WINS (`216.38 s` vs `242.75 s`) — REJECT `K=8` for True-Cold.**
   - Splitting `wave13_unified/compiler.bend` (`3.65 MB`, `410` types, `9,306` defs, `901` laws) into `K=8` balanced acyclic modules (`m00..m07`, `387–461 KB` each, `0` lost/dup/cycles) and running native `n5_o2` across all `7` `x86-iface` hops + all `8` `x86-module-fast` compiles + native `x86-merge-obj` + `gcc-10` link (`n6_k8`, `90.5 MB`, smoke `out=34` PASS):
     - **`K=8` 7-hop `x86-iface` chain:** **`207.10 s`** vs `K=14` 13-hop **`196.34 s`** (`0.95×` — actually **+10.76 s slower**, not `2.5–3×` faster!).
     - **`K=8` 7-core pipelined true-cold E2E:** **`242.75 s`** (`207.10 s` iface + `36.15 s` `m07` tail + `0.54 s` merge/link) vs `K=14`'s **`216.38 s`** (**+26.37 s slower**).
     - **`K=8` leaf-edit latency (`m07`):** **`36.15 s`** vs `K=14`'s `m11` **`20.00 s`** (`1.81×` slower).
     - **`K=8` 7-core warm-`.p130` E2E:** **`74.66 s`** vs `K=14`'s **`76.93 s`** (essentially tied).
     - **Why `K=8` failed to beat `K=14`:** `.p130` decode (`prep`) is only `~10–16 s` summed across all modules. The dominant cost inside `x86-iface` is `p86_plan` + interface construction over the module's own defs, which scales super-linearly on the dense early modules (`m00`: `1,938 defs`, `1,653 exports` took **`42.41 s`** alone vs `16.07 s` for `m00a + m00b` in `K=14`!), AND the larger `m07` leaf doubles the post-iface tail (`36.15 s` vs `19.48 s`).
     - **Notable consolation finding:** `K=8` reduced total FIDs by **`6,207`** (`58,973 / 65,532` vs `K=14`'s `65,180 / 65,532` — `10.0%` FID headroom) due to fewer cross-module private stubs. `research/agy/w10_mod_bend/k8_wave13/` was removed since `K=8` lost on true-cold (`split_k8_w13.py` is preserved for exact reproduction).
     - **Strategic conclusion:** Shrinking `K` will **not** break `<= 100 s` true-cold. Only **accelerating `x86-iface` itself** (W14-B: avoiding full body type-checking / incremental `.p130` + W14-A/D `p86_plan` speedups) can break `<= 100 s`.

2. **Zero-Loss Native `n5_o2` Profile of `m11` (`20.32 s`, `4,083` samples, `0` dropped, `0` overruns, `zero_loss=True`, `usable=True`):**
   - **`p86_plan` (`5,629 ms`, `27.7%`) + `x198pw_plan` (`7,782 ms`, `38.3%`) = `66.0%` (`13.41 s`)** of `m11` compile time.
   - **Physical CPU buckets:** `generated_bend = 53.71%` (`10.85 s`), `reclamation = 24.34%` (`4.92 s`: `term_drop` `20.28%` + `span_fade` `4.07%`), `ownership_and_products = 10.68%` (`2.16 s`: `p125_rt_ctor2` `4.95%`, `p198_rfc_take2` `2.94%`, `p111_rt_take` `2.20%`, `p111_rt_ctor` `1.59%`, `ctr_take` `1.32%`).
   - **#1 Bend hotspot family:** `String` cons-list churn — `String.append` (`4.11%`), `agy_str_eq` (`1.93%`), `p98_tag_eq` (`1.49%`), `index_hash` (`1.45%`), `String.eq` (`1.10%`), `p88_string_eq` (`0.78%`), `U32.show.fin` (`0.61%`) = **`11.47%` direct leaf CPU** + a huge share of `term_drop`/`ctor2`/`take2`.
   - **Concrete levers (`20.3 s -> 11.5–13.8 s`, `<= 14 s`):** (1) inline fast-path `term_drop` skip + `-O2` inlined `ctor2` bump-alloc in x86 codegen (`-2.0 to -3.0 s`), (2) `U32`-tag `KTerm`/`p98_tag_eq` + direct non-closure `w6_local_find` + inlined `String.eq` (`-2.5 to -3.5 s`), (3) reduce `String.append` in `x198pw_plan` + borrow `tree` in `index_find` (`-1.0 to -1.5 s`), (4) tighten `p130` word-pair decode in `prep` (`-1.0 s`).

---

## 2. Part 1: Zero-Loss Native Profile of `n5_o2` Compiling `m11` (CPU `2`)

### 2.1 Capture Integrity & `--trace` Breakdown
- **Input:** `m11_exp.bend` (`import Base` + `k14_wave13/m11.bend`) + `/tmp/agy_k14_w13_cache/iface/m10.p130` (`42,058,950 B`, `779,398` nodes, `12,086` strings), `fid_base=61881`.
- **Clean run (CPU `2`):** `wall = 20,317.0 ms`, `cpu = 20.1918 s`, `m11.o = 5,939,000 B` (**100% SHA-256 bit-identical** to W13 cache).
- **Profiled run (CPU `2`, `sample-threads.c`, `BEND_SAMPLE_PERIOD_US=5000`):** `wall = 20,524.9 ms` (**`+1.02%` overhead**), `cpu = 20.4421 s`, `m11.o` **bit-identical**.
  *(Note: an initial `1000 us` run hit `15,714` timer overruns due to the 4 ms Linux kernel tick; raising `period_us` to `5000` achieved `0` dropped, `0` overruns, `4,083` samples, `zero_loss=True`, `usable=True`.)*

| `--trace` Stage | Time (ms) | Share of Wall | Primary Work |
|---|---:|---:|---|
| `read` | 179.0 | 0.9% | Read `.bend` + `m10.p130` (`42 MB`) |
| `prep` | 2,023.0 | 10.0% | Decode `779k`-node `m10.p130` (`p88_number_read`, `p130m_word`) |
| `p86_plan` | 5,629.0 | 27.7% | Parse + resolve + check `m11` (`index_find`, `index_hash`, `p131i_insert`) |
| `x198pw_plan` | 7,782.0 | 38.3% | Lowering/planning (`String.append`, `p98_tag_eq`, `w6_local_find`, `agy_str_eq`) |
| `x187_priv` | 131.0 | 0.6% | Private helper emission (almost none in leaf `m11`) |
| `x187_pub` | 2,511.0 | 12.4% | Direct-to-`X187Build` x86-64 emission (`3,299` segs) |
| `x187_elf` | 1,950.0 | 9.6% | ELF `.o` serialization (`5.94 MB`) |
| **Total Wall** | **20,317.0** | **100.0%** | *(unaccounted exit/init: `112 ms`)* |

### 2.2 Physical Group Breakdown (`analyze.py`)

| Group | Samples | Share (%) | Est. Clean CPU (s) |
|---|---:|---:|---:|
| `generated_bend` | 2,193 | 53.71% | 10.845 |
| `reclamation` (`term_drop`, `span_fade`) | 994 | 24.34% | 4.916 |
| `ownership_and_products` (`ctor2`, `take2`, `rt_take`, `rt_ctor`, `ctr_take`) | 436 | 10.68% | 2.156 |
| `other` (`p111_rt_op`, `p111_rt_sink`, `io_str`, libc) | 383 | 9.38% | 1.894 |
| `scheduler` (`work_loop.constprop.0`) | 41 | 1.00% | 0.203 |
| `unresolved` (`[library_unresolved]`) | 35 | 0.86% | 0.173 |
| `allocation` (`heap_alloc_miss` / bump) | 1 | 0.02% | 0.005 |

### 2.3 Top 15 Leaf Functions

| Rank | Leaf Symbol (Decoded) | Samples | Share (%) | Est. CPU (s) | Category / Root Cause |
|---:|---|---:|---:|---:|---|
| 1 | `term_drop` | 828 | 20.28% | 4.095 | Reclamation of short-lived `SCon` / `Con` / AST / closure nodes |
| 2 | `p125_rt_ctor2` | 202 | 4.95% | 0.999 | 2-field ctor call (`SCon`, `Con`, `Pair`) — out-of-line call overhead |
| 3 | `p113d_FID_$direct.String.append` | 168 | 4.11% | 0.831 | `#1` Bend leaf; copies left `SCon` list char-by-char |
| 4 | `span_fade` | 166 | 4.07% | 0.821 | Reclamation helper called from `term_drop` |
| 5 | `p198_rfc_take2` | 120 | 2.94% | 0.593 | 2-field unpack + refcount check |
| 6 | `p111_rt_take` | 90 | 2.20% | 0.445 | Generic `N`-field unpack |
| 7 | `p113d_FID_$direct.agy_str_eq` | 79 | 1.93% | 0.391 | 1-line wrapper around `String.eq` (hot in `w6_local_find`) |
| 8 | `p113d_FID_$direct.index_find` | 65 | 1.59% | 0.321 | Radix-tree lookup; takes `tree` owned (drops unused child!) |
| 9 | `p111_rt_ctor` | 65 | 1.59% | 0.321 | Generic `N`-field constructor |
| 10 | `p113d_FID_$direct.p98_tag_eq` | 61 | 1.49% | 0.302 | `String.eq(tag, key)` on `KTerm` string tags |
| 11 | `p113d_FID_$direct.index_hash` | 59 | 1.45% | 0.292 | FNV-1a over `SCon` char-by-char |
| 12 | `ctr_take` | 54 | 1.32% | 0.267 | Runtime constructor take |
| 13 | `p113d_FID_$direct.String.eq` | 45 | 1.10% | 0.223 | Recursive char-by-char `SCon` equality |
| 14 | `p111_rt_op` | 40 | 0.98% | 0.198 | Runtime primitive op dispatch |
| 15 | `work_loop.constprop.0` | 39 | 0.96% | 0.193 | Runtime scheduler loop |

*(Ranks 16–25: `w6_local_find` `0.93%`, `[library_unresolved]` `0.86%`, `nt_reverse` `0.78%`, `p88_string_eq` `0.78%`, `p88_number_read` `0.76%`, `p131i_insert` `0.76%`, `p111_rt_sink` `0.71%`, `U32.show.fin` `0.61%`, `nu_has` `0.61%`, `io_str` `0.61%`.)*

### 2.4 Concrete Levers to Push `m11` from `20.3 s` to `<= 14 s`

1. **Pure-Bend x86-64 Codegen: Inline Immediate-Skip Before `term_drop` + Inline Bump-Alloc `ctor2` (Target: `-2.0 to -3.0 s`):**
   - `term_drop` (`20.28%`) + `span_fade` (`4.07%`) + `p125_rt_ctor2` (`4.95%`) + `p198_rfc_take2` (`2.94%`) = `32.24%` (`6.51 s`).
   - In `-O2` x86 codegen (no `runtime.c` edit needed!), emitting a 2–3 instruction tag check to skip `call term_drop` on immediate/unboxed terms and inlining the bump-pointer fast path for `ctor2` (calling `heap_alloc_miss`, currently only `0.51%`, on overflow) eliminates millions of out-of-line runtime calls.
2. **Eliminate `String`-Tag & Linear `w6_local_find` Churn (Target: `-2.5 to -3.5 s`):**
   - `p98_tag_eq` (`1.49%`), `agy_str_eq` (`1.93%`), `String.eq` (`1.10%`), `p88_string_eq` (`0.78%`), and `w6_local_find` (`0.93%`) total `6.23%` direct leaf CPU plus heavy `term_drop`/`ctor2` churn.
   - Replace `KTerm` `String` tags (`"Lam"`, `"App"`, ...) with `U32` tag IDs (or direct `U32` dispatch in `p98_tag_eq`), rewrite `w6_local_find` (L50062) without `nt_choose` closure allocation (direct `match` / `U32` hash pre-check), and inline `agy_str_eq`/`p88_string_eq`.
3. **Cut `String.append` (`4.11%`) in `x198pw_plan` + Borrow `tree` in `index_find` (`1.59%`) (Target: `-1.0 to -1.5 s`):**
   - `String.append` is the #1 Bend function (`0.831 s` leaf + large `SCon` alloc/drop tail). Using difference-lists / `U32` IDs instead of repeated symbol-name `String.append` in `x198pw_plan`, and borrowing `+tree` in `index_find` (L4970) so radix lookup doesn't `term_drop` the unused branch at every level.
4. **Tighten `.p130` Decode (`prep = 2.02 s`, `p88_number_read` `0.76%` + `p130m_word` `0.59%`) (Target: `-0.8 to -1.2 s`):**
   - Reducing `.p130` decode work (or W14-B compact/delta `.p130`) cuts `prep` on `m11` and every downstream module.

---

## 3. Part 2: `K=8` Acyclic Split & Native `n5_o2` True-Cold Measurement

### 3.1 `K=8` Split & Native Measurements (`n5_o2`, CPUs `2, 3`)
- **Split:** `410` types, `9,306` defs, `901` laws, `0` lost, `0` duplicated, `0` cycles (`split_ms = 1,724.4 ms`).
- **FID Budget:** **`58,973 / 65,532`** (`6,559` FIDs spare vs `K=14`'s `352` spare — `6,207` FIDs saved!).
- **Native Link & Smoke:** `x86-merge-obj` = `88.3 ms` (`416,808 B`), `gcc-10 -O2 -no-pie` = `449.3 ms`, `n6_k8` = `90,526,040 B`, `compiler_slice.bend` smoke = **PASS (`out=34`, `8,521.3 ms`, `420,440 B`)**.

| Module | Size (KB) | Defs | Exports | `x86-iface` (ms) | `.p130` Nodes | `x86-module-fast` (ms) | `prep` (ms) | `p86_plan` (ms) | `x198pw_plan` (ms) | Segs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `m00` | 461.3 | 1,938 | 1,653 | 42,410.1 | 199,763 | 43,431.3 | 134 | 11,533 | 11,471 | 8,548 |
| `m01` | 453.7 | 1,366 | 876 | 32,915.8 | 286,849 | 40,866.2 | 528 | 9,673 | 14,003 | 7,709 |
| `m02` | 453.6 | 1,085 | 546 | 33,062.5 | 368,978 | 37,969.9 | 773 | 9,553 | 13,718 | 6,786 |
| `m03` | 450.7 | 1,069 | 520 | 34,130.6 | 459,571 | 38,476.9 | 972 | 9,967 | 15,243 | 7,189 |
| `m04` | 444.7 | 1,088 | 438 | 21,595.4 | 551,734 | 45,935.4 | 1,186 | 10,933 | 16,649 | 8,390 |
| `m05` | 437.0 | 1,020 | 283 | 19,782.9 | 645,144 | 38,871.9 | 1,456 | 9,439 | 13,932 | 8,136 |
| `m06` | 427.2 | 1,006 | 114 | 22,168.9 | 746,999 | 56,305.1 *(redo: 35,254.6)* | 3,109 | 14,653 | 24,674 | 7,035 |
| `m07` | 387.1 | 734 | 0 | — | — | 36,151.1 *(redo: 44,293.2)* | 3,698 | 12,911 | 12,009 | 5,180 |
| **Total** | **3,515.3** | **9,306** | **4,430** | **207,100.2** | **746,999** | **338,007.8** | **11,856** | **88,662** | **121,699** | **58,973** |

### 3.2 Head-to-Head: `K=8` vs `K=14` (Native `n5_o2`)

| Metric | `K=14` (W13-INT Measured) | `K=8` (W14-C Measured / Sim) | Winner |
|---|---:|---:|---|
| Sequential `x86-iface` chain | **196.34 s** (`13` hops) | 207.10 s (`7` hops) | **`K=14`** (`-10.76 s`) |
| Post-iface compile tail (7-core) | **19.48 s** (`m11`) | 36.15 s (`m07`) | **`K=14`** (`-16.67 s`) |
| **7-Core Pipelined True-Cold E2E** | **216.38 s** | 242.75 s | **`K=14`** (`-26.37 s`) |
| 5-Core Pipelined True-Cold E2E | ~216.4 s | 242.75 s | **`K=14`** (`-26.4 s`) |
| 7-Core Warm-`.p130` E2E | 76.93 s | **74.66 s** | `K=8` (`-2.27 s`, tie) |
| Leaf-Edit Incremental Rebuild | **20.00 s** (`m11`) | 36.69 s (`m07` + link) | **`K=14`** (`1.83×` faster) |
| Total FIDs Used (`/ 65,532`) | 65,180 (`99.5%`) | **58,973 (`90.0%`)** | **`K=8`** (`-6,207` FIDs) |

**Conclusion:** Keep **`K=14`** as the primary modular build layout. Focus Wave 14 optimization effort on **W14-B (`x86-iface` speedup)** for `<= 100 s` true-cold and on the **4 `m11` profile levers above** (`term_drop`/`ctor2` x86 fast-path, `String`-tag/`w6_local_find` elimination, `String.append`/`index_find` reduction, `prep` decode) for `<= 14 s` leaf edits and `<= 55 s` warm-cold.
