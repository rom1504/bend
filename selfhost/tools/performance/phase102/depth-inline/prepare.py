#!/usr/bin/env python3
"""Offline bounded-depth forced-inlining experiment on exact generated C."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OPAQUE = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*'
BRACES = re.compile(OPAQUE + r'|[{}]', re.S)
IGNORED = re.compile(OPAQUE, re.S)
FUNCTION = re.compile(r'^(NF_INLINE|INLINE) Term (NF_FID_\w+)\([^;{}]*\) \{', re.M)
SIGNATURE = re.compile(r'^(NF_INLINE|INLINE) Term (NF_FID_\w+)\([^;{}]*\) ([;{])', re.M)
CALL = re.compile(r'\b(NF_FID_\w+)\s*\(')


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def save(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + '\n')


def transform(source, limit=8192, passes=3):
    assert 0 < limit and 0 < passes <= 16
    workers = {}
    for match in FUNCTION.finditer(source):
        depth = 1
        for token in BRACES.finditer(source, match.end()):
            if token[0] == '{': depth += 1
            elif token[0] == '}': depth -= 1
            if depth == 0: break
        else: raise AssertionError('Unterminated NF definition')
        name = match[2]
        assert name not in workers, ('Duplicate definition', name)
        body = source[match.end():token.start()]
        calls = Counter(CALL.findall(IGNORED.sub(' ', body)))
        workers[name] = dict(name=name, originalHint=match[1], bodyBytes=len(body.encode()),
                             calls=dict(sorted(calls.items())))
    assert workers, 'No generated NF definitions'
    eligible = {name for name, row in workers.items()
                if row['originalHint'] == 'NF_INLINE' and row['bodyBytes'] <= limit}
    selected = set()
    rounds = []
    for level in range(passes):
        previous = selected
        selected = {name for name in eligible if set(workers[name]['calls']) <= previous}
        assert previous <= selected
        rounds.append(dict(level=level, count=len(selected), added=sorted(selected - previous)))
    demoted = {name for name, row in workers.items()
               if row['originalHint'] == 'NF_INLINE' and name not in selected}
    # Rewrite the hint token only, at every declaration/definition of that name.
    declarations = re.compile(r'^(NF_INLINE|INLINE)(?= Term (NF_FID_\w+)\()', re.M)
    edits = []
    seen = Counter()
    for match in declarations.finditer(source):
        name = match[2]
        assert name in workers, ('Declaration without definition', name)
        assert match[1] == workers[name]['originalHint'], ('Inconsistent old hint', name)
        seen[name] += 1
        if name in demoted:
            edits.append(dict(offset=match.start(), old='NF_INLINE', new='INLINE'))
    assert set(seen) == set(workers)
    assert all(count in (1, 2) for count in seen.values()), seen
    pieces = []; cursor = 0
    for edit in edits:
        at = edit['offset']; pieces += [source[cursor:at], edit['new']]
        cursor = at + len(edit['old'])
    pieces.append(source[cursor:]); candidate = ''.join(pieces)
    # Inverse verifies that every byte except the selected hint tokens survives.
    parts = []; cursor = 0; shift = 0
    for edit in edits:
        at = edit['offset'] + shift
        assert candidate[at:at + len(edit['new'])] == edit['new']
        parts += [candidate[cursor:at], edit['old']]
        cursor = at + len(edit['new']); shift += len(edit['new']) - len(edit['old'])
    parts.append(candidate[cursor:]); assert ''.join(parts) == source
    for name, row in workers.items():
        row['selected'] = name in selected
        row['missingCallees'] = sorted(set(row['calls']) - workers.keys())
        row['declarationAndDefinitionCount'] = seen[name]
    return candidate, dict(kind='phase102-actual-c-depth-inline', targetsRun=False,
        limit=limit, passes=passes, maximumForcedCallDepth=passes-1,
        definitions=len(workers), originallyForced=sum(r['originalHint']=='NF_INLINE' for r in workers.values()),
        sizeEligible=len(eligible), selected=len(selected), demoted=len(demoted),
        hintTokensChanged=len(edits), inverseExact=True, rounds=rounds,
        workers=list(workers.values()),
        scope='Only demotes original NF_INLINE tokens. Actual C body bytes and NF call graph; '
              'TRMC private bodies are distinct vertices. This may be stricter than Bend NC_Code '
              'metadata and is not compiler-image qualification.')


def controls():
    def f(name, calls='', hint='NF_INLINE'):
        return f'{hint} Term NF_FID_{name}(Env e);\n{hint} Term NF_FID_{name}(Env e) {{ {calls} return 1; }}\n'
    text = f('a') + f('b', 'NF_FID_a(e);') + f('c', 'NF_FID_b(e);') + f('d', 'NF_FID_c(e);')
    candidate, report = transform(text)
    assert [r['count'] for r in report['rounds']] == [1, 2, 3]
    assert candidate.count('INLINE Term NF_FID_d(') == 2
    assert 'NF_INLINE Term NF_FID_d(' not in candidate
    text += f('cycle1', 'NF_FID_cycle2(e);') + f('cycle2', 'NF_FID_cycle1(e);')
    text += f('missing', 'NF_FID_absent(e);') + f('ordinary', hint='INLINE')
    text += f('calls_ordinary', 'NF_FID_ordinary(e);') + f('large', ' ' * 8193)
    candidate, report = transform(text)
    assert {r['name'] for r in report['workers'] if r['selected']} == {'NF_FID_a','NF_FID_b','NF_FID_c'}
    assert report['inverseExact']
    _, renamed = transform(text.replace('NF_FID_', 'NF_FID_renamed_'))
    assert renamed['selected'] == report['selected']
    return dict(complete=True, targetsRun=False, cases=['three-immutable-passes', 'consistent-prototype-body',
        'cycle-refusal', 'missing-callee-refusal', 'original-INLINE-refusal',
        'oversized-body-refusal', 'arbitrary-names', 'exact-inverse'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path)
    p.add_argument('--catalog', type=Path)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--limit', type=int, default=8192)
    p.add_argument('--passes', type=int, default=3)
    a = p.parse_args(); assert a.source or a.catalog
    out = a.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, targetsRun=False, method=pin(__file__), limit=a.limit, passes=a.passes,
                  controls=controls(), programs=[])
    if a.source:
        original = pin(a.source)
        candidate, graph = transform(a.source.read_text(), a.limit, a.passes)
        dest = out/'compiler.c'; dest.write_text(candidate)
        save(out/'compiler-graph.json', graph)
        report['selfCompiler'] = dict(originalC=original, candidateC=pin(dest), graph=pin(out/'compiler-graph.json'))
    if a.catalog:
        old = json.loads(a.catalog.read_text()); assert old['complete']
        report['parent'] = pin(a.catalog)
        for row in old['programs']:
            assert pin(row['candidateC']['file']) == row['candidateC']
            candidate, graph = transform(Path(row['candidateC']['file']).read_text(), a.limit, a.passes)
            dest = out/(row['id']+'.c'); dest.write_text(candidate)
            graph_path = out/(row['id']+'-graph.json'); save(graph_path, graph)
            report['programs'].append(dict(id=row['id'], baselineC=row['baselineC'], originalC=row['candidateC'],
                candidateC=pin(dest), graph=pin(graph_path), selected=graph['selected'], demoted=graph['demoted']))
        (out/'prepare.py').write_text('''from pathlib import Path
import hashlib,json
def transform(source):
    catalog=json.loads(Path(__file__).with_name('catalog.json').read_text())
    digest=hashlib.sha256(source.encode()).hexdigest()
    rows=[v for v in catalog['programs'] if v['baselineC']['sha256']==digest]
    assert len(rows)==1
    row=rows[0]; data=Path(__file__).with_name(row['id']+'.c').read_bytes()
    assert hashlib.sha256(data).hexdigest()==row['candidateC']['sha256']
    return data.decode(),dict(kind='Generated-C depth2 hint experiment; not an image',
        original=row['originalC'],method=catalog['method'],graph=row['graph'])
''')
    report['complete'] = True
    save(out/'catalog.json', report)
    print(json.dumps(dict(out=str(out), selfCompiler=report.get('selfCompiler'),
        apps={r['id']:dict(selected=r['selected'],demoted=r['demoted']) for r in report['programs']})))


if __name__ == '__main__': main()
