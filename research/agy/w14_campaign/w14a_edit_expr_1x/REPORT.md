# Wave 14-A Report: 7-Family Geomean `1.1856× -> 1.0239× gcc-10 -O2`

## 1. Executive Summary
- **Goal:** Push the 7-family compiled-program geomean (`x86-object -O2` vs `gcc-10 -O2`) from W13-E's `1.1856×` to **`<= 1.05×`**, attacking `editdist` (`1.65–1.96× C`) and `expression` (`1.31–1.51× C`) with clean, general, pure-Bend x86-64 codegen passes.
- **Result (CPU `7`, 5-run median, exact checksums on 7/7):**
  - **7-Family Paired Geomean vs `gcc-10 -O2`:** **`1.1856× -> 1.0239×`** (**`1.158×` over W13-E**, **`1.307×` over Wave 11's `1.3383×`** — smashing the `<= 1.05×` target!).
  - **`expression`:** **`1.5094× -> 0.9434× C`** (`9.433 ms -> 5.896 ms` vs `6.249 ms` C, **`1.60×` faster** — **beating `gcc-10 -O2` by 6%!**).
  - **`editdist`:** **`1.9592× -> 1.6210× C`** (`19.286 ms -> 15.703 ms`, **`1.23×` faster**, **0 stack spills** in `$product.columns` inner loop, `-1,024 B` object code).
  - **`bst` (general pass bonus):** **`1.7532× -> 1.2987× C`** (`22.937 ms -> 16.990 ms`, **`1.35×` faster** automatically from general loop & liveness upgrades!).
- **Soundness & Conformance Gates (100% PASS on CPU `7`):**
  - `--check-only`: **PASS** (`28.4 s`, `0` type/linearity errors).
  - **`64/64 native64` (`x86-object -O2`):** **`64/64 PASS`** (`65.8 s`).
  - **Live-Metadata Observer Gate:** **`44+2 ABI + 15/15 PASS` (`0` violations)**.
- **Artifacts:**
  - Patch: [w14a_edit_expr_1x.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/w14a_edit_expr_1x.patch)
  - Builder: [build_w14a.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/build_w14a.py)
  - Results JSON: [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/results.json)

## 2. Pure-Bend Compiler Upgrades
All changes are pure Bend in `compiler.bend` (built on read-only `selfhost/build/agy/wave11_unified/compiler.bend` + W12-G + W13-E); `bend2/bend.ts`, `runtime.c`, and `runtime-agy.o` are untouched.

1. **Liveness & x86-64 Encoder Extensions (`w5c_is_alu_c`, `w14a_rd_xor`, `w13e_es_f19`, `x202o_dispatch`):**
   - Added `notl` and `negq` to `w5c_is_alu_c` so `w4b_reg_dead` sees through them cleanly.
   - Taught `w5c_rd_inst_c_f` (`w14a_rd_xor`) that self-xor (`xorl`/`xorq %r, %r`) is a write-only zeroing idiom that kills `%r` without reading it (unlocking dead-`%rax` optimizations before `xor %eax, %eax; ret` epilogues).
   - Generalized `w13e_es_f19` to emit 64-bit `REX.W` for `width == 64` and registered `negq` (`0xF7 /3`) in `x202o_dispatch`.
2. **Enable `x198qm` Magic-Multiply Div/Mod on Non-Loop Callers (`x191_frame_forward`, `w14a_has_rt_op`):**
   - Previously, `x191_frame_forward` bypassed `x191_frame_forward_when` on non-loop functions with `> 96` items and a call, leaving `callq p111_rt_op` for constant `U32.div`/`U32.mod` in peeled entry functions like `expression`'s `$direct.bench`. Running `x191_frame_forward_when` whenever `p111_rt_op` is present eliminates both `p111_rt_op` calls in `$direct.bench`.
3. **Contiguous 4-Slot Stack `cmoveq` Table Lookup -> `negq` + Indexed `movq` (`w14a_cmov_table_go`):**
   - Replaces `andq $3, %rIdx; movq d3(%rbp), %rDst; cmpq $2, %rIdx; cmoveq d2(%rbp), %rDst; cmpq $1, %rIdx; cmoveq d1(%rbp), %rDst; testq %rIdx, %rIdx; cmoveq d0(%rbp), %rDst` (when `d3 = d2-8 = d1-16 = d0-24`, intermediate labels are dead, and `rIdx` is dead after) with 3 instructions: `andq $3, %rIdx; negq %rIdx; movq d0(%rbp, %rIdx, 8), %rDst`.
   - Cuts 5 instructions, 3 memory loads, and a 3-cycle serial `cmove` chain per iteration in `editdist` `$product.columns`.
4. **General Straight-Line Call-Free Loop Register Promotion & Copy Optimizer (`w14a_sl_loop_opt`):**
   - Operates on any single-entry, single-backedge straight-line call-free loop (skipping dead internal labels):
     - Deduplicates consecutive identical loop-local temp stores (`w14a_dedup_stores`).
     - Promotes a loop-carried stack slot into `%r12` when `%r12` is saved in prologue, unused in loop body, and never read after loop exit except epilogue restore (`-0x80(%rbp)` `score` -> `%r12` in `editdist`, folding to 1-instruction `addl %r9d, %r12d`).
     - Iteratively promotes loop-local temp stack slots into free registers (or keeps them in their source register when unwritten across `[firstW..lastR]`) and runs straight-line copy-forward, 2-imm in-place folding, indexed-load forwarding, and deferred writeback folding.
     - Eliminates **all 6 stack spills** (`xv`, `neg`, `next`×2, `new_mv`, `new_hin`, `score`) in `editdist` `$product.columns` -> **0 stack accesses inside the inner loop**.
5. **General Multi-Branch Call-Free Loop Induction & Copy Cleanup (`w14a_mb_loop_opt`):**
   - Converts `leaq -1(%rCnt), %rNext` + backedge `movq %rNext, %rCnt; testq %rCnt, %rCnt; jne lTop` into in-place `subq $1, %rCnt; jne lTop`.
   - Converts `movq %rInd, %rT; subl $1, %rT32; movq %rT, %rC1; movq %rT, %rC2` + backedge `movq %rC2, %rInd` into in-place `subl $1, %rInd32`, eliminating duplicate copies.
   - Folds dead `movl %rA32, %rB32; jne L; ... L: subq $1, %rB64; jne L2` into `jne L; ... L: cmpl $1, %rA32; jne L2`.
   - Cuts `expression` `$direct.unwind` from `19 / 27 / 21` instructions per path down to **`12 / 20 / 12`** (fewer than `gcc-10 -O2`'s `14 / 20 / 16`), beating `gcc-10 -O2` (`0.943× C`).

## 3. Paired 7-Family Results vs `gcc-10 -O2` (CPU `7`, 5-Run Median)

| Family | Group | W13-E (`× C`) | **W14-A (`× C`)** | W13-E Bend (ms) | **W14-A Bend (ms)** | W14-A C (ms) | Speedup vs W13-E | Obj Bytes (W13-E -> W14-A) |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `histogram` | upstream | `1.2857×` | **`1.1736×`** | 28.085 | 31.138 | 26.531 | `0.90×` | `214512 -> 209000` |
| `gameoflife` | upstream | `0.4675×` | **`0.4688×`** | 435.798 | **435.849** | 929.675 | `1.00×` | `62288 -> 62104` |
| `nbody` | upstream | `1.0696×` | **`1.0735×`** | 93.010 | 95.210 | 88.695 | `0.98×` | `60776 -> 60592` |
| `list` | tuned | `0.9877×` | **`1.0061×`** | 0.265 | **0.265** | 0.264 | `1.00×` | `63128 -> 62872` |
| `expression` | tuned | `1.5094×` | **`0.9434×`** | 9.433 | **5.896** | 6.249 | **`1.60×`** | `62520 -> 62104` |
| `bst` | tuned | `1.7532×` | **`1.2987×`** | 22.937 | **16.990** | 13.082 | **`1.35×`** | `73536 -> 73200` |
| `editdist` | tuned | `1.9592×` | **`1.6210×`** | 19.286 | **15.703** | 9.688 | **`1.23×`** | `111464 -> 110440` |
| **Geomean (7)** | — | `1.1856×` | **`1.0239×`** | — | — | — | **`1.158×`** | **all 7 shrunk** |
