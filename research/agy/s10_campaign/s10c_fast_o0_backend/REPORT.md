# S10-C: Pure-Bend Fast `-O0` Backend Optimizer (`x86-object-fast` & `x86-module-fast`)

**Status:** **100% Verified & Ready for Wave 16 Integration**  
**Patcher:** [`research/agy/s10_campaign/s10c_fast_o0_backend/apply_s10c.py`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10c_fast_o0_backend/apply_s10c.py) (idempotent on both `wave15_unified/compiler.bend` and `k10_wave15/m09.bend`; 100% self-contained in `m09`)  
**Evidence:** [`research/agy/s10_campaign/s10c_fast_o0_backend/results.json`](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10c_fast_o0_backend/results.json)

---

## Executive Summary

S10-C accelerates all four `-O0` backend stages (`x198pw_plan`, `x187_priv`, `x187_pub`, `x187_elf`) in pure Bend while leaving `-O2` (`x86-object` / `x86-module`) **100% bit-identical** (SHA-256 verified):

| Benchmark (`-O0`, 3-run median, CPU 3) | Stage | `n6_base` (ms) | `n6_s10c` (ms) | Speedup |
|---|---|---:|---:|---:|
| **`m09_exp` (`x86-module-fast`)** | `x198pw_plan` | 16,453 | **13,336** | **`1.23×`** |
| | `x187_priv` | 250 | **36** | **`6.94×`** |
| | `x187_pub` | 5,329 | **2,944** | **`1.81×`** |
| | `x187_elf` | 2,619 | **2,201** | **`1.19×`** |
| | **Backend Subtotal** | **24,649** | **18,387** | **`1.34×` (-6,262 ms)** |
| | **Total Compile** | 42,177 | **35,430** | **`1.19×` (-6,747 ms)** |
| | **Object Size** | 7.31 MB | **5.35 MB** | **`-26.9%`** |
| **`compiler_slice` (`x86-object-fast`)** | `x198pw_plan` | 801 | **800** | `1.00×` |
| | `x187_priv` | 249 | **59** | **`4.22×`** |
| | `x187_pub` | 132 | **75** | **`1.76×`** |
| | `x187_elf` | 274 | **172** | **`1.59×`** |
| | **Backend Subtotal** | **1,392** | **1,097** | **`1.27×` (-295 ms)** |
| | **Total Compile** | 6,371 | **5,852** | **`1.09×`** |
| | **Object Size** | 420.8 KB | **340.6 KB** | **`-19.1%`** |
| **`compiler_slice` (`x86-object -O2`)** | **SHA-256** | `08bebcba62f3771b` | `08bebcba62f3771b` | **100% BIT-IDENTICAL** |

*(Note: Both `n6_base` and `n6_s10c` were built identically with `m00..m08` at `-O0` and `m09` at `-O2` for a strict apples-to-apples A/B; absolute ms will drop further once all 10 modules are compiled at `-O2` in Wave 16.)*

---

## Architecture: Four Pure-Bend `-O0` Pillars

1. **Fused Direct-to-`X187Build` Private Function Emitter (`s10c_priv_emit_fast`, `4.22×`–`6.94×` faster):**
   - Handles all 5 `P113DStmt` forms (`P113DScalar`, `P113DIf`, `P113DCall`, `P113DResult`, `P113DAgain`) directly onto `X187Build` machine-code bytes without allocating `X188Seq` / `X187Parsed` / `w10f_output_fn` / `x187_encode` intermediates.
2. **Lean `-O0` Public Emitter (`s10c_pub_emit_fast` + `s10c_emit_scalar`, `1.76×`–`1.81×` faster, `-19%` to `-27%` smaller `.o`):**
   - Bypasses the `-O2` late transport/borrow/runtime-inlining AST rewrite (`x185_late_stmts`) in `-O0` for both public and private functions.
   - Emits 5-byte direct `call p111_rt_sink` / `call p111_rt_keep` (`w13c_emit_call_direct`) instead of pasting 150–152 bytes of inline fast-path template per call site (`w13c_emit_call_sink_keep`). Keeps 10-byte `w13c_emit_call_ctor0` and `w13c_call_is_special` intact.
3. **Stub-Aware + CPS-Pruned + O(1)-BangMap `-O0` Lowering (`s10c_plan_fast`, `1.23×` faster on `m09_exp`):**
   - Skips upstream `.p130` stubs in `p128br_scan`, `p113pl`, `p126sc`, `p113d_passes`, and `x187_priv` while preserving exact `$direct.*` + `p111_FID_*` ABI.
   - Uses O(1) hash-trie `bangMap` lookup in `s10c_p164a_allowed_fast`.
   - **Design findings from controlled A/B ablations (v1 -> v2 -> v3):**
     - **2-round dedup (`w6_dedup_round(ordered, 2)`) beats 1-round**: 1-round left +218 duplicate segments on `m09`, costing +360 ms in `x187_pub` and +160 KB in `.o` size.
     - **Keeping `p112s_prepare` beats skipping it**: Skipping `p112s_prepare` forced `p167l_loop` to dynamically lower large static `List<U32>` literals, adding +3.1 s to `x198pw_plan` on `m09_zero`.
4. **Fast 8×-Unrolled + Single-Pass Symbol ELF Finisher (`s10c_elf_finish_io`, `1.19×`–`1.59×` faster):**
   - 8×-unrolled byte reverse (`s10c_rev_u32`) and local branch fixup span (`s10c_x201f_span8`), zero redundant `x188_symbol_count` / `x201e_checked_size` scans, and single-pass symbol partition + single-hash ELF symtab/strtab emission.

---

## Verification Gates (Zero-Tolerance)

| Gate | Scope | Result |
|---|---|---|
| `locked_bun.sh --check-only` | Full `compiler_s10c.bend` (3.91 MB) | **PASS** (`0` type errors, `0` linearity errors; standard `9,388` `@unsafe` notice) |
| Idempotency | Re-applying `apply_s10c.py` to patched output | **PASS** (`ALREADY_APPLIED`) |
| `native64` Conformance (`x86-object-fast -O0`) | All 64 cases incl. 3 negative refusal tests | **`64/64 PASS`** (wall `27.82 s`, compile sum `78.84 s`, CPUs `2,3,4`) |
| Live-Metadata Observer Gate (`x86-object-fast -O0`) | 5 probes × 3 modes (`normal`, `cap-no8`, `all-hot`) | **`15/15 PASS`, `0` violations** (wall `4.67 s`, CPUs `2,3,4`) |
| `-O2` Non-Regression (`x86-object -O2`) | `compiler_slice.bend` | **PASS** (`SHA-256` bit-identical: `08bebcba62f3771b...`, `388,208 B`) |
| Disk Hygiene | `/dev/md2` after cleaning `/tmp/agy_s10c/` | **PASS** (`6.4 GiB` free, `>= 5.5 GiB` target) |
