# Wave 13-E: 7-Family Geomean Push (`1.2644× -> 1.1856×` quiet / `1.2433×` loaded vs `gcc-10 -O2`)

- **Workspace & Artifacts:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/results.json), [w13e_bst_hist_1x.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/w13e_bst_hist_1x.patch)
- **Gates (CPU 7):** `--check-only` **PASS (`0` type errors, `22.0 s`)**, **`64/64 native64` PASS** (`63.3 s`), **`15/15` Observer Gate PASS (`44+2 ABI`, `0` violations)**.
- **7-Family Paired Geomean vs `gcc-10 -O2` (CPU 7, 5-run median, exact checksums on 7/7):**
  - **Quiet host (`load ~1`, identical `.o` byte sizes to final `64/64`-verified build):** **`1.2644× -> 1.1856×`** (`histogram` `1.983× -> 1.286×` **`1.55×` faster**, `bst` `2.403× -> 1.753×` **`1.37×` faster**, `gameoflife` `0.468×`, `list` `0.988×`, `nbody` `1.070×`, `expression` `1.509×`, `editdist` `1.959×`).
  - **Loaded host (`load ~6.9`, final post-`64/64` run):** **`1.2433×`** (`histogram` `1.285×`, `bst` `1.714×`, `gameoflife` `0.427×`, `expression` `1.383×`, `nbody` `1.258×`, `list` `1.338×`, `editdist` `2.097×`).

## Summary of Pure-Bend Upgrades
1. **x86-64 / SSE2 / SSE4.1 Encodings (`x187`, `x202o_dispatch`):** Added `notl`, `rep_stosq`, `movdqa`, `paddd`, `psubd`, `pand`, `por`, `punpcklqdq`, `movq_x`, `pmulld`, `pslld`, `psrld`, `pshufd0`, and `movdqu_st`.
2. **`editdist` `notl` (`x185_immediate`, `x185_physical_immediate`):** Replaced `movabs $0xffffffff; xorq` with 3-byte `notl` (`-40 B` object code).
3. **Post-Select x86-64 Loop Pass (`w13e_loop_opt`):**
   - Contiguous-zero `rep stosq` (`histogram` `zero.go`).
   - Overflow-guarded `leaq`/`addl` bin-update hoist (`10 -> 7` instrs/iter in `histogram` `count.go`).
   - 4-wide SSE4.1 vectorizer (`pmulld`/`paddd`/`pslld`/`psrld`/`pxor`/`pand`/`movdqu_st`) for pure 32-bit contiguous `Array<U32>` fill loops (`histogram` `fill.go`).
4. **General `P113D` Passes (`w13e_opt_cursor` in `agy_da_annotate`):**
   - Tiny 3-param mul-add tail-loop inliner (`w13e_ma_*` -> `w13e_muladd_loop`; eliminates `callq repeat_key` + spills in `bst` `sorted_fold`).
   - Non-escaping small stack `Array<U32>` specialization (`w13e_sa_*` -> `N111Alloca` + `rep stosq` + direct masked load/store + `p111_rt_sink` elision + callee cloning `$sa<cls>_<argIdx>`), guarded by sound upwards-exposed use checking, live-branch merging, `res <= 2` callee bound, and non-recursive root check. Drops `bst` `n=0` `3.0×` (`132 ms -> 44 ms`).
