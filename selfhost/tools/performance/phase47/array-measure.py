#!/usr/bin/env python3
"""Serial, oracle-checked timing of the four saved array probe variants.

Defaults: 8192 repetitions, 8192 warmups, five rotated rounds. Use --check-only
with small counts for correctness; this grants no timing credit. Root alone
runs this controller. No profiling or compiler acquisition is performed.
"""
import argparse
import hashlib
import importlib.util
import json
import statistics
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PHASE46 = ROOT / 'selfhost/tools/performance/phase46'
VARIANTS = ['original', 'shell', 'view', 'length']
PARENT_SHA = '0a079e6ee0ce4f8c261943cd708c86df1d7dd2e0d67cf4d72e91b0122ad8a2a4'
PINS = {
    'selfhost/build/phase46/oracles.json': 'acddea0fcd157f223798ab9b0ecd81c28472461a4a2de8c5535dcfddf1f345a0',
    'selfhost/tools/performance/phase46/oracle.py': 'd7ad109d37b5beb210dfd4942f6d5baa6a2e14a02abb57ac18db656a16d9d2ad',
    'selfhost/tools/performance/phase46/execute.py': '5e24c95228ea620468db7814ce5ece921d969f3466ccf1a66e51c532234114b2',
    'selfhost/tools/performance/programs/support.py': '36e000b43f92809e2de0bcdb462e6e42005fad7341f6ec2122734311073d1cef',
}


def identity(file):
    file = Path(file).resolve(strict=True)
    digest = hashlib.sha256()
    with file.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return dict(path=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)


def recorded(item):
    actual = identity(item.get('path') or item.get('file') or item['canonicalPath'])
    assert actual['sha256'] == item['sha256'], actual['path']
    if 'bytes' in item:
        assert actual['bytes'] == item['bytes'], actual['path']
    return actual


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--repetitions', type=int, default=8192)
    parser.add_argument('--warmups', type=int, default=8192)
    parser.add_argument('--rounds', type=int, default=5)
    parser.add_argument('--check-only', action='store_true')
    parser.add_argument('--node', type=Path, default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    args = parser.parse_args()
    assert 0 <= args.repetitions <= 100000 and 0 <= args.warmups <= 100000
    assert 1 <= args.rounds <= 25
    inputs = [identity(Path(__file__)), identity(args.manifest), identity(args.node), identity(sys.executable)]
    for relative, expected in PINS.items():
        item = identity(ROOT / relative)
        assert item['sha256'] == expected, relative
        inputs.append(item)
    support = module('phase47_array_support', ROOT / 'selfhost/tools/performance/programs/support.py')
    oracle = module('phase47_array_oracle', PHASE46 / 'oracle.py')
    saved = json.loads((ROOT / 'selfhost/build/phase46/oracles.json').read_text())
    assert saved['complete'] is True and saved['kind'] == 'phase46-independent-batch-oracles'
    assert saved['cycle'] == 16 and saved['initial'] == 2166136261
    inputs.extend(recorded(item) for item in saved['inputs'])
    case = next(row for row in saved['cases'] if row['name'] == 'array')
    assert case['base'] == case['values'][0] == 2339999928
    assert len(case['values']) == 16
    assert oracle.digest(case['values'], 2) == case['defaultWarmDigest']
    assert oracle.digest(case['values'], 8) == case['defaultMeasuredDigest']
    manifest = json.loads(args.manifest.read_text())
    assert manifest['kind'] == 'phase47-array-view-probe' and manifest['complete'] is True
    assert manifest['diagnosticOnly'] is True and manifest['productionSafe'] is False
    assert set(manifest['variants']) == set(VARIANTS)
    inputs.extend(recorded(item) for item in manifest['inputs'])
    inputs.extend(recorded(item) for item in manifest['parentCompiler'])
    inputs.append(recorded(manifest['parentSource']))
    assert manifest['parentSource']['sha256'] == case['wrapper']['sha256']
    assert manifest['inputs'][0]['sha256'] == PARENT_SHA
    modules = {name: recorded(manifest['variants'][name]['module']) for name in VARIANTS}
    assert modules['original']['sha256'] == PARENT_SHA
    assert len({item['sha256'] for item in modules.values()}) == 4
    inputs.extend(modules.values())
    expected = [case['base'], oracle.digest(case['values'], args.warmups),
                oracle.digest(case['values'], args.repetitions)]
    output = args.out.resolve()
    output.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase47-array-probe-measurement', schemaVersion=1, complete=False,
        passed=False, started=time.time(), correctnessPass=False, timingPass=False,
        productionSafe=False, mode='correctness-only' if args.check_only else 'clean-timing',
        inputs=inputs, modules=modules, expected=expected, records=[],
        configuration=dict(repetitions=args.repetitions, warmups=args.warmups, rounds=args.rounds,
            cpu=3, nodeHeapMiB=1024, processTreeRssMiB=2048, availableFloorMiB=4096,
            childDeadlineSeconds=60, minimumElapsedMs=100, order='rotate original,shell,view,length each round'),
        scope='Fresh process per sample; fixed warmup, batch IO.now interval includes digest formatting/print. No JIT stationarity or production-equivalence claim; no profiles.')

    def save():
        report['finished'] = time.time()
        support.save(output / 'report.json', report)

    try:
        save()
        with support.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            version_dir = output / 'node-version'
            version = guard.run(['taskset', '-c', '3', str(args.node.resolve()), '--version'],
                                version_dir, time.monotonic() + 10)
            assert version['complete'], 'Node version acquisition failed'
            report['nodeVersion'] = (version_dir / 'stdout.log').read_text().strip()
            assert report['nodeVersion'] == 'v24.18.0', 'The preserved acquisition used Node v24.18.0'
            report['nodeVersionProcess'] = version
            report['nodeVersionOutputs'] = [identity(file) for file in sorted(version_dir.iterdir()) if file.is_file()]
            for round_index in range(args.rounds):
                shift = round_index % len(VARIANTS)
                for variant in VARIANTS[shift:] + VARIANTS[:shift]:
                    assert identity(modules[variant]['path']) == modules[variant]
                    directory = output / ('round-%02d-%s' % (round_index, variant))
                    child = directory / 'child.json'
                    command = [str(args.node.resolve()), '--max-old-space-size=1024', modules[variant]['path'],
                               '--threads', '1', '--gpu', 'off', '--', str(args.repetitions), str(args.warmups)]
                    process = guard.run(['taskset', '-c', '3', sys.executable, str(PHASE46 / 'execute.py'),
                                         str(child), *command], directory, time.monotonic() + 60)
                    row = dict(variant=variant, round=round_index, process=process, correct=False,
                               validClock=False, timingQualified=False, expected=expected)
                    if child.exists():
                        observation = json.loads(child.read_text())
                        row['child'] = observation
                        lines = observation['stdout'].strip().splitlines()
                        if len(lines) == 4 and all(value.isdecimal() for value in lines):
                            values = list(map(int, lines))
                            row['observed'] = values
                            row['correct'] = process['complete'] and observation['returncode'] == 0 and values[:3] == expected
                            row['elapsedMs'] = values[3]
                            row['validClock'] = 0 <= values[3] <= observation['processSeconds'] * 1000 + 2
                            row['timingQualified'] = row['correct'] and row['validClock'] and values[3] >= 100
                    row['outputs'] = [identity(file) for file in sorted(directory.iterdir()) if file.is_file()]
                    report['records'].append(row)
                    save()
                    print(json.dumps({key: row.get(key) for key in ['variant', 'round', 'correct', 'elapsedMs', 'timingQualified']}), flush=True)
                    assert row['correct'], 'Checksum/process failure; stopping remaining samples'
                    assert row['validClock'], 'Clock exceeds observed process duration'
                    assert not guard.interrupted, 'Guard interrupted'
        for item in inputs:
            assert identity(item['path']) == item, 'Consumed input changed'
        for row in report['records']:
            for item in row['outputs']:
                assert identity(item['path']) == item, 'Recorded output changed'
        for item in report['nodeVersionOutputs']:
            assert identity(item['path']) == item, 'Node version output changed'
        report['correctnessPass'] = len(report['records']) == args.rounds * 4 and all(row['correct'] for row in report['records'])
        report['timingPass'] = not args.check_only and report['correctnessPass'] and all(row['timingQualified'] for row in report['records'])
        if report['timingPass']:
            medians = {variant: statistics.median(row['elapsedMs'] for row in report['records'] if row['variant'] == variant) for variant in VARIANTS}
            report['summary'] = {variant: dict(medianElapsedMs=medians[variant],
                originalOverVariant=medians['original'] / medians[variant],
                pairedOriginalOverVariant=[next(row['elapsedMs'] for row in report['records'] if row['round'] == r and row['variant'] == 'original') /
                    next(row['elapsedMs'] for row in report['records'] if row['round'] == r and row['variant'] == variant) for r in range(args.rounds)]) for variant in VARIANTS}
        report['complete'] = True
        report['passed'] = report['correctnessPass'] if args.check_only else report['timingPass']
        if not report['passed']:
            report['inconclusive'] = 'At least one sample is below the 100ms qualification threshold; no speed summary.'
        save()
        return 0 if report['passed'] else 2
    except Exception as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    raise SystemExit(main())
