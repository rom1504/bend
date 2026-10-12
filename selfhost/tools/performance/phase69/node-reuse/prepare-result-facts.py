#!/usr/bin/env python3
"""Prepare checked typed10 lexer result/packed-fact saved-C probes; no targets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
REPORT = ROOT / 'selfhost/build/phase69/typed10-native/report.json'
PREFIX = '../phase37/fixtures-historical/lexer:'


def pin(p):
    p = Path(p).resolve()
    return dict(path=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)


def verify(p):
    assert pin(p['path']) == p, p


def sym(name):
    return 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in name)


def scalar_results(original):
    # These declarations are pinned in lexer.bend. The private worker's C
    # return itself is a success bit; the semantic result is in nq_result[].
    one = ['prng', 'seed', 'salt', 'op.pick', 'mix', 'fnv', 'flush', 'lex', 'line',
           'batch', 'expect.small', 'expect.big']
    slots = {sym(PREFIX + n): [0] for n in one}
    slots.update({sym('$product.' + PREFIX + n): [1] for n in ['step', 'step.at']})
    edits = []
    pattern = r'^if \(!(?P<symbol>NF_FID_[0-9_]+)\(e, seq, (?P<out>nq_result_[0-9]+),[^\n]*\)\) \{ return 0; \}\n'
    for m in re.finditer(pattern, original, re.M):
        if m['symbol'] not in slots:
            continue
        before = m.group(0)
        after = before + ''.join(f"{m['out']}[{i}] = (u32){m['out']}[{i}];\n" for i in slots[m['symbol']])
        edits.append(dict(offsetInParent=m.start(), before=before, after=after,
                          resultSlots=slots[m['symbol']], resultType='trusted 32-bit scalar'))
    assert edits
    return apply(original, edits)


def packed_inputs(original):
    # Exactly this checked source's Mode and Cls: Mode has Gap{} and two U32
    # payload constructors, Cls has four nullary constructors. Keep full tags.
    params = {sym(PREFIX+n): ['v_4294967295'] for n in ['step.at', 'step', 'flush']}
    params.update({sym('$product.'+PREFIX+n): ['v_4294967295'] for n in ['step.at', 'step']})
    for p in ['', '$product.']:
        params[sym(p+PREFIX+'step.at')].append('v_4294967294')
    pattern = r'^(?:INLINE|NF_INLINE) Term (?P<symbol>NF_FID_[0-9_]+)\([^\n]*\) \{\n'
    edits = []
    for m in re.finditer(pattern, original, re.M):
        if m['symbol'] not in params:
            continue
        before = m.group(0)
        facts = ''.join(f'if (term_tag({p}) != TAG_PAK || term_rfc({p})) {{ __builtin_unreachable(); }}\n' for p in params[m['symbol']])
        after = before + '#if NATIVE_TYPED_SCALARS && NATIVE_PACK_CTORS\n' + facts + '#endif\n'
        edits.append(dict(offsetInParent=m.start(), before=before, after=after,
                          fullTermPreserved=True, parameterNames=params[m['symbol']]))
    assert len(edits) == 5, len(edits)
    return apply(original, edits)


def apply(original, edits):
    text = original
    edits = sorted(edits, key=lambda e: e['offsetInParent'], reverse=True)
    for e in edits:
        at = e['offsetInParent']
        assert text[at:at+len(e['before'])] == e['before']
        e['lineInParent'] = original.count('\n', 0, at) + 1
        text = text[:at] + e['after'] + text[at+len(e['before']):]
    reverse = text
    for e in reversed(edits):
        at = e['offsetInParent']
        assert reverse[at:at+len(e['after'])] == e['after']
        reverse = reverse[:at] + e['before'] + reverse[at+len(e['after']):]
    assert reverse == original
    return text, edits


def main():
    assert os.sched_getaffinity(0) == {0}
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', required=True, type=Path)
    args = ap.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase69')
    out.mkdir(parents=True, exist_ok=False)
    report = json.loads(REPORT.read_text())
    assert report['complete']
    row = next(r for r in report['records'] if r['case'] == 'lexer' and r['role'] == 'selfhost')
    assert row['correct'] and row['emission']['complete'] and row['emission']['returncode'] == 0
    for p in [row['nativeSource'], row['source'], row['emissionReceipt'], report['recipe']]:
        verify(p)
    original = Path(row['nativeSource']['path']).read_text()
    assert '#define NATIVE_TYPED_SCALARS 1\n' in original
    assert '#define NATIVE_PACK_CTORS 1\n' in original
    jobs = []
    for arm, derive in [('typed10', lambda s: (s, [])), ('scalar_results', scalar_results), ('packed_inputs', packed_inputs)]:
        text, edits = derive(original)
        path = out / (arm + '.c')
        path.write_text(text)
        jobs.append(dict(arm=arm, source=pin(path), parent=row['nativeSource'], edits=edits,
                         reverseRecoversParent=True, kernel='lexer', targetsExecuted=False))
    result = dict(kind='phase69-native-result-facts-plan-v1', targetsExecuted=False,
                  producer=pin(__file__), hypothesis=pin(ROOT / 'experiments/phase69/P69-010-native-result-layout-facts.md'),
                  acquisition=pin(REPORT), recipe=report['recipe'], emissionReceipt=row['emissionReceipt'],
                  baseline=row['nativeSource'], source=row['source'],
                  typedFixture=pin(ROOT / 'selfhost/tools/performance/phase37/fixtures-historical/lexer.bend'), jobs=jobs,
                  scope='Explicit typed10 baseline; independent scalar result narrowing and canonical packed Mode/Cls input facts. No runtime, scheduler, body control-flow, ABI or compiler edits.')
    (out / 'plan.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(plan=pin(out / 'plan.json'), edits={r['arm']:len(r['edits']) for r in jobs}, targetsExecuted=False)))


if __name__ == '__main__':
    main()
