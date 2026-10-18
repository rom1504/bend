#!/usr/bin/env python3
"""Alternate existing qualified promotion/strength binaries; no recompilation."""
import hashlib,json,random,statistics,struct,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];B=ROOT/'selfhost/build/phase107';out=B/'strength-pair01';out.mkdir(exist_ok=False)
def pin(p):
 d=p.read_bytes();return dict(file=str(p),bytes=len(d),sha256=hashlib.sha256(d).hexdigest())
def codehash(p):
 d=p.read_bytes();assert d[:6]==b'\x7fELF\x02\x01';off=struct.unpack_from('<Q',d,40)[0];size,count,strings=struct.unpack_from('<HHH',d,58)
 sh=lambda i:struct.unpack_from('<IIQQQQIIQQ',d,off+i*size)
 table=sh(strings);names=d[table[4]:table[4]+table[5]]
 for i in range(count):
  s=sh(i)
  if names[s[0]:].split(b'\0',1)[0]==b'.text':return hashlib.sha256(d[s[4]:s[4]+s[5]]).hexdigest()
 raise ValueError('no text')
reports=[json.loads((B/n/'report.json').read_text())for n in ['measure07','measure08']];assert all(r['complete']for r in reports)
(out/'method.py').write_bytes(Path(__file__).read_bytes());r=dict(complete=False,scope='Five alternating rounds of existing binaries; same arguments/repeat/complete expected result. Code-identical text is labelled, not credited as an optimization gain.',inputs=[pin(Path(__file__)),*[pin(B/n/'report.json')for n in ['measure07','measure08']]],pairs=[],jobs=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
pairs=[]
for name in sorted({x['name']for x in reports[0]['runtimes']}):
 for target in ['c','cl','qbe']:
  rows=[next(x for x in z['runtimes']if x['name']==name and x['budget']==4096 and x['backend']==target)for z in reports]
  assert all((x['args'],x['repeat'],x['expected'])==(rows[0]['args'],rows[0]['repeat'],rows[0]['expected'])for x in rows)
  binaries=[B/n/(name+'-4096-'+target)for n in ['measure07','measure08']]
  p=dict(name=name,target=target,args=rows[0]['args'],repeat=rows[0]['repeat'],expected=rows[0]['expected'],binaries=[pin(x)for x in binaries],textHashes=[codehash(x)for x in binaries]);p['sameText']=len(set(p['textHashes']))==1;pairs.append(p)
random.Random(10710).shuffle(pairs);r['pairs']=pairs;save()
try:
 for round in range(5):
  for i,p in enumerate(pairs):
   for role in ([0,1]if (i+round)%2==0 else [1,0]):
    cmd=[p['binaries'][role]['file'],'--expect',str(p['expected']),'--repeat',str(p['repeat']),*map(str,p['args'])];start=time.perf_counter();v=subprocess.run(cmd,capture_output=True,text=True,timeout=30);elapsed=time.perf_counter()-start
    assert v.returncode==0 and v.stdout==str(p['expected']*p['repeat']&0xffffffff)+'\n' and v.stderr=='',(cmd,v)
    r['jobs'].append(dict(name=p['name'],target=p['target'],round=round,role=['promotion','strength'][role],seconds=elapsed,command=cmd,stdout=v.stdout));save()
  pairs.reverse()
 r['summary']=[]
 for p in pairs:
  samples={role:[x['seconds']for x in r['jobs']if (x['name'],x['target'],x['role'])==(p['name'],p['target'],role)]for role in ['promotion','strength']};med={k:statistics.median(v)for k,v in samples.items()}
  r['summary'].append(dict(name=p['name'],target=p['target'],sameText=p['sameText'],samples=samples,medians=med,strengthOverPromotion=med['strength']/med['promotion']))
 for p in pairs:
  for old in p['binaries']:assert pin(Path(old['file']))==old
 r['complete']=True
finally:save()
print(json.dumps(dict(complete=True,pairs=len(pairs),observations=len(r['jobs']))))
