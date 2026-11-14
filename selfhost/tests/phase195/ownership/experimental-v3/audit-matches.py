#!/usr/bin/env python3
"""Static scrutinee inventory only; does not parse, check or execute Bend."""
from pathlib import Path
import json
import re
ROOT = Path(__file__).resolve().parent
rows=[]
for filename in ['layout.bend','proof.bend','evaluator.bend','bst-fixture.bend']:
    lines=(ROOT/filename).read_text().splitlines()
    function=None; params=[];fields=set();locals_seen=set()
    for line_number,line in enumerate(lines,1):
        definition=re.match(r'^def (\w+)\(([^)]*)\)',line)
        if definition:
            function=definition[1]
            params=re.findall(r'(?:^|,)\s*\+?([a-zA-Z_]\w*)\s*(?=:|,|$)',definition[2])
            fields=set();locals_seen=set()
        if not function: continue
        if line.lstrip().startswith('case '):
            pattern=line.split('case ',1)[1].split(':',1)[0]
            fields.update(re.findall(r'\b[a-z_]\w*\b',pattern))
        assignment=re.match(r'^\s+\+?([a-z_]\w*)\s*(?::[^=]+)?=',line)
        if assignment: locals_seen.add(assignment[1])
        match=re.match(r'^\s+match (.*):\s*$',line)
        tuple_match=re.match(r'^\s*\([^=]*\)\s*=\s*(.*)$',line)
        if not match and not tuple_match: continue
        text=(match or tuple_match)[1]
        names=re.findall(r'[a-zA-Z_]\w*',text)
        simple=bool(re.fullmatch(r'[a-zA-Z_]\w*(?:[ ,]+[a-zA-Z_]\w*)*',text))
        source=['parameter' if n in params else 'field' if n in fields else 'computed-or-unknown' for n in names]
        error=not simple or any(n in locals_seen for n in names) or 'computed-or-unknown' in source
        positions=[params.index(n) for n in names if n in params]
        error=error or positions!=sorted(positions)
        rows.append(dict(file=filename,line=line_number,function=function,scrutinee=text,
                         kind='match' if match else 'tuple-pattern',source=source,flagged=error))
report={'kind':'phase195-static-match-audit','compilerExecuted':False,
        'scope':'Lexical inventory plus manual review. Not a parser or source acceptance certificate.',
        'sites':len(rows),'flagged':sum(x['flagged'] for x in rows),'rows':rows}
(ROOT/'match-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='rows'}))
for row in rows:
    if row['flagged']: print(row)
assert not report['flagged']
