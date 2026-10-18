#!/usr/bin/env python3
"""Render frozen test data as C initializers; no Bend algorithms are translated."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
CONTROLS = HERE.parent / 'controls'


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    args = p.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('output must be fresh under selfhost/build/phase109')
    manifest = json.loads((CONTROLS / 'manifest.json').read_text())
    raw = (CONTROLS / 'cases.json').read_bytes()
    if hashlib.sha256(raw).hexdigest() != manifest['ownershipCases']['sha256']:
        raise ValueError('frozen fixture identity differs')
    cases = json.loads(raw)['cases']
    lines, records = [], []
    for i, case in enumerate(cases):
        string_kind = case['kind'] == 'string'
        for side in ('input', 'acc'):
            values = [case[side + 'Codepoints']] if string_kind else [list(map(ord, s)) for s in case[side + 'Strings']]
            texts = []
            for j, value in enumerate(values):
                name = f'c{i}_{side}_{j}'
                lines.append(f'static const uint32_t {name}[] = {{{", ".join(map(str, value)) or "0"}}};')
                texts.append(f'{{{name}, {len(value)}}}')
            lines.append(f'static const Text c{i}_{side}[] = {{{", ".join(texts) or "{NULL, 0}"}}};')
        aliases = []
        for alias in case['aliases']:
            aliases.append('{%d, %d, %d}' % ({'root': 0, 'tail': 1, 'head': 2}[alias['from']], alias.get('offset', 0), alias['kind'] == 'string'))
        lines.append(f'static const Alias c{i}_aliases[] = {{{", ".join(aliases) or "{0, 0, 0}"}}};')
        records.append('{%s, %d, %d, %d, c%d_input, c%d_acc, %d, %d, c%d_aliases, %d}' % (
            json.dumps(case['name']), string_kind, case['staticInput'], case['inputPatternRepeats'], i, i,
            1 if string_kind else len(case['inputStrings']), 1 if string_kind else len(case['accStrings']), i, len(case['aliases'])))
    lines.append('static const Case CASES[] = {\n  ' + ',\n  '.join(records) + '\n};')
    out.mkdir(parents=True)
    (out / 'cases.inc.c').write_text('\n'.join(lines) + '\n')
    for name in ('harness.c', 'abi.h'):
        (out / name).write_bytes((HERE / name).read_bytes())
    record = dict(kind='phase109-frozen-runtime-harness', version=1, complete=True, targetsRun=False,
                  inputs=[pin(Path(__file__).resolve()), pin(CONTROLS / 'cases.json'), pin(CONTROLS / 'manifest.json'), pin(HERE / 'harness.c'), pin(HERE / 'abi.h')],
                  outputs=[pin(out / name) for name in ('harness.c', 'abi.h', 'cases.inc.c')])
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record))


if __name__ == '__main__':
    main()
