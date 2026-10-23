#!/usr/bin/env python3
"""Freeze qualified N1 request commands for the generic profiler; no targets."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('profiler_run', ROOT/'selfhost/tools/profiler/run.py')
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--sampler', type=Path, default=ROOT/'selfhost/build/phase108/profiler01/sampler.so')
    a = p.parse_args()
    paths = {
        'phase125': ROOT/'selfhost/build/phase112/p126-native32-transport01-phase125/report.json',
        'phase126': ROOT/'selfhost/build/phase112/p126-native32-transport01/report.json'}
    workloads = {}
    proofs = [R.pin(__file__)]
    for label, path in paths.items():
        data = json.loads(path.read_text())
        assert data['complete'] and data['passed']
        proofs.append(R.pin(path))
        known = {x['file']: x for x in data['inputs']}
        for row in data['rows']:
            if row['round'] != 1 or row['role'] != 'phase111' or row['mode'] != 'cache':
                continue
            job = row['jobs'][0]
            assert job['stage'] == 'compile-qbe' and job['returncode'] == 0
            command = job['command']
            inputs = []
            for argument in command:
                if Path(argument).is_file():
                    item = R.pin(argument)
                    assert known[item['file']] == item
                    inputs.append(item)
            for item in (job['stdout'], job['stderr']):
                R.verify(item)
            variant = dict(name=label, binary=inputs[0], command=command, inputs=inputs,
                oracleReceipt=R.pin(path), expected=dict(exitCode=0,
                    stdout={'kind':'exact', **job['stdout']}, stderr={'kind':'exact', **job['stderr']}))
            workloads.setdefault(row['name'], dict(name=row['name'], timeoutSeconds=30, variants=[]))['variants'].append(variant)
    assert len(workloads) == 3 and all(len(w['variants']) == 2 for w in workloads.values())
    for workload in workloads.values():
        assert workload['variants'][0]['command'][1:] == workload['variants'][1]['command'][1:]
    result = dict(schema='bend-native-profile-workloads-v1', cwd=str(ROOT), inputs=proofs,
        sampler=R.pin(a.sampler), samplerSource=R.pin(ROOT/'selfhost/tools/performance/phase68/parity-survey/sample-preload-v3.c'),
        workloads=list(workloads.values()),
        scope='Qualified Phase125/126 route N1; exact same three ordinary source requests and prepared Base. Each version retains its own independent whole-QBE oracle. No machine builds or N2 calls.')
    assert not a.out.exists()
    a.out.parent.mkdir(parents=True, exist_ok=True)
    R.save(a.out, result)
    print(json.dumps(dict(workloads=len(workloads), manifest=R.pin(a.out), targetsRun=False)))


if __name__ == '__main__':
    main()
