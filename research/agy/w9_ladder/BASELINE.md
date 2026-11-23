# Wave 9 3-Rung Live-Reachable Scaling Ladder & Native Profiler Baseline

**Base Native Compiler**: `selfhost/build/agy/wave8-native-self/n1` (`ulimit -s 262144`)  
**Base JS API**: `selfhost/build/agy/wave8_unified/api.mjs`  
**Machine-readable data**: [baseline.json](file:///home/ai/bend2_agy/research/agy/w9_ladder/baseline.json)

## 1. Ladder Construction & Verification

| Rung | File | Lines | Size | Annotated Defs | Live Segments | Private Fns | `--check-only` | `n1` Compile + Link + Run | JS vs `n1` `.o` Bytes |
|---|---|---:|---:|---:|---:|---:|---|---|---|
| **Rung 0** | [compiler_slice.bend](file:///home/ai/bend2_agy/research/agy/w7_bench/compiler_slice.bend) | 7,275 | 242.7 KB | 1,419 | **103** | 48 | PASS | PASS | Exact (`432,208 B`) |
| **Rung 1** | [rung1_parse.bend](file:///home/ai/bend2_agy/research/agy/w9_ladder/rung1_parse.bend) | 25,365 | 842.0 KB | 3,310 | **3,440** | 475 | PASS (type-clean) | PASS (`out=17`) | Exact (`9,087,456 B`) |
| **Rung 2** | [rung2_frontend.bend](file:///home/ai/bend2_agy/research/agy/w9_ladder/rung2_frontend.bend) | 35,495 | 1,270.2 KB | 4,669 | **10,373** | 1,222 | PASS (type-clean) | PASS (`out=9030`) | Exact (`26,509,728 B`) |

- **Rung 1 (`rung1_parse.bend`)**: Prefix up to `f_source_header` plus transitive closure of referenced patch defs/laws; `main() -> U32` invokes `f_source_header` on a real Bend snippet, keeping the entire lexer + parser live (**33.4×** more live segments than `compiler_slice`).
- **Rung 2 (`rung2_frontend.bend`)**: Prefix up to `p86_plan` plus transitive closure; `main() -> U32` invokes `p86_prepare` + `p86_plan`, keeping the entire frontend (lexer + parser + checker + annotator) live (**100.7×** more live segments than `compiler_slice`, **3.015×** Rung 1).

## 2. Stage Timings & Scaling Slopes

### Raw Wall Timings (ms)

| Rung | Live Segs | JS `p86_plan` | JS `x198pw_plan` | JS `x187_prepared_fast` | JS `x187_prepared` | JS Total (fast) | `n1` `x86-object-fast` | `n1` `x86-object` | `n1`/JS (fast) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `compiler_slice` | 103 | 2,796.7 | 976.4 | 913.2 | 1,792.3 | 4,686.3 | 13,361 | 16,117 | 2.85× |
| `rung1_parse` | 3,440 | 6,873.7 | 10,365.3 | 16,917.9 | 39,756.9 | 34,156.9 | 117,896 | 273,359 | 3.45× |
| `rung2_frontend` | 10,373 | 11,214.6 | 29,281.7 | 64,352.7 | — | 104,849.0 | 329,865 | — | 3.15× |

### Normalized Scaling Slopes (`ms / 1k live_segs`) & Superlinear Flags

| Stage | Rung 0 (103 segs) | Rung 1 (3,440 segs) | Rung 2 (10,373 segs) | R1 → R2 Slope Δ | Empirical Exponent | Scaling Verdict |
|---|---:|---:|---:|---:|---:|---|
| JS `p86_plan` (per 1k segs) | 27,152.4 | 1,998.2 | 1,081.1 | -45.9% | — | Scales with **defs**, not live segs |
| JS `p86_plan` (per **1k defs**) | 1,970.9 | 2,076.6 | 2,401.9 | **+15.7%** | **$N^{1.42}$** (vs defs) | **SUPERLINEAR WATCH** (10.7% share at R2) |
| JS `x198pw_plan` | 9,479.6 | 3,013.2 | 2,822.9 | -6.3% | $N^{0.94}$ | **Linear $O(N)$** (27.9% share at R2) |
| JS `x187_prepared_fast` | 8,866.0 | 4,918.0 | **6,203.9** | **+26.1%** | **$N^{1.21}$** | **SUPERLINEAR CLIFF** (61.4% share at R2!) |
| JS Total (fast) | 45,498.1 | 9,929.3 | 10,107.9 | +1.8% | $N^{1.02}$ | Dominated by `x187_prepared_fast` |
| Native `n1` `x86-object-fast` | 129,718.4 | 34,272.1 | 31,800.4 | -7.2% | $N^{0.93}$ | Linear-ish in R1→R2; 3.15× slower than V8 |

**Key Structural Takeaway**: On `compiler_slice.bend`, `p86_plan` appeared to be 59.7% of compile time while `x187_prepared_fast` was only 19.5%. Once real compiler subsystems are live (`rung2_frontend`), **`x187_prepared_fast` is 61.4% of total JS compile time AND exhibits a +26.1% superlinear slope increase (`4,918 → 6,204 ms / 1k live_segs`, $N^{1.21}$)**.

## 3. Native CPU Profile (`n1` compiling `rung1_parse.bend`, `x86-object-fast`)

- **Capture**: [n1_rung1_fast.samples](file:///home/ai/bend2_agy/research/agy/w9_ladder/n1_rung1_fast.samples) | **Decoded**: [n1_rung1_fast.profile.json](file:///home/ai/bend2_agy/research/agy/w9_ladder/n1_rung1_fast.profile.json)
- **Quality**: `11,629` samples @ `10,000 us` period, **zero loss** (`dropped=0, overruns=0`), `99.98%` delivery, `98.54%` resolved, `usable_for_process_cpu_attribution: true`, profiled wall `116.47 s` vs clean `117.90 s`.

### Physical Group Breakdown
| Group | Samples | % CPU | Est. Clean CPU |
|---|---:|---:|---:|
| `generated_bend` | 7,989 | 68.70% | 80.99 s |
| `reclamation` (`term_drop`, `span_fade`) | 1,417 | 12.19% | 14.37 s |
| `ownership_and_products` (`p125_rt_ctor2`, `take`, `borrow`) | 933 | 8.02% | 9.46 s |
| `other` (runtime ops/returns/libc) | 807 | 6.94% | 8.18 s |
| `scheduler` (`work_loop.constprop.0`) | 313 | 2.69% | 3.17 s |
| `unresolved` | 170 | 1.46% | 1.72 s |

### Top 20 Decoded Native CPU Hotspots
| Rank | % CPU | Samples | Est. CPU | Decoded Symbol |
|---:|---:|---:|---:|---|
| 1 | **13.72%** | 1,595 | 16.17 s | `p113d_FID_$p128borrow.owned.String.order.go` |
| 2 | **8.53%** | 992 | 10.06 s | `term_drop` |
| 3 | **4.82%** | 560 | 5.68 s | `p125_rt_ctor2` |
| 4 | **4.13%** | 480 | 4.87 s | `p113d_FID_$p118borrow.read.index_hash` |
| 5 | **3.65%** | 425 | 4.31 s | `span_fade` |
| 6 | **3.09%** | 359 | 3.64 s | `p113d_FID_$p118borrow.read.String.order.go` |
| 7 | **2.69%** | 313 | 3.17 s | `work_loop.constprop.0` |
| 8 | **1.38%** | 160 | 1.62 s | `[library_unresolved]` (`libc-2.31.so`) |
| 9 | **1.32%** | 154 | 1.56 s | `p111_rt_op` |
| 10 | **1.31%** | 152 | 1.54 s | `p111_rt_take` |
| 11 | **1.27%** | 148 | 1.50 s | `p198_rfc_take2` |
| 12 | **0.95%** | 110 | 1.12 s | `p113d_FID_$direct.nt_reverse` |
| 13 | **0.91%** | 106 | 1.07 s | `p118_rt_borrow_scalar_safe` |
| 14 | **0.80%** | 93 | 0.94 s | `p113d_FID_$direct.String.append` |
| 15 | **0.80%** | 93 | 0.94 s | `p113d_FID_$direct.String.order.go` |
| 16 | **0.80%** | 93 | 0.94 s | `p111_rt_return` |
| 17 | **0.70%** | 81 | 0.82 s | `p111_FID_$direct.index_find` |
| 18 | **0.70%** | 81 | 0.82 s | `p198_rfc_take4` |
| 19 | **0.70%** | 81 | 0.82 s | `p111_rt_ctor` |
| 20 | **0.65%** | 76 | 0.77 s | `p111_FID_$direct.w5c_idx_find_lr` |

**Top Wave 9 Native Optimization Targets**:
1. **`String.order.go` family (#1 + #6 + #15 = 17.61% / 20.75 s)**: Character-by-character linked-list `String` comparison dominates native self-compilation (BST/map lookups & sorting). Replacing string-keyed BSTs with hashed/U32-keyed tries or short-circuiting/inlining `String.order.go` is the single largest lever.
2. **Heap allocation + reclamation (#2 + #3 + #5 = 17.00% / 20.05 s)**: `term_drop` (`8.53%`), `p125_rt_ctor2` (`4.82%`), and `span_fade` (`3.65%`) reflect massive `Con`/`SCon` 2-field churn during codegen/ELF emission.
3. **Hash-trie lookup path (#4 + #17 + #20 = 5.48% / 6.46 s)**: `index_hash` (`4.13%`), `index_find` (`0.70%`), `w5c_idx_find_lr` (`0.65%`).
4. **`x187_prepared_fast` superlinear cliff (+26.1% / 1k segs, $N^{1.21}$)**: Accounts for 61.4% of Rung 2 compile time and is the primary scaling risk toward full 3.35 MB self-compilation.
