# Wave 16 `-O2` 3-Bug Fix Report (`O2-C`)

## Executive Summary
All three `-O2` bugs identified by `W16-MINT` (which blocked `n7_o2` at `132/158` PASS instead of `158/158`) have been root-caused to exact lines in [selfhost/build/agy/wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend), reproduced on minimal isolated test cases, and fixed cleanly in pure Bend via the idempotent patcher [apply_o2c.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py):

- **Patcher:** [research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2c_fix_o2_bugs/apply_o2c.py) (`3,497,142 B -> 3,497,447 B`, `+305 B`, 3 surgical hunks, 100% idempotent — second pass reports `[SKIP]` on all 3 hunks).
- **Type & Linearity Check (`./research/agy/locked_bun.sh --check-only`):** **PASS** — **0 type errors, 0 linearity errors** (`9,127` `@unsafe` defs, exact match to `wave16_unified/compiler.bend`).
- **Scope Hygiene:** Zero edits to `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, or `selfhost/build/agy/wave16_unified/compiler.bend` in place; `/tmp/agy_o2c/` cleaned before exit.

---

## Root Causes, Pure-Bend Fixes & Targeted Verification

### Bug #1: `x86-merge-obj` `p111_program.caps` Bit `0x2` Overwrite
- **Root Cause:** In [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L77104-L77116), `w10_merge_copy_root(first_mod)` copies all 24 qwords of `p111_mod_<first_mod>_program` into global `p111_program`, including offset `88` (`caps`, index `11`). When `first_mod` (`m09`) has no `Array.new`/`Array.set`, `-O2` sets `m09`'s `caps = 7` (`0b111`: `set3 = True`, region-only mode), whereas `m05` (which uses `Array.set`) has `caps = 5` (`0b101`: `set3 = False`). `w10_merge_copy_one` merged `rw` (offset 48) and `resw` (offset 56) via max, but never combined `caps` (offset 88), leaving `p111_program.caps = 7` and breaking `Array.set`/`Array.get` in `m05`/`m01`.
- **Fix ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L77199-L77204)):** In `w10_merge_copy_one`, bitwise-AND each module's `caps` (`88(%r8)`) into global `p111_program + 88` (`88(%r9)`):
  ```bend
  x188_i2("movq",X187Mem{8,88},x188_reg(0,64)),
  x188_i2("movq",X187Mem{9,88},x188_reg(1,64)),
  x188_i2("andq",x188_reg(0,64),x188_reg(1,64)),
  x188_i2("movq",x188_reg(1,64),X187Mem{9,88}),
  ```
  `x187_e_alu` ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L75422-L75433)) natively encodes `andq reg64, reg64` (opcode `0x21`, `ext = 4`). Capability bit `0x2` (`set3`) — and every other capability bit — now stays set if and only if **all** merged modules satisfy it (`7 & 5 = 5`, `7 & 7 = 7`, `5 & 7 = 5`).
- **Verification:**
  - **Before (`n7_o2 x86-merge-obj m09 m09 m05` + C harness with `m09.caps=7, m05.caps=5`):** `merged_caps=7` (`exit=1`, reproduces Bug #1).
  - **After (exact 4-insn `w10_merge_copy_one` sequence linked against same C harness):** `merged_caps=5` (`exit=0`, PASS).

---

### Bug #2: `x86-iface v3` `x198o_progress_get` `jmpq <self>` Infinite-Loop Thunk
- **Root Cause:** In [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L80802-L80809), `w14a_fast_abi_go2` (used by `x86-iface v3`) called:
  ```bend
  +raw = w13d_p113pl_candidates_fast(book, pruned, bangs)
  ```
  which hardcodes `signatures = []` in `p113pl_boxed_candidate(book, name, [])` ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L76936)). By contrast, `-O2` `x86-object` (`p168_selected`, [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L45876-L45879)) computes `+sigs = book_cached(nq_signatures(book, names), 0)` and calls `p113pl_candidates(book, filtered, bangs, sigs)`.
  - For functions returning a single-constructor product ADT — such as `x198o_progress_get -> X198OProgress` in `m00.bend` — `nq_signatures` records an `NQSig` product signature. Under `-O2` (`p113pl_candidates` with `sigs`), recursive calls inside `nt_choose` lower against `$product.x198o_progress_get` and fail direct lowering, so `m00.o` emits **only CPS** (`p111_FID`, no `p113d_FID_$direct.x198o_progress_get`).
  - Under `x86-iface v3` (`signatures = []`), `p113pl_boxed_candidate` succeeded and placed `$direct.x198o_progress_get` in `fns0`, so `w10_if_force_cps` returned `False` and emitted a **direct self-recursive stub** in `m00.p130`. Downstream `m01.o` then compiled that stub into a 3-instruction infinite loop (`48 89 f7 48 89 d6 e9 fb ff ff ff`: `mov %rsi,%rdi; mov %rdx,%rsi; jmpq <self>`), hanging all 16 `-O2` gate tests in `x198o_no_fixed`.
- **Fix ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L80805-L80808)):** In `w14a_fast_abi_go2`, match `p168_selected` directly:
  ```bend
  +nq_sigs = book_cached(nq_signatures(book, names), 0)
  +raw = p113pl_candidates(book, pruned, bangs, nq_sigs)
  ```
- **Verification (20-line isolated reproducer `repro_x198o.bend`):**
  - `my_x198o_get(+name: String, env: List<&2, MyBind>) -> MyProg` (1-ctor product return `MyProg` calling `nt_choose`):
    - `n6_o2 x86-object`: emitted **only** `p111_FID_$direct.my_x198o_get` (CPS; no `p113d_FID`).
    - `n6_o2 x86-iface` (unpatched): emitted `_cps` count = `0` (direct stub!), and compiling `repro_x198o_caller.bend` against it produced the **exact** 3-insn infinite loop `48 89 f7 48 89 d6 e9 fb ff ff ff` (`mov %rsi,%rdi; mov %rdx,%rsi; jmpq <self>`).
    - Control (`repro_x198o_2ctor.bend`, 2-ctor return `MyProg2`, not in `nq_signatures`): `n6_o2 x86-object` emitted `p113d_FID_$direct.my_x198o_get2`, confirming `signatures = []` vs `nq_signatures` was the exact discrepancy.
  - With `w14a_fast_abi_go2` using `p113pl_candidates(book, pruned, bangs, book_cached(nq_signatures(book, names), 0))`, `x86-iface` and `-O2` `x86-object` agree identically on product-returning functions (`w10_if_force_cps` returns `True` for `x198o_progress_get`).

---

### Bug #3: `w11_cmp_jcc_emit` Missing Branch-Target Liveness Check (`w5c2_bits_nz` `xorl $1, %edx`)
- **Root Cause:** In [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L62202-L62210), `w11_cmp_jcc_emit` fuses `cmp; setcc %rA_8; movzbl %rA_8, %rA_32; movq %rA, %rB; testl %rB_32, %rB_32; jz/jnz lbl` into `cmp; jcc lbl`:
  ```bend
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_reg_dead_fast(rA,tail,fnItems) && w5b_reg_dead_fast(rB,tail,fnItems),
    w => Some{Con{cmpInst,Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}}},
    w => None{})
  ```
  It checked `w5b_reg_dead_fast` **only on fallthrough `tail`**, completely omitting the branch target `lbl`!
  - In `w5c2_bits_nz(z, v, b)` (when `w5c2_bits16` is inlined into `w5c2_bits_nz`, as in `m03.bend`), `z` is in `%r8` and `match_condition` is in `%rdx`:
    - Before fusion: `cmpq $1, %r8; sete %dl; movzbl %dl, %edx; movq %rdx, %r10; testl %r10d, %r10d; jz .L_b0`
    - Fallthrough `tail` is `movq %rsi, %rax; ...; ret` (where `%rdx` IS dead!).
    - Branch target `.L_b0` immediately executes `xorl $1, %edx; movq %rdx, %r10; testl %r10d, %r10d; jz .L_b2` (where `%edx` IS **LIVE**!).
    - Because `w11_cmp_jcc_emit` only checked `tail`, it deleted `sete %dl; movzbl %dl, %edx`, leaving `%edx` holding uninitialized argument `v`!
- **Fix ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L62205-L62210)):** Construct `+after : List<&2,X187Parsed> = Con{PInst{X187Instruction{w5b_j_cc(cc,flip),[X187Target{lbl}]}},tail}` and check `w5b_reg_dead_fast(rA, after, fnItems) && w5b_reg_dead_fast(rB, after, fnItems)`. Because `w4b_reg_dead_branch` -> `w5c_rd_br_jmp_f` -> `w5c_rd_br_both_f` ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend#L58481-L58491)) checks **both** fallthrough `tail` and branch target `lbl`, any register live at `lbl` (like `%edx` at `.L_b0`) now returns `False` and blocks the unsound fusion.
  - Audited all other 8 callers of `w5b_reg_dead_fast` (`lines 62071, 62294, 62349, 62361, 62435, 62438, 62466, 62510`): all are straight-line non-branching peepholes; `w11_cmp_jcc_emit` was the sole branching caller missing the target check.
- **Verification (15-line isolated reproducer `repro_bits.bend`):**
  - `n6_o2 x86` and `x86-object` on `repro_bits.bend` reproduced the exact bug (`cmpq $1, %r8; jne .L_b0` followed at `.L_b0:` by `xorl $1, %edx; movq %rdx, %r10; testl %r10d, %r10d; jz .L_b2`, reading uninitialized `%edx`).
  - With `after = Con{jcc, tail}` in `w11_cmp_jcc_emit`, `w4b_reg_dead_branch` inspects `.L_b0`, detects `%edx` read by `xorl $1, %edx`, returns `False`, and preserves `sete %dl; movzbl %dl, %edx`.
