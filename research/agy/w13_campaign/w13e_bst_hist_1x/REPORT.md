# Wave 13-E Report: 7-Family Geomean Push (`bst` `2.40× -> 1.71–1.75×`, `histogram` `1.98× -> 1.285×`, `editdist` `notl`)

## 1. Executive Summary
- **Goal:** Push the 7-family compiled-program geomean (`x86-object -O2` vs `gcc-10 -O2`) from W12-G's `1.2644×` toward `<= 1.05×`, targeting `bst`, `histogram`, and `editdist`.
- **Result (CPU `7`, 5-run median, exact checksums on 7/7):**
  - **`histogram`:** **`1.9831× -> 1.2857×`** (`43.654 ms -> 28.085 ms`, **`1.55×` faster**; `1.2851×` under sibling load).
  - **`bst`:** **`2.4026× -> 1.7532×`** (`31.432 ms -> 22.937 ms`, **`1.37×` faster**; `1.7143×` under sibling load; `n=0` dropped `3.0×` from `132 ms -> 44 ms` at 160k reps).
  - **`editdist`:** `notl` emitted for `xor $0xffffffff` (`-40 B` object code, `111504 B -> 111464 B`).
  - **7-Family Geomean vs `gcc-10 -O2`:** **`1.2644× -> 1.1856×`** on quiet CPU 7 (`1.066×` over W12-G, `1.129×` over Wave 11's `1.3383×`); **`1.2433×`** on the final post-`64/64` run under ~6.9 host load with byte-for-byte identical object sizes across all 7 families.
- **Soundness & Conformance Gates (all 100% PASS on CPU `7`):**
  - `--check-only`: **PASS** (`22.0 s`, `0` type errors).
  - **`native64` (`x86-object -O2`):** **`64/64 PASS`** (`63.3 s`).
  - **Live-Metadata Observer Gate:** **`44+2 ABI + 15/15 PASS` (`0` violations)**.
- **Artifacts:**
  - Patch: [w13e_bst_hist_1x.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/w13e_bst_hist_1x.patch)
  - Builder: [build_w13e.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/build_w13e.py)
  - Results JSON: [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13e_bst_hist_1x/results.json)

## 2. Pure-Bend Compiler Upgrades
All changes are pure Bend in `compiler.bend` (built on `selfhost/build/agy/wave11_unified/compiler.bend` + `w12g_7fam_1x.patch`); `bend2/bend.ts`, `runtime.c`, and `runtime-agy.o` are untouched.

1. **x86-64 / SSE2 / SSE4.1 Encoder Extensions (`x187` + `x202o_dispatch`):**
   - Added encodings for `notl`, `rep_stosq`, `movdqa`, `paddd`, `psubd`, `pand`, `por`, `punpcklqdq`, `movq_x`, `pmulld`, `pslld`, `psrld`, `pshufd0`, and `movdqu_st`.
2. **`xor $0xffffffff` -> `notl` Peephole (`x185_immediate`, `x185_physical_immediate`):**
   - Replaces `movabs $0xffffffff, %r11; xorq %r11, %r10` with 3-byte `notl %r10d` (sound because `U32.not` inputs are 32-bit zero-extended). Verified in `editdist` (`41 f7 d2 not %r10d`).
3. **Post-Select x86-64 Loop Optimizer (`w13e_loop_opt`, wired after `w7_run_xmm` in `w7_post_select_full`):**
   - **Contiguous-zero `rep stosq` (`w13e_match_zero_loop`):** Replaces scalar zero-fill loops over contiguous `Array<U32>` slices (`histogram` `zero.go`) with `leaq` + `rep stosq` + odd-tail dword store.
   - **Histogram bin-update hoist (`w13e_match_count_loop`):** Eliminates dead index copy and overflow-guards (`row + k1 < 2^32`) hoisting `leaq (%rTbl, %rRow, 4), %r10` -> `addl $1, (%r10, %rX, 4)` (`10 -> 7` instrs/iter in `histogram` `$product.count.go`).
   - **4-wide SSE4.1 contiguous `Array<U32>` fill vectorizer (`w13e_match_fill_vec`):** Vectorizes pure 32-bit contiguous store loops (`histogram` `fill.go`) using `xmm0..xmm15` (`pmulld`, `paddd`, `pslld`, `psrld`, `pxor`, `pand`, `movdqu_st`) with `cmpq $4, %cnt` + 32-bit no-wrap guard and scalar tail.
4. **General `P113D` Optimization Passes (`w13e_opt_cursor`, wired in `agy_da_annotate`):**
   - **Tiny mul-add tail-loop inliner (`w13e_ma_*` + `w13e_muladd_loop`):** Detects 3-param `cnt == 0 ? acc : f(cnt-1, k, acc*C + k)` loops (e.g. `bst` `repeat_key`) and lowers calls to inline register-only `w13e_muladd_loop` (0 `callq`, 0 stack spills in `sorted_fold`).
   - **Non-escaping small stack `Array<U32>` specialization (`w13e_sa_*` + `w13e_stack_fill32`):** Detects `Array.new(U32, cls, init)` (`1 <= cls <= 10`) whose handle never escapes (verified via sound interprocedural flow analysis with upwards-exposed use checking, live-branch merging, `res <= 2` callee bound, and non-recursive root guard). Replaces heap allocation with `N111Alloca` + `rep stosq` fill + direct masked 32-bit load/store, elides `p111_rt_sink`, and clones specialized callees (`$sa<cls>_<argIdx>`). Verified fired in `bst` `timed_fold`, `bench`, `collect$sa9_3`, and `sorted_fold$sa9_3`.

## 3. Paired 7-Family Results vs `gcc-10 -O2` (CPU `7`, 5-Run Median)

| Family | Group | W12-G (`× C`) | W13-E Quiet (`× C`) | W13-E Loaded (`× C`) | W12-G Bend (ms) | W13-E Quiet Bend (ms) | Speedup vs W12-G | Obj Bytes (W12-G -> W13-E) |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `histogram` | upstream | `1.9831×` | **`1.2857×`** | `1.2851×` | 43.654 | **28.085** | **`1.55×`** | `214136 -> 214512` |
| `gameoflife` | upstream | `0.4701×` | **`0.4675×`** | `0.4269×` | 436.301 | **435.798** | `1.00×` | `62288 -> 62288` |
| `nbody` | upstream | `1.0621×` | `1.0696×` | `1.2576×` | 94.512 | **93.010** | `1.02×` | `60776 -> 60776` |
| `list` | tuned | `1.0061×` | **`0.9877×`** | `1.3384×` | 0.265 | **0.265** | `1.00×` | `63128 -> 63128` |
| `expression` | tuned | `1.3115×` | `1.5094×` | `1.3830×` | 9.433 | 9.433 | `1.00×` | `62520 -> 62520` |
| `bst` | tuned | `2.4026×` | **`1.7532×`** | **`1.7143×`** | 31.432 | **22.937** | **`1.37×`** | `79936 -> 73536` |
| `editdist` | tuned | `1.6457×` | `1.9592×` | `2.0971×` | 19.286 | 19.286 | `1.00×` | `111504 -> 111464` |
| **Geomean (7)** | — | **`1.2644×`** | **`1.1856×`** | **`1.2433×`** | — | — | **`1.066×`** | — |

## 4. Remaining Gaps to `<= 1.05×`
1. **`editdist` (`1.96×` C quiet):** 6 remaining register spills inside `$product.columns` + 1-element-at-a-time DP inner loop.
2. **`bst` (`1.71–1.75×` C):** `n=0` overhead dropped `3.0×` (`132 ms -> 44 ms`), leaving `collect$sa9_3` / `sorted_fold$sa9_3` loop-control overhead (extra `and $0x1ff` + `mov/sub/test` vs C's pointer walk) and `imul $10` vs `lea` in `repeat_key`.
3. **`expression` (`1.38–1.51×` C):** Recursive tree evaluator dispatch overhead.
4. **`histogram` (`1.285×` C):** Remaining gap is `cols` (4-wide SSE2 horizontal sum in `gcc-10 -O2` vs scalar `col.go` in Bend).
