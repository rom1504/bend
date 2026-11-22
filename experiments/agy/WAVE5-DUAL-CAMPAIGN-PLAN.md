# Wave 5 Dual-Engine Campaign Plan — 10×–100× Compilation Speed + `~1.0×` Optimized C Runtime Speed

- **Start Time**: `2026-11-22 07:00 UTC`
- **Starting Checkpoint**: `775b1824` (`origin/selfhost/agy`, Wave 4C: `1.99×` C16 on untouched upstream defaults, `2.014×` C16 / `1.621×` GCC-10 on 7-family proxy, `64/64 native64`, `15/15 observer`, `3/3` positive holdouts)
- **Dual Objective (Running Simultaneously & Bundled at Phase Gates)**:
  1. **Engine A — Compilation Speed (`10× → 100×` trajectory):**
     - Immediately recover Wave 4C's compile-time regression (`run_proxy` emit `49 s → ≤ 10 s`, `native64` `397 s → ≤ 60 s`) with **0% runtime loss**.
     - Profile and attack the structural bottlenecks across **all compiler stages** (parse/check/lower/opt/x86/ELF) on a **diverse 6-program compile-speed proxy** (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`) + a `~200`-def slice of `compiler.bend`, targeting `10×` on hosted/native compile speed and paving the path toward `100×` (O(N) passes + enum tags + native string/hash + parallel `fork()` codegen).
  2. **Engine B — Compiled-Program Speed (`2.0× → ~1.0×` Clang-16 C):**
     - Recover the two tiny Wave 4C composition interactions (`histogram` `2.05× → 2.72×`, `nbody` `1.23× → 1.50×`) immediately.
     - Push all 7 families toward **`~1.0×–1.5×` Clang-16 C**: `nbody ≤ 1.1×`, `list ≤ 0.90×`, `expression ≤ 1.15×`, `gameoflife ≤ 1.5×`, `histogram ≤ 1.4×`, `editdist ≤ 1.5×`, `bst ≤ 1.8×`.
     - Keep `runtime-agy.o` unchanged (100% Bend-emitted x86-64) and preserve `native45` non-regression + `64/64 native64` + `0` observer violations.

---

## OOM-Safe Concurrency & Bundled Qualification Rules
1. **Mandatory Tool Locks (4 Concurrent Agents, Zero OOMs):**
   - Every `bun bend2/main.ts` compile MUST run via `research/agy/locked_bun.sh` (`flock` + `timeout 60`).
   - Every heavy `node` batch emit / profiler MUST run via `research/agy/locked_node.sh` (`flock` + `4 GiB` heap cap).
   - Never write multi-scrutinee `match a b` on large ADTs (always use 1-scrutinee helper defs).
2. **Fast Small-Proxy Iteration (`< 15 s` per experiment):**
   - **Compile-speed proxy (`research/agy/wave5_compile/bench_compile.py`)**: times per-stage and total compilation of 6 diverse programs (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`) + verifies bit-exact `.o` output vs `wave4c_unified`!
   - **Runtime-speed proxy (`research/agy/wave4_bench/run_proxy.py`)**: times all 7 families on CPU 2 with exact checksum verification!
3. **Bundled Phase Gates:**
   - Every ~35–40 min, compose **Engine A + Engine B** together into `wave5a_unified`, then run ONE shared qualification (`64/64 native64`, `44+2/46` ABI + `15/15 observer`, `bench_compile.py`, `run_proxy.py`, `native45` non-regression), commit & push!
   - 15-minute watchdog cron (`*/15 * * * *`) checks every worker's live state and keeps all tracks unblocked.

---

## Wave 5A Parallel Tracks (`07:00–07:35 UTC`, 35-min Worker Cap)

| Engine | Track | Role | Target |
|---|---|---|---|
| **Engine A (Compile Speed)** | **W5-C1** | `Backend Compile-Time Profiler & O(N²) Killer` | Build `bench_compile.py` (6 diverse programs, per-pass timing), profile `wave4c_unified` (`49 s` emit / `397 s` `native64`), gate `w4c_xmm_opt` (`has_xmm`) + `w4b_licm_magic`/`w4b_rotate_loop` (`has_loop`), kill O(N²) liveness scans, fuse redundant `w4_peep_flat` passes → **target `3–8×` faster compile with 0% runtime loss** |
| **Engine A (Compile Speed)** | **W5-C2** | `Structural 10×–100× Compile-Speed Architect` | Profile full pipeline (frontend/check/lower/x86/ELF) across the 6 diverse programs + 200-def `compiler.bend` slice; eliminate biggest structural compile-time costs (e.g., fix Wave 3B Track B2's native `p88_string_eq`/`index_hash` bail rate, replace hot `String` opcode/tag comparisons with O(1) dispatch or pre-indexed maps, and prototype `fork()`-after-`agy_enrich_cursor` parallel codegen) |
| **Engine B (Runtime Speed)** | **W5-R1** | `Histogram / Editdist / BST Closer` | Recover W4-10's `histogram` `49.3 ms` (`2.05×` C16) lost in Wave 4C composition (`65.4 ms`), then push `histogram → ≤ 1.5×`, `editdist → ≤ 1.8×`, `bst → ≤ 2.0×` C16 via 100% general passes |
| **Engine B (Runtime Speed)** | **W5-R2** | `Nbody / GameOfLife / Expression Closer` | Recover W4-11's `nbody` `92.2 ms` (`1.23×` C16) lost in Wave 4C composition (`112.1 ms`), push `nbody → ≤ 1.1×`, `gameoflife → ≤ 1.5×`, `expression → ≤ 1.2×` C16 via 100% general passes |
| **Engine B (Runtime Speed)** | **W5-R3** | `Kmeans 60×-C & Struct/Tree-Fold Optimizer` | General direct-style arity lift (`32 → 64`), canonical `cmov` select, disjoint-buffer slot forwarding |
| **Engine B (Runtime Speed)** | **W5-R4** | `BFS & Merkle General Graph/Hash Optimizer` | Inline `P111_SPECIAL_SUCC` (`1n+j`), general 2-level Loop-Carried Product Unboxing |
| **Engine A (Compile Speed)** | **W5-C3** | `Frontend & Lowering Compile-Speed Killer` | Zero-closure `p98_tag_eq`/`nd_*`/`p111v_*`/`p205v_*`/`w2d_walk*`, Patricia-tree `p111v_intersection` |

---

## Wave 5A Checkpoint Results (`07:52 UTC`, ALL 7/7 Tracks Composed & Qualified)
- **Unified Artifact**: `selfhost/build/agy/wave5a_unified/{compiler.bend,api.mjs}` (`research/agy/compose_wave5a.py`)
- **Compile Speed (`bench_compile.py`, 6 diverse programs)**:
  - **Total**: **`66.07 s → 20.14 s` (`3.28×` faster)** | Frontend `p86_plan`: **`8.37 s → 2.93 s` (`2.86×`, `lexer` `3.72×`)** | Emit: **`57.64 s → 17.13 s` (`3.37×`, `gameoflife` `5.03×`)** | `6/6` bit-exact `.o` SHA-256 across Engine A tracks.
  - Full `64/64 native64` + `15/15 observer` wall-clock: **`397 s → ~75 s` (`>5×` faster qualification!)**.
- **Runtime Speed (`run_proxy.py`, CPU 2, `7/7` PASS)**:
  - `list` **`0.88×` C16**, `nbody` **`1.25×` C16** (`1.07×` GCC-10), `expression` **`1.47×` C16**, `histogram` **`1.92×` C16**, `gameoflife` **`2.01×` C16** (`0.53×` GCC-10), `editdist` **`2.73×` C16**, `bst` **`3.14×` C16**.
  - **Upstream-medium geomean**: **`1.689×` C16 (`1.049×` GCC-10)** | **7-family overall**: **`2.014× → 1.765×` C16 (`1.421×` GCC-10)**.
- **Holdouts**: `kmeans` (`size=13n`) **`60.3× → 8.0×` C**, `bfs_15` **`7.49× → 2.59×` C**, full `merkle` (`depth=22n`) **`41.4 s → 22.25 s` (`1.86×`)**.
- **Correctness & Safety**: **`64/64 native64` PASS**, **`44+2/46` ABI PASS**, **`15/15 observer` PASS (`0` violations)**.

---

## Wave 5B Parallel Tracks (`07:53–08:40 UTC`, 7 Concurrent OOM-Locked Agents)
- **W5B-C1**: Backend/RegAlloc/ELF Compile-Speed Killer (`emit 17.13 s → ≤ 6 s`, bit-exact `.o`)
- **W5B-C2**: Frontend/IR/Lowering & Closure Killer (`plan 2.93 s → ≤ 1.0 s`, `pw >2×`, bit-exact `.o`)
- **W5B-C3**: Multi-Core Parallel Sharded Codegen (`apply_parcg.py`) + Native `apply_strhash.py` Fix (`4–8×` multiplicative wall-clock speedup)
- **W5B-R1**: Array/Loop Closer (`histogram ≤ 1.3×`, `editdist ≤ 1.6×`, `bst ≤ 1.8×` C16)
- **W5B-R2**: F32/Bitwise Closer (`gameoflife ≤ 1.3×`, `nbody ≤ 1.05×`, `expression ≤ 1.15×` C16)
- **W5B-R3**: Holdout Transfer Closer (`kmeans ≤ 2.0×`, `bfs_15 ≤ 1.5×`, `merkle ≤ 1.5×` C)
- **W5B-V1**: Adversarial Differential Fuzzer (`80+` new Wave 5 tests) + Lean 4 Proofs (`Wave5Laws.lean`, `0 sorry`)

## Strictly Untouched Wave 5 Final Holdout Suite (NEVER inspect before `09:30 UTC`)
- `queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap` (in `/home/ai/bend2/build/publish/bend/bench/runtime/`).
