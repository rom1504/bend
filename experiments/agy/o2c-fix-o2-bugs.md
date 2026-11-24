# Experiment `o2c-fix-o2-bugs`: Wave 16 `-O2` 3-Bug Fix (`132/158 -> 158/158`)

- **Hypothesis:** Fixing the three exact `-O2` bugs pinpointed by `W16-MINT` (`x86-merge-obj` `caps` overwrite, `x86-iface v3` `x198o_progress_get` direct-stub mismatch, and `w11_cmp_jcc_emit` missing branch-target liveness check on `w5c2_bits_nz`) in pure Bend eliminates all 16 `-O2` gate hangs and the 2 manual binary patches in `n7_o2`, unlocking clean `158/158` `-O0`/`-O2` qualification on Wave 17.
- **Patcher:** [research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py) (idempotent, `+305 B` against [selfhost/build/agy/wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend)).
- **Detailed Report & Evidence:** [research/agy/o2_50s/o2c_fix_o2_bugs/REPORT.md](file:///home/ai/bend2_agy/research/agy/o2_50s/o2c_fix_o2_bugs/REPORT.md) and [results.json](file:///home/ai/bend2_agy/research/agy/o2_50s/o2c_fix_o2_bugs/results.json).

## Summary of Fixes & Verification

| # | Bug | Function (`wave16_unified/compiler.bend`) | Pure-Bend Root-Cause Fix | Verification |
|---|---|---|---|---|
| 1 | `x86-merge-obj` `caps=7` bit `0x2` overwrite | `w10_merge_copy_one` (`L77199`) | Bitwise-AND each module's `88(%r8)` into `p111_program+88` (`88(%r9)`) | **PASS** — `n7_o2` before: `merged_caps=7` (fail); patched 4-insn sequence: `merged_caps=5` (pass) |
| 2 | `x86-iface v3` `x198o_progress_get` `jmpq <self>` thunk | `w14a_fast_abi_go2` (`L80806`) | Replace `w13d_p113pl_candidates_fast(..., [])` with `p113pl_candidates(..., book_cached(nq_signatures(book, names), 0))` to match `-O2` `p168_selected` | **PASS** — 20-line `repro_x198o.bend` reproduced exact `48 89 f7 48 89 d6 e9 fb ff ff ff` loop & 2-ctor control proved `nq_signatures` cause |
| 3 | `w5c2_bits_nz` `xorl $1, %edx` uninitialized reg | `w11_cmp_jcc_emit` (`L62207`) | Check `w5b_reg_dead_fast` on `Con{jcc, tail}` instead of fallthrough `tail` only | **PASS** — 15-line `repro_bits.bend` reproduced exact `cmpq $1,%r8; jne .L_b0; ... xorl $1,%edx`; `w4b_reg_dead_branch` verified to check both paths |
| — | Type & Linearity Check | Full patched `compiler_o2c.bend` (`3,497,447 B`) | `./research/agy/locked_bun.sh --check-only` | **PASS** — `0` type errors, `0` linearity errors (`9,127` `@unsafe` defs) |

## Decision
**PROMOTE** `apply_o2c.py` into Wave 17 composition so `n8_o2` mints with zero binary patches and targets `158/158` (`79/79` `-O0` + `79/79` `-O2`) on the first shot.
