# Phase109 ownership IR fast loop

[Design](../../../../design/phase109/direct-owned-ir.md) ·
[Architecture](../../../../docs/self_hosted/OWNED_NATIVE_IR.md) ·
[Report](../../../../implementation/phase109/README.md).

All commands run from repository root. Restore the selected native/typed compiler
assets and Phase108 toolchain as described in their guides before replaying.
`runtime/materialize.py` authenticates the Phase90 production runtime core; the
Phase109 evidence capsule includes that small input for restoration. Never replace
the installed compiler or edit upstream `bend2/bend.ts` for these experiments.

## Small checked API

Use a fresh output directory each time. `assemble.py` only concatenates exact Bend
modules; it performs no language transformation. This build includes rejection
controls and the raw/trusted/fused policies.

```sh
python3 -B selfhost/tools/performance/phase109/assemble.py --out selfhost/build/phase109/my-api
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase109/my-api-guard --seconds 30 \
  --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/stage0-library.mjs \
  selfhost/build/phase109/my-api/source.bend selfhost/build/phase109/my-api/api.mjs \
  nxo_lower nxo_lower_policy nxlib_qbe nxlib_c nxlib_verify \
  nxlib_runtime_imports nxlib_runtime_imports_policy nxlib_control_report \
  nx_json_function nxlib_optimize nxo_ownership_report nxo_policy_report
```

Capture real erased facts with `capture.mjs SOURCE FRESH_OUT` under the same
guard. Use `phase108/coverage/fixtures/nt-reverse.bend` and
`phase109/controls/derived/ownership.bend`. `captureNativeFacts` requires a
driver-owned compiler API and checked native capture; injected APIs cannot use
this trust path. `capture-controls.mjs SOURCE FRESH_OUT` checks that boundary.

`emit.mjs API CAPTURE FRESH_OUT [reverse|discard|duplicate] [raw|trusted|fused]`
validates and writes the owned graph, Nx graph, QBE text and comparison C.
`lower-admission.mjs API REVERSE_CAPTURE FRESH_OUT` exercises 38 positive and
corrupted-fact controls. Every emitter invocation runs the Bend structural,
ownership and fusion controls as well.

## Actual runtime and independent observations

```sh
python3 -B selfhost/tools/performance/phase109/runtime/materialize.py --out selfhost/build/phase109/my-runtime
python3 -B selfhost/tools/performance/phase109/runtime/materialize.py --out selfhost/build/phase109/my-production --production-workers
python3 -B selfhost/tools/performance/phase109/runtime/prepare-harness.py --out selfhost/build/phase109/my-harness
```

`runtime/run-contracts.py --runtime RUNTIME --out FRESH` builds and checks the
public runtime contracts, including eleven fail-stop cases and five positive
cases. Run under a 30-second, 1-GiB guard. Frozen expected outputs come from
`controls/expected.jsonl` and the separate discard/duplicate files, not candidate
execution. No benchmark definitions are modified when choosing a policy.

The approximately 10-second semantic suite (23 seconds with the initial timing
rounds) is the normal integration loop:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase109/my-suite-guard --seconds 120 \
  --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase109/suite.py \
  --out selfhost/build/phase109/my-suite \
  --api selfhost/build/phase109/my-api/api.mjs \
  --capture selfhost/build/phase109/my-reverse-capture \
  --derived selfhost/build/phase109/my-derived-capture \
  --runtime selfhost/build/phase109/my-runtime \
  --production-runtime selfhost/build/phase109/my-production \
  --harness selfhost/build/phase109/my-harness --rounds 0
```

Use `--policies fused` for a focused candidate screen. The full suite checks all
three policies, both direct emitters, and actual production worker controls. It
does not rebuild the compiler image. The production workers implement reverse
only and are never used as discard/duplicate references.

Run `compare.py --suite SUITE --out FRESH --rounds 5 --repetitions 20` under a
90-second guard for alternating measurements of the frozen qualified binaries.
Recorded wall time was 18.6 seconds. It excludes input setup from the worker clock
and verifies every result. `runtime/inspect.py --suite SUITE --out FRESH` performs
offline machine inspection; check `--help` for current options.

`controls/baseline.py --out FRESH` is a separate 12-build control: identical full
C under original Clang, portable Clang, portable Clang with cproc adapters and
portable cproc/QBE. Its tiny process clocks are diagnostic, not representative
runtime benchmarks. The kernel cproc comparison lacks Phase108 v3 accessor
expansions; keep those denominators distinct.

## Expensive gate

Only after a changed frontend/runtime integration passes this loop, use the
[native image recipe](native/README.md). Native image acquisition is separate from
the worker loop. General self-hosting and broad45 await full-language IR coverage;
running them on this selected slice would not establish that coverage.
