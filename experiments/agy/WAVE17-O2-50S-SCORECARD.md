# Wave 17 (`W17-O2`) Composition, Mint & `-O2` Cold Self-Compile Scorecard

**Date:** `2026-11-24T01:25Z`  
**Status:** Composed, Type-Checked (`0` errors), Split (`K=10`/`K=16`/`K=24`), Stage-0 Minted & Smoked (`-O0` + `-O2` `out=34`), Stage-1 `K=16` `-O2 --nodrop` Compiled `16/16` (FID overflow `68,469 / 65,532` hit at `01:24:15Z`, 1m45s before `01:26Z` hard deadline).

## 1. Wave 17 Unified Source & Splits

- **Composer:** [`compose_w17.py`](file:///home/ai/bend2_agy/research/agy/o2_50s/w17_o2/compose_w17.py)
- **Source:** [`selfhost/build/agy/wave17_unified/compiler.bend`](file:///home/ai/bend2_agy/selfhost/build/agy/wave17_unified/compiler.bend) (`3,497,142 B` → `3,523,906 B`, `+26,764 B`)
- **Applied cleanly (0 conflicts):**
  1. **O2-C**: All 3 Wave 16 `-O2` bug fixes (`w10_merge_copy_one` caps AND, `w14a_fast_abi_go2` `nq_signatures`, `w11_cmp_jcc_emit` branch-target liveness).
  2. **O2-F**: Linear `O(N)` `w4b_find_loop`.
  3. **O2-A (safe 4/7 hunks only)**: `w4b_reg_dead_cap`, `w14a_sl_rounds_cap`, `w14a_sl_rounds_cap_h`, `x191_frame_forward_large_call_cap` (omitted unsafe hunks 5–7).
  4. **O2-D**: Full zero-`.p130` stub skip + `-O2` direct-stub skip + synthetic `.exp` demand.
  5. **O2-E**: `w7c_fast_inst_c` + `x186`/`x190`/`x191` non-loop fast paths + `w8_tr_emit_pub` cold fast path.
  - **Omitted:** `O2-B` (held back to guarantee 0% `bst`/`terrain` regression).
- **Type-check (`locked_bun.sh --check-only`):** **PASS** (`0` type errors, `0` linearity errors, `9163` standard `@unsafe` defs).
- **Balanced Acyclic Splits:**
  - `k10_wave17`: `avg=339.4 KB`, `max=340.5 KB` (`1.003x`), `422` types, `9,379` defs, `912` laws, `0` cycles.
  - `k16_wave17`: `avg=212.2 KB`, `max=213.4 KB` (`1.006x`).
  - `k24_wave17`: `avg=141.5 KB`, `max=142.6 KB` (`1.007x`).

## 2. Stage 0 (`n8_stage0`) & Stage 1 (`K=16` `-O2 --nodrop`) Results

- **Stage 0 (`n7_o2` compiling `k10_wave17` in `-O0`):**
  - Linked `n8_stage0` (`84,134,680 B`, `65,206 / 65,532` FIDs).
  - Smoke PASS: `compiler_slice.bend -O0` → `out=34` (`7,500.9 ms`, `377,176 B`), `-O2` → `out=34` (`12,107.0 ms`, `390,640 B`).
- **Stage 1 (`n8_stage0` compiling `k16_wave17` in `--nodrop --trace x86-module` `-O2`):**
  - **All 16/16 modules compiled cleanly in TRUE `-O2 --nodrop`** (0 crashes, 0 hangs, peak RSS `474.7 MiB`!).
  - **FID count:** `68,469 / 65,532` (`+2,937` over 16-bit limit) — stopped before merge/link at `01:24:15Z`.

## 3. Two Key Engineering Findings for Immediate Next Step

1. **Why `K=16` hit `68,469` FIDs (`+2,937` over 65,532):**
   - `o2d_is_exp_main_go` did **not** match `m00..m14`'s synthetic `.exp` `main()` (`m00` emitted `5,284` segs vs `n7`'s `5,273`), so the ~20,000 dead `.exp` currying factory FIDs remained. Fixing the `o2d_is_exp_main_go` AST pattern (or minting `n8_o2` on `k10_wave17` immediately) unlocks `K=16` and `K=24` with >15,000 FID headroom.
2. **Exact `-O2` Stage Breakdown (`k16_wave17` on `-O0` `n8_stage0`, divide by `2.805×` for `-O2` `n8_o2` speed):**
   - `cpu_sum = 3,637 s` at `-O0` binary speed → projected **`~162 s` 8-core wall** at `-O2` `n8_o2` speed (down from `~700 s` `n6_o2` baseline — a **`~4.3×` speedup**, but still above the `<= 50 s` target!).
   - Per-module ranges on `n8_stage0` (`-O0` speed → projected `-O2` speed):
     - `x187_priv`: `85–185 s` → **`30–66 s`**
     - `x187_pub`: `34–173 s` → **`12–62 s`** (note `m10` spent `173 s` in `x187_pub`!)
     - `x198pw_plan`: `56–113 s` → **`20–40 s`**
     - `p86_plan`: `20–29 s` → **`7–10 s`**
     - `x187_elf`: `2.1–3.9 s` → **`0.8–1.4 s`** (solved!)
   - **Next to hit `<= 50 s`:** (1) fix `o2d_is_exp_main_go` (slashes both FIDs and `x187_pub` + `x198pw_plan` on dead `.exp` factories!), (2) mint `n8_o2` on `k10_wave17` and run the official `158/158` + 7-family + `terrain` gates!
