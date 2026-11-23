# W12-D Report: Dual-Array Loop Scalarization (`terrain` `hist`) & GPR/XMM Spill Investigation

**Headline Result:**
- **`terrain` (`SIZE=16n, EPASS=5n`, exact `2572468224`):** **`22.192 s` → `16.734 s`** (**`1.326×` faster**, **`-5.46 s`** on CPU 7; equivalent to **`~-9.8 s`** on W11-B's CPU 6 baseline).
- **Root Cause & Fix (`w5_lcu` Dual-Carrier Unboxing):** `w5_lcu_selected` already recursed to `depth < 2`, so `$direct.hist` unboxed its first pair `r: Array<U32> & U32` into `$lcu0.$direct.hist`, but `depth = 1` failed on the second pair `rg: Array<U32> & U32` because:
  1. `w5_lcu_ctor_before_again` only inspected the single statement `s0` immediately preceding `P113DAgain`, missing constructors separated from `P113DAgain` by intervening arithmetic (`acc_next = acc * 2654435761 + v * (i + 1)`).
  2. `p111_rt_ctor` writes into `value`, followed by `N111Set{v_next, N111U64{}, N111Local{"value"}}`.
  Generalizing `w5_lcu_ctor_before_again` and `w5_lcu_rewrite_again_mc` to scan backwards up to 64 straight-line scalar statements (with strict read/write/liveness safety checks on `aName`, `buf`, `src`, and `fvs`) and follow a 1-step `N111Set` copy immediately unboxes **both** pairs (`$lcu1.$lcu0.$direct.hist`), which automatically unlocks **`p117v_$lcu1.$lcu0.$direct.hist`** (direct-memory array hoisting for both `h2` and `g` simultaneously!).
- **All Mandatory Gates PASSED (`0` regressions, `0` violations):**
  - `--check-only`: **PASS** (`0` type/linearity errors across `8,836` defs; `@unsafe` audit only)
  - `64/64 native64` (`x86-object -O2`): **`64/64 PASS`** (`68.8 s`)
  - `15/15` Observer Gate (`44+2` ABI + 5 probes × 3 modes): **`15/15 PASS`** (`0` violations)

---

## 1. Paired A/B Benchmarks (CPU `7`, `x86-object -O2`, 3-Run Median)

| Benchmark | Wave 11 (`api.mjs`) | **W12-D (`compiler_w12d.bend`)** | Speedup | Checksum |
|---|---:|---:|---:|---|
| **`terrain` big** (`16n, 5n`) | `22.192 s` (`[22.039, 22.192, 22.868]`) | **`16.734 s`** (`[17.066, 16.734, 16.597]`) | **`1.326×`** (`-5.46 s`) | `2572468224` OK |
| **`nbody` med** (`10n, 300n`) | `134.2 ms` (`[133.5, 143.5, 134.2]`) | **`133.9 ms`** (`[135.4, 133.9, 133.9]`) | `1.002×` | `728502159` OK |
| **`nbody` big** (`17n, 300n`) | `11.313 s` (`[11.313, 11.308, 11.510]`) | `11.469 s` (`[11.357, 11.469, 16.217]`) | `0.986×` (identical asm) | `3516450380` OK |

### Disassembly Impact (`objdump -d`)

| Function | Wave 11 (Insns / `(%rbp)` / Calls) | **W12-D (Insns / `(%rbp)` / Calls)** | Change |
|---|---:|---:|---|
| **`terrain` `hist` hot loop** | `$lcu0.$direct.hist`: `1,231` / `250` / `19` | **`$lcu1.$lcu0.$direct.hist` + `p117v_`**: **`432` / `99` / `8`** (`0` in hot loop!) | **`-64.9%` insns, `-60.4%` `(%rbp)`, `0` hot calls** |
| **`terrain` `$product.erode`** | `501` / `108` / `1` | `501` / `108` / `1` | Unchanged |
| **`terrain` `$product.fill`** | `303` / `86` / `1` | `303` / `86` / `1` | Unchanged |
| **`nbody` `$product.loop3`** | `733` / `189` / `0` | `733` / `189` / `0` | Unchanged |

---

## 2. Rejected Spill-Reduction Experiments (Preserved per Policy)

1. **Two-Pass Span-Priority XMM Allocation (`x186_x_scanned_capped`) + All-9-Register Overflow Allocation (`w5c_post_joint_transient`):**
   - Eliminated inner-kernel spills in `nbody` `loop3` pair B/C (`bx..bz, cx..cz`) by prioritizing `span <= 16` before `qax..qaz`, and extended `w5c_post_joint_transient` to all 9 colors.
   - **Outcome: REJECTED.** Paired CPU 7 3-run medians regressed both `terrain` (`16.987 s` → `18.048 s`) and `nbody` (`11.525 s` → `11.878 s`) because spilling `qax..qaz` added latency on the critical force-accumulation chain, and callee-saved overflow allocation disrupted register scheduling in `erode`. Reverted cleanly.
2. **Cross-Register Store-to-Load Forwarding (`W12FwdRepl` in `w5c_copy_peep_t`):**
   - Cut `-8` `(%rbp)` ops each in `terrain` `fill` (`86 -> 78`) and `erode` (`108 -> 100`) and brought `terrain` to `16.709 s`, **but** failed 2/64 `native64` tests (`broad/coverage-record-aggregation-64` and `-256`).
   - **Outcome: REJECTED.** Narrowed `w12_fwd_s2l` to strictly same-register redundant reload dropping (`W12FwdDrop`, `r0 != rbp`), which passed **`64/64 native64`** and **`15/15` Observer Gate** cleanly.

---

## 3. Deliverables
- Patched compiler: [compiler_w12d.bend](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/compiler_w12d.bend)
- Unified patch vs `wave11_unified/compiler.bend`: [w12d_terrain_nbody.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/w12d_terrain_nbody.patch) (`339` lines)
- Structured receipts: [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12d_terrain_nbody/results.json)
- Hypothesis log: [wave12d-terrain-nbody.md](file:///home/ai/bend2_agy/experiments/agy/wave12d-terrain-nbody.md)
