# W12-G Report: 7-Family Compiled-Program Geomean Audit & Pure-Bend Codegen Upgrades

**Status:** **ALL GATES PASSED** (`--check-only` `0` type errors, `64/64 native64`, `15/15` Observer Gate with `0` violations).  
**7-Family Geomean vs `gcc-10 -O2` (CPU `7`, 5-run median):** **`1.3383×` -> `1.2644×`** (`1.058×` geomean improvement; **`editdist` `2.255× -> 1.646×`**, `gameoflife` `0.485× -> 0.470×`, `nbody` `1.081× -> 1.062×`, `list` `1.012× -> 1.006×`, `expression` `1.473× -> 1.312×`).

## 1. Deliverables
- **Patch (vs read-only `selfhost/build/agy/wave11_unified/compiler.bend`):** [w12g_7fam_1x.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/w12g_7fam_1x.patch) (`21,657 B`)
- **Reproducible Builder & Benchmark Harness:** [build_w12g.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/build_w12g.py), [bench_7fam.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/bench_7fam.py)
- **Full Receipts:** [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/results.json), [baseline_wave11.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/baseline_wave11.json), [after_w12g.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/after_w12g.json)

## 2. Paired 7-Family Results (`x86-object -O2` vs `gcc-10 -O2`, CPU `7`, 5-run median)

| Family | `gcc-10 -O2` (base) | Wave 11 (`api.mjs`) | Wave 11 / C | `gcc-10 -O2` (after) | **W12-G** | **W12-G / C** | Bend Speedup | Checksum |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| **`gameoflife`** | 950.419 ms | 461.002 ms | `0.485×` | 928.140 ms | **436.300 ms** | **`0.470×`** | `1.057×` | OK |
| **`list`** | 0.279 ms | 0.282 ms | `1.012×` | 0.264 ms | **0.265 ms** | **`1.006×`** | `1.064×` | 3/3 OK |
| **`nbody`** | 90.863 ms | 98.228 ms | `1.081×` | 88.987 ms | **94.512 ms** | **`1.062×`** | `1.039×` | OK |
| **`expression`** | 6.603 ms | 9.728 ms | `1.473×` | 7.193 ms | **9.433 ms** | **`1.312×`** | `1.031×` | 3/3 OK |
| **`editdist`** | 10.312 ms | 23.250 ms | `2.255×` | 11.719 ms | **19.286 ms** | **`1.646×`** | **`1.206×`** | 3/3 OK |
| **`histogram`** | 22.195 ms | 41.884 ms | `1.887×` | 22.013 ms | **43.654 ms** | **`1.983×`** | `0.959×` | OK |
| **`bst`** | 13.592 ms | 31.431 ms | `2.312×` | 13.082 ms | **31.431 ms** | **`2.403×`** | `1.000×` | 3/3 OK |
| **7-Family Geomean** | — | — | **`1.3383×`** | — | — | **`1.2644×`** | **`1.058×`** | **7/7 OK** |

## 3. Pure-Bend Codegen Upgrades Implemented
1. **Wire `w5_nat_match_chain` + Fix `G11` 2-Label `cmov` Peephole:**
   - `w5_nat_match_chain` existed in `compiler.bend` but had zero call sites; wired into `w4c_diamond_body`.
   - Fixed `w5_g11_c` / `w5_g11_d` to match 2-label empty-`else` diamonds (`jne L1; movq -disp(%rbp), %r; jmp L2; L1:; L2:` -> `cmoveq -disp(%rbp), %r`), converting `editdist`'s `symbol(s & 3, m)` 3-branch cascade into 3 branchless `cmove`s.
2. **6th Caller-Saved Register (`%rcx`) + 10-Slot `w5c_post_joint_transient`:**
   - Expanded `X185Transient` from 5 registers (`rdi, rsi, rdx, r8, r9`) to 6 (`+ %rcx`, gated on `!w12g_body_var_shift(body)`).
   - Expanded `w5c_post_joint_transient` to 10 slots (caller-saved `0..5` + callee-saved `rbx, r13, r14, r15` when not live at loop header), removed the `== 32` candidate-count gate, skipped dead-in-body `setup` locals in `w5c_pj_collect_one`, and taught `w4c_t_if_sel_no` that 1-arm `cmov` `if c { a = va } else {}` does not cut transient regions.
   - Eliminated **12 stack spills/reloads per iteration** in `editdist`'s `$product.columns` (`s` -> `%rcx`; `xh`, `ph>>31`, `hin==2`, `hm`, `new_pv` -> `%r15`).
3. **Unused Incoming ABI Register Relaxation (`x190_j_allowed`):**
   - Allowed caller-saved registers whose ABI argument index `>= nt_count(params)` to be assigned to any parameter in `x190_j_color` / `x190_a_color` / `x190_j_valid`.
4. **Generalized `G10` / `G10b` In-Place ALU Peephole:**
   - Extended `w5_g10_b` / `w5_g10_c` to `addl`/`subl`/`addq`/`subq` and 2-dest copies (`movq %rA,%rB; op $c,%rB; movq %rB,%rC; movq %rB,%rA` -> `op $c,%rA; movq %rA,%rC`), trimming `histogram`'s `$product.count.go` from 12 to 10 instructions and `editdist`'s loop decrement from 3 instructions to 1 (`sub $1, %r13`).

## 4. Verification Gates
| Gate | Result |
|---|---|
| **`--check-only`** | **PASS** (`0` type/linearity errors, `68.7 s`) |
| **`64/64 native64`** (`x86-object -O2`) | **64/64 PASS** (`61.6 s`) |
| **`15/15` Observer Gate** (`44+2` ABI + `5 × 3` modes) | **15/15 PASS** (`0` violations) |

## 5. Exact Remaining Structural Gaps to Reach `<= 1.05× gcc -O2`
Disassembly & `n=64` vs `n=0` isolation pinpointed the exact remaining gaps:
1. **`bst` (`2.40×` C):** `collect` is already **`1.00×` C** (`48 ms` vs `48 ms` at 160k reps). 100% of the gap is in `n=0` (`132 ms` vs `29 ms` C): C stack-allocates `uint32_t a[257]` (`sub $0x398, %rsp; rep stosq`), whereas Bend heap-allocates 512 U32s via `Array.new(U32, 9n, 0)` in `runtime-agy.o` + frees via `p111_rt_sink`, and `sorted_fold` keeps `callq repeat_key` for `v >= 3`, forcing `base` and `next` to spill.
2. **`histogram` (`1.98×` C):** `$product.count.go` is already a tight 10-instruction hoisted loop (vs C's 7-instruction loop; hoisting `t_base + row*4` for `ISUM` will match C's 7 instructions). The main remaining gap is `$direct.fill.go`: `gcc-10 -O2` auto-vectorizes `fill` (4-wide SSE2 `paddd`/`pslld`/`pxor`/`movups`) and `cols` (SSE2 `paddd`) and uses `rep stosq` for `zero`, whereas Bend emits scalar x86-64.
3. **`editdist` (`1.65×` C):** Down from `2.255×` C; remaining gap is 6 spills (`xv, neg, next, new_mv, new_hin, score`), 2× `movabs $0xffffffff; xor` (vs `notl`/`xorl $-1`), and 3 serial `cmove`s vs C's indexed stack lookup.
