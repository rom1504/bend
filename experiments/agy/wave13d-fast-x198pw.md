# Wave 13-D: Fast `x198pw_plan_fast` for `x86-module-fast` / `x86-object-fast` (`-O0`)

- **Date:** 2026-11-23
- **Patch:** [w13d_fast_x198pw.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13d_fast_x198pw/w13d_fast_x198pw.patch)
- **Full Report & Data:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13d_fast_x198pw/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13d_fast_x198pw/results.json)

## Summary

`x86-module-fast` and `x86-object-fast` (`-O0`) were running the full `-O2` `x198pw_plan` pipeline. Sub-stage profiling on CPU `2` identified `31–46%` of `x198pw_plan` spent in `-O2`-only passes (`p121f`/`p198e`/`p125p`/`$product.*` candidates, `w4p_adapt_functions`, `p169o_closed` inlining/folding/retry, `p167v_original`/`p118b_verify_functions`/`p167live_eligible`, `p169c_selected` cold tables, `p168j_registry` 6-round fusion, and 7 `x198pw_after` passes).

We implemented pure-Bend `x198pw_plan_fast` exclusively for `-O0` (`-O2` stays 100% untouched), preserving `p112s_prepare`, `p128br_scan`, `p113d_passes`, and `p167l_functions` (`w6_dedup_segments`) for exact cross-module `$direct.*` + `p111_FID_*` ABI parity with `x86-iface`:

- **`m05` (`x86-module-fast`, CPU 2):** `x198pw_plan` **`19,415 ms -> 10,582 ms` (`1.835×`, `-45.5%`)**, total compile **`62,769 ms -> 48,699 ms` (`1.289×`, `-22.4%`)**, `segs = 5,957 -> 5,957` (`0` delta), `524/524` exact `$direct.*` ABI match.
- **`m11` (`x86-module-fast`, CPU 2):** `x198pw_plan` **`11,263 ms -> 7,753 ms` (`1.453×`, `-31.2%`)**, total compile **`37,465 ms -> 33,052 ms` (`1.134×`, `-11.8%`)**, `segs = 3,549 -> 3,549` (`0` delta), `201/201` exact `$direct.*` ABI match.
- **All Gates PASS:** `0` type errors, **`64/64 native64` (`x86-object-fast`) PASS**, **`15/15` Observer Gate (`x86-object-fast`, `0` violations) PASS**, and real cross-module `B -> A` `-O0` (`x86-iface` + `x86-module-fast` + `x86-merge-obj`) **PASS (`163`)**.
