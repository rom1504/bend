# Phase105 raw evidence

[`receipt.json`](receipt.json) authenticates [`raw.zip`](raw.zip) and
[`manifest.json`](manifest.json). Each manifest path maps to an object containing
its exact bytes. Identical outputs are stored once. All7,218 paths/4,215 unique
objects were verified after archive construction; no failed runs were omitted.

The capsule includes all five completed campaign directories, complete generated
C, the twelve selected product executables, raw child/guard records and logs,
benchmark sources and pinned measurement methods. Source/method contents were
checked against the recorded input pins while packing. Figures and summary CSV/JSON
are committed alongside the report and can be regenerated from these raw records.

This is evidence preservation, not a standalone compiler distribution. Compiler
binaries, Bun/Clang, historical qualification/oracle receipts and native runtime
assets remain separately pinned prerequisites. See the
[candidate04 guide](../../../docs/self_hosted/NATIVE_PHASE102.md),
[promotion evidence](../../phase102/default-promotion.md) and
[measurement replay guide](../../../selfhost/tools/performance/phase105/README.md).
Original absolute paths in receipts identify the measured environment; restoring
the capsule does not silently rewrite or reauthenticate those bindings.

To inspect the capsule in a fresh directory from the repository root:

```sh
python3 -B - <<'PY'
import hashlib, json, os, zipfile
from pathlib import Path
base = Path('implementation/phase105/evidence')
receipt = json.loads((base/'receipt.json').read_text())
for key in ['archive', 'manifest']:
    item = receipt[key]
    assert hashlib.sha256((base/item['file']).read_bytes()).hexdigest() == item['sha256']
manifest = json.loads((base/'manifest.json').read_text())
out = Path('selfhost/build/phase105-restored').resolve()
out.mkdir(exist_ok=False)
seen = {}
with zipfile.ZipFile(base/'raw.zip') as archive:
    for item in manifest['files']:
        dest = (out/item['file']).resolve()
        assert dest.is_relative_to(out)
        dest.parent.mkdir(parents=True, exist_ok=True)
        key = item['sha256']
        if key in seen:
            os.link(seen[key], dest)
        else:
            data = archive.read('objects/'+key)
            assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == key
            dest.write_bytes(data)
            dest.chmod(item['mode'])
            seen[key] = dest
print(out)
PY
```

This restores observations for analysis; it does not execute any compiler or
benchmark. Running measurements again requires the authenticated toolchain,
current-stage assets and fresh output directories specified in the replay guide.
