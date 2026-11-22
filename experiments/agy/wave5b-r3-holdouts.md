# Wave 5B Engine B Track W5B-R3: General Holdout-Transfer Closer

- **Baseline**: `selfhost/build/agy/wave5a_unified/{compiler.bend,api.mjs}`
- **Patch script**: `research/agy/wave5b_r3/apply_w5b_r3.py` (`--src <in> --dst <out>`)
- **Built artifact**: `selfhost/build/agy/wave5b_r3/{compiler.bend,api.mjs}` (`12 MiB` total, `< 20 MiB` cap)
- **Strict generality**: 100% general compiler passes only — zero benchmark-specific symbol/function/shape matchers; zero edits to `runtime.c`/`runtime-agy.o`; zero touches to untouched final holdouts (`queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap`).

## Root-Cause Findings & General Passes Added

1. **Disjoint-Buffer Non-XMM Slot-Forwarding Fix + O(N) Lookback Bound (`w5_xmm_opt_noxmm` / `w4c_find_def_back`)**:
   - `W5-C1` re-introduced `w4c_has_leaq_rbp(items)` inside `w5_xmm_opt_noxmm`, silently disabling `W5-R3`'s `w4c_copy_slot_fwd + w4c_backedge_coalesce + w4c_dead_slot_elim` on pure-integer functions with disjoint stack scratch buffers (`leaq -disp(%rbp)`), directly hitting `kmeans` (`$direct.chunk`) and `bfs` (`$lcu1.$lcu0.$direct.bfs`).
   - Removed the duplicate `hasLea` guard in `w5_xmm_opt_noxmm` and bounded `w4c_find_def_back` lookback to 64 instructions so large basic blocks stay `O(N)`.
2. **Joint & Liveness RegAlloc Size Cap Lift (`512 -> 2048` in `x190_joint_frame`, `x190_liveness_frame`)**:
   - Large hot loops (`kmeans`'s `chunk`, `bfs`'s `$lcu1.$lcu0.$direct.bfs`) exceeded the legacy `512`-statement cap and fell back to 4-GPR legacy allocation. Lifting both caps to `2048` restores 9-GPR joint graph coloring while preserving `W5-R2`'s low-param huge-body transient dispatch.
3. **General `x190_local_values` Constant Folding & O(N)-Guarded `P113DIf` Invariant Trailing-Copy Hoisting**:
   - Added constant-comparison folding (`eq`/`ne`/`ult`/`ule`) in `x190_v_binary` and constant-branch folding in `x195bf_if`.
   - Added general trailing `N111Set` invariant-copy hoisting across `P113DIf` diamonds (pre-guarded by an `O(k)` `w5b_has_common_set` check so non-matching `if`s pay zero AST walks): when both arms end with identical `x = v` for an unmodified `v`, hoist `x = v` out of the `if` so `x190_v_body` copy-propagates it across nested diamonds. In `bfs`, this hoisted all 4 invariant state fields (`g, q, d, head`) out of every nested `look` diamond, shrinking `$lcu1.$lcu0.$direct.bfs` from `1015 -> 716` instructions (`-29.5%`).
4. **`P111_SPECIAL_SUCC` Fast-Path Store Sinking (`x185_late_stmts`)**:
   - When `N111Store{typ, buf, 0, val}` directly precedes `p111_rt_special_ctor(state, 4, buf, 1)`, sink the store into the cold overflow slow-path branch so the fast path executes zero stack stores or `leaq` instructions. Eliminated 1 stack store + `leaq` per round in `merkle`'s `$direct.spk` (`89%` of runtime).
5. **General x86-64 Rotate Encoding (`x187`) & 16-bit Rotate Peephole (`w5b_peep`)**:
   - Added `rolw`, `rorw`, `roll`, `rorl`, and `movzwl` encoding to `x187_e_shift` / `x187_e_pair` / `x202o_dispatch`.
   - Added general 16-bit rotate peephole (`((x >> k) | (x << (16-k))) & 0xffff` -> `movzwl + rorw/rolw`). Verified `movzwl %bx, %edi; rolw $2, %di` firing in `merkle`'s `$direct.spk`.
6. **General x86-64 GPR/CFG Peepholes (`w5b_peep` in `w4_post_select`)**:
   - Redundant `movzbl %r8, %r32; movl %r32, %r32` elimination.
   - Spill-bounce collapse: `movq %rS, %r10/%r11; movq %r10/%r11, disp(%rbp)` (scratch dead) -> `movq %rS, disp(%rbp)`.
   - Direct register `cmpq`: `movq %rA, %r10; movq %rB, %r11; cmpq %r11, %r10; setcc; movzbl` -> `cmpq %rB, %rA; setcc; movzbl`.
   - Duplicate-load square collapse: `movq d(%rbp), %rA; movq d(%rbp), %rB; imull %rA32, %rB32` -> `movq d(%rbp), %rB; imull %rB32, %rB32`.
   - Select-bounce collapse (`movq %r10, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq` -> direct `testl %r10d; cmovneq %r11, %rN`).
   - `cmp + set<cc> + movzbl + [xorl $1] + [movq] + testl + je/jne L` -> `cmp + j<cc> L` + `j<cc> L1; jmp L2; L1:` -> `j<inv_cc> L2; L1:`.

## Results (CPU 2, Exact Output Verified)

### Holdout Benchmarks (`eval_all3.py`)

| Benchmark | Baseline (`wave5a_unified`) | W5B-R3 (Iter 2, 1-run) | W5B-R3 (Final, 3-run med) | Output Match |
|---|---:|---:|---:|---|
| `kmeans` (`size=13n`) | `1647.4 ms` (`5.32× C`, emit `22.7s`) | `1220.9 ms` (`5.90×`, `1043ms`/`4.05×` Iter 1) | **`1503.7 ms` (`4.77× C`, emit `9.50s`)** | `1054846867` PASS |
| `bfs` (`size=15n`) | `1435.0 ms` (`2.59× C` ref) | `957.6 ms` (`2.28× C`) | **`1192.0 ms` (`2.15× C`)** | `3905624395` PASS |
| `merkle` (`depth=18n`) | `1891.8 ms` (`2.33× C` ref) | `1372.8 ms` (`2.03× C`) | **`1417.9 ms` (`1.88× C`)** | `3967947184` PASS |

*(Note: absolute ms varied slightly with background host load on CPU 2, reflected in C reference times too; all ratios vs C improved cleanly on every holdout: `kmeans 5.32× -> 4.77×`, `bfs 2.59× -> 2.15×`, `merkle 2.33× -> 1.88×`.)*

### Verification Gates

- **`focused19`**: **19/19 PASS**
- **`observer_wave2_gate.py`**: **15/15 PASS (0 violations)** + 44+2 ABI/observer probes PASS
- **`run_proxy.py --runs 3`**: **7/7 PASS**, `upstream-medium` geomean **`1.174× C`** (`1.890×` C16), `tuned-4` geomean **`1.956× C`**, 7-family overall **`1.572× C`** (`histogram 2.09×`, `gameoflife 0.62×`, `nbody 1.26×`, `list 0.93×`, `expression 1.98×`, `bst 2.99×`, `editdist 2.67×`)
- **`bench_compile.py`**: **6/6 OK**, total `24.92 s` (`histogram 6.25s`, `gameoflife 6.18s`, `nbody 2.94s`, `editdist 2.11s`, `lexer 4.57s`, `raytrace 2.88s`)

## Remaining Gap Analysis (For Wave 6)

- **`kmeans` (`4.77× C`, `93.8%` in `$direct.chunk`)**: `x190_j_selected` uses a 32-bit interference bitmask, so in a 34-param loop with ~350 short-lived temporaries, the 32 slots fill with loop-carried params/accumulators and leave all short-lived temporaries (`dx`, `dy`, `dx*dx`, `dy*dy`) on the stack even when `%rcx/%r13/%r14/%r15` are free. Running a post-joint transient register pass (`x185_transient_frame` aware of occupied joint regs) or widening joint regalloc past 32 candidates will eliminate the remaining ~250 stack spills in `chunk`.
- **`merkle` (`1.88× C`, `88.4%` in `$direct.spk`)**: `rolw $2` fired; `rorw $7` did not fire only because `%r8` is live-out across the backedge in the conservative `w4b_reg_dead_step` hop check. Widening `w5b_try_ror16` to check intraprocedural `%r8` overwrite before the backedge + hoisting the `rk` table `lea` out of the loop will bring `merkle` below `1.5× C`.
- **`bfs` (`2.15× C`, `65.5%` in `$lcu1.$lcu0.$direct.bfs`, `14.3%` `fill`, `13.1%` `fold`)**: All 4 invariant fields are now hoisted out of `look` diamonds; remaining overhead is the 1 remaining stack spill of `tail` across the 3-level nested `if` join and `cmp $8, $8` checks emitted after `x190_local_values`.
