# Exact retired transport capture

`capture-transport-v04.py` is restricted to the SHA256-pinned proposal04 and its
three named `001/002/003-transport/payload.bin` members. It never executes compiler
targets, deletes files, applies a plan, or changes an original retention record.

The adapter holds the existing shared lock for the whole operation. It checks
the successful unselected batch/guard, complete transport receipts, original
hashes/inodes, exclusive ownership and retained payload000 identity. A bounded
streaming scan checks current manifest, tool and Phase173 paths before and after
capture. It does not parse or recursively traverse compiler object graphs.

Capture needs **5 GiB free plus 64 MiB scratch**. Only the three selected files
are streamed into gzip/tar. The compressed file has a hard **60 MiB limit**,
leaving 4 MiB for receipts and allocation overhead inside the **64 MiB total fresh
output cap**. Physical allocation and free space are monitored. No uncompressed
archive or temporary copy of the 304 MiB input is created.

The archive is reopened as a stream; every member name, kind, size, mode, owner,
timestamp and byte hash is checked, including the gzip footer. Original source
identities and current references are rechecked. The unchanged maintained
`archive-v02.py` then independently verifies the archive and emits a prune plan.
Its exact path/size/hash selection must equal the three-file proposal. All
unlisted files, source/runtime/binary/profile evidence and payload000 stay hot.

Root may run these steps serially after reviewing the adapter:

```sh
python3 -B experiments/phase173/capture-transport-v04.py --check-only
python3 -B experiments/phase173/capture-transport-v04.py \
  --out selfhost/build-retention/phase173/capture04-p140-full-batch01
```

Inspect `capture.json`, `receipt.json` and `verified/plan.json`. Repeat metadata
admission immediately before the separate root-owned apply:

```sh
python3 -B experiments/phase173/capture-transport-v04.py --check-only
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase173/capture04-p140-full-batch01/verified/plan.json \
  --out selfhost/build-retention/phase173/capture04-p140-full-batch01/applied
```

Restore with the same maintained tool and verified plan, using `restore` and a
fresh receipt directory. A failed capture keeps original files and partial
diagnostic evidence; it must never be treated as a valid apply plan. The tools'
shared lock is nonblocking, so contention refuses rather than queues.

Validation by the implementing agent was limited to AST/static inspection,
authentication of the frozen proposal/verifier identities, and source review.
No capture, adapter preflight, apply, archive compression or target execution ran.
