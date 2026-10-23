#!/usr/bin/env python3
"""Require an exact QBE difference of only the independently admitted live-bank flag."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
DESCRIPTOR = re.compile(rb'((?:export )?data \$p111_program = align 8 \{)([^}]+)(\}.*)')


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--before', type=Path, required=True)
    parser.add_argument('--after', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase127'):
        raise ValueError('Fresh Phase127 report required')
    report = dict(complete=False, inputs=[pin(__file__), pin(args.before), pin(args.after)],
                  changedLines=[], scope='Read-only byte comparison; exactly one descriptor flag change required. No target execution or semantic qualification.')
    try:
        with args.before.open('rb') as before, args.after.open('rb') as after:
            for number, (left, right) in enumerate(itertools.zip_longest(before, after), 1):
                if left == right:
                    continue
                if left is None or right is None:
                    raise ValueError('Different QBE line counts')
                match = DESCRIPTOR.fullmatch(left.rstrip(b'\n'))
                if not match:
                    raise ValueError('Non-descriptor difference at line ' + str(number))
                fields = match[2].split(b',')
                if len(fields) != 24:
                    raise ValueError('Unexpected descriptor field count')
                value = re.fullmatch(rb'(\s*l\s+)([0-9]+)(\s*)', fields[11])
                if not value:
                    raise ValueError('Unexpected capability field')
                old = int(value[2])
                if old & 4:
                    raise ValueError('Parent already enables the live bank')
                fields[11] = value[1] + str(old | 4).encode() + value[3]
                reconstructed = match[1] + b','.join(fields) + match[3] + (b'\n' if left.endswith(b'\n') else b'')
                if right != reconstructed:
                    raise ValueError('Additional descriptor changes')
                report['changedLines'].append(dict(line=number, before=old, after=old | 4))
        if len(report['changedLines']) != 1:
            raise ValueError('Expected exactly one restored live-bank flag')
        for item in report['inputs']:
            if pin(item['file']) != item:
                raise ValueError('Input changed during comparison')
        report['complete'] = True
    except Exception as error:
        report['error'] = str(error)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=report['complete'], changedLines=report['changedLines'], error=report.get('error'))))
    raise SystemExit(0 if report['complete'] else 1)


if __name__ == '__main__':
    main()
