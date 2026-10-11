#!/usr/bin/env python3
"""Prepare, but never compile/run, exact pinned lexer static-literal ablations.

This is a fixture-specific saved-C diagnostic, not a production transformation.
The small recognizer rejects statements outside the observed constant graph.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT / 'selfhost/build/phase68/native-facts23-lexer/lexer-selfhost/program.c'
FIXTURE = ROOT / 'selfhost/tools/performance/phase37/fixtures-historical/lexer.bend'
SOURCE_SHA = '5a6a19f98a4ed6f4135333f0f9cce814a3626677b0242f99d17b489ec5bf3cd1'
NAME = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in '../phase37/fixtures-historical/lexer:tpl')


def identity(path):
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def only(pattern, text):
    matches = list(re.finditer(pattern, text, re.M))
    assert len(matches) == 1, (pattern, len(matches))
    return matches[0]


def constant_graph(body):
    """Interpret only explicit constants, aliases and this literal's SCon DAG."""
    values, cells, returns = {}, {}, []
    lines = body.splitlines()
    labels = {s.strip()[:-2]: i for i, s in enumerate(lines) if re.fullmatch(r'nf_join_\d+:;', s.strip())}
    for i, raw in enumerate(lines):
        line = raw.strip()
        if not line or line in ('{', '}', 'u32 nf_poll = 0;', 'nf_again:;', 'return 1;', 'return 0;',
                'if (err_spun(e.mem, &nf_poll)) { return 0; }',
                'if (!seq && err_seen(e.mem)) { return 0; }'):
            continue
        if re.fullmatch(r'Term v_\d+;|nf_join_\d+:;', line):
            continue
        m = re.fullmatch(r'goto (nf_join_\d+);', line)
        if m:
            # Every join skips only lexical closing braces in this expression.
            target = labels[m[1]]
            assert target > i and all(s.strip() == '}' for s in lines[i + 1:target])
            continue
        m = re.fullmatch(r'u64 (nd_\d+) = heap_alloc\(e, cls_fit\(2\)\);', line)
        if m:
            assert m[1] not in cells
            cells[m[1]] = {}
            continue
        m = re.fullmatch(r'e.mem\[(nd_\d+) \+ ([01])\] = rfc_seal\(e, (v_\d+)\);', line)
        if m:
            assert int(m[2]) not in cells[m[1]]
            cells[m[1]][int(m[2])] = values[m[3]]
            continue
        m = re.fullmatch(r'(v_\d+|nf_out\[0\]) = (.*);', line)
        assert m, ('unrecognized statement', line)
        lhs, expr = m.groups()
        if re.fullmatch(r'\d+ull', expr):
            val = int(expr[:-3])
        elif expr == 'term_pak(CID_SNIL, 0)':
            val = ()
        elif expr in values:
            val = values[expr]
        else:
            ctor = re.fullmatch(r'term_ctr\(CID_SCON, (nd_\d+)\)', expr)
            assert ctor and set(cells[ctor[1]]) == {0, 1}, expr
            char, tail = cells[ctor[1]][0], cells[ctor[1]][1]
            assert isinstance(char, int) and isinstance(tail, tuple)
            val = (char,) + tail
        assert lhs not in values, lhs
        values[lhs] = val
        if lhs == 'nf_out[0]':
            returns.append(val)
    assert len(returns) == 1 and len(cells) == len(returns[0]) == 39
    return returns[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    out = args.output.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase68')
    assert identity(SOURCE)['sha256'] == SOURCE_SHA
    source = SOURCE.read_text()
    signature = only(r'^(?:INLINE|NF_INLINE) Term ' + re.escape(NAME) + r'\(Env e, bool seq, Term\* nf_out\) \{', source)
    start, depth, end = signature.end(), 1, None
    for at in range(start, len(source)):
        depth += (source[at] == '{') - (source[at] == '}')
        if depth == 0:
            end = at
            break
    assert end is not None
    body = source[start:end]
    points = constant_graph(body)
    fixture_literal = only(r'^def tpl\(\) -> String:\n  ("[^"\n]*")$', FIXTURE.read_text())
    literal = json.loads(fixture_literal[1])
    assert tuple(map(ord, literal)) == points
    assert only(r'^#define CID_SCON (\d+)$', source)[1] == '25'
    assert only(r'^#define CID_SNIL (\d+)$', source)[1] == '24'
    assert '#define term_ctr(cid, loc) term_make(TAG_CTR, cid, loc)' in source
    assert '#define term_pak(cid, loc) term_make(TAG_PAK, cid, loc)' in source
    assert '#define HEAP_OFF (STAT_OFF + PAGE_UP(STAT_LEN))' in source
    stat_len = only(r'^#define STAT_LEN 0$', source)
    stat_img = only(r'^CONSTV u64 STAT_IMG\[\] = \{ 0 \};$', source)
    bangs = only(r'^#define BANGS 16$', source)
    words = []
    for i, char in enumerate(reversed(points)):
        words += [f'{char}ull', 'term_pak(CID_SNIL, 0)' if i == 0 else f'term_ctr(CID_SCON, STAT_OFF + {2 * (i - 1)})']
    assert len(words) == 78
    replacement = '\nu32 nf_poll = 0;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\nif (!seq && err_seen(e.mem)) { return 0; }\nnf_out[0] = term_ctr(CID_SCON, STAT_OFF + 76);\nreturn 1;\n'
    patches = [
        dict(name='STAT_LEN', start=stat_len.start(), end=stat_len.end(), old=stat_len[0], new='#define STAT_LEN 78'),
        dict(name='STAT_IMG', start=stat_img.start(), end=stat_img.end(), old=stat_img[0], new='CONSTV u64 STAT_IMG[] = {\n  ' + ',\n  '.join(', '.join(words[i:i+2]) for i in range(0, 78, 2)) + '\n};'),
        dict(name='NF_tpl_body', start=start, end=end, old=body, new=replacement)]
    out.mkdir(parents=True, exist_ok=False)
    original = out / 'original-tpl-function.c.txt'
    original.write_text(source[signature.start():end+1] + '\n')
    report = dict(schema='phase68-c23-static-template-derivation-v1', preparedOnly=True,
        scope='Fixture-specific saved-C causality ablation; no compilation, execution, or production change.',
        inputs=[identity(SOURCE), identity(FIXTURE), identity(Path(__file__))],
        originalFunction=identity(original), functionName=NAME, literal=literal,
        codepoints=list(points), staticWords=len(words), staticRootOffset=76,
        validation='Recognized each original statement; evaluated constant graph and checked against Bend literal; reversed each exact patch to recover original bytes; unrelated text unchanged.',
        derivatives=[])
    for label, mode_zero in [('static-only', False), ('static-and-bangs-zero', True)]:
        edits = patches + ([dict(name='BANGS', start=bangs.start(), end=bangs.end(), old=bangs[0], new='#define BANGS 0')] if mode_zero else [])
        edits = sorted(edits, key=lambda e: e['start'])
        result, pos, applied = '', 0, []
        for edit in edits:
            assert source[edit['start']:edit['end']] == edit['old'] and pos <= edit['start']
            result += source[pos:edit['start']]
            applied.append(dict(**edit, derivedStart=len(result), derivedEnd=len(result)+len(edit['new'])))
            result += edit['new']
            pos = edit['end']
        result += source[pos:]
        restored = result
        for edit in reversed(applied):
            assert restored[edit['derivedStart']:edit['derivedEnd']] == edit['new']
            restored = restored[:edit['derivedStart']] + edit['old'] + restored[edit['derivedEnd']:]
        assert restored == source
        dest = out / (label + '.c')
        dest.write_text(result)
        report['derivatives'].append(dict(label=label, source=identity(dest), patches=applied))
    (out / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(output=str(out), derivatives=[dict(label=x['label'], source=x['source']) for x in report['derivatives']]), indent=2))


if __name__ == '__main__':
    main()
