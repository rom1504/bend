# Wave 11-D Promotion Gate Receipt: Native `n4_o2`

- **Date:** 2026-11-23
- **Compiler:** `selfhost/build/agy/wave11-native-mod/n4_o2` (`67,862,728 B`, native modular `-O2` self-reproduced)
- **Status:** **PROMOTED (PASS)** — ready for Wave 12 integration
- **Evidence:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11d_n4_gate/results.json)

## Gate Summary

1. **Native Qualification (`158/158 PASS`, CPUs `0..3`, `118.12 s` wall, `timeout 60`):**
   - `64/64 native64` (`x86-object-fast`, `-O0`): **64/64 PASS** (`24.95 s` wall, `89.30 s` compile sum)
   - `64/64 native64` (`x86-object`, `-O2`): **64/64 PASS** (`44.93 s` wall, `157.82 s` compile sum — `1.56x` faster than Wave 10 `n3_w10`)
   - `15/15` Live-Metadata Observer (`x86-object`, `-O2`): **15/15 PASS**, `0` violations (`17.03 s` wall)
   - `15/15` Live-Metadata Observer (`x86-object-fast`, `-O0`): **15/15 PASS**, `0` violations (`4.27 s` wall)
   - ELF Section Audit (`readelf -SW/-sW` on `compiler_slice.bend`, both modes): **PASS** (`p111_cid_hot` in `.data WA`, `p111_cid_arity` & `p111_cid_names_0` in `.rodata A`)

2. **7-Family Proxy Runtime Scorecard (`7/7` exact checksums, CPU `0`, 3-run median, `x86-object -O2`):**
   - **7-Family Geomean vs `gcc-10`:** **`1.3863x`** (vs Wave 8 `n1` `1.5613x` on same CPU `0` → **`0.8879x` W8**, and vs Wave 10 `n3_w10` `3.4391x` → **`0.2968x` W10**; vs Clang-16 ref: `1.7762x`)
   - Per-family (`n4_o2` / `gcc-10` / ratio): `histogram` `42.38 ms` / `23.09 ms` (`1.835x`), `gameoflife` `470.25 ms` / `964.59 ms` (`0.487x`, `2.87x` faster than W8), `nbody` `93.46 ms` / `91.06 ms` (`1.026x`), `list` `0.390 ms` / `0.269 ms` (`1.451x`), `expression` `9.14 ms` / `6.60 ms` (`1.384x`), `bst` `30.58 ms` / `13.25 ms` (`2.308x`), `editdist` `23.13 ms` / `10.00 ms` (`2.312x`).

3. **3-Holdout Runtime Scorecard (`3/3` exact stdout, CPU `0`, 3-run median vs `gcc-10 -O2`):**
   - `terrain`: **`21.731 s`** vs `8.294 s` (`2.620x`, `1.83x` faster than W8 `39.66 s`, recovered from W10 timeout; `70` direct syms)
   - `hashmap`: **`7.166 s`** vs `1.212 s` (`5.914x`, `2.13x` faster than W8 `15.27 s`, `2.69x` faster than W10 `19.27 s`; `26` direct syms)
   - `tree-radix`: **`11.699 s`** vs `6.451 s` (`1.814x`, `1.33x` faster than W8 `15.61 s`, `1.28x` faster than W10 `14.98 s`; `13` direct syms)
   - **3-Holdout Geomean vs `gcc-10 -O2`:** **`3.0403x`**

4. **Hygiene:** `/tmp/agy_w11d/` removed; `/dev/md2` free = `6.6 GiB` (`>= 5.0 GiB`); CPUs `4..7` and all read-only paths untouched.
