# Phase177 explicit N1 qualification recipes

These recipes are prepared but have not executed targets. Run from the root-owned
serial CPU3 lane after `selfhost/build/phase177/full-native-n1/report.json` and
its separate `image-binding.json` are complete. They reuse the maintained finite qualifier and Phase175's unchanged
Phase170 timed-product re-emitter. No compiler selector or framework changes.

The exact candidate is:

```text
image:   selfhost/build/phase177/full-native-n1/program
receipt: selfhost/build/phase177/full-native-n1/image-binding.json
build:   selfhost/build/phase177/full-native-n1/report.json
source:  selfhost/build/phase177/full-source01/compiler.bend
host:    native
stage:   N1
target:  qbe
mode:    cache
```

`--stage N1` identifies the executing image. The native build report's top-level
`stage` identifies its producer and may say N2; do not copy that into requests.
The authoritative standalone binding has `stage=N1`, protocol `qbe-source-v1`,
targets `['qbe']`, with `sourceIdentity` matching the selected full source.
The maintained request adapter requires a complete receipt, complete binding,
matching image bytes and the exact requested host/stage/target. An incomplete
build must fail admission. This build omitted `--output-stage`, so its preserved
successful build report has no embedded `imageBinding`. The separate binding,
created by root's `bind-native.py`, pins that unchanged build report, the selected
source composition and independent source check. It declares Built, not
semantically qualified. The maintained request adapter explicitly supports this
standalone binding form; the original build evidence remains unchanged.

## Root-owned execution order

```sh
bash selfhost/tests/phase177/qualification/native64-n1.sh
bash selfhost/tests/phase177/qualification/timed-products45-n1.sh
bash selfhost/tests/phase177/qualification/compare-timed175.sh
```

Each script uses the existing Phase177 `job.py`, one aggregate guard and its
retention close. They execute serially and must not be put inside another guard.
Names and output paths are fresh, fixed recipes; for a repeat, change every
corresponding job/output name together instead of overwriting evidence.

1. **Native64:** maintained `qualification.py --suite all`, with per-request
   emission/build/execution limits 30/30/10 seconds. The outer limit is 240
   seconds and 96 MiB of fresh disk. Require `complete:true`, `passed:true`,
   `counts={pass:64,fail:0,unsupported:0}` and no changed inputs. This includes
   61 complete-output positives and three stage-specific refusal controls.
   The report retains actual emitted programs, machine builds and executions.
2. **Timed45:** unchanged `phase170/reemit-products.py`, using the exact
   Phase169 six/remaining candidate acquisition receipts, 45 expected sources,
   and 60 seconds per request. The outer limit is 180 seconds and 64 MiB.
   Require all 45 rows complete, byte-exact emissions and no changed inputs.
   The old method authenticates exact source, prepared Base/stamp, machine
   policy, original output/count oracles and every full original QBE product.
   It emits the timed wrappers but does not execute or time them.
3. **Phase175 comparison:** a small metadata/file-only companion compares the
   newly emitted timed45 products directly to
   `selfhost/build/phase175/timed-products45/report.json`. It keys by exact
   source identity, verifies all source/product/emission pins and the same
   underlying reference receipts, then compares complete source, oracle and
   output bytes. It writes `timed-products45-v175/report.json` with
   `targetsRun:false`. Limit: 30 seconds and 4 MiB. This is a file comparator,
   not another compiler runner or qualification framework.

Phase175 used the same two Phase169 timed references. All 45 current Phase175
source, expected QBE, actual QBE and emission-report paths were present during
recipe preparation. The additional comparison therefore supplies explicit
Phase175 equality rather than relying only on transitivity through Phase169.
The broad45 portion of native64 uses its ordinary sources; it does not replace
the timed-wrapper product gate.

Historical budget evidence: Phase175 native64 used 67.62 guard seconds and
40.82 MiB peak run allocation; timed45 used 61.94 seconds and 24.70 MiB. These
are budget references, not predicted Phase177 timings. The existing wrapper
also enforces 2 GiB RSS, 16 GiB available memory and the default 5 GiB disk
reserve. All budgets include the complete new run's output, not one file.

For an authenticated read-only plan after the image finishes, copy the command
inside the respective script and add `--plan`; omit the outer job wrapper if
printing directly. Those maintained plan modes execute no compiler and create
no output directory. Do not run the target recipes while another performance
target or image acquisition owns the serial lane.

## JS6 and C6 are unsupported by this native image

The actual native QBE entry and its binding advertise only QBE. Maintained
`request.py` explicitly rejects JS/C under `qbe-source-v1`. Native64 and timed45
cannot establish JS/C product preservation for this candidate image.

Phase175's `js6-reemit01` and `c6-reemit01` instead used a separately acquired,
independently checked hosted B1 API in live mode. Its six selected cases were:
`broad/editdist`, `broad/tree-bitonic`, `broad/lexer`,
`broad/test-rle-roundtrip`, `broad/coverage-closures-256`, and
`broad/coverage-map-churn-128`. Reusing Phase175's old API would test the old
source; pointing its hosted re-emitter at this native binary would violate the
protocol. Neither is included. A separately authorized candidate hosted-source
acquisition could later reuse `phase175/reemit-public.py` with explicit new
`--api` and `--api-receipt`, but that would be a distinct host/qualification
lane, not native N1 JS/C support.

Passing these recipes remains finite N1 qualification and exact product
preservation. It is not native self-reproduction, independent BendTT proof,
new generated-program timing, broad frontend parity, installed promotion,
parallel execution or GPU qualification.
