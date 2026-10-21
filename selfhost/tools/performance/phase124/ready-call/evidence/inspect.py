#!/usr/bin/env python3
"""Read-only extraction of retained QBE text; never invokes compiler or target."""
from pathlib import Path
from collections import Counter
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[6]
OUT=Path(__file__).resolve().parent

def decode(symbol):
 m=re.fullmatch(r'(.*)FID_((?:[0-9]+_)+)',symbol)
 return m[1]+''.join(chr(int(x)) for x in m[2].split('_') if x) if m else symbol

def capture(path):
 text=path.read_text()
 functions={}
 for m in re.finditer(r'^(?:export )?function [wl] \$([^\s(]+)\([^\n]*\) \{\n.*?^\}',text,re.M|re.S):
  functions[m[1]]={'symbol':m[1],'decoded':decode(m[1]),'line':text.count('\n',0,m.start())+1,'body':m[0]+'\n'}
 table=re.search(r'^data \$p111_segments = align 8 \{ (.*?) \}$',text,re.M)[1]
 ids=re.findall(r'\$(\S+?)(?=,|$)',table)
 return text,functions,ids

def info(row):
 calls=re.findall(r'\bcall \$([^\s(]+)',row['body'])
 return {'symbol':row['symbol'],'decoded':row['decoded'],'source_line':row['line'],
         'call_sites':dict(Counter(decode(x) for x in calls)),
         'line_count':len(row['body'].splitlines()),
         'descend_jumps':row['body'].count('jmp @p114r_descend'),
         'unwind_jumps':row['body'].count('jmp @p114r_unwind'),
         'owner_native_reentry':sum(x==row['symbol'] for x in calls)}

reports=[]
for case,owner in [('p124-list-resume01','$direct.parcel.collect'),('p124-tree-resume01','$direct.archive.collect')]:
 paths={role:ROOT/f'selfhost/build/phase118/p124-{role}-controls-emit01/{case}.ssa' for role in ['parent','ready']}
 data={role:capture(p) for role,p in paths.items()}
 ct,cf,ci=data['ready']
 worker=next(row for row in cf.values() if row['decoded']=='p114r_'+owner)
 cids=[int(x) for x in re.findall(r'%p114h_test_\d+ =w ceql %p114h_fid, (\d+)',worker['body'])]
 continuation_symbols=[ci[x] for x in cids]
 sections=[]
 item={'case':case,'owner':owner,'inputs':{},'continuations':[{'fid':n,'symbol':ci[n],'decoded':decode(ci[n])} for n in cids],'roles':{}}
 for role,path in paths.items():
  text,funcs,ids=data[role]
  item['inputs'][role]={'file':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size}
  public=next(row for row in funcs.values() if row['decoded']=='p111_'+owner)
  chosen=[public]+([worker] if role=='ready' else [funcs[x] for x in continuation_symbols])
  item['roles'][role]=[info(row) for row in chosen]
  for row in chosen:
   sections.append(f"# {role}: {row['decoded']}\n# {path.relative_to(ROOT)}:{row['line']}\n{row['body']}")
 # Inspect the transitive private callees, not merely names on the first call.
 seen=set(); todo=[worker['symbol']]; closure=[]
 while todo:
  sym=todo.pop()
  if sym in seen: continue
  seen.add(sym)
  if sym not in cf: continue
  row=cf[sym]; closure.append(info(row))
  todo.extend(x for x in re.findall(r'\bcall \$([^\s(]+)',row['body']) if x in cf)
 item['candidate_direct_call_closure']=closure
 item['candidate_closure_owner_reentry']=any(row['decoded']!='p114r_'+owner and ('p114r_'+owner in row['call_sites'] or 'p111_'+owner in row['call_sites']) for row in closure)
 (OUT/f'{case}.ssa').write_text('\n'.join(sections))
 reports.append(item)
(OUT/'report.json').write_text(json.dumps({'kind':'phase124-static-qbe-owner-comparison','dynamic_counts':False,'program_execution':False,'cases':reports},indent=2)+'\n')
for item in reports:
 print(item['case'],json.dumps(item['roles']['ready'][-1],separators=(',',':')))
