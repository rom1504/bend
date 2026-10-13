# Phase85 evidence capsule

`phase85.zip` contains all910 new raw files (155,439,019 bytes uncompressed),
including original incomplete diagnostic methods, plans, every target receipt,
complete C, traces/profiles, filtered assembly, rejected generated image and its
genuinely prepared Base cache. Its17,386,595 bytes are bound by
[manifest.json](manifest.json) and the [verified receipt](../../../../../implementation/phase85/evidence.json).
Every member was reopened and checked against its original size/SHA256.

Restore paths from repository root:

```sh
python3 -m zipfile -e selfhost/tools/performance/phase85/evidence01/phase85.zip .
```

Do not extract over modified evidence. Frozen plans also depend on historical
inputs, retained in the [Phase83 capsule](../../phase83/evidence01/),
[Phase82 capsule](../../phase82/evidence01/README.md) and their linked parent
archives. They are intentionally not duplicated here. The upstream checkout and
Node executable are identified by version/commit and exact hashes in each plan.
Historical absolute paths use `/home/ai/bend2/build/publish/bend`; restore that
layout or explicitly rebind and validate a new experiment instead of silently
altering the recorded one.

`summary-initial.json` preserves the earlier summary result; its producing source
revision is in commit a906937. `summary-final.json` and the compact published
tables retain final scope/classification. `timeline01` lacks phase markers and
is not a valid phase-attribution source. `timeline02` has explicit PID/hrtime
markers. `bytecode01` preserves the overbroad leading-wildcard filter; later exact
filters are separate runs. The lexer-choice image is unchecked and rejected.

No raw Phase85 path was deleted or changed by archiving. No prior seal was changed.
