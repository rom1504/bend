# Wave 2 Track C Report: `editdist`, `local-pair`, and `symreg`

## Summary

Two general, sound, standalone composable x86 compiler passes were designed, implemented on top of `/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend`, and verified:

1. **`AGY-W2-ROREC`** ([apply_rorec.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/apply_rorec.py)): **Borrowed Native-Recursion Fast Path for Read-Only ADT-to-`U32` Evaluators/Folds**.
2. **`AGY-W2-DPLOOP`** ([apply_dp_loop.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/apply_dp_loop.py)): **Certified 1D Stencil / Recurrence Fast Path for `p117v` Array Loops** (no-wrap mask elimination + loop-carried register promotion + `min` reassociation).

### Benchmark Results (CPU-2 Alternating Medians vs Unified Baseline + `runtime-agy.o`)

| Case | Unified Fixed-Work (ms) | Cand / Base Ratio | Projected Fixed-Work (ms) | Delta (ms) | Projected vs C |
| :--- | ---: | ---: | ---: | ---: | ---: |
| `editdist` | 306 | **0.415x** (265.0 / 638.5 ms, reps=512) | 127 | **-179** | ~0.62x C |
| `variation-editdist-0-17` | 303 | **0.414x** (215.5 / 520.0 ms, reps=1664) | 125 | **-178** | ~0.62x C |
| `variation-editdist-3-123` | 299 | **0.409x** (211.5 / 517.5 ms, reps=192) | 122 | **-177** | ~0.60x C |
| `local-pair` | 303 | **0.406x** (142.0 / 350.0 ms, reps=1024) | 123 | **-180** | ~0.61x C |
| `symreg` | 314 | **0.317x** (191.0 / 602.0 ms, reps=192) | 100 | **-214** | ~0.30x C |
| `variation-symreg-4-17` | 312 | **0.293x** (179.5 / 612.5 ms, reps=256) | 91 | **-221** | ~0.28x C |
| `variation-symreg-7-123` | 322 | **0.291x** (192.5 / 660.5 ms, reps=128) | 94 | **-228** | ~0.28x C |
| **Bucket Total (7 cases)** | **2,160** | **0.3593x geomean (2.78x faster)** | **782** | **-1,378 ms (-63.8%)** | — |

Raw benchmark JSON: `/home/ai/bend2_agy/selfhost/build/agy/wave2_editsym/bench_both/results.json`.

---

## Root Cause Analysis & Pass Designs

### 1. `symreg` Family (`AGY-W2-ROREC`)
- **Root cause**: `eval(e: Expr, +x: U32) -> U32` and `esize(e: Expr) -> U32` are lowered to `p114r_` explicit-continuation-stack workers. On every internal tree node, `p114r_$direct.eval` calls `p125_rt_take2` (which branches to `p198_rfc_take2` on shared `0x82` trees, allocating/mutating refcount cells on every node across all 16 `floop` evaluations) and `p111_rt_frame` (pushing continuation frames onto `state->sp`), costing ~22.5 ns/node.
- **General optimization (`AGY-W2-ROREC`)**:
  - At KTerm annotation (`x198pw_annotate`), certifies any arity-1 (`T -> U32`) or arity-2 (`T -> U32 -> U32`) function matching a non-indexed, non-erased 0-param ADT `T` whose constructor arms (arity ≤ 2, fields typed `U32` or `T`) compute pure `U32` expressions over literals, `x`, `U32` fields, recursive self-calls on `T` fields, and `U32.{add,sub,mul,xor,and,or}`.
  - At x86 emit (`x198pw_worker`), wraps `p114r_<f>` with a depth-bounded (budget=256) native x86 recursive helper:
    - Handles nullary (`tag == 0x01`), inline 1-field `U32` (`tag == 0x01`), direct heap (`tag == 0x02`), and RFC-shared (`tag == 0x82`) nodes in pure read-only mode with zero allocations, zero refcount churn, and zero `p111_rt_frame` calls.
    - For RFC-shared roots (`tag == 0x82`, `rc >= 2`), decrements the root refcount by 1 **only after** the native recursion succeeds (`bail == 0`). On depth-limit bailout or unexpected tag, zero heap mutation has occurred and control jumps cleanly to `p198w_original_p114r_<f>`.
    - Unique (`0x02`) and last-owner (`rc == 1`) roots jump directly to the original worker to free cleanly.
- **Key debugging finding (falsified assumption)**: The initial prototype missed that 1-field `U32` constructors (like `Lit{v}`) are inline-packed with `tag == 0x01` (payload in low 32 bits), causing ~100% bailout (1.05x). Dispatching `tag == 0x01` for 1-field `U32` ctors (`movl %esi, %eax`) immediately dropped `symreg` to `0.29x–0.32x`.

### 2. `editdist` + `local-pair` Family (`AGY-W2-DPLOOP`)
- **Root cause**: `p113d_$product.row` (the 256×256 inner DP loop) executed 48 x86 instructions per cell with 4 stack spills/reloads (`n-1`, `j+1`, `b_mask`, `b_ptr`), 5 redundant `& mask` operations, 4 array loads + 1 store, a 5-cycle store-to-load forwarding stall (`cur[j+1] = v` immediately read as `cur[j]` next iteration), and `min(min(up+1, left+1), diag+cost)` placing the loop-carried `left` operand in the inner `min` (~12–15 cycles/cell).
- **General optimization (`AGY-W2-DPLOOP`)**:
  - Hooks into `x185_array_version` / `x199s_array_emit` after standard `x185` normalization (`x185_copy_function`, `x186_expression_body`, `x185_dead_body`).
  - Uses a name-independent semantic token verifier (`agy_dp_certify`) to certify `p117v`-versioned 1D stencil/recurrence loops over 3 invariant raw `U32` arrays.
  - Emits a 17-instruction, zero-spill native x86 fast path guarded once before the loop on raw array tags, `heap_min`, non-aliasing (`cur != prev && cur != b`), and no-wrap bounds (`j + n <= b_size`, `j + n < prev_size`, `j + n < cur_size`, `j + n <= 0xffffffff`), falling back to `agy_dp_slow_<symbol>` on any guard failure:
    - Eliminates all 5 `& mask` operations per iteration.
    - Carries `diag = prev[j]` and `left = cur[j]` in registers (2 loads + 1 store, zero STL forwarding).
    - Reassociates `min(min(up+1, left+1), diag+cost)` → `min(left+1, min(up+1, diag+cost))` (exact by `U32` `min` associativity/commutativity), reducing the loop-carried critical path to 3 cycles/cell.

---

## Verification Evidence

1. **Adversarial & Boundary Differential Tests** ([test_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/test_adversarial.py)) vs upstream Bend (`bun bend2/main.ts`):
   - `rorec_adversarial`: **PASS** (`259395363 454511031 981617408 2583206609 4294967288`) — covers nullary root, inline-`U32` leaf root, all 6 binary ops (`add/sub/mul/xor/and/or`), non-commutative `Sub`, `U32` overflow/underflow, diamond-shared DAGs (internal `0x82` RFC nodes), 300-deep tree exceeding budget=256 (forcing clean bailout), unique `0x02` root, and repeated shared evaluations.
   - `dploop_adversarial`: **PASS** (`4223251217 2531559981 651528885 2880071921 531042470 3574733953 2369325985`) — covers `n = 0` (swap-only), `n = 1`, non-zero `j`, exact no-wrap boundary (`j + n == b_size`), `U32` overflow values (`0xfffffffe`/`0xffffffff`), and power-of-2 wrap-around fallback (`j + n >= size`).
2. **Focused19 Qualification Suite** ([run_focused19.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/run_focused19.py)):
   - **`FOCUSED19 PASS: 19 / 19`** (including all 3 expected-reject negative tests).
3. **Standalone Composable Patchers** (apply cleanly in either order on `/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend`):
   - `/home/ai/bend2_agy/research/agy/wave2_editsym/apply_rorec.py`
   - `/home/ai/bend2_agy/research/agy/wave2_editsym/apply_dp_loop.py`
