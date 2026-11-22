# AGY Compiler Optimization & Qualification Discipline

A reusable two-tier workflow for compiler optimization campaigns (`selfhost/agy`). Keeps iteration loops in seconds while running heavy qualification gates in parallel without interference, OOMs, or benchmark-specific overfitting.

---

## 1. Two-Tier Loop: Fast Inner Loop vs. Full Qualification

| Tier | Purpose | Target Wall-Clock | When to Run |
|---|---|---|---|
| **Tier 1 — Fast Inner Loop** | Hypothesis iteration, profiling, micro-bench validation | **5–60 s** | Every edit / prototype |
| **Tier 2 — Promotion Gate** | Correctness + regression proof before composing/promoting | **~1–2 min** | Once a prototype wins Tier 1 |
| **Tier 3 — Heavy Integration Gate** | Full upstream defaults, native self-compile fixed-point, blind holdouts | **5–20 min** | Wave close / milestone (in parallel with next wave's Tier 1!) |

### Concrete Suites per Tier
- **Tier 1 (Fast Inner Loop)**:
  - **Runtime passes**: `run_proxy.py` (7-family fast proxy, ~10 s) + scaled-down reproducers for slow holdouts (e.g., smaller `N` on `queens` to profile scaling in seconds instead of waiting 90 s for timeouts).
  - **Compile-speed passes**: `bench_compile.py` (6-program compile bench, ~12 s).
  - **Incremental passes**: 4-program live-edit bench (`histogram`, `gameoflife`, `nbody`, `lexer`: cold, 1-fn edit, no-op).
  - **Self-compile / IR size probes**: One-shot `node --max-old-space-size=8192 --stack-size=16384` probe (~45–60 s) to measure exact `N111Segment` / IR counts instead of waiting 6 min on an older native binary to fail silently.
- **Tier 2 (Promotion Gate — per winning prototype)**:
  - `64/64 native64` + `15/15 observer` (~60 s with Wave 5 compiler).
  - Zero regressions on `run_proxy.py` / `bench_compile.py`.
  - Adversarial differential tests / Lean 4 algebraic laws for non-trivial rewrites.
- **Tier 3 (Heavy Integration Gate — run in parallel with next-wave exploration)**:
  - Full untouched upstream defaults (`0e2f38f`, 3 runs each, CPU 2).
  - `10/10 native45` + `44+2/46` ABI + `6/6` Base-Pin + `19/19 focused19`.
  - Full native self-compilation fixed-point (`N0 → N1 → N2 → N3`, exact byte/behavior parity).
  - Strictly untouched blind holdouts (run **only post-freeze** to prevent overfitting).

---

## 2. Parallel Execution & Isolation Rules

Run Tier 3 qualification on one dedicated core while fanning out Tier 1 exploration agents on remaining cores:

1. **CPU Pinning**:
   - Reserve **CPU 2** exclusively for timed benchmarks & Tier 3 qualification (`taskset -c 2` + `/tmp/agy_cpu2_bench.lock`).
   - Pin parallel Tier 1 exploration agents to **CPUs `0, 1, 4, 5`** (`taskset -c 0`, `1`, `4`, `5`, or `0,1,4,5` for sharded builds).
   - Never use CPUs `3` or `7`.
2. **Directory & Artifact Isolation**:
   - Every parallel track owns its own `research/agy/<wave>_<track>/` directory (scripts + `REPORT.md`) and `/tmp/agy_<wave>_<track>/` scratch directory.
   - Never edit shared promoted build artifacts (`selfhost/build/agy/*_unified/`, `*_native-self/`), `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, `experiments/STEERING.md`, or `experiments/ledger.md` from an exploration track.
   - Only the coordinator composes verified winning patches into a unified build.
3. **Memory & Disk Safety**:
   - Always invoke `bun` and `node` through `research/agy/locked_bun.sh` and `research/agy/locked_node.sh` (`flock` + memory/stack caps) to prevent concurrent OOM kills.
   - Exception: a single solo `node --max-old-space-size=8192 --stack-size=16384` probe is allowed when `>= 12 GiB` RAM is free and no other heavy Node process is running.
   - Maintain **`>= 5.0 GiB` free disk** on `/dev/md2`; put transient `.s`/`.o`/binaries in `/tmp/` and clean up after verification.
4. **Generality & Evidence**:
   - **Zero benchmark-specific matchers**; every pass must be a general compiler transformation.
   - Keep a `REPORT.md` + JSON receipt per track with exact before/after numbers, assembly/IR evidence, and preserved rejected attempts.
