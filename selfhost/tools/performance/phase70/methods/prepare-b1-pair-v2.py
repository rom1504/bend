#!/usr/bin/env python3
"""Bind two checked B1 images to the frozen Phase70 baseline C oracles; data only."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASELINE = ROOT/'selfhost/build/phase70/compiler69-profile02/plan.json'
INPUTS = {}


def pin(path, expected=None):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert value['sha256'] == expected['sha256'], path
        assert 'bytes' not in expected or value['bytes'] == expected['bytes'], path
    INPUTS[str(path)] = value
    return value


def read(path):
    return json.loads(Path(pin(path)['file']).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--attempt', type=Path, required=True, help='New checked attempt.json')
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert os.sched_getaffinity(0) == {0}
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase70') and not out.exists()
    baseline_pin, baseline = pin(BASELINE), read(BASELINE)
    assert baseline_pin['sha256'] == '1f9ac7dba7a51ba02ec1ec7e346cab22c84ded32f88a6f73d0d7b5ca5a334fa3'
    for item in baseline['inputs']:
        pin(item['file'], item)
    baseline_attempt = read(baseline['attempt']['file'])
    candidate_pin, candidate = pin(args.attempt), read(args.attempt)
    for attempt in [baseline_attempt, candidate]:
        assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1' and attempt['config']['strictExact']
        assert attempt['config']['jobs'] == 1 and str(attempt['config']['cpu']) == '3'
        for key in ['api', 'checkedApi', 'derivationReport', 'bootstrapReport', 'base', 'node']:
            pin(attempt[key]['file'], attempt[key])
        for item in attempt['snapshot']['sources']:
            pin(item['frozen']['file'], item['frozen'])
    assert candidate['base']['sha256'] == baseline_attempt['base']['sha256']
    assert candidate['node']['sha256'] == baseline_attempt['node']['sha256']
    for name in ['prepare-b1-pair-v2.py', 'compilation/worker.mjs', 'compilation/run.py', 'compilation/analyze-b1-pair.py']:
        pin(HERE/name)
    out.mkdir(parents=True)
    roles, copies = {}, []
    original_root = Path(baseline_attempt['snapshot']['root'])
    source_relatives = [Path(item['original']['file']).relative_to(original_root)
        for item in baseline['copies'] if '/b1/project/' in item['copy']['file']]
    assert source_relatives and len(set(source_relatives)) == len(source_relatives)
    original_by_relative = {Path(item['frozen']['file']).relative_to(original_root):item['frozen']
        for item in baseline_attempt['snapshot']['sources']}
    for role, attempt in [('baseline', baseline_attempt), ('candidate', candidate)]:
        snapshot = Path(attempt['snapshot']['root'])
        frozen = {item['frozen']['file']:item['frozen'] for item in attempt['snapshot']['sources']}
        project = out/role/'project'
        for relative in source_relatives:
            original = pin(snapshot/relative, frozen[str(snapshot/relative)])
            assert original['sha256'] == original_by_relative[relative]['sha256'], 'Compiler-work screen requires unchanged host and runtime'
            target = project/relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(Path(original['file']).read_bytes())
            copied = pin(target)
            assert copied['sha256'] == original['sha256']
            copies.append(dict(original=original, copy=copied))
        roles[role] = dict(api=pin(attempt['api']['file'], attempt['api']), node=baseline['roles']['b1']['node'],
            base=baseline['roles']['b1']['base'], project=str(project), driver=pin(project/'tools/typed-driver.mjs'),
            runtime=pin(project/'src/runtime.mjs'), preparation=str(out/'runs'/('prepare-'+role)/'report.json'))
    cases = copy.deepcopy(baseline['cases'])
    for item in cases.values():
        oracle = item['expected']['b1']
        pin(oracle['file'], oracle)
        item['expected'] = dict(baseline=oracle, candidate=oracle)
    jobs = [dict(name='prepare-'+role, role=role, action='prepare', profile=False) for role in roles]
    for round_ in range(2):
        for offset, case in enumerate(cases):
            order = ['baseline','candidate'] if (round_+offset)%2 == 0 else ['candidate','baseline']
            for role in order:
                jobs.append(dict(name=f'clean-{round_}-{case}-{role}', action='request', role=role,
                    case=case, profile=False, round=round_))
    jobs.append(dict(name='profile-numeric-candidate', action='request', role='candidate', case='numeric', profile=True))
    plan = dict(kind='phase68-native-compilation-plan', version=4, status='prepared-unexecuted',
        producer=pin(__file__), baselinePlan=baseline_pin, baselineAttempt=baseline['attempt'],
        attempt=candidate_pin, oracleAttempt=baseline['oracleAttempt'], oracleApi=baseline['oracleApi'],
        copies=copies, roles=roles, cases=cases, jobs=jobs, cpu=3, nodeArgs=baseline['nodeArgs'],
        seconds=90, rssMiB=2048, availableMiB=4096, inputs=list(INPUTS.values()),
        scope='Two alternating fresh-process rounds for baseline69 versus candidate checked B1, numeric/array/lexer. Both own freshly prepared Base; full C must equal frozen baseline69 native-acquisition oracle. Imports, preparation, request and diagnostic profiling remain separate clocks. No new B2, Clang or generated-program run is needed for this narrow unchanged-C screen. Two samples per cell are screening evidence, not final precision or parity claims. One additional candidate numeric profile is diagnostic only. Existing guarded worker and serial runner are unchanged.')
    with (out/'plan.json').open('x') as stream:
        stream.write(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'plan.json'), jobs=len(jobs), targetsExecuted=False)))


if __name__ == '__main__':
    main()
