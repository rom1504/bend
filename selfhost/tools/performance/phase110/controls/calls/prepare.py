#!/usr/bin/env python3
"""Prepare frozen append graph data with independent aliased argument ownership."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def pin(path):
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest(), bytes=path.stat().st_size)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--split', choices=['all', 'training', 'heldout'], default='all')
    args = parser.parse_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for key in ('source', 'originalSource', 'cases', 'expected', 'reference', 'observationCode'):
        record = manifest[key]
        if pin(ROOT / record['file'])['sha256'] != record['sha256']:
            raise ValueError('frozen append control changed: ' + record['file'])
    cases = [case for case in json.loads((HERE / 'cases.json').read_text())['cases'] if args.split == 'all' or case['split'] == args.split]
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh directory under selfhost/build/phase110 required')
    lines, records = [], []
    for i, case in enumerate(cases):
        for side in ('input', 'acc'):
            texts = []
            for j, value in enumerate(case[side + 'Strings']):
                name = f'c{i}_{side}_{j}'
                lines.append(f'static const uint32_t {name}[] = {{{", ".join(str(ord(c)) for c in value) or "0"}}};')
                texts.append(f'{{{name}, {len(value)}}}')
            lines.append(f'static const Text c{i}_{side}[] = {{{", ".join(texts) or "{NULL, 0}"}}};')
        aliases = ['{%d, %d, %d}' % ({'root': 0, 'tail': 1, 'head': 2, 'acc-root': 3, 'acc-tail': 4, 'acc-head': 5}[a['from']], a.get('offset', 0), a['kind'] == 'string') for a in case['aliases']]
        lines.append(f'static const Alias c{i}_aliases[] = {{{", ".join(aliases) or "{0, 0, 0}"}}};')
        offset = -1 if case['accFromInputTailOffset'] is None else case['accFromInputTailOffset']
        records.append('{%s, 0, %d, %d, c%d_input, c%d_acc, %d, %d, c%d_aliases, %d, {NULL, 0}, %d, %d}' % (
            json.dumps(case['name']), case['staticInput'], case['inputPatternRepeats'], i, i,
            len(case['inputStrings']), len(case['accStrings']), i, len(case['aliases']), case['accPatternRepeats'], offset))
    lines.append('static const Case CASES[] = {\n  ' + ',\n  '.join(records) + '\n};')
    out.mkdir(parents=True)
    (out / 'cases.inc.c').write_text('\n'.join(lines) + '\n')
    (out / 'harness.c').write_text('#define P110_SELECTOR 3\n' + (HERE / 'harness.c').read_text())
    abi = ROOT / 'selfhost/tools/performance/phase109/runtime/abi.h'
    (out / 'abi.h').write_bytes(abi.read_bytes())
    known = {case['name'] for case in cases}
    expected = [line for line in (HERE / 'expected.jsonl').read_text().splitlines() if json.loads(line)['name'] in known]
    (out / 'expected.jsonl').write_text('\n'.join(expected) + '\n')
    record = dict(kind='phase110-prepared-call-controls', version=1, complete=True, targetsRun=False, split=args.split, cases=len(cases),
        inputs=[pin(HERE / name) for name in ('prepare.py', 'harness.c', 'manifest.json', 'cases.json', 'expected.jsonl')] + [pin(abi)],
        outputs=[pin(out / name) for name in ('harness.c', 'abi.h', 'cases.inc.c', 'expected.jsonl')])
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(cases), split=args.split, out=str(out))))


if __name__ == '__main__':
    main()
