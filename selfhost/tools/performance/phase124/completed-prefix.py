"""Recover only closed verified cases from a deadline-limited immutable emission.

This does not mark the original batch successful. All input and completed output
hashes are rechecked; unfinished cases are explicitly excluded and named.
"""
import argparse, hashlib, json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--guard',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
def pin(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(x):assert pin(x['file'])==x,x['file']
r=json.loads(a.emission.read_text());g=json.loads(a.guard.read_text())
assert not r['complete'] and not r.get('error') and g.get('stoppedFor')=='deadline'
assert str(a.emission.resolve().parent) in g['command'] or str(a.emission.parent) in g['command']
assert not a.out.exists()
for x in r['inputs']:verify(x)
closed=[];excluded=[]
for x in r['cases']:
 if x.get('verified') and x.get('parentVerified') and 'qbe' in x and all(k in x['stages'] for k in ['frontend','admission','independentParent','integrated']):
  verify(x['qbe']);verify(x['source']);closed.append(x)
 else:excluded.append(x['name'])
assert closed
r.update(complete=True,cases=closed,partialBatch=True,excluded=excluded,recovery='Only completed verified cases of a deadline-limited batch; original batch remains incomplete. Rehashed every input and retained output.')
r['inputs'] += [pin(__file__),pin(a.emission),pin(a.guard)]
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(retained=[x['name'] for x in closed],excluded=excluded)))
