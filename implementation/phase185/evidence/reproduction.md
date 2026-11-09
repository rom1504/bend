# Phase185 final evidence and reproduction

`final.json.gz` contains 14,421 exact UTF-8 metadata members (102,710,851 raw bytes), compressed to 16,575,790 bytes. Its SHA256 is `bfa160efa99892f7d0e6ef50dfa760d498ffc5fe86400d26687aa0c419ac312d`. `index.json` identifies the critical receipts, current source snapshots and guard costs. The archive uses the earlier `files[path] = {bytes, sha256, text}` layout; paths are relative to the repository. Original absolute paths inside each text are preserved.

The snapshot includes both complete native bootstrap chains, both passing 64-row gates, the 45-program native acquisition, the 12-row B1/native identity comparison, both final runtime runs, prior profiles/controls and failed attempts, every eligible Phase185 guard/retention record, source maps and snapshot manifests. The QBE seed report and its small archived companions were read directly from the authenticated retention capsule. No product was restored, deleted or rerun while packaging.

Each member is capped at 8 MiB, with a 160 MiB total text cap. 1,986 excluded paths are listed with reasons under `omissions`; generated source, full API modules, assembly/IR, objects and executable bytes are deliberately absent. Their identities remain in receipts. Exact historical executable recovery still requires the retained hot products or their separately verified retention archives. Source recipes alone do not guarantee historical binary identity. `early-screens.json.gz` remains an independent earlier snapshot.

## Verify and inspect without running targets

From the repository root:

```sh
python3 -B - <<'PYVERIFY'
import gzip, hashlib, json
from pathlib import Path
base = Path('implementation/phase185/evidence')
index = json.loads((base/'index.json').read_text())
raw = (base/'final.json.gz').read_bytes()
assert len(raw) == index['archive']['bytes']
assert hashlib.sha256(raw).hexdigest() == index['archive']['sha256']
evidence = json.loads(gzip.decompress(raw))
for name, member in evidence['files'].items():
    data = member['text'].encode('utf-8')
    assert len(data) == member['bytes'], name
    assert hashlib.sha256(data).hexdigest() == member['sha256'], name
print(len(evidence['files']), 'verified members')
print(evidence['files']['selfhost/build/phase185/release-qbe-chain01-guard/process.json']['text'])
PYVERIFY
```

Inspect each selected guard's `process.json` for its exact argv, resource budget, CPU binding and declared roots. The chain reports bind actual N1/N2/final emission generations; generation receipts bind source, runtime, toolchain and product identities. Keep QBE and x86 fixed points separate from semantic qualification. The native64 receipts provide finite conformance observations; B1 identity covers 12 selected products. Runtime reports contain adaptive calibration, rotation, per-invocation output verification and raw samples. Profiles are diagnostic evidence, separate from clean timings.

For a new execution, first supply and authenticate the pinned inputs and installed reference runtime/assets. Use fresh output and guard directories, the shared execution lock and the maintained disk guard with an explicit whole-run budget and the 5 GiB reserve. Preserve recorded CPU3, sequential runtime/GPU-off settings and finite case sets. Replaying commands into existing evidence directories is invalid. Keep native seed outputs until their dependent chain has completed, then use the standard archive/verify/prune lifecycle if reclaiming them. No installation or promotion is implied by these commands or this archive.

## Recorded campaign costs

The archive contains 73 completed outer guard records: 57 successful and 16 unsuccessful. Their wall durations sum to 4184.995 seconds (1.162 hours); the union of guard time intervals is 4184.974 seconds. The span from first start to last finish is 9997.645 seconds and includes gaps. Unfinished guard records: 0.

These are observed guard wall costs, not CPU-hours, total engineering time or billing estimates. Overlapping guard intervals are merged only for the union figure. Do not add nested request, profile or runtime durations again. Maximum sampled process-tree RSS is 2,142,466,048 bytes; maximum allocated storage in any one guarded run is 532,373,504 bytes. Peaks are maxima rather than sums; shared files and other filesystem writers make them unsuitable for cumulative storage accounting.
