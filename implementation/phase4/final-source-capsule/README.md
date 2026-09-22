# Final Phase 4 compiler capsule, version 1

This versioned capsule preserves the actual checked B1 API, the byte-identical stage2/stage3 H library, assembled Bend compiler source and runtime from the [completed fixed point](../final-source.md). The four deterministic gzip files total **392,575 bytes**. No generated compiler replaces `dist`, and extraction does not run or claim a new bootstrap.

| Extracted file | Uncompressed bytes | Role |
| --- | ---: | --- |
| `b1.mjs` | 1,014,729 | Actual combined checked-overlay B1 API, with its recorded 63 export roots |
| `h.mjs` | 1,143,517 | One copy of the exact equal stage2/stage3 H library |
| `compiler.bend` | 589,702 | Exact assembled source compiled by both proof stages |
| `runtime.mjs` | 39,290 | Exact runtime paired with those stages |

[manifest.json](manifest.json) records full SHA-256 hashes, compressed hashes, lengths, original absolute paths, before/after creation identities, canonical Base, host identities and the actual checked export list. It links the existing [checked-build report](../final-source-evidence/checked-build.json.gz) and [completed self-reproduction report](../final-source-evidence/fixedpoint.json), whose bytes are preserved. The checked B1 here is the 63-export experimental API used in that proof, not the separate normal 54-export development API.

## Verify or extract

From the repository root, using Python 3 standard libraries only:

```sh
python3 implementation/phase4/final-source-capsule/extract.py --verify-only
python3 implementation/phase4/final-source-capsule/extract.py /tmp/bend-phase4-capsule-NEW
```

The output directory must not exist; its parent must exist. All compressed and restored hashes, lengths and proof identities are checked before creating it. The extractor also requires successful checked B1 provenance, both successful historical stages, and equal H hashes. It writes four files plus an `extraction-record.json` explicitly stating `newBootstrap: false`. It does not alter or relocate provenance reports, create host/cache configuration or overwrite existing output. Corruption, incomplete proof or an existing destination fails the command. A filesystem write failure may leave an incomplete newly created directory, which is not a successful extraction.

Run the five focused tests with:

```sh
python3 implementation/phase4/final-source-capsule/extract_test.py
```

[verification.json](verification.json) records actual gzip restoration and the test result. These are artifact-preservation checks; no extra compiler build was run.

## Reuse and historical path requirements

These files allow an experiment to reuse an already checked frozen compiler immediately. This does **not** validate changed compiler source. Use the [normal checked development loop](../../../docs/PHASE4_DEVELOPMENT.md) for source edits, and create fresh experiment/provenance records when the compiler, host, runtime, inputs or roots change.

The original proof and checked-build reports contain absolute paths under `/home/ai/bend2/build/publish/bend/selfhost/`, including `build/phase4/combined-checked/compiler.bend`, `build/phase4/combined-host/tools/typed-driver.mjs` and `.bootstrap/upstream/bend2/base.bend`. Those paths describe the historical run; extraction deliberately leaves them unchanged. Source and Base module identities also affect output bytes and root policy. An exact historical replay needs those canonical module paths, pinned Base SHA `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946`, the recorded frozen host/helper bytes, and upstream revision `6018e28ecc67cf1fffc0c20c64b11023474c2df8`.

This capsule does not bundle the upstream checkout, canonical Base, host helpers, all 59 separate source modules, native compiler or private optimization images. Their identities and available evidence remain in the existing reports. A new location or current host requires an explicit new run configuration and identity checks; do not rewrite historical report paths and present them as a newly checked bootstrap. Verification/extraction alone needs none of those original absolute files: it uses this capsule and its two repository-relative archived proof reports.
