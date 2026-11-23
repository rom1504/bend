# Wave 14-D: Pure-Bend `bend_build_real` Driving Real `n5_o2` Self-Compilation (`k14_wave13`)

**Status:** PASSED | **CPUs:** `4, 5, 6` (`--jobs 3`) | **Source:** [`bend_build_real.bend`](../../research/agy/w14_campaign/w14d_bend_build_real/bend_build_real.bend) | **Receipts:** [`results.json`](../../research/agy/w14_campaign/w14d_bend_build_real/results.json)

## Objective
Harden Wave 12-C's pure-Bend `bend_build_pipe` into `bend_build_real` (`ALL PROOFS CHECK`, `0` `@unsafe`) and verify it driving **real `n5_o2` self-compilation of all 14 modules (`k14_wave13`, `3.65 MB`, `65,180 / 65,532` FIDs)** with **0 Python, 0 JS, 0 C, and 0 `objcopy` at runtime**.

## Key Results
- **Purity & Binary:** `ALL PROOFS CHECK`, **`0` `@unsafe`** declarations, compiled to an **845 KB** (`845,408 B`) standalone native x86-64 ELF binary ([`bend_build_real`](../../research/agy/w14_campaign/w14d_bend_build_real/bend_build_real)).
- **New Capabilities:** 6-column prefix/footer manifest assembly on cache miss (zero temp files on hit), parallel `IO.fork` streaming 64 KiB dual-FNV-1a file hashing (`206 ms → 155 ms` across `3.65 MB`), pure-Bend `.p130` UTF-8 header stamp adoption (`--adopt-p130`), built-in `ulimit -s 262144`, `--trace x86-module-fast`, native `x86-merge-obj` (`m11` first!), and `gcc-10 -O2 -no-pie` link.
- **4-Scenario Real `n5_o2` Self-Compilation Verification (CPUs `4, 5, 6`, `--jobs 3`):**
  1. **Warm-`.p130` 3-Core Build (`--adopt-p130`):** `14/14` rebuilt in **`141.36 s`** (`iface=377 ms`, `compile=140,545 ms` / `sum=405,792 ms` = **`2.89×` on 3 cores**, `merge=64 ms`, `link=751 ms`), **`14/14` `.o` + `merge.o` 100% SHA-256 bit-identical** to W13-INT Stage 2A, `n6_bend_build` smoke **`out=34`**.
  2. **No-Op Rebuild:** `0/14` rebuilt in **`156 ms`** median (`162, 155, 156 ms`, full `3.65 MB` content-verified dual-FNV-1a across 3 cores; `base.bend` has no `mtime` stat primitive), `14/14` `.o` SHA-256 untouched.
  3. **Leaf Edit (`m11.bend`: `stage=read -> stage=read_w14d`):** **`1/14` rebuilt** in **`28.83 s`** (`m11.o=28.01 s`, `merge=55 ms`, `link=483 ms`), `13/14` `.o` SHA-256 untouched, `n6_bend_build` smoke **`out=34`** + `stage=read_w14d` observed.
  4. **Mid-Stack Body-Only Edit (`m06.bend`: `w10_if_suffix_set` body):** `m06.p130` rebuilt in `14.59 s` with **identical stamp** (`a49725d60e163c94`), **100% overlapped behind `m06.o` (`35.05 s`)**, downstream `m07..m11` all `[cache HIT]` in `0–1 ms` → **`1/14` rebuilt** in **`35.71 s`**, `13/14` `.o` SHA-256 untouched, `n6_bend_build` smoke **`out=34`**.

Full details in [`research/agy/w14_campaign/w14d_bend_build_real/REPORT.md`](../../research/agy/w14_campaign/w14d_bend_build_real/REPORT.md).
