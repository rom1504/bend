#!/usr/bin/env python3
"""Freeze full independent TRMC outputs and a separate all-hot sharing fixture."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def value(n, wide):
    # Build a flat description, then close delimiters; no recursive constructor
    # representation or copy of the Bend recursive rendering implementation.
    left, right = 'λleft', '🙂right'
    pieces = []
    for remaining in range(n, 0, -1):
        pieces.append(f'W{{{left};{remaining - 1};{right};' if wide else f'S{{{left};')
        left, right = right, left
        wide = not wide
    return ''.join(pieces) + 'E{' + left + '}' + '}' * n


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    source = (HERE / 'mixed-construction.bend').read_text()
    shared_main = '''def main() -> IO(Unit):
  +left : String = String.append("λ", "left")
  +right : String = String.append("🙂", "right")
  +trail : MixedTrail = mixed_build(6n, left, right, True{})
  do IO<Unit>:
    IO.print(mixed_text(trail))
    IO.print(mixed_text(trail))
    IO.print(left)
    IO.print(right)
'''
    unique = out / 'mixed-construction.bend'; unique.write_text(source)
    shared = out / 'shared-construction.bend'
    shared.write_text(source[:source.index('def main()')] + shared_main)
    records = []
    for name, src, rows, policies in [
        ('mixed', unique, [value(0, False), value(1, False), value(1, True),
                           value(5, False), value(6, True), 'λleft', '🙂right'],
         ['natural', 'all-hot', 'all-cold', 'short-hot-wide-cold-end-cold',
          'short-cold-wide-hot-end-cold', 'short-cold-wide-cold-end-hot']),
        ('shared', shared, [value(6, True), value(6, True), 'λleft', '🙂right'],
         ['natural', 'all-hot']),
    ]:
        expected = out / (name + '.stdout'); expected.write_bytes(('\n'.join(rows) + '\n').encode())
        records.append(dict(id=name, source=pin(src), stdout=pin(expected), stderr='', exit=0,
                            policies=policies, workers=[1, 2, 4]))
    report = dict(kind='phase102-trmc-destination-policy-controls', complete=True,
                  targetsRun=False, method=pin(Path(__file__)), template=pin(HERE / 'mixed-construction.bend'),
                  records=records,
                  scope='Prepared independent finite full-value controls only; admission, TRMC code shape and executions unperformed.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), cases=len(records), targetsRun=False)))


if __name__ == '__main__': main()
