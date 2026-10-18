#!/usr/bin/env python3
"""Authenticate frozen controls and prepare C graph data. Runs no compiler/target."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
SPEC = importlib.util.spec_from_file_location('reference', HERE / 'reference.py')
REFERENCE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(REFERENCE)


def pin(path):
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest(), bytes=path.stat().st_size)


def verify():
    manifest = json.loads((HERE / 'manifest.json').read_text())
    records = [manifest['ownershipCases'], manifest['oracleCode'], manifest['sourceFixture'], *manifest['expected'], *manifest['oldControls']]
    records += [row[key] for row in manifest['sourceControls'] for key in ('source', 'snapshot')]
    records += [row[key] for row in manifest['datasets'] for key in ('source', 'snapshot')]
    for record in records:
        if pin(ROOT / record['file'])['sha256'] != record['sha256']:
            raise ValueError('frozen input changed: ' + record['file'])
    return manifest, json.loads((HERE / 'cases.json').read_text())['cases']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--variant', choices=['reverse', 'discard', 'duplicate', 'tail', 'last', 'append'], default='reverse')
    parser.add_argument('--split', choices=['all', 'training', 'heldout'], default='all')
    args = parser.parse_args()
    manifest, cases = verify()
    cases = REFERENCE.selected(cases, args.variant)
    if args.split != 'all':
        cases = [case for case in cases if case['split'] == args.split]
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh directory under selfhost/build/phase110 required')
    lines, records = [], []
    for i, case in enumerate(cases):
        string_kind = case['kind'] == 'string'
        for side in ('input', 'acc', 'last_acc'):
            if side == 'last_acc':
                values = [case.get('lastAccumulatorCodepoints', [])]
            else:
                values = [case[side + 'Codepoints']] if string_kind else [list(map(ord, s)) for s in case[side + 'Strings']]
            texts = []
            for j, value in enumerate(values):
                name = f'c{i}_{side}_{j}'
                lines.append(f'static const uint32_t {name}[] = {{{", ".join(map(str, value)) or "0"}}};')
                texts.append(f'{{{name}, {len(value)}}}')
            lines.append(f'static const Text c{i}_{side}[] = {{{", ".join(texts) or "{NULL, 0}"}}};')
        aliases = ['{%d, %d, %d}' % ({'root': 0, 'tail': 1, 'head': 2}[a['from']], a.get('offset', 0), a['kind'] == 'string') for a in case['aliases']]
        lines.append(f'static const Alias c{i}_aliases[] = {{{", ".join(aliases) or "{0, 0, 0}"}}};')
        records.append('{%s, %d, %d, %d, c%d_input, c%d_acc, %d, %d, c%d_aliases, %d, {c%d_last_acc_0, %d}}' % (
            json.dumps(case['name']), string_kind, case['staticInput'], case['inputPatternRepeats'], i, i,
            1 if string_kind else len(case['inputStrings']), 1 if string_kind else len(case['accStrings']), i, len(case['aliases']), i, len(case.get('lastAccumulatorCodepoints', []))))
    lines.append('static const Case CASES[] = {\n  ' + ',\n  '.join(records) + '\n};')
    out.mkdir(parents=True)
    (out / 'cases.inc.c').write_text('\n'.join(lines) + '\n')
    selector = {'tail': 1, 'last': 2, 'append': 3}.get(args.variant, 0)
    (out / 'harness.c').write_text(f'#define P110_SELECTOR {selector}\n' + (HERE / 'harness.c').read_text())
    abi = ROOT / 'selfhost/tools/performance/phase109/runtime/abi.h'
    (out / 'abi.h').write_bytes(abi.read_bytes())
    known = {c['name'] for c in cases}
    expected = [line for line in (HERE / f'{args.variant}.expected.jsonl').read_text().splitlines() if json.loads(line)['name'] in known]
    (out / 'expected.jsonl').write_text('\n'.join(expected) + '\n')
    record = dict(kind='phase110-prepared-controls', version=1, complete=True, targetsRun=False, variant=args.variant, split=args.split, cases=len(cases),
        inputs=[pin(HERE / name) for name in ('prepare.py', 'harness.c', 'manifest.json', 'cases.json', f'{args.variant}.expected.jsonl')] + [pin(abi)],
        outputs=[pin(out / name) for name in ('harness.c', 'abi.h', 'cases.inc.c', 'expected.jsonl')])
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(cases), variant=args.variant, split=args.split, out=str(out))))


if __name__ == '__main__':
    main()
