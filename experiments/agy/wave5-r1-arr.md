# Wave 5 Engine B Track W5-R1: `histogram`, `editdist`, and `bst` C16 Closer

## Summary

Track W5-R1 diagnosed and fixed the `wave4c_unified` composition regression on `histogram` (`65.4 ms / 2.72× C16` → `45.61 ms / 1.90× C16`, **-30.3%**) and pushed all three target array benchmarks forward using 100% general, semantics-preserving backend passes (zero benchmark-specific matchers; `runtime-agy.o` unchanged).

- **Composable patcher**: [`research/agy/wave5_r1/apply_r1.py`](../../research/agy/wave5_r1/apply_r1.py) (`--src` default `selfhost/build/agy/wave4c_unified/compiler.bend` → `--dst` `selfhost/build/agy/wave5_r1/compiler.bend`)
- **Built compiler**: `selfhost/build/agy/wave5_r1/api.mjs` (compiled via `research/agy/locked_bun.sh`, total build dir `11 MiB` < `40 MiB`)

## Root-Cause Diagnosis of the `wave4c_unified` `histogram` Regression (`2.05×` → `2.72×` C16)

Disassembly comparison of `p113d_$product.count.go` between `wave4c_arrclose` and `wave4c_unified` exposed the exact cause:
- In `wave4c_arrclose`, `p113d_$product.count.go` had `nCands <= 64`, so `x190_j_counted` entered the 9-color joint interference-graph register allocator (`x190_j_selected`: 4 callee-saved + 5 caller-saved registers), producing a 17-insn loop with `addl $0x1, (%rdi,%rsi,4)` and zero loop-variable spills.
- In `wave4c_unified`, W4-9's `w4c_diamond_body` introduced ~2 fresh temporary names in `count.go`, pushing `nCands` over `x190_j_counted`'s hard `64`-name pre-ranking cap! That kicked `count.go` out of `x190_j_selected` into the legacy 4-register allocator (`x181_register_frame`), spilling `j`, `row`, `t_mask`, and `ks_base` to stack slots every iteration and inflating the inner loop from 17 to 30 instructions (and blocking `addl $1, m32`).
- The same `64`-name cap also excluded `editdist`'s `$product.columns` (~90–120 locals) from 9-color joint register allocation altogether, even though `x203_candidates` already ranks and retains only the top 32 candidates (`U32` bitmask).

## General Compiler Passes Implemented (`apply_r1.py`)

1. **Pass 1 — Joint Register Allocator Candidate Cap (`64 → 256` in `x190_j_counted`)**:
   - Raises the pre-ranking candidate cap from `64` to `256` (still bounded by `x190_joint_frame`'s 512-stmt limit; `x203_candidates` keeps top 32).
   - Restores 9-color joint coloring for `histogram :: $product.count.go` and unlocks it for `editdist :: $product.columns`.
2. **Pass 2 — General Loop-Counter Decrement Sinking (`w5_sink_body`)**:
   - Right before `x185_function_copied` / `x190_allocate_frame`, sinks pure `p = Sub(n, 1)` from the top of a loop body to immediately before `P113DAgain` whenever `p` is neither read nor written in the middle statements, `n` is not written in the middle statements, and `p` is passed to `P113DAgain`.
   - Eliminates the per-iteration loop-counter stack spill (`-0xab0` / `-0xa08` / `-0x970` / `-0xa10` / `-0x9d0`) across `count.go`, `fill.go`, `collect`, `columns`, and `sorted_fold`, turning `lea -1(%r); mov ..., spill; ...; mov spill, %r; test; jne` into in-place `sub $0x1, %r` right before the loop backedge.
3. **Pass 3 — Bottom-Up Multi-Level Pure Scalar `cmov` Diamonds (`w4c_dia_*` + `N111If` dispatch)**:
   - Dispatches `P113DScalar{N111If{...}}` into `w4c_dia_if`, collapses dead single-use snapshot-assign pairs (`[t = v, dst = t]` → `[dst = v]`), and admits canonical 1-stmt `P113DIf` `cmov` selects inside pure diamond arms.
4. **Pass 4 — Tiny Self-Recursive Loop 2-Step Peeling (`p113j_inline` / `w5_expand_peel`) + General Exit-Block Loop Rotation (`w5_take_exit_gen`)**:
   - For tiny (`<= 64` stmts), scratch-free, `P113DCall`-free self-recursive `P113DAgain` callees, peels 2 extra iterations inline before falling back to the recursive call — eliminating ~99.8% of out-of-line `callq repeat_key` executions in `bst :: $product.sorted_fold` (`v = 0, 1, 2` handled inline).
   - Extends `w4b_take_exit_clean` (`w5_take_exit_gen`) to rotate loop exit blocks containing cold calls/internal branches (e.g. `p111_rt_sink`) whenever the exit block ends in `ret` right before `bodyLbl` and no branch inside it jumps to `loopLbl` or `bodyLbl`, enabling bottom-tested loop rotation for `bst :: $product.sorted_fold`.
5. **Pass 5 — Invariant-Bounded `inv_base + min(any, inv_k)` BCE (`w4c_bce_analyze`) + Flag-Preserving `subq $1, %r; [0..2 movs]; testq %r, %r; jz/jnz` Peephole (`w4c_peep_cfg`)**:
   - Tracks loop-invariant params (`w5_fs_inv_mask`) and `min(x, inv_k)` + `inv_base` sums in `w4c_bce_analyze`, hoisting `base <= mask && k <= mask && (base + k) <= mask` into `p113a_version_guard`.
   - Drops redundant `testq %r, %r` separated from `subq $1, %r` by 0–2 flag-preserving `movq`/`movl` instructions that do not write `%r` (eliminating `testq` in `count.go`, `fill.go`, `collect`, and `sorted_fold`).

## Benchmark Results (`run_proxy.py --only histogram,editdist,bst --runs 3`)

| Benchmark | Group | Clang-16 Ref (ms) | `wave4c_unified` (ms / ×C16) | `wave5_r1` Quiet CPU 2 (ms / ×C16) | `wave5_r1` CPU 3 (ms / ×C16) | Speedup vs `wave4c_unified` | Status |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | :--- |
| `histogram` | upstream | 24.000 | 65.4 (`2.72×`) | **45.610 (`1.90×`)** | 47.398 (`1.97×`) | **1.43×** (`-30.3%`) | PASS |
| `editdist` | tuned | 9.219 | 27.0 (`2.93×`) | **24.375 (`2.64×`)** | 25.500 (`2.77×`) | **1.11×** (`-9.7%`) | PASS |
| `bst` | tuned | 10.836 | 38.2 (`3.53×`) | **32.281 (`2.98×`)** | 33.130 (`3.06×`) | **1.18×** (`-15.5%`) | PASS |
| **3-family geomean** | — | — | `3.04×` C16 | **`2.465×` C16** | `2.556×` C16 | **1.23×** (`-18.9%`) | **3/3 PASS** |

*Compile time*: `emit = 17.19s–18.58s` on quiet host (matching `wave4c_unified`'s ~18s, zero compile-time regression).

## Remaining Gaps & Exact Next Steps for Follow-Up

Disassembly of `wave5_r1` shows the exact remaining opportunities to reach `≤ 1.4× / 1.6× / 1.9×` C16:
1. **`histogram` (`1.90×` → `≤ 1.4×`)**: `w5_step_min_if` did not yet fire on `count.go`'s `t[row + min(x, k1)]` because `U32.min` is lowered through `U32.is_lt` → `Bool.pick` with an intermediate `eq(c, 0)` / tag-match before `P113DIf`. Matching that negated/copied bool pattern will eliminate `and %r14, %rdx` and free `%r14` for `q` (eliminating the remaining `-0xab8(%rbp)` spill in `count.go`, dropping it from 16 to 11 insns).
2. **`editdist` (`2.64×` → `≤ 1.6×`)**: `symbol(s & 3, m)` still emits 3 conditional branches (`2e90`–`2ecb`) because `x190_local_values_body` / `p113i` emits `N111Bin` `sub` + `N111If` with an extra live temp before `w4c_diamond_body`, and `columns` still has ~12 stack spills plus two `movabs $0xffffffff; xor` (`notl`). Converting `symbol` to branchless `cmov` + lowering 32-bit `xor 0xffffffff` to `notl` directly attacks the remaining gap.
3. **`bst` (`2.98×` → `≤ 1.9×`)**: `sorted_fold` now handles `v = 0, 1, 2` inline without calling `repeat_key`, but the cold `v >= 3` `callq repeat_key` still forces `sorted_fold` into callee-saved-only allocation (spilling `a_base` to `-0x958(%rbp)` and `h` temps to `-0x9a8`/`-0x9c0`), and `blk_new` (`[0 : U32*512n]`) is 23.7% of total runtime. Outlining/cold-splitting the `v >= 3` call (or emitting a small local nested loop for `repeat_key`) will make `sorted_fold` call-free and eliminate all spills.

## Mandatory Verification Gates

- **`focused19`** (`research/agy/wave2_editsym/run_focused19.py`): **19 / 19 PASS**
- **`observer_wave2_gate`** (`research/agy/wave3_fuzz/observer_wave2_gate.py`): **15 / 15 PASS (0 violations)** + **44 + 2 ABI/observer probes PASS**
- **`test_array_adversarial.py`** (`research/agy/wave4_array/test_array_adversarial.py`): **15 / 15 PASS (0 failures)** across `normal`, `cap-no8`, `all-hot`
