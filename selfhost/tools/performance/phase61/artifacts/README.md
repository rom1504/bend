# Phase61 evidence capsule

The closed campaign contains **17,386 files / 882,650,258 uncompressed bytes**.
Its [archive](raw/raw-campaign.tar.gz) is **90,979,618 bytes**, SHA256:

```text
0f3ceb5a8f90686a05469af2bf0ab2b18e9b479e11a14ad18a7f23461ee62d43
```

[archive.json](raw/archive.json) records every member's size and hash. The
streaming publisher reopened and verified every member, then verified that the
original raw tree and its contents remained unchanged. [publication.json](raw/publication.json)
binds the resulting single archive. No compiler or target ran during publication.
Raw writers closed on October 7, 2026, at 16:42:16 UTC.

The capsule preserves successful and failed candidates, profiles, timing
workers, frozen methods, image snapshots, interrupted records, release gates
and prior installed files. The original disk-interrupted build, process-permission
failure, metadata-validator failure and restart-interrupted release wrapper
retain their original status. Successful retries and receipt joins are separate.

## Restore and inspect

From the repository root, restore into an empty raw directory:

```sh
mkdir -p selfhost/build/phase61
tar --keep-old-files -xzf selfhost/tools/performance/phase61/artifacts/raw/raw-campaign.tar.gz \
  -C selfhost/build/phase61
```

The command refuses to overwrite existing files. The archived receipts retain
their original absolute paths under `/home/ai/bend2/build/publish/bend`; moving
the checkout requires fresh input bindings for execution. Do not rewrite a
historical receipt to pretend it came from the new location.

Useful entry points after restoration:

- `final-state08/qualification.json`: final selected release, completed gates
  and explicit reconciliation of interrupted/failed wrapper receipts.
- `state08-b2-latency01/broad420/report.json`: 207 first-request workers across
  23 sources, three roles and three balanced rounds.
- `final-state08/bootstrap/full/compiler.mjs`: genuine B2, reproduced exactly
  as B3; distinct from the installed checked B1.
- `preservation-final.json`: selected installed files, 103 protected files and
  32,973 closed historical files verified.
- `writers-closed.json`: final raw-write boundary and selected artifact hashes.

The [report](../../../../../implementation/phase61/README.md),
[results](../../../../../implementation/phase61/state08-results.md),
[source footprint](../../../../../implementation/phase61/source-footprint.md)
and [fast-loop recipes](../latency/README.md) explain metric and validation scope.
The archive is evidence, not a replacement for the maintained compiler workflow.

## External prerequisites

Execution still requires the pinned upstream checkout
`018751270e800bc222a93dad7f257083ee53a5f7`, Node 24.18.0 and the toolchain versions
named in each plan. Historical reference inputs remain in their separately
preserved Phase58–60 and earlier evidence locations. The October 7 cleanup's
older compressed profiles and restoration mappings are also stored separately;
this capsule does not claim to include those external payloads. See the
[cleanup record](../../../../../implementation/phase61/cleanup.md).

The target-account cutoff precedes documentation and publication. The
[time account](../../../../../implementation/phase61/timing-account.md) reports
observed process wall intervals, including failures, without treating unobserved
elapsed time as waiting or CPU usage.
