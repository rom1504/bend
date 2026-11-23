# Wave 16 Final Mint, 8-Core Cold Self-Compile & Gate Report (`W16-MINT`)

## Executive Summary
- **Minted Binary:** [selfhost/build/agy/wave16-native-mod/n7_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave16-native-mod/n7_o2) (`79,054,424 B`, `63,354 / 65,532` FIDs, `merge = 127.8 ms`, `link = 456.2 ms`, 10/10 `-O2` pipelined `.p130` via `n6_o2` on `k10_wave16`, 0 stubs, 0 `objcopy`).
- **Smoke (`compiler_slice.bend`):**
  - `-O0` (`x86-object-fast`): **PASS** (`out = 34`, **`2,767.7 ms`**, `377,176 B`)
  - `-O2` (`x86-object`): **PASS** (`out = 34`, **`4,990.3 ms`**, `388,208 B`)
- **8-Core Zero-Cache Cold Compile (`n7_o2`, `K=10` `k10_wave16`, CPUs `0..7`, EMPTY `/tmp/agy_w16_cold/`):**
  - `gen_stubs`: **`0.91 s`** (`913.1 ms`)
  - **8-Core Compile Wall:** **`62.87 s`** (`62,871.6 ms`, `1-core CPU sum = 361.11 s`, `5.74×` 8-core scaling, `peak RSS = 540.7 MiB`, `total_segs = 64,660 / 65,532`)
  - **Projected E2E Wall (`K=10`, 1-pass exact FIDs):** **`~64.4 s`** (`0.91 s` stubs + `62.87 s` compile + `~0.6 s` merge/link) — **`1.74×` faster than Wave 15's `~112 s`**, and **reveals the exact remaining bottlenecks above `10.0 s` for Wave 17!**
- **Zero-Regression Gate (`run_w16_gate.py qual` on `n7_o2`):**
  - **`-O0` (`x86-object-fast`):** **`64/64` native64 PASS (`7.34 s` wall)** + **`15/15` Observer PASS (`1.22 s` wall)** = **`79/79` (`100%`) PASS**!
  - **ELF Section Audit:** **PASS** (`.text=71.4 MB AX`, `.rodata=200 KB A`, `.data=1.55 MB WA`, `.bss=1.15 MB WA`).
  - **`-O2` (`x86-object`):** **`53/64` native64 PASS**, **`0/15` Observer PASS** (all 11 broad + 5 Observer failures are `x187_priv` `-O2` hangs traced to a single `n6_o2` cross-module thunk bug in `x198o_progress_get`!). Total: **`132/158` PASS**.
  - Because `n7_o2` is `132/158` (not `158/158`), `n6_o2` was **kept hot** (not gzipped) per hygiene rules.

---

## Exact `--trace` Stage Breakdown (`n7_o2`, `K=10` Zero-`.p130`, CPUs `0..7`)
Note: `x187_priv_done` elapsed is measured from `t0`; true `x187_priv` = `priv_elapsed - (rd + pr + p86 + pw)`!

| Module | Wall (ms) | RSS (MiB) | Segs | `read` | `prep` | `p86_plan` | `x198pw_plan` | `x187_priv` (true) | `x187_pub` | `x187_elf` |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **`m00`** | `23,762` | `540.7` | `7,536` | `30` | `253` | `9,024` | `8,519` | `1,677` | `2,101` | `1,932` |
| **`m01`** | `28,786` | `462.4` | `6,899` | `30` | `253` | `11,851` | `10,094` | `1,315` | `3,072` | `1,964` |
| **`m02`** | `36,449` | `414.0` | `6,444` | `29` | `227` | `10,940` | `14,718` | `1,677` | `5,685` | `2,836` |
| **`m03`** | `43,140` | `454.1` | `5,314` | `40` | `233` | `12,140` | `22,103` | `2,095` | `4,208` | `2,115` |
| **`m04`** | `46,819` | `460.8` | `6,158` | `40` | `231` | `11,466` | `22,089` | `845` | `9,132` | `2,714` |
| **`m05`** | `37,756` | `406.8` | `6,700` | `41` | `233` | `10,126` | `15,859` | `221` | `8,145` | `2,795` |
| **`m06`** | `38,219` | `465.5` | `7,086` | `35` | `240` | `9,257` | `15,827` | `74` | `10,086` | `2,349` |
| **`m07`** | `35,479` | `415.7` | `7,104` | `39` | `234` | `9,849` | `14,237` | `99` | `7,922` | `2,753` |
| **`m08`** | `36,691` | `409.8` | `6,344` | `40` | `231` | `9,576` | `15,901` | `94` | `7,985` | `2,560` |
| **`m09`** | `34,013` | `391.0` | `5,075` | `38` | `233` | `8,814` | `15,245` | `48` | `7,297` | `2,128` |
| **1-Core Sum** | **`361,115`** | **max `540.7`** | **`64,660`** | **`362` (0.1%)** | **`2,366` (0.7%)** | **`103,043` (28.5%)** | **`154,592` (42.8%)** | **`8,145` (2.3%)** | **`65,633` (18.2%)** | **`24,146` (6.7%)** |

### Critical Wave 17 Targets (Exact Milliseconds Above `10.0 s`)
To break **`<= 10.0 s`** on 8 cores, total 1-core CPU sum must drop from **`361.1 s`** to **`<= 72 s`** (`5×` reduction):
1. **`x198pw_plan` = `154.6 s` (`42.8%`) — #1 KILLER!** `S10-H` skipped `p113d` direct-stub codegen (crushing `x187_priv` to `2.3%`!), **but `p111` CPS segment lowering + `p111_FID_*` stub emission still ran on all 2,600 stubs** (keeping `total_segs = 64,660 / 65,532`, blocking `K=16`/`K=24`!). Skipping stub `p111` lowering completely will simultaneously cut `x198pw_plan`, `x187_pub`, `x187_elf`, AND halve `total_segs` so `K=16`/`K=24` fit with `>30,000` FID headroom!
2. **`p86_plan` = `103.0 s` (`28.5%`) — #2 KILLER!** Every module re-parses `types.bend` (`~58 KB`) + `2,600` stubs (`~120 KB`) + its own `336 KB` body in `p86_plan`. Pre-compiled/shared `types.p130` or binary stub header + faster `S10-E` lexer/parser directly attacks this `103 s`.
3. **`x187_pub` = `65.6 s` (`18.2%`) + `x187_elf` = `24.1 s` (`6.7%`) — #3 KILLER!** Directly proportional to `total_segs` (`64,660`, of which `~50%` are duplicated Base + S10-A stubs!). Eliminating stub `p111` segments + Base segment deduplication cuts both `x187_pub` and `x187_elf` by `~2–3×`.

---

## Exact Root Causes Found During Minting (Actionable for Wave 17)
1. **Merged `p111_program.caps` Bit `0x2` Bug in `x86-merge-obj`:** When entry module `m09` has no `Array.new`/`Array.set` (unlike `m05`), `-O2` sets `m09`'s `caps = 7` (`set3 = True`, region-only mode) instead of `5`. `w10_merge_copy_root` copied `m09`'s `caps = 7` into global `p111_program`, breaking `Array.set`/`Array.get` in `m05`/`m01`. Patching `p111_mod_m09_program+88` from `7 -> 5` fixed it immediately; Wave 17 should clear bit `0x2` in `w10_merge_copy_root` (or AND `caps` across modules).
2. **`n6_o2` Cross-Module `-O2` Codegen Bugs (Only Triggered by `k10_wave16` Split):**
   - `w5c2_bits_nz` (`m03` vs `p113k_bits` in `m04`): `n6_o2` emitted `xor $1, %edx` instead of `%r8d` (patched 9 bytes in `n7_o2`, fixing `-O2` `compiler_slice.bend`).
   - `x198o_progress_get` (`0x131616c`): `n6_o2` emitted a broken 2-arg thunk `mov %rsi,%rdi; mov %rdx,%rsi; jmpq <self>` (`e9 fb ff ff ff`), causing the 11 broad + 5 Observer `-O2` hangs in `x198o_no_fixed`.
3. **`S10-H` Direct-Stub vs `p111` Wrapper Link Mismatch:** `s10h_split_stubs` skipped emitting `p113d_FID_$direct.<stub>` while `p111` still emitted `p111_FID_$direct.<stub>` referencing `p113d_FID_$direct.<stub>`. Skipping stub `p111` segments completely (Finding #1 above) fixes this structurally AND unlocks `K=16`/`K=24`!
