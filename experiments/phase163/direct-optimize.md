# Restoring useful passes without generic materialization

`selfhost/tests/phase163/direct-optimize.bend` is an additive adapter over the
verified closed-library plan. It does not edit the frozen direct prototype or any
maintained pass. Its entry is `p163o_executable_mode(mode, request)`; the short
`p163o_executable(request)` selects mode3. `p163o_library(mode, request, roots)`
is the corresponding library route.

| Mode | Work added after the original semantic plan |
| --- | --- |
| 0 | None; original direct plan and renderer |
| 1 | Existing bounded `p113i_functions` inlining and its scalar simplification |
| 2 | Existing `p118c_plan` source-derived cold-constructor analysis |
| 3 | Both, with one final verification after the transformations |

`p114s_ranges` currently returns its input unchanged. Adding a separately named
range pass would therefore be misleading. The existing inliner's
`p113i_function_done` already invokes `p113k_function` under its ordinary size,
scratch, naming, recursion and eligibility restrictions.

The cold pass rederives eligibility from the same checked request using
`p118c_plan`. Its conditions include the ordinary source/binder check,
`ns_definitions`, and refusal of unknown sharing (`"*"`). Exported roots must
belong to the authentic request closure. Otherwise the old hot flags remain.
The adapter never trusts a caller-supplied cold list or infers coldness from
benchmark identity. Rendering the resulting actual catalogue uses the existing
`p118c_tables` capability update automatically.

Every transformed candidate is then checked by unchanged `p163d_verify`: actual
constructor/static-image verification and the original final direct-function
verifier with **zero scheduled FIDs**. A structural failure refuses output. No
generic bodies, fake original program or new ownership proof certificate are
created. The structural verifier does not itself prove the source sharing
analysis; that authority remains the unchanged conservative predicate above.

## Evidence motivating the small experiment

Static inspection of root's saved
`selfhost/build/phase163/direct-runtime-emission01/*-runtime-10000-source01-*.ssa`
found that both direct outputs kept all163 constructor flags hot and capability1.
Baseline reverse used capability15 and lookup13, with proved cold flags. Existing
runtime constructor paths test capability bit8 and the matching CID's hot flag
before deciding whether sealing is needed (`runtime/qbe/runtime.c:3943`, and the
sized constructor paths). This is a concrete omitted mechanism, not a measured
attribution of the runtime gap.

The direct path also omits borrowed-reader composition. Reusing that safely needs
its source observer derivation, helper composition, and independent projected
function checker; the original direct verifier alone is not that authority.
Those transformations are deliberately outside this bounded adapter. Live
register-bank capability4 is also left unchanged; with one entry segment it is
unlikely to explain a large gap, but no causal measurement is claimed.

## Validation and cost

`p163o_controls()` checks final closed verification after inlining, missing-call
refusal, and covered/uncovered roots. Root still owns source checks and complete
runtime oracles. Run the same 0/1/2/3 input bytes through the same host/image, then
compare native results before timing. The mode discriminator is not a benchmark
name admission rule.

Modes1–3 charge transformation work and one additional final verifier. Cold mode
also charges its repeated source/binder/sharing analysis; no semantic-plan cache
or free precomputed proof is assumed. There is one candidate-lowering pass and
one executable-rendering pass, with no unused library-text rendering. Measure
backend construction cost and produced-program speed separately; a runtime gain
does not establish a compiler-time gain.

The initial frozen source was acquired successfully on the first attempt:
`selfhost/build/phase163/direct-opt-api01/report.json` records checked B1 hosted
API acquisition from `direct-opt-api-source01/compiler.bend`. The outer guard
completed in10.81s with peak process-tree RSS1,189,371,904 bytes under the original
2GiB/120s/48MiB disk-growth limits and5GiB free-disk reserve. This is source/API
acquisition only; it does not qualify the mode controls or native outputs.

`experiments/phase163/tools/direct-modes.mjs` provides the next controlled screen:

```sh
selfhost/.assets/bin/bun experiments/phase163/tools/direct-modes.mjs \
  selfhost/build/phase163/direct-opt-api01/report.json \
  selfhost/build/phase163/direct-runtime-emission01/report.json \
  selfhost/.bootstrap/upstream-phase66/bend2/base.bend \
  selfhost/build/phase163/direct-modes01
```

Run that command under the maintained CPU3/resource/disk guard, not unguarded.
Its default cases are the frozen reverse/lookup10,000-repeat inputs. It runs all22
structural controls, shares one Base seed, calls the checked frontend once per
source, and executes all four modes with opposite mode order on the second
source. Each mode records its Bend API time, separate host artifact-materializing
time, exact QBE pin and static metadata census. Mode0 must reproduce the earlier
direct output byte for byte. Baseline QBE remains the immutable prior artifact;
historical baseline seconds are explicitly labelled and are not new paired
timings. Single observations only screen costs; they are not statistical claims.
The output rows retain the existing `native-pilot.py` interface. Baseline machine
builds can be reused by a later runner only with their exact existing identities
and toolchain receipts; this harness does not synthesize those receipts.
