# Phase174 control source and operational selector proposals

These helpers transport source and authenticated metadata. They do not run a
compiler, qualify an image, or change the installed compiler. The coordinating
agent owns target execution and publication.

## Additive finite-control API

`prepare-controls.py` retains the full maintained QBE source byte for byte,
including its native `main`, and appends exactly four pinned Phase171 control
modules from `controls.json`. It adds 41 declarations and exports seven QBE
entry points plus five control roots. No source pruning or optimization overlay
is applied; Phase171 implementations are already integrated.

The resulting control API is separate from the release QBE API. The release API
must be acquired from the unchanged canonical source, using the release export
manifest; it must not contain the appended control source or claim live
preparation via `p86_prepare`.

Metadata-only assembly:

```sh
python3 -B selfhost/tests/phase174/prepare-controls.py \
  --canonical-source selfhost/build/phase174/source01/compiler.bend \
  --out selfhost/build/phase174/control-source01
```

Use `--plan` to authenticate inputs and inspect the assembly without creating
output. A real assembly requires a fresh output directory. The manifest records
all input identities, offsets of appended declarations, exact inverse removal,
Base/carrier bindings, and unchanged protected declarations.

The prepared `control-source01` retains the 3,161,409-byte canonical prefix
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
Its 3,179,883-byte control source has SHA256
`8b09c754ae03bdabc6f56d7cf648c42703b314e0aa12134d0a55a0d58898a5ec`.
This is an assembly identity, not a source-checking result.

The coordinator can acquire and run the finite gates separately:

```sh
python3 -B selfhost/tests/phase174/job.py --rss-mib 4096 control-api01 180 96 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase174/control-source01/compiler.bend \
  --exports selfhost/build/phase174/control-source01/exports.json \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun \
  --out selfhost/build/phase174/control-api01

python3 -B selfhost/tests/phase174/job.py controls-fail-fast 30 16 \
  selfhost/.assets/bin/bun selfhost/tests/phase171/fail-fast-controls.mjs \
  --baseline selfhost/build/phase171/combined-api05/report.json \
  --candidate selfhost/build/phase174/control-api01/report.json \
  --out selfhost/build/phase174/controls-fail-fast

python3 -B selfhost/tests/phase174/job.py controls-lazy 30 24 \
  selfhost/.assets/bin/bun selfhost/tests/phase171/lazy-admission-controls.mjs \
  --baseline selfhost/build/phase171/combined-api05/report.json \
  --candidate selfhost/build/phase174/control-api01/report.json \
  --out selfhost/build/phase174/controls-lazy

python3 -B selfhost/tests/phase174/job.py controls-catalogue 30 8 \
  selfhost/.assets/bin/bun selfhost/tests/phase171/value-controls.mjs \
  --receipt selfhost/build/phase174/control-api01/report.json \
  --export p171sc_controls --count 12 \
  --out selfhost/build/phase174/controls-catalogue

python3 -B selfhost/tests/phase174/job.py controls-publication 30 8 \
  selfhost/.assets/bin/bun selfhost/tests/phase171/value-controls.mjs \
  --receipt selfhost/build/phase174/control-api01/report.json \
  --export p171s_controls --count 5 \
  --out selfhost/build/phase174/controls-publication
```

The total is 22 lowering cases, six SCC cases, 32 complete planner observations,
12 catalogue controls, and five publication controls: **77**. The two paired
runners preserve complete successful values and explicit failure/admission
oracles. They are finite compiler-data checks, separate from native64, runtime
qualification, self-reproduction, and mathematical proofs.

## Selector proposal after all gates

`prepare-selectors.py` adapts the frozen Phase170 preparation method without
modifying it. It authenticates six independent receipts, both executable/API
artifacts, the maintained source, and the unchanged linked runtime. It requires
the exact canonical source above, native64, the hosted QBE finite gate, the six
positive native session comparisons, and the six-row normal session result.

Once those receipts exist, the coordinator can run:

```sh
python3 -B selfhost/tests/phase174/prepare-selectors.py \
  --native-build selfhost/build/phase174/n2/report.json \
  --native-qualification selfhost/build/phase174/qbe64/report.json \
  --hosted-api selfhost/build/phase174/qbe-api/report.json \
  --hosted-qualification selfhost/build/phase174/qbe-hosted/report.json \
  --session-bootstrap selfhost/build/phase174/native-session-bootstrap/report.json \
  --session-normal selfhost/build/phase174/native-session-normal/report.json \
  --out selfhost/build/phase174/selectors-proposal01
```

All receipt paths have these defaults but can be overridden to match the actual
qualified directories. Output must be fresh and under `selfhost/build/`.

Only `assets.qbe-n2`, `assets.qbe-api`, `images.qbe-n2`, and `images.qbe-api`
change in the proposed `assets-native.json`, `assets-session.json`, and
`assets-c-request.json`. Updating the C-request map avoids stale hashes for the
same installed QBE files; its C selection and every unrelated row remain exact.
Existing hosted exports cannot be removed, and runtime/Base/provider/toolchain
pins remain unchanged. The helper checks this by restoring those four rows and
requiring equality with each original manifest.

`installable-files.json` maps the existing seven installed QBE paths to their
authenticated Phase174 source artifacts and receipts. `report.json` records
the original and proposed manifest hashes, all input pins, and the frozen
predecessor identity. `installed:false` and `targetsRun:false` remain explicit.
Copying artifacts and publishing these manifests is a separate coordinator
action, followed by default-selector verification.
