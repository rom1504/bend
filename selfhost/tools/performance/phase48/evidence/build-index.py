#!/usr/bin/env python3
"""Index completed Phase48 publications; no raw writes or target execution."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def identity(path):
    path = Path(path)
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return dict(path=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                sha256=h.hexdigest())


def read(name):
    return json.loads((HERE / name).read_text())


assert not (HERE / 'index.json').exists()
selected = read('selected-qualification.json')
assert selected['complete'] and selected['passed']
assert selected['points'] == 45 and selected['samples'] == 669
assert selected['cliSteps'] == 42 and selected['compilerRequests'] == 18
closed = read('writers-closed.json')
assert closed['complete'] and closed['writersClosed']
archive = read('raw/archive.json')
parts = read('raw/parts.json')
assert archive['complete'] and archive['reopenedVerified'] and archive['inputStabilityVerified']
assert parts['complete'] and parts['concatenationVerified']
assert parts['archive'] == archive['archive']
assert archive['api'] == selected['api'] and archive['attempt'] == selected['attempt']
assert Path(archive['rawRoot']).resolve() == ROOT / 'selfhost/build/phase48'
for field, name in [('writersClosed', 'writers-closed.json'), ('protectedFinal', 'protected-final.json')]:
    actual = identity(HERE / name)
    assert all(actual[k] == archive[field][k] for k in ['bytes', 'sha256'])
h = hashlib.sha256()
total = 0
for row in parts['parts']:
    path = HERE / 'raw' / row['path']
    actual = identity(path)
    assert all(actual[k] == row[k] for k in ['bytes', 'sha256'])
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
            total += len(chunk)
assert total == archive['archive']['bytes'] and h.hexdigest() == archive['archive']['sha256']

receipts = ['selected-qualification.json', 'semantic-qualification.json',
            'installed-release.json', 'source-reconciliation.json',
            'writers-closed.json', 'protected-final.json',
            'raw/archive.json', 'raw/parts.json']
prior_rows = json.loads(
    (HERE.parent.parent / 'phase47/evidence/index.json').read_text())['prerequisites']
for row in prior_rows:
    assert identity(ROOT / row['path']) == row, 'Changed predecessor prerequisite'
prerequisites = [r['path'] for r in prior_rows]
prerequisites += ['selfhost/tools/performance/phase47/evidence/index.json',
                  'selfhost/tools/performance/phase47/evidence/raw/archive.json',
                  'selfhost/tools/performance/phase47/evidence/raw/parts.json']
roots = ['design/phase48', 'experiments/phase48', 'implementation/phase48',
         'selfhost/tools/performance/phase48', 'docs/self_hosted/phase48-representations.md']
names = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others',
                                 '--exclude-standard', '--', *roots], cwd=ROOT).decode().split('\0')
maintained = []
for name in sorted(set(names) - {''}):
    path = ROOT / name
    if path == HERE / 'index.json' or path.is_relative_to(HERE / 'raw'):
        continue
    assert path.is_file() and not path.is_symlink()
    maintained.append(identity(path))
result = dict(kind='phase48-published-evidence-index', complete=True,
              compilerExecuted=False, generatedProgramsExecuted=False,
              producer=identity(Path(__file__)),
              receipts={n: identity(HERE / n) for n in receipts},
              archive=archive['archive'], members=archive['members'],
              uncompressedBytes=archive['uncompressedBytes'], parts=parts['parts'],
              maintainedInputs=maintained,
              prerequisites=[identity(ROOT / n) for n in prerequisites],
              scope='Installed RNFA04, completed reports and complete closed raw capsule. '
                    'Failed/unselected experiments remain unqualified. Absolute historical '
                    'receipt paths retained. Frontend scope remains historical; no new fixed point. '
                    'Index is outside raw and does not include itself.')
for row in [*result['receipts'].values(), *maintained, *result['prerequisites']]:
    assert identity(ROOT / row['path']) == row
with (HERE / 'index.json').open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, maintainedInputs=len(maintained), members=archive['members'])))
