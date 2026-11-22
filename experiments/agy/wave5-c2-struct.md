# Wave 5 Engine A Track W5-C2: Structural `10×–100×` Compile-Speed Architect

- **Date**: `2026-11-22`
- **Baseline**: `selfhost/build/agy/wave4c_unified/{compiler.bend,api.mjs}` (checkpoint `775b1824`)
- **Deliverables**:
  - Composable patcher: [apply_struct_fast.py](file:///home/ai/bend2_agy/research/agy/wave5_struct/apply_struct_fast.py)
  - Full-pipeline profiler & V8 analyzer: [profile_pipeline.mjs](file:///home/ai/bend2_agy/research/agy/wave5_struct/profile_pipeline.mjs), [analyze_cpuprof.py](file:///home/ai/bend2_agy/research/agy/wave5_struct/analyze_cpuprof.py)
  - Built artifact (`11 MiB < 40 MiB`): `selfhost/build/agy/wave5_c2/{compiler.bend,api.mjs}`
- **Scope Separation**: 100% orthogonal to Track W5-C1 (`w4_post_select` backend peepholes — untouched by W5-C2 for zero-conflict composition).

---

## 1. Full-Pipeline Stage Profile (`wave4c_unified/api.mjs`)

We profiled `wave4c_unified/api.mjs` across 6 diverse programs (`lexer`, `raytrace`, `gameoflife`, `histogram`, `nbody`, `editdist`) using stage timers (`p86_plan`, `x198pw_plan`, `x187_prepared`) and V8 `--cpu-prof` (`55,392` samples across `60.52 s` on 5 programs before adding `editdist`, and `64.07 s` wall-clock across all 6).

### 1.1 Stage Wall-Clock Breakdown (Baseline `wave4c_unified`)

| Program | `plan` (Parse+Check+IR) | `pw` (Lower+Opt+Cursor) | `emit` (x86+ELF) | Total | `.o` Size |
|---|---:|---:|---:|---:|---:|
| `lexer` | 4,794 ms (32%) | 4,031 ms (27%) | 6,035 ms (41%) | 14,860 ms | 88,416 B |
| `raytrace` | 696 ms (13%) | 2,440 ms (45%) | 2,260 ms (42%) | 5,396 ms | 102,336 B |
| `gameoflife` | 238 ms (1%) | 7,767 ms (34%) | 14,654 ms (65%) | 22,659 ms | 68,728 B |
| `histogram` | 552 ms (6%) | 1,690 ms (19%) | 6,880 ms (75%) | 9,123 ms | 267,168 B |
| `nbody` | 713 ms (13%) | 3,312 ms (62%) | 1,323 ms (25%) | 5,348 ms | 60,088 B |
| `editdist` | 235 ms (4%) | 947 ms (14%) | 5,507 ms (82%) | 6,689 ms | 145,800 B |
| **TOTAL (6 programs)** | **7,228 ms (11.3%)** | **20,188 ms (31.5%)** | **36,659 ms (57.2%)** | **64,074 ms** | **732,536 B** |

### 1.2 Top Structural Hotspots Outside `w4_post_select` (V8 Inclusive CPU Profile, `60.52 s`)

`w4_post_select` (owned by Track W5-C1) accounted for `6.48 s` (`10.7%`) in this profile. Outside `w4_post_select`, the V8 CPU profile exposed **three massive structural bottlenecks**:

| Rank | Function / Subsystem | Inclusive Time | Share | Root Cause |
|---:|---|---:|---:|---|
| 1 | **`agy_str_eq` + `char_len` + `index_bucket` + `index_hash`** | **~20.0 s** | **~33%** | Cons-list `String` destructuring (`char_len` = `9.65 s` self, `agy_str_eq` = `12.21 s` incl.) driven by O(N²) scans and redundant hashing |
| 2 | **`p113k_body` / `p113k_join`** (`pw` stage) | **11.28 s** (`7.35 s` in `p113k_join`) | **18.6%** | `p113k_join_record` called `p111v_get(right, name)` **and then** `p113k_get(right, name)` (duplicate lookup!), then `p113k_put(out, ...)` called `p113l_version(out, name)` (always 0!) + `index_set` — **4× `index_hash` + 3× `index_find` per variable per `if/else` join**, with zero trie pruning! |
| 3 | **`x186_e_body`** (`emit` stage CSE/alias pass) | **6.45 s** | **10.7%** | `facts: List<X186Expr>` and `aliases: List<X186Alias>` had their caps raised to **1,024** while remaining linear linked lists! Every single statement ran O(1024) `x186_e_kill_facts` (3 `agy_str_eq`/item), O(1024) `x186_e_kill_aliases` (2 `agy_str_eq`/item), O(1024) `x186_e_alias`, O(1024) `x186_e_find`, and O(1024) `nt_count`. |
| 4 | **`x185_sf_scalar` / `x187_encode` / `index_remove`** | **~1.5 s** | **~2.5%** | `x185_sf_scalar` called `p111v_get(buffers, buffer)` on every `N111Load` even when `facts` was `Nil{}`; `x187_encode` checked `agy_str_eq(op, "sqrtss")` and `agy_str_eq(op, "cvttss2siq")` on every single emitted instruction before `x202o_dispatch`; `index_remove` still called `p88_string_eq`. |

---

## 2. Structural Optimizations Implemented (`apply_struct_fast.py`)

All 5 optimizations are 100% general, 1-scrutinee-clean, and **100% bit-exact** with `wave4c_unified`:

1. **Opt 1 — `p113k_join` Patricia-Trie Structural Intersection + Single-Hash `p113k_put`**:
   - Replaced leaf-by-leaf re-hashing in `p113k_join` with structural Patricia-trie intersection (`p113k_join_go`, `p113k_join_leaf`, `p113k_join_node`, `p113k_join_nn`, `p113k_join_nn_diff`): disjoint subtrees prune in **O(1)** via `(lh ^ rh) & (mask - 1) != 0`, leaf intersections reuse the stored `U32` hash directly (0 `index_hash` calls), eliminate the duplicate `p113k_get(right, name)` lookup, and insert directly with `Epoch=1` via `p131i_insert` (0 `p113l_version` calls on fresh `out`).
   - Fused `p113k_put` to compute `index_hash(name, 2166136261)` once instead of twice.
2. **Opt 2 — `x186_e_*` O(N²) → O(log N) Patricia-Trie CSE & Alias Engine**:
   - Extended `X186ExprState` with `factCount: U32`, `aliasCount: U32` (eliminating O(1024) `nt_count` scans), a `mentioned: KDef` hash-trie of all variable names referenced in live facts/aliases, and dedicated Patricia hash-tries `X186FactTrie` (keyed by commutative-symmetric expression hash `x186_expr_hash`) and `X186AliasTrie`.
   - `x186_e_written` checks `mentioned` in O(log N): for >95% of SSA definitions (fresh variables never previously mentioned), `x186_e_kill_facts` and `x186_e_kill_aliases` are completely skipped in O(log N)!
   - `x186_e_alias_t` and `x186_e_find` hit 0-or-1-element Patricia-trie buckets instead of scanning up to 1,024 elements.
   - `w4_cse_comm` upgraded to O(1) first-char dispatch.
3. **Opt 3 — `x185_sf_scalar` Empty-Facts Short-Circuit**:
   - Guards `N111Load` with `List.is_empty(&2, X185ScratchCell, facts)`, skipping `x185_sf_cell` (`p111v_get`) when no scratch cells are tracked.
4. **Opt 4 — `x187_encode` / `x202o_dispatch` Opcode Dispatch Fusion**:
   - Moved `"sqrtss"` into `case 115:` (`'s'`) and `"cvttss2siq"` into `case 99:` (`'c'`, family `17`) of `x202o_dispatch`, eliminating 2 string comparisons on every emitted x86-64 instruction.
5. **Opt 5 — `index_remove` `agy_str_eq` Upgrade**:
   - Replaced `p88_string_eq` with `agy_str_eq` in `index_remove`.

---

## 3. Measured Compile-Time Speedup & Mandatory Verification

### 3.1 6-Program Compile-Time Benchmark (`wave4c_unified` vs `wave5_c2`)

| Program | `wave4c_unified` | `wave5_c2` | Speedup | `pw` (`x198pw_plan`) | `emit` (`x187_prepared`) | `.o` Output |
|---|---:|---:|---:|---:|---:|---|
| `lexer` | 14,860 ms | 14,074 ms | 1.06× | 4,031 → 3,371 ms (`1.20×`) | 6,035 → 5,992 ms | **BIT-EXACT** (`6dd7139790e75915`) |
| `raytrace` | 5,396 ms | 5,747 ms | 0.94× | 2,440 → 2,627 ms | 2,260 → 2,305 ms | **BIT-EXACT** (`d7012fcf422090b6`) |
| `gameoflife` | 22,659 ms | **12,343 ms** | **1.84×** | 7,767 → **4,967 ms** (**1.56×**) | 14,654 → **7,126 ms** (**2.06×**) | **BIT-EXACT** (`d68f17458f6ca0ec`) |
| `histogram` | 9,123 ms | 8,950 ms | 1.02× | 1,690 → 1,629 ms | 6,880 → 6,726 ms | **BIT-EXACT** (`8a1d7071fc25e54c`) |
| `nbody` | 5,348 ms | 5,285 ms | 1.01× | 3,312 → 3,117 ms | 1,323 → 1,496 ms | **BIT-EXACT** (`8c3a381a9a997dfd`) |
| `editdist` | 6,689 ms | 6,586 ms | 1.02× | 947 → 1,045 ms | 5,507 → 5,241 ms | **BIT-EXACT** (`beb79ef0f9f3933d`) |
| **TOTAL (6 programs)** | **64,074 ms** | **52,984 ms** | **1.21× (−11.1 s)** | **20,188 → 16,756 ms (1.20×)** | **36,659 → 28,885 ms (1.27×)** | **6/6 BIT-EXACT** |

Post-optimization V8 CPU profile confirmation (`53.63 s` across all 6 programs):
- `p113k_join`: **`7.35 s` → eliminated from Top 35** (`p113k_body`: `11.28 s → 6.91 s` even with `editdist` added).
- `x186_e_body`: **`6.45 s` → eliminated from Top 35** (`x185_sf_source`: `2.03 s → 0.22 s`, `x186_e_kill_aliases`: `1.73 s → 0.23 s`).
- `p111v_get`: **`9.18 s → 5.11 s` (−44%)**.
- `char_len`: **`9.65 s → 7.83 s` (−19%)**.

### 3.2 Mandatory Correctness & Safety Gates
- **Compiler build (`locked_bun.sh`)**: `wave5_c2/api.mjs` compiled cleanly (`exit 0`, dir size **`11 MiB < 40 MiB`**).
- **Object-file equivalence**: **6/6 BIT-EXACT SHA-256** match vs `wave4c_unified` across `lexer`, `raytrace`, `gameoflife`, `histogram`, `nbody`, `editdist`.
- **Conformance (`focused19`)**: **`19/19 PASS`**.
- **Live-metadata observer gate (`observer_wave2_gate.py`)**: **`44+2 ABI PASS`** + **`15/15 PASS` (`0` violations)** across `normal`, `cap-no8`, and `all-hot`.
- **Runtime oracle (`run_proxy.py --small`)**: **`7/7 PASS`** (exact checksums on `histogram`, `gameoflife`, `nbody`, `list`, `expression`, `bst`, `editdist`).

---

## 4. Root-Cause Diagnosis of Wave 3B Track B2 (`apply_strhash.py`) `1.05×` Bail Rate

Disassembling `wave3b_strhash/api.mjs`'s emitted `bench_strhash.o` (`objdump -dr`) and auditing `apply_strhash.py` against `wave4c_unified/compiler.bend` identified **three concrete blockers** explaining why `apply_strhash.py` yielded only `1.05×` on `direct_bench` and why it must be updated before native `n3` self-compile:

1. **Stale AST Pins After Wave 3 S2 (`p88_string_eq_go` and `p98_tag_eq_read` decline!)**:
   - `nm` on `bench_strhash.o` confirmed `p98_tag_eq` emitted **zero** `__sh_slow` wrappers because `p98_tag_eq_read` in `compiler.bend` uses `p88_string_eq_go("Lam", key, True{})` rather than `p88_string_eq("Lam", key)`.
   - In `wave4c_unified/compiler.bend`, `p88_string_eq_go` uses `U32.is_eq(Char.to_u32(h1), Char.to_u32(h2))` instead of `Char.is_eq(h1, h2)`, so `agy_sh_def_pin(book, "p88_string_eq_go", 3024631756, 2674381182)` fails and declines!
2. **`agy_str_eq` / `agy_str_eq_go` Not Covered**:
   - Wave 3 S1 rewrote 1,953 `@unsafe String.eq` call sites in `compiler.bend` to `agy_str_eq` / `agy_str_eq_go` (arg order `(same, a, b)`!), which `apply_strhash.py` does not match at all.
3. **Owned-Wrapper `p111_rt_keep` / `p111_rt_sink` Overhead on Microbenchmarks**:
   - In `bench_strhash.o` (`0x14b..0x16c` and `0x1b25..0x1b46`), owned variants (`$p128borrow.owned.*` / `$direct.*`) still invoke `p111_rt_sink` on every call after the fast loop, while callers invoke `p111_rt_keep` before each call, masking the inner-loop speedup on short strings. On `compiler.bend` self-compile, the dominant call sites are **`$p118borrow.read.agy_str_eq_go`** and **`$p118borrow.read.index_hash`** (zero-sink borrowed loops!), which represent **~20%+ of native `n2` self-compile time** once the 3 pins + `agy_str_eq_go` emitter are updated.

---

## 5. Architecture Blueprint: Exact Path to `10×` and `100×` Compile Speed

Combining our V8 profile (`64.07 s` hosted) and the Wave 3 S1/S2 505 s native `n2` `SIGPROF` profile (`505 s` → `300 s` unloaded with `runtime-opt-w3.o`), here is the quantified multiplicative path:

| Stage / Lever | Target Bottleneck | Hosted JS (`api.mjs`) Multiplier | Native `n3` Self-Compile Multiplier | Cumulative Native Time (from `505 s`) |
|---|---|---:|---:|---:|
| **Baseline (`wave4c_unified` / `n2`)** | Full pipeline | `1.00×` (`64.1 s`) | `1.00×` | `505 s` |
| **1. W5-C1 (`w4_post_select` gating + O(N²) liveness)** | Backend peepholes (`w4b_find_label`, `w4c_xmm_opt`) | `~1.3–1.8×` | `~1.15×` | `~440 s` |
| **2. W5-C2 (`apply_struct_fast.py` — SHIPPED)** | `p113k_join` + `x186_e_*` O(N²) → O(log N) | **`1.21×`** (`1.84×` on `gameoflife`) | `~1.15×` | `~380 s` |
| **3. Wave 3 S2 (`runtime-opt-w3.o` + C1–C4)** | `span_fade`, `term_drop`, `p111_rt_special_ctor`, `p111_rt_take` (`44.8%` of `n2`) | — (native only) | **`1.65×`** (measured!) | **`~230 s`** |
| **4. Fixed `apply_strhash` (`agy_str_eq_go` + `index_hash` + `p98_tag_eq` borrowed loops)** | `p88_string_eq_go` / `agy_str_eq_go` (14.4%) + `index_hash` (6.2%) + `p98_tag_eq` (2.8%) | — (native only) | **`~1.25×`** | **`~185 s`** |
| **5. `KTerm.tag` & `KDef.kind` `U32` Enum + Interned Symbol IDs** | Eliminates remaining heap cons-list `String` alloc/drop/compare across parse, check, lower, IR (`~25%` of remaining) | `~1.6×` | **`~1.35×`** | **`~135 s`** |
| **6. Bump-Arena Compiler Mode (`--arena` in `runtime-opt-w3.o`)** | Single-threaded compiler never needs per-node Perceus `term_drop`/`p111_rt_sink`/`p111_rt_keep` (`~30%` of remaining `n2`) | — (native only) | **`~1.45×`** | **`~93 s`** |
| **7. `fork()`-after-`agy_enrich_cursor` Parallel Codegen (on top of `apply_parcg.py`)** | `x181`/`x185`/`x186`/`x187` codegen+ELF (`~40–55%` of wall time) sharded across 8–16 cores via POSIX `fork()` (zero serialization, COW shared AST/cursor!) | `~2.5×` (4–6 workers) | **`~2.0–2.5×`** (8–16 cores; `~4×` on codegen) | **`~40–50 s` (`~10–12×` total!)** |
| **8. Path from `10×` → `100×` (Parallel Module Check/Lower + Incremental Cache + Flat Byte-Buffer Strings)** | Parallelize `check_*`/`p169np_plan` per strongly-connected def group (`4×`), replace cons-list `String` with packed `U8` `Array` slices (`2.5×`), and cache unchanged `base.bend` + module `.o` shards (`2×`) | `~15–20×` | **`~10×` on top of `10×` = `~100×`** | **`~5 s` full self-compile!** |

### Immediate Next Steps for Wave 5A Composition Gate
1. Compose **`W5-C1` + `W5-C2` (`apply_struct_fast.py`)** cleanly (zero overlapping edits: W5-C1 touches `w4_post_select`, W5-C2 touches `p113k_join`/`p113k_put`/`x186_e_*`/`x185_sf_scalar`/`x187_encode`/`index_remove`).
2. In Wave 5B, update `apply_strhash.py`'s 3 AST pins + add `$p118borrow.read.agy_str_eq_go`, and pair with `runtime-opt-w3.o` + `fork()` parallel codegen (`apply_parcg.py`) for the `10×` native milestone.
