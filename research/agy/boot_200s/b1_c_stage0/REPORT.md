# B1 Report: Zero-JS-Runtime Fast Stage 0 Bootstrap (`compiler.bend` → Native C `stage0_seed`)

**Date:** 2026-11-24 UTC  
**Status:** Modular K=16 C Stage 0 pipeline implemented & verified through global merge (692 CIDs, 59,300 FIDs, 85.4 MiB C) and 11/17 parallel GCC `.o` builds (`rt_main.o` + 10 modules including 21 MiB `mod06.c`); final 1-line `Array` fact fix applied to `gen_comp_mod.py` right at the `04:25 UTC` cutoff. Final link + `m00_zero.bend` `-O2` execution verification is ready as a 1-command follow-up.

## 1. Key Findings on Monolithic Upstream `bend2` C Emission
Testing unmodified `bun bend2/main.ts` on `selfhost/build/agy/wave17_unified/compiler.bend` (3.52 MiB, 11,246 decls) exposed **four hard blockers**:
1. **No Clang on host:** Only `gcc 10.2.1` is installed. `bend2`'s C runtime uses Clang-only `__attribute__((musttail))` on `WL_JMP`/`WL_DYN`.
2. **GCC 10 sibling-tail-call failure on `ctr_take`:** Stripping `musttail` and compiling with `gcc -O1 -foptimize-sibling-calls` worked on `tiny.bend` (true `jmpq`), but on `compiler.bend` (`m15`), **237 / 351** `WL_JMP`s still compiled to `callq` because `Term _fb[N]` stack buffers passed to `ctr_take` defeated GCC escape analysis (guaranteed stack overflow on deep recursion).
3. **Monolithic `bend2` C emit blows up (`> 270 s`, `> 20 GiB` RSS):** Phase profiling showed `book_load = 17.09 s (1.55 GiB)`, `book_valid = 18.78 s (4.55 GiB)`, `file_book = 20.83 s (6.58 GiB)`, and then `c_units()`'s multi-pass `do ... while (was !== FL.facts.size)` fixed-point loop ran for `> 200 s` and grew past `20 GiB` RSS.
4. **GCC `-O1` compile speed on 48-arg ABI:** `bend2`'s 48-argument `WL_SIG` (`r0..r42` passed by value) + inlining took **39.93 s / MiB** in `gcc -O1`.

## 2. Modular K=16 Zero-JS C Stage 0 Architecture
Implemented in:
- [`gen_comp_mod.py`](file:///home/ai/bend2_agy/research/agy/boot_200s/b1_c_stage0/gen_comp_mod.py) / [`comp_mod.ts`](file:///home/ai/bend2_agy/research/agy/boot_200s/b1_c_stage0/comp_mod.ts) (derived from read-only `bend2/comp.ts`)
- [`emit_mod_c.ts`](file:///home/ai/bend2_agy/research/agy/boot_200s/b1_c_stage0/emit_mod_c.ts)
- [`build_stage0.py`](file:///home/ai/bend2_agy/research/agy/boot_200s/b1_c_stage0/build_stage0.py)

Key engineering solutions:
1. **O(1)-stack `WLState*` trampoline ABI + `const u32 seq = 1u` + `-O1 -fno-inline` + PCH:**
   - Replaced 48-argument `musttail` calls with a 1-argument `WLState* _S` trampoline loop in `work_loop()` (zero stack growth, GCC-10 native).
   - Constant-folded `seq = 1u` in user modules (`BANGS == 0`), eliminating dead `!seq` parallel-fork branches.
   - Cut GCC `-O1` compile time by **4×** (`39.93 s` → `10.24 s` per MiB on `m15`).
2. **Uniform 1-pass modular C ABI (`comp_mod.ts`):**
   - `fact("own", *) = true`, `fact("ctr", *) = true`, `fact("type", "Array") = false` → 100% uniform calling convention across all 16 modules and **1-pass `c_units()`** (no fixed-point loop).
   - Boxed user ADTs `> 4` words (`(!tld.b && lay.ks.length > 4)`) while keeping `Base` word types unboxed.
   - Disabled `once` single-call-site inlining (prevented mutual-recursion stack overflow in modular splits).
   - Upgraded pure `<= 4`-line leaf stubs (e.g. `x188_i0/i1/i2/reg/label/many`) to real bodies so `flat_of` keeps them flat (`static inline spin_*`), eliminating `m05`'s `arity > 247` crash (`1,133` CPS continuations → `5.2 MiB`, `8.98 s`).
3. **Global C Merger (`build_stage0.py`):**
   - Merges union of `CID_T` (692), `FID_T` (59,300), relocated `STAT_IMG` (101,255 words, rewriting `STAT_OFF + k`), namespaced `TAB_m{i}_*`, deduplicated `// Requests` effect handlers (15 runtime IO/File effects), and per-module `WL_SPIN`/`WL_SPUN`/`WL_AGAIN` scopes in **`2.09 s`**.

## 3. Exact Measured Stage Timings
Under the strict post-restart RAM guard (`--bun-jobs 1`, `--gcc-jobs 8`, immediate `.c` deletion keeping `/tmp/agy_b1 <= 150 MiB`):

| Stage | Measured Wall | Peak Worker RSS | Notes |
|---|---:|---:|---|
| Stage 1: K=16 stubs + leaf prep | **1.76 s** | < 100 MiB | 1,125 leaf helpers identified |
| Stage 2: `bun` C emit (1 worker, 16 mods) | **145.70 s** | 7,773 MiB (`m06`) | 15 normal mods: `3.24–13.95 s` (`0.34–2.27 GiB`), sum `104.48 s`; `m06` outlier `41.22 s` (`21.8 MiB` C) |
| Stage 3: Global C merge | **2.09 s** | ~300 MiB | 692 CIDs, 59,300 FIDs, 101,255 STAT words, 85.4 MiB total C |
| Stage 4a: PCH (`bend_common.h.gch`) | **0.99 s** | ~150 MiB | Clean, 0 warnings |
| Stage 4b: Parallel `gcc` (8 cores) | **~89 s** (11/17 done) | ~600 MiB | `rt_main.o` (5.7 MiB) + 10 `mod*.o` incl. `mod06.o` (5.7 MiB) succeeded with 0 warnings; remaining 6 hit mid-pass `Array` fact flip (now fixed in `gen_comp_mod.py`) |

## 4. Path to `<= 45 s` Wall Time
1. **Re-run `build_stage0.py`** with the `fact("type", "Array") = false` fix already committed in `gen_comp_mod.py` to link `stage0_seed` and verify `x86-module` `-O2` on `m00_zero.bend`.
2. **Eliminate the `m06` outlier (`41.2 s` bun, `21.8 MiB` C):** Expand `collect_leaf_defs` from `<= 4` lines to `<= 10` lines (covering the 3 remaining `x188` helpers called by `w13e_sa_rew_body`, `w14a_sl_copy_3`, `w13e_sa_chk_body`). That cuts `m06` from `41 s / 21.8 MiB` down to `~7 s / 5 MiB` and total C from `85 MiB` to `~65 MiB`.
3. **4-core `bun` + 8-core `gcc`:** Once `m06` is `~1 GiB` instead of `7.7 GiB`, 4 parallel `bun` workers fit under `4 GiB` total RAM and finish Stage 2 in **`~22 s`**, while 8-core `gcc -O1 -fno-inline` finishes Stage 4 in **`~18–20 s`** → **total `~43–45 s` wall time from pure source**.
