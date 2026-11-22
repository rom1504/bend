# Wave 2 Track D: Lexer & Record Aggregation Report

## Executive Summary

Track D investigated our 2,022 ms bucket (18.4% of the 10,997 ms fixed-work batch):
- **Lexer family** (`lexer`, `variation-lexer-6-17`, `variation-lexer-10-123` — 1,024 ms total, 1.68× C)
- **Record Aggregation & Serialized Row family** (`coverage-record-aggregation-256`, `coverage-record-aggregation-64`, `complete-generic-row32` — 998 ms total, 2.17–2.68× C)

We designed, implemented, and verified a **100% general, kernel-checked compiler pass (`p205v` + `W2D`)** combining:
1. **Extended `p205v` Scalar & Sound U32 Interval Specialization**: generalizes Phase 205's scalar specialization with sound unsigned 32-bit interval analysis (`mod`, `and`, no-wrap `add`), `Bool.and`/`Bool.or` folding, pure dead-`Let` elimination, `Sigma`/`Pair` closed-type support, and `Mat`-argument distribution.
2. **General `String` `foldl` Shortcut Deforestation (`W2D`)**: recognizes any 2-argument safe non-base `String` left-fold `F(s, st)` and pushes `F(_, st)` through `SNil`/`SCon`, linear `String`-continuation `Let` bindings, non-recursive `String` builders, and `Nat`-recursive tail-continuation `String` cons-builders `P(n, ..., rest)`.
3. **General Constructor-Loop Unboxing (`$c`) & Top-Level `Mat` Lifting**: when a fused `Nat` worker over `(SumType, Acc)` has a constructor-preserving self-recursive arm `C{h}` with invariant `Acc`, extracts an unboxed scalar inner loop `H$c(n, ..., h) -> FieldTy`; lifts closed/1-free-var residual `Mat` nodes to top-level `Def`s so `p113d` compiles the caller directly to x86 without `p111` trampoline closures.

Every synthesized helper and rewritten definition is mandatorily rechecked by Bend's kernel checker (`check_definition_body` + `ka_def` + `jl_checked_error`), with exact fallback to the original definition.

---

## Verified Benchmark Results (CPU-2 Alternating, 4 Rounds, `runtime-agy.o`)

Baseline: `/home/ai/bend2_agy/selfhost/build/agy/unified/api.mjs` + `runtime-agy.o`
Candidate: `/home/ai/bend2_agy/selfhost/build/agy/wave2_lexrec/api_lex.mjs` + `runtime-agy.o`

| Benchmark | Reps | Baseline (ms) | Candidate (ms) | Ratio (Cand/Base) | Est. Batch Savings |
|---|---:|---:|---:|---:|---:|
| `lexer` | 1,920 | 1,686.5 | 240.0 | **0.142×** (7.0× faster) | ~286 ms (333 → 47 ms) |
| `variation-lexer-6-17` | 8,192 | 2,206.5 | 278.5 | **0.126×** (7.9× faster) | ~312 ms (357 → 45 ms) |
| `variation-lexer-10-123` | 256 | 1,042.0 | 138.0 | **0.132×** (7.6× faster) | ~289 ms (333 → 44 ms) |
| **Geomean (3 lexer cases)** | — | — | — | **0.1335× (7.49× faster)** | **~887 ms saved** |

On the lexer family, direct x86 drops from **1.68× mature C** down to **~0.22× mature C** (over 4.5× faster than mature Bend C) via a general compiler pass with zero hardcoded lexer names or constants.

### Machine-Level Census (`bench_lex15/lexer.cand.o`)
- `p113d_FID_ $direct.line` (2,358 insns): **0 calls** to `lex`, `gen.at`, `ident`, `num`, `op`, `cls`, `step.at`, `salt`, or `p125_rt_ctor2` (zero `SCon` heap allocations!).
- `p113d_FID_ $direct.ident$w2d$lex$c` (80 insns): **0 calls** — pure register x86 loop.
- `p113d_FID_ $direct.num$w2d$lex$c` (83 insns): **0 calls** — pure register x86 loop.
- `p113d_FID_ $direct.$w2d$m2$Gap` (192 insns): direct x86 leaf helper for operator token dispatch.

---

## Root-Cause Diagnosis & Falsified Hypotheses (Record Aggregation & Row32)

### `coverage-record-aggregation-256` (352 ms, 2.27× C) & `coverage-record-aggregation-64` (334 ms, 2.17× C)
- **Disassembly diagnosis**: `Map.ins.go` (8,641 insns, `p111_FID`), `Map.seek.go` (4,400 insns, `p111_FID`), `Map.get.go` (4,235 insns, `p111_FID`), and `Map.put.go` (4,083 insns, `p111_FID`) are all compiled on the slow `p111` trampoline ABI (`p111_rt_jump`/`p111_rt_return`/`p111_rt_sink`, 664 `p111_rt_sink` relocations, 234 `p111_rt_apply`) because they are non-tail-recursive with two recursive call sites (`Map.lo`/`Map.hi` and `MNode`), which neither `p113d` nor single-continuation `p114r` admits. Moreover, every record executes three Patricia-tree walks (`Map.get` + `Map.seek` + `Map.put`).
- **Falsified hypothesis**: We tested fusing `p37.records` + `p37.aggregate` + the exact identity `U32.read(U32.show(x)) = Some{x}` via a source-level ceiling probe (`/tmp/recagg_fused_probe.bend`, 392 reps). Result: baseline **381 ms** vs fused **420 ms** (slower because `p37.fused` fell out of `p113d` TRMC into `p111`). This confirms that the intermediate list and `U32.show`/`U32.read` are negligible compared to the `p111` Patricia-tree `Map.*` walks. Closing the 686 ms record-aggregation gap requires extending `p114r` / direct-x86 lowering to multi-site non-tail-recursive functions (`Map.get.go`/`Map.seek.go`/`Map.put.go`/`Map.ins.go`) or adding a direct `Map` update/lookup path.

### `complete-generic-row32` (312 ms, 2.68× C)
- **Disassembly diagnosis**: `row.probe(32, 17)` executes only 32 DP iterations (`p117v_FID_ $product.row`), while `p88_row_output` serializes all four 128-element `Array<U32>`s (512 elements -> 1,078-char `String`) via `p114r_FID_ $direct.Array.to_list.go~0` (`p111_rt_special_test`/`p111_rt_special_take`) and `p114r_FID_ $direct.p88_row_numbers` (`p111_rt_frame` per element, calling `U32.show` + `String.append`), followed by `String.eq` on 1,078 characters.

---

## Verification & Safety Evidence

1. **`focused19` qualification suite** (`research/agy/wave2_lexrec/run_focused19.py`): **19/19 PASS** (all 16 execute cases match exact stdout/exitCode; all 3 negative admission cases properly rejected).
2. **Adversarial & boundary differential tests vs upstream Bend** (`research/agy/wave2_lexrec/test_w2d_adversarial.py`, 5/5 PASS):
   - `u32_interval_wrap`: `(4294967290 + (x % 10))` wrapping past `UINT32_MAX` — exact match (`807`).
   - `adjacent_and_zero`: zero-count builders (`0n`), adjacent same-class (`A+A`, `B+B`) and mixed-class (`A+B`, `B+A`) tokens, trailing open token without space, `0` and `4294967295` seeds — exact match (`2908539912`).
   - `observed_intermediate`: intermediate `String` used twice (`len_u32` + `sum_ch`) — linear `senv` guard preserves observed string, exact match (`840`).
   - `unicode_template_fold`: renamed independent fold/builder over Unicode template `"a#α#b#"` — proves zero hardcoded names, exact match (`200365276`).
   - `lexer_boundary_seeds`: real `lexer.bend` at `depth=0`, `seed=0`, `seed=4294967295`, `seed=4294967294` — exact match (`3644823610`).
3. **Non-regression check on `coverage-record-aggregation-64/256` and `complete-generic-row32`**: verified via `bench_compare.py` (byte-identical objects, zero regression).

---

## Composable Artifacts & Patcher Paths

- Pass implementation: `/home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend`
- Standalone composable patcher (applies cleanly on top of `/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend`):
  `/home/ai/bend2_agy/research/agy/wave2_lexrec/apply_lex_deforest.py`
  Usage: `python3 research/agy/wave2_lexrec/apply_lex_deforest.py <in_compiler.bend> <out_compiler.bend>`
- Verification scripts:
  - `/home/ai/bend2_agy/research/agy/wave2_lexrec/run_focused19.py`
  - `/home/ai/bend2_agy/research/agy/wave2_lexrec/test_w2d_adversarial.py`
- Built candidate API (for immediate composition/testing):
  `/home/ai/bend2_agy/selfhost/build/agy/wave2_lexrec/api_lex.mjs`
