#!/usr/bin/env python3
"""Independently rehash every captured complete object against hosted evidence."""
import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path


def digest(path):
    path = Path(path)
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            h.update(block)
    return dict(bytes=path.stat().st_size, sha256=h.hexdigest())


def check(pin):
    actual = digest(pin['file'])
    if any(actual[k] != pin[k] for k in actual):
        raise ValueError('Changed evidence: '+pin['file'])
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--roles', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    roles = json.loads(args.roles.read_text())
    report = json.loads(args.report.read_text())
    if not report.get('complete') or not report.get('passed'):
        raise ValueError('Incomplete/failed capture campaign')
    expected = check(roles['independentOutput'])
    check(roles['independentComparison'])
    comparison = json.loads(Path(roles['independentComparison']['file']).read_text())
    provenance = next(r for r in comparison['rows'] if
                      r['left']['object'] == roles['independentOutput'])
    if not comparison['complete'] or not provenance['objectIdentical']:
        raise ValueError('Independent hosted provenance is incomplete')
    counts, checked = Counter(), []
    for row in report['rows']:
        role = roles['roles'][row['variant']]
        if (row['command'] != role['request']['command'] or row['argv0'] != 'compiler-work'
                or row['returncode'] != 0 or row['timedOut'] or not row['correct']):
            raise ValueError('Request/status mismatch')
        check(role['image'])
        check(role['imageReceipt'])
        if check(row['stdout']) != expected or check(row['stderr'])['bytes'] != 0:
            raise ValueError('Complete stdout/stderr mismatch')
        counts[row['variant'], row['mode']] += 1
        checked.append(dict(role=row['variant'], mode=row['mode'], stdout=row['stdout']))
    for role in roles['roles']:
        if counts[role, 'clean'] != 2 or counts[role, 'sample'] != 4:
            raise ValueError('Expected two clean and four sampled requests per role')
    if len(checked) != 12:
        raise ValueError('Unexpected capture count')
    result = dict(complete=True, targetsRun=False, exactOutputs=len(checked),
        independentOutput=roles['independentOutput'], checked=checked,
        report=dict(file=str(args.report.resolve()), **digest(args.report)),
        method=dict(file=str(Path(__file__).resolve()), **digest(__file__)),
        scope='Separate complete-byte/status check; no profile-quality or correctness proof.')
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, exactOutputs=len(checked))))


if __name__ == '__main__':
    main()
