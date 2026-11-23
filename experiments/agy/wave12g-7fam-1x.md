# Wave 12-G: 7-Family Compiled-Program Geomean Push (`1.3383× -> 1.2644× gcc-10 -O2`)

- **Workspace & Artifacts:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/results.json), [w12g_7fam_1x.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12g_7fam_1x/w12g_7fam_1x.patch)
- **Gates (CPU 7):** `--check-only` **PASS (`0` type errors)**, **`64/64 native64` PASS** (`61.6 s`), **`15/15` Observer Gate PASS (`0` violations)**.
- **7-Family Paired Geomean vs `gcc-10 -O2` (CPU 7, 5-run median):** **`1.3383× -> 1.2644×`** (`editdist` `2.255× -> 1.646×`, `gameoflife` `0.485× -> 0.470×`, `nbody` `1.081× -> 1.062×`, `list` `1.012× -> 1.006×`, `expression` `1.473× -> 1.312×`, `histogram` `1.887× -> 1.983×`, `bst` `2.312× -> 2.403×`).

## Summary of Pure-Bend Upgrades
1. Wired `w5_nat_match_chain` in `w4c_diamond_body` + fixed `G11` peephole for 2-label empty-`else` diamonds (`cmoveq`/`cmovneq`).
2. Expanded `X185Transient` to 6 caller-saved registers (adding `%rcx` when `body` has no variable shifts) and `w5c_post_joint_transient` to 10 slots (caller-saved `0..5` + non-header-live callee-saved `rbx, r13, r14, r15`), skipping dead-in-body `setup` locals and keeping 1-arm `cmov`s inside the same transient region (`-12` stack spills/iter in `editdist` `$product.columns`).
3. Relaxed `x190_j_allowed` for unused incoming ABI registers (`abi >= nt_count(params)`).
4. Generalized `G10`/`G10b` peephole to `addl`/`subl`/`addq`/`subq` and 2-dest copies (`-2` instrs/iter in `histogram` `$product.count.go`, `-2` instrs/iter in `editdist` decrement).

## Remaining Gaps to `<= 1.05×`
- **`bst` (`2.40×` C):** `collect` is `1.00×` C (`48 ms` vs `48 ms`); 100% of the gap is `Array.new(U32, 9n, 0)` + `p111_rt_sink` heap alloc/free vs C stack `uint32_t a[257]` (`rep stosq`), plus `callq repeat_key` in `sorted_fold`.
- **`histogram` (`1.98×` C):** `gcc-10 -O2` auto-vectorizes `fill` and `cols` with SSE2 (4-wide) and uses `rep stosq` for `zero`; Bend emits scalar x86-64.
- **`editdist` (`1.65×` C):** 6 remaining spills + 2× `movabs $0xffffffff; xor` (vs `xorl $-1` / `notl`).
