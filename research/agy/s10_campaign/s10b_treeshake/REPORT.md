# S10-B Report: Deterministic Pure-Bend Compiler Tree-Shaker

## 1. Executive Summary
- **Goal:** Deterministically prune dead legacy CLI modes, constant feature flags, duplicate drivers, and unreachable defs/laws/types from `selfhost/build/agy/wave15_unified/compiler.bend` while preserving **all 7 native x86-64 CLI modes** (`x86-object`, `x86-object-fast`, `x86-module`, `x86-module-fast`, `x86-merge-obj`, `x86-iface`, `--trace`) and **0% `-O2` regression**.
- **Size & FID Reduction:**
  - **Lines:** `91,122 -> 80,477` (**`-10,645` lines, `-11.68%`**)
  - **Bytes:** `3,874,573 -> 3,408,937` (**`-465,636 B`, `-12.02%`**)
  - **Defs / Laws / Types:** `9,610 -> 9,162` defs (**`-448`, `-4.66%`**), `931 -> 891` laws (`-40`), `426 -> 415` types (`-11`)
  - **Total FIDs (`K=10` native self-compile):** `64,869 -> 61,822` (**`-3,047` FIDs, `-4.70%`**), expanding 16-bit FID headroom (`65,532 - total_segs`) from **`663` -> `3,710` (`5.6×` headroom!)**.
  - **`.p130` `x86-iface` sum (`m00..m08`):** `144.74 s -> 137.06 s` (**`-5.31%`**).
- **Soundness & Zero-Regression Verification:**
  - `--check-only` (`bend2/main.ts`, CPU `7`): **PASS** (`0` type/linearity errors across `8,946` `@unsafe` defs).
  - Native `K=10` self-compile (`n6_o2 -> n7_pruned` via `x86-iface` + `x86-module-fast` + `x86-merge-obj` + `gcc-10`): **PASS** (`n7_pruned` = `96,965,880 B`).
  - **`-O2` / `-O0` Bit-Identity Gate (`n6_o2` vs `n7_pruned`, CPU `5`):** **`7/7` benchmarks 100% SHA-256 `.o` BIT-IDENTICAL** (`compiler_slice -O0`, `compiler_slice -O2`, `gameoflife`, `histogram`, `bst`, `editdist`, `expression`), with exact runtime checksums (`34`, `3681094808`, `3307081914`).

## 2. What Was Pruned (and Fixpoint Analysis)
1. **Unified CLI Dispatch (`w8_dispatch_args`, `w8_tr_entry`, `x181_entry_args`):**
   - Removed dead legacy CLI modes: `--trace-slow` (`36` `ts_*` defs), text asm (`x181_print`), `x86-shard` (`agy_lpt_*`), 8-arg `x86-object` (`agy_parcg_*`), and duplicate non-streaming object/module cursor drivers.
   - Routed `x86-object`, `x86-object-fast`, `x86-module`, and `x86-module-fast` through the single unified streaming driver `w8_tr_run_obj(False{}, ...)`.
2. **Constant-Folding 55 `() -> Bool` Feature Flags (`53` `True{}`, `2` `False{}`):**
   - Inlined `106` flag calls and folded `24` `nt_choose(T, True{}/False{}, ...)` thunks, pruning dead fallback subtrees (e.g. `p185cc_*`).
3. **Transitive Reachability from `main` + Comment Stripping:**
   - Top pruned def prefixes: `agy` (64), `w10` (39), `ts` (36), `x187` (32), `x181` (18), `x186` (17), `x185` (15), `x190` (14), `x188` (13), `w10f` (11).
   - Pruned 11 dead types: `P111QDecimal`, `X187ObjectResult`, `X181StreamSlice`, `X187ElfLayout`, `AgyParCgReady`, `AgyLptPriv*`, `AgyLptPub*`, `W10IfLoad`.
4. **Why `-11.7%` is the Exact Semantics-Preserving Fixpoint:**
   - Call-graph audit of the remaining `9,162` defs confirmed every surviving subsystem (`w7` 11.3%, `agy` 8.4%, `f` parser 4.7%, `w5`/`w4c`/`w13e`/`w14a` `-O2` passes, `j` layout/validate, `w10`/`w14` `.p130` & `x86-merge-obj`) is actively reachable from the 7 required CLI modes. Routing `w8_tr_compile` from `p88_cache_prepare` to `w14_p88_cache_prepare` only disconnects 1 extra def (`p88_cache_prepare`) because `w14_p88_cache_prepare` retains a fallback to `p88_decode_admitted` for v1 carriers. Pushing to `-25–35%` would require dropping live `-O2` passes or live frontend/checker features, violating the zero-regression constraint.

## 3. Artifacts
- Tree-shaker: [treeshake_w15.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/treeshake_w15.py)
- Verifier: [verify_and_bench.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/verify_and_bench.py)
- Results JSON: [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/results.json)
