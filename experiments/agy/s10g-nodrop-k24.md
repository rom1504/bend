# Experiment S10-G: Compiler-Mode `--nodrop` Codegen Flag + Balanced `K=16`/`K=24` Zero-Tail Splitter

- **Status:** Delivered & Verified (CPUs `5, 7`, `/tmp/agy_s10g` cleaned)
- **Deliverables:**
  - [apply_s10g.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/apply_s10g.py) — idempotent pure-Bend `--nodrop` patch (self-contained in `m09`, 0 new types, `--check-only` PASS)
  - [split_kN_balanced.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py) — exact binary-search painter's partition acyclic splitter (`K=16` `1.020×`, `K=24` `1.005×`, emits `.exp` + `manifest.txt` + `manifest.json`)
  - [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/REPORT.md) & [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10g_nodrop_and_k24/results.json)
- **Key Results:**
  - `K=24` on `compiler_pruned.bend`: `135.3–137.6 KB` (`avg = 136.9 KB`, **`max/avg = 1.005×`**), `0` cycles, `0` lost/dup, ready for S10-A2 zero-`.p130` 8-core parallel compilation (3 balanced waves, eliminating `K=10`'s `639 KB` straggler).
  - `--nodrop` zero-regression gate: `3/3` normal modes (`slice_O0`, `slice_O2`, `histogram_O2`) **100% SHA-256 `.o` bit-identical** to `n6_o2`; `--nodrop` cuts `.o` size by `7–12.4%` (`k10_m09`: `7,669 -> 6,717 KB`, `0.876×`; `k24_m00`: `4,940 -> 4,456 KB`, `0.902×`) with peak RSS `< 370 MiB` (`<< 1.5 GiB` budget).
