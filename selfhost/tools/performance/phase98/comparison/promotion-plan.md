# Phase98 native release: corrected2a72 profile

These commands describe the final release sequence. Run target commands only in
the root-owned serial queue, and execute later steps only after the earlier
reports actually pass. Prepared tools and source replay do not qualify an image.

The source is `origin-guard-source01/compiler.bend`, SHA256
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
It contains permission02, held equality, tag-v4 and the minimal lazy ancestor
refusal. The earlier59b36 composition failed full self because eager `&&`
recursed through `Absent`; its sources, failures and profile01 stay preserved.
Cache/redirect variants are excluded. Historical native07 and canonical/installed
JavaScript sources remain unchanged.

## Source replay and actual admission

The default replay profile is now comparison02. It reproduces 1,754,096 bytes from
D04 using 1,376 exact edits and reverses exactly; its compressed delta is 14,812 bytes.
The already completed `profile-replay03.json` binds the current `profile.py` and
actual source. Receipts01/02 retain the prior method hash; do not use them after
the default change. Prior method bytes are in `build/phase98/profile-method01/`.
For a fresh data-only reproduction:

```sh
python3 -B selfhost/tools/native/profile.py --profile selfhost/tools/native/profiles/phase98-comparison02/profile.json --out-source /tmp/compiler-native-phase98.bend --receipt /tmp/compiler-native-phase98-replay.json
```

Frozen snapshot 14 supplies the final gate and collector methods. The exact
prepared target commands are in `build/phase98/origin-final-commands02/commands.json`.
That successor uses `profile-replay03.json`; preparation01 is preserved with its
earlier replay02 argument. Never alter a preserved preparation receipt or a
frozen method. Root's final images are `origin-b1.json`
and `origin-b2.json`, with separate upstream-C and own-C argv policies.

After both self requests, controls, broad45 generated-program execution, native69
per stage plus rejections, backend-specific evidence and all five final-image
control programs pass, collect the actual receipts:

```sh
python3 -B selfhost/build/phase98/qualification-methods14/methods/admit.py \
  --b1-build selfhost/build/phase98/origin-b1.json \
  --b2-build selfhost/build/phase98/origin-b2.json \
  --b1-self selfhost/build/phase98/origin-b1-self01/report.json \
  --b2-self selfhost/build/phase98/origin-b2-self01/report.json \
  --source-recipe selfhost/build/phase98/profile-replay03.json \
  --controls selfhost/build/phase98/origin-controls-native01/report.json \
  --broad45 selfhost/build/phase98/origin-broad45-native01/report.json \
  --conformance selfhost/build/phase98/origin-conformance01/collected.json \
  --backend-policy selfhost/build/phase98/origin-guard-backend-policy01/policy.json \
  --backend-controls selfhost/build/phase98/origin-backend-specific01/report.json \
  --final-controls selfhost/build/phase98/origin-final-controls01/report.json \
  --out selfhost/build/phase98/origin-admission01/report.json
```

The collector checks full raw provenance; build-only/private receipts remain
unchanged. The new admission is explicitly nondefault. B1/B2 self C agreement
is a source-bound consistency gate, not an ELF fixed point or whole-compiler proof.

## Explicit public pointer and CLI gates

Create a temporary pointer from the actual admission, without selecting a default:

```sh
python3 -B - <<'PY'
import hashlib,json
from pathlib import Path
p=Path('selfhost/build/phase98/origin-admission01/report.json').resolve()
b=p.read_bytes();r=json.loads(b)
assert r['complete'] and r['qualified'] and r['defaultSelection'] is False
assert r['source']['sha256']=='2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
assert set(r['stages'])=={'b1','b2'}
selection=dict(kind='bend-native-compiler-selection',version=1,complete=True,
 admission=dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b)),defaultStage='b2')
with Path('selfhost/build/phase98/public-selection02.json').open('x') as f:
 json.dump(selection,f,indent=2);f.write('\n')
PY
python3 -B selfhost/tools/native/cli-controls.py selfhost/build/phase98/public-selection02.json selfhost/build/phase98/origin-controls-native01/report.json selfhost/build/phase98/public-cli02
```

The nine public controls cover both stages' cached Small, live file IO and five
complete Map requests, defaultStage B2, invalid source, changed-admission digest
and no-overwrite refusal. The launcher runs no JavaScript or compiler rebuild.
All target work remains guarded and serial. Keep request directories under
`selfhost/build/native/requests`; those are separate from the Phase98 raw root.

Before selecting the public default, seal and verify the explicit request capsule:

```sh
python3 -B selfhost/tools/native/assets.py seal selfhost/build/phase98/public-selection02.json selfhost/tools/native/releases/phase98-preselection02
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-preselection02/receipt.json --verify-only
```

Only after admission, public controls and archive verification pass, select the
exact pointer. This refuses an existing default rather than silently replacing it:

```sh
python3 -B - <<'PY'
import hashlib,json
from pathlib import Path
p=Path('selfhost/build/phase98/public-selection02.json').resolve();b=p.read_bytes()
c=json.loads(Path('selfhost/build/phase98/public-cli02/report.json').read_text())
assert c['complete'] and c['passed'] and c['inputsUnchanged'] and len(c['rows'])==9
assert c['admission']['selection']==dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
assert json.loads(Path('selfhost/tools/native/releases/phase98-preselection02/receipt.json').read_text())['complete']
with Path('selfhost/tools/native/selection.json').open('xb') as f:f.write(b)
PY
python3 -B selfhost/native.py selfhost/tools/performance/phase77/fixtures/small.bend -o selfhost/build/phase98/public-default02.c
```

Check that last full C against the completed B2 cached-small product before
reporting the default ready. Preserve its request receipt. Then seal the final
capsule so restoration includes the stable default pointer itself:

```sh
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase98-assets02
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json --verify-only
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json
```

The final restore is missing-only and should report zero missing files on the
existing checkout. A fresh machine restore must use the same canonical checkout
root: the Base carrier and evidence receipts contain source-location identities.
Changed existing bytes/modes are refused. Do not rewrite paths or old native07.

## Evidence archive and documentation closure

The public capsule contains both images, source/profile transport and request
assets. It excludes large self-C and raw experiment history. The separate
`phase98/evidence.py` preserves every frozen Phase98 raw file, method, proof,
report and failure, plus native request logs. Each identical byte string is stored
once; the manifest retains every original path/mode. Empty directories survive.
ZIP parts are at most 64 MiB, below 90 MB. Every blob is reopened and fully hashed.
No huge uncompressed staging copy is created, and no input is deleted.

Finish report/scoreboard/ledger and the new `NATIVE_PHASE98.md` guide, preserving
the audit-pinned historical `NATIVE_HOST.md` and `NATIVE_OBSERVERS.md`. Stop all target and
metadata writers, and acknowledge that freeze before running:

```sh
python3 -B selfhost/tools/performance/phase98/evidence.py seal --frozen --public-assets selfhost/tools/native/releases/phase98-assets02/receipt.json --out selfhost/tools/performance/phase98/artifacts/evidence01
python3 -B selfhost/tools/performance/phase98/evidence.py restore selfhost/tools/performance/phase98/artifacts/evidence01/receipt.json --verify-only
python3 -B selfhost/tools/performance/phase98/evidence.py restore selfhost/tools/performance/phase98/artifacts/evidence01/receipt.json
```

Scratch data controls already exercise split ZIPs, deduplication with distinct
modes, missing-only restoration, changed-byte/mode refusal and corrupt-part
refusal, including insufficient spool-plus-parts space; see
`build/phase98/evidence-method-controls02/report.json`. They are
separate from the final campaign seal. The evidence archive records the public
capsule as an external dependency and excludes archive-output directories and
Python bytecode. Earlier-phase toolchains/upstream/history remain external;
restore their preserved capsules first when replay needs them.

Publish compact profile files, methods, reports, final request capsule and evidence
parts/manifests. Do not stage giant untracked dispatch JSON or raw build trees as
text. Keep their compressed/archived forms with the full identities. Report only
actual final-stage timing and finite conformance scope; no full frontend/GPU,
parallel scaling, TypeScript parity or universal compiler-correctness claim.
