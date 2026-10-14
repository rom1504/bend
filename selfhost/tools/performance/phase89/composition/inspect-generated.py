#!/usr/bin/env python3
"""Static generated-C site accounting, not dynamic work or performance counts."""
import collections,hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==4,'Usage: inspect-generated.py OLD_C NEW_C NEW_REPORT.json'
old,new,out=map(Path,sys.argv[1:]);families=['NC_MATCH_APPLY_ORIGINAL_TO','NC_MATCH_APPLY_SLOW_TO']
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def analyze(p):
    s=p.read_text();marks=list(re.finditer(r'(?m)^  WL_CASE\((FID_[A-Z0-9_]+)\)',s));rows=[]
    for i,m in enumerate(marks):
        family=next((f for f in families if m[1].startswith('FID_'+f)),None)
        if family is None:continue
        end=marks[i+1].start() if i+1<len(marks) else len(s);body=s[m.start():end]
        counts={k:len(re.findall(r'\b'+k+r'\(',body)) for k in ['term_keep','term_sink','spin_24','spin_25','spin_26','spin_29']}
        counts.update(appendJumps=body.count('WL_JMP(FID_STRING_APPEND)'),firstErrorJumps=body.count('WL_JMP(FID_NC_FIRST_ERROR)'))
        rows.append(dict(name=m[1],family=family,line=s.count('\n',0,m.start())+1,endLine=s.count('\n',0,end)+1,
                         sha256=hashlib.sha256(body.encode()).hexdigest(),bytes=len(body.encode()),counts=counts,
                         popSlots=[int(x) for x in re.findall(r'WL_POPN\((\d+)\)',body)],
                         relevantLines=[dict(line=s.count('\n',0,m.start())+j+1,text=line.strip()) for j,line in enumerate(body.splitlines())
                                        if re.search(r'\b(term_keep|term_sink|spin_2[4569])\(',line)]))
    aggregates={}
    for family in families:
        selected=[r for r in rows if r['family']==family];counts=collections.Counter()
        for row in selected:counts.update(row['counts'])
        aggregates[family]=dict(cases=len(selected),counts=dict(counts))
    projections={}
    for name in ['spin_24','spin_25','spin_26','spin_29']:
        m=re.search(r'(?m)^INLINE Term '+name+r'\([^\n]*\) \{',s);assert m,name
        end=re.search(r'(?m)^}',s[m.end():]);assert end
        body=s[m.start():m.end()+end.end()]
        projections[name]=dict(line=s.count('\n',0,m.start())+1,sha256=hashlib.sha256(body.encode()).hexdigest(),source=body)
    return dict(input=pin(p),families=aggregates,cases=rows,projectionDefinitions=projections)
report=dict(kind='phase89-generated-match-static-ownership',complete=True,old=analyze(old),new=analyze(new),method=pin(Path(__file__)),
            scope='Counts are textual operation sites across named continuation families, not execution counts. '
                  'Projection names are bound to the included exact definitions; no cross-build numbering assumption. '
                  'These are component-image C files, not proof of identical inlining in the full compiler.')
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps({r:report[r]['families'] for r in ['old','new']},indent=2))
