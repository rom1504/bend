# Wave 4 Phase 3 Track W4-10: Array Bounds-Check Elimination & `editdist`/`bst`/`histogram` Closer

## Summary

Track W4-10 attacks the remaining general backend bottlenecks identified via `SIGPROF` + `objdump -d` on `wave4b_unified/compiler.bend` across `editdist`, `bst`, and `histogram` (zero benchmark-specific pattern matchers; `runtime-agy.o` unchanged; `bfs`/`merkle`/`kmeans` untouched).

- **Composable patcher**: [`research/agy/wave4c_arrclose/apply_arrclose.py`](../../research/agy/wave4c_arrclose/apply_arrclose.py) (`--src` default `selfhost/build/agy/wave4b_unified/compiler.bend` → `--dst` `selfhost/build/agy/wave4c_arrclose/compiler.bend`)
- **Built compiler**: `selfhost/build/agy/wave4c_arrclose/api.mjs` (compiled via `research/agy/locked_bun.sh`)

## SIGPROF & Disassembly Root-Cause Findings (`wave4b_unified`)

1. **`editdist` (`45.000 ms`, `4.88×` C16) — `94.1%` in `p113d_$product.columns`**:
   - `Masks4{a: U32, b: U32, c: U32, d: U32}` was unpacked by product layout (`nq_layout_single`) into 4 flat words, but `nf_expand_kinds` gave all unpacked fields opaque `N_W64{}` kinds and `p113k_function` started with `missing()` instead of seeding `N_W32` param bounds.
   - Result: **4 `p111_rt_keep` fast-paths (~145 insns/iter)** inside `$product.columns` + **4 `p111_rt_sink`** calls on exit, which broke call-free register allocation and caused 25+ stack spills/iter (`619` insns total, `472`-insn loop).
   - Both `Array.set(..., j, ...)` and `Array.get_unchecked(..., next)` reloaded `mask` from `-0x9c8(%rbp)` and masked `j & mask` / `next & mask` every iteration even though `next = (j + 1) & 255`.
2. **`histogram` (`57.476 ms`, `2.39×` C16) — `53.8%` in `$product.count.go`, `30.8%` in `$direct.fill.go`**:
   - `w4b_rotate_loop` (bottom-tested loop rotation) never fired because W4-6's `w4_peep_cmp0_jcc` converted `cmpq $0, %r; jne` → `testq %r, %r; jne` before `w4b_rotate_loop` ran.
   - `w4_peep_mem_inc` (`addl $1, m32`) did not fire in `$product.count.go` because `w4_peep_reg_dead` did not follow `jmp` back-edges and `w4b_is_simple_alu` lacked `cmov*`.
   - Unit-stride induction variable `j` (`j -> j + 1`, countdown `n -> n - 1`) still masked `ks[q]` with `%r15` (`ks_mask`), forcing `ks_base` to spill to `-0xa20(%rbp)` every iteration; `fill.go` reloaded `arr_mask` from `-0x940(%rbp)` every iteration.
3. **`bst` (`37.378 ms`, `3.45×` C16) — `60.7%` in `$product.sorted_fold`, `23.7%` in `blk_new`, `8.2%` in `$direct.collect`, `4.4%` in `$direct.repeat_key`**:
   - `$direct.collect` was top-tested; `$product.sorted_fold` calls `$direct.repeat_key` on `v != 0` (~25% of buckets) and does a single peel + `p111_rt_sink` on exit.

## General Compiler Passes Implemented (`apply_arrclose.py`)

1. **Pass 1 — Product-Field Scalar Kind Propagation (`nq_layout_single`, `nf_expand_kinds`, `p113pl_bind_flat`, `p113k_function`)**:
   - Encodes a 2-bit-per-field `N_WordKind` mask (`1 = N_W32` for `U32`/`F32`/`Char`/`Bool`, `2 = N_Imm64` for `Nat`, `0 = N_W64` otherwise) in the unused `qt` field of `NQShape` (which `nq_same` ignores).
   - Restores exact field kinds in `nf_expand_kinds` and `p113pl_bind_flat`, and seeds `p113k_function` with `p113k_bound(32)` for `N_W32` parameters.
   - Eliminates all 4 `p111_rt_keep` + 4 `p111_rt_sink` calls on `Masks4` fields in `$product.columns` (shrinking `$product.columns` from `619` insns / `472`-insn loop to `325` insns / `129`-insn call-free loop!).
2. **Pass 2 — Bottom-Tested Loop Rotation Fix (`w4b_rotate_body`)**:
   - Extends `w4b_rotate_body` to match `testq %r, %r` / `testl %r, %r` loop headers in addition to `cmpq`/`cmpl $0, %r`, enabling bottom-tested loop rotation across `$product.columns`, `$product.count.go`, `$direct.fill.go`, `$direct.collect`, and `$direct.repeat_key`.
3. **Pass 3 — CFG-Aware Machine Peepholes (`w4c_peep_cfg` in `w4_post_select`)**:
   - Adds `cmov*` to `w4b_is_simple_alu` and uses CFG-aware `w4b_reg_dead` to fuse:
     - `movabsq $c, %r64; addl m32, %r32; movl %r32, m32` → `addl $c, m32` (`$product.count.go` now emits `addl $0x1, (%rdi,%rsi,4)`!)
     - `movl %r32, %eax; andl $M, %eax; movq %rax, %r64` → `andl $M, %r32`
     - Post-rotation `subq $1, %r; testq %r, %r; jne` → `subq $1, %r; jne`.
4. **Pass 4 — Hoisted Bitmask & Unit-Stride IV Array Mask Elimination (`p117v` / `x185_array_version`)**:
   - Flow-sensitive BCE analyzer (`w4c_bce_analyze`) formally justified by `Wave4Laws.lean: w4_bitmask_bounds_sound`:
     - **Bitmask-bounded index** (`x & M` or loop param with back-edge `x & M`): hoists `M <= mask` (and `param <= mask` for loop params) into `p113a_version_guard` once outside the loop. Eliminates both array masks in `$product.columns`.
     - **Unit-stride induction variable** (`j -> j + 1` paired with guarded countdown `left -> left - 1` under `left != 0`): hoists `j <= mask && left <= mask && (j + left) <= mask` into `p113a_version_guard`. Since `mask = (1 << (class & 31)) - 1 <= 2^31 - 1`, `j + left < 2^32` (no 32-bit wraparound) and `idx & mask == idx` on every iteration. Eliminates `ks[q]` mask in `$product.count.go` (freeing `%r15` to hold `ks_base`, shrinking the entire inner loop to **17 instructions**!) and `arr[j]` mask in `$direct.fill.go`.
   - Any input failing the hoisted guard transparently falls back to the verified `p117v_<fid>` worker.

## Benchmark Results (`run_proxy.py --only editdist,bst,histogram --runs 3`, CPU 2)

| Benchmark | Group | Clang-16 Ref (ms) | `wave4b_unified` (ms / ×C16) | `wave4c_arrclose` (ms / ×C16) | Speedup | Status |
| :--- | :--- | ---: | ---: | ---: | ---: | :--- |
| `editdist` | tuned | 9.219 | 45.000 (`4.88×`) | **28.594 (`3.10×`)** | **1.57×** (`-36.5%`) | PASS |
| `bst` | tuned | 10.836 | 37.378 (`3.45×`) | 38.227 (`3.53×`) | ~1.00× (`1.05×` on isolated CPU 3 A/B) | PASS |
| `histogram` | upstream | 24.000 | 57.476 (`2.39×`) | **49.266 (`2.05×`)** | **1.17×** (`-14.3%`) | PASS |
| **3-family geomean** | — | — | `3.429×` C16 | **`2.822×` C16** | **1.22×** (`-17.7%`) | **3/3 PASS** |

## Mandatory Verification Gates

- **`focused19`** (`research/agy/wave2_editsym/run_focused19.py`): **19/19 PASS**
- **`observer_wave2_gate`** (`research/agy/wave3_fuzz/observer_wave2_gate.py`): **15/15 PASS (0 violations)** + **44+2 ABI/observer probes PASS**
- **`test_array_adversarial.py`** (`research/agy/wave4_array/test_array_adversarial.py`): **15/15 PASS (0 failures)** across `normal`, `cap-no8`, `all-hot`
