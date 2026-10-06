#!/usr/bin/env python3
"""Index completed Phase58 evidence after writer closure; no targets or archive creation."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase58'
PUBLIC = ROOT / 'selfhost/tools/performance/phase58'
p = argparse.ArgumentParser(description=__doc__)
for name in ['attempt', 'release', 'release-jobs', 'qualification', 'clean', 'allocation',
             'programs', 'source-accounting', 'preservation', 'protected', 'time-use', 'archive', 'out']:
    p.add_argument('--' + name, type=Path, required=True)
p.add_argument('--archive-part', type=Path, action='append', default=[],
               help='Ordered transport parts; concatenated bytes must match archive.json exactly')
p.add_argument('--own-source', type=Path, help='Optional selected clean own-source reproduction receipt')
p.add_argument('--cpu', type=Path, help='Optional selected B2 CPU analysis summary, separate from clean timing')
p.add_argument('--report', type=Path, default=ROOT / 'implementation/phase58/README.md')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(PUBLIC) and not out.exists(), 'Fresh publication output outside raw required'
inputs = {}


def identify(file):
    file = Path(file).resolve(strict=True)
    assert file.is_file() and file.is_relative_to(ROOT), str(file)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return dict(path=file.relative_to(ROOT).as_posix(), bytes=file.stat().st_size, sha256=h.hexdigest())


def pin(file, expected=None):
    row = identify(file)
    if expected:
        assert row['sha256'] == expected['sha256'], str(file)
        if 'bytes' in expected:
            assert row['bytes'] == expected['bytes'], str(file)
    assert row['path'] not in inputs or inputs[row['path']] == row, str(file)
    inputs[row['path']] = row
    return row


def reported(row):
    file = Path(row.get('file', row.get('path')))
    return pin(file if file.is_absolute() else ROOT / file, row)


def read(file, kind=None, flag=None):
    row = pin(file)
    value = json.loads((ROOT / row['path']).read_text())
    if kind:
        assert value['kind'] == kind, row['path']
    if flag:
        assert value['complete'] is True and value[flag] is True, row['path']
    return row, value


producer = pin(__file__)
qualification_id, q = read(a.qualification, 'phase58-last01-qualification-index', 'qualifiedScopesPassed')
assert q['reportInputsUnchanged'] is True
attempt_id, attempt = read(a.attempt, 'bend-development-attempt')
assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
assert attempt_id == reported(q['selected']['attempt'])
assert Path(attempt_id['path']).parent == Path('selfhost/build/phase58/checked-last01')
b1 = reported(q['selected']['checkedB1']); b2 = reported(q['selected']['directB2'])
source = reported(q['selected']['source']); runtime = reported(q['selected']['runtime'])
direct_runtime = reported(q['selected']['directRuntime'])
assert reported(attempt['api']) == b1 and reported(attempt['runtime']) == runtime
assert q['fixedPoint']['byteEquality'] is True
assert q['fixedPoint']['b2Sha256'] == q['fixedPoint']['b3Sha256'] == b2['sha256']

release_id, release = read(a.release, 'bend-default-equality-release')
assert release_id['path'] == 'selfhost/dist/release.json'
assert release['artifact'] == 'equality-derived-b1'
assert release['sourceSha256'] == source['sha256']
assert release['runtimeSha256'] == runtime['sha256']
assert release['directRuntimeSha256'] == direct_runtime['sha256']
assert release['lineage']['checkedParentSha256'] == attempt['checkedApi']['sha256']
installed = {row['path']: pin(ROOT / 'selfhost' / row['path'], row) for row in release['files']}
assert len(installed) == len(release['files']) == 6
assert installed['dist/typed-api.mjs']['sha256'] == b1['sha256']
release_jobs_id, jobs = read(a.release_jobs, 'phase55-retention-execution', 'pass')
release_names = ['install', 'verify-before', 'legacy42', 'default24', 'verify-after']
assert jobs['returncode'] == 0 and [step['name'] for step in jobs['steps']] == release_names
assert all(step['returncode'] == 0 for step in jobs['steps'])
release_plan_id = pin(jobs['plan'], {'sha256': jobs['planSha256']})
_, release_plan = read(ROOT / release_plan_id['path'], 'phase58-root-release-launch-plan')
assert [(step['name'], step['command']) for step in jobs['steps']] == [
    (step['name'], step['command']) for step in release_plan['commands']]
source_plan_id = reported(release_plan['sourcePlan'])
_, source_plan = read(ROOT / source_plan_id['path'], 'phase53-default-release-qualification-plan')
assert reported(source_plan['attempt']) == attempt_id and reported(source_plan['api']) == b1
assert any('--install-attempt' in step['command'] and str(a.attempt.resolve().parent) in step['command']
           for step in jobs['steps']), 'Release queue must install this exact attempt'


def analysis(file, mode, expected_images):
    identity, value = read(file, 'phase58-latency-emission-analysis', 'pass')
    images = set()
    assert value['campaigns']
    for campaign in value['campaigns']:
        assert campaign['mode'] == mode
        image = campaign['roles']['candidate']['image']
        assert image['source']['sha256'] == source['sha256']
        assert image['directRuntime']['sha256'] == direct_runtime['sha256']
        images.add(image['api']['sha256'])
        original_id = reported(campaign['report'])
        _, original = read(ROOT / original_id['path'], 'phase58-candidate-image-library-latency', 'pass')
        assert original['mode'] == mode
    assert images == expected_images, (mode, images)
    return identity


clean_id = analysis(a.clean, 'clean', {b1['sha256'], b2['sha256']})
allocation_id = analysis(a.allocation, 'allocation', {b2['sha256']})
cpu_id = analysis(a.cpu, 'cpu', {b2['sha256']}) if a.cpu else None
own_source = None
if a.own_source:
    own_id, own = read(a.own_source, 'phase58-b2-own-source-emission', 'pass')
    assert own['mode'] == 'clean' and own['cleanTiming'] is True and own['byteEquality'] is True
    assert reported(own['subject']['attempt']) == attempt_id and reported(own['subject']['source']) == source
    assert reported(own['b2']) == b2
    b3 = reported(own['b3'])
    assert b3['sha256'] == b2['sha256'] and b3['bytes'] == b2['bytes']
    assert own['image']['api']['sha256'] == b2['sha256'] and own['seconds'] > 0
    own_source = dict(receipt=own_id, seconds=own['seconds'], b3=b3, byteEquality=True,
        scope='One clean unsplit own-source reproduction; no repeats or fresh type-check claim.')
program_id, programs = read(a.programs, 'phase58-completed-direct-full45-aggregate', 'passed')
assert programs['inputsUnchanged'] is True and programs['points'] == 45 and programs['sources'] == 23
assert reported(programs['attempts']) == attempt_id
assert programs['compiler']['api']['sha256'] == b1['sha256']
assert programs['compiler']['sourceSha256'] == source['sha256']
accounting_id, accounting = read(a.source_accounting, 'phase58-frozen-source-accounting', 'pass')
assert accounting['inputsUnchanged'] is True
assert reported(accounting['roles']['candidate']['attempt']) == attempt_id

preservation_id, preservation = read(a.preservation, 'phase58-preservation-audit', 'pass')
assert preservation['installedMode'] == 'selected' and preservation['inputsUnchanged'] is True
assert preservation['installedFiles'] == 7 and preservation['protectedFiles'] == 103
assert preservation['addedHistoricalFiles'] == preservation['removedHistoricalFiles'] == preservation['protectedStaged'] == []
assert reported(preservation['selectedAttempt']) == attempt_id
actual_installed = [release_id, *installed.values()]
assert sorted(reported(row)['path'] for row in preservation['installedInventory']) == sorted(row['path'] for row in actual_installed)
protected_id, protected = read(a.protected)
assert protected['complete'] is True and protected['checked'] == 103
assert protected['changed'] == protected['protectedStaged'] == []
time_id, time_use = read(a.time_use, 'phase52-top-level-supervisor-time')
assert time_use['complete'] is True and time_use['elapsedSeconds'] >= 0
assert time_use['provisional'] is False and time_use['changedInputs'] == []

archive_id, archive = read(a.archive, 'phase42-closed-raw-campaign-archive')
assert archive['complete'] is True and archive['reopenedVerified'] is True and archive['inputStabilityVerified'] is True
assert Path(archive['rawRoot']).resolve() == RAW
assert reported(archive['attempt']) == attempt_id and reported(archive['api']) == b1
assert reported(archive['protectedFinal']) == protected_id
closed_id = reported(archive['writersClosed'])
_, closed = read(ROOT / closed_id['path'])
assert closed['complete'] is True and closed['writersClosed'] is True and Path(closed['rawRoot']).resolve() == RAW
assert reported(closed['attempt']) == attempt_id and reported(closed['api']) == b1
assert archive['members'] == len(archive['files'])
for row in inputs.values():
    file = ROOT / row['path']
    if file.is_relative_to(RAW):
        assert archive['files'][file.relative_to(RAW).as_posix()] == {key: row[key] for key in ['bytes', 'sha256']}
parts = a.archive_part or [a.archive.resolve().parent / archive['archive']['path']]
assert len({file.resolve() for file in parts}) == len(parts)
transport = []; joined = hashlib.sha256(); size = 0
for file in parts:
    transport.append(pin(file))
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            joined.update(block); size += len(block)
assert size == archive['archive']['bytes'] and joined.hexdigest() == archive['archive']['sha256']
report_id = pin(a.report)
for row in inputs.values():
    assert identify(ROOT / row['path']) == row, row['path']
result = dict(kind='phase58-qualified-compiler-publication', complete=True, dataOnly=True, targetExecuted=False,
    producer=producer, selected=dict(attempt=attempt_id, checkedB1=b1, directB2=b2, source=source,
        directRuntime=direct_runtime, installedRelease=release_id, installedFiles=actual_installed),
    qualification=qualification_id, release=dict(receipt=release_jobs_id, plan=release_plan_id, jobs=5),
    compilerPerformance=dict(clean=clean_id, sampledAllocation=allocation_id, cpuDiagnostic=cpu_id,
        ownSource=own_source), programPerformance=program_id,
    sourceAccounting=accounting_id, preservation=preservation_id, protected=protected_id, timeUse=time_id,
    rawArchive=dict(inventory=archive_id, logicalArchive=archive['archive'], transport=transport,
        concatenatedBytesVerified=True, reopenedVerifiedByArchiveProducer=True, writersClosed=closed_id,
        members=archive['members'], uncompressedBytes=archive['uncompressedBytes']), report=report_id,
    scope='Direct evidence hashes and authoritative completed gates, not a second transitive audit. Test scopes overlap; unsafe source acceptance is not kernel proof. B2 fixed-point evidence is separate from the installed checked B1. Failed experiments remain archived. Profile data are not clean speed samples.',
    inputs=list(inputs.values()), inputsUnchanged=True)
with out.open('x') as stream:
    json.dump(result, stream, indent=2); stream.write('\n')
print(json.dumps(dict(complete=True, publication=identify(out))))
