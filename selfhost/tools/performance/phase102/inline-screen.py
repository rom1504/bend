#!/usr/bin/env python3
"""Prepare a size-bounded generated-C inlining intervention, not a compiler image."""
import argparse
import json
import re
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R

TOKENS = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*|[{}]', re.S)
FUNCTION = re.compile(r'^INLINE Term (NF_FID_\w+)\([^;{}]*\) \{', re.M)


def transform(source, limit):
    selected = []
    for m in FUNCTION.finditer(source):
        depth = 1
        for token in TOKENS.finditer(source, m.end()):
            if token[0] == '{': depth += 1
            elif token[0] == '}': depth -= 1
            if depth == 0:
                length = token.end() - m.end()
                if length <= limit:
                    selected.append(dict(name=m[1], bodyBytes=length))
                break
        else: raise AssertionError('Unterminated NF body')
    for row in selected:
        old = 'INLINE Term '+row['name']+'('
        assert source.count(old) == 2, row
        source = source.replace(old, 'NF_INLINE Term '+row['name']+'(')
    return source, selected


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--catalog', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--limit', type=int, default=8192)
    a = p.parse_args(); assert 4096 < a.limit <= 16384
    old = R.read(a.catalog); assert old['complete']
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=True, method=R.pin(__file__), parent=R.pin(a.catalog), limit=a.limit, programs=[])
    for row in old['programs']:
        R.verify(row['candidateC']); text = Path(row['candidateC']['file']).read_text()
        result, selected = transform(text, a.limit)
        dest = out/(row['id']+'.c'); dest.write_text(result)
        report['programs'].append(dict(id=row['id'], baselineC=row['baselineC'], originalC=row['candidateC'],
            candidateC=R.pin(dest), forcedInline=selected))
    R.save(out/'catalog.json', report)
    (out/'prepare.py').write_text('''from pathlib import Path
import hashlib,json
def transform(source):
    catalog=json.loads(Path(__file__).with_name('catalog.json').read_text())
    digest=hashlib.sha256(source.encode()).hexdigest()
    rows=[v for v in catalog['programs'] if v['baselineC']['sha256']==digest]
    assert len(rows)==1
    row=rows[0]; data=Path(__file__).with_name(row['id']+'.c').read_bytes()
    assert hashlib.sha256(data).hexdigest()==row['candidateC']['sha256']
    return data.decode(),dict(kind='Saved-C bounded inlining intervention; not Bend emitter integration',
        original=row['originalC'],method=catalog['method'],limit=catalog['limit'],selected=row['forcedInline'])
''')
    print(json.dumps({r['id']:len(r['forcedInline']) for r in report['programs']}))


if __name__ == '__main__': main()
