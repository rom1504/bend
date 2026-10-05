#!/usr/bin/env python3
"""Join completed Phase48 release evidence; execute no compiler or program."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase48'
OUT = Path(__file__).resolve().parent / 'evidence'
API = '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
RUNTIME = '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
PINS = {}


def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    row = dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())
    if expected:
        assert row['sha256'] == expected['sha256'], file
        assert 'bytes' not in expected or row['bytes'] == expected['bytes'], file
    assert PINS.get(str(file), row) == row, file
    PINS[str(file)] = row
    return row


def bound(row):
    return pin(row.get('file', row.get('path', row.get('canonicalPath'))), row)


def read(file, status='pass'):
    pin(file)
    x = json.loads(Path(file).read_text())
    assert x['complete'] is True, file
    assert status is None or x[status] is True, file
    assert not x.get('error'), file
    return x


def tuple_matches(value):
    assert bound(value['api'])['sha256'] == API
    assert bound(value['runtime'])['sha256'] == RUNTIME


def main():
    assert not (OUT / 'selected-qualification.json').exists()
    assert not (OUT / 'installed-release.json').exists()
    pin(__file__)
    pin(ROOT / 'selfhost/tools/performance/phase47/evidence/publish-selected.py')
    attempt_file = RAW / 'checked-combined-rnfa04/attempt.json'
    attempt = json.loads(attempt_file.read_text())
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    tuple_matches(attempt)
    paths = dict(
        semantic=RAW / 'selected-semantic04.json',
        runtime=RAW / 'corpus-rnfa04/summary.json',
        runtimeEvidence=ROOT / 'implementation/phase48/evidence/runtime-summary.json',
        compilerCost=RAW / 'compiler-cost-rnfa04/report.json',
        accounting=ROOT / 'implementation/phase48/evidence/accounting-rnfa04.json',
        installed=RAW / 'release04/installed-release.json',
        publication=OUT.parent / 'current/publication.json',
        portableSmoke=RAW / 'portable-rnfa04-smoke/report.json',
        protected=OUT / 'protected-final.json',
    )
    records = {k: read(p, 'passed' if k == 'semantic' else None if k in
               ['installed', 'publication', 'protected'] else 'pass') for k, p in paths.items()}
    semantic, runtime, installed = [records[k] for k in ['semantic', 'runtime', 'installed']]
    assert semantic['inputsUnchanged'] and len(semantic['jobs']) == 28
    assert semantic['focusedBeforeMaintained'] and semantic['countExecutionAlias']
    for obj in [semantic['selected'], installed, records['publication']]:
        tuple_matches(obj)
        assert bound(obj['attempt']) == pin(attempt_file)
    backend_job = next(j for j in semantic['jobs'] if j['name'] == 'backend81')
    backend = read(bound(backend_job['report'])['file'], None)
    assert backend['agreementComplete'] and backend['exactRows'] == 81
    assert backend['fixtureExecutionPasses'] == 69 and backend['sharedRawCheckFailures'] == 4
    assert installed['inputsUnchanged'] and installed['maintainedSuites'] == 8 and installed['cliSteps'] == 42
    assert (runtime['points'], runtime['samples'], runtime['sourceCount']) == (45, 669, 23)
    tuple_matches(runtime['plan']['variants']['candidate']['compiler'])
    evidence = records['runtimeEvidence']
    assert bound(evidence['authoritativeSummary']) == pin(paths['runtime'])
    assert evidence['verification']['sampleLeafAgreements'] == 669
    assert evidence['verification']['independentlyRecomputedMedians'] == 135
    cost = records['compilerCost']
    assert len(cost['rows']) == 18
    config = json.loads(Path(bound(cost['config'])['file']).read_text())
    tuple_matches(config['variants']['candidate'])
    assert bound(config['variants']['candidate']['manifest']) == pin(attempt_file)
    candidate_rows = [r for r in cost['rows'] if r['variant'] == 'candidate']
    assert len(candidate_rows) == 6
    cases = {c['id']: c for c in config['cases']}
    assert len(cases) == 2
    assert {(r['source'], r['sample'], r['variant']) for r in cost['rows']} == {
        (c, n, v) for c in cases for n in range(3) for v in ['baseline', 'candidate', 'typescript']}
    for row in cost['rows']:
        assert row['observation']['complete'] and row['observation']['pass']
        assert row['execution']['complete'] and row['execution']['returncode'] == 0
        assert bound(row['observation']['output'])['sha256'] == bound(cases[row['source']]['expected'][row['variant']])['sha256']
    publication = records['publication']
    assert publication['kind'] == 'phase48-portable-benchmark-publication'
    assert publication['points'] == 45 and publication['protectedUnchanged']
    smoke = records['portableSmoke']
    assert smoke['measuredCases'] == smoke['selectedCases'] == 3
    assert {c['id'] for c in smoke['cases']} == {'local-fold', 'scalar-region-0', 'complete-generic-row32'}
    tuple_matches(smoke['plan']['variants']['candidate']['compiler'])
    smoke_inputs = {bound(r)['file']: bound(r) for r in smoke['inputs']}
    for key in ['candidateManifest', 'baselineManifest']:
        expected = bound(publication[key])
        assert smoke_inputs[expected['file']] == expected
    assert bound(records['accounting']['roles']['candidate']['attempt']) == pin(attempt_file)
    tuple_matches(records['accounting']['roles']['candidate']['images'])
    protected = records['protected']
    assert protected['checked'] == 103 and not protected['changed'] and not protected['protectedStaged']
    assert bound(protected['start'])['sha256'] == 'c5e803405d3c8267bd2f3741a638c77b4ce58c561cc5c829d0abac2ac8d67288'
    for name in ['semantic', 'runtime', 'compilerCost', 'accounting', 'installed', 'publication', 'portableSmoke']:
        for identity in records[name]['inputs']:
            bound(identity)
    for key in ['candidateManifest', 'baselineManifest', 'archive']:
        bound(publication[key])
    for row in publication['baselineCopies'] + publication['candidateFiles']:
        bound(row)
    for row in list(PINS.values()):
        bound(row)
    result = dict(kind='phase48-selected-qualification', complete=True, passed=True,
        compilerExecuted=False, generatedProgramsExecuted=False, producer=pin(__file__),
        attempt=pin(attempt_file), api=bound(attempt['api']), runtime=bound(attempt['runtime']),
        base=bound(attempt['base']), artifactKind=attempt['artifactKind'],
        reports={k: pin(p) for k, p in paths.items()}, maintainedSuites=8, cliSteps=42,
        backendOutcomes=dict(total=81, executionPasses=69, notApplicable=8, sharedFailures=4),
        points=45, samples=669, sources=23, compilerRequests=18,
        geometricMeans=runtime['geometricMeans'], medianChanges=runtime['medianChanges'],
        inputsUnchanged=True, inputs=list(PINS.values()),
        scope='Installed RNFA04 with separately qualified semantics, execution, compiler cost and portable replay. Counts overlap. Frontend3026/196 remains historical; no new fixed point, broad GPU or proof-validity claim. Native IO.args remains unresolved. Campaign-time accounting and archive closure are separate receipts.')
    OUT.mkdir(parents=True, exist_ok=True)
    with (OUT / 'installed-release.json').open('xb') as stream:
        stream.write(paths['installed'].read_bytes())
    assert pin(OUT / 'installed-release.json')['sha256'] == pin(paths['installed'])['sha256']
    with (OUT / 'selected-qualification.json').open('x') as stream:
        json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, passed=True, points=45, samples=669, cliSteps=42)))


if __name__ == '__main__':
    main()
