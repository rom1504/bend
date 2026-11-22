# Wave 3B Track B1 — Runtime Drainer (`compiler.bend` x86-64 Inline Fast Paths)

## Hypothesis & Goal
Drain the hottest C runtime (`runtime-agy.o`) calls **out of C and into Bend-emitted x86-64** inside `compiler.bend` (starting from `selfhost/build/agy/wave2_unified/compiler.bend`), while keeping `selfhost/build/agy/unified/runtime-agy.o` **completely unchanged** and preserving live-metadata (`capabilities` / `cid_hot`) safety (`0 OBSERVER_VIOLATION`s).

## Composable Patcher
- Patcher: [`research/agy/wave3b_rtdrain/apply_rtdrain.py`](file:///home/ai/bend2_agy/research/agy/wave3b_rtdrain/apply_rtdrain.py)
- Patched compiler: [`selfhost/build/agy/wave3b_rtdrain/compiler.bend`](file:///home/ai/bend2_agy/selfhost/build/agy/wave3b_rtdrain/compiler.bend) (`2.4 MiB`)
- Built Stage-0 API: [`selfhost/build/agy/wave3b_rtdrain/api.mjs`](file:///home/ai/bend2_agy/selfhost/build/agy/wave3b_rtdrain/api.mjs) (`5.9 MiB`, total dir `8.3 MiB`, zero leftover `.o`/`.exe`)

### Transformations Applied (`C1`–`C2`, `D1`–`D4`)
1. **`C1` (`p111_rt_special_ctor` inline)**: Inline `P111_SPECIAL_FALSE` (`1 -> 0`), `P111_SPECIAL_TRUE` (`2 -> 1`), and `P111_SPECIAL_ZERO` (`3 -> 0`) directly in `p186ch_expand`.
2. **`C2` (Borrow-guard fusion + `p128bf_rfc` single 64-bit load)**: Fuse `tag == 2 && aux == ctor` into a single `((word >> 40) & 0x7fffff) - 0x20000 == ctor` check; replace split 32-bit loads in `p128bf_rfc` with a single 64-bit `N111Load`; branch directly on `borrow_rfc_bit`.
3. **`D1` (Broadened inline `p111_rt_sink` & `p111_rt_keep` on all frames)**:
   - Shared RFC (`term < 0`): inline non-atomic decrement (`cnt >= 2 -> H[r] -= 1`) for `p111_rt_sink` and increment (`cnt < 0xFFFFFE -> H[r] += 1`) for `p111_rt_keep`.
   - Trivial terms (`term >= 0` and `(term >> 56) < 2`) **and** static-image terms (`(term & LOC_MASK) < HEAP_OFF`): skip C call completely.
   - Slow-path to C only on `cnt <= 1` recursive drop (`p111_rt_sink`), `rfc_wrap` (`p111_rt_keep`), or overflow guard.
4. **`D2` (Inline RFC fast paths in `agy_rt_take_text` for `p125_rt_take1..4`)**:
   - Previously `agy_rt_take_text` only inlined non-RFC constructors (`tag == 0x02`) and fell back to C (`p125_rt_take*` → `p198_rfc_take*` → `span_fade` → `term_drop`) on every RFC constructor (`tag == 0x82`).
   - Now validates `(tag & 0x7F) == 2`, `cid < constructor_count`, `cid_arity[cid] == count`, and `capabilities & 1` once, then handles BOTH:
     - **Unique RFC (`cnt == 1`)**: copies fields to `out`, pushes `r` to class-0 freelist and `src` to class-`cls` freelist inline (checking `src >= HEAP_OFF`, `r >= HEAP_OFF`, and freelist capacity `< 32768`).
     - **Shared RFC (`cnt > 1`, `span_fade` killer)**: two-phase validate-then-commit — Phase A copies all `count` fields to `out` and validates every child is either trivial (`(f >> 56) < 2`) or RFC with `cnt < 0xFFFFFA` (jumping cleanly to C slow path on any non-RFC non-trivial or near-overflow child before any heap mutation); Phase B bumps every RFC child `H[rf] += 1` and decrements parent `H[r] -= 1`.
5. **`D3` (Inline `p118_rt_borrow_scalar_safe` for `count == 1` and `count == 2`)**: Inline aliasing check (`first_loc == second_loc`), RFC `cnt > 1` check, and trivial tag `< 2` check; slow-path to C only on static/non-trivial non-RFC roots.
6. **`D4` (Broaden `agy_mark_bounded_frame`)**: Raise statement threshold from `256` to `512` so larger hot functions also receive inline ctor/take fast paths.

## Measurement Results (Unchanged `unified/runtime-agy.o`)

### High-Sample Interleaved A/B (`proxy_rfc_ast.bend` @ 12k iterations — AST/ADT/String/RFC workload)
| Metric | Baseline (`wave2_unified`) | Runtime Drainer (`wave3b_rtdrain`) | Delta |
|---|---:|---:|---:|
| **`runtime-agy.o` SIGPROF share** | **38.8%** (`97/250`) | **8.5%** (`13/153`) | **-30.3 pp (-78.1% rel)** |
| **Interleaved median wall-clock** | **986.1 ms** (`[835.7, 1131.7, 986.1]`) | **742.7 ms** (`[742.7, 786.0, 690.1]`) | **1.328× speedup** |
| `p118_rt_borrow_scalar_safe` | 6.4% | **0.0%** | **-100%** |
| `p111_rt_sink` | 5.2% | **0.0%** | **-100%** |
| `span_fade` / `p198_rfc_take*` | 4.8% | **0.0%** | **-100%** |
| `p111_rt_keep` | 4.0% | **0.0%** | **-100%** |
| `term_drop` | 2.0% | **0.0%** | **-100%** |
| Remaining `runtime-agy.o` | `p111_rt_op` (4.8%) + others | `p111_rt_op` (3.3%), `p111_rt_ctor` (2.6%), `p111_rt_frame` (2.6%) | — |

### 2k-iteration `proxy_rfc_ast.bend` + 6 Catalog Proxies (`eval_report.json`)
- `proxy_rfc_ast` (2k): `runtime-agy.o` share **39.5% → 21.4%** (`p111_rt_keep` 10.5%→0%, `term_drop` 7.9%→0%, `p118_rt_borrow_scalar_safe` 5.3%→0%, `p111_rt_special_ctor` 5.3%→0%, `span_fade` 5.3%→0%).
- All 6 catalog proxies (`lexer`, `coverage-bst-64`, `coverage-map-churn-32`, `symreg`, `raytrace`, `mandelbrot`): **6/6 exact stdout PASS**.

## Verification & Safety Gates
- **Upstream differential check** (`bun bend2/main.ts` vs `wave3b_rtdrain`): **PASS** (`3961562177` @ 2k, `2609298305` @ 12k).
- **`focused19` conformance gate**: **19/19 PASS**.
- **`observer_wave2_gate` live-metadata safety gate** (`normal`, `cap-no8`, `all-hot` across all 5 probes): **15/15 PASS (`0 OBSERVER_VIOLATION`s)**.
- **Harness**: [`research/agy/wave3b_rtdrain/verify_rtdrain.py`](file:///home/ai/bend2_agy/research/agy/wave3b_rtdrain/verify_rtdrain.py), [`selfhost/build/agy/wave3b_rtdrain/eval_report.json`](file:///home/ai/bend2_agy/selfhost/build/agy/wave3b_rtdrain/eval_report.json).
