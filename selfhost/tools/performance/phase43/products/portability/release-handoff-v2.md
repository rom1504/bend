# Phase43 portable release and evidence handoff

Root executes this only after integration01 semantic owners, frontend/conformance,
full 45 timing, profiles and compiler-cost admission pass for the selected image.
This handoff runs no build, compiler, target, installation or archive itself.
All Phase42 tools/evidence and Phase43 baseline files remain byte-for-byte intact.
Every output is new. Retain a failed/partial publication and choose a new version;
never remove it to reuse an output path.

## Bind the final recipe and installed closure

From repository root, set PHASE43_RECIPE to the latest reviewed materialized recipe, including any
reviewed repair successor; its bindings select
both actual attempt and integration campaign. Do not substitute a prototype API.

```sh
PHASE43_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE43_CPU=3
: "${PHASE43_RECIPE:?Set the absolute latest reviewed materialized Phase43 recipe}"
PHASE43_ATTEMPT=$(python3 - "$PHASE43_RECIPE" <<'PYATTEMPT'
import json,sys
r=json.load(open(sys.argv[1]));assert r['complete'] and r['bound']
print(r['bindings']['ATTEMPT'])
PYATTEMPT
)
PHASE43_OUT=$(python3 - "$PHASE43_RECIPE" <<'PYOUT'
import json,sys
print(json.load(open(sys.argv[1]))['bindings']['OUT'])
PYOUT
)
PHASE43_CATALOG=$PWD/selfhost/tools/performance/phase37/catalog.json
PHASE43_EVIDENCE=$PWD/selfhost/tools/performance/phase43/evidence
```

The installed sequence is the maintained recipe stage, not a second ad hoc
installation. It requires frozen same-attempt/API performance/cost admission and
passing composite-preinstall, including the fresh new-owner contracts:

```sh
python3 selfhost/tools/performance/phase43/validation/run-recipe-v1.py \
  "$PHASE43_RECIPE" --stage postinstall \
  --admission "$PHASE43_OUT/performance-admission.json" \
  --ledger selfhost/build/phase43/campaign.jsonl \
  --jobs "$PHASE43_OUT/postinstall-jobs" --prefix phase43-final-postinstall
```

The current root campaign ledger is campaign.jsonl; postinstall-jobs is a fresh
recipe job directory. The generated recipe has exactly postinstall,
audit-postinstall and composite-postinstall. Require integration01/postinstall-launch,
postinstall-audit and composite-postinstall/report.json; the audit requires
owner-report.json closed with 34 owners (16 inherited +18 new). All selected
reports and process receipts must pass. `release.mjs --verify` is
read-only verification if an additional standalone check is needed; do not run
`--build` here or create new bootstrap provenance. Installation preserves the old
default API/Base/lineage in dist/release-history by original API digest.

## Adapt the retained freezer's three display strings

The Phase42 candidate freezer already validates the actual complete maintained
45-point acquisition, exact selected API/runtime/Base/driver/Node/source hashes,
generic-row serializer, all receipts/logs/consumed tools, streamed bounds and
independent archive reopening. Reuse it with exactly three help/phase-label
substitutions, retaining parent identity. The prepared derivative is the Phase43-labelled helper
at the same directory depth; no validation logic or import paths change.

```sh
python3 - <<'PYFREEZER'
import ast,hashlib,json
from pathlib import Path
parent=Path('selfhost/tools/performance/phase42/validation/freeze-candidate-v1.py')
output=Path('selfhost/tools/performance/phase43/products/freeze-candidate-v1.py')
derivation=json.loads(output.with_suffix('.derivation.json').read_text())
assert derivation['complete'] and derivation['executed'] is False
assert hashlib.sha256(parent.read_bytes()).hexdigest()=='d36aa493d1b52c413902271aa13221dd57aa68eae5c53e46c054ff35ae8886c5'
assert hashlib.sha256(output.read_bytes()).hexdigest()=='140e43d3c10fb4e5f34fd6fae28ec284d965387f419157b7959ecd1f39290e70'
text=parent.read_text()
assert len(derivation['changes'])==3
for row in derivation['changes']:
 assert row['count']==1 and text.count(row['before'])==1
 text=text.replace(row['before'],row['after'])
assert output.read_text()==text
ast.parse(text)
print('Exact three-label derivative verified; no freezer executed')
PYFREEZER
```

The new helper lives at performance/phase43/products, so its existing
HERE.parent.parent/programs and phase37/catalog paths remain correct.
The helper and derivation already exist; the command above verifies them read-only.
Do not overwrite either consumed file.

## Freeze the portable 45 current bundle

Require the final actual full preparation manifest, not diagnostic/instrumented
or handwritten ablations. `current` must not exist. The selected attempt's recipe
bindings identify the acquired compiler; mismatched module/receipt/source/adapter
hashes are rejected by the unchanged freezer.

```sh
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
  --rss-mib 2048 --available-mib 2048 \
  "$PHASE43_OUT/run-freeze-current01" -- \
  taskset -c "$PHASE43_CPU" python3 \
  selfhost/tools/performance/phase43/products/freeze-candidate-v1.py \
  --from "$PHASE43_OUT/full-preparation/manifest.json" \
  --attempt "$PHASE43_ATTEMPT" --catalog "$PHASE43_CATALOG" \
  --out selfhost/tools/performance/phase43/current
```

Success creates current/manifest.json, programs.tar.gz and provenance.json. The
manifest must report complete,45 cases, reopenedVerified and byteExact. Link its
archive bytes/SHA and selected API/source/runtime/attempt identities in published
evidence. The retained Phase43 baseline remains Phase42 checked16 + pinned TS;
do not freeze Phase42's older baseline as the Phase43 denominator.

Use README.template.md as the final phase43/README.md after identities/results
are known. Its links target that final location. Run portable `--plan`, then a
fresh budget20 fast replay and budget60 BST/Map/numeric replay before closure:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog "$PHASE43_CATALOG" \
  --baseline selfhost/tools/performance/phase43/baseline/manifest.json \
  --candidate selfhost/tools/performance/phase43/current/manifest.json \
  --node "$PHASE43_NODE" --cpu "$PHASE43_CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 20 --set fast --plan
python3 selfhost/tools/performance/programs/run.py \
  --catalog "$PHASE43_CATALOG" \
  --baseline selfhost/tools/performance/phase43/baseline/manifest.json \
  --candidate selfhost/tools/performance/phase43/current/manifest.json \
  --node "$PHASE43_NODE" --cpu "$PHASE43_CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 20 --set fast \
  --out "$PHASE43_OUT/portable-fast01"
python3 selfhost/tools/performance/programs/run.py \
  --catalog "$PHASE43_CATALOG" \
  --baseline selfhost/tools/performance/phase43/baseline/manifest.json \
  --candidate selfhost/tools/performance/phase43/current/manifest.json \
  --node "$PHASE43_NODE" --cpu "$PHASE43_CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 60 \
  --cases coverage-bst-64,coverage-map-churn-128,coverage-numeric-recurrence-1024 \
  --out "$PHASE43_OUT/portable-targets01"
```

These are labelled replay smoke checks; their samples never join the clean final
live45 campaign. If full portable remeasurement is wanted, use a separately
labelled campaign with three serial 15-point budget600 batches from the template.

## Close raw writers, then archive outside the campaign

Complete installation/postinstall, every acquisition/timing/profile/diagnostic,
portable replay, protected sweep, final accounting and ledger events first.
Phase43 protected-start currently contains the same 103 unique protected inputs;
the unchanged checker confirms their bytes and that none is staged:

```sh
python3 selfhost/tools/performance/phase42/validation/check-protected-v1.py \
  selfhost/build/phase43/protected-start.json \
  selfhost/build/phase43/protected-final.json
```

Root then stops all raw writers, including agents and ledger appenders. Only once
this is true may root create the declaration outside the raw root. A quiet period
or zero active benchmarks is insufficient if ledger/accounting still writes.
The declaration contains actual checked attempt/API SHA, not placeholders:

```sh
mkdir -p "$PHASE43_EVIDENCE"
python3 - "$PHASE43_ATTEMPT" "$PHASE43_EVIDENCE/writers-closed01.json" <<'PYCLOSED'
import hashlib,json,sys
from pathlib import Path
attempt=Path(sys.argv[1]);manifest=attempt/'attempt.json';a=json.loads(manifest.read_text());out=Path(sys.argv[2]);assert not out.exists()
ident=lambda p:{'file':str(Path(p).resolve()),'sha256':hashlib.sha256(Path(p).read_bytes()).hexdigest()}
api=ident(a['api']['file']);assert api['sha256']==a['api']['sha256']
out.write_text(json.dumps({'complete':True,'writersClosed':True,'rawRoot':str(Path('selfhost/build/phase43').resolve()),'attempt':ident(manifest),'api':api,'closureNote':'Root confirms every target/job/agent/ledger/accounting raw writer stopped. Future publication writes are outside this root.'},indent=2)+'\n')
PYCLOSED
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 900 \
  --rss-mib 2048 --available-mib 2048 \
  "$PHASE43_EVIDENCE/run-publication01" -- \
  taskset -c "$PHASE43_CPU" python3 \
  selfhost/tools/performance/phase42/validation/archive-campaign-v1.py \
  --raw selfhost/build/phase43 \
  --writers-closed "$PHASE43_EVIDENCE/writers-closed01.json" \
  --protected-final selfhost/build/phase43/protected-final.json \
  --out "$PHASE43_EVIDENCE/campaign-archive01"
```

The existing archive/checker JSON kinds retain their Phase42 tool-lineage names;
rawRoot, closure declaration and protected inputs bind Phase43 exactly. No Phase42
raw path is an output. Archive bounds are 2GiB/file, 64GiB total, 500000 members. The
helper captures every regular raw file, rejects symlinks, reopens/hash-checks all
members, rechecks membership/tokens/hashes, and atomically publishes only success.
Failed staging is preserved. The publication supervisor and its logs are outside
rawRoot, so no terminal publication event is appended to the archived ledger.

Finish published selected-release/evidence README after archive digest/size are
known. Index exact final reports by member+SHA+bytes from archive.json, selected
attempt/API, portable baseline/current manifest+archive identities, publication
run.json, writer closure and protected-final. Include failures in the raw archive;
do not let failed prototype receipts satisfy selected release requirements. New
report prose/rendering after closure stays outside rawRoot and is not claimed as
archive content. The evidence README template gives the final receipt inventory.
