# One large retired transport tranche

The strongest candidate is **one old experimental root**,
`selfhost/build/phase140/full-batch01`. Archive exactly these three generated-QBE
transport payloads:

- `001-transport/payload.bin`
- `002-transport/payload.bin`
- `003-transport/payload.bin`

Their total **actual allocated storage is 304.1015625 MiB**. Each is an exclusive
regular file, with stable inode metadata, fresh SHA256 matching both its original
batch product and transport receipt, and no extended attributes. They are three
different products; this is not a duplicate-file claim. Keep the reference
`000-transport/payload.bin` hot.

[storage-proposal04.json](storage-proposal04.json) gives the exact file-level
identities, writer evidence, dependency audit and capture budget. No capture,
compression, pruning or compiler target ran during this review.

## Real headroom and execution cost

Use a **64 MiB hard cap for the complete new archive plus receipts**, with the
usual **5 GiB reserve**. If bounded capture and verification succeed, then applying
this exact selection frees at least **240.1015625 MiB net of those new artifacts**,
excluding unrelated concurrent writers, filesystem effects or open-file retention.
The current-user open-descriptor check found no selected file held open.

Comparable archived QBE from Phase127/128 occupies about 13.5% of its original
allocation. Applying that measured ratio predicts roughly **41.1 MiB archived and
263.0 MiB net recovered** here. That is an estimate; these payloads have not been
compressed. The 64 MiB bound is the enforceable condition, not an assumption that
the estimate will hold. Refuse an oversized archive while retaining original files.

This should make a prospective 300 MiB native-build budget feasible from roughly
130 MiB existing headroom. Actual admission still belongs to the normal disk
guard after reclamation is measured.

Capture all three nested members in one transaction, with one live dependency
review before capture and an immediate review before separate apply. Do not
repeat full Phase173 object-graph scans per member. The bounded current-reference
scan read 236.4 MB across 1,498 files in about 0.3 seconds. Existing comparable
96 MiB QBE archive verification took about 1.1 seconds, with another 1.7 seconds
of archive roundtrip/source checks. Compression and three-member verification
will cost more, but the expected scale is seconds to tens of seconds, not another
22-root maintenance loop. No timing claim for this proposed capture is measured.

## Why this root is eligible

The original batch is complete, experimental, explicitly unselected, has exit
code zero and unchanged recorded inputs. Its writer at
`selfhost/build/phase111/p140-full-batch01-guard/process.json` completed
successfully. This is a legacy terminal experiment without a modern lifecycle;
no sealed closure is being fabricated or reopened.

The transport receipts alone do not attest producer success. The proposal joins
them to the successful outer batch and guard. The batch's
`independentProductsExact` flag is false, so this is preservation of unqualified
experimental evidence, **not** a correctness or qualification claim.

A current-reference audit covered maintained manifests, build/native/profiler
methods, Phase173 test methods and all bounded Phase173 JSON/source artifacts.
It found no reference to this retired batch. An additional scan of all 395
maintained tool source files found no `full-batch01` literal. Actual current
request and binding manifests name their source/API/IR inputs; none names this
transport. Root should repeat the bounded check immediately before action.

Historical Phase140 incremental/replay commands may consume these transport
manifests and payloads. Such reproduction will require restoring the exact
archived members first. All four transport reports, contexts, frame streams,
original methods/jobs/reports/logs, native executables, source snapshots and
runtime/toolchain inputs remain hot. Every Phase173 artifact, qualified chain and
profile is untouched, including the active `plan-capture-binary03`.

## Capture implementation boundary

The existing narrow Phase169 and Phase173 capture adapters do not admit these
nested `payload.bin` members. A separately reviewed bounded streaming capture is
needed. Reuse the maintained `archive-v02.py` verifier/apply/restore machinery
without weakening its exact-byte or inode checks.

Do not use the generic `close.capsule` raw-size scratch reservation unchanged:
it would reserve over 320 MiB even though no uncompressed staging is required.
Instead stream the three source members into a size-capped gzip/tar output with
fixed small buffers, preserving their relative member paths and modes. Enforce
5 GiB free space and the 64 MiB total new-artifact cap, reopen/hash every member,
check unchanged originals, and create an exact allowlisted verification plan.
Root reviews and separately applies that plan. No directory removal is needed.

Other candidates are inferior and remain hot: the 105 MiB Phase171
`lazy-controls01/baseline.json` belongs to a killed failed attempt and begins with
NUL bytes; it is not a demonstrated reusable plan. Phase144 verifier graphs are
smaller. Old Phase147 diagnostic stdout contains QBE but is attached to profiling
evidence. None is needed when this single completed transport batch can provide
the required headroom.
