#!/usr/bin/env python3
"""Root-only bounded native f_find timing; importing this file runs no target."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
COMMON = ROOT / 'selfhost/tools/laws/phase97/common.py'
sys.path.insert(0, str(COMMON.parent))
from common import BUILD, GUARD, pin, read, save, verify, run, passed

ROLES = ['baseline', 'candidate']
SHAPES = [('128-head', 128, 0), ('128-middle', 128, 1), ('128-miss', 128, 2),
          ('128-tail', 128, 3), ('8-miss', 8, 2), ('1024-miss', 1024, 2)]
LIMIT = 2_000_000
FLOOR_MS, CEILING_MS, TARGET_MS = 200, 800, 300


def adjusted_count(count, ms, target=TARGET_MS):
    estimate = math.ceil(count * target / max(ms, 1))
    return max(1, min(LIMIT, count * 16, max(math.ceil(count / 16), estimate)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--frozen', type=Path, default=BUILD / 'projection-frozen02')
    parser.add_argument('--baseline', type=Path, default=BUILD / 'projection-micro-baseline01')
    parser.add_argument('--candidate', type=Path, default=BUILD / 'projection-micro-candidate01')
    args = parser.parse_args()
    out, frozen = args.out.resolve(), args.frozen.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    products = {role: getattr(args, role).resolve() for role in ROLES}
    out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, inputsUnchanged=False, inputs=[], records=[], cases=[], scaling=[],
                  scope='Actual extracted f_find with a shared original book. Timed work includes the success-count print; setup and full output/alias serialization are outside the timer. This is not compiler latency.',
                  semantics='All non-timing stdout lines match the frozen independent reference exactly. The timed loop checks a discriminating arity; the separate full contract suite checks every field.',
                  bounds=dict(minMeasuredMs=FLOOR_MS, maxMeasuredMs=CEILING_MS, targetMs=TARGET_MS,
                              repetitionCap=LIMIT, processSeconds=30, campaignSeconds=180, rounds=3),
                  calibration='Independent per role/shape; retain excluded out-of-window attempts; normalize each accepted sample by its own invocation count; alternate role order each round.')
    pins = {}

    def write():
        save(out / 'report.json', report)

    def bind(file, expected=None):
        item = pin(file)
        if expected is not None:
            assert item == expected, (str(file), 'input identity changed')
        if item['file'] in pins:
            assert pins[item['file']] == item
        pins[item['file']] = item
        report['inputs'] = list(pins.values())
        return item

    write()
    try:
        for file in [Path(__file__), COMMON, GUARD,
                     ROOT / 'selfhost/tools/performance/programs/support.py',
                     ROOT / 'selfhost/tools/performance/phase95/membership-run-v2.py']:
            bind(file)
        # Keep the executed method bytes alongside their identities.
        (out / 'measure.py').write_bytes(Path(__file__).read_bytes())
        bind(frozen / 'receipt.json')
        receipt = read(frozen / 'receipt.json')
        assert receipt['complete'] and not receipt['targetsRun']
        for item in receipt['methods']:
            bind(item['file'], item)
        reference_file = frozen / 'methods/reference.py'
        bind(reference_file)
        spec = importlib.util.spec_from_file_location('phase97_frozen_reference', reference_file)
        reference = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(reference)
        for role in ROLES:
            manifest = frozen / role / 'manifest.json'
            bind(manifest, receipt['manifests'][role])
            source_pin = pin(frozen / role / 'micro.bend')
            assert source_pin in read(manifest)['frozenInputs']
            bind(source_pin['file'], source_pin)
            acquisition = products[role] / 'report.json'
            bind(acquisition)
            data = read(acquisition)
            assert data['complete'] and data['holes'] == 0 and not data.get('error'), role
            assert data['source'] == source_pin, (role, 'wrong acquired source')
            assert data['upstream']['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
            for item in [data['source'], data['c'], data['method'], data['host'],
                         *data['loadedFiles'], *data['upstream']['inputs']]:
                bind(item['file'], item)
            bind(products[role] / 'program')
        report['binaries'] = {role: pins[str(products[role] / 'program')] for role in ROLES}
        report['binaryProvenanceLimit'] = 'Acquisition source/C receipts and the supplied compiled binary are pinned; root owns the guarded Clang build receipt linking each C input to that binary.'
        expected = {}
        for name, size, mode in SHAPES:
            value = reference.micro_expected(0, size, mode)
            path = out / (name + '.expected.json')
            save(path, value)
            expected[name] = value
        report['oracles'] = {name: pin(out / (name + '.expected.json')) for name, _, _ in SHAPES}
        write()
        deadline = time.monotonic() + 180

        def sample(shape, role, count, stage, round_number=None):
            name, size, mode = shape
            assert 0 < count <= LIMIT < 2**32
            remaining = deadline - time.monotonic()
            assert remaining >= 1, 'Campaign wall budget exhausted'
            binary = products[role] / 'program'
            verify(report['binaries'][role])
            folder = out / f'{len(report["records"]):03d}-{name}-{stage}-{role}'
            row = dict(shape=name, size=size, mode=mode, role=role, repetitions=count,
                       stage=stage, round=round_number, directory=str(folder), correct=False,
                       accepted=False)
            report['records'].append(row)
            write()
            job = run(folder, [binary, '--threads', '1', '--gpu', 'off', '--', str(count), str(size), str(mode)],
                      seconds=min(30, int(remaining)), rss=1024)
            # Full output stays in raw files, not duplicated into every report revision.
            row.update(process=job['process'], receipt=job['receipt'],
                       stdout=pin(folder / 'stdout.log'), stderr=pin(folder / 'stderr.log'))
            write()
            assert passed(job), (name, role, 'guard or target failure')
            assert not job['stderr'], (name, role, 'unexpected stderr')
            lines = job['stdout'].splitlines()
            assert len(lines) == 5 and lines[1].isdigit() and lines[2].isdigit(), (name, role, 'stdout shape')
            oracle = reference.micro_expected(count, size, mode)
            assert oracle['initial'] == expected[name]['initial'] and oracle['alias'] == expected[name]['alias']
            render = lambda value: json.dumps(value, separators=(',', ':'))
            checks = dict(initial=lines[0] == render(oracle['initial']),
                          successes=lines[1] == str(oracle['successes']), final=lines[3] == render(oracle['final']),
                          originalAlias=lines[4] == render(oracle['alias']))
            ms = int(lines[2])
            row.update(elapsedMs=ms, lineMatches=checks, correct=all(checks.values()),
                       usPerInvocation=ms * 1000 / count)
            write()
            assert row['correct'], (name, role, checks)
            assert ms <= job['process']['wallSeconds'] * 1000 + 2, 'Invalid elapsed timer'
            return row

        def calibrate(shape, role, start=100, stage='calibrate', low=250, high=400):
            count = start
            for attempt in range(8):
                row = sample(shape, role, count, 'pilot' if attempt == 0 and stage == 'calibrate' else stage)
                if low <= row['elapsedMs'] <= high:
                    row['accepted'] = True
                    write()
                    return count, row
                next_count = adjusted_count(count, row['elapsedMs'])
                assert next_count != count, (shape, role, 'calibration cap/floor')
                count = next_count
            raise AssertionError((shape, role, 'calibration exhausted'))

        for index, shape in enumerate(SHAPES):
            name, size, mode = shape
            counts = {}
            for role in ROLES if index % 2 == 0 else ROLES[::-1]:
                counts[role], _ = calibrate(shape, role)
            measured = []
            for round_number in range(1, 4):
                for role in ROLES if (index + round_number) % 2 == 1 else ROLES[::-1]:
                    for attempt in range(3):
                        row = sample(shape, role, counts[role], 'measure', round_number)
                        if FLOOR_MS <= row['elapsedMs'] <= CEILING_MS:
                            row['accepted'] = True
                            measured.append(row)
                            write()
                            break
                        counts[role] = adjusted_count(counts[role], row['elapsedMs'])
                    else:
                        raise AssertionError((name, role, 'measurement outside timing window'))
            stats = {}
            for role in ROLES:
                selected = [row for row in measured if row['role'] == role]
                assert len(selected) == 3
                values = [row['usPerInvocation'] for row in selected]
                stats[role] = dict(repetitions=[row['repetitions'] for row in selected],
                                   medianUs=statistics.median(values), minUs=min(values), maxUs=max(values))
            result = dict(shape=name, size=size, mode=mode, roles=stats,
                          candidateOverBaseline=stats['candidate']['medianUs'] / stats['baseline']['medianUs'])
            report['cases'].append(result)
            write()
            print(json.dumps(result), flush=True)
            if index == 0:
                # One doubled sample per role. A fresh base around 300ms keeps
                # the doubled run inside the same 200..800ms window.
                for role in ROLES:
                    initial = max(1, min(LIMIT // 2, math.ceil(TARGET_MS * 1000 / stats[role]['medianUs'])))
                    count, base = calibrate(shape, role, initial, stage='scaling-base')
                    assert count * 2 <= LIMIT
                    doubled = sample(shape, role, count * 2, 'scaling-double')
                    ratio = doubled['elapsedMs'] / base['elapsedMs']
                    row = dict(role=role, shape=name, repetitions=count, baseMs=base['elapsedMs'],
                               doubleMs=doubled['elapsedMs'], doubleCountRatio=ratio,
                               passed=FLOOR_MS <= doubled['elapsedMs'] <= CEILING_MS and 1.5 <= ratio <= 2.5)
                    report['scaling'].append(row)
                    doubled['accepted'] = row['passed']
                    write()
                    assert row['passed'], ('doubling control', row)
        for item in pins.values():
            verify(item)
        for item in report['oracles'].values():
            verify(item)
        report.update(complete=True, inputsUnchanged=True)
    except BaseException as error:
        report.update(complete=False, error=repr(error))
        raise
    finally:
        write()
    print(json.dumps(dict(complete=True, cases=len(report['cases']), records=len(report['records']),
                          inputsUnchanged=True)), flush=True)


if __name__ == '__main__':
    main()
