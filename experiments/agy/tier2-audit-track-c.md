# Tier-2 Adversarial & Conformance Audit: Wave 2 Track C

**Audit Target:**
- `AGY-W2-ROREC`: [apply_rorec.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/apply_rorec.py)
- `AGY-W2-DPLOOP`: [apply_dp_loop.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/apply_dp_loop.py)
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/test_tier2_adversarial.py)

## Overall Verdict: **FAIL (BLOCKED FOR TIER-3 INTEGRATION)**

- **`AGY-W2-DPLOOP` (`apply_dp_loop.py`)**: **PASS (CLEARED)** — Sound across static audit, all Hosted-B1 conformance suites, and all Tier-2 adversarial boundary tests.
- **`AGY-W2-ROREC` (`apply_rorec.py`)**: **FAIL (MISCOMPILATION BUG)** — Silent register clobbering (`%edx`) in `agy_ro_emit_bin` on nested right-hand-side binary expressions without recursive calls.

---

## 1. Miscompilation Found in `AGY-W2-ROREC`

### Root Cause
In [apply_rorec.py](file:///home/ai/bend2_agy/research/agy/wave2_editsym/apply_rorec.py#L398-L418), `agy_ro_emit_bin` checks only `agy_ro_expr_has_rec(right)` to decide whether to spill `left` onto the stack (`pushq %rbx; movl %eax, %ebx`) or keep `left` in scratch register `%edx` (`x188_reg(2, 32)`):

```bend
  nt_choose(X188Seq,agy_ro_expr_has_rec(right),
    u => ...,  # saves left in %rbx across right
    u => x188_many([
      agy_ro_emit_expr(left,rec_lbl,bail_lbl,tag ++ "l",inline_f0),
      x188_i2("movl",x188_reg(0,32),x188_reg(2,32)),
      agy_ro_emit_expr(right,rec_lbl,bail_lbl,tag ++ "r",inline_f0),
      agy_ro_emit_bin_op(op,2)]))
```

When `right` is a nested `RoBin` that does **not** contain a `RoRec` (e.g. `U32.sub(100, U32.add(x, 7))`, `U32.add(10, U32.add(2, 3))`, `U32.sub(100, U32.sub(v, 1))`, or `U32.add(eval(a, x), U32.mul(x, 5))`):
1. The outer `RoBin` evaluates `left` into `%eax` and saves it in `%edx`.
2. The inner `RoBin` (evaluating `right`) also sees `agy_ro_expr_has_rec(...) == False` and executes `movl %eax, %edx`, **overwriting the outer `left` operand in `%edx`**.
3. The outer `agy_ro_emit_bin_op(op, 2)` then combines the clobbered `%edx` with `%eax`, silently returning the wrong `U32`.

### Exact Reproducer (`rorec_nested_rhs_bin`)
Run `python3 -B research/agy/wave2_editsym/test_tier2_adversarial.py <api.mjs>`:
```text
[rorec_nested_rhs_bin] FAIL
  upstream : 172 102 96 328 542 | 30 168 214 74 24
  phase205 : 172 102 96 328 542 | 30 168 214 74 24
  track_c  : 4294967282 102 96 328 542 | 14 0 214 74 24
```
- `ELeaf{}: U32.sub(100, U32.add(x, 7))` for `x=5, 9`: expected `(100-12)+(100-16) = 172`, observed `(5-12)+(9-16) = -14 mod 2^32 = 4294967282`.
- `ELeaf{}: U32.add(10, U32.add(2, 3))` (×2): expected `15 + 15 = 30`, observed `(2+5) + (2+5) = 14`.
- `ELit{17}: U32.sub(100, U32.sub(v, 1))` (×2): expected `84 + 84 = 168`, observed `(16-16) + (16-16) = 0`.

### Required Fix
In `agy_ro_emit_bin` (`apply_rorec.py:401`), change the condition from `agy_ro_expr_has_rec(right)` to `String.eq(tg(right),"RoBin") || String.eq(tg(right),"RoRec")` (i.e., use the `%edx` shortcut **only** when `right` is a leaf `RoConst`/`RoParamX`/`RoField`, and save `left` in `%rbx` on the stack whenever `right` is `RoBin` or `RoRec`). Re-run `test_tier2_adversarial.py` after fixing.

---

## 2. Other Soundness Checks

### `AGY-W2-ROREC` (Other Invariants Verified Clean)
- **Shared root (`0x82`, `rc >= 2`) & reuse**: Decrements root `rc` by 1 only on `bail == 0`; `rc == 1` and `0x02` unique roots jump to `slow`. Verified intact via post-call non-certified observer `check_depth`.
- **Exact depth boundaries (`254, 255, 256, 257, 258`) + internal `0x82` bailout**: `rorec_depth_255_256_257_and_reuse` **PASS** (`518 520 522 524 526 1184` across upstream, Phase 205, and Track C).
- **ADT edge cases**: Swapped non-commutative `Sub(b, a)`, `U32.max` literal constants, default wildcard arm (`case _: 123456789` cleanly bailing to `slow`), dropped/duplicated fields, modified `x` (cleanly declined), and erased field `-tag: U32` (cleanly declined): `rorec_adt_edge_cases` **PASS** (`4294967282 4294967270 4294967293 11 14`).

### `AGY-W2-DPLOOP` (Verified Clean)
- **Bounds & `U32.max` overflow**: `n <= 0x7fffffff` and `j_u32 + n <= 0xffffffff` guarded before loop; `j + n <= b_size`, `j + n < prev_size`, `j + n < cur_size` checked via `ja`/`jae`. Tested `j = 4294967290, n = 10` and `j = 4294967295, n = 1`.
- **`U32.max` cell wraparound**: `min(left+1, min(up+1, diag+cost))` verified bit-exact with `min(min(up+1, left+1), diag+cost)` across `0`, `1`, `0xfffffffe`, `0xffffffff` in `prev`/`cur` and match/mismatch at indices `0` and `n-1`.
- **Aliasing & shared RFC arrays**: `Array<U32>` is linear (`Type`, not `Data`) in Bend, and the x86 preamble additionally guards `tag == 4` (rejecting any `0x84` RFC) and `cur != prev && cur != b`.
- `dploop_adversarial_tier2`: **PASS** (`1799972027 4159853956 1080340236 2935025486` across upstream, Phase 205, and Track C).

---

## 3. Hosted-B1 Conformance Results (Track C Combined API)

Built freshly from `unified/compiler.bend` + `apply_rorec.py` + `apply_dp_loop.py` via `stage0-library.mjs`:
- **`native64`**: **64 / 64 PASS** (110.68s)
- **`runtime10`**: **10 / 10 PASS** (9.79s)
- **`boundary13`**: **13 / 13 PASS** (9.66s)
- **Tier-2 Adversarial (`test_tier2_adversarial.py`)**: **3 / 4 PASS, 1 FAIL** (`rorec_nested_rhs_bin`)
