#!/usr/bin/env python3
"""Compare private-worker C shapes; counts are source sites, not profiles."""
import hashlib, json, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase72'
def read(p): return json.loads((ROOT/p).read_text())
def inventory(paths):
 out={}
 for p in paths:
  r=read(p);assert r['complete']
  for x in r['records']:
   if x['role']=='selfhost':out[x['case']]=x['nativeSource']
 return out
def bodies(s):
 out={};tokens=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/|[{}]')
 for m in re.finditer(r'(?:NF_INLINE|INLINE) Term (NF_FID_[0-9_]+)\([^\n;]*\) \{',s):
  depth=1
  for t in tokens.finditer(s,m.end()):
   if t[0]=='{':depth+=1
   elif t[0]=='}':depth-=1
   if not depth:break
  assert depth==0
  name=''.join(chr(int(i)) for i in m[1][7:].split('_') if i)
  out[name]=s[m.start():t.end()]
 return out
old=inventory(['selfhost/build/phase70/'+p+'/report.json' for p in ['compiler02-native06','compiler02-coverage-missing-five01','compiler02-array-map']])
new=inventory(['selfhost/build/phase72/'+p+'/report.json' for p in ['compiler02-native06','compiler02-coverage02','compiler02-coverage-rest']])
rows=[]
for case in sorted(new):
 a,b=(Path(d[case]['path']).read_text() for d in [old,new]);aa,bb=bodies(a),bodies(b)
 changes=[]
 for n in sorted(aa.keys()|bb.keys()):
  if aa.get(n)==bb.get(n):continue
  changes.append(dict(name=n,old={k:aa.get(n,'').count(v) for k,v in [('allocations','heap_alloc('),('seals','rfc_seal(')]},new={k:bb.get(n,'').count(v) for k,v in [('allocations','heap_alloc('),('seals','rfc_seal(')]},added=n not in aa,removed=n not in bb))
 rows.append(dict(case=case,old=old[case],new=new[case],identical=a==b,byteChange=len(b.encode())-len(a.encode()),changedWorkers=changes))
out=RAW/'shapes.json';assert not out.exists();out.write_text(json.dumps(dict(producerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Static private-worker source-site counts; no dynamic allocation-frequency claim.',rows=rows),indent=2)+'\n')
print(json.dumps([dict(case=r['case'],identical=r['identical'],byteChange=r['byteChange'],changedWorkers=len(r['changedWorkers'])) for r in rows]))
