# Phase107 fast research loop

Run from the repository root. Start with the smallest check that distinguishes
your hypothesis; widen only after it passes. The [phase report](../../../../implementation/phase107/README.md)
and [claim audit](../../../../implementation/phase107/claim-audit.md) define what
the existing results establish. This directory is an experimental backend, not
the selected production compiler.

| Budget | Useful scope | Existing evidence, not a universal deadline |
| --- | --- | --- |
| 5s | One acquired native frontend/build request | Subsecond scalar builds; the separate frozen source gate took 4.33s |
| 20s | A focused pass or small native/JS kernel comparison | Kernel source03's 18 paired comparisons took 10.06s |
| 60s | Broader source controls or the C/Cranelift/QBE matrix | Native controls03 took 33.24s; measure07 took 29.23s |
| About 375s | Acquire a changed full native frontend image | Source04: 110.84s C emission + 264.53s Clang; use the documented 900s guard |

These are different workloads. Not all correctness tests fit 20s; timeout is a
failed/incomplete run, not a pass. Tool acquisition and native image acquisition
are separate costs from repeated requests. Reuse acquired images for hypothesis
tests; rebuild after changing the Bend code those images must execute.

## Setup and serial guard

The examples use retained local images and pinned tools. If absent, follow
[native source/image and QBE acquisition](../../../../docs/self_hosted/NATIVE_IR.md)
and [locked Cranelift acquisition](../phase106/README.md). QBE1.3 lives at
`selfhost/build/phase107/toolchain/qbe-1.3/qbe`; Cranelift uses the Phase106
locked Cargo manifest and `cargo-target/release/bend-native-ir-cranelift`.
The matrix also requires the pinned Lean4.32 Clang, GCC and binutils.

Choose a new run name before every replay. Every output/guard directory must be
fresh; only an explicitly selected object cache may be reused. Preserve failures.
The guard serializes target jobs on CPU3 and limits memory; do not bypass it to
parallelize competing benchmark processes.

```sh
p107_tools=selfhost/tools/performance/phase107
p107_build=selfhost/build/phase107
p107_bun=selfhost/.bootstrap/bun-1.4.3/bun
p107_run=user01
p107_guard() {
  local seconds="$1" label="$2"
  shift 2
  python3 -B selfhost/tools/performance/phase86/guard.py \
    --out "$p107_build/$p107_run-$label-guard" --seconds "$seconds" \
    --rss-mib 2048 --available-mib 4096 --cpu 3 -- "$@"
}
```

## Native source smoke check: reuse image04

```sh
p107_guard 5 native python3 -B "$p107_tools/frontend/native/compile.py" \
  "$p107_tools/cases/arithmetic.bend" \
  --image "$p107_build/native-source04/image.json" --entry bench \
  --policy fast --base cache --whole-object \
  --cache "$p107_build/$p107_run-object-cache" \
  --out "$p107_build/$p107_run-native"
p107_guard 5 result "$p107_build/$p107_run-native/program" \
  --expect 4268337842 19 23
```

`frontend/native/run.py` takes the same source/image/entry/policy/Base options,
plus `--format json|qbe|units`, to inspect frontend output without machine-code
construction. `compile.py --units` selects reusable function objects. Change the
output and guard labels for a warm replay while retaining the cache path.
`--base live` is a separate timing condition. Ordinary requests use native Bend,
QBE and GNU tools; acquiring image04 used Clang. See the [source contract](../../../../docs/self_hosted/NATIVE_IR.md).

## Edit an IR pass without rebuilding the full native frontend

Assemble/check a small Bend bridge, then run only the affected gate. This uses
the pinned upstream compiler to expose Bend functions as a JS testing API; it
does not modify image04. Omitting export names below exports all eligible bridge
definitions after checking the complete book.

```sh
python3 -B "$p107_tools/frontend/assemble.py" \
  --out "$p107_build/$p107_run-bridge"
p107_guard 60 bridge "$p107_bun" selfhost/tools/stage0-library.mjs \
  "$p107_build/$p107_run-bridge/source.bend" \
  "$p107_build/$p107_run-bridge/api.mjs"
p107_api="$p107_build/$p107_run-bridge/api.mjs"

p107_guard 20 demand-emit "$p107_bun" "$p107_tools/demand-audit.mjs" \
  "$p107_api" "$p107_build/$p107_run-demand"
p107_guard 20 demand-check python3 -B "$p107_tools/demand-audit.py" \
  "$p107_build/$p107_run-demand"
```

The paired `audit.mjs`/`audit.py` checks baseline/deep/entry inlining.
`tail-audit`, `reach-audit`, `leaf-audit`, `memory-audit`, `promotion-audit` and
`strength-audit` use the same two-command shape: `.mjs API FRESH_DIR`, then
`.py THAT_DIR`. Select the relevant pair and distinct labels; allow 60s for
gates that build/run all three machine backends. The Python step completes the
newly emitted gate directory; never apply it to an old result directory.
See [pass contracts](inline/README.md) and [backend controls](backends/README.md).

For checked-versus-fast exact products and warmed optimizer timings:

```sh
p107_guard 60 pipeline "$p107_bun" "$p107_tools/pipeline-audit.mjs" \
  "$p107_api" "$p107_build/$p107_run-pipeline" \
  "$p107_build/native-controls03"
```

This replays retained native IR; it does not execute generated programs anew.
For a roughly 20s paired native/JS loop, use the parameterized
[kernel command](kernel/README.md), selecting `--workloads many,shared,text
--policies fast,promote --formats json --rounds 3`. Acquire matching kernel
images after changing kernel code; existing source03 measures its frozen code.

## Emit and measure the cross-backend matrix

```sh
p107_guard 20 emit "$p107_bun" "$p107_tools/emit.mjs" \
  "$p107_api" "$p107_build/source-graphs01" \
  "$p107_build/$p107_run-artifacts" nx_inline_demand promote
p107_guard 60 matrix python3 -B "$p107_tools/measure.py" \
  --artifacts "$p107_build/$p107_run-artifacts" \
  --out "$p107_build/$p107_run-matrix" --rounds 3
```

The retained `source-graphs01` contains five checked source cases and two refused
cases. `frontend/capture-batch.py FRESH_DIR` reacquires that corpus when source or
frontend changes; its default scans only `cases/*.bend`, not `cases/review/`.
`emit.mjs` adds eight constructed IR workloads and emits JSON, C and QBE for
budgets 0/4096. Pipelines are `inline`, `tail-fused`, `leaf-reach`,
`memory-demand`, `fast`, `promote`, `strength`; use a matching checked API and
record both pipeline and inliner arguments. Budget0 still folds constants: it
is not the kernel's untransformed `raw` policy.

The matrix independently checks answers, builds all three backends and records
paired runtime rounds. It separates construction, object/link and execution
clocks. Its reference is experimental IR compiled with Clang O2, not upstream
Bend. Do not treat diagnostic gate clocks as performance measurements.

Source-subset success, constructed memory/closure IR success and production
B1/B2/full-language conformance are separate evidence. Image04 also lacks some
newer research passes. Use [frozen source controls](heldout/README.md) and broader
integration gates when justified; keep exact outputs, input/tool identities,
failures and cold/warm conditions with every result. This index adds no new
measurements and makes no production promotion decision.
