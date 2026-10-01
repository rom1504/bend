#!/usr/bin/env python3
"""Publish compact copies of completed Phase37 release receipts; run no targets."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RAW = ROOT/'selfhost/build/phase37'
API = 'ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1'

def identity(file):
    file = Path(file).resolve()
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)

def read(file):
    return json.loads(Path(file).read_text())

def save(file, value):
    with Path(file).open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')

gates_file = RAW/'postinstall-audit01/gates.json'
gates = read(gates_file)
assert gates['complete'] and gates['pass'] and gates['postInstallChecked']
assert gates['api']['sha256'] == API
assert len(gates['gates']) == 15 and all(x['accepted'] for x in gates['gates'])
assert gates['canonicalSource'] == dict(accepted=True, changes=[], snapshotSources=227)
owners = RAW/'phase36-owner-close02/report.json'
new_owners = RAW/'new-owner-close02.json'
for file, count in [(owners, 7), (new_owners, 3)]:
    result = read(file)
    assert result['complete'] and result['pass'] and len(result['cases']) == count
    assert result['api']['sha256'] == API
launcher = read(RAW/'final-plan01/release-smoke/launcher.json')
checks_file = Path(launcher['checks']['file'])
assert identity(checks_file)['sha256'] == launcher['checks']['sha256']
checks = read(checks_file)
assert checks['pass'] and checks['apiSha256'] == API and len(checks['steps']) == 42
manifest_file = ROOT/'selfhost/dist/release.json'
release = read(manifest_file)
files, checkout = [], []
for field, rows in [('files', files), ('checkout', checkout)]:
    for ref in release[field]:
        actual = identity(ROOT/'selfhost'/ref['path'])
        assert actual['sha256'] == ref['sha256'] and actual['bytes'] == ref['bytes']
        rows.append(actual)
assert len(files) == 6 and files[0]['sha256'] == API
out = HERE/'final-conformance'
out.mkdir(exist_ok=False)
(out/'gates.json').write_bytes(gates_file.read_bytes())
text = (RAW/'postinstall-audit01/gates.md').read_text()
assert text.startswith('# Phase35 final gate closure')
text = text.replace('# Phase35 final gate closure', '# Phase37 final gate closure', 1)
text += '\nPublication changes only the inherited Markdown heading. The JSON is a byte-identical copy of the final audited receipt. Phase36 and Phase37 owner closures remain separately required and linked by the phase report.\n'
(out/'gates.md').write_text(text)
(HERE/'release-cli.json').write_bytes(checks_file.read_bytes())
save(HERE/'release-installation.json', dict(kind='phase37-installed-release-record',
    complete=True, api=API, manifest=identity(manifest_file), files=files,
    checkout=checkout, lineage=release['lineage'], gates=identity(gates_file),
    phase36Owners=identity(owners), newOwners=identity(new_owners),
    cli=identity(checks_file), producer=identity(__file__)))
print(json.dumps(dict(complete=True, api=API, gates=15, cli=42,
                     installedFiles=len(files), checkoutFiles=len(checkout))))
