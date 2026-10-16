#!/usr/bin/env python3
"""Freeze complete independent ordered-root observations; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    cases = [('empty', '', ''), ('prefix', 'prefix', 'prefix-tail'),
             ('equal-long', 'aλ🙂' * 1500, 'aλ🙂' * 1500),
             ('late-less', 'aλ🙂' * 1200 + 'a', 'aλ🙂' * 1200 + 'b'),
             ('early-greater', 'Ω123', 'A456')]
    records = []
    for name, left, right in cases:
        cmp = 'lt' if left < right else 'gt' if left > right else 'eq'
        lines = [str(int(left == right)), left, right, cmp, left, right,
                 left, right, cmp]
        expected = out / (name + '.stdout')
        expected.write_text('\n'.join(lines) + '\n')
        records.append(dict(id=name, source=str(HERE / 'observer-controls.bend'),
                            argv=['--pair', left, right], expected=str(expected), workers=[1]))
    def pin(path):
        b = path.read_bytes()
        return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
    report = dict(complete=True, targetsRun=False, records=records,
                  pins=[pin(p) for p in [HERE / 'observer-controls.bend',
                    Path(__file__).resolve(), *sorted(out.iterdir())]],
                  scope='Finite equality/order and exact owned-root identity controls, '
                    'with held aliases then consumed roots. Empty, prefix, Unicode, '
                    'long equal and late mismatch inputs; no target execution by preparer.')
    (out / 'controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), records=len(records))))


if __name__ == '__main__':
    main()
