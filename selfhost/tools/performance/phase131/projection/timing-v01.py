"""Seal three-role, two-length proxy comparisons; no target execution here."""
import argparse
import hashlib
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
DIGEST = 3516497831
ROLES = ('baseline', 'closure', 'candidate')
CASES = ('projection-string', 'projection-list')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    with Path(path).open('x') as stream:
        stream.write(json.dumps(value, indent=2) + '\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--pilot-report', type=Path)
    args = ap.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase131') and not out.exists()
    inputs = [pin(__file__), pin(HERE / 'cases-v05.json'), pin(HERE / 'expected.stdout')]
    binaries = {}
    for role in ROLES:
        for case in CASES:
            stem = (f'p131-projection-loop04-baseline-{case}-build' if role == 'baseline'
                    else f'p131-projection06-{role}-{case}-build')
            report_path = ROOT / 'selfhost/build/phase111' / stem / 'report.json'
            report = read(report_path)
            assert report['complete'] and report['outputExact']
            for item in report['inputs'] + [report['binary']]:
                assert pin(item['file']) == item
            inputs += [pin(report_path), *report['inputs'], report['binary']]
            binaries[role, case] = report['binary']
    repeats = {f'{case}-size{size}': 2048 for case in CASES for size in (8, 128)}
    if args.pilot_report:
        pilot = read(args.pilot_report); assert pilot['complete'] and pilot['passed']
        inputs += [pin(args.pilot_report)]
        for workload in repeats:
            rows = [r for r in pilot['rows'] if r['workload'] == workload and r['mode'] == 'clean']
            assert len(rows) == 3 and all(r['correct'] for r in rows)
            seconds = min(r['wallSeconds'] for r in rows); assert seconds > 0
            repeats[workload] = min(1000000, max(2048, math.ceil(2048 * .35 / seconds)))
    out.mkdir(parents=True)

    def manifest(long_prefix=False):
        workloads = []
        for case in CASES:
            for size in ((4096,) if long_prefix else (8, 128)):
                name = f'{case}-size{size}'; count = 1 if long_prefix else repeats[name]
                warm = 0 if long_prefix else 2
                prefix = f'{DIGEST}\n{(DIGEST * warm) & 0xffffffff}\n{(DIGEST * count) & 0xffffffff}\n'
                variants = []
                for role in ROLES:
                    binary = binaries[role, case]
                    variants.append(dict(name=role, binary=binary,
                        command=[binary['file'], '--threads', '1', '--gpu', 'off', '--',
                                 str(count), str(warm), str(size), '0'],
                        expected=dict(exitCode=0, stdout=dict(kind='prefix-integer-line', prefix=prefix),
                            stderr=dict(kind='exact', bytes=0, sha256=hashlib.sha256(b'').hexdigest()))))
                workloads.append(dict(name=name, timeoutSeconds=30, variants=variants))
        return dict(schema='bend-native-profile-workloads-v1', cwd=str(ROOT), inputs=inputs,
            workloads=workloads, repetitions=repeats,
            scope='Same program source and runtime/aligned build across qualified parent, worker-closure-only control and product-projection candidate. Ordinary independent outputs already pass. Length8 exposes fixed construction cost; length128 retains original traversal cost. No compiler throughput claim.',
            calibration='2048-repetition clean pilot, then target350ms for fastest whole-child variant with1000000 cap. Actual per-role durations and consumed internal milliseconds remain in raw stdout; no confidence-interval claim.')
    save(out / 'manifest.json', manifest())
    if not args.pilot_report:
        save(out / 'long-prefix.json', manifest(True))
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=str(out / 'manifest.json'), repetitions=repeats)))


if __name__ == '__main__':
    main()
