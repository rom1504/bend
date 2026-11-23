# Wave 15 Final Gate Receipt: Native `n6_o2`

- **Date:** 2026-11-23
- **Compiler:** `selfhost/build/agy/wave15-native-mod/n6_o2` (`76,923,256 B`, pure-Bend modular native `-O2`)
- **Status:** **FAIL / HOLD — BLOCKED ON `bst -O2` SIGSEGV**
- **Evidence:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w15_final/gate/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w15_final/gate/results.json)

## Gate Summary

1. **Gate 1 — Native Qualification (`158/158 PASS`, CPUs `0..6`, `67.04 s` wall):**
   - `64/64 native64 -O0` (`x86-object-fast`): **64/64 PASS** (`10.06 s` wall, `60.02 s` compile sum)
   - `64/64 native64 -O2` (`x86-object`): **64/64 PASS** (`31.91 s` wall, `162.82 s` compile sum)
   - `15/15` Observer Gate `-O2`: **15/15 PASS**, `0` violations (`11.02 s` wall)
   - `15/15` Observer Gate `-O0`: **15/15 PASS**, `0` violations (`2.78 s` wall)
   - ELF Section Audit (`readelf -SW/-sW` on `compiler_slice.bend` emitted `.o` both modes + `n6_o2` binary): **PASS**

2. **Gate 2 — Official 7-Family Scorecard (CPU `7`, 5-run median, `n6_o2 -O2` vs `gcc-10 -O2`):** **FAIL (`6/7` PASS, `1/7` FAIL)**
   - **`bst -O2` CRASHED (`rc=1`, `bend: memory fault`)** even on `1 rep, 0 warm` (`bst -O0` passes with `861157620`).
   - `gdb` root cause: `SIGSEGV` at `p113_rt_array_pair+217` called from `p117v_FID_$direct.collect` (`rbx=0x7fffffffaff0` stack pointer passed where tagged heap pointer expected).
   - Passing 6 families (`n6_o2` / `gcc-10` / ratio): `gameoflife` `436.11 ms` / `925.15 ms` (`0.4714×`), `expression` `8.45 ms` / `6.25 ms` (`1.3522×`), `list` `0.265 ms` / `0.264 ms` (`1.0061×`), `nbody` `94.74 ms` / `88.74 ms` (`1.0676×`), `histogram` `29.59 ms` / `23.86 ms` (`1.2401×`), `editdist` `20.63 ms` / `9.84 ms` (`2.0952×`). Incomplete 6-family geomean: `1.1008×`.
   - Note: `expression` (`1.3522×`) and `editdist` (`2.0952×`) did not show W14-A's `0.9434×` / `1.6210×` speedups.

3. **Gate 3 — Official 3-Holdout Scorecard (CPU `7`, 3-run median, `n6_o2 -O2` vs `gcc-10 -O2`):** **PASS (`3/3` exact stdout)**
   - `terrain`: **`12.3272 s`** vs `7.8668 s` (`1.5670× C`, **`1.7628×` faster than W11 `21.731 s`**)
   - `hashmap`: **`5.8135 s`** vs `1.1942 s` (`4.8681× C`, **`1.2326×` faster than W11 `7.166 s`**)
   - `tree-radix`: **`10.7071 s`** vs `5.3467 s` (`2.0026× C`, **`1.0926×` faster than W11 `11.699 s`**)
   - **3-Holdout Geomean vs `gcc-10 -O2`:** **`2.4813×`** (**`1.3340×` faster than W11**)

4. **Hygiene:** `/tmp/agy_w15_gate/` removed; `/dev/md2` free = `6.4 GiB` (`>= 5.5 GiB`).
