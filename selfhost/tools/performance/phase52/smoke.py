#!/usr/bin/env python3
"""Exact-output rejection screen with the unchanged execution worker; not timing evidence."""
import argparse
import json
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from support import ExecutionGuard, identity, save
from run import load_bundle


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--catalog', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--node', type=Path, default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    worker = PROGRAMS / 'execute.mjs'
    inputs = [identity(f) for f in [__file__, worker, PROGRAMS / 'run.py', PROGRAMS / 'support.py', a.node, a.catalog]]
    assert inputs[1]['sha256'] == '5a37e3bdcc390cdc9a9745fcfacdcca75fc8a16a5b02405345aa618f770692c5'
    manifest = json.loads(a.manifest.read_text())
    catalog = json.loads(a.catalog.read_text())
    chosen = {c['id'] for c in manifest['cases']}
    selected = [c for c in catalog['cases'] if c['id'] in chosen]
    assert len(selected) == len(chosen)
    bundle = load_bundle(a.manifest, catalog, identity(a.catalog)['sha256'], selected, ['candidate'], inputs)
    compiler = bundle['roles']['candidate']['compiler']
    assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
    report = dict(kind='phase52-direct-output-smoke', complete=False, passed=False, inputs=inputs,
                  scope='No speed claim. Zero warmup, one calibration invocation and one measured invocation, plus the worker first-call oracle.', cases=[])
    save(a.out / 'report.json', report)
    with ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
        for case in selected:
            name = case['id']
            config = dict(case['point'], warmupCalls=0, warmupMs=0, calibrationMs=0, targetMs=1, maxRepetitions=1)
            config_path = a.out / (name + '.json')
            save(config_path, config)
            inputs.append(identity(config_path))
            module = a.manifest.resolve().parent / bundle['points'][name]['candidate']['path']
            result_path = a.out / (name + '.result.json')
            command = ['taskset', '-c', '3', str(a.node), '--max-old-space-size=1024', str(worker), str(module), str(config_path), str(result_path)]
            process = guard.run(command, a.out / ('job-' + name), time.monotonic() + 60)
            result = json.loads(result_path.read_text()) if result_path.exists() else None
            passed = process['complete'] and result is not None and result['complete'] and result['pass']
            report['cases'].append(dict(id=name, passed=passed, process=process, result=result,
                                        receipt=identity(result_path) if result else None))
            print(json.dumps(dict(case=name, passed=passed, error=result.get('error') if result else process.get('error'))), flush=True)
            save(a.out / 'report.json', report)
            if guard.interrupted:
                break
    for item in inputs:
        assert identity(item['path']) == item, item['path']
    report.update(complete=len(report['cases']) == len(selected), inputsUnchanged=True)
    report['passed'] = report['complete'] and all(c['passed'] for c in report['cases'])
    save(a.out / 'report.json', report)
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
