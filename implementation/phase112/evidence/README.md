# Phase112 compact evidence capsule

The coordinator should prepare and seal evidence only after the intended
measurements and reports have stopped changing. No capsule has been produced
merely by adding this tool or this README.

Run the final offline [time accounting](../time-use.md) before planning the
capsule. Its JSON under `selfhost/build/phase112/` is then captured alongside
the original guard receipts. Phase111 `p112-*` native emission, build and
self-reproduction receipts are already in scope; no extra collection is needed.

From the repository root, using fresh names:

```sh
python3 -B selfhost/tools/performance/phase112/seal-evidence.py plan \
  --out implementation/phase112/evidence/plan01.json
python3 -B selfhost/tools/performance/phase112/seal-evidence.py seal \
  --plan implementation/phase112/evidence/plan01.json \
  --out implementation/phase112/evidence/capsule01.tar.gz
```

Planning reads `selfhost/build/phase112/` and each immediate
`selfhost/build/phase111/p112-*` scope. Every JSON receipt is captured exactly,
including failures, incomplete attempts, superseded variants, guards and
per-stage measurements. Malformed JSON is retained with its parse diagnostic.
Small stdout/stderr/log files are exact; logs over64KiB retain an explicit
head/tail excerpt and the complete original's byte count/SHA256. An excerpt is
never labelled a complete output. The original large log remains local.

Source modules, generated APIs and directly pinned source/API dependencies are
hashed but their payloads are excluded. Current source identities and historical
receipt identities are separate, with any differences recorded. The tool does
not recursively collect earlier phases or scan the home directory. Generated
binaries, IR, assembly and objects are not archived; their recorded receipt pins
remain in the capsule. No compiler or target is launched.

Limits are16MiB per exact JSON receipt,64MiB unique raw receipt/log payload and
8MiB compressed archive. The initial preflight refused the9,482,169-byte compiler
profile under its8MiB JSON cap. An explicit inventory found1,798 JSON files,
49,827,591 total bytes and48,432,568 unique bytes; the original32MiB payload
cap could not preserve them. These finite limits were raised before sealing to
retain complete profiles and every failed receipt, rather than dropping evidence. Exceeding a limit fails explicitly; it does not silently
omit failure evidence or relax the cap. Inspect the plan before sealing. If a
large JSON is actually a graph dump, design a separate, explicit summary while
retaining that original and its pin. The normal sealer does not reinterpret a
large receipt or substitute a benchmark definition.

The content-addressed archive contains `index.json`, `summary.json` and
`blobs/sha256/HASH`. It deduplicates identical raw receipts. Source/API pins and
payload hashes are rechecked during sealing; the archive is reopened and every
member verified before its final name is published. The adjacent manifest pins
the archive, plan and method and records exact captures versus excerpts. Failed
partial archives and their error manifests remain available; outputs are never
overwritten or deleted.

The summary retains individual results/error messages and guard statuses. It
does not sum overlapping parent/child timings, infer unique test counts, report
an aggregate speedup or claim promotion. Use the phase report for interpretation.

To restore evidence, read `index.json`, select an entry with `payload=true` and
`capture="exact"`, retrieve its blob, and verify both payload and original hashes
before writing a new staging file. Excerpt and identity-only entries cannot
restore the original artifact and do **not** authorize deleting local inputs.
The earlier hardlink cleanup receipts retain their own metadata/byte guarantees.
