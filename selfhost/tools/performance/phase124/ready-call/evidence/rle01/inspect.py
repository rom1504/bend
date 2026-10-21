#!/usr/bin/env python3
"""Static retained-QBE extraction only. Does not import/run another method."""
from pathlib import Path
from collections import Counter
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[7]
OUT=Path(__file__).resolve().parent
paths={'parent':ROOT/'selfhost/build/phase118/p123-broad-emit04/test-rle-roundtrip.ssa','ready':ROOT/'selfhost/build/phase118/p124-ready-fast-emit01/test-rle-roundtrip.ssa'}
def decode(x):
 m=re.fullmatch(r'(.*)FID_((?:[0-9]+_)+)',x)
 return m[1]+''.join(chr(int(n)) for n in m[2].split('_') if n) if m else x
def pin(p):
 return {'file':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def read(p):
 t=p.read_text(); fs={}
 for m in re.finditer(r'^(?:export )?function [wl] \$([^\s(]+)\([^\n]*\) \{\n.*?^\}',t,re.M|re.S):
  fs[m[1]]={'symbol':m[1],'decoded':decode(m[1]),'line':t.count('\n',0,m.start())+1,'body':m[0]+'\n'}
 tab=re.search(r'^data \$p111_segments = align 8 \{ (.*?) \}$',t,re.M)[1]
 return fs,re.findall(r'\$(\S+?)(?=,|$)',tab)
def summary(row,ids):
 return {'symbol':row['symbol'],'decoded':row['decoded'],'line':row['line'],'calls':dict(Counter(decode(x) for x in re.findall(r'\bcall \$([^\s(]+)',row['body']))),'runtime_jump_edges':[{'fid':int(n),'target':decode(ids[int(n)])} for n in re.findall(r'call \$p111_rt_jump\(l %state, w (\d+),',row['body'])]}
data={k:read(p) for k,p in paths.items()}
cf,ci=data['ready']; worker=next(x for x in cf.values() if x['decoded']=='p114r_$direct.expand')
fids=[int(n) for n in re.findall(r'%p114h_test_\d+ =w ceql %p114h_fid, (\d+)',worker['body'])]
cont=[ci[n] for n in fids]
report={'kind':'phase124-static-rle-owner-and-absorbed-continuations','execution':False,'dynamic_counts':False,'inputs':{k:pin(p) for k,p in paths.items()},'continuations':[{'fid':n,'symbol':ci[n],'decoded':decode(ci[n])} for n in fids],'roles':{}}
for role,(fs,ids) in data.items():
 selected=[x for x in fs.values() if x['decoded'] in ['p111_$direct.expand','p111_$direct.lrepeat','p111_$direct.lconcat']]
 if role=='parent': selected += [fs[x] for x in cont]
 else: selected += [worker]
 report['roles'][role]=[summary(x,ids) for x in selected]
 (OUT/(role+'.ssa')).write_text('\n'.join(f"# {x['decoded']}\n# {paths[role].relative_to(ROOT)}:{x['line']}\n{x['body']}" for x in selected))
seen=set(); todo=[worker['symbol']]; closure=[]
while todo:
 sym=todo.pop()
 if sym in seen or sym not in cf: continue
 seen.add(sym); row=cf[sym]; closure.append(row)
 todo += re.findall(r'\bcall \$([^\s(]+)',row['body'])
report['private_closure']=[summary(x,ci) for x in closure]
(OUT/'private-helpers.ssa').write_text('\n'.join(f"# {x['decoded']}\n# {paths['ready'].relative_to(ROOT)}:{x['line']}\n{x['body']}" for x in closure if x['symbol']!=worker['symbol']))
more=[ROOT/'selfhost/tools/performance/programs/fixtures/test-rle-roundtrip.bend',ROOT/'selfhost/build/phase118/runtime-extend01/runtime.c',ROOT/'selfhost/build/phase118/runtime-extend01/primitives.h',ROOT/'selfhost/tools/performance/phase118/runtime-extend-sized.c',ROOT/'selfhost/build/phase124/fast-machine01/report.json']
report['supporting_inputs']=[pin(p) for p in more]
machine=json.loads(more[-1].read_text()); report['root_machine_rows']=[x for x in machine['rows'] if x['name']=='test-rle-roundtrip']
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
for role,rows in report['roles'].items():
 print(role,[(x['decoded'],x['calls'],x['runtime_jump_edges']) for x in rows])
print('closure',[(x['decoded'],x['calls']) for x in report['private_closure']])
