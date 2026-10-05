#!/usr/bin/env python3
"""Root-only guarded numeric derivative controls and 45 fresh timing samples."""
import argparse
import importlib.util
import json
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PROGRAMS = ROOT / 'selfhost/tools/performance/programs'
spec = importlib.util.spec_from_file_location('numeric_support', PROGRAMS / 'support.py')
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)
ROLES = ['original', 'write-preserved', 'constants']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    p.add_argument('--node', type=Path, default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    p.add_argument('--budget', type=float, default=150)
    args = p.parse_args()
    assert args.budget >= 20
    control = Path(__file__).with_name('numeric-controls.mjs')
    worker = PROGRAMS / 'execute.mjs'
    inputs = [support.identity(f) for f in [__file__, control, worker, PROGRAMS / 'support.py', args.manifest, args.node, sys.executable]]
    manifest = json.loads(args.manifest.read_text())
    assert manifest['kind'] == 'phase48-saved-numeric-constants-ablation' and manifest['complete']
    assert set(manifest['modules']) == set(ROLES)
    for item in manifest['inputs'] + list(manifest['modules'].values()):
        assert support.identity(item['path']) == item
        inputs.append(item)
    assert manifest['invariants'] == dict(outsideHelperByteIdentical=True, rootGuardsByteIdentical=True,
                                         publicFallbackByteIdentical=True, allFroundCallsRetained=True)
    points = [c for c in manifest['controls'] if c['args'][0] in [256, 1024, 8192] and c['args'][1] == 123]
    assert len(points) == 3
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    start = time.monotonic()
    deadline = start + args.budget
    report = dict(kind='phase48-numeric-derivative-timing', complete=False, passed=False, inputs=inputs, records=[],
        scope='Finite saved-output diagnostics; pure constants are an unqualified upper bound. Timing excludes import/first call; no production or stationarity claim.',
        protocol=dict(rounds=5, roles=ROLES, warmupMs=1000, warmupCalls=3, calibrationMs=50, targetMs=300,
                      minimumMeasuredMs=100, cpu=3, heapMiB=1024, rssMiB=2048, availableMiB=4096, stackKiB=4096))

    def save():
        report['wallSeconds'] = time.monotonic() - start
        support.save(out / 'report.json', report)

    def rehash():
        for item in inputs:
            assert support.identity(item['path']) == item, item['path']

    try:
        save()
        with support.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            cp = out / 'controls.json'
            process = guard.run(['taskset', '-c', '3', str(args.node), '--stack-size=4096', '--max-old-space-size=1024',
                                 str(control), str(args.manifest.resolve()), str(cp)], out / 'controls-process', min(deadline, time.monotonic() + 30))
            report['controlProcess'] = process
            assert process['complete'] and cp.exists()
            report['controls'] = json.loads(cp.read_text())
            report['controlIdentity'] = support.identity(cp)
            assert report['controls']['complete'] and report['controls']['pass']
            for point in points:
                for round_index in range(5):
                    shift = round_index % 3
                    for role in ROLES[shift:] + ROLES[:shift]:
                        rehash()
                        directory = out / ('n%d-r%d-%s' % (point['args'][0], round_index, role))
                        directory.mkdir()
                        config = directory / 'point.json'
                        support.save(config, dict(**point, exportName='bench', warmupMs=1000, warmupCalls=3,
                                                  calibrationMs=50, targetMs=300, maxRepetitions=1000000))
                        sample = directory / 'sample.json'
                        module = manifest['modules'][role]
                        process = guard.run(['taskset', '-c', '3', str(args.node), '--stack-size=4096', '--max-old-space-size=1024',
                                             str(worker), module['path'], str(config), str(sample)], directory / 'process', min(deadline, time.monotonic() + 20))
                        row = dict(role=role, round=round_index, args=point['args'], process=process, passResult=False)
                        report['records'].append(row)
                        if sample.exists():
                            row['sample'] = json.loads(sample.read_text())
                            row['sampleIdentity'] = support.identity(sample)
                            row['configIdentity'] = support.identity(config)
                            s = row['sample']
                            row['passResult'] = process['complete'] and s['complete'] and s['pass'] and s['node'] == 'v24.18.0' \
                                and s['module']['sha256'] == module['sha256'] and s['executionMs'] >= 100
                        save()
                        assert row['passResult'], 'Sample failure or sub-100ms measurement; preserve incomplete report'
                        assert not guard.interrupted
        rehash()
        report['summary'] = []
        for point in points:
            rows = [r for r in report['records'] if r['args'] == point['args']]
            medians = {role: statistics.median(r['sample']['msPerCall'] for r in rows if r['role'] == role) for role in ROLES}
            report['summary'].append(dict(args=point['args'], mediansMs=medians,
                originalOverVariant={role: medians['original']/medians[role] for role in ROLES},
                samples={role: [r['sample']['msPerCall'] for r in rows if r['role'] == role] for role in ROLES},
                halfDriftPercent={role: [r['sample']['halfDriftPercent'] for r in rows if r['role'] == role] for role in ROLES}))
        for row in report['records']:
            assert support.identity(row['sampleIdentity']['path']) == row['sampleIdentity']
            assert support.identity(row['configIdentity']['path']) == row['configIdentity']
        assert support.identity(cp) == report['controlIdentity']
        report['complete'] = report['passed'] = len(report['records']) == 45
        save()
    except Exception as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
