"""Seal retained exact nq_uses products for parent-owned clean timing; no execution."""
import argparse
import hashlib
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--pilot-report', type=Path)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase131') and not out.exists()
    inputs = [pin(__file__), pin(HERE / 'uses.oracle.json'),
              pin(HERE / 'uses.cases.json'), pin(HERE / 'compiler-uses.expected.stdout')]
    count = 1024
    if args.pilot_report:
        pilot = read(args.pilot_report)
        assert pilot['complete'] and pilot['passed']
        rows = [row for row in pilot['rows'] if row['mode'] == 'clean']
        assert len(rows) == 2 and all(row['correct'] for row in rows)
        fastest = min(row['wallSeconds'] for row in rows)
        assert fastest > 0
        count = min(1000000, max(1024, math.ceil(1024 * .5 / fastest)))
        inputs.append(pin(args.pilot_report))
    variants = []
    for role in ('baseline', 'candidate'):
        emission_path = ROOT / f'selfhost/build/phase118/p131-regions-uses01-{role}/report.json'
        build_path = ROOT / f'selfhost/build/phase111/p131-regions-uses01-{role}-build/report.json'
        emission, build = read(emission_path), read(build_path)
        assert emission['complete'] and build['complete'] and build['outputExact']
        assert len(emission['cases']) == 1
        case = emission['cases'][0]
        assert case['verified'] and case['parentVerified']
        for item in [*emission['inputs'], case['source'], case['qbe'], *build['inputs'], build['binary']]:
            assert pin(item['file']) == item, item['file']
            inputs.append(item)
        inputs += [pin(emission_path), pin(build_path)]
        binary = build['binary']
        variants.append(dict(name=role, binary=binary,
            command=[binary['file'], '--threads', '1', '--gpu', 'off', '--', str(count)],
            expected=dict(exitCode=0, stdout=dict(kind='prefix-integer-line', prefix=f'2\n{(count * 2) & 0xffffffff}\n'),
                stderr=dict(kind='exact', bytes=0, sha256=hashlib.sha256(b'').hexdigest()))))
    out.mkdir(parents=True)
    manifest = dict(schema='bend-native-profile-workloads-v1', cwd=str(ROOT), inputs=inputs,
        workloads=[dict(name='compiler-uses', timeoutSeconds=30, variants=variants)],
        repetitions=count,
        scope='Unchanged extracted compiler occurrence-count algorithm on retained shared255-node trees. Same runtime, aligned build and frozen ten-line independent ordinary oracle. Baseline Phase130 vs source03 shallow/virtual borrowing only; no late-inline duplicate preparation. No full-compiler throughput claim.',
        calibration='1024-repetition one-round pilot, optionally choose500ms for fastest whole child, cap1000000. Source/oracle frozen before first execution.')
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=str(out / 'manifest.json'), repetitions=count)))


if __name__ == '__main__':
    main()
