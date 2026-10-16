# Phase102 native image acquisition and qualification plan

This is an offline command/provenance review. The coordinator owns execution;
no command here has been run by the author. Freeze a final source recipe only
after the small app and ownership controls pass. Neither the checked JavaScript
API nor an application ELF constitutes a new native compiler stage.

## Recommended short path

Acquire a genuine upstream-built B1 first. Historical acquisition costs are
small enough that skipping its provenance is a weak tradeoff:

| Operation | Existing evidence | Planning allowance |
| --- | --- | --- |
| Upstream check and C emission | Phase98 33.85 s; Phase99 46.63 s | 60–90 s, 4 GiB RSS |
| Matched `-O2` B1 Clang build | 186.72–190.61 s; about 4 GiB peak | 420 s, 6 GiB RSS |
| B1 small cached request | Prior six cases 64 ms–1.65 s request | 60 s guard, normally seconds |
| B1 full candidate-source emission | Phase98 104.82 s | 300 s guard, 2 GiB RSS |
| Matched `-O2` B2 Clang build | 260.85–266.90 s; about 3.9 GiB peak | 420 s, 6 GiB RSS |
| B2 full fixed-point request | Phase98 140.99 s | 300 s guard, 2 GiB RSS |

These are historical costs, not predictions for changed code. Image construction
must use the existing 6 GiB/16 GiB-available envelope and serial queue. The generic
Phase100 2 GiB program guard is too small for upstream compiler-image emission or
Clang. Preserve the matched compiler-image flags; app `-O3` results are a separate
experiment. Check disk space before every large C/image output.

The practical sequence is roughly 4–5 min to B1 plus a tiny native screen, then
another 6–8 min to B2 and its first useful requests. A full self fixed point adds
roughly 2–3 min. Avoid repeated full-self timing until small B2 timings show benefit.

## Existing commands and path constraints

The prepared Phase102 runner automates only upstream acquisition, matched build
and private B1 binding:

```sh
python3 -B selfhost/tools/performance/phase102/acquire-native.py \
  --recipe FINAL_RECIPE.json \
  --out selfhost/build/phase102/native-b1-01
```

It independently checks the full forward/inverse source recipe and the current
installed Phase98 stages, then runs targets serially with the bounds above.
`acquire-native.mjs` is an exact copy of the existing acquisition method with
only its allowed output directory changed to Phase102; the old/new hashes and
literal substitution are in `acquire-native-derivation.json`. Build and bind
reuse the unchanged methods below. The runner reports a source-bound B1 image,
never qualification or a changed installed selection. Only Python/MJS syntax
and offline derivation checks were performed by its author.

The unchanged `phase99/acquire.mjs` accepts any exact candidate source, but its
output must be beneath `selfhost/build/phase99/`. Its isolated output may be named
`phase102-final-checked01`; this is just a directory restriction. It invokes the
pinned upstream TypeScript compiler (`059266225b77c8ca256ac6b25ee5c21449bab151`)
under Bun, checks zero holes and binds every loaded source. Run it through the
coordinator's guard with the larger upstream-acquisition allowance:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase99/acquire.mjs \
  FINAL_SOURCE.bend selfhost/build/phase99/phase102-final-checked01
```

The existing build and bind adapters accept Phase102 output directories and
already enforce actual unmodified C, exact Clang, matched flags, entry transport,
source identity and guard completion:

```sh
python3 -B selfhost/tools/performance/phase99/qualification/reuse.py build \
  --emission-receipt selfhost/build/phase99/phase102-final-checked01/report.json \
  --binary selfhost/build/phase102/native-final01/b1/compiler \
  --out selfhost/build/phase102/native-final01/b1-build

python3 -B selfhost/tools/performance/phase99/qualification/reuse.py bind \
  --stage b1 --binary selfhost/build/phase102/native-final01/b1/compiler \
  --source FINAL_SOURCE.bend \
  --emission-receipt selfhost/build/phase99/phase102-final-checked01/report.json \
  --build-guard selfhost/build/phase102/native-final01/b1-build \
  --out selfhost/build/phase102/native-final01/b1.json
```

The matched Clang command is:

```text
clang -isystem CLANG_PARENT/include/clang -O2 EXACT_EMITTED.c -o IMAGE -lm -pthread
```

The bound Clang is `/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang`.
The existing builder uses CPU 2,3 and a 420 s deadline. It records the C hash and
never patches the emitted C. Do not call a discovery image B1 merely because it
uses these flags: B1 specifically requires checked pinned-upstream C provenance.

## Exact request transport

Read current frozen assets through `phase99/qualification/reuse.py` support or
`selfhost/tools/native/launch.py` authentication. The selected baseline remains
Phase98 source `2a72bbdc…`, B1 `099df960…`, B2 `c481bd2c…`.

```text
B1 --threads 1 --gpu off -- SOURCE BASE RUNTIME EFFECTS_DIR PREFIX 1 CARRIER STAMP
B2 --threads 1 --gpu off -- phase90-native SOURCE BASE RUNTIME EFFECTS_DIR PREFIX 1 CARRIER STAMP
```

The sentinel distinction is essential: upstream's argv provider and our native
provider differ. A discovery image built from our emitted C uses the B2-shaped
argv, while still being labeled discovery rather than qualified B2.

Exact assets are in `phase98/origin-admission01/report.json`:

- Base: `.bootstrap/upstream-phase66/bend2/base.bend`, SHA256 `99ac43f2…`.
- Runtime: `build/phase90/runtime-accessor-transport02/runtime.c`, SHA256
  `9e1c5907…`, its five exact parts, template and nine approved effect files.
- Carrier: `tools/performance/phase88/base/carrier01/base.p88`, SHA256
  `07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7`.
- Stamp: `p88-private-base-text-1:8dec5b64d3900d61a208e51d92113194b91364c4f4d35d1903edb481d678ed03`.

Paths above are relative to `selfhost/`. Pin full paths, sizes and hashes before
and after the run; the shortened Base/runtime hashes here are explanatory only.
Output is `PREFIX.1.c`. Successful execution must have empty stdout, complete
guard success, exactly one request clock, and the entire expected diagnostic
after removing only the three recognized clock-line forms. Preserve unsafe or
foreign-dependency diagnostics; do not replace them with a blanket proof claim.

For fast discovery, a small generic runner may substitute a candidate binary into
the authenticated transport while recording its source/acquisition/build receipts.
It should require exact C agreement with that candidate's checked-API emission,
then compare request and complete-process time separately. This does not grant
the public native launcher a new admitted selection.

## First native screen and escalation

First compile the fixed small source and source-index app once through B1. Require
complete C/diagnostic agreement with the same candidate's checked API. Add
dependency-plan and image-render once for the three useful workloads. The extra
planning cost is visible in B1 even though the new backend optimizations do not
change B1's own machine code. Then use two alternating baseline/candidate pairs
on the most useful request; expand to the historical six sources only if useful.

For B2, first freeze changed-C intent with the existing backend policy. Its
recipe adapter requires independently replayed `forwardReplayExact` and
`inverseRecoversSource` facts in addition to the Phase102 recipe's exact changes.
`phase99/qualification/prepare.py` performs that adaptation and emits the entire
staged plan; its output path also must be under `selfhost/build/phase99/`.
It does not execute the commands. Use a fresh `phase102-final-plan01` subdirectory
and stop at decision points rather than running all generated commands blindly.

The existing generated plan provides these exact stage gates:

1. Independent current native B2 compiles the **same final candidate source** and
   supplies its entire diagnostic; changed C is expected and explicitly recorded.
2. Candidate B1 self-emits that source through `reuse.py request --purpose
   changed-backend`, bound to the independent report and source-specific policy.
3. `reuse.py build` compiles that exact B1 C; `reuse.py bind --stage b2` checks that
   its producer was the candidate B1 for the same source. This is actual B2
   provenance, still not semantic qualification.
4. B2 compiles small/app controls and reproduces B1's entire C. Its own full
   self-emission must then reproduce the exact B1 self C.
5. Only after those pass: original live/cache controls and rejections, original 45
   complete program executions, and native69 plus exact rejection controls on
   both images. Changed program C requires fresh matched runtime comparisons.
   A fixed point alone is insufficient for release or conformance claims.

`reuse.py compare` currently restricts output to Phase99, selects the correct
frozen Phase98 comparator, and runs four full six-source pairs. Its unmodified
method is suitable for final evidence, but the smaller Phase102 discovery runner
should precede it. Avoid the old Phase98 B2 comparator: it selects native07.

## Alternative direct discovery image

`phase99/discovery-compile-v2.mjs` can compile final source through its checked API
using the exact prepared `p86` request/effect path. Historical full own-C emission
took 184.51 s and 1.91 GiB. Building that own C takes another ~4.5 min; the image can then
use the B2 argv above and must reproduce complete API-produced C on independent
small requests. This directly tests the newly emitted native compiler's behavior
without first building B1, saving approximately 3–5 min. It is a useful fallback
when time is tight, but its emitter is JavaScript-hosted Bend, so it must remain
**discovery**. A later native B1/B2 chain remains necessary before promotion.
