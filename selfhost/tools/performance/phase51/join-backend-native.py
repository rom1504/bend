#!/usr/bin/env python3
"""Join 60 accepted census rows with one fresh native batch; data only."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase51'
FIELDS = ['referenceVerdict', 'candidateVerdict', 'reference', 'candidate', 'exactAgreement', 'semanticAgreement']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('plan', type=Path)
    p.add_argument('original', type=Path)
    p.add_argument('retry', type=Path)
    p.add_argument('retry_process', type=Path)
    p.add_argument('out', type=Path)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(RAW) and out.parent.is_dir() and not out.exists()
    inputs = {}
    report = dict(kind='phase51-backend-native-recovery', complete=False, agreementComplete=False,
                  compilerExecuted=False, generatedProgramsExecuted=False,
                  scope='Data-only union: 60 accepted original observations plus 21 fresh native observations. Original sandbox failures remain preserved; this is not 81 fresh executions or a rewritten queue PASS.')

    def pin(file, want=None):
        file = Path(file).resolve(strict=True)
        digest = hashlib.sha256()
        with file.open('rb') as stream:
            for chunk in iter(lambda: stream.read(2**20), b''):
                digest.update(chunk)
        row = dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)
        if want:
            assert row['sha256'] == want['sha256'], str(file)
            if 'bytes' in want:
                assert row['bytes'] == want['bytes'], str(file)
        if str(file) in inputs:
            assert row == inputs[str(file)], str(file)
        inputs[str(file)] = row
        return row

    def read(file, want=None):
        pin(file, want)
        return json.loads(Path(file).read_text())

    def archive(file, want=None):
        value = read(file, want)
        assert value['verifiedFiles'] > 0 and value['verifiedFiles'] == len(value['files'])
        return dict(receipt=pin(file), archive=pin(value['archive']['file'], value['archive']), verifiedFiles=value['verifiedFiles'])

    try:
        pin(__file__)
        plan = read(a.plan)
        assert plan['kind'] == 'phase30-retained-backend-renewal-plan' and plan['complete'] and not plan['executed']
        assert plan['campaign'] == 'pilot' and plan['expectedRows'] == 81 and len(plan['batches']) == 7
        for row in plan['inputs']:
            pin(row['file'], row)
        runner = ROOT / 'selfhost/build/phase43/integration01/final-plan/tools/backend-run.py'
        helper = runner.with_name('backend-census.py')
        report['classificationMethod'] = pin(runner, {'sha256': '739a392b91dd2566169f8cdb516276610f9a75e6fb7afac212a19a8ef87fcc0d'})
        pin(helper, {'sha256': '2dc3fe206f950841181e3673bd43c7d7dc42e99a00160522314b2333677deb72'})
        assert 'observedFields=' + repr(FIELDS) in runner.read_text()
        expected = read(plan['historicalRows']['file'], plan['historicalRows'])
        expected_by_key = {(r['id'], r['lane']): r for r in expected}
        assert len(expected_by_key) == len(expected) == 81
        attempt = read(plan['attempt']['file'], plan['attempt'])
        report['selected'] = dict(attempt=pin(plan['attempt']['file']))
        for key in ['api', 'runtime', 'base']:
            report['selected'][key] = pin(attempt[key]['file'], attempt[key])
        original = read(a.original)
        assert original['kind'] == 'phase30-retained-backend-renewal' and original['complete']
        assert not original['agreementComplete'] and not original.get('error')
        assert original['plan']['sha256'] == pin(a.plan)['sha256'] and original['attempt']['sha256'] == plan['attempt']['sha256']
        assert len(original['rows']) == original['exactRows'] == 81 and len(original['steps']) == 7
        assert not original['unexecuted'] and not original['incompleteBatchRows']
        batch = plan['batches'][6]
        assert batch['name'] == 'pilot-native' and len(batch['cases']) == 21
        old_native = [r for r in original['rows'] if r['batch'] == batch['name']]
        kept = [r for r in original['rows'] if r['batch'] != batch['name']]
        assert len(kept) == 60 and all(r['acceptedCampaignObservation'] for r in kept)
        failed = [r for r in old_native if not r['acceptedCampaignObservation']]
        diagnostic = 'spawnSync /home/ai/bend2/build/publish/bend/selfhost/build/phase1/clang/root/usr/bin/clang-16 EPERM'
        assert len(old_native) == 21 and len(failed) == 17
        for row in failed:
            assert row['lane'] == 'native' and row['referenceVerdict'] == row['candidateVerdict'] == 'fail'
            assert row['exactAgreement'] and row['semanticAgreement']
            assert all(row[role]['phase'] == 'compile' and row[role]['diagnostic'] == diagnostic for role in ['reference', 'candidate'])
        report['original'] = dict(report=pin(a.original), acceptedRows=60, replacedBatchRows=21, sandboxBlockedRows=17)
        report['originalArchives'] = []
        for index, step in enumerate(original['steps']):
            assert step['name'] == plan['batches'][index]['name'] and step['exitCode'] == 0
            assert step['complete'] == (index < 6)
            pin(step['receipt']['file'], step['receipt'])
            report['originalArchives'].append(archive(step['archiveReceipt']['file'], step['archiveReceipt']))

        retry = read(a.retry)
        process = read(a.retry_process)
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
        retry_out = a.retry.resolve().parent
        expected_tail = batch['command'][1:6] + [str(retry_out), batch['command'][7]]
        assert process['command'][:3] == ['taskset', '-c', '3']
        assert len(process['command']) == 11 and Path(process['command'][3]).name == 'python3'
        actual_tail = process['command'][-7:]
        for index in [1, 3, 4]:
            assert actual_tail[index] == expected_tail[index]
        for index in [0, 2, 5, 6]:
            assert (ROOT / actual_tail[index]).resolve(strict=True) == Path(expected_tail[index]).resolve(strict=True)
        assert process['rssLimitBytes'] == 2048 * 1024**2 and process['availableFloorBytes'] == 4096 * 1024**2
        for name in ['stdout.log', 'stderr.log']:
            pin(a.retry_process.resolve().parent / name)
        assert retry['kind'] == 'phase24-backend-census-batch' and retry['batch'] == 'pilot-native'
        assert retry['complete'] and not retry.get('error') and retry['changedInputs'] == []
        assert retry['rowsExpected'] == len(retry['rows']) == 21
        retry_pins = {row['file']: pin(row['file'], row) for row in retry['inputs']}
        for row in [plan['attempt'], attempt['api'], attempt['runtime'], attempt['base']]:
            assert retry_pins[str(Path(row['file']).resolve())]['sha256'] == row['sha256']
        assert retry_pins[str(helper)]['sha256'] == pin(helper)['sha256']
        assert {(r['id'], r['lane']) for r in retry['rows']} == {(r['id'], r['lanes'][0]) for r in batch['cases']}
        report['retry'] = dict(report=pin(a.retry), process=pin(a.retry_process), rows=21,
                              archive=archive(retry_out / 'archive.json'))
        rows = []
        # This is the frozen runner's six-field historical comparison, not merely
        # candidate/reference equality (which also held for the EPERM failures).
        for origin, source in [('original-accepted', kept), ('fresh-native-retry', retry['rows'])]:
            for row in source:
                expected_row = expected_by_key[(row['id'], row['lane'])]
                valid = row['exactAgreement'] and row['semanticAgreement'] and all(row[k] == expected_row[k] for k in FIELDS)
                assert valid, (row['id'], row['lane'])
                shared = row['lane'] == 'check' and row['id'] in plan['expectedSharedCheckFailures']
                rows.append(dict(row, batch=row.get('batch', 'pilot-native'), executionSource=origin,
                                 expectedSharedCheckFailure=shared, acceptedCampaignObservation=True))
        assert len(rows) == len({(r['id'], r['lane']) for r in rows}) == 81
        assert Counter(r['candidateVerdict'] for r in rows) == {'pass': 69, 'not-applicable': 8, 'fail': 4}
        report.update(rows=rows, rowsExpected=81, reusedAcceptedRows=60, freshNativeRows=21,
                      exactRows=81, fixtureExecutionPasses=69, notApplicable=8, sharedRawCheckFailures=4)
        queue_file = a.plan.resolve().parent.parent / 'report.json'
        queue = read(queue_file)
        assert queue['kind'] == 'phase51-selected-semantic-queue' and not queue['complete'] and not queue['passed']
        assert queue['plannedEntries'] == len(queue['jobs']) == 11
        assert all(row['passed'] for row in queue['jobs'][:10])
        assert queue['jobs'][-1]['name'] == 'backend81' and not queue['jobs'][-1]['passed']
        assert queue['jobs'][-1]['returncode'] == 1
        assert queue['selected']['attempt']['sha256'] == plan['attempt']['sha256']
        assert queue['selected']['api']['sha256'] == attempt['api']['sha256']
        assert queue['selected']['runtime']['sha256'] == attempt['runtime']['sha256']
        for row in queue['inputs']:
            pin(row['file'], row)
        for index, row in enumerate(queue['jobs'][:10]):
            child = read(row['report']['file'], row['report'])
            assert child['complete']
            if 4 <= index <= 8:
                assert child['pass'] and not child.get('error')
            for key, expected_count in row.get('counts', {}).items():
                assert len(child[key]) == expected_count
        report['queueResolution'] = dict(original=pin(queue_file), originalComplete=False, originalPassed=False,
            previouslyPassedEntries=10, resolvedEntries=11, semanticQualificationComplete=True,
            scope='The original queue remains failed. Its ten successful entries are reused unchanged; only its backend census result is resolved by the explicit 60+21 historical-agreement union.')
        for row in list(inputs.values()):
            pin(row['file'], row)
        report.update(complete=True, agreementComplete=True, inputsUnchanged=True)
    except Exception as error:
        report['error'] = repr(error)
    report['inputs'] = list(inputs.values())
    with out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps({key: report.get(key) for key in ['complete', 'agreementComplete', 'reusedAcceptedRows', 'freshNativeRows', 'error']}))
    return 0 if report['agreementComplete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
