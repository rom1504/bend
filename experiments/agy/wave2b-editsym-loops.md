# Wave 2B Report: `AGY-W2B-F32LOOP` & `AGY-W2B-DEADARR`

## Summary

Two additional general, sound, standalone composable passes were implemented in `/home/ai/bend2_agy/research/agy/wave2_editsym_b/` on top of Track C (`AGY-W2-ROREC` + `AGY-W2-DPLOOP`):

1. **`AGY-W2B-F32LOOP`** ([apply_f32_loop.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_f32_loop.py)): **General XMM Loop-Carried `F32` Recurrence + Constant Hoisting Pass** (targets `coverage-numeric-recurrence-1024` and `coverage-numeric-recurrence-256`).
2. **`AGY-W2B-DEADARR`** ([apply_dead_arr_scan.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_dead_arr_scan.py)): **General IR Peephole for Fresh-Array Scan4 Allocation Elision & No-Wrap Closed Form** (targets `variation-local-fold-128-0`).

### Benchmark Results (CPU-2 Alternating Medians vs Unified Baseline + `runtime-agy.o`)

| Case | Unified Fixed-Work (ms) | Cand / Base Ratio | Projected Fixed-Work (ms) | Delta (ms) |
| :--- | ---: | ---: | ---: | ---: |
| `variation-local-fold-128-0` | 281 | **0.018x** (2.0 / 112.5 ms, reps=500000) | ~5 | **-276** |
| `coverage-numeric-recurrence-1024` | ~230 | **0.411x** (198.5 / 482.5 ms, reps=32768) | ~95 | **-135** |
| `coverage-numeric-recurrence-256` | ~230 | **0.580x** (263.5 / 454.0 ms, reps=163840) | ~133 | **-97** |
| `local-fold` | 90 | 1.027x (270.0 / 263.0 ms, reps=49152, 6 rounds) | ~92 | +2 (noise) |
| **Wave 2B Net Savings** | — | — | — | **~-506 ms** |

Raw benchmark JSON: `/home/ai/bend2_agy/selfhost/build/agy/wave2_editsym_b/bench_w2b/results.json`.

---

## Root Cause Analysis & Pass Designs

### 1. `AGY-W2B-F32LOOP` (`coverage-numeric-recurrence-1024/256`: 460 ms -> ~228 ms)
- **Root cause**: `p113d_$direct.p37.numeric` executed ~50 instructions/iter on Ivy Bridge (`Xeon E3-1245 V2`) because:
  - The loop-carried `F32` state `x` bounced GPR ↔ XMM (`movd`) 6 times per iteration (2–3 cycles/crossing).
  - All 3 `F32` constants (`3.75`, `1.0`, `1000000.0`) were reloaded via 10-byte `movabs` + `movd` every iteration.
  - Redundant double `cmp $0, %rdi` (`sete`/`je` + `setne`/`je`) ran every iteration.
  - `F32.to_u32` emitted a dead `pxor`/`comiss` plus a `movd` round-trip back to XMM.
- **Design**:
  - Hooks into `x181_direct` for 3-param, 1-result functions `f(state, n, x, h) -> U32`.
  - After standard `x185` normalization, parses pure `F32` expression DAGs (`addss`/`subss`/`mulss`/`divss`), optional `f32_to_u32` observation (with automatic subexpression reuse of `y` in `%xmm1`), and pure `U32` hash/accumulator DAGs (`addl`/`subl`/`imull`/`xorl`/`andl`/`orl`).
  - Emits a zero-spill native x86 SSE loop keeping `x` in `%xmm0`, hoisting up to 8 distinct `F32` constants into `%xmm8..%xmm15` once before the loop, using a single `subq $1, %rsi; jne`, and exact IEEE-754 `F32.to_u32` (`movd %xmm2, %edx; cmpl $0x4f800000, %edx; jae .Loz; cvttss2siq %xmm2, %rdx`).

### 2. `AGY-W2B-DEADARR` (`variation-local-fold-128-0`: 281 ms -> ~5 ms)
- **Root cause**: `variation-local-fold-128-0` executes `bench(128, 0)` 1.895M times (`p93.loop` inlines `bench`), allocating a fresh 128-slot `[seed : U32*128n]` via `p111_rt_op(71)`, calling `x199s`-certified `$product.fold.loop` (`p199_rt_u32_scan4`), and immediately freeing the array via `p111_rt_sink`.
- **Design**:
  - At `x198pw_plan` time, marks every `P134Private` function certified by `x199s` as `p199_rt_u32_scan4` under `"$agy.scan4/" ++ name` in `N111Ids`.
  - At `x185_function_copied` (after `x185_dead_body`), performs a general `P113DStmt` IR peephole rewrite inside **any** `p113d_` function (whether standalone or inlined into a caller loop like `p93.loop`): whenever a fresh constant-filled `Array<U32>` of size `K = 2^cls` (`0 <= cls <= 16`) is passed directly to a marked `scan4` function and immediately sunk with no remaining uses of `arr` or `aout`, guards `n <= K` and computes the exact closed form `(acc0 + n * seed) mod 2^32` (since all `n <= K` visited slots `(i0 + k) & (K - 1)` are pairwise distinct, every read observes initial `seed` and every write to the immediately-sunk array is dead), falling back to the original 5 statements when `n > K`.
- **Key finding**: Matching only standalone 2-arg functions missed `variation-local-fold-128-0` because `p93.loop` inlines `bench`; lifting the rewrite to a general `P113DStmt` IR peephole in `x185_function_copied` (with arbitrary inlined scratch buffer names `b0 == b1 == b2`) immediately unlocked the 56x speedup (`0.018x`).

---

## Verification Evidence

1. **Wave 2B Adversarial Differential Tests** ([test_w2b_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym_b/test_w2b_adversarial.py)) vs upstream Bend (`bun bend2/main.ts`):
   - `f32loop_adversarial`: **PASS** (`123456789 1962463394 1929 1242 1020 798 460`) — covers `n=0`, logistic recurrence, negative `F32`, `>= 2^32` (`1e20`), `NaN` (`0.0/0.0`), `+Inf` (`1.0/0.0`), float near `2^32 - 256`, non-commutative `F32.sub`/`U32.sub`, and nested RHS `U32` ops.
   - `deadarr_adversarial`: **PASS** (`0 4294967295 156790009 4294967168 2193 2890084 4294967162 4294967165 19 47 72 48052`) — covers `n=0,1,127,128` (closed form), `n=129,300` (fallback), wrapping non-zero `i0`/`acc0` (`4294967290`), and tiny `K=4` boundaries (`n=0,4,5,25`).
2. **Tier-2 + Track C Adversarial Differential Tests**: **ALL 6 / 6 PASS** (`rorec_nested_rhs_bin`, `rorec_depth_255_256_257_and_reuse`, `rorec_adt_edge_cases`, `dploop_adversarial_tier2`, `rorec_adversarial`, `dploop_adversarial`).
3. **`focused19` Qualification Suite**: **PASS 19 / 19**.
4. **Standalone Composable Patchers** (apply cleanly on top of unified + Track C):
   - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_f32_loop.py`
   - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_dead_arr_scan.py`
