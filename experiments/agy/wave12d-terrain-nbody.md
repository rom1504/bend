# Experiment Wave 12-D: Dual-Array Loop Scalarization (`terrain` `hist`) & GPR/XMM Spill Reduction

## Hypothesis
1. **H1 (Dual-Array Loop Carrier Unboxing):** `terrain` `hist` carries two `Array<U32> & U32` pairs (`r` and `rg`). `w5_lcu_selected` unboxes `r` at `depth=0`, but fails on `rg` at `depth=1` because `w5_lcu_ctor_before_again` only inspects the single statement immediately before `P113DAgain` and does not follow a 1-step `N111Set` copy from `value = p111_rt_ctor(...)`. Generalizing `w5_lcu_ctor_before_again` and `w5_lcu_rewrite_again_mc` to scan backwards through straight-line scalar statements (budget 64) with strict read/write/liveness checks will unbox both pairs (`$lcu1.$lcu0.$direct.hist`) and unlock dual-array `p117v_` hoisting, cutting `terrain` by `~1.3×`.
2. **H2 (Two-Pass Span-Priority XMM & All-9-Reg Post-Joint GPR Allocation):** Prioritizing short-span intervals (`<= 16`) in `x186_x_scanned_capped` and extending `w5c_post_joint_transient` to all 9 GPRs will cut spills in `terrain` `erode`/`fill` and `nbody` `loop3`.
3. **H3 (Forward Store-to-Load Peephole):** Forwarding `movq %r0, d0(%rbp)` across up to 8 pure register-only instructions in `w5c_copy_peep_t` will eliminate redundant stack reloads in `prng` loops.

## Evidence & Decisions
- **H1 — PROMOTED:**
  - Triggered both `$lcu1.$lcu0.$direct.hist` and `p117v_$lcu1.$lcu0.$direct.hist` (`1,231 -> 432` insns, `250 -> 99` `(%rbp)` ops, `19 -> 0` hot-loop calls).
  - Paired CPU `7` 3-run median (`x86-object -O2`): **`terrain`** `22.192 s -> 16.734 s` (**`1.326×` faster**, `-5.46 s`, exact stdout `2572468224`).
  - Passed `--check-only` (`0` type errors across `8,836` defs), `64/64 native64` (`68.8 s`), and `15/15` Observer Gate (`0` violations).
- **H2 — REJECTED (Reverted):**
  - Paired CPU `7` 3-run median regressed both `terrain` (`16.987 s -> 18.048 s`) and `nbody` (`11.525 s -> 11.878 s`). Reverted cleanly.
- **H3 — PARTIALLY PROMOTED (Drop-Only `W12FwdDrop`):**
  - Cross-register forwarding (`W12FwdRepl`) failed 2/64 `native64` (`broad/coverage-record-aggregation-64`, `-256`) and was rejected.
  - Same-register redundant reload dropping (`W12FwdDrop`, `r0 != rbp`) passed `64/64 native64` + `15/15` Observer Gate cleanly.

## Artifacts
- [REPORT.md](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/REPORT.md)
- [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/results.json)
- [w12d_terrain_nbody.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/w12d_terrain_nbody.patch)
- [compiler_w12d.bend](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/compiler_w12d.bend)
