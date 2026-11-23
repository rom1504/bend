# S10-C: Fast `-O0` Backend Optimizer (`x86-object-fast` & `x86-module-fast`)

## Hypothesis
In Wave 15 `-O0` modular builds (`x86-module-fast`), the backend (`x198pw_plan` + `x187_priv` + `x187_pub` + `x187_elf`) accounts for ~60% of total compile time because:
1. Private functions still lower through text/AST intermediates (`X181Output` -> `w10f_output_fn`).
2. Public and private `-O0` emitters still execute the `-O2` late AST rewrite (`x185_late_stmts`) and expand `p111_rt_sink` / `p111_rt_keep` into 150–152 byte inline templates per call site, bloating `.text` and ELF serialization.
3. `x198pw_plan_fast` scans upstream `.p130` stubs in `p128br_scan`/`p113pl`/`p126sc`/`p113d_passes` and performs linear `bangs` scans.
4. ELF finalization performs redundant size/count passes and 1-byte-at-a-time reversals.

Eliminating these overheads strictly on the `-O0` path (`x86-object-fast` / `x86-module-fast`) should accelerate `-O0` backend compilation by ~1.25–1.35× and shrink `.o` size by ~20–27% with zero impact on `-O2` codegen.

## Implementation
- Self-contained, idempotent patcher: [`research/agy/s10_campaign/s10c_fast_o0_backend/apply_s10c.py`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10c_fast_o0_backend/apply_s10c.py) (applies cleanly to both `selfhost/build/agy/wave15_unified/compiler.bend` and `selfhost/build/agy/k10_wave15/m09.bend`).
- All new definitions live in `m09`: `s10c_priv_emit_fast`, `s10c_pub_emit_fast`, `s10c_emit_scalar`, `s10c_plan_fast`, and `s10c_elf_finish_io`.

## Rejected Sub-Hypotheses (Preserved)
1. **1-round segment dedup (`w6_dedup_round(ordered, 1)`)**: Rejected after A/B measurement on `m09_zero` and `m09_exp` showed +218–221 surviving duplicate segments, regressing `x187_pub` by +360 ms and bloating `.o` by +160 KB. Restored 2-round dedup.
2. **Skipping `p112s_prepare` in `-O0`**: Rejected after 3-run median A/B on `m09_zero` showed `x198pw_plan` regressed from `14,880 ms -> 17,978 ms` (`0.83×`) because unlifted static `List<U32>` literals forced `p167l_loop` to emit far more dynamic IR. Restored `p112s_prepare`.

## Exact Run Evidence
Full JSON: [`research/agy/s10_campaign/s10c_fast_o0_backend/results.json`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10c_fast_o0_backend/results.json)  
Detailed report: [`research/agy/s10_campaign/s10c_fast_o0_backend/REPORT.md`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10c_fast_o0_backend/REPORT.md)

- **Correctness Gates:**
  - `locked_bun.sh --check-only`: **PASS** (`0` type/linearity errors)
  - `native64` (`x86-object-fast -O0`): **`64/64 PASS`** (`27.82 s` wall, CPUs `2,3,4`)
  - Observer Gate (`x86-object-fast -O0`): **`15/15 PASS` (`0` violations)** (`4.67 s` wall, CPUs `2,3,4`)
  - `-O2` (`x86-object`): **SHA-256 bit-identical** (`08bebcba62f3771b...`, `388,208 B`)
- **3-Run Median A/B (CPU 3, `n6_base` vs `n6_s10c`):**
  - `m09_exp` (`x86-module-fast`): backend `24,649 -> 18,387 ms` (**`1.34×`**), total `42,177 -> 35,430 ms` (**`1.19×`**), `x198pw_plan` `1.23×`, `x187_priv` `6.94×`, `x187_pub` `1.81×`, `x187_elf` `1.19×`, `.o` size **`-26.9%`**.
  - `compiler_slice` (`x86-object-fast`): backend `1,392 -> 1,097 ms` (**`1.27×`**), total `6,371 -> 5,852 ms` (**`1.09×`**), `x187_priv` `4.22×`, `x187_pub` `1.76×`, `x187_elf` `1.59×`, `.o` size **`-19.1%`**.

## Promotion Decision
**PROMOTE** into Wave 16 Integration (`apply_s10c.py` is clean, idempotent, 100% localized to `m09`, and verified on all gates with zero `-O2` impact).
