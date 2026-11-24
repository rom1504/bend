# Wave 18 (`BOOT-200S`) Final Scorecard

**Date:** 2026-11-24 (`04:57 UTC`)  
**Status:** **`n9_o2` MINTED & SMOKE-PASSED (FULL RECLAMATION) — `m11` `x187_pub` Straggler & Qualification Pending Follow-Up (Hard Deadline Reached)**

---

## 1. Composition & Typecheck (`PASS`)

- **Composer:** [compose_w18.py](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/compose_w18.py)
- **Output:** [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave18_unified/compiler.bend) (`3,497,142 B → 3,541,794 B`, `+44,652 B`)
- **Patches Applied (8/8 cleanly):** `O2-C` + `O2-F` + `O2-A` (**3 safe hunks only**, `x191_frame_forward_large_call_cap` REMOVED) + `O2-D` + `O2-E` + `B2` + `B3` + `B4`.
- **`locked_bun.sh --check-only`:** **PASS (`0` type errors, `0` linearity errors, `9,210` `@unsafe` defs)**.
- **DFS Acyclic Balanced Splits (`--order dfs`):**
  - `selfhost/build/agy/wave18_unified/k16_wave18_dfs`: `max/avg = 1.004×` (`209.6–214.2 KB`), `422` types, `9,426` defs, `918` laws, `0` forward edges.
  - `selfhost/build/agy/wave18_unified/k10_wave18_dfs`: `max/avg = 1.020×` (`331.4–348.2 KB`), `0` forward edges.

---

## 2. Clean Full-Reclamation Bootstrap (`n9_o2`, NO `--nodrop`)

| Stage | Compiler | Target | Mode | Wall | Max RSS | Total FIDs | Binary Size | Smoke (`compiler_slice.bend`) |
|---|---|---|---|---:|---:|---:|---:|---|
| **Stage 0 (`n9_stage0`)** | `n7_o2` | `k10_wave18_dfs` | `x86-module-fast` (`-O0`) | **`57.78 s`** | `405.1 MiB` | **`37,580 / 65,532`** | `70.8 MB` | `-O0`: `7.31 s` (`34`), `-O2`: `11.99 s` (`34`) |
| **Stage 1 (`n9_o2`)** | `n9_stage0` | `k16_wave18_dfs` | `x86-module` (`-O2`) | `15/16` + `419.3 s` (`m11`) | `425.7 MiB` (`515.8 MiB` `m11`) | **`35,638 / 65,532`** | **`80.4 MB`** | **`-O0`: `4.32 s` (`34`)**, **`-O2`: `7.03 s` (`34`)** |

- **Direct Oracle Extracted:** `3,673` exact Wave 18 `-O2` direct symbols → [p113d_oracle_w18_o2.txt](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/p113d_oracle_w18_o2.txt).
- **Smoke Speedup vs `n8_o2`:** `compiler_slice.bend` `-O0` improved **`5.07 s → 4.32 s` (`1.17×`)** and `-O2` improved **`7.95 s → 7.03 s` (`1.13×`)**!

---

## 3. Official 8-Core Cold `-O2` Self-Compile on `n9_o2` (`k16_wave18_dfs`, Full Reclamation)

15 of 16 modules completed cleanly with **major stage speedups** over `n8_o2` (`k16_wave17` BFS):

| Metric | `n8_o2` (`k16` BFS, 16/16) | `n9_o2` (`k16` DFS, 15/16) | Delta |
|---|---:|---:|---|
| **`p86_plan` range** | `13.02 – 20.20 s` | **`9.45 – 12.80 s`** | **`~1.5×` faster (B4 + DFS)** |
| **`x198pw_plan` range** | `31.43 – 75.41 s` | **`29.81 – 62.93 s`** | **`-17%` max** |
| **`x187_priv` range** | `50.01 – 139.88 s` | `49.08 – 123.36 s` (`m02`: `207.6 s`) | Faster on 14/15; `m02` outlier |
| **`x187_pub` range** | `7.10 – 105.30 s` | **`27.67 – 53.66 s`** (`m11` straggler) | **2× tighter on 15/16** |
| **Total FIDs** | `42,284 / 65,532` | **`35,283 / 65,532`** | **`-16.6%` fewer FIDs** |
| **Max RSS (15/16)** | `412.6 MiB` | **`432.9 MiB`** | **`<= 450 MiB` budget** |
| **15-Module Median / CPU Sum** | `148.3 s` / `2,333.2 s` (16 mods) | **`141.1 s`** / `2,082.5 s` (15 mods) | On track for ~278 s without `m11` |

### Root Cause of `m11` Straggler (`TIMEOUT` at `360 s`)
- `m11` reached `x187_pub done=2000/2490` at `elapsed=357.6 s` (`p86=12.7 s`, `pw=51.1 s`, `priv=91.7 s`, `pub > 266 s` — **`5–10×` slower in `x187_pub`** than every other module's `27.7–53.7 s`).
- `k16_wave18_dfs` co-located `w13e_sa_rew_body` (`7,372 B`) and `w13e_sa_chk_body` (`6,329 B`) in `m11`, creating a single-module `x187_pub` tail bottleneck (~400 s).

---

## 4. Handoff / Ready-to-Run Follow-Up (Zero Re-Mint Needed!)

All intermediate `/tmp/agy_w18` artifacts have been cleaned (`/dev/md2` preserved `>= 5.3 GiB` free), and `n9_o2` is preserved hot at [n9_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave18-native-mod/n9_o2). Because promotion gates have not run yet, `n6_o2`, `n7_o2`, and `n8_o2` were all left untouched.

Ready-to-run commands for immediate qualification (~6 min total):
1. **Full Qualification (`158/158` + 7-family + `terrain`):** `python3 research/agy/boot_200s/w18_final/run_w18_gate.py all`
2. **B2 Cross-Module Contracts:** `python3 research/agy/boot_200s/b2_direct_fid/test_b2_contracts.py --compiler selfhost/build/agy/wave18-native-mod/n9_o2`
3. **Cold `-O2` (with `timeout_s=540`) & Cold `-O0`:** `python3 research/agy/boot_200s/w18_final/run_w18_mint_and_bench.py --stages 2`
