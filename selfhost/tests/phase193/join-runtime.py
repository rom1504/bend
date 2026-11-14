#!/usr/bin/env python3
"""Authenticate a stopped native45 run and its exact remaining-case continuation.

Metadata only: never invokes a target, changes calibration, or chooses among samples.
"""
import argparse
import copy
import importlib.util
import json
import math
from pathlib import Path
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

A = module('retained_analyzer', ROOT/'selfhost/tests/phase186/analyze-runtime.py')
R = module('adaptive_runtime', ROOT/'selfhost/tests/phase185/runtime-loop.py')
B, C = A.B, A.C
POLICY = ('kind', 'version', 'roles', 'reference', 'rounds', 'targetMs',
          'initialPilotMaximumRepetitions', 'minimumAcceptedMs', 'cpu',
          'positionBalanced', 'scope', 'ordering', 'inputs')


def validate_segment(report, document, deadline_stop=False):
    roles = list(report['roles'])
    known = {c['id']: c for c in document['cases']}
    names = report['selectedCaseIds']
    B.require(names and len(names) == len(set(names)) and
              [c['id'] for c in report['cases']] == names, 'Exact unique segment selection required')
    B.require(report['roles'] == document['roles'] and report['reference'] == document['reference'],
              'Manifest roles differ')
    B.require(not report['changedInputs'] and report['deadlineReached'] == deadline_stop,
              'Changed inputs or unexpected deadline')
    B.require(math.isfinite(report['wallSeconds']) and report['wallSeconds'] > 0
              and report['deadlineReached'] == (report['wallSeconds'] >= report['secondsLimit']),
              'Deadline flag differs from retained campaign clock')
    counts = dict(pilots=0, samples=0)
    failures = []
    for ci, case in enumerate(report['cases']):
        original = known[case['id']]
        B.require(all(case[k] == original[k] for k in ('point', 'family', 'sourceGroup')),
                  'Case differs from frozen manifest')
        eligible = case['point']['ratioEligible']
        for stage in counts:
            for row in case[stage]:
                B.require(row['role'] in roles, 'Unknown role')
                proc = row['process']
                product = original['products'][row['role']]
                point = dict(case['point'], repetitions=row['repetitions'])
                expected = [product['artifact']['file'], *B.native_runtime_arguments(product),
                            str(row['repetitions']), str(point['warmups']), *map(str, point['runtimeArgs'])]
                B.require(proc['command'] == expected and row['warmups'] == point['warmups'],
                          'Command differs')
                B.require(type(row['repetitions']) is int and 0 < row['repetitions'] <= R.MAX_COUNT,
                          'Invalid repetition count')
                if not row['correct']:
                    B.require(deadline_stop and ci == 41 and stage == 'pilots'
                              and row is case['pilots'][-1] and not case['samples']
                              and row.get('error') == 'Child deadline exceeded'
                              and proc['exitCode'] == -9 and proc['timedOut'] is True
                              and math.isfinite(proc['seconds']) and 0 < proc['seconds'] < 1
                              and not any(k in row for k in ('elapsedMs', 'metricMs', 'lowResolution')),
                              'Only the final deadline-interrupted calibration child is admissible')
                    B.require(C.verify(proc['stdout']).read_bytes() == b''
                              and C.verify(proc['stderr']).read_bytes() == b'',
                              'Interrupted pilot must have empty authenticated output')
                    receipt = Path(proc['stdout']['file']).with_name('process.json')
                    receipt_pin = C.pin(receipt)
                    B.require(B.read(receipt) == proc, 'Failed child differs from independent process receipt')
                    failures.append(dict(caseId=case['id'], role=row['role'], round=row['round'],
                        repetitions=row['repetitions'], processReceipt=receipt_pin,
                        process=copy.deepcopy(proc)))
                    continue
                B.require('error' not in row and proc['exitCode'] == 0 and not proc['timedOut'],
                          'Incorrect observation')
                elapsed = B.observation(C.verify(proc['stdout']).read_bytes(),
                    C.verify(proc['stderr']).read_bytes(), proc['exitCode'], point, proc['seconds'])
                B.require(elapsed == row['elapsedMs'] and elapsed / row['repetitions'] == row['metricMs']
                          and row['lowResolution'] == (eligible and elapsed < report['minimumAcceptedMs']),
                          'Recorded metric or low-resolution flag differs')
                counts[stage] += 1
        # Validate the original adaptive schedule, including any stopped-case pilots.
        offset = ci % len(roles)
        pilot_order = roles[offset:] + roles[:offset]
        reconstructed, cursor, stopped = {}, 0, False
        for role in pilot_order:
            count = min(report['initialPilotMaximumRepetitions'], case['point']['repetitions'])
            if not eligible:
                # Empty untouched cases have not entered calibration at all.
                if role in case['calibration']:
                    reconstructed[role] = count
                continue
            accepted = False
            for attempt in range(8):
                if cursor == len(case['pilots']):
                    stopped = True
                    break
                row = case['pilots'][cursor]
                B.require(row['role'] == role and row['round'] == attempt and row['repetitions'] == count,
                          'Pilot schedule differs')
                cursor += 1
                if not row['correct']:
                    # Role, attempt and next_count were reconstructed above, including
                    # the interrupted command. It contributes no elapsed-time metric.
                    stopped = True
                    break
                if row['elapsedMs'] >= report['targetMs'] and (row['elapsedMs'] <= 2*report['targetMs'] or count == 1):
                    reconstructed[role] = count
                    accepted = True
                    break
                count = R.next_count(count, row['elapsedMs'], report['targetMs'])
            if not accepted:
                stopped = True
            if stopped:
                break
        B.require(cursor == len(case['pilots']) and reconstructed == case['calibration'],
                  'Calibration differs from authenticated pilots')
        expected_order = [(ri, role) for ri in range(report['rounds'])
                          for role in roles[(ci+ri)%len(roles):] + roles[:(ci+ri)%len(roles)]]
        B.require([(s['round'], s['role']) for s in case['samples']] == expected_order[:len(case['samples'])]
                  and len(case['samples']) <= len(expected_order), 'Segment-local timed rotation differs')
        for row in case['samples']:
            B.require(len(case['calibration']) == len(roles)
                      and row['repetitions'] == case['calibration'][row['role']], 'Timed count differs')
        summary = B.summary(case['samples'], roles, report['reference'], report['rounds'], eligible)
        summary['admitted'] = summary['complete'] and (not eligible or summary['ratios'] is not None)
        B.require(summary == case['summary'], 'Stored admission or summary differs')
    expected_complete = not report.get('error') and all(c['summary']['admitted'] for c in report['cases'])
    B.require(report['complete'] == expected_complete, 'Segment completeness differs')
    expected_aggregate = B.aggregate(report['cases'], roles, report['reference']) if expected_complete else dict(complete=False)
    B.require(report['aggregate'] == expected_aggregate, 'Segment aggregate differs')
    B.require(len(failures) == int(deadline_stop), 'Exactly one deadline failure required on the left only')
    return dict(**counts, interruptedPilots=failures)


def join(left_path, right_path, manifest_path, out):
    B.require(not out.exists(), 'Fresh joined output required')
    source_pins = [C.pin(p) for p in (left_path, right_path, manifest_path)]
    left, right = B.read(left_path), B.read(right_path)
    B.require(left['kind'] == 'phase185-adaptive-native-runtime' and left['version'] == 1,
              'Maintained adaptive runtime schema required')
    B.require(all(left[k] == right[k] for k in POLICY), 'Segment roles, policy or input pins differ')
    B.require(left['rounds'] == 4 and left['targetMs'] == 250 and left['minimumAcceptedMs'] == 100
              and left['initialPilotMaximumRepetitions'] == 16 and left['positionBalanced']
              and list(left['roles']) == ['c', 'qbe', 'baseline', 'candidate'], 'Frozen campaign policy required')
    B.require(not left['complete'] and left.get('error') == "ValueError('Calibration child failed')"
              and left['secondsLimit'] == 400 and right['secondsLimit'] == 80
              and right['complete'] and not right.get('error'),
              'Deadline-stopped calibration plus complete continuation required')
    document = R.load(manifest_path)
    expected_inputs = B.unique_inputs([source_pins[2], B.pin(R.__file__), B.pin(R.CATALOG), *document['inputs']])
    B.require(left['inputs'] == expected_inputs, 'Exact frozen runtime inputs required')
    for pin in expected_inputs:
        C.verify(pin)
    counts = [validate_segment(left, document, deadline_stop=True), validate_segment(right, document)]
    admitted = [c['id'] for c in left['cases'] if c['summary']['admitted']]
    remaining = [c['id'] for c in left['cases'] if not c['summary']['admitted']]
    names = [c['id'] for c in document['cases']]
    B.require(len(names) == 45 and left['selectedCaseIds'] == names and left['fullCatalog']
              and len(admitted) == 41 and len(remaining) == 4 and names == admitted + remaining,
              'Expected complete catalog with forty-one-case admitted prefix required')
    B.require(right['selectedCaseIds'] == remaining and not right['fullCatalog']
              and all(c['summary']['admitted'] for c in right['cases']), 'Continuation must be exactly all remaining cases')
    B.require(not any(c['samples'] for c in left['cases'][41:]), 'Unexpected timed observations in unadmitted suffix')
    B.require(not any(c['pilots'] or c['calibration'] for c in left['cases'][42:]),
              'Cases after the interrupted pilot must be untouched')
    failed = counts[0]['interruptedPilots'][0]
    result = copy.deepcopy(left)
    result.pop('error', None)
    result.update(complete=True, changedInputs=[], deadlineReached=False,
        cases=copy.deepcopy(left['cases'][:41] + right['cases']),
        inputs=B.unique_inputs([*expected_inputs, *source_pins[:2], C.pin(__file__), C.pin(A.__file__),
                                failed['processReceipt'], failed['process']['stdout'], failed['process']['stderr']]),
        wallSeconds=left['wallSeconds'] + right['wallSeconds'],
        secondsLimit=left['secondsLimit'] + right['secondsLimit'])
    result['aggregate'] = B.aggregate(result['cases'], list(result['roles']), result['reference'])
    result['composition'] = dict(kind='phase193-exact-runtime-continuation', programsExecuted=False,
        sourceReports=source_pins[:2], manifest=source_pins[2], method=C.pin(__file__),
        admittedLeftCaseIds=admitted, continuedCaseIds=remaining,
        sourceObservationsRevalidated=counts,
        segmentWallSeconds=[left['wallSeconds'], right['wallSeconds']],
        segmentSecondsLimits=[left['secondsLimit'], right['secondsLimit']],
        deadlineEvidence=dict(failedChild=failed, campaignWallSeconds=left['wallSeconds'],
            campaignLimitSeconds=left['secondsLimit'], perChildMaximumSeconds=30,
            inference='The pinned runtime driver uses min(global deadline, child start + 30s). The authenticated timer-killed empty-output child lasted less than one second, far below its 30s cap, and the report reached its global deadline; its command and next repetition count match the reconstructed pilot schedule. No child-start timestamp or exact remaining-budget value is recorded.'),
        discardedLeftUnadmittedObservations=[dict(id=c['id'], pilots=len(c['pilots']), samples=len(c['samples']))
                                            for c in left['cases'][41:]],
        ordering='Role rotation uses the original segment-local case index. The continuation restarts at index zero; each case still has all four role positions over four rounds.',
        accounting='wallSeconds and secondsLimit are sums of source segments, not a new continuous measurement. Failed calibration pilots remain in the authenticated left receipt and are excluded from ratios.',
        selection='All forty-one admitted prefix cases retained exactly; all four unadmitted suffix cases continued exactly. No sample selection, recalibration-rule change, or new timing.')
    # The maintained independent analyzer rereads stdout and recomputes every summary/aggregate.
    with tempfile.TemporaryDirectory(prefix='phase193-runtime-join-') as directory:
        temporary = Path(directory)/'report.json'
        B.save(temporary, result, fresh=True)
        analysis = A.analyze(temporary)
    result['composition']['independentValidation'] = dict(method=C.pin(A.__file__),
        oracleRevalidated=analysis['oracleRevalidated'], caseCount=analysis['caseCount'],
        inputPinsVerified=analysis['inputPinsVerified'])
    for pin in [*source_pins, *result['inputs']]:
        C.verify(pin)
    out.parent.mkdir(parents=True, exist_ok=True)
    B.save(out, result, fresh=True)
    return dict(report=C.pin(out), complete=True, caseCount=45, segments=[41,4], programsExecuted=False,
                oracleRevalidated=analysis['oracleRevalidated'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--left', type=Path, required=True)
    p.add_argument('--right', type=Path, required=True)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    print(json.dumps(join(a.left, a.right, a.manifest, a.out)))


if __name__ == '__main__':
    main()
