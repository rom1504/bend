# L22-ORACLE-DIFF: 5-Way Oracle Soundness & Metamorphic Differential Audit

**Branch / Base Commit:** `selfhost/agy` @ `2f59e12ba76395352409166a02e324c23dca84c8` (Proven-21)  
**Pinned Upstream `bend2/` Commit:** `6180be5b21c4af6895395b27ad3cde026909364e` (`git diff upstream/main -- bend2/` = 0 lines)  
**CPU Pin:** All compilation, linking, and execution pinned to **CPU 4** (`taskset -c 4`)  
**Reproducible Artifacts:**
- Harness & Generator: [run_audit.py](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/run_audit.py)
- Structured Results: [results.json](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/results.json)
- Minimized Reproducers: [reproducers/](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/)

---

## 1. Executive Answer to the Central Question

> **Central Question:** *Can we find a small, well-typed program with fully defined, in-range operations where upstream JS (`6180be5b`), upstream C (`6180be5b`), `bend5k -O0`, or `bend5k -O2` (`2f59e12b`) computes the wrong value?*

**YES — with a sharp split between Upstream (`6180be5b`) and `bend5k` (`2f59e12b`):**

1. **Upstream JS (`6180be5b`) and Upstream C (`6180be5b`) on Group A (ordinary, well-typed, in-range programs): `185 / 185` (`100.0%`) EXACT MATCH against our independent Python Reference Oracle, and `22 / 22` (`100.0%`) on Group A metamorphic pairs.**
   - We found **0 wrong answers** in Upstream JS or Upstream C on ordinary, fully defined, in-range programs.
2. **`bend5k -O0` and `bend5k -O2` (`2f59e12b`) on Group A: `181 / 185` (`97.8%`) — we found 4 genuine, minimal, well-typed ordinary-program bugs in `bend5k`**, including **2 silent wrong-value miscompilations** (one as small as **3 lines**):
   - **`A_char_quote_ascii_plain.bend` (3 lines):** `IO.print(Char.quote(39, Chr{65}))` — Python Oracle, Upstream JS, and Upstream C all print **`A`** (`rc=0`). `bend5k -O0` **crashes** (`rc=1`, `bend: phase111: constructor arity mismatch`), while **`bend5k -O2` silently computes the WRONG VALUE (`""`, empty string, `rc=0`)!**
   - **`A_nat_peel_wide.bend` (10 lines):** `case 3n+rest: Nat.add(30n, rest)` on a valid in-range `Nat` `5000000003n` (`< 2^48-1`, built via `Nat.add(Nat.mul(5n, 1000000000n), 3n)`) — Python Oracle, Upstream JS, and Upstream C all print **`0,10,20,5000000030`**. **Both `bend5k -O0` and `bend5k -O2` silently compute the WRONG VALUE `0,10,20,705032734`** (`5000000030 mod 2^32`, 32-bit truncation in `Nat` pattern subtraction!).
   - **`A_str_quote_ascii_plain.bend` (3 lines):** `IO.print(String.quote("hello"))` — Python Oracle, Upstream JS, and Upstream C all print **`"hello"`** (`rc=0`). Both `bend5k -O0` and `bend5k -O2` **crash** (`rc=1`, `bend: phase111: constructor arity mismatch`).
   - **`A_hof_compose_and_apply_n.bend` (15 lines):** Typed `let` with arrow type `f : U32 -> U32 = x => ...` passes Upstream `--check-only` (`ALL PROOFS CHECK`) and prints **`27,31`** on Upstream JS & C, but is **falsely rejected** by `bend5k` (`expected '=' in let`).
   - *(Cross-reference, independent concurrent finding)*: `L22-ORACLE-HANDASM` (`97d4a043`, [hand_asm_opportunities_w22.md](file:///home/ai/bend2_agy/research/agy/bend5k/hand_asm_opportunities_w22.md#L195-L200) §5) additionally found a 5th ordinary-program `bend5k -O2` silent miscompilation in `$bor.*` borrowed-arg specialization on non-tail binary recursion (`k2_tree_prune_fold`: Upstream `bun` == `gcc -O2` == `bend5k -O0` = `703409789`, while `bend5k -O2` returns `571768773`).
3. **Group B (boundary & specification-edge probes, strictly separated, `27` cases): `21 / 27` all-4-agree, `6` divergences** — including **2 divergences INSIDE Upstream (`6180be5b`) itself**:
   - **Live Upstream `#2181` Metamorphic Divergence (`B_b2_nat_2p48_issue2181_match_lit.bend` vs `B_b2_nat_2p48_issue2181_match_sub.bend`):** On `pick(0n, 7, Nat.mul(16777216n, 16777216n))`, **Upstream C returns `7` (`rc=0`)** while Upstream JS, `bend5k -O0`, and `bend5k -O2` fail-stop (`rc=1`, `bend: a Nat past the largest immediate 2^48-1`). Replacing literal `0n` with `Nat.sub(5n, 5n)` makes **Upstream C fail-stop too** — proving Upstream C breaks metamorphic equivalence on `2^48` Nat overflow!
   - **Upstream JS vs Upstream C `F32.show` Divergence (`B_b1_f32_show_2097152_25.bend`):** `F32.show(2097152.25)` prints **`2097152.3`** on Upstream JS vs **`2097152.2`** on Upstream C / `bend5k`.
   - **Plus 4 `bend5k`-specific Group B divergences:** `F32.show(F32.pi())` prints 6 digits (`3.141593`) on `bend5k` vs 7 digits (`3.1415927`) on Upstream JS & C; `5000000000n` is rejected at parse time by Upstream but silently truncated mod `2^32` (`705032704`) by `bend5k`; and `Char.quote`/`String.quote` fail on control/Unicode escapes for the same root cause as Group A.

---

## 2. Methodology & Pinned 5-Way Oracle Setup

Every test case in `run_audit.py` is run on identical `.bend` source pinned to **CPU 4** (`taskset -c 4`):

| Oracle | Pinned Revision / Binary | Exact Invocation |
|---|---|---|
| **1. Independent Python Reference** | `run_audit.py` (pure Python 3) | Direct mathematical / operational evaluation in Python (never derived from any Bend backend) |
| **2. Upstream JS** | `bend2/main.ts` @ `6180be5b` + `node v24.22.1` | `taskset -c 4 bash research/agy/locked_bun.sh <src> -o <out.js> -o <out.c>` then `taskset -c 4 node <out.js>` |
| **3. Upstream C** | `bend2/main.ts` @ `6180be5b` + `gcc 10.2.1` | Same emitted `<out.c>`, stripping Clang-only `__attribute__((musttail)) ` (since `clang` is not installed on this host), compiled with `taskset -c 4 gcc -std=c11 -O2 <out_gcc.c> -lpthread -lm -o <bin>` and run on CPU 4 |
| **4. `bend5k -O0`** | `bend5k_o2` @ `2f59e12b` + `runtime-agy.o` | `taskset -c 4 bend5k_o2 -O0 <src> <obj.o>` + `gcc -no-pie <obj.o> runtime-agy.o -pthread -lm -o <exe>` + run |
| **5. `bend5k -O2`** | `bend5k_o2` @ `2f59e12b` + `runtime-agy.o` | `taskset -c 4 bend5k_o2 -O2 <src> <obj.o>` + link + run |

*Note on `musttail` stripping for Upstream C:* `bend2/comp.ts` emits Clang-only `__attribute__((musttail))` on `WL_JMP`/`WL_DYN`. Stripping that calling-convention attribute lets `gcc 10.2.1 -std=c11 -O2` compile the exact emitted C semantics for all bounded-depth audit programs (`0` stack overflows across all 212 cases). Every Group A case is verified well-typed by Upstream `bend2/main.ts` (`book_read` + `book_valid`), and all reproducers were independently checked with `locked_bun.sh --check-only`.

---

## 3. Group A Results — Ordinary, Well-Typed, In-Range Programs (`185` Cases)

### 3.1 Coverage by Program Family & Metamorphic Transformation

| Family | Cases | Upstream JS == Py | Upstream C == Py | `bend5k -O0` == Py | `bend5k -O2` == Py | Notes |
|---|---:|---:|---:|---:|---:|---|
| `u32_arith_inrange` | 25 | 25 / 25 | 25 / 25 | 25 / 25 | 25 / 25 | Includes bit-31 set (`>= 2^31`) unsigned ops & precedence |
| `nat_arith_inrange` | 20 | 20 / 20 | 20 / 20 | **19 / 20** | **19 / 20** | **`nat_peel_wide` silent 32-bit truncation in `bend5k`!** |
| `adt_nested_match` | 15 | 15 / 15 | 15 / 15 | 15 / 15 | 15 / 15 | Binary/ternary trees, AST eval, 8-ctor, 4-level match, borrowed trees |
| `multi_scrutinee_match` | 10 | 10 / 10 | 10 / 10 | 10 / 10 | 10 / 10 | 2/3-scrutinee decision trees, overlapping wildcards, `Tree x Tree` |
| `closures_hof` | 10 | 10 / 10 | 10 / 10 | **9 / 10** | **9 / 10** | **`hof_compose_and_apply_n` parse reject in `bend5k`!** |
| `recursion_tail_mutual` | 10 | 10 / 10 | 10 / 10 | 10 / 10 | 10 / 10 | Mutual-state parity, 3-way state machine, Ackermann, GCD, sort, 10k TCO |
| `linear_arrays` | 8 | 8 / 8 | 8 / 8 | 8 / 8 | 8 / 8 | `new`/`get`/`set`/`swap`/`size`/`clone`/`map`/`to_list`, `^d` vs `*n` |
| `strings_chars_bools` | 6 | 6 / 6 | 6 / 6 | **4 / 6** | **4 / 6** | **`char_quote_ascii_plain` & `str_quote_ascii_plain` fail in `bend5k`!** |
| `metamorphic_lit_vs_computed` (5 pairs) | 10 | 10 / 10 | 10 / 10 | 10 / 10 | 10 / 10 | `0n` vs `Nat.sub(k,k)`, `0` vs `U32.sub`, `True` vs `is_eq`, ADT tags |
| `metamorphic_helper_vs_inline` (3 pairs) | 6 | 6 / 6 | 6 / 6 | 6 / 6 | 6 / 6 | Helper call vs manually inlined body & 3-helper chains |
| `metamorphic_tail_vs_nontail` (4 pairs) | 8 | 8 / 8 | 8 / 8 | 8 / 8 | 8 / 8 | Sum of squares, `fact(11)`, list sum, `3^15` |
| `metamorphic_record_vs_unpacked` (2 pairs) | 4 | 4 / 4 | 4 / 4 | 4 / 4 | 4 / 4 | 4-field & 8-field single-ctor records vs unpacked args |
| `metamorphic_lut_vs_if` (2 pairs) | 4 | 4 / 4 | 4 / 4 | 4 / 4 | 4 / 4 | 16-way & 32-way dense `.rodata` LUT vs binary `if`-tree / formula |
| `metamorphic_unused_arg` (3 pairs) | 6 | 6 / 6 | 6 / 6 | 6 / 6 | 6 / 6 | Unused pure in-range `U32`, `Nat`, heap `Tree` vs eliminated |
| `metamorphic_adt_match_reuse` (3 pairs) | 6 | 6 / 6 | 6 / 6 | 6 / 6 | 6 / 6 | Nested vs shallow match, borrowed vs owned rebuild, 2-pass vs fused |
| `metamorphic_state_sweep` | 35 | 35 / 35 | 35 / 35 | 35 / 35 | 35 / 35 | 35 deterministic PRNG-seeded stateful ADT+U32 machines |
| **TOTAL GROUP A** | **185** | **185 / 185** | **185 / 185** | **181 / 185** | **181 / 185** | **22/22 metamorphic pairs agree across all 5 oracles** |

### 3.2 Detailed Analysis of Every Group A Disagreement

#### Group A Finding #1 — `A_char_quote_ascii_plain.bend` (`bend5k -O0` crash, `bend5k -O2` SILENT WRONG VALUE)
- **Minimized Reproducer** ([A_char_quote_ascii_plain.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/A_char_quote_ascii_plain.bend), 3 lines, `locked_bun.sh --check-only` -> `ALL PROOFS CHECK`):
  ```bend
  import Base

  def main() -> IO(Unit):
    IO.print(Char.quote(39, Chr{65}))
  ```
- **Independent Ground Truth (Hand Derivation of `bend2/base.bend:2631-2650`):**
  In `Char.quote(39, Chr{65})`, `x = 65` (ASCII `'A'`), `q = 39`. None of `x == 10, 9, 13, 0, 92, 39` hold, so `k = 0`, `plain = U32.is_zero(0) = True{}`, `raw = False{}`. `Char.quote.at(65, 0, True{}, False{})` takes `case True{} False{}: SCon{Chr{65}, SNil{}}`, which prints **`"A\n"`**.
- **Exact Backend Results (CPU 4):**
  - **Upstream JS (`6180be5b`):** `rc=0`, stdout=`"A\n"`, stderr=`""`
  - **Upstream C (`6180be5b`):** `rc=0`, stdout=`"A\n"`, stderr=`""`
  - **`bend5k -O0` (`2f59e12b`):** **`rc=1`**, stdout=`""`, stderr=`"bend: phase111: constructor arity mismatch\n"`
  - **`bend5k -O2` (`2f59e12b`):** **`rc=0`**, stdout=`"\n"` (**SILENT WRONG VALUE: empty string instead of `"A"`!**), stderr=`""`
- **BendTT Law:** `bend2/bendtt.lean` `theorem adequate : Claim.adequate` (`bendtt.lean:3860`) and `theorem confluent : Claim.confluent` (`bendtt.lean:1988`) uniquely fix the normal form of `Char.quote(39, Chr{65})` to `SCon{Chr{65}, SNil{}}`. Both `bend5k -O0` (runtime abort) and `bend5k -O2` (wrong value `SNil{}`) violate adequacy.

#### Group A Finding #2 — `A_nat_peel_wide.bend` (`bend5k -O0` and `-O2` SILENT WRONG VALUE: 32-bit `Nat` pattern truncation)
- **Minimized Reproducer** ([A_nat_peel_wide.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/A_nat_peel_wide.bend), 10 lines, `locked_bun.sh --check-only` -> `ALL PROOFS CHECK`):
  ```bend
  import Base

  def peel(n: Nat) -> Nat:
    match n:
      case 0n: 0n
      case 1n: 10n
      case 2n: 20n
      case 3n+rest: Nat.add(30n, rest)

  def main() -> IO(Unit):
    IO.print(Nat.show(peel(0n)) ++ "," ++ Nat.show(peel(1n)) ++ "," ++ Nat.show(peel(2n)) ++ "," ++ Nat.show(peel(Nat.add(Nat.mul(5n, 1000000000n), 3n))))
  ```
- **Independent Ground Truth (Python / Mathematical Peano `Nat`):**
  `5 * 1000000000 + 3 = 5000000003` (strictly in-range, `< 2^48 - 1 = 281474976710655`). Matching `case 3n+rest` binds `rest = 5000000000`, so `Nat.add(30n, rest) = 5000000030`. Expected output: **`"0,10,20,5000000030\n"`**.
- **Exact Backend Results (CPU 4):**
  - **Upstream JS (`6180be5b`):** `rc=0`, stdout=`"0,10,20,5000000030\n"`
  - **Upstream C (`6180be5b`):** `rc=0`, stdout=`"0,10,20,5000000030\n"`
  - **`bend5k -O0` (`2f59e12b`):** `rc=0`, stdout=`"0,10,20,705032734\n"` (**WRONG VALUE!** `5000000030 mod 2^32 = 705032734`)
  - **`bend5k -O2` (`2f59e12b`):** `rc=0`, stdout=`"0,10,20,705032734\n"` (**WRONG VALUE!**)
- **Root Cause:** `bend5k`'s `Nat` pattern subtraction (`case k+rest:`) truncates the wide 48-bit `Nat` value to 32 bits (likely emitting a 32-bit `subl` or `U32.sub` instead of 64-bit `Nat` subtraction).
- **BendTT Law:** `Claim.adequate` (`bendtt.lean:3860`) — `peel(5000000003n)` normalizes uniquely to `5000000030n`, which is well inside Bend's `2^48-1` immediate `Nat` contract.

#### Group A Finding #3 — `A_str_quote_ascii_plain.bend` (`bend5k -O0` & `-O2` runtime crash)
- **Minimized Reproducer** ([A_str_quote_ascii_plain.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/A_str_quote_ascii_plain.bend), 3 lines, `locked_bun.sh --check-only` -> `ALL PROOFS CHECK`):
  ```bend
  import Base

  def main() -> IO(Unit):
    IO.print(String.quote("hello"))
  ```
- **Independent Ground Truth:** `"\"hello\"\n"`.
- **Exact Backend Results (CPU 4):**
  - **Upstream JS (`6180be5b`):** `rc=0`, stdout=`"\"hello\"\n"`
  - **Upstream C (`6180be5b`):** `rc=0`, stdout=`"\"hello\"\n"`
  - **`bend5k -O0` & `-O2` (`2f59e12b`):** **`rc=1`**, stderr=`"bend: phase111: constructor arity mismatch\n"`

#### Group A Finding #4 — `A_hof_compose_and_apply_n.bend` (`bend5k` parser false reject on arrow-typed `let`)
- **Minimized Reproducer** ([A_hof_compose_and_apply_n.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/A_hof_compose_and_apply_n.bend), `locked_bun.sh --check-only` -> `ALL PROOFS CHECK`):
  Uses `f : U32 -> U32 = x => U32.add(U32.mul(2, x), 1)` inside `main`.
- **Exact Backend Results (CPU 4):**
  - **Python Oracle / Upstream JS / Upstream C:** `rc=0`, stdout=`"27,31\n"`
  - **`bend5k -O0` & `-O2`:** `rc=1`, stderr=`"expected '=' in let"` (compile-time parse error, not silent miscompilation).

#### Cross-Referenced Group A Finding #5 — Proven-21 `bend5k -O2` `$bor.*` Miscompilation
Independently discovered during Wave-22 (`L22-ORACLE-HANDASM`, commit `97d4a043`, [hand_asm_opportunities_w22.md](file:///home/ai/bend2_agy/research/agy/bend5k/hand_asm_opportunities_w22.md#L195-L200) §5): on a non-tail binary-recursive borrowed-ADT function with nested `Nat`/`Bool` dispatch (`k2_tree_prune_fold`), Upstream `bun`, `gcc -O2`, and `bend5k -O0` all produce `703409789`, whereas `bend5k -O2` miscompiles `$bor.range_sum` to return `0` on every call (`571768773`).

### 3.3 What Remains Uncovered in Group A
- Parallel `!` fork/join and GPU (`Metal`/`CUDA`) execution lanes (outside `bend5k`'s single-threaded fixed-runtime scope).
- Effectful `IO` primitives (`File`, `Tcp`, `Process`, `Window`, `Audio`, `IO.within`) — intentionally excluded from `runtime-agy.o`.
- In-range `F32` arithmetic chains (e.g., FMA contraction / subnormal rounding across JS `Math.fround` vs C `float` vs x86 SSE).
- Records/constructors with `> 255` fields or functions with `> 256` parameters (known fixed-ABI limits of `runtime-agy.o`).
- Dependent proof erasure in non-trivial indexed families (`Word(n)`, `Eq` transport, `Vec`) beyond `Base`.

---

## 4. Group B Results — Boundary & Specification-Edge Probes (`27` Cases, Strictly Separated)

Of `27` boundary probes, **`21 / 27` agree identically across all 4 backends** (including `U32` wraparound mod `2^32`, `U32.shln`/`shrn` for constant and dynamic shifts `>= 32`, `U32.div`/`mod` by `0` -> `(0, a)`, `Nat.sub` underflow -> `0`, `Nat.div`/`mod` by `0` -> `(0, a)`, `F32.to_u32` on negative/`Inf`/`NaN`/`2^32` -> `0`, IEEE-754 `-0.0` bits & equality, `NaN` comparisons, `F32.show` on `0.0`/`-0.0`/`0.1`/`16777216.0`/`+Inf`/`-Inf`/`NaN`/`1e-7`, and `Nat` `2^48` overflow for used `mul`/`add`/`double`/`Succ` and direct unused `ignore(e)`).

The **`6` Group B divergences** reveal **2 genuine upstream oracle limitations** and **4 `bend5k` boundary gaps**:

| # | Reproducer | Upstream JS (`6180be5b`) | Upstream C (`6180be5b`) | `bend5k -O0` (`2f59e12b`) | `bend5k -O2` (`2f59e12b`) | Specification / Root Cause |
|---|---|---|---|---|---|---|
| **B1** | [B_b1_f32_show_2097152_25.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b1_f32_show_2097152_25.bend) | `2097152.3` (`rc=0`) | `2097152.2` (`rc=0`) | `2097152.2` (`rc=0`) | `2097152.2` (`rc=0`) | **Upstream JS ≠ Upstream C!** `2097152.25` is exact in `binary32` (`0x4a000001`). At 7 sig figs, JS rounds half-away-from-zero (`.3`) while C `snprintf("%.7g")` rounds half-to-even (`.2`). **Spec open** in `base.bend` (`F32.show` is foreign/unproven). |
| **B2** | [B_b1_f32_show_pi.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b1_f32_show_pi.bend) | `3.1415927` (`rc=0`) | `3.1415927` (`rc=0`) | `3.141593` (`rc=0`) | `3.141593` (`rc=0`) | `bend5k` / `runtime-agy.o` formats `F32.show` with `%.6g` (6 sig figs) instead of Upstream's 7 sig figs (`%.7g`). |
| **B3** | [B_b2_nat_2p48_issue2181_match_lit.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b2_nat_2p48_issue2181_match_lit.bend) vs [B_b2_nat_2p48_issue2181_match_sub.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b2_nat_2p48_issue2181_match_sub.bend) | `rc=1` (both) | **`7` (`rc=0`) on `0n`**, `rc=1` on `Nat.sub(5n,5n)` | `rc=1` (both) | `rc=1` (both) | **Live Upstream `#2181`!** Upstream C specializes `pick(0n, 7, ...)` at compile time and drops unused `b`, returning `7`, while Upstream JS & `bend5k` fail-stop (`bend: a Nat past the largest immediate 2^48-1`). Violates upstream's own *"ONE law on every lane"* contract (`tests/run/nat_overflow.bend`) and breaks metamorphic equivalence inside Upstream C! In mathematical BendTT (`Claim.confluent`, `Claim.halts`), `Nat` is unbounded so both normalize to `7`; the `2^48-1` wall is a runtime limit outside BendTT. |
| **B4** | [B_b4_nat_literal_gt_u32max.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b4_nat_literal_gt_u32max.bend) | Parse reject (`rc=1`) | Parse reject (`rc=1`) | **`705032704` (`rc=0`)** | **`705032704` (`rc=0`)** | Upstream caps `Nat` literals at `4294967295n`. `bend5k` accepts `5000000000n` and silently truncates mod `2^32` (`705032704`)! |
| **B5** | [B_b6_string_escapes_and_unicode.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b6_string_escapes_and_unicode.bend) | `"a\tb\"c\\dé"\|8` | `"a\tb\"c\\dé"\|8` | `rc=1` (arity mismatch) | `rc=1` (arity mismatch) | Same `bend5k` `Char.quote`/`String.quote` bug as Group A #1/#3. |
| **B6** | [B_b6_char_quote_control.bend](file:///home/ai/bend2_agy/research/agy/bend5k/oracle_audit_w22/reproducers/B_b6_char_quote_control.bend) | `\0\|\n\|\'\|\\\|é` | `\0\|\n\|\'\|\\\|é` | `rc=1` (arity mismatch) | **`\|\|\|\|` (`rc=0`)** | Same `bend5k` `Char.quote` bug: `-O0` crashes, `-O2` silently returns empty strings! |

---

## 5. Actionable Oracle Trust Rule for `bend5k`

Based on our 212-case 5-way differential audit (185 Group A + 27 Group B):

1. **When Upstream JS & Upstream C (`6180be5b`) ARE a reliable oracle (High Confidence):**
   - For **ordinary, well-typed, in-range pure programs** (`U32`, `Nat < 2^48`, ADTs, multi-scrutinee matches, closures/HOFs, recursion, linear `Array`s, ASCII `String`/`Char`) that pass `locked_bun.sh --check-only` (`ALL PROOFS CHECK`), **Upstream JS and Upstream C agreed `185 / 185` (`100%`) with our independent Python Reference Oracle and `22 / 22` (`100%`) across metamorphic transformations**.
   - **Rule:** When Upstream JS and Upstream C both exit `0` and agree on an ordinary in-range program, treat their shared output as a high-confidence reference oracle for `bend5k -O0` and `bend5k -O2`.

2. **When you MUST NOT trust Upstream JS/C alone (Require an Independent 5th Oracle):**
   - **Whenever `Nat` values approach or cross `2^48 - 1` (especially in unused arguments or dead branches):** Upstream C (`6180be5b`) violates its own runtime overflow law and breaks metamorphic equivalence (`#2181`, `0n` vs `Nat.sub(k, k)`). Use Upstream JS + explicit boundary expectations, never Upstream C alone.
   - **Whenever `F32.show` formatting is compared as exact strings:** Upstream JS and Upstream C disagree on tie-breaking (`2097152.25` -> `.3` vs `.2`), and `runtime-agy.o` uses `%.6g` instead of `%.7g`. Compare `F32` results via `F32.bits(x)` (exact IEEE-754 `U32` bit pattern!) instead of `F32.show(x)` whenever testing float computation correctness.
   - **Whenever testing parser/checker acceptance boundaries (e.g., `Nat` literals `> 2^32 - 1`):** Always gate with `locked_bun.sh --check-only` (and `--verdict` for mathematical proofs in BendTT), because `bend5k` can silently accept and truncate inputs that upstream rejects.
   - **Whenever both `bend5k` and Upstream share an assumption (e.g., `base.bend` definitions or `F32.to_u32`):** Maintain a small independent Python reference oracle for algorithmic kernels so a shared bug cannot hide behind a 2-to-1 backend vote.

3. **Which Correctness Checks Will Catch the Next Meaningful Bugs in `bend5k`:**
   1. **Wide in-range `Nat` (`2^32 <= n < 2^48`) differential suite across EVERY `Nat` construct:** Our audit immediately caught `case k+rest:` 32-bit truncation (`A_nat_peel_wide.bend`) and `> 2^32-1` literal truncation (`B_b4_nat_literal_gt_u32max.bend`). Every `Nat` IR op, pattern match, and runtime helper should be tested with values in `[2^32, 2^47]`.
   2. **`Base` library self-execution sweep (`Char.quote`, `String.quote`, `U32.hex`, `F32.show.dot`, `Map.*`, `Array.*`):** Our audit caught a 3-line `Base` bug (`Char.quote(39, Chr{65})`) where `bend5k -O0` crashes and `bend5k -O2` silently returns `""` — missed by the 758-test conformance suite because no existing test exercised `Char.quote`/`String.quote` directly!
   3. **`bend5k -O0` vs `bend5k -O2` metamorphic & `$bor.*` non-tail recursion differential fuzzer:** Comparing `-O0` against `-O2` (and against an independent Python/C oracle) specifically on non-tail binary-recursive borrowed-ADT functions with nested `Nat`/`Bool` dispatch directly targets the `$bor.*` `-O2` miscompilation class (`L22-ORACLE-HANDASM` §5).
   4. **Strict `bend5k` parser conformance on typed `let` annotations (`x : A -> B = ...`) and `Nat` literal bounds (`<= 4294967295n`).**
