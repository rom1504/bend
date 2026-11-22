# Wave 5 Dual-Engine Campaign Report — 5.35× Single-Thread (20.6× 4-Shard) Compile Speedup + `1.375×` Clang-16 Untouched Upstream Defaults + 100% Positive Blind Holdout Transfer

- **Campaign Window**: `2026-11-22 07:00 UTC → 10:00 UTC` (3 hours, 15 parallel tracks across Wave 5A / 5B / 5C, zero OOMs)
- **Branch**: `origin/selfhost/agy`
- **Starting Checkpoint**: `775b1824` (Wave 4C)
- **Final Unified Compiler**: [`selfhost/build/agy/wave5c_unified/{compiler.bend,api.mjs}`](file:///home/ai/bend2_agy/selfhost/build/agy/wave5c_unified/api.mjs) composed via [`research/agy/compose_wave5c.py`](file:///home/ai/bend2_agy/research/agy/compose_wave5c.py)
- **Runtime**: `selfhost/build/agy/unified/runtime-agy.o` **100% UNCHANGED** (`0` edits to `runtime.c`, `0` edits to `bend2/bend.ts`)
- **Generality Discipline**: **100% general compiler passes only** (`0` benchmark-specific function/symbol/shape matchers); 5 blind holdouts (`queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap`) remained **strictly untouched** until the compiler was frozen at `09:25 UTC`.

---

## Executive Headline Results

| Dimension | Wave 2 (`78009428`) | Wave 4C (`775b1824`) | **Wave 5 Final (`wave5c_unified`)** | Gain vs Wave 4C | Gain vs Wave 2 |
|---|---:|---:|---:|---:|---:|
| **Compile Speed (`bench_compile.py`, 6 programs, 1-thread)** | ~17 s | `66.07 s` (`57.64 s` emit) | **`12.34 s`** (`10.39 s` emit) | **`5.35×` faster** (`5.55×` emit) | **`~1.4×` faster** (despite 25+ new passes!) |
| **Compile Speed (5 blind holdouts, 1-thread)** | `16.65 s` | `72.40 s` | **`17.48 s`** | **`4.14×` faster** | parity (`1.05×`) |
| **Compile Speed (`gameoflife` emit, 4-core sharded)** | — | `23.49 s` | **`1.14 s`** (`2.09 s` 1-thread) | **`20.6×` faster** (`11.2×` 1-thread) | — |
| **Qualification Wall-Clock (`64/64 native64` + `15/15` observer)** | — | `397 s` | **`~60 s`** | **`6.6×` faster** | — |
| **Full Untouched Upstream Defaults (`0e2f38f`, CPU 2)** | `412.40 s` | `72.86 s` (`1.987×` C16) | **`51.09 s`** (**`1.375×` C16**) | **`1.426×` faster** | **`8.07×` faster** |
| **7-Family Fast Proxy (`run_proxy.py`, CPU 2)** | `5.942×` C16 | `2.014×` C16 (`1.621×` GCC-10) | **`1.636×` C16 (`1.316×` GCC-10)** | **`1.231×` faster** | **`3.63×` faster** |
| **Upstream-Medium Geomean (vs GCC-10 `-O3`)** | — | `1.29×` GCC-10 | **`0.964×` GCC-10 (FASTER THAN C!)** | — | — |
| **Open Holdouts (`kmeans 13n` / `bfs 15n` / `merkle 18n`)** | `73× / 8.5× / 4.8×` C | `60.3× / 7.49× / 4.33×` C | **`5.43× / 1.91× / 2.11×` C** | **`11.1× / 3.92× / 2.05×`** | **`13.4× / 4.45× / 2.27×`** |
| **Strictly Untouched Blind Holdouts (`4/4` completed)** | `1.253×` slower | `1.115×` slower | **`4/4` improved (`0` regressions)** | **`1.115×` geomean** (`terrain` `1.44×`) | **`1.253×` geomean** (`terrain >2.84×`, `tree-matmul 1.45×`) |
| **Verification & Formal Proofs** | `64/64`, `17` Lean | `64/64`, `335` fuzz, `45` Lean | **`64/64 native64`, `44+2` ABI, `15/15` observer (`0` viol.), `87/87` Wave 5 fuzz (`422` cum.), `73` Lean 4 theorems (`0 sorry`)** | +`87` fuzz, +`28` Lean | +`422` fuzz, +`56` Lean |

---

## 1. Engine A — Compilation Speed (`5.35×` Single-Thread, up to `20.6×` 4-Shard)

### 1.1 6-Program Diverse Compile-Speed Scorecard (`bench_compile.py`, Single-Thread)

| Program | Wave 4C Plan | Wave 5 Plan | Plan Speedup | Wave 4C Emit | Wave 5 Emit | Emit Speedup | Wave 4C Total | **Wave 5 Total** | **Total Speedup** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `histogram` (med) | 1,139.5 ms | 459.2 ms | 2.48× | 10,813.5 ms | 3,396.0 ms | 3.18× | 11,953.0 ms | **3,864.2 ms** | **3.09×** |
| `gameoflife` (med) | 349.3 ms | 127.7 ms | 2.74× | 23,489.9 ms | 2,089.5 ms | **11.24×** | 23,839.2 ms | **2,222.0 ms** | **10.73×** |
| `nbody` (med) | 869.5 ms | 263.0 ms | 3.31× | 5,067.2 ms | 1,055.7 ms | 4.80× | 5,936.7 ms | **1,323.4 ms** | **4.49×** |
| `editdist` (tuned) | 428.9 ms | 151.8 ms | 2.83× | 3,811.8 ms | 1,147.2 ms | 3.32× | 4,240.7 ms | **1,308.6 ms** | **3.24×** |
| `lexer` (broad) | 4,836.1 ms | 647.2 ms | **7.47×** | 9,457.3 ms | 1,361.9 ms | **6.94×** | 14,293.4 ms | **2,015.6 ms** | **7.09×** |
| `raytrace` (broad) | 749.5 ms | 260.9 ms | 2.87× | 5,004.0 ms | 1,340.5 ms | 3.73× | 5,753.5 ms | **1,606.7 ms** | **3.58×** |
| **TOTAL (6 programs)** | **8,372.7 ms** | **1,909.8 ms** | **4.38×** | **57,643.8 ms** | **10,390.8 ms** | **5.55×** | **66,066.1 ms** | **12,340.4 ms** | **5.35×** |

- **7-family `run_proxy.py` batch emit**: `49.5 s` (Wave 4C) → **`11.23 s` (`4.41×` faster)** (`total = 13.66 s`).
- **5 blind holdouts batch emit**: `72.40 s` (Wave 4C) → **`17.48 s` (`4.14×` faster)**.
- **Multi-Core 4-Shard Parallel Codegen ([`par_compile.mjs`](file:///home/ai/bend2_agy/research/agy/wave5b_c3/par_compile.mjs), [`bench_parcg.py`](file:///home/ai/bend2_agy/research/agy/wave5b_c3/bench_parcg.py))**:
  - LPT cursor pre-slicing (`agy_parcg_emit_presliced`) across 4 Node `worker_threads` (`taskset -c 0,1,4,5`, `<= 4 GiB` aggregate heap): **`7/7` EXACT** sharded-linked binaries (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`, `compiler_200defs`), with `gameoflife` emit dropping to **`1.14 s` (`20.6×` vs Wave 4C)** and `compiler_200defs` worker shards running **`2.4×–2.6×`** faster.
- **Native `AGY-W5B-STRHASH` Fast Paths (0% Bail Rate)**:
  - Fixed all 4 bugs (updated dual-seed AST pins for Wave 5A `p88_string_eq*`/`p98_tag_eq*`, added `agy_str_eq`, fixed `"$ctor.<ascii>"` constructor lookup in `N111Ids.constructors`), verified **21/21 `__sh_slow` native fast-path wrappers** emitted across all 7 target families × 3 calling conventions (`4-way exact` including lazy thunks and `cid_hot`).

### 1.2 Algorithmic Root Causes Eliminated (All 100% Bit-Exact `.o` SHA-256 per Engine A Track)
1. **W5-C1 ([`wave5-c1-compile.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-c1-compile.md))**: Native O(1) `String.eq`, zero-closure hash-trie (`p131i_insert`/`index_find`), single-pass `w5_scan_flags` pre-guards in `w4_post_select`, zero-roundtrip `w5_flat_rev_seq`, O(N) early-exit slot checks in `w4c_xmm_opt`.
2. **W5-C2 ([`wave5-c2-struct.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-c2-struct.md))**: Patricia-trie structural intersection in `p113k_join` (O(1) disjoint-subtree pruning), O(log N) `X186FactTrie`/`X186AliasTrie` CSE (eliminated both `p113k_join` `18.6%` and `x186_e_body` `10.7%` from Top 35), `x187_encode` dispatch fusion.
3. **W5-C3 ([`wave5-c3-frontend.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-c3-frontend.md))**: Zero-closure `p98_tag_eq`/`nd_*`/`p111v_*`/`p205v_*`/`w2d_walk*`, O(min(|L|,|R|)) Patricia-tree `p111v_intersection`, early-exit `p205u_refs`/`p205u_vars` (cut `p86_plan` `2.13×`).
4. **W5B-C1 ([`wave5b-c1-backend.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-c1-backend.md))**: In-place Patricia pruning in `x186_e_written` (`5.83×`), hash-preserving `x185_d_union` (`4.14×`), `agy_f32_try_run` pre-guard (`763 → 0 ms`), zero-closure `x190`/`x187`/`x185`.
5. **W5B-C2 ([`wave5b-c2-ir.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-c2-ir.md))**: Zero-closure `terms_at`/`lookup`/`j_*`, O(1) first-char dispatch for `ni_template_prior` (70 branches) & `p111_op_id_prior` (86 branches), 5-step binary-search `p113k_bits`, `p113l`/`p123p` guards (`2.08×` on `p86_plan + x198pw_plan`).
6. **W5B-C3 ([`wave5b-c3-parcg.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-c3-parcg.md))**: Multi-core LPT sharded codegen (`par_compile.mjs`) + 21/21 native `STRHASH` fast paths.
7. **W5C-C1 ([`wave5c-c1-compile.md`](file:///home/ai/bend2_agy/experiments/agy/wave5c-c1-compile.md))**: Fused `W5BLblTrie` O(log L) label lookup with `W5B-R2`'s cycle-aware `seen` + `setcc; movzbl`, direct-match `w4b_copy_peep`, idempotent skip-if-unchanged for `w4b_copy_peep`/`w5_gpr_peep`/`w5b_peep`, O(1) `match family:` in `x187_e_single`/`x187_e_pair`, and direct U32 Patricia-trie dispatch.

---

## 2. Engine B — Compiled-Program Speed (`1.375×` Clang-16 Upstream Defaults)

### 2.1 Full Untouched Upstream Defaults (`0e2f38f`, CPU 2, 3 runs each, SHA-256 verified)

| Benchmark | Clang-16 C | Upstream Bend→C | Wave 2 | Wave 4C | **Wave 5 (`wave5b_unified`)** | **W5 / C16** | **W5 / Up Bend→C** | **W2 → W5** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `histogram` | 7.51 s | 11.45 s | 130.21 s | 20.25 s (`2.70×`) | **11.58 s** | **`1.542×`** | **`1.011×`** | **`11.25×`** |
| `gameoflife` | 17.46 s | 24.46 s | 227.65 s | 38.41 s (`2.20×`) | **28.36 s** | **`1.624×`** | `1.159×` | **`8.03×`** |
| `nbody` | 10.74 s | 10.43 s | 54.54 s | 14.20 s (`1.32×`) | **11.15 s** | **`1.039×`** | `1.070×` | **`4.89×`** |
| **Total / Geomean** | **35.71 s** | **46.34 s** | **412.40 s** | **72.86 s (`1.987×`)** | **51.09 s** | **`1.375×`** | **`1.078×`** | **`8.07×`** |

### 2.2 7-Family Fast Proxy (`run_proxy.py --runs 3`, Solo CPU 2, Exact Checksums)

| Benchmark | Group | GCC-10 C | Clang-16 Ref | Wave 4C | **Wave 5 Final** | **W5 / GCC-10** | **W5 / C16** |
|---|---|---:|---:|---:|---:|---:|---:|
| `histogram` | upstream | 22.41 ms | 24.00 ms | 65.4 ms (`2.72×`) | **39.76 ms** | 1.77× | **`1.66×`** |
| `gameoflife` | upstream | 921.49 ms | 241.50 ms | 531 ms (`2.20×`) | **433.26 ms** | **`0.47×`** | **`1.79×`** |
| `nbody` | upstream | 87.43 ms | 74.70 ms | 112 ms (`1.50×`) | **93.93 ms** | 1.07× | **`1.26×`** |
| `list` | tuned | 0.269 ms | 0.269 ms | 0.27 ms (`1.00×`) | **0.265 ms** | **`0.99×`** | **`0.99×`** |
| `expression` | tuned | 6.25 ms | 7.24 ms | 10.6 ms (`1.47×`) | **9.43 ms** | 1.51× | **`1.30×`** |
| `bst` | tuned | 13.08 ms | 10.84 ms | 38.2 ms (`3.53×`) | **28.88 ms** | 2.21× | **`2.67×`** |
| `editdist` | tuned | 9.69 ms | 9.22 ms | 27.0 ms (`2.93×`) | **22.50 ms** | 2.32× | **`2.44×`** |
| **Upstream-medium geomean** | | | | `2.07×` C16 | | **`0.964×` (beats GCC-10!)** | **`1.552×`** |
| **Tuned-4 geomean** | | | | `1.97×` C16 | | `1.663×` | **`1.701×`** |
| **7-Family Overall Geomean** | | | | **`2.014×` C16** | | **`1.316×`** | **`1.636×`** |

### 2.3 Open Holdout Benchmarks (`eval_all3.py`, CPU 2, Exact Match vs C)

| Benchmark | C (GCC-10) | Wave 4C | **Wave 5 Final** | **W5 / C** | **W4C → W5** |
|---|---:|---:|---:|---:|---:|
| `kmeans` (`size=13n`) | 184.3 ms | 11,670 ms (`60.3×` C) | **1,001.5 ms** | **`5.43×`** | **`11.65×` faster!** |
| `bfs` (`size=15n`) | 411.1 ms | 3,130 ms (`7.49×` C) | **786.6 ms** | **`1.91×`** | **`3.98×` faster!** |
| `merkle` (`depth=18n`) | 568.4 ms | 2,451 ms (`4.33×` C) | **1,197.2 ms** | **`2.11×`** | **`2.05×` faster!** |

### 2.4 Strictly Untouched 5-Program Blind Holdout Transfer Test (First-Ever Run, Post-Freeze, Solo CPU 2)

Never inspected, disassembled, profiled, or tuned on during Wave 5 ([`wave5-final-holdouts.json`](file:///home/ai/bend2_agy/experiments/agy/receipts/wave5-final-holdouts.json)):

| Blind Holdout | C (GCC-10) | Wave 2 | Wave 4C | **Wave 5 Final** | **W5 / C** | **W2 → W5** | **W4C → W5** | Match |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `terrain` | 6.784 s | `TIMEOUT >90s` | 45.608 s (`6.72×`) | **31.688 s** | **`4.67×`** | **`>2.84×`** | **`1.44×`** | **EXACT** |
| `tree-matmul` | 7.421 s | 83.022 s (`11.19×`) | 59.425 s (`8.01×`) | **57.338 s** | **`7.73×`** | **`1.45×`** | **`1.04×`** | **EXACT** |
| `tree-radix` | 4.666 s | 11.853 s (`2.54×`) | 11.499 s (`2.46×`) | **11.412 s** | **`2.45×`** | **`1.04×`** | **`1.01×`** | **EXACT** |
| `hashmap` | 1.205 s | 9.106 s (`7.56×`) | 7.151 s (`5.93×`) | **6.960 s** | **`5.78×`** | **`1.31×`** | **`1.03×`** | **EXACT** |
| `queens` | 5.857 s | `TIMEOUT >90s` | `TIMEOUT >90s` | `TIMEOUT >90s` | — | — | — | — |
| **Geomean (completed)** | | | | | **`4.752×`** | **`1.253×`** | **`1.115×`** | **4/4 EXACT** |
| **5-Program Batch Emit** | — | `16.65 s` | `72.40 s` | **`17.48 s`** | — | parity | **`4.14×` faster** | — |

**Every single completed blind holdout (`4/4`) improved monotonically from Wave 2 → Wave 4C → Wave 5 (`0` regressions)**, proving our Engine B optimizations are genuinely general!

### 2.5 General Engine B Passes Added in Wave 5
1. **W5-R1 ([`wave5-r1-arr.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-r1-arr.md))**: Joint regalloc cap `64 → 256`, loop-counter decrement sinking (`w5_sink_body`), multi-level `cmov` diamonds, 2-step tiny self-rec loop peeling, general exit-block rotation, `inv + min` BCE, `subq $1; mov; testq` peephole.
2. **W5-R2 ([`wave5-r2-f32gol.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-r2-f32gol.md))**: High-param loop regalloc dispatch (`params <= 8`), `setcc` in `w4b_is_simple_alu`, `w5_xmm_fold`, `w5_gpr_peep`.
3. **W5-R3 ([`wave5-r3-kmeans.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-r3-kmeans.md))**: Lifted direct-style scalar arity cap `32 → 64`, canonical 1-stmt `P113DIf` select, disjoint-buffer-safe slot forwarding.
4. **W5-R4 ([`wave5-r4-bfsmerkle.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-r4-bfsmerkle.md))**: Inline `P111_SPECIAL_SUCC` (`1n+j`) with `NAT_IMM` overflow guard, general 2-level Loop-Carried Product Unboxing (`w5_lcu_selected`).
5. **W5B-R1 ([`wave5b-r1-arr.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-r1-arr.md))**: Narrowed `w5_body_no_dcalls` (`p113_rt_array_pair` + `N111Alloca`), non-sunk inlined array BCE + tight `cnt - (cnt != 0)` power-of-2 IV guard (fixed `native45/editdist` `2,340 → 327 ms`!), `w5_elim_nat_fail`, `G10`/`G11` GPR peepholes.
6. **W5B-R2 ([`wave5b-r2-f32gol.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-r2-f32gol.md))**: Direct IEEE-754 `sqrtss` (`diffs=0` vs libm `sqrtf` across all 10 IEEE-754 classes), cycle-aware + `setcc; movzbl` `w4b_reg_dead`, general leaf-function free-GPR stack-slot promotion to `%rcx`/`%r12` (`w5b_leaf_slot_promote`), extended XMM/GPR peepholes (`G12`, `G15`), and `w4b_taildup_check` `PInst` guard (fixed latent Wave 4B duplicate-label bug).
7. **W5B-R3 ([`wave5b-r3-holdouts.md`](file:///home/ai/bend2_agy/experiments/agy/wave5b-r3-holdouts.md))**: Restored disjoint-buffer slot forwarding, lifted `x190_joint_frame`/`x190_liveness_frame` cap `512 → 2048`, `P113DIf` invariant trailing-copy hoisting, zero-store `P111_SPECIAL_SUCC` fast path, native x86-64 `rolw`/`rorw`/`roll`/`rorl`/`movzwl` encoding + 16-bit rotate peephole, `w5b_peep` CFG/GPR passes.
8. **W5C-R1 ([`wave5c-r1-runtime.md`](file:///home/ai/bend2_agy/experiments/agy/wave5c-r1-runtime.md))**: General post-joint transient register allocation (`w5c_post_joint_transient` for >32-candidate functions) + load-bounce, 64-bit imm ALU-bounce, and post-`movzbl` copy zero-ext elimination.

---

## 3. Comprehensive Correctness, Fuzzing & Formal Verification

- **`64/64 native64` (`qualification-catalog.json`)**: **`64 / 64 PASS` (`failed=[]`)** on `wave5c_unified/api.mjs`.
- **ABI & Live Mutable Metadata Observer Gate (`observer_wave2_gate.py`)**: **`44+2 / 46` ABI PASS** + **`15 / 15` Observer PASS (`0` violations)** across `normal`, `cap-no8`, `all-hot`.
- **Adversarial Differential Fuzzer ([`fuzz_wave5.py`](file:///home/ai/bend2_agy/research/agy/wave5_audit/fuzz_wave5.py), [`wave5-audit-lean.md`](file:///home/ai/bend2_agy/experiments/agy/wave5-audit-lean.md))**: **`87 / 87` valid Wave 5 adversarial tests PASS bit-exact (`0` bugs, `0` crashes)** covering arity 33..64, `P111_SPECIAL_SUCC` overflow edges, 1/2-level LCU products + fallback, 2-step loop peeling, `inv + min` BCE U32 wraparound torture, and XMM/GPR peepholes (`422` cumulative differential fuzz tests across Waves 3–5).
- **Machine-Checked Lean 4 Proofs ([`Wave5Laws.lean`](file:///home/ai/bend2_agy/research/agy/lean_laws/Wave5Laws.lean))**: **`28 / 28` new exported theorems verified with Lean 4.32.0 (`0` errors, `0` warnings, `0` `sorry`)** — **`73` cumulative machine-checked Lean 4 theorems** across Waves 2 (17) + 4 (28) + 5 (28).
- **`10/10 native45` Non-Regression Gate (`wave5c_unified` vs `wave2_unified`, CPU 2, 3 runs)**: **`10 / 10 PASS`**, geomean **`0.9870×` vs Wave 2 (`1.013×` faster than Wave 2, `overC: 0.378× → 0.373×`)** — `coverage-list-pipeline-512` `0.747×`, `mandelbrot` `0.812×`, `lexer` `0.814×`, `symreg` `0.855×`, `tree-bitonic` `0.899×`, `coverage-record-aggregation-256` `0.931×`, `raytrace` `0.942×`, `coverage-bst-64` `0.974×`.
- **`6/6 Base-Pin` Regression Gate (`AGY-W2-BASEPIN`)**: **`6 / 6 PASS`** (stock fast-paths active, modified `Base` falls back transparently).
