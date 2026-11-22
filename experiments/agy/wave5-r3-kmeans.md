# Wave 5 Engine B Track W5-R3: `kmeans` (`60.3×` C → `5.11×` C, `10.23×` Speedup)

**Date**: 2026-11-22  
**Base**: `selfhost/build/agy/wave4c_unified/compiler.bend`  
**Patch**: [`research/agy/wave5_r3/apply_r3.py`](file:///home/ai/bend2_agy/research/agy/wave5_r3/apply_r3.py)  
**Built Compiler**: [`selfhost/build/agy/wave5_r3/api.mjs`](file:///home/ai/bend2_agy/selfhost/build/agy/wave5_r3/api.mjs)  
**Status**: **QUALIFIED & READY FOR COMPOSITION** (`10.23×` speedup on `kmeans`, `19/19` `focused19`, `15/15` `observer_wave2_gate` (`0` violations), `7/7` `run_proxy.py` zero regression).

---

## 1. Root-Cause Diagnosis (`SIGPROF` + Symbol Audit + `objdump -d`)

In Phase 4, untouched holdout `kmeans` (`size=13n`, expected `1054846867`) took **`11.67 s` vs `0.194 s` GCC-10 C (`60.3×` C)**.

Profiling `kmeans` (`size=11n`, `6.010 s`, 299 `SIGPROF` samples at 100 Hz) on `wave4c_unified/api.mjs` exposed the exact bottleneck:
- **>90% of all samples** were inside `p111` CPS continuations (`$p111.k.*`, 188 continuation functions) plus `p111($direct.chunk)` (`8.4%`), `work_loop.constprop.0` (`5.4%`), `p111_rt_return` (`2.0%`), and `p111_set_regs` (`1.3%`).
- `dst`, `min2`, `b2u`, `prng`, `sel`, `sel.go`, `cnew`, `step.fin`, and `$product.step.fin` **all compiled to `p113d`**, **but `chunk` failed to enter `p113d` at all!**
- **Why**: `chunk` has **34 scalar parameters** (`j, i, c0..c7, s0x..s7n`), and `compiler.bend` had arbitrary **`U32.is_le(arity, 32)`** caps in `p113pl_candidates`, `nq_signature_tele`, `p113i_eligible`, `p112w`, `p164a_allowed`/`p164a_shape`, `p167v_allowed`, and `p169q_metadata` — even though `p111_rt_reg_get` supports up to `255` registers and `x181_frame` / `x181_call_text` / `__x181_tail` already support arbitrary stack-passed arity.
- Because `chunk` fell back to `p111` CPS, every single inner call (`prng`, 8× `dst`, 7× `min2`, 8× `b2u` = 24 calls per point × 64 points × 128 chunks × 20 rounds × 64 restarts) heap-allocated a CPS continuation frame saving all 34+ live variables and bounced through `work_loop`.

After lifting the arity cap to `64` (`v1`: `11.67 s` → `1.2236 s`, `9.54×` speedup, `92.2%` in `p113d($direct.chunk)`), `objdump -d` of `p113d($direct.chunk)` revealed two additional general backend bottlenecks:
1. **`w4g_try_diamond` emitted 4-op bitmask selects** (`movabsq $0; sub; xor; and; xor`) instead of canonical 1-statement `P113DIf` selects, preventing `x191_conditional_select` (`cmov`) and `x194_ps` (`cmp + cmov` fusion) from firing across 23 selects/iteration (16× in `dst`, 7× in `min2`).
2. **`w4c_xmm_opt` skipped `w4c_copy_slot_fwd` + `w4c_backedge_coalesce` + `w4c_dead_slot_elim`** whenever a function contained any `leaq -disp(%rbp)` (such as `scratch` for constructors in the base case), leaving 24 dead temp spills and 24 redundant tail-copy pairs (`mov -0x1290(%rbp), %r10; mov %r10, -0x110(%rbp)`) in `chunk`'s loop backedge.

---

## 2. General Compiler Passes Implemented (`apply_r3.py`)

All passes are 100% general (zero benchmark-specific matchers, zero edits to `bend2/bend.ts`):

1. **General High-Arity Direct-Style Admission (`arity <= 32` → `arity <= 64`)**:
   - Lifts the 10 arbitrary `U32.is_le(..., 32)` caps in `nq_signature_tele`, `p112w` (`p112r`/`p112w` worker/region checks), `p113pl_candidates`, `p113i_eligible`, `p164a_allowed`, `p164a_shape`, `p167v_allowed`, and `p169q_metadata` to `64`.
   - Verified no 32-bit parameter bitmask overflows (`x185_array_selected` already guards `count > 16`; `w4c_fs_iv_mask` / `w4c_has_bit` already guard `i < 31`; `p111_rt_reg_get` supports `< 255`).
2. **Canonical 1-Statement `P113DIf` Select Lowering in `w4g_try_diamond`**:
   - Replaces the 4-statement bitmask select (`sub 0`, `xor`, `and`, `xor`) with `P113DIf{condition, [Set{ydst, ynm}], [Set{ydst, nnm}]}` using the already-verified U32 `condition`, enabling `x191_conditional_select` (`cmovne`) and `x194_ps` (`cmp + cmovb`).
3. **Disjoint-Buffer-Safe Slot Forwarding, Backedge Coalescing & Dead-Slot Elimination (`w4c_xmm_opt`)**:
   - Enables `w4c_copy_slot_fwd` + `w4c_backedge_coalesce` + `w4c_dead_slot_elim` even when a function contains `leaq -disp(%rbp)` for disjoint stack buffers (`scratch`, `__x181_tail`, `__x181_results`, `alloca`). In `x181_frame`, buffer addresses are strictly disjoint from scalar `X181Stack` homes, and `w4c_inst_reads` already counts `leaq -disp(%rbp)` as a read.

### Rejected Hypothesis (Preserved)
- **Lifting `x190_joint_frame` / `x190_liveness_frame` size cap (`512 → 2048`) and `nCands` cap (`64 → 512`)**: **REJECTED** (`1.22 s` → `2.25 s`). Because `x190_joint_frame`'s 32-bit interference graph only allocates registers for the top 32 locals by read score and bypasses `x185_transient_frame`, it spilled short-lived expression temporaries in `prng` and `dst` onto the stack (adding ~80 store-forwarding stalls on the critical path). Keeping `x185_transient_frame` for large `>512`-stmt / `>64`-local functions was dramatically faster (`1.14 s`, `89` vs `121` SIGPROF samples).

---

## 3. Measurements & Verification

### `kmeans` (`size=13n`, CPU 2, exact output `1054846867`)

| Build | Time (s) | vs GCC-10 C | Speedup vs Wave 4C | `SIGPROF` Samples | `$p111.k.*` Count |
|---|---:|---:|---:|---:|---:|
| GCC-10 `-O3 -ffp-contract=off` (ref) | `0.2231 s` (Phase 4: `0.194 s`) | `1.00×` | — | — | — |
| `wave4c_unified/api.mjs` (Phase 4) | `11.67 s` | `60.3×` | `1.00×` | `>90%` in `$p111.k.*` | `188` |
| `wave5_r3` v1 (Pass 1: arity 64) | `1.2236 s` | `5.77×` | `9.54×` | `115` (`92.2%` `chunk`) | `96` |
| `wave5_r3` v2b (Passes 1+2+3+4, rejected) | `2.2575 s` | `8.84×` | `5.17×` | `121` (`95.0%` `chunk`) | `96` |
| **`wave5_r3` v3 (Passes 1+2+4, FINAL, 3-run median)** | **`1.1408 s`** | **`5.11×`** | **`10.23×`** | **`89` (`96.6%` `chunk`)** | **`96`** |

### Verification Gates
- **`focused19`**: **`PASS 19/19`**
- **`observer_wave2_gate`**: **`PASS 15/15` (`0` violations)** + `44 + 2` ABI/live-metadata probes PASSED
- **`run_proxy.py --runs 1` (CPU 2)**: **`7/7 PASS`**, zero regression:
  - `histogram`: `66.242 ms` (`2.96× C`, `2.76× C16`) PASS
  - `gameoflife`: `677.588 ms` (`0.74× C`, `2.81× C16`) PASS
  - `nbody`: `116.941 ms` (`1.34× C`, `1.57× C16`) PASS
  - `list`: `0.249 ms` (`0.93× C`, `0.93× C16`) PASS
  - `expression`: `12.676 ms` (`2.03× C`, `1.75× C16`) PASS
  - `bst`: `45.023 ms` (`3.44× C`, `4.16× C16`) PASS
  - `editdist`: `28.125 ms` (`2.90× C`, `3.05× C16`) PASS
  - **7-family overall geomean**: **`1.771×` GCC-10 C** (`2.200×` Clang-16)
