#!/usr/bin/env python3
"""Hash the completed Phase49 publication; no raw writes or target execution."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def identity(path):
    path = Path(path)
    assert path.is_file() and not path.is_symlink()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    label = path.relative_to(ROOT) if path.is_relative_to(ROOT) else path
    return dict(path=str(label), bytes=path.stat().st_size,
                sha256=digest.hexdigest())


archive = json.loads((HERE / 'raw/archive.json').read_text())
closed = json.loads((HERE / 'writers-closed.json').read_text())
summary_path = ROOT / 'implementation/phase49/evidence/measurements.json'
summary = json.loads(summary_path.read_text())
assert archive['complete'] and archive['reopenedVerified'] and archive['inputStabilityVerified']
assert closed['complete'] and closed['writersClosed'] and summary['complete']
assert Path(archive['rawRoot']).resolve() == ROOT / 'selfhost/build/phase49'
assert archive['api'] == closed['api'] and archive['attempt'] == closed['attempt']
for field, name in [('writersClosed', 'writers-closed.json'), ('protectedFinal', 'protected-final.json')]:
    actual = identity(HERE / name)
    assert all(actual[k] == archive[field][k] for k in ['bytes', 'sha256'])
compressed = identity(HERE / 'raw/raw-campaign.tar.gz')
assert all(compressed[k] == archive['archive'][k] for k in ['bytes', 'sha256'])
for row in summary['inputs']:
    actual = identity(Path(row['file']))
    assert all(actual[k] == row[k] for k in ['bytes', 'sha256'])

roots = ['design/phase49', 'experiments/phase49', 'implementation/phase49',
         'selfhost/tools/performance/phase49']
names = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others',
                                 '--exclude-standard', '--', *roots], cwd=ROOT).decode().split('\0')
maintained = [identity(ROOT / name) for name in sorted(set(names) - {''})
              if ROOT / name != HERE / 'index.json']
prerequisites = ['selfhost/tools/performance/phase48/evidence/index.json',
                 'selfhost/tools/performance/programs/profile.mjs',
                 'selfhost/tools/performance/programs/support.py',
                 'selfhost/tools/performance/phase42/validation/archive-campaign-v1.py',
                 'selfhost/tools/performance/phase42/validation/check-protected-v1.py']
result = dict(kind='phase49-published-evidence-index', complete=True,
              compilerExecuted=False, generatedProgramsExecuted=False,
              producer=identity(Path(__file__)), archive=compressed,
              members=archive['members'], uncompressedBytes=archive['uncompressedBytes'],
              verifiedSummaryInputs=len(summary['inputs']), maintainedInputs=maintained,
              prerequisites=[identity(ROOT / name) for name in prerequisites],
              scope='V8-aware diagnosis only; installed Phase48 RNFA04 is unchanged. '
                    'Unsafe guard derivatives and the incomplete first TS graph remain '
                    'explicitly unqualified. All closed raw files are preserved. '
                    'Index is outside raw and excludes itself.')
with (HERE / 'index.json').open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, maintainedInputs=len(maintained),
                     verifiedSummaryInputs=len(summary['inputs']), members=archive['members'])))
