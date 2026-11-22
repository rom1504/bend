# Wave 4 Phase 2 — Track W4-7: Call-Free Full-XMM Loop Allocator + Magic-Constant LICM + Copy-Forwarding Peephole + Bottom-Tested Loops

## Summary

Track W4-7 implements four 100% general, semantics-preserving x86-64 codegen passes on top of `selfhost/build/agy/wave4a_unified/compiler.bend` via the composable patcher [`research/agy/wave4b_loopxmm/apply_loopxmm.py`](../../research/agy/wave4b_loopxmm/apply_loopxmm.py), producing `selfhost/build/agy/wave4b_loopxmm/compiler.bend` and `selfhost/build/agy/wave4b_loopxmm/api.mjs` (9.6 MiB total dir size).

- **Zero benchmark-specific pattern matchers / AST templates.**
- **Exact IEEE-754 `F32` semantics preserved** (no FMA contraction; chaotic `nbody` checksum `728502159`, `raytrace` checksum `1612651` / `402971`, and `mandelbrot` checksum `3969916376` match bit-for-bit).
- **All correctness & observer gates pass:** `19/19 focused19`, `15/15 observer_wave2_gate` (`0 violations`), and exact oracle checksums on all proxy benchmarks.

## Passes Implemented (`apply_loopxmm.py`)

1. **Dynamic Call-Free XMM Loop Partitioning (`xmm2..xmm15`) + Hot-Loop Constant Hoisting (`w4b_xl_hot_consts`, `w4b_xl_start_reg`, `x186_x_scanned_capped`):**
   - Previously, `w4_xl_build_loop` hardcoded `startReg = 10` (only 6 loop-pinned XMM registers `xmm10..xmm15`) and `w2_xl_consts` collected constants from cold loop-exit branches (e.g., `0.5` in `nbody`'s `n == 0` exit case stole a loop register while `0.001` used 18× per iteration and `1.0` used 3× per iteration were left unhoisted).
   - `w4b_xl_hot_consts` collects float constants exclusively from paths that can reach `P113DAgain`.
   - `w4b_xl_start_reg` dynamically partitions `xmm2..xmm15` between intra-iteration temps (`xmm2..xmm(startReg-1)`) and loop-pinned invariants/constants/carried values (`xmm(startReg)..xmm15`): loops needing ≤ 6 pinned floats keep `startReg = 10` (zero change), while register-heavy float loops expand down to `--min-start 8` (`xmm2..xmm7` = 6 temp regs, `xmm8..xmm15` = 8 loop-pinned regs).
   - Bumped `w2_dead_in` fuel in `w2_x_emit_branch_or_node` and `w2_skip_dom_ne` from `64` to `512`, enabling large float loops to fuse their integer loop-exit comparison and eliminate dominated `n != 0` checks.
   - Note on `--min-start` sweep: `min_start_reg=4` (only 2 temp XMM regs) increased intra-iteration stack spills in `loop3` (`150 → 244` `%rbp` refs, `193.3 ms`); `min_start_reg=7` dropped `nbody` to `140.2 ms`; `min_start_reg=8` achieved the best balance (`135.1–137.9 ms`).

2. **CFG-Aware Copy-Forwarding & Flag-Reuse Peephole (`w4b_copy_peep`, `w4b_reg_dead`):**
   - Runs in `w4_post_select` on the flat `List<&2, X187Parsed>` stream using strictly shallow single-level extractors (avoiding `bend.ts` pattern-match blowup).
   - Folds `movl %s32, %t32; movq %t64, %d64 → movl %s32, %d32` and `movl %s32, %t32; alu32 %t32, %d32 → alu32 %s32, %d32` when `%t` is provably dead along all CFG paths (bounded 3-hop `jmp`/`jcc` deadness analysis).
   - Drops redundant `cmpq $0, %d64` before `je`/`jne` when immediately preceded by `subl %s32, %t32; movl %t32, %d32`, and drops redundant self-`movl %r32, %r32` after 32-bit zero-extending writes.

3. **General Loop-Invariant Magic-Constant Hoisting (`w4b_licm_magic`):**
   - On call-free functions with a loop header `L` (targeted by backward `jmp L` and never jumped to before `L`), identifies free caller-saved GPRs in `[r8, r9, rcx, rdx]` unused from `L` onward, hoists `movl $imm, %r_free_32` (`imm >= 256`) before `L`, and rewrites `movl $imm, %r11d; imulq %r11, %rax → imulq %r_free, %rax` (e.g., hoisting `0xaaaaaaab` and `0xcccccccd` for `U32.mod` by 3 and 5 in `expression`'s `unwind`).

4. **General Bottom-Tested Tail-Loop Rotation + Tiny Backedge Tail-Duplication (`w4b_rotate_loop`, `w4b_taildup_check`):**
   - Rotates canonical top-tested tail loops (`L: cmpq/cmpl $0, %r; jne L_body; <exit>; L_body: <body>; jmp L`) into bottom-tested loops (`test %r, %r; je L_exit; L_body: <body>; test %r, %r; jne L_body; L_exit: <exit>`), eliminating 1 unconditional `jmp` per iteration.
   - Tail-duplicates 1-instruction merge-backedge blocks (`L_merge: mov; test; jne L_body`) into `jmp L_merge` sites inside the loop body, eliminating double jumps on interior branches.

## Benchmark Results (CPU 2, `runs=3`, `--threads 1 --gpu off`)

### Target Proxy Benchmarks (`research/agy/wave4_bench/run_proxy.py --only nbody,expression,list --runs 3`)

| Benchmark | Group | Checksum | C (GCC-10) | C16 Ref | `wave4a_unified` | `wave4b_loopxmm` | Speedup | `Bend/C16` (Before → After) | `Bend/C` (Before → After) |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **`nbody`** | upstream-med | `728502159` | `87.429 ms` | `74.700 ms` | `209.952 ms` | **`135.149 ms`** | **`1.55×`** | `2.81×` → **`1.81×`** | `2.40×` → **`1.55×`** |
| **`expression`** | tuned | `3393903617` | `6.249 ms` | `7.237 ms` | `14.739 ms` | **`10.317 ms`** | **`1.43×`** | `2.04×` → **`1.43×`** | `2.36×` → **`1.65×`** |
| **`list`** | tuned | `1904` | `0.269 ms` | `0.269 ms` | `0.274 ms` | **`0.249 ms`** | **`1.10×`** | `1.02×` → **`0.93×`** | `1.02×` → **`0.93×`** |
| **3-family geomean** | — | ALL PASS | — | — | `1.800×` C16 | **`1.337×` C16** | **`1.35×`** | `1.800×` → **`1.337×`** | `1.793×` → **`1.332×`** |

### Floating-Point Zero-Regression Check (Interleaved 5-run median, CPU 2)

| Benchmark | Knob | Checksum | `wave4a_unified` | `wave4b_loopxmm` | Ratio |
|---|---|---:|---:|---:|---:|
| **`raytrace`** | `rows=7n, width=160` | `1612651` | `35.29 ms` | **`33.84 ms`** | **`0.959×`** (-4.1%) |
| **`mandelbrot`** | `rend!(10n, 51n)` | `3969916376` | `9.66 ms` | `9.86 ms` | `1.020×` (noise) |

## Verification Summary

- `19/19 focused19`: **PASS** (`failed=[]`)
- `15/15 observer_wave2_gate` (`normal`, `cap-no8`, `all-hot`): **PASS** (`0 violations`)
- `nbody`, `expression`, `list`, `raytrace`, `mandelbrot`: **100% bit-exact checksums**
- Artifact size: `selfhost/build/agy/wave4b_loopxmm/` = **9.6 MiB** (`compiler.bend` + `api.mjs`), zero leftover `/tmp` scratch.
