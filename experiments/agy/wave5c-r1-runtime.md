# Wave 5C Track W5C-R1: General Runtime Closer (`editdist`, `bst`, `kmeans`)

- **Baseline**: `selfhost/build/agy/wave5b_unified/{compiler.bend,api.mjs}`
- **Patch script**: [apply_w5c_r1.py](file:///home/ai/bend2_agy/research/agy/wave5c_r1/apply_w5c_r1.py) (`--src <in> --dst <out>`)
- **Built artifact**: `selfhost/build/agy/wave5c_r1/{compiler.bend,api.mjs}` (`12 MiB` total, `< 20 MiB` cap)
- **Strict generality & orthogonality**: 100% general compiler passes only — zero benchmark matchers; zero edits to `runtime.c`/`runtime-agy.o`; zero touches to untouched final holdouts (`queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap`); 100% orthogonal to W5C-C1 (untouched: `w4b_reg_dead`, `w4b_copy_peep`, `w4_post_select` skip-flags, `x187_e_single`/`x187_e_pair`).

## Root-Cause Findings & General Passes Added

1. **General Post-Joint Transient Register Allocation (`w5c_post_joint_transient` in `x190_j_checked`)**:
   - **Root cause**: Joint graph-coloring regalloc (`x190_j_selected`) uses a 32-bit interference bitmask (`x203_candidates` caps at 32 locals). In large hot loops (`kmeans :: $direct.chunk` with 34 params + ~350 temporaries, `editdist :: $product.columns` with >32 locals), loop-carried params and setup locals consume the 32 slots and leave all remaining short-lived temporaries on the stack (`X181Stack`), even when caller-saved transient registers (`%rdi/%rsi/%rdx/%r8/%r9`) are unoccupied or only sparsely used in disjoint straight-line intervals.
   - **Pass**: When `x190_j_valid` succeeds and `nt_count(String, names) == 32` (zero overhead on functions with `< 32` candidates), run a sound post-joint linear-scan transient pass over all remaining `X181Stack` locals:
     - Scans `body` with `x185_t_body` (excluding `params` and `setup`).
     - For each joint-allocated `X185Transient{k}` (`k ∈ 0..4`), if any joint occupant is live across `Again` (`header & bit != 0`) or lacks a single-region `X185TRange`, permanently blocks register `k` (`ends[k] = 0xFFFFFFFF`). Otherwise records its exact inclusive interval `[da, dx]` in `occ[k]`.
     - Places remaining `X181Stack` single-region locals (`w5c_pj_place`) into the first transient register `k` whose `ends[k] < first` and whose `[first, last]` is strictly disjoint from every interval in `occ[k]`.

2. **General x86-64 GPR Peepholes in `w5b_peep`**:
   - **Load-bounce collapse (`w5c_try_load_bounce`)**: `movq d(%rbp), %r10/%r11; movq %r10/%r11, %rD` (scratch dead via `w5b_reg_dead_fast`) → `movq d(%rbp), %rD`. Eliminates 5 bounces/iter in `editdist :: $product.columns`, 1 bounce/iter in `bst :: $product.sorted_fold`, and dozens across `kmeans`.
   - **64-bit immediate ALU-bounce collapse (`w5c_try_alu64_bounce`)**: `movq %rA, %r10/%r11; addq/subq $imm, %r10/%r11; movq %r10/%r11, %rA` (scratch dead) → `addq/subq $imm, %rA`.
   - **Post-`movzbl` copy zero-ext elimination (`w5c_movzbl_copy`)**: `movzbl %r8, %rD32; movq %rD, %rB; movl %rB32, %rB32` → `movzbl %r8, %rD32; movq %rD, %rB`.

## Benchmark Results (CPU 2, Exact Output Verified)

### Proxy Suite (`run_proxy.py --runs 3`) — 7/7 PASS, Zero Regressions

| Benchmark | Group | `wave5b_unified` (C16) | `wave5c_r1` (Bend ms) | Bend/C | Bend/C16 | Status |
|---|---|---:|---:|---:|---:|---|
| `histogram` | upstream | `1.71×` | **`39.881 ms`** | `1.78×` | **`1.66×`** | PASS |
| `gameoflife` | upstream | `1.84×` | **`433.328 ms`** | `0.47×` | **`1.79×`** | PASS |
| `nbody` | upstream | `1.23×` | **`94.199 ms`** | `1.08×` | `1.26×` | PASS |
| `list` | tuned | — | **`0.265 ms`** | `0.99×` | **`0.99×`** | PASS |
| `expression` | tuned | `1.34×` | **`9.433 ms`** | `1.51×` | **`1.30×`** | PASS |
| `bst` | tuned | `2.67×` (`28.88 ms`) | **`28.883 ms`** | `2.21×` | **`2.67×`** | PASS |
| `editdist` | tuned | `2.64×` (`24.38 ms`) | **`22.188 ms`** | `2.29×` | **`2.41×`** (**`-9.0%`**) | PASS |

- **Upstream-medium geomean**: **`0.966×` Bend/C** | **`1.555×` vs Clang-16**
- **Tuned-4 geomean**: **`1.657×` Bend/C** | **`1.695×` vs Clang-16**
- **7-family overall geomean**: **`1.315×` Bend/C** | **`1.634×` vs Clang-16**

### Holdout Suite (`eval_all3.py --runs 3`) — 3/3 Exact Match

| Benchmark | `wave5b_unified` | `wave5c_r1` (3-run med) | Delta | Output Match |
|---|---:|---:|---:|---|
| `kmeans` (`13n`) | `1191.5 ms` (`6.29× C`) | **`1010.6 ms` (`5.32× C`)** | **`-15.2%`** | `1054846867` PASS |
| `bfs` (`15n`) | — | **`773.3 ms` (`1.93× C`)** | — | `3905624395` PASS |
| `merkle` (`18n`) | — | **`1205.4 ms` (`2.15× C`)** | — | `3967947184` PASS |

## Verification Gates

- **`focused19`**: **19/19 PASS**
- **`observer_wave2_gate.py`**: **15/15 PASS (0 violations)** + `44 + 2` ABI/live mutable metadata probes PASS
- **`bench_compile.py`**: **6/6 OK**, **`17.81 s` total** (`18.42 s` wall) vs **`17.86 s` total** (`18.53 s` wall) on `wave5b_unified` (**zero compile-time regression**, `-47 ms` faster, smaller `.o` on all 6 programs)
- **Footprint**: `selfhost/build/agy/wave5c_r1/` = **`12 MiB`** (`< 20 MiB` cap)
