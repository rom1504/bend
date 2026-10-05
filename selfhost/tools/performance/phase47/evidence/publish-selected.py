#!/usr/bin/env python3
"""Data-only join of completed Phase47 receipts; never executes a compiler."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase47'
OUT = Path(__file__).resolve().parent


def identity(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def load(path, require_pass=True):
    data = json.loads(path.read_text())
    assert data['complete'] is True, path
    if require_pass:
        assert data['pass'] is True, path
    return data


def main():
    assert (ROOT / 'selfhost/src/compiler.json').is_file()
    attempt_path = RAW / 'checked-array06/attempt.json'
    attempt = json.loads(attempt_path.read_text())
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    installed_path = RAW / 'release06/installed-release.json'
    installed = load(installed_path, False)
    assert installed['inputsUnchanged'] and installed['maintainedSuites'] == 8 and installed['cliSteps'] == 42
    for role in ('api', 'runtime', 'base'):
        row = attempt[role]
        assert identity(row['file'])['sha256'] == row['sha256']
        if role in installed:
            assert installed[role]['sha256'] == row['sha256']
    assert attempt['api']['sha256'] == '28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
    assert attempt['runtime']['sha256'] == '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
    reports = {
        'focused': RAW / 'checked-array06/validation-001/report.json',
        'maintained': RAW / 'qualify-array06/report.json',
        'arrayV2': RAW / 'array06-controls/observations-v2/report.json',
        'layoutV3': RAW / 'array06-layout-controls/observations-v3/report.json',
        'treeV4': RAW / 'array06-tree-controls/observations-v4/report.json',
        'integerV5': RAW / 'array06-integer-controls/observations-v5/report.json',
        'canaries': RAW / 'array06-canaries/report.json',
        'runtime': RAW / 'corpus-array06/summary.json',
        'compilerCost': RAW / 'compiler-cost-array06/report.json',
        'accounting': RAW / 'accounting06/report.json',
        'portableSmoke': RAW / 'portable-array06-smoke/report.json',
    }
    data = {key: load(path) for key, path in reports.items()}
    runtime = data['runtime']
    assert (runtime['points'], runtime['samples'], runtime['sourceCount']) == (45, 669, 23)
    assert len(data['compilerCost']['rows']) == 27
    protected = load(OUT / 'protected-final.json', False)
    assert protected['checked'] == 103 and not protected['changed'] and not protected['protectedStaged']
    assert identity(protected['start']['file']) == protected['start']
    publication = ROOT / 'selfhost/tools/performance/phase47/current/publication.json'
    load(publication, False)
    controls = {key: dict(oracles=len(data[key]['oracles']), boundaries=len(data[key]['boundaries']))
                for key in ('arrayV2', 'layoutV3', 'treeV4', 'integerV5')}
    controls['layoutV3']['publicStates'] = len(data['layoutV3']['publicStates'])
    result = dict(kind='phase47-selected-qualification', complete=True, pass_=True,
                  compilerExecuted=False, generatedProgramsExecuted=False,
                  producer=identity(__file__), attempt=identity(attempt_path),
                  api=identity(attempt['api']['file']), runtime=identity(attempt['runtime']['file']),
                  base=identity(attempt['base']['file']), artifactKind=attempt['artifactKind'],
                  reports={key: identity(path) for key, path in reports.items()},
                  installed=identity(installed_path), publication=identity(publication),
                  protected=identity(OUT / 'protected-final.json'), controls=controls,
                  maintainedSuites=8, cliSteps=42, points=45, samples=669, sources=23,
                  geometricMeans=runtime['geometricMeans'], medianChanges=runtime['medianChanges'],
                  compilerRequests=27,
                  scope='Data-only receipt join for installed array06. Control scopes overlap; do not sum as unique language tests. No fresh full frontend 3026/196 or 81-case backend inventory, no new self-emitted fixed point, native/GPU qualification or proof-validity upgrade. Historical Phase45 frontend/backend results retain their original scope. Known native IO.args mismatch remains open.')
    result['pass'] = result.pop('pass_')
    with (OUT / 'installed-release.json').open('xb') as handle:
        handle.write(installed_path.read_bytes())
    assert identity(OUT / 'installed-release.json')['sha256'] == identity(installed_path)['sha256']
    with (OUT / 'selected-qualification.json').open('x') as handle:
        json.dump(result, handle, indent=2)
        handle.write('\n')
    print(json.dumps(dict(complete=True, points=45, samples=669, cliSteps=42)))


if __name__ == '__main__':
    main()
