#!/usr/bin/env python3
"""Freeze independent complete-value local-worker controls, without execution."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def expected(text):
    return ('\n'.join([text + '|L', text + '|R', text,
                       text + '|L:' + text + '|L',
                       '17023,23017,4294967295', '5007,9011']) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    records = []
    for name, text in [('empty', ''), ('ascii', 'runtime-text'),
                       ('unicode', 'λ🙂\tΩ'), ('long', 'xλ🙂' * 257)]:
        path = out / (name + '.stdout')
        path.write_bytes(expected(text))
        records.append(dict(id=name, source=str(HERE / 'controls.bend'),
                            argv=['--text', text], expected=str(path), workers=[1]))
    def fork(depth, value):
        return 3 * value + 7 if not depth else fork(depth - 1, value + 1) + fork(depth - 1, value + 2)
    path = out / 'bang.stdout'
    path.write_text(str(fork(3, 11)) + '\n')
    records.append(dict(id='bang', source=str(HERE / 'controls-bang.bend'),
                        argv=[], expected=str(path), workers=[1, 2, 4],
                        requireBaselineCIdentity=True))
    def pin(path):
        data = path.read_bytes()
        return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    report = dict(kind='phase102-local-worker-controls', complete=True, targetsRun=False,
                  records=records, pins=[pin(p) for p in [HERE / 'controls.bend',
                  HERE / 'controls-bang.bend', Path(__file__).resolve(), *sorted(out.iterdir())]],
                  scope='Finite value/alias/drop/partial/dynamic/scalar-boundary controls. '
                  'Argument positions are independently observed; evaluation-order '
                  'preservation additionally depends on reusing ordered argument lowering. '
                  'No runtime proof or finite coverage of all effect/error-order behavior.')
    (out / 'controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), records=len(records))))


if __name__ == '__main__':
    main()
