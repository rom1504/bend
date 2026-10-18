#!/usr/bin/env python3
"""Prepare direct-worker call-shape controls without compiling or executing."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def pin(path):
    return dict(file=str(path), bytes=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--split', choices=['all', 'training', 'heldout'], default='all')
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for key in ('source', 'parentFrozenSource', 'catalogue', 'cases', 'expected', 'harness', 'initializers'):
        item = manifest[key]
        if pin(ROOT / item['file'])['sha256'] != item['sha256']:
            raise ValueError('frozen call-shape input changed: ' + item['file'])
    cases = [c for c in json.loads((HERE / 'cases.json').read_text())['cases'] if args.split == 'all' or c['split'] == args.split]
    out.mkdir(parents=True)
    for name in ('harness.c', 'catalogue.json', 'source.bend'):
        (out / name).write_bytes((HERE / name).read_bytes())
    (out / 'cases.inc.c').write_text('static const Case CASES[] = {\n' + ',\n'.join('  {%s, %d, %d}' % (json.dumps(c['name']), c['op'], c['shape']) for c in cases) + '\n};\n')
    names = {c['name'] for c in cases}
    (out / 'expected.jsonl').write_text(''.join(line + '\n' for line in (HERE / 'expected.jsonl').read_text().splitlines() if json.loads(line)['name'] in names))
    abi = ROOT / 'selfhost/tools/performance/phase109/runtime/abi.h'
    (out / 'abi.h').write_bytes(abi.read_bytes())
    record = dict(kind='phase110-prepared-call-shape-controls', complete=True, targetsRun=False, cases=len(cases), split=args.split,
        inputs=[pin(HERE / name) for name in ('prepare.py', 'manifest.json', 'harness.c', 'cases.json', 'expected.jsonl', 'catalogue.json', 'source.bend')] + [pin(abi)],
        outputs=[pin(out / name) for name in ('harness.c', 'cases.inc.c', 'expected.jsonl', 'abi.h', 'catalogue.json', 'source.bend')])
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(cases), split=args.split, out=str(out))))


if __name__ == '__main__':
    main()
