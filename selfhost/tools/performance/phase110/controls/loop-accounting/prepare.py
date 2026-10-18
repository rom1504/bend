#!/usr/bin/env python3
"""Prepare separately versioned loop accounting; no compiler or target runs."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def pin(path):
    data = path.read_bytes()
    return {'file': str(path.relative_to(ROOT)), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def verify(record):
    actual = pin(ROOT / record['file'])
    if actual != record:
        raise ValueError('changed input: ' + record['file'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for row in [manifest['baselineManifest'], *manifest['baselineFiles'],
                manifest['instrumentedHarness'], manifest['delta'], manifest['policySearch']]:
        verify(row)
    baseline = ROOT / manifest['baselineDirectory']
    original = json.loads((baseline / 'manifest.json').read_text())
    for row in original['outputs']:
        data = Path(row['file']).read_bytes()
        assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], row['file']
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh directory under selfhost/build/phase110 required')
    out.mkdir(parents=True)
    (out / 'harness.c').write_bytes((HERE / 'harness.c').read_bytes())
    for name in ('abi.h', 'cases.inc.c', 'expected.jsonl'):
        (out / name).write_bytes((baseline / name).read_bytes())
    result = {'kind': 'phase110-prepared-loop-accounting-v1', 'complete': True,
              'targetsRun': False, 'baselineDirectory': manifest['baselineDirectory'],
              'trainingCases': 11, 'timingCases': manifest['timingCases'],
              'inputs': [pin(HERE / name) for name in ('prepare.py', 'manifest.json', 'harness.c', 'harness.patch')],
              'outputs': [pin(out / name) for name in ('harness.c', 'abi.h', 'cases.inc.c', 'expected.jsonl')]}
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'complete': True, 'targetsRun': False, 'out': str(out), 'timingCases': len(result['timingCases'])}))


if __name__ == '__main__':
    main()
