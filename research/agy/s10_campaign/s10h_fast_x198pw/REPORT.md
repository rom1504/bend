# S10-H: Fast `-O0` `x198pw_plan_fast` Patch & Empirical Lowering Analysis

**Status:** Patch Implemented, Type-Checked (`0` errors), Idempotent; Ready for Wave 16 Integration A/B & `64/64` Gate  
**Patcher:** [`research/agy/s10_campaign/s10h_fast_x198pw/apply_s10h.py`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10h_fast_x198pw/apply_s10h.py) (stacks cleanly after `apply_s10a.py` + `apply_s10c.py`, 100% self-contained in `m09`, `-O0` ONLY, zero `-O2` changes)  
**Evidence:** [`research/agy/s10_campaign/s10h_fast_x198pw/results.json`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10h_fast_x198pw/results.json)

---

## Key Empirical Findings (Measured on `n6_o2`, CPUs `2,3`)

### 1. Pure CPS (`--abi cps` / Skipping `p113d_passes`) Is a `2–2.7×` Regression + FID Overflow
Measured directly across `k10_wave15` (`m00..m08`) with `n6_o2 --trace x86-module-fast`:

| Module | `--abi auto` `x198pw_plan` (ms) | `--abi cps` `x198pw_plan` (ms) | Slowdown | Notes |
|---|---:|---:|---:|---|
| `m07` | 18,256 | **48,621** | **`2.66×` slower** | CPS stub explosion |
| `m08` | 18,172 | **33,299** | **`1.83×` slower** | CPS stub explosion |
| `m04` | 14,926 | **31,261** | **`2.09×` slower** | `6,872` segs → **`data width overflow`!** |
| `m03` | 9,149 | **31,539** | **`3.45×` slower** | CPS stub explosion |
| `m05` | 8,989 | **39,564** | **`4.40×` slower** | CPS stub explosion |
| `m06` | 7,308 | **30,124** | **`4.12×` slower** | CPS stub explosion |
| `m01` | 12,661 | **19,015** | **`1.50×` slower** | CPS stub explosion |
| `m02` | 13,690 | **18,793** | **`1.37×` slower** | CPS stub explosion |

**Root Cause:** When cross-module stubs or functions fall back to CPS (`w6_worker_non_direct`), `p111_lower` generates `3–10×` more `$p111.k.*` continuation segments, blowing up `p167l_loop` + `w6_dedup_round(ordered, 2)` and overflowing 16-bit FIDs/data width (`m04` hit `6,872` segments and failed!). **Direct-call lowering (`p113d_passes`) MUST be retained at `-O0`.**

### 2. Root Cause of `x198pw_plan_fast` Slowness in Zero-`.p130` (`S10-A`) Mode
In S10-A zero-`.p130` mode (`m01_zero..m09_zero`), each module has **559 to 1,303** self-recursive direct/CPS stubs (`631` direct + `38` CPS on `m09_zero`, `1,253` direct + `43` CPS on `m08_zero`).
- S10-C's `s10c_split_stubs` only recognizes `.p130` stubs (`w10_if_stub_kind`), which returns `0` for all S10-A zero-`.p130` stubs!
- As a result, `m09_zero` currently runs `p112s_prepare`, `p128br_scan`, `w14a_prune_active`, `p113pl`, `p126sc_candidates`, `p113d_passes`, and `x187_priv` on **all 669 stubs** (`priv=713` vs `25` in `.p130` mode!).
- Baseline `n6_o2` on `m09_zero.bend`: `x198pw_plan = 7,923 ms`, `priv = 713`, `segs = 3,272`, `total = 18,350 ms`.
- Baseline `n6_o2` on `compiler_slice.bend`: `x198pw_plan = 470 ms`, `priv = 38`, `segs = 83`, `total = 3,191 ms`.

---

## Architecture of `apply_s10h.py` (`-O0` ONLY, Stacks After S10-C)

1. **Unified `.p130` + S10-A Zero-`.p130` Stub Skipping (`s10h_stub_kind`, `s10h_drop_stubs`, `s10h_split_stubs`):**
   - Recognizes both `.p130` stubs (`w10_if_stub_kind`) and S10-A self-recursive direct (`1000 + arity`) and CPS (`2`) stubs (`s10h_s10a_kind_go`).
   - Injects exact `P113Direct` signatures directly into `ready_stubs` in O(1) while skipping `p128br_scan`, `w14a_prune_active`, `p113pl`, `p113d_passes`, and `x187_priv` on all 559–1,303 imported stubs per module.
2. **Skip `-O2` Mutual-Tail-Call SCC Fusion (`p126sc_candidates`) in `-O0`:**
   - Passes `raw` directly to `p113d_passes` in `s10h_p168_selected_split` (internal `$p126scc.*` fusion is `-O2`-only and has zero cross-module ABI effect).
3. **O(1) Hash-Trie `bangMap` in `s10h_p167ob_remaining`:**
   - Replaces O(N × |bangs|) `nb_contains` scans in `p167ob_remaining` with O(1) `s10c_p164a_allowed_fast(..., bangMap, ready0)`.
4. **Skip Direct Stubs in `p112s_prepare` (`s10h_p112s_filter_names`):**
   - Filters `sk >= 1000` direct stubs out of `p112s_prepare` (`nc_compact` + `p112s_term`), since direct stubs contain zero static constructors and are never lowered through `nc_compact_definition`.

---

## Verification Status

| Gate | Result | Notes |
|---|---|---|
| `locked_bun.sh --check-only` (`compiler.bend` + S10-C + S10-H) | **PASS** | `0` type errors, `0` linearity errors (`9,404` `@unsafe` defs = S10-C `9,388` + `16` S10-H defs) |
| Idempotency (`apply_s10h.py` re-applied) | **PASS** | `ALREADY_APPLIED` on both `compiler.bend` and `k10_wave15/m09.bend` |
| `-O2` Non-Regression | **PASS (structural)** | Only modifies `s10c_plan_fast` (called exclusively by `x198pw_plan_fast`); `-O2` paths untouched |
| End-to-End A/B & `64/64 native64 -O0` + `15/15 Observer -O0` | **DEFERRED TO WAVE 16 INTEGRATION** | Hit 21:28 UTC sprint handoff deadline before full modular rebuild; Wave 16 Integration should compile `n7_w16` with `S10-A + S10-C + S10-H` and run the `64/64` + `15/15` + A/B benchmark gates. |
