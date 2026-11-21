# Publishing and operating a candidate without installing it

A reconstructible source checkpoint and a usable native compiler are separate artifacts. This maintenance proposal can publish the exact checked x86 source, complete map, untouched other profiles, and retained checking/qualification receipts without changing `selfhost/manifests/current.json`, installed images, or operational asset maps. The public `selfhost/bend` and `cli.mjs` launchers continue to use the installed selection.

For the next frozen portfolio, record its exact agreed source SHA256, complete independent zero-hole source-check receipt, and composition audit. Then prepare a source-only checkpoint:

```sh
python3 research/phase198/maintenance/prepare-checkpoint.py \
  --baseline selfhost/build/phase198/selected-source01/maintained \
  --stage selfhost/build/phase198/FROZEN_PORTFOLIO/maintained \
  --source-check selfhost/build/phase198/FROZEN_CHECK/report.json \
  --audit selfhost/build/phase198/FROZEN_PORTFOLIO/audit.json \
  --sha256 AGREED_FULL_SOURCE_SHA256 \
  --out research/phase198/maintenance/checkpoints/FROZEN_NAME
```

The script authenticates the baseline against the existing tracked qualification archive, requires both retained receipts to name the agreed source, verifies the maintained tree emits those bytes, and proves the scoped policy reconstruction and unchanged other profiles. It creates a compressed delta, compact source evidence, pins and summary; it refuses silent file removal or additional shared changes that affect other profiles. The generated `validation/` tree stays untracked.

From a clean checkout containing that checkpoint, source reconstruction uses:

```sh
python3 research/phase198/maintenance/replay.py \
  --recipe research/phase198/maintenance/checkpoints/FROZEN_NAME/replay.json \
  --out research/phase198/maintenance/replay-output-fresh
```

This produces `proof/compiler.bend`, `proof/map.json` and a complete maintained tree using the existing optional x86-only policy proposal. It runs the 29 transport tests and exact byte/map comparisons, and authenticates the retained checker receipt. It does not rerun Lean/Bend checking, acquire a compiler executable, infer native qualification, or install anything. A source checkpoint can therefore be published before a native image is packaged, with that limitation stated explicitly.

## Using an actual published native candidate

The executable package must supply an actual compiler binary plus its complete `bend-native-build` image-binding receipt, its exact compiled-source identity, actual generation, and explicit runtime/Base/toolchain assets. Those artifacts may be acquired into fresh paths; preserve their exact bytes and receipt identities. A source hash alone cannot stand in for the executable or its generation receipt.

The maintained tools already support selecting this image without an installed release. This preflight performs no compiler/target execution:

```sh
python3 -B selfhost/tools/build/request.py \
  --assets PATH_TO_AUTHENTICATED_ASSETS_JSON \
  --image PATH_TO_CANDIDATE_PROGRAM \
  --image-receipt PATH_TO_CANDIDATE_REPORT_JSON \
  --host native --stage ACTUAL_RECORDED_STAGE --target x86 --mode cache \
  --emit object --source INPUT.bend --out FRESH_REQUEST_DIRECTORY \
  --seconds 60 --plan
```

Actual program construction uses the same explicit arguments with `native.py`, under the ordinary resource guard and retention closure. It defaults x86 source builds to direct objects and links with the authenticated ABI11102 runtime. Use `--expected-stdout` only with the actual independent expected output. Keep compiler construction/generation labels and generated-program execution distinct. [Maintained candidate commands](../../../docs/self_hosted/ASSEMBLY.md#build-with-an-explicit-image) describe the full guarded flow.

## Replacing the installed baseline is a separate decision

Phase189's direct-object release required an independent full source check, the real qualified QBE producer → x86 N1 → object-built N2 → actual N3 lineage, complete N2/N3 compiler-object identity, all 64 finite cases and ten runtime controls, and matching runtime ABI/argument convention. The release audit checks actual clean nested compiler jobs and exact source/image/provider identities; renamed stages or matching summary fields do not substitute for those receipts.

A promotion additionally binds the maintained x86 profile to the selected source, keeps the existing JS/C/QBE component records and frozen canonical source identities exact, and selects the actual qualified N2. `release.py audit` is read-only; `install` performs a separately authorized transaction with rollback and publishes the selector last. Operational asset publication and installed public-command controls must agree with the release's `defaultEmission` and runtime. Source reconstruction, a benchmark win, or a standalone candidate command does not perform this installation.

These requirements come from the current `selfhost/tools/build/release.py` implementation and [Phase189 release evidence](../../../implementation/phase189/README.md). The older general `RELEASE.md` describes the original three-component format; the live validator and direct-object tests also handle the independent fourth x86 component.
