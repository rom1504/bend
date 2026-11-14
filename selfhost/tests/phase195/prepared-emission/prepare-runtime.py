#!/usr/bin/env python3
"""Prepare the seven-role six-case screen after completed builds; never run targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
from types import SimpleNamespace

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT / 'selfhost/tests/phase185/runtime-loop.py'
spec = importlib.util.spec_from_file_location('phase195_prepared_runtime', METHOD)
runtime = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runtime)
B = runtime.B
BUILD = ROOT / 'selfhost/build/phase195'
CASES = ['local-pair', 'editdist', 'coverage-numeric-recurrence-256',
         'variation-ray-active-64-2440', 'tree-bitonic', 'lexer']
CANDIDATES = ['rcx', 'call', 'compose', 'adaptive']
REFERENCES = ['c', 'qbe', 'baseline']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, default=BUILD / 'prepared-candidates-runtime-plan01')
    p.add_argument('--run-name', default='prepared-candidates-runtime01')
    a = p.parse_args()
    B.require(a.run_name.replace('-', '').isalnum() and '/' not in a.run_name, 'Simple fresh run name required')
    run_out = BUILD / a.run_name
    argv_file = BUILD / (a.run_name + '-argv.json')
    B.require(not a.out.exists() and not run_out.exists() and not argv_file.exists(), 'Fresh plan/run/argv required')
    known = {c['id']: c for c in B.catalog(runtime.CATALOG)['cases']}
    inputs = [B.pin(__file__), B.pin(METHOD), B.pin(ROOT / 'selfhost/tests/phase195/job.py')]
    acquisitions = []
    # Fail immediately if a prerequisite is absent/incomplete. No waiting or polling.
    for role in CANDIDATES:
        directory = BUILD / (role + '-dev-build01')
        receipt = B.pin(directory / 'report.json')
        report = B.read(receipt['file'])
        B.require(report.get('complete') is True and not report.get('error') and not report.get('changedInputs'),
                  'Complete candidate acquisition required: ' + role)
        B.require(report['programManifest'] == B.pin(directory / 'programs.manifest.json'), 'Acquisition manifest differs')
        B.require(set(report['selected']) == set(CASES) and len(report['rows']) == len(CASES), 'Exact six-case build required')
        B.require(set(report['roles']) == {role}, 'Exact build role required')
        for item in report['inputs']:
            B.verify(item)
        B.require({r['id'] for r in report['rows']} == set(CASES), 'Unique expected oracle rows required')
        for row in report['rows']:
            B.require(row.get('complete') is True, 'Incomplete machine/oracle row')
            for key in ['buildReceipt', 'artifact', 'oracleReceipt']:
                B.verify(row[key])
            child = B.read(row['oracleReceipt']['file'])
            B.require(child.get('complete') is True, 'Complete independent observation required')
            B.verify(child['stdout'])
            B.verify(child['stderr'])
            stdout, stderr = Path(child['stdout']['file']).read_bytes(), Path(child['stderr']['file']).read_bytes()
            point = dict(known[row['id']]['point'], repetitions=1, warmups=0)
            B.observation(stdout, stderr, child['exitCode'], point, child['seconds'])
        acquisitions.append(receipt)
    reference = BUILD / 'references01/manifest.json'
    previous = BUILD / 'second-screen-runtime-plan01/manifest.json'
    refs, prior = runtime.load(reference), runtime.load(previous)
    refs_by_id = {c['id']: c for c in refs['cases']}
    prior_by_id = {c['id']: c for c in prior['cases']}
    for name in CASES:
        for role in REFERENCES:
            B.require(refs_by_id[name]['products'][role] == prior_by_id[name]['products'][role],
                      'Reference product differs from prior screen: ' + role + '/' + name)
    roles = [(r, str(reference), r) for r in REFERENCES] + [
        (r, str(BUILD / (r + '-dev-build01') / 'programs.manifest.json'), r) for r in CANDIDATES]
    runtime.merge(SimpleNamespace(role=roles, reference='c', cases=','.join(CASES), out=a.out))
    manifest = B.pin(a.out / 'manifest.json')
    rounds = 7
    B.require(len(roles) == rounds, 'Seven rounds must balance all seven roles')
    argv = ['python3', '-B', 'selfhost/tests/phase195/job.py', a.run_name, '210', '96',
            'python3', '-B', 'selfhost/tests/phase185/runtime-loop.py', 'run', '--manifest', manifest['file'],
            '--out', str(run_out), '--rounds', str(rounds), '--seconds', '180', '--target-ms', '200',
            '--cpu', '3', '--guarded']
    B.save(argv_file, argv, fresh=True)
    report = dict(kind='phase195-prepared-candidates-runtime-plan', complete=True, targetsRun=False,
                  compilerRun=False, manifest=manifest, argv=B.pin(argv_file), inputs=inputs,
                  acquisitionReports=acquisitions, references=B.pin(reference), priorScreen=B.pin(previous),
                  independentOutputObservationsRevalidated=24, referenceProductsExactlyMatchPriorScreen=True,
                  roles=REFERENCES + CANDIDATES, cases=CASES, rounds=rounds, positionBalanced=True,
                  targetMs=200, innerSeconds=180, outerSeconds=210, diskMiB=96, cpu=3,
                  scope='Six-case development screen with serial balanced role rotation. Maintained runtime harness and independent oracles unchanged; no compiler timing, full45 result or final headline claim.')
    B.save(a.out / 'runtime-preparation.json', report, fresh=True)
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=manifest, argv=B.pin(argv_file))))


if __name__ == '__main__':
    main()
