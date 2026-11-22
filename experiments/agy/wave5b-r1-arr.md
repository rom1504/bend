# Wave 5B Engine B Track W5B-R1: Array/Loop Closer (`histogram`, `editdist`, `bst`)

## Summary
Implemented 4 **100% general, semantics-preserving** compiler passes in [apply_w5b_r1.py](file:///home/ai/bend2_agy/research/agy/wave5b_r1/apply_w5b_r1.py) (`--src <in> --dst <out>` on top of `selfhost/build/agy/wave5a_unified/compiler.bend`), with zero benchmark-specific function/symbol matchers and zero runtime edits.

## Passes Implemented
1. **Pass 1 — Narrow `w5_body_no_dcalls` in `p113j_inline`**:
   - Root cause of `bst` regression (`29.73 ms` → `34.0 ms`): every `Nat`-matching function (including `repeat_key`) contains an unreachable `p111_rt_fail` `N111Call` branch, so rejecting all `N111Call`s blocked 2-step peeling for every `Nat` loop.
   - Fix: reject only `p113_rt_array_pair` (product-array import requiring buffer verification) and `N111Alloca`.
   - Result: `broad/local-fold` stays **PASS** (`2339999928`) while `bst` fully recovers to **`29.733 ms`** (`-12.6%` vs `34.0 ms`).

2. **Pass 2 — General BCE for Non-Sunk Inlined Array Ops, Negated-Min & Constant-Divisor Mod**:
   - Propagate `ISUM`, `MIN`, `LT_*`, and `NLT_*` facts through `w4c_env_copy`.
   - Track `xor(LT_x, 1)` → `NLT_x` and recognize both `LT_x` and `NLT_x` in `w5_step_min_if` (fixes `U32.min(x, k1)` where Bend lowers `Bool` match with `xor 1`).
   - Track `N111Store(buf, 8, val)` (both constant divisors `"C8"` and local facts) into `env["__st8_" ++ buf]`, track `p111_rt_op(state, 19, buf, 2)` (mod by constant) and `urem(x, C)` as `BM(C - 1)`, and hoist `bound <= mask` for `BM` locals in `w4c_bce_site_local`.
   - Apply `w4c_bce_site` in `w4c_bce_walk_step` for non-sunk array ops (`id = 72/73/74`, e.g. inside inlined helpers using `p113i_*_scratch`) via `env["__st8_" ++ buf]`.
   - Impact:
     - `histogram :: p113d:$product.count.go` drops from **17 insns + 2 stack spills + `and` mask** to **12 insns, 0 spills, 0 mask** (`addl $1, (%rdi,%rsi,4)` stays fused).
     - `bst :: p113d:$direct.collect` drops `mov -0x940(%rbp), %r11; and %r11, %rsi` (15 insns, 0 stack accesses, fused `addl $1, (%rbx,%rsi,4)`).

3. **Pass 3 — General Unreachable `ne(x, 0)` Fail-Branch Elimination (`w5_elim_nat_fail`)**:
   - Simplifies `c1 = eq(x, 0); if c1 { A } else { c2 = ne(x, 0); if c2 { B } else { fail } }` → `c1 = eq(x, 0); if c1 { A } else { B }` before `w4c_dia_body`.
   - Note: tested two branchless `cmov` multi-arm `Nat` match variants on `editdist :: $product.columns` (`symbol(s & 3, m)`): cond-saving diamond (`48.75 ms`, spilled `j`/`pv`/`arr_ptr`) and zero-temp `cmov` chain (`30.94 ms`, 4 stack loads per iter vs 1); both were rejected on measurement, keeping `w5_elim_nat_fail` which cleanly improves `editdist` to `24.750 ms`.

4. **Pass 4 — General x86-64 GPR Peepholes**:
   - Raised dead-`%rax` scan window in `w4c_try_eax_and_3` from `24` to `64` (folds `mov %esi,%eax; and $0xff,%eax; mov %rax,%rsi` → `and $0xff,%esi` in `histogram :: $direct.fill.go`).
   - Added **G10** (`movq %rA,%rB; addl $c,%rB32; movq %rB,%rA` with `rB` dead → `addl $c,%rA32`) and **G11** (`jne/je L; movq -disp(%rbp),%r64; jmp L; L:` → `cmoveq/cmovneq -disp(%rbp),%r64; L:`) in `w5_gpr_peep`.

## Benchmark Results (CPU 2, `run_proxy.py --runs 3`)
| Benchmark | Group | `wave5a_unified` (ms / C16) | `wave5b_r1` (ms / C16) | Bend/C | Delta vs `wave5a` | Status |
|---|---:|---:|---:|---:|---:|---|
| `histogram` | upstream | 46.0 ms (`1.92×`) | **40.861 ms (`1.70×`)** | `1.82×` | **-11.2%** | PASS |
| `gameoflife` | upstream | — | **471.614 ms (`1.95×`)** | `0.51×` | 0% | PASS |
| `nbody` | upstream | — | **92.982 ms (`1.24×`)** | `1.06×` | 0% | PASS |
| `list` | tuned | — | **0.439 ms (`1.64×`)** | `1.64×` | 0% | PASS |
| `expression` | tuned | — | **10.612 ms (`1.47×`)** | `1.70×` | 0% | PASS |
| `bst` | tuned | 34.0 ms (`3.14×`) | **29.733 ms (`2.74×`)** | `2.27×` | **-12.6%** | PASS |
| `editdist` | tuned | 25.1 ms (`2.73×`) | **24.750 ms (`2.68×`)** | `2.55×` | **-1.4%** | PASS |

- **Upstream-medium geomean**: `0.997×` Bend/C, `1.606×` vs Clang-16
- **Tuned-4 geomean**: `2.004×` Bend/C, `2.050×` vs Clang-16
- **7-family overall geomean**: `1.486×` Bend/C, `1.846×` vs Clang-16

## Verification Gates
- `broad/local-fold`: **PASS** (`2339999928`)
- `focused19`: **19/19 PASS**
- `observer_wave2_gate.py`: **15/15 PASS (0 violations)** + 44+2 ABI/metadata probes PASS
- `bench_compile.py`: **20.64 s total** (`3.01 s` plan + `17.58 s` emit, 6/6 OK, zero compile-time regression)
- Build footprint: `selfhost/build/agy/wave5b_r1/` = **11 MiB** (`< 20 MiB` cap)
