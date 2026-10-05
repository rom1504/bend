#!/usr/bin/env python3
"""Join an already installed checked release to existing verification receipts.

Data-only: no compiler, generated program, installer, archive or test is run.
This attests installed identity, eight maintained suites and 42 CLI checks;
full frontend, runtime performance and broader qualification remain separate.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
SH = ROOT / 'selfhost'
PINS = {}


def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    row = dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)
    if expected:
        assert row['sha256'] == expected['sha256'], file
        assert 'bytes' not in expected or row['bytes'] == expected['bytes'], file
    assert str(file) not in PINS or PINS[str(file)] == row, file
    PINS[str(file)] = row
    return row


def read(file):
    pin(file)
    return json.loads(Path(file).read_text())


def audit(row):
    return pin(row.get('file', row.get('path', row.get('canonicalPath'))), row)


def relative(root, name):
    file = (root / name).resolve(strict=True)
    assert file.is_relative_to(root.resolve()), name
    return file


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['attempt', 'maintained', 'install-run', 'verify-run', 'smoke-run', 'smoke-launcher', 'protected', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--expected-api', required=True)
    p.add_argument('--expected-runtime', required=True)
    p.add_argument('--publication', type=Path, help='Optional existing portable publication receipt')
    a = p.parse_args()
    assert not a.out.exists(), 'Output must be fresh'
    pin(__file__)
    attempt_file = a.attempt / 'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt = read(attempt_file)
    assert attempt['checked'] is True and attempt['config']['strictExact'] is True
    assert attempt['api']['sha256'] == a.expected_api and attempt['runtime']['sha256'] == a.expected_runtime
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        audit(attempt[key])
    for row in attempt['artifacts']:
        audit(row)
    focused = read(attempt_file.parent / 'validation-001/report.json')
    assert focused['complete'] and focused['pass'] and focused['strictExact']
    assert focused['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert focused['api']['sha256'] == a.expected_api
    maintained = read(a.maintained)
    assert maintained['kind'] == 'phase47-maintained-semantic-qualification'
    assert maintained['complete'] and maintained['pass'] and maintained['inputsUnchanged']
    assert maintained['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert maintained['api']['sha256'] == a.expected_api and maintained['runtime']['sha256'] == a.expected_runtime
    assert len(maintained['tests']) == 8 and all(row['pass'] for row in maintained['tests'])
    for row in maintained['inputs']:
        audit(row)
    release_file = SH / 'dist/release.json'
    release = read(release_file)
    assert release['artifact'] == 'equality-derived-b1' and release['newBootstrap'] is False
    assert release['runtimeSha256'] == a.expected_runtime
    bootstrap = read(attempt['bootstrapReport']['file'])
    assert release['sourceSha256'] == bootstrap['sourceSha256']
    for row in bootstrap['modules']:
        pin(relative(SH, row['file']), row)
    for row in release['files'] + release['checkout']:
        pin(relative(SH, row['path']), row)
    assert pin(SH / 'dist/typed-api.mjs')['sha256'] == a.expected_api
    assert pin(SH / 'src/runtime.mjs')['sha256'] == a.expected_runtime
    assert pin(SH / 'dist/base.bend')['sha256'] == attempt['base']['sha256']
    for file, verb in [(a.install_run, '--install-attempt'), (a.verify_run, '--verify'), (a.smoke_run, None)]:
        run = read(file)
        assert run['complete'] and run['returncode'] == 0 and not run.get('stoppedFor')
        assert attempt['node']['file'] in run['command']
        assert verb is None or verb in run['command']
        assert run['rssLimitBytes'] <= 2048 * 1024**2 and run['availableFloorBytes'] >= 4096 * 1024**2
        if verb == '--install-attempt':
            assert Path(run['command'][run['command'].index(verb) + 1]).resolve() == attempt_file.parent.resolve()
        # Both standard bounded-run/run.json and the Phase46 job.py
        # ExecutionGuard/process.json preserve logs beside their receipt.
        logs = {}
        for channel in ['stdout', 'stderr']:
            logs[channel] = pin(file.parent / (channel + '.log'))
            if channel in run:
                assert audit(run[channel]) == logs[channel]
        result = read(logs['stdout']['file'])
        assert result['complete']
        if verb:
            assert result['api']['sha256'] == a.expected_api and result['newBootstrap'] is False
            assert result['artifact'] == release['artifact'] and result['sourceSha256'] == release['sourceSha256']
        else:
            assert result['pass'] and result['steps'] == 42
            assert str(a.smoke_launcher.parent.resolve()) in run['command'] and a.expected_api in run['command']
    launcher = read(a.smoke_launcher)
    assert launcher['complete'] and launcher['pass'] and launcher['expectedApi'] == a.expected_api
    assert launcher['steps'] == 42 and launcher['cpu'] == 3
    for row in launcher['inputs']:
        audit(row)
    audit(launcher['checks'])
    smoke = read(launcher['checks']['file'])
    assert smoke['pass'] and smoke['apiSha256'] == a.expected_api
    assert len(smoke['steps']) == 42 and all(row['pass'] and not any(row.get(k) for k in ['error', 'signal', 'timedOut', 'overflow']) for row in smoke['steps'])
    assert smoke['release']['sha256'] == pin(release_file)['sha256']
    assert smoke['node']['sha256'] == attempt['node']['sha256']
    assert not any(smoke[k] for k in ['changedOrdinaryInputs', 'changedRelocatedInputs', 'changedFixtures'])
    for row in smoke['ordinaryInputs'] + smoke['relocation']['copiedFiles'] + smoke['fixtureInputs'] + smoke['outputs']:
        audit(row)
    assert smoke['relocation']['noUpstreamCheckout'] and not smoke['relocation']['createdUpstreamCheckout']
    protected = read(a.protected)
    assert protected['complete'] and protected['checked'] == 103
    assert not protected['changed'] and not protected['protectedStaged']
    audit(protected['start'])
    assert protected['start']['sha256'] == 'c5e803405d3c8267bd2f3741a638c77b4ce58c561cc5c829d0abac2ac8d67288'
    start = read(protected['start']['file'])
    rows = start.get('files', start.get('protectedPreexisting'))
    assert len(rows) == 103 and len({r['path'] for r in rows}) == 103
    for row in rows:
        pin(relative(ROOT, row['path']), row)
    publication = None
    if a.publication:
        published = read(a.publication)
        assert published['kind'] == 'phase47-portable-benchmark-publication' and published['complete']
        assert published['attempt']['sha256'] == pin(attempt_file)['sha256']
        assert published['api']['sha256'] == a.expected_api and published['runtime']['sha256'] == a.expected_runtime
        assert published['protectedUnchanged'] and published['points'] == 45
        for key in ['candidateManifest', 'baselineManifest', 'archive']:
            audit(published[key])
        for row in published['baselineCopies'] + published['candidateFiles']:
            audit(row)
        publication = pin(a.publication)
    for row in list(PINS.values()):
        audit(row)
    result = dict(kind='phase47-installed-release-receipt', complete=True,
        scope=__doc__.strip(), compilerExecuted=False, generatedProgramsExecuted=False,
        attempt=pin(attempt_file), api=audit(attempt['api']), runtime=audit(attempt['runtime']),
        release=pin(release_file), maintained=pin(a.maintained), installRun=pin(a.install_run),
        verifyRun=pin(a.verify_run), smokeRun=pin(a.smoke_run), smokeLauncher=pin(a.smoke_launcher), smokeChecks=audit(launcher['checks']),
        protected=pin(a.protected), publication=publication, maintainedSuites=8, cliSteps=42,
        inputsUnchanged=True, inputs=list(PINS.values()))
    with a.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, report=str(a.out), api=a.expected_api, runtime=a.expected_runtime)))


if __name__ == '__main__':
    main()
