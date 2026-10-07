# State08 evidence closure recipe

Prepared from existing methods; no archive, installation or target is run by
this document. Root closes the campaign only after all targets, report writers,
accounting and preservation checks finish. Run the hash-heavy steps outside
compiler timing. The selected attempt remains `checked-state08` unless root
explicitly replaces it and prepares new evidence bindings.

## Resolve the preserved checked-stage failure

The original `final-state08/checked-execution/report.json` remains failed:
composition acquisition succeeded, but all 36 controller child launches
reported `spawnSync Node EPERM`. Recorded observations alone are not admitted
as healthy executions. `checked-resume02-plan.json` reuses only that acquisition,
retries the identical controller into `composition-controls-retry02`, and keeps
the remaining twelve commands, guards, inputs and oracles unchanged.

After the complete healthy retry, outside timing, root runs this data-only join:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/resolve-checked.py \
  --final-root selfhost/build/phase61/final-state08 \
  --out selfhost/build/phase61/final-state08/checked-resolution.json
```

It requires the original acquisition success, the preserved failure, all 13
healthy retry commands, the unchanged 18/18 composition oracles, exact command
substitution and final input hashes. Its 14 logical jobs comprise one reused
successful acquisition and 13 healthy executions. The original queue stays
failed. Bind this resolution receipt, original queue and retry queue in the
final qualification index; do not require or invent an original-queue PASS.

The frozen release planner only produces guarded commands. It neither consumes
nor overrides the checked-stage result. Root's release admission must use this
explicit resolution alongside completed bootstrap, B2, program and measurement
gates. No release-plan/controller successor or oracle exception is needed.

## Final checks and writer closure

The seven prior installed files are already preserved in `prior-release`.
Do not rerun the capture step. Before installation use a fresh preservation
receipt with `--installed unchanged`; after the existing five release steps
(install, verify, legacy42, default24, verify) use selected mode:

```sh
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/preservation.py \
  --installed selected --attempt selfhost/build/phase61/checked-state08 \
  --out selfhost/build/phase61/preservation-final.json
taskset -c 0 python3 -B selfhost/tools/performance/phase51/check-protected.py \
  selfhost/build/phase61/protected-final.json
```

The preservation method retains installed7, protected103, exact closed Phase58–60
inventories and selected derivation lineage. Finish time accounting and all
report/index writes before root writes `writers-closed.json`. That final
declaration requires `complete:true`, `writersClosed:true`, the absolute Phase61
`rawRoot`, and real selected `attempt`/`api` file/SHA256 identities. An idle target
slot is not writer closure. Do not create that declaration in advance.

## Stream, reopen, verify, publish

After closure, reuse the existing producers directly. Keep their stdout and any
failure logs outside raw; do not wrap them in a launcher which appends raw logs.
The archive destination must be fresh. These commands preserve every regular
raw file, including failed candidates, interrupted guards and raw profiles.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase61 \
  --out selfhost/tools/performance/phase61/artifacts/raw \
  --writers-closed selfhost/build/phase61/writers-closed.json \
  --protected-final selfhost/build/phase61/protected-final.json
taskset -c 0 python3 -B selfhost/build/phase61/preservation-method01/publication/publish-parts.py \
  --archive-dir selfhost/tools/performance/phase61/artifacts/raw
```

The archive method (`4d393286e9a3e26892ff52bb242f53f1ea3211a82caeee3ef79a52b4597cfaa6`)
streams tar/gzip without a second uncompressed tree. It hashes each source,
reopens every archive member and verifies bytes/SHA256, compares the raw file
set/stat tokens, then rehashes raw content before publishing. Its limits are
2 GiB/file, 64 GiB total and 500,000 members. Symlinks are rejected. Do not delete
failed staging output or raw evidence to make a retry look successful.

Durable metadata is outside raw at `artifacts/raw/archive.json` and
`publication.json`. The former includes every member identity and explicit
`reopenedVerified`/`inputStabilityVerified`; the latter binds the archive and its
publication form. Below 100,000,000 bytes, track the single archive. Otherwise
the existing publisher creates ordered 48 MiB parts, verifies their concatenated
hash/length and ignores the full local archive for Git. Track the parts and both
metadata files. No second capsule or large evidence-copy scheme is needed.

## Provisional capacity estimate

A metadata-only walk at **2026-10-07 16:13:28 UTC**, while writers remained open,
found 12,970 regular files: **748,034,823 logical bytes**, 780,144,640 allocated
bytes, no symlinks, and a largest file of 24,525,740 bytes. This is an estimate,
not the final archive inventory. Existing Phase58/59/60 archive-to-raw ratios
were approximately 8.6%/6.2%/4.1%; applying those only as planning anchors gives
roughly 30–65 MB for this checkpoint. Final composition may differ.

With the reported 19 GB free, capacity is ample for the current tree. Reserve
about **3 GB additional space** for final growth, tar overhead, the archive and
optional part copies; recheck free space after writer closure. Do not promise
the capsule will fit one GitHub file until its actual compressed size is known.
