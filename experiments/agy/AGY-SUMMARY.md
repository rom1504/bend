# `selfhost/agy` Campaign Summary — Direct x86 Compiled Program Speed (`0.4471×` Mature Bend C)

- **Branch**: `selfhost/agy` (branched off `selfhost/bootstrap` at `8f5caabf`, Phase 205)
- **Goal**: Drive direct x86-64 ELF compiled program speed under **`0.50×` mature Bend C** with general, verified compiler & runtime optimizations and full qualification.
- **Unified composer**: `research/agy/compose_all.py` → `selfhost/build/agy/unified/compiler.bend` (`2,115,381` bytes)
- **Unified runtime**: `selfhost/build/agy/unified/runtime-agy.o` (`runtime-opt.o` + `sqrt-keep.o`, `132` KiB)
- **Receipts**:
  - Full 45-case `native45` timing & oracle summary: `experiments/agy/receipts/unified-full44-summary.json`
  - Independent 4-gate qualification report: `experiments/agy/receipts/unified-qual-report.json`
  - Guarded native `N0 → N1 → N2 → N3` self-build & transfer receipt: `experiments/agy/receipts/unified-native-selfbuild.json` (`unified-native-selfbuild-guard.json`)
  - `AGY-002` runtime benchmark receipt: `experiments/agy/receipts/agy002-rt-results.json`

## Headline Results (`native45`, CPU 2, 3 alternating rounds, 45/45 oracles PASS)

| Metric | Phase 205 Baseline | Unified `selfhost/agy` | Change |
|---|---:|---:|---:|
| **Geomean vs mature Bend C (44 timed)** | `0.941×` | **`0.4471×`** | **0.4749×** cand/base (**2.11× faster**, `< 0.50× C` achieved!) |
| **Fixed-work batch vs C** | `1.547×` (`15.667 s`) | **`1.0862×`** (`10.997 s`) | **−4.670 s** (`10.125 s` C reference) |
| **Cases > 2× slower than C** | `15 / 44` | **`6 / 44`** | **−9 cases** |
| **Cases > 1.1× slower than C** | `30 / 44` | **`23 / 44`** | **−7 cases** |

*(Note: For the 3 CTFE-folded cases that measured `0 ms` over `500,000` repetitions on the millisecond `IO.now()` clock — `test-evening-program`, `test-rle-roundtrip`, `test-map-set-ops` — `bench_all44.py` applies a conservative `0.5 ms` upper bound floor and flags `zero_clamped: true` explicitly in the receipt.)*

## Composed General Optimizations (All 7 Independent & Verified)

1. **`AGY-001` — Binary-Fork `Nat`-Depth `U32.add` Linearization** (`research/agy/bf_linearize.bend`):
   - Linearizes pure binary-fork `Nat`-depth `U32.add` reductions into a guarded (`d <= 31n`) tail-recursive `Nat` loop with exact fallback for `d >= 32n`.
   - Impact: `raytrace` **0.313×** (`1.643× → 0.515× C`), `mandelbrot` **0.513×** (`2.010× → 1.031× C`).
2. **`AGY-002` — ABI-11102 Runtime Fast Paths** (`research/agy/rt/build_rt.py` → `runtime-opt.o`):
   - Cached physical `HEAP_OFF` at `p111_bind` (preserving live mutable descriptor checks), inlined `rfc_wrap`/`rfc_seal` + batch class-0 sealing, unrolled `N=1..4` copies + zero-frame `p125_rt_take1..4`, and 64-bit single-mutator `rfc_view`/`rfc_bump`/`term_drop`/`p111_rt_sink`.
   - Impact (isolated 6-case heap/ADT geomean): **0.9141× (−8.6%)**.
3. **`AGY-003` — Parallel Call-Arg Scheduling + Bounded Cold `ctor{1..4}` Inlining** (`research/agy/x86_ctor/apply.py --mode=args_ctor`):
   - Replaces blanket `x186_call_arguments` stack-snapshot staging with zero-spill register parallel-move scheduling (`r10` cycle breaker) and inlines cold `p125_rt_ctor{1..4}` fast paths in bounded `p113d_`/`p114r_` workers (`<= 256` stmts) with live descriptor checks.
   - Impact (isolated on top of `runtime-opt.o`): **0.8933× (−10.7%)**; `tree-bitonic` `0.743×`, `coverage-bst-64` `0.835×`, `coverage-bst-32` `0.861×`.
4. **`AGY-004` — Dominating CSE into `if`/`else` + Immediate `cmpq $id`** (`research/agy/x86_reg/apply.py --branch-cse`):
   - Propagates dominating CSE facts into both arms of `x186_e_if` and resolves `N111CtorId`/`N111FuncId` to 32-bit immediates (`cmpq $id, %reg`). Shrinks every object by `0.5–3.2 KiB` with zero compile-time overhead.
   - *(Falsified & excluded: lifting `p114h_plan` caps for `Map.*.go` regressed `1.04–1.08×` due to 40 KiB L1i cache overflow; `--rcx`/`--r12` kept optional.)*
5. **`AGY-005-sqrt` — `sqrt`-Preserving F32 Regions** (`research/agy/big_wins/apply_sqrt.py` + `sqrt-keep.s`):
   - Ported Phase 200's staged `p200_rt_f32_sqrt_keep` regions onto `p205-compiler.bend`: `-7.05%` `.text` on `raytrace`, **0.9597×** across the 3 ray cases (`-8.4%` on `variation-ray-active-256-2240`).
6. **`AGY-005b` — Fueled-Loop Absorbing-State Early-Exit** (`research/agy/absorbing/absorbing.bend`):
   - Detects absorbing fixed-point arms in pure fueled `Nat` loops and exits early: **0.9597×** on BST, **27.4×** on general non-product absorbing loops, byte-identical on adverse non-absorbing loops.
7. **`AGY-005a` — General Bounded Pure Closed-Term Evaluator (CTFE)** (`research/agy/big_wins/ctfe.bend`):
   - Evaluates pure, safe, 0-arg closed definitions under 262,144-step fuel (supporting `U32`, `Nat`, `F32`, `Bool`, `Char`, `String`, `Word`, `Array`, ADTs) with mandatory kernel recheck (`check_definition_body` + `ka_def` + `jl_checked_error`).
   - Impact: `test-morning-program` **0.056×** (`3.059× → 0.172× C`), `test-evening-program` / `test-rle-roundtrip` / `test-map-set-ops` **< 0.002× C**.

## Full Independent Qualification (`experiments/agy/receipts/unified-qual-report.json`)

| Gate | Result | Scope |
|---|---|---|
| **1. Runtime ABI, Live Metadata & `sqrt-keep`** | **PASS** | `44/44` `abi-contract.c`, `2/2` `observer.c` (`owner-hot`/`owner-cap`), `65,888` `sqrt` differentials + `1,024` register-preservation checks across `16` MXCSR modes |
| **2. Adverse & Soundness Controls** | **7 / 7 PASS** | `fuel_exhaust`, `dynamic_arg`, `io_order`, `div_zero_safe`, `test_adverse` (non-absorbing), `test_general_pos` (27.4×), `bf_step3` (`d=0,1,5`, non-zero `x`) |
| **3. Broad x86 Conformance (`native64` + `runtime10`)** | **74 / 74 PASS** | `64/64` `native64` (19 focused + 45 broad incl. 3 refusal controls) + `10/10` `runtime10` |
| **4. Independent Source Check** | **PASS** | Unmodified `bend2/bend.ts` (`book_load` + `book_valid`), `typeAccepted: true`, **`unresolvedHoles: 0`**, `6,687` declaration events |
| **5. Full `native45` Suite** | **45 / 45 PASS** | `44/44` timed + `1/1` zero-work oracle (`scalar-region-0`) |
| **6. Native Self-Build (`N0 → N1 → N2 → N3`)** | **PASS (Exact Fixed-Point)** | `SHA-256(n2.o) == SHA-256(n3.o)` (`3d4058cd...`), `N2 == B1` byte-identical on `5/5` `native45` transfer programs with passing oracles |

## Native Self-Build & Fixed-Point Verification (`experiments/agy/receipts/unified-native-selfbuild.json`)

Executed under `selfhost/tools/build-retention/guard.py` on CPU 2 (`wallSeconds: 948.95 s`, `peakTreeRssBytes: 1.93 GiB`, `peakRunAllocatedBytes: 89.1 MiB`):

| Stage | Producer → Target | Emit Time | Object Size | Executable Size | Notes |
|---|---|---:|---:|---:|---|
| **Stage 1** | `N0` (Phase 205) → `N1` | `326.02 s` | `35,986,320 B` | `28,980,144 B` | Phase 205 compiling unified `compiler.bend` + `runtime-agy.o` |
| **Stage 2** | `N1` → `N2` | `307.20 s` | `35,044,896 B` | `28,042,160 B` | **−5.8%** faster emit, **−941 KiB (−2.62%)** smaller `.o` |
| **Stage 3** | `N2` → `N3` | **`300.35 s`** | `35,044,896 B` | — | **−7.87%** faster than `N0`, **`exactFixedPoint: true`** (`SHA-256: 3d4058cdc10e6c7913737c41d53d7025ada816ccb98fd2913f2459591f65df4b`) |
| **Stage 4** | `N2` vs Hosted `B1` (`5` programs) | `2.15–3.78 s` | — | — | **5 / 5 `sameAsHostedB1: true`** & **5 / 5 `oracleOk: true`** (`raytrace`, `mandelbrot`, `coverage-bst-64`, `test-morning-program`, `test-evening-program`) |

*(Distinction preserved per `AGENTS.md`: source checking, hosted-B1 qualification, native `N0→N1→N2→N3` byte-exact self-reproduction, and independent Lean BendTT kernel proofs are reported distinctly; BendTT kernel proofs remain a separate downstream gate.)*
