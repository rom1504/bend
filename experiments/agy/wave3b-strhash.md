# Wave 3B Track B2: Native x86-64 String/Hash/Tag Killer (`AGY-W3B-STRHASH`)

## Summary
Implemented a composable compiler patcher [`apply_strhash.py`](file:///home/ai/bend2_agy/research/agy/wave3b_strhash/apply_strhash.py) transforming `selfhost/build/agy/wave2_unified/compiler.bend` → `selfhost/build/agy/wave3b_strhash/compiler.bend` and compiled `selfhost/build/agy/wave3b_strhash/api.mjs` (total build dir `8.7 MiB < 40 MiB`).

### What Was Built
1. **Source-Level `String.eq → p88_string_eq` Rewrite (Track S1 Composition)**:
   - Rewrote all **2,082** real `String.eq(` call sites in `compiler.bend` (outside string literals and comments) to `p88_string_eq(`, routing them away from `Base.String.order.go` directly into our native x86-64 string equality path.
2. **Dual-Seed 64-Bit AST Certification (`agy_sh_annotate`, `AGY-W2-BASEPIN` Discipline)**:
   - Checks exact `String` (`SNil/0`, `SCon/2`), `Char` (`Chr/1`), `Bool` (`False/0`, `True/0`), and `KTerm` (`KTerm/8`, `KLambda/8`, `KLiteral/5`) ADT layouts.
   - Verifies dual-seed 64-bit structural AST fingerprints (`2166136261`, `33554467`) for `Char.is_eq`, `Char.to_u32`, `p88_string_eq_go`, `p98_eq_finish`, `p88_string_eq`, `String.eq`, `String.order`, `String.order.go`, `index_hash`, `p98_tag_eq_read`, `p98_tag_eq_finish`, and `p98_tag_eq`.
   - Any redefined `String`, `Char`, `KTerm`, or custom function body cleanly declines fast-path emission (verified by `redefined_body_pin_decline`).
3. **Native x86-64 Register Loops in `x181_direct`**:
   - Guards every entry with `capabilities & 9 == 9` and `!cid_hot[*]` (verified 0 observer violations via `cid_hot_shim.c` forcing all `cid_hot[i] = 1`).
   - Supports static strings (`loc < HEAP_OFF`), heap `TAG_CTR` (`0x02`), refcounted `RFC|TAG_CTR` (`0x82`), unboxed `TAG_NUM` / `TAG_PAK` / boxed `Chr`, pointer-equality short-circuit (`a == b` on WHNF `SCon`), and transparent fallback to original `__sh_slow` on thunks/lazy strings or non-standard tags.
   - Covers `$p118borrow.read.*` (read-only, zero-sink; zero-stack leaf loop for `index_hash`), `$p128borrow.owned.*`, and `$direct.*` (with guarded `p111_rt_sink` for owned args) for:
     - `p88_string_eq_go`
     - `p88_string_eq`
     - `String.eq`
     - `index_hash`
     - `p98_tag_eq` / `p98_tag_eq_read`

## Verification Results (`verify_strhash.py`)
- **Adversarial 3-way diff (`upstream == wave2_unified == wave3b_strhash == cid_hot_observer`)**:
  - `edge_cases`: **PASS** (`2166138990`, `__sh_slow` wrappers emitted)
  - `lazy_thunk_strings`: **PASS** (`31`, lazy `SCon` tails cleanly bail to `__sh_slow`)
  - `redefined_body_pin_decline`: **PASS** (`299566379`, custom `index_hash`/`p88_string_eq` declined)
  - **`cid_hot` observer shim** (all `cid_hot[i] = 1`): **0 observer violations** across all 3 suites
- **Conformance (`focused19`)**: **19/19 PASS**

## Proxy Benchmarks (Median of 5 Runs, Bit-Exact Output)
| Benchmark | `wave2_unified` | `wave3b_strhash` | Speedup | Output |
|---|---:|---:|---:|---|
| `direct_bench.bend` (1.0M calls: `p88_string_eq` + `index_hash`, 80-char strings) | 962.60 ms | 918.00 ms | **1.05x** | `2971199589` (exact) |
| `bench_strhash.bend` (1.5M calls, 15 ops/iter via `BenchData`) | 659.14 ms | 679.63 ms | 0.97x | `392033600` (exact) |
| `bench/runtime/lexer/main.bend` | 3381.61 ms | 3317.53 ms | **1.02x** | `2401049475` (exact) |

### Diagnostic Note for Follow-Up
In `direct_bench.bend` and `bench_strhash.bend`, `__sh_slow` wrappers were emitted for `p88_string_eq_go`, `p88_string_eq`, and `index_hash`, and `capabilities=0xd` (`& 9 == 9`). However, the modest proxy speedup (1.02x–1.05x instead of 5x–10x) indicates that either (a) the benchmark loops spend most of their time in `p111_rt_keep`/`p111_rt_sink` or `p111_` wrapper dispatch rather than inside `p113d_$p118borrow.read.*`, or (b) one runtime guard inside the loop (e.g., `scon_cid` vs `cid_hot` or `p98_tag_eq` `KTerm` cid lookup) is still hitting `__sh_slow` on a subset of calls. Recommended immediate follow-up before self-compile promotion: profile the fast-vs-slow hit rate in `direct_bench` (a 1-line counter in `__sh_slow`) and verify `p98_tag_eq` cid registration in `N111Ids`.

## Artifacts
- Patcher: [apply_strhash.py](file:///home/ai/bend2_agy/research/agy/wave3b_strhash/apply_strhash.py)
- Microbenchmark: [bench_strhash.bend](file:///home/ai/bend2_agy/research/agy/wave3b_strhash/bench_strhash.bend)
- Verifier: [verify_strhash.py](file:///home/ai/bend2_agy/research/agy/wave3b_strhash/verify_strhash.py)
- Build dir (`8.7 MiB`): `selfhost/build/agy/wave3b_strhash/{compiler.bend,api.mjs}`
