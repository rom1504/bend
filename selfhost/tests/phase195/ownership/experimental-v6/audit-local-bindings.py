#!/usr/bin/env python3
"""Inventory local bindings for constructor inference gaps; no compiler."""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parent
rows=[];flagged=[]
for name in ['layout.bend','proof.bend','evaluator.bend','bst-fixture.bend']:
    lines=(ROOT/name).read_text().splitlines();owner=''
    for number,line in enumerate(lines,1):
        definition=re.match(r'^def (\w+)',line)
        if definition:owner=definition[1]
        m=re.match(r'^\s+\+?([a-z_]\w*)\s*(?::\s*([^=]+?))?\s*=\s*(.*)$',line)
        if not m:continue
        rhs=m[3].strip()
        constructor=bool(re.match(r'^(?:[A-Z][\w.]*\{|\[)',rhs))
        row=dict(file=name,line=number,owner=owner,binder=m[1],annotation=m[2],constructorLiteral=constructor,
            rhsStart=rhs[:100],flagged=constructor and not bool(m[2]))
        rows.append(row)
        if row['flagged']:flagged.append(row)
report=dict(kind='phase195-static-local-binding-audit',compilerExecuted=False,bindings=len(rows),
    constructorBindings=sum(r['constructorLiteral'] for r in rows),flagged=flagged,rows=rows,
    scope='Lexical inventory of named local assignments, including all Con/Nil/list and other constructor literals; not type checking.')
(ROOT/'local-bindings-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='rows'}));assert not flagged
