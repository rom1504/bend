#!/usr/bin/env python3
"""Authenticate frozen inputs; optionally check an already saved observation."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def verify(pin):
    path = Path(pin['file'])
    if not path.is_absolute():
        path = ROOT / path
    data = path.read_bytes()
    if len(data) != pin['bytes'] or hashlib.sha256(data).hexdigest() != pin['sha256']:
        raise ValueError('changed input: ' + str(path))
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case')
    parser.add_argument('--stdout', type=Path)
    parser.add_argument('--stderr', type=Path)
    parser.add_argument('--exit-code', type=int)
    parser.add_argument('--stage', choices=['execute', 'source-admission'])
    parser.add_argument('--product', type=Path, action='append', default=[])
    args = parser.parse_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for pin in manifest['inputs']:
        verify(pin)
    cases = {row['name']: row for row in manifest['fixtures']}
    cases.update({'broad:' + row['name']: row for row in manifest['representatives']})
    for row in cases.values():
        verify(row['source'])
        for key in ['origin', 'stdoutFile', 'expectationFile', 'independentPriorEvidence']:
            if key in row:
                data = verify(row[key])
                if key in ['stdoutFile', 'independentPriorEvidence']:
                    assert data == row['expect']['stdout'].encode()
    result = dict(kind='phase111-frozen-input-verification', complete=True,
                  focused=len(manifest['fixtures']), representatives=len(manifest['representatives']),
                  targetsExecutedByThisTool=False)
    if args.case:
        case = cases[args.case]
        expected = case['expect']
        if args.stage != expected['stage'] or args.exit_code is None:
            raise ValueError('supply actual stage and exit code')
        if args.stage == 'execute':
            if args.stdout is None or args.stderr is None:
                raise ValueError('supply saved stdout and stderr')
            assert args.exit_code == expected['exitCode']
            assert args.stdout.read_bytes() == expected['stdout'].encode()
            assert args.stderr.read_bytes() == expected['stderr'].encode()
        else:
            if not args.product:
                raise ValueError('supply every intended QBE/data/object/executable product path')
            assert args.exit_code != 0
            assert not any(path.exists() for path in args.product)
        result.update(case=args.case, savedObservationMatches=True)
    print(json.dumps(result))


if __name__ == '__main__':
    main()
