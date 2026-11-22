# Wave 4 Campaign Plan — Reaching `~1.0×` Optimized C on General Bend Programs & Draining the C Runtime (3-Hour Campaign)

- **Branch**: `selfhost/agy` (starting from audited Wave 3B checkpoint `fb3a32ae`)
- **Duration**: **3 hours (`180 min`)**, structured into 5 timed phases with hard worker caps and fast-proxy iteration
- **Primary Targets**:
  1. **General Compiled-Program Speed (`~1.0×` optimized handwritten Clang 16 `-O3 -ffp-contract=off`)** on Codex's two new un-gamed benchmark suites:
     - **`upstream-runtime-v1`** (untouched upstream Bend programs pinned at `0e2f38f`, 1-core CPU):
       - `histogram`: `17.34×` C → **target `≤ 1.3×` C** (`130.2 s → ~8–10 s`)
       - `gameoflife`: `13.04×` C → **target `≤ 1.3×` C** (`227.7 s → ~18–23 s`)
       - `nbody`: `5.08×` C → **target `≤ 1.1×` C** (`54.5 s → ~10–12 s`)
     - **`native-tuned-v1`** (rotating 32-seed anti-CTFE/anti-overfit pilot on tuned sources):
       - Family geomean: **`4.32×` C → target `≤ 1.3×` C** (`list` `1.61×`, `expression` `2.36×`, `bst` `6.14×`, `editdist` `14.99×`)
  2. **Honest Transfer Proof (Zero Overfitting)**:
     - **`bfs`, `merkle`, `kmeans`** remain **strictly untouched holdouts** until Phase 4 (`2:30–3:00`). Never inspect or tune on them during Phases 0–3.
     - **`native45` zero-regression**: preserve or beat Wave 2's **`0.4527×` C fixed-work batch** (`0.2006×` geomean).
  3. **Compiler & Runtime Cleanup**:
     - **Zero benchmark-specific pattern matchers.** Every Wave 4 pass must be a **general IR / x86-64 compiler optimization**.
     - **Drain `runtime.c` further** (building on Wave 3B's **78% runtime drain**, `38.8% → 8.5%`) by lowering remaining hot runtime ops (`Array` ops, `fork`/join, bump-alloc `ctor`, arity 5–9 `take`) directly into Bend-emitted x86-64.
     - **Retire brittle Wave 2 ad-hoc passes** wherever Wave 4's general passes match or beat them on `native45`, shrinking `compiler.bend` and accelerating self-compilation as a direct bonus.

---

## Core Operating Rules (Distilled from Waves 1–3B)

1. **Fast 1–5 s Proxy Loop Inside Every Worker**:
   - **NEVER** run full `compiler.bend` self-compiles (`300–500 s`) or full untouched upstream defaults (`130–228 s`) inside exploration workers.
   - Every worker iterates on the **< 10 s fast proxy suite** (medium `histogram` `0.34 s`, medium `nbody` `0.32 s`, small/medium `gameoflife`, and `native-tuned-v1` single-family runs).
   - Reserve full untouched defaults, holdout transfer (`bfs`/`merkle`/`kmeans`), and native self-builds strictly for Phase 4.
2. **Profile & Disassemble First (`SIGPROF` + `objdump -d` vs Clang `-O3`)**:
   - Never guess a pass. Every hypothesis starts from an exact `SIGPROF` profile and side-by-side x86-64 inner-loop comparison against `Upstream Bend→C` (`0.97×–1.52×` C) and `Handwritten C -O3`.
3. **Composable, Non-Overlapping Patchers**:
   - Every track delivers a clean, standalone `.py` patcher transforming `compiler.bend`, composed centrally by `research/agy/compose_wave4.py`.
   - Keep `selfhost/src/runtime/qbe/runtime.c` untouched and ABI-11102 intact (`71/71` exports, `44+2/46` ABI/observer probes).
4. **Parallel Correctness & Safety Discipline**:
   - **Tier-1 (inside every worker):** `19/19 focused19`, exact checksum match vs upstream TS/C oracles, `15/15 observer_wave2_gate` (`0` violations).
   - **Tier-2 (every phase gate):** `64/64 native64`, `44+2/46` ABI + `observer.c`, `6/6` Base-pin regression, expanded differential fuzzer (`fuzz_diff.py`), and `F32` exact bit-reproducibility (`-ffp-contract=off` semantics on chaotic `nbody`!).
   - **Tier-3 (Phase 4):** Full `upstream-runtime-v1`, `native-tuned-v1`, untouched holdouts (`bfs`/`merkle`/`kmeans`), `native45` zero-regression, Lean 4 proofs for any new algebraic/bounds-check law.
5. **Host & Disk Hygiene**:
   - Pin timed benchmarks to **CPU 2** (never CPU 3 or CPU 7).
   - Keep per-worker scratch `< 40 MiB` under `selfhost/build/agy/wave4_<track>/`; wrap any heavy final qualification in `selfhost/tools/build-retention/guard.py` (`5 GiB` free-space reserve).
   - Commit & push a clean checkpoint at the end of every phase (`Wave 4A`, `Wave 4B`, `Wave 4C`).

---

## 3-Hour Phased Execution Schedule

### Phase 0 (`0:00–0:15`, 15 min) — Fast Proxy Harness & Instruction-Level Root-Cause Diagnosis
*Launch 3 parallel read-only/profiling agents (12-min cap):*

| Agent | Task | Deliverable |
|---|---|---|
| **P0-Harness** | Build `/home/ai/bend2_agy/research/agy/wave4_bench/run_proxy.py`: compiles & times medium `histogram`, medium `gameoflife`, medium `nbody`, and `native-tuned-v1` (`list`, `expression`, `bst`, `editdist`) in **< 12 s total** on CPU 2 using `batch_emit.mjs`, verifying exact checksums against pinned upstream oracles (`0e2f38f`). **Never touch `bfs`/`merkle`/`kmeans`.** | `research/agy/wave4_bench/run_proxy.py` + baseline JSON |
| **P0-Prof-IntArr** | `SIGPROF` + `objdump -d` side-by-side (`AGY x86` vs `Upstream Bend→C` vs `Handwritten C -O3`) on **`histogram` (`17.34×`)**, **`gameoflife` (`13.04×`)**, **`editdist` (`14.99×`)**, and **`bst` (`6.14×`)**. Quantify exact % spent in: `fork`/join overhead, `Array` get/set/alloc C calls, bounds checks, boxing, stack spills, and refcounting. | `experiments/agy/wave4-diag-intarr.md` |
| **P0-Prof-FloatLoop** | `SIGPROF` + `objdump -d` side-by-side on **`nbody` (`5.08×`)** and **`expression` (`2.36×`)**. Quantify exact % spent in: `F32` boxing/unboxing, XMM spills, tuple/struct allocation across loop backedges, `sqrtss` calls, and `fork` overhead. | `experiments/agy/wave4-diag-floatloop.md` |

**Phase 0 Exit Gate (`0:15`):** Ranked table of exact instruction-level root causes across all 7 benchmark families, with exact % of wall-clock attributable to each general mechanism.

---

### Phase 1 (`0:15–1:00`, 45 min) — Wave 4A: The 4 High-Multiplier General Backend Passes
*Launch 4 orthogonal parallel agents (35-min worker cap → `0:50`, followed by 10-min compose & Phase 1 gate):*

1. **Track W4-1 — General Single-Thread `fork` / Join Lowering (`apply_fork_seq.py`)**:
   - Eliminate `fork` task/closure allocation and `work_loop` dispatch when executing single-threaded (`capabilities` / `--threads 1` or inline direct-call fast path with runtime fallback when multi-threaded).
   - Directly attacks the `fork` trees present in `histogram`, `gameoflife`, `nbody` (and holdouts `bfs`, `merkle`, `kmeans`).
2. **Track W4-2 — General Inline `Array` / Buffer `U32`/`F32` Lowering (`apply_array_inline.py`)**:
   - Lower general `Array.get`, `Array.set`, `Array.mut` / swap, and `Array.len` directly to inline x86-64 loads/stores (`mov eax, [base + idx*4]` / `movss`) with compact bounds check + `capabilities` guard + slow-path fallback, eliminating C runtime calls and value boxing inside array loops.
   - Directly attacks **`histogram` (`17.34×` → target `< 3×`)** and **tuned `editdist` (`14.99×` → target `< 3×`)**.
3. **Track W4-3 — General Loop-Carried Scalar/F32 XMM Regalloc & Worker/Wrapper Unboxing (`apply_scalar_loop.py`)**:
   - Generalize Wave 2's ad-hoc loop rules into a **general tail-recursive loop-carried `U32`/`F32` unboxer + GPR/XMM register allocator + worker/wrapper tuple/record splitter** (no benchmark-specific templates!).
   - Preserve exact IEEE-754 `F32` semantics (no FMA contraction, matching `-ffp-contract=off` on chaotic `nbody`).
   - Directly attacks **`nbody` (`5.08×` → target `< 1.8×`)**, **`gameoflife` (`13.04×` → target `< 3×`)**, **`expression` (`2.36×` → target `< 1.4×`)**, and **`bst` (`6.14×` → target `< 2.5×`)**.
4. **Track W4-4 — Further C-Runtime Draining + Self-Compile Bonus (`apply_rtdrain2.py`)**:
   - Extend Wave 3B Track B1 (`apply_rtdrain.py`): inline bump-alloc `p111_rt_ctor` / `p125_rt_ctor*` (`alloc_ptr + words <= alloc_end`), inline arity 5–9 `p111_rt_take`, and fix Wave 3B Track B2's `p88_string_eq` / `index_hash` fast-path bail rate.
   - Goal: push C runtime `SIGPROF` share **below `5%`** on general workloads and accelerate self-compilation simultaneously.

**Phase 1 Exit Gate (`0:50–1:00`):**
- Compose `W4-1..4` via `research/agy/compose_wave4.py` → `wave4a_unified/api.mjs`.
- Run in parallel: `64/64 native64`, `44+2/46` ABI + `15/15 observer` (`0` violations), and `run_proxy.py` scorecard.
- Commit & push checkpoint **`Wave 4A`**.

---

### Phase 2 (`1:00–1:55`, 55 min) — Wave 4B: 2nd-Order Gap Closing, Cleanup & Adversarial Hardening
*First 5 min (`1:00–1:05`): re-profile `wave4a_unified` on `run_proxy.py` to expose the exact 2nd-order bottlenecks.*
*Next 40 min (`1:05–1:45`): launch 4 parallel agents (3 optimization/cleanup + 1 dedicated adversarial auditor):*

1. **Track W4-5 — 2nd-Order Scalar/Loop Optimizer (`apply_loop_opt2.py`)**:
   - Attack remaining gaps in `gameoflife`, `nbody`, `expression`, `list`: LICM (hoisting loop-invariant loads/constants/array bases out of inner loops), branchless bitwise/comparison sequences (`cmov`/bitops for `gameoflife` 4×4 toroidal boards), strength reduction, and eliminating redundant moves/spills.
2. **Track W4-6 — 2nd-Order Memory/Perceus Reuse & Bounds-Check Elimination (`apply_mem_opt2.py`)**:
   - Attack remaining gaps in `histogram`, `editdist`, `bst`: range/induction-variable bounds-check elimination (`0 <= i < len` proven across loop), general Perceus constructor reuse across recursive helper boundaries (for `bst`), and in-place 2-row buffer reuse (for `editdist`).
3. **Track W4-7 — Compiler Cleanup & Brittle-Pass Retirement**:
   - Audit all 14 Wave 2 passes (`compose_wave2.py`) against `wave4_unified`: identify which ad-hoc Wave 2 passes (e.g., `apply_dp_loop`, `apply_f32_loop`, redundant emitters) are now superseded by Wave 4's general passes, test retiring them cleanly on `native45` (`0` regression required!), and shrink `compiler.bend` code size (cutting self-compile time too!).
4. **Track W4-8 — Adversarial Correctness, Fuzzer Expansion & Lean 4 Laws**:
   - Expand `research/agy/wave3_fuzz/fuzz_diff.py` with 4 new pass-family generators: (a) `fork`-join trees, (b) `Array` mutation/aliasing/out-of-bounds/empty arrays, (c) chaotic `F32` arithmetic (`-0.0`, `NaN`, subnormals, non-contraction), (d) deep recursive `bst`/record updates under live `cid_hot` mutation.
   - Add machine-checked Lean 4 theorems (`Wave4Laws.lean`, 0 `sorry`) for any new bounds-check / loop-induction / fork-equivalence laws.

**Phase 2 Exit Gate (`1:45–1:55`):**
- Compose `Wave 4B`, run `64/64 native64` + `observer` + expanded fuzzer (`300+` cases) + `run_proxy.py` + `native45` regression check.
- Commit & push checkpoint **`Wave 4B`**.

---

### Phase 3 (`1:55–2:30`, 35 min) — Precision Closing to `~1.0×` C & Runtime Thinning Audit
*Launch 2–3 surgical parallel agents (25-min cap → `2:20`, 10-min compose & gate):*

- Compare exact x86-64 inner-loop instruction counts (`objdump -d`) of `wave4b_unified` vs Clang 16 `-O3` on whichever of the 7 families (`histogram`, `gameoflife`, `nbody`, `list`, `expression`, `bst`, `editdist`) remain above `1.25×` C.
- Close the final 10–30% gap (e.g., loop unrolling where profitable, register-pressure fixes, eliminating remaining spill/reload pairs, dead-symbol inventory of `runtime.c` showing exact C runtime footprint that can now be retired).
- Compose, verify `64/64 native64` + `observer` + `run_proxy.py`, commit & push checkpoint **`Wave 4C`**.

---

### Phase 4 (`2:30–3:00`, 30 min) — Full Qualification, Untouched Holdout Transfer & Final Report
*Zero new optimizations — pure verification, transfer measurement, and reporting:*

1. **Full `upstream-runtime-v1` (small + medium + untouched upstream defaults)** on CPU 2 (`histogram`, `gameoflife`, `nbody`), exact checksums verified.
2. **Full `native-tuned-v1` (all 10 points, 32 rotating seeds)** on CPU 2 (`list`, `expression`, `bst`, `editdist`), exact checksums verified.
3. **Untouched Holdout Transfer Test (`bfs`, `merkle`, `kmeans`)**:
   - First and only measurement of Wave 4 vs Wave 2 vs Handwritten C on Codex's 3 reserved holdouts — honest proof of generality!
4. **Full Correctness & Non-Regression Matrix**:
   - `64/64 native64`, `44+2/46` ABI + `15/15 observer` (`0` violations), `6/6` Base-pin regression, `300+` differential fuzz cases (`0` mismatches), Lean 4 proofs (`0` `sorry`).
   - `native45` zero-regression (`≤ 0.4527×` C fixed-work batch preserved or improved).
   - C runtime `SIGPROF` share table across all workloads + updated `compiler.bend` size & self-compile proxy speedup.
5. **Publish `experiments/agy/WAVE4-REPORT.md`**, clean temporary build artifacts (`guard.py` + `5 GiB` reserve verified), commit & push final **Wave 4** checkpoint to `origin/selfhost/agy`.

---

## Success Criteria (Go / No-Go Scorecard)

| Metric | Wave 2 Baseline | Wave 4 Target | Stretch Goal |
|---|---:|---:|---:|
| `upstream-runtime-v1` `histogram` (default) | `17.34×` C | `≤ 1.5×` C | `≤ 1.1×` C |
| `upstream-runtime-v1` `gameoflife` (default) | `13.04×` C | `≤ 1.5×` C | `≤ 1.1×` C |
| `upstream-runtime-v1` `nbody` (default) | `5.08×` C | `≤ 1.2×` C | `≤ 1.0×` C |
| `native-tuned-v1` 4-family geomean | `4.32×` C | `≤ 1.5×` C | `≤ 1.1×` C |
| Untouched Holdouts (`bfs`, `merkle`, `kmeans`) | baseline | **clear general speedup (`≥ 2×`)** | `≤ 1.5×` C |
| `native45` fixed-work batch | `0.4527×` C | `≤ 0.4527×` C (zero regression) | `< 0.42×` C |
| `runtime.c` `SIGPROF` share (AST/general) | `38.8%` | `≤ 5%` | `≤ 2%` |
| Correctness (`native64` / `observer` / `fuzz` / `Lean`) | `64/64`, `0`, `245/245`, `17` | `64/64`, `0`, `300+/300+`, `20+` | 100% clean |
