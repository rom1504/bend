# Versioned native89 launcher

`native.py SOURCE --image IMAGE -o NEW_OUTPUT.c [--live]` reuses Phase88's CLI,
guard, request logs and atomic output publication. Its private module instance
replaces authentication only. Compilation remains in the recorded native Bend
image. The default mode uses the exact qualified prepared Base carrier; `--live`
checks/prepares Base in the native process. Existing `--calls 1|5` and
`--seconds 1..600` options remain available. Unsupported effects/imports and
compiler refusals remain refusals with retained request evidence.

The qualified image is `selfhost/build/phase89/compiler-native-self01`, SHA256
`8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45`;
its source is `4584cf08…` and C is `b1560234…`. Root prepared the admission
manifest after this exact image passed eight live/cache exact-C gates and its
own broad 45-point gate. `ADMISSION_SHA` now pins manifest SHA256
`9201ff03499900ed108b28b59ab24ecc79ccb7e9c64bb5765b105db7763a9a50`.
The wrapper passed all ten separate controls in
[`launcher-controls01/report.json`](../../../build/phase89/launcher-controls01/report.json)
(SHA256 `0c29802279ef9ccce0bf2d245184e7f923cc7f560573f19a794cf39473863898`).
Cached and live Small/file-IO emissions match the independent full-C oracles.
The public CLI refuses an old image, alternate cache-receipt path, extra import,
unaudited IO.sleep effect and existing output; the existing output stays exact.
A private module-instance test also rejects a changed manifest. The tests do not
mutate providers or the actual admission manifest. They do not execute the
generated programs.

The admitted providers are args, print, now, print_err, file_open, file_read,
file_size, file_write and file_close. All nine are checked before and after each
request. This extends available IO providers without granting scalar-array or
observer optimization permission to file effects.

For a future version, offline preparation remains:

```sh
python3 -B selfhost/tools/performance/phase89/admission.py prepare \
  EXACT_IMAGE EXACT_GATES.json EXACT_BROAD_REPORT.json NEW_PROPOSED_MANIFEST.json
```

Preparation validates real source/C/build authentication, successful process and
output identities, all nine providers, the prepared-cache binding and complete
broad coverage. It runs no targets and does not automatically admit a proposal.
Review new proofs and pin the actual manifest digest explicitly; no placeholder
binary or C digest can qualify. Check the current admission without running the
compiler:

```sh
python3 -B selfhost/tools/performance/phase89/admission.py check \
  selfhost/build/phase89/compiler-native-self01
python3 -B selfhost/tools/performance/phase89/admission.py check \
  selfhost/build/phase89/compiler-native-self01 --live
```

Authentication repeats before/after each request via the reused launcher. Its
returned record includes the wrapper, admission module, reused launcher, support
and guard identities, alongside sealed proof and nine-effect identities. Thus
the historical launcher's `method` field is not the only method attribution.
Any other image, source/C/build tuple, cache receipt path, altered provider or
changed proof/manifest must refuse. The ten-control run verifies those selected refusals and live/cache publication;
it does not claim exhaustive mutation or crash-fault testing.

Only frozen acquisition products and proof receipts remain launcher dependencies.
The 145 inherited mutable production-module paths in historical acquisitions
remain archived provenance, not live source requirements. The existing Phase88
cache authenticator is reused, so its preserved original image and cache assets
are still dependencies; no cache protocol implementation is copied.

`restore.py` reads sealed `implementation/phase89/evidence02.json` and
`evidence03.json`. Each has relative `archive` and `manifest` identity records.
At least one also names a pinned `nativeAssets` JSON with
`{canonicalRoot, files, executable}`. `files` selects only required Phase89
assets from these capsules; shared Phase88 assets must first be restored by
`phase88/restore.py`. A later capsule supplies any superseding same-path member.
Restoration refuses changed existing bytes and requires a 160 MiB disk reserve;
`--verify-only` checks selected archive members without writing or executing.
Normal restoration authenticates the resulting exact image without running it.
Evidence03 and its nativeAssets selection are sealed. All12 selected assets
verify, and a real missing-executable recovery restored the exact admitted bytes
and executable mode. See [the restoration receipt](../../../../implementation/phase89/restoration.json).
Missing qualification/capsule files still refuse.

The native build profile retains owned composition and ordered body chunks as
isolated source changes (+93 compiler lines). Canonical production modules and
the installed Phase82 JS B2 remain unchanged: separate ordinary JS B1 screens
found 4.11% slower requests for combined chunks and 1.15% slower for owned-only
across six cases. See [JS integration](../../../../implementation/phase89/js-integration.md).

The full self-source attempt reached its 600-second deadline (600.022 seconds
wall, peak tree RSS 1,079,590,912 bytes) without emitted C. This was a deadline
stop, not OOM. The successful immutable eight-gate receipt is separate from that
failed optional self-emission attempt. No native B2 was built or executed;
complete-language conformance and newly measured generated-program execution
speed are not implied by launcher admission.

Root-run verification and asset selection use these separate methods:

```sh
python3 -B selfhost/tools/performance/phase89/launcher-controls.py \
  selfhost/build/phase89/launcher-controls02
python3 -B selfhost/tools/performance/phase89/native-assets.py NEW_NATIVE_ASSETS.json
```

Choose a fresh controls directory. The controls copy complete native request
evidence into their Phase89 directory with original/copy hash mappings for
capsule retention. The asset generator runs no targets and deletes nothing: it
selects actual authenticated Phase89 image/source/C/build/proof dependencies,
including the build guard. Shared dependencies are tracked repository files
(including all nine providers) plus the preserved Phase88 cache/runtime chain.
Historical mutable production acquisition inputs are excluded. Bind the
generated selection in evidence03 before running restore verification.
