# AGY-001 · General Binary-Fork `Nat`-Depth `U32.add` Reduction Linearization

- **Status**: **In progress (source-checked & matching `colf`/`rowf`; 1 remaining emitter bug)**
- **Motivation**: SIGPROF profiling of Phase 205 direct x86 executables revealed:
  - `raytrace` (`+0.947 s` gap to C, #1 fixed-batch deficit): **49.2%** in `p114r_$direct.colf` + **6.2%** in `p111_rt_frame` (**55.4% total**) due to continuation-frame bouncing over `2^14` columns.
  - `mandelbrot` (`+0.399 s` gap to C): **28.8%** in `p111_$direct.rcol` + **11.5%** in `work_loop` + **7.7%** in `p111_$p111.k.9516` (**48.0% total**) on the exact same binary-fork `U32.add` reduction pattern.
- **Mechanism** (`research/agy/bf_linearize.bend`, `research/agy/apply_bf.py`):
  - Recognizes checked Bend functions `f(d: Nat, x: U32, a_1..a_k) -> U32` where `0n => BASE` and `1n+p => let a = f(p, x, a...); b = f(p, x + (STEP << p), a...) in a + b`.
  - Generates checked tail-recursive loop `f$agy_bf(rem: Nat, x: U32, acc: U32, a...) -> U32` and a `d <= 31n` guarded dispatcher falling back to `f$agy_orig` for `d >= 32n`.
- **Current state**:
  - Pass compiles cleanly through upstream Bend (`Checked 4 API exports`), matches `colf` and `rowf` in `raytrace.bend`, and passes `check_definition_body` + `jl_checked_error`.
  - **Remaining blocker**: `p144o_prepare_annotated` / `p111_effects` reports `foreign provider unavailable in fixed runtime: Nat` because `"Nat"` enters `plan.request.names` when new helper defs are added to `annotated`/`context`. Next step: inspect `p144o_build` to see why newly added defs pull `Nat` into `names`, fix it, and run `research/agy/bench_compare.py` across all 6 `raytrace` + `mandelbrot` cases (expected ~`-45–50%` on `raytrace`, ~`-40%` on `mandelbrot`).
