# Wave 6: General `p111` Dead-Factory Pruner + Alpha-Equivalent CPS Continuation Deduplicator

## Executive Summary

A 100% general, two-pass IR optimization in `p167l` (running **before** `p140or_finish` and 16-bit FID assignment in `p111v_functions`) permanently eliminates the `65,531` 16-bit FID limit on untrimmed `selfhost/build/agy/wave5c_unified/compiler.bend` (**3.13x** fewer `N111Segment`s: `78,688 -> 25,125`, `38.3%` of FID capacity), shrinks `.o` binaries by **19.9%**, and speeds up emit by **1.07x** even on small direct-heavy programs (up to `1.14x` on `raytrace`, with ~3x segment-processing reduction on CPS-heavy `compiler.bend` self-compile):

| Metric (`wave5c_unified/compiler.bend`, untrimmed) | Baseline (`wave5c_unified`) | Wave 6 (`p111_prune`) | Delta |
|---|---:|---:|---:|
| **Total `N111Segment`s** | **78,688** *(EXCEEDS 65,531 cap!)* | **25,125** | **-53,563 (-68.1%, 3.13x fewer)** |
| 16-bit FID capacity usage (`65,531` max) | `120.1%` (**REFUSED**) | **`38.3%`** (**`40,406` headroom**) | Permanently solved |
| `$p111.k.*` continuation segments | 67,259 | 18,517 | **-48,742 (-72.5%)** |
| `$direct.*` worker segments | 6,506 | 6,499 | -7 |
| Factory / `main` segments | 4,923 | 109 | **-4,814 (-97.8%)** |
| Unreachable `N111Segment`s | 24,205 | **0** | **-24,205 (-100.0%)** |
| Full verifier + prepare (`p169s_lowered`) | **FAIL** (FID overflow) | **PASS** (`error = ""`, 27.0s) | Zero verifier changes |

## Root-Cause Analysis

Diagnostic probing of `p168_request_mode(1, plan.request)` on untrimmed `selfhost/build/agy/wave5c_unified/compiler.bend` (`7,333` top-level defs, `3,433` direct `P113DFunction`s, `4,827` non-direct CPS families) revealed two massive, 100% general sources of `N111Segment` bloat:

1. **Dead Curried Factories in `p167l_dispatch` (`24,205` unreachable segments = `30.8%` of total):**
   When `p167l_dispatch` materialized a demanded non-direct worker `$direct.<f>` (`dx(entry) == 0`, `arity > 0`), it unconditionally called `p167l_family` -> `p111_entry`, which emitted **both** the worker `$direct.<f>` **and** the 0-arg curried closure factory `<f>` plus its `arity` nested `$p111.k.*` closure-currying lambdas (`4,821` dead factories + `19,384` dead currying lambdas = `24,205` completely unreachable segments).
2. **Duplicate Alpha-Equivalent `$p111.k.*` Continuations (`~29,358` redundant segments):**
   Because `p112_liveness_cut` allocates a fresh `$p111.k.<n>` segment at every non-tail call / `p111_slow_app` site, thousands of emitted continuations are structurally identical up to alpha-renaming of local variable names (`v_*`). In particular, `13,134` distinct `$p111.k.*` segments in `compiler.bend` are literally the exact same 5-statement `p111_rt_apply(state, reg[0], stack[0])` continuation, plus thousands more identical `p111_rt_jump`, `p111_rt_return`, `p111_rt_ctor`, and `p111_rt_closure` continuations.

## Implementation (`apply_p111_prune.py`)

Patch script: `research/agy/wave6_p111_prune/apply_p111_prune.py` (+12.5 KB of self-contained Bend helpers, zero benchmark-specific matchers, zero verifier/runtime/ABI changes).

### Pass 1 — Demand-Split Non-Direct `p167l_dispatch`
- Mirrors the split already used for direct functions (`dx(entry) == 1`):
  - When `dx(entry) == 0` and `arity == 0`: unchanged (`p167l_family`).
  - When `dx(entry) == 0`, `arity > 0`, and `dk(entry) == "P167Worker"`: `w6_worker_non_direct` lowers **only** the `$direct.<f>` worker and its continuations (never the curried factory or its `arity` nested lambdas).
  - When `dx(entry) == 0`, `arity > 0`, and `dk(entry) == "P167Factory"`: `w6_factory_non_direct` lowers **only** the factory `<f>` (eta-expanded when `eta == True`, which references `N111FuncId{"$direct.<f>"}` and automatically demands the worker via `p167l_segment_demands`; compact body when `eta == False`).
- Eliminates all `24,205` unreachable segments on `compiler.bend` **without ever lowering them** (`78,688 -> 54,483`).

### Pass 2 — Bounded Alpha-Equivalent `$p111.k.*` Continuation Deduplication
- Runs in `p167l_finish` right before `p140or_finish` (when `error == ""`), **before** `p167v_original` / `p111v_functions` (16-bit FID assignment & verification) and all downstream backend passes (`p112f_index`, `p168j_registry`, `x181`/`x187`).
- Runs 2 linear rounds (`w6_dedup_round(ordered, 2)`):
  - Only `$p111.k.*` internal continuations are eligible (`main`, `$direct.*`, factories, and `P164Adapter`s are never touched).
  - Each `$p111.k.*` segment with `<= 32` statements (`fuel = 33`, guaranteeing O(1) bounded work per segment) is canonicalized by alpha-renaming locals in deterministic definition order (`"state"` fixed) into a canonical key string `(arity|result|incoming|flags|stmts)` and looked up in the existing FNV-1a hash-trie (`p111v_get` / `p113e_insert`).
  - Duplicates are recorded in an `alias` hash-trie (`old_name -> canonical_name`) and dropped; if `merged > 0`, `w6_rw_segs` rewrites all `N111FuncId` references across surviving segments before the next round.
- Collapses `54,483 -> 25,125` segments (`-29,358` additional segments).

## Verification Results

### 1. Correctness & Safety Gates (`research/agy/wave6_p111_prune/verify_w6.py`)
- **`native64` conformance**: **64/64 PASS** (all 19 focused + 45 broad cases including 3 refusals)
- **Live-Metadata Observer Gate**: **44+2 ABI + 15/15 PASS (0 violations)** across `normal`, `cap-no8`, and `all-hot` modes
- **Full `compiler.bend` Verifier Admission (`p169s_lowered`)**: **PASS (`error = ""`)** on untrimmed `wave5c_unified/compiler.bend` (`25,125` segments, `0` unreachable, `27.0s` verify+prepare)

### 2. Compile-Speed & `.o` Size Benchmark (`bench_compile.py`, CPU 0, back-to-back uncontended)
Baseline (`selfhost/build/agy/wave5c_unified/api.mjs`) vs Wave 6 (`/tmp/agy_w6_p111_prune/api.mjs`):

| Program | Base Emit (ms) | Wave 6 Emit (ms) | Speedup | Base `.o` (B) | Wave 6 `.o` (B) | `.o` Delta |
|---|---:|---:|---:|---:|---:|---:|
| `histogram` | 7,554.8 | 6,740.0 | **1.12x** | 259,632 | 194,464 | -25.1% |
| `gameoflife` | 4,541.9 | 4,577.7 | 0.99x | 61,680 | 59,616 | -3.3% |
| `nbody` | 2,528.8 | 2,471.3 | 1.02x | 58,216 | 54,272 | -6.8% |
| `editdist` | 2,548.1 | 2,345.7 | **1.09x** | 129,480 | 106,688 | -17.6% |
| `lexer` | 2,488.1 | 2,475.2 | 1.01x | 86,376 | 78,560 | -9.0% |
| `raytrace` | 2,553.2 | 2,237.6 | **1.14x** | 99,328 | 63,056 | -36.5% |
| **TOTAL** | **22,214.8** | **20,847.5** | **1.07x** | **694,712** | **556,656** | **-19.9%** |

*(On these 6 small benchmarks, >80% of functions are already direct `P113DFunction`s so CPS segments are a small fraction of emit time; on `compiler.bend` itself, CPS segments are 85.5% of all segments and drop 3.13x from `78,688 -> 25,125`.)*

## Integration Instructions

To apply this pass to any Wave 5C / Wave 6 unified `compiler.bend`:

```bash
python3 -B research/agy/wave6_p111_prune/apply_p111_prune.py \
  --src <in_compiler.bend> \
  --dst <out_compiler.bend>
bash research/agy/locked_bun.sh <out_compiler.bend> -o <out_api.mjs>
```

Because both passes are completely self-contained within `p167l_dispatch` and `p167l_finish`, they compose cleanly with all Wave 5/6 runtime and codegen tracks without touching `p111v`, `p113d`, `x181`, `x187`, or `runtime-agy.o`.
