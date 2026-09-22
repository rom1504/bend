# Final private image archive, version 1

This archive preserves the two immutable private compiler images consumed by the final Phase 4 runs. It is historical artifact preservation, not a new build, bootstrap, performance result or completion of a running correctness gate. The root reports record those gates separately.

| Restored directory | Image SHA-256 | Recorded files, including manifest |
| --- | --- | ---: |
| `scope-fixed` | `61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1` | 29 |
| `profile-combined` | `4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3` | 33 |

The first image is the corrected ordinary private specialization. The second explicitly selects `phase4-boolean-stable`; it is not the default. Each image's original manifest is restored verbatim, including the default's historically absent `optimizationProfile` field. The [profile review](../private-profile-review.md) describes the separate packaging and semantic scope.

[manifest.json](manifest.json) records every original artifact and manifest identity, original directories, object hashes, before/after capture identities and storage accounting. The 62 files total **9,858,006 bytes**. Their 36 distinct contents total **6,967,949 bytes**. Deterministic local gzip objects occupy **591,512 bytes**; four repository-relative objects reuse **392,575 bytes** from the [final-source capsule](../final-source-capsule/README.md), rather than storing its B1, H, source and runtime again. Keep both archive directories together.

## Verify or extract

Using Python 3 standard libraries, from the repository root:

```sh
python3 implementation/phase4/private-final-images/extract.py --verify-only
python3 implementation/phase4/private-final-images/extract.py /tmp/bend-private-images-NEW
```

The destination must not exist and its parent must exist. The extractor verifies every compressed/uncompressed object hash and length, both historical image inventories and their recorded artifact hashes, image identities, completed historical image status and selected profile before creating output. It restores both subdirectories and writes a separate `extraction-record.json` with `newBootstrap: false` and `newPrivateBuild: false`. It neither edits historical manifests nor substitutes new paths in their proofs.

An existing destination, changed object or unsafe artifact path fails. A filesystem failure during writing may leave an incomplete new directory; it is not a successful restoration. The five focused [tests](extract_test.py) cover exact restoration, existing-output preservation, local/shared-object corruption and unsafe output paths. [verification.json](verification.json) records the actual restore and [tests.log](tests.log) records the test result. No compiler execution, image rebuild or timing experiment was needed.

Only each image's recorded `manifest.artifacts` plus its original manifest are archived. Mutable Base caches, request outputs, measurements, worker logs and other unrecorded files are excluded. The [creation-tool snapshot](creation-tool.py) records the one-time capture procedure at its original absolute checkout; it is not the portable extraction entrypoint and refuses an already populated object directory.

## Historical provenance and reuse limits

The original source images lived under `/home/ai/bend2/build/publish/bend/selfhost/build/phase4/private/`. Their manifests retain original tool/source/proof paths and canonical Base at `/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream/bend2/base.bend`, SHA `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946`. The original driver was the frozen `build/phase4/combined-host/tools/typed-driver.mjs`. Exact consumed host/helper and runner bytes are included at each recorded relative artifact path.

Restoration itself needs only these versioned archives. Executing or replaying a historical protocol has additional requirements: the canonical Base must exist with its recorded identity, Node/resource settings and input module identities must be selected explicitly, and any command that revalidates original proof/build inputs needs their original paths or a separately documented new configuration. This archive does not claim an automatically relocatable protocol and does not rewrite old proof paths to manufacture one. The existing sealed-image verifier remains authoritative before execution.

A frozen image can serve as a checked compiler for a fresh experiment with newly recorded inputs. It does not prove that newly edited compiler source has been checked. The private transport remains text/path-only; extraction does not authorize exposing raw function objects or mutable compiler graphs as a supported public API. Use the [normal development workflow](../../../docs/PHASE4_DEVELOPMENT.md) for changed-source validation and keep future artifact versions separate.
