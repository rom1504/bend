"""Merge fixed identical native request workloads; execute nothing."""
import argparse,hashlib,json,pathlib
p=argparse.ArgumentParser();p.add_argument('--manifest',action='append',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists()
def pin(p):
 b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads(a.manifest[0].read_text());m['inputs'] += [pin(pathlib.Path(__file__))]
for path in a.manifest:
 b=json.loads(path.read_text());assert b['cwd']==m['cwd'] and [w['name']for w in b['workloads']]==[w['name']for w in m['workloads']];m['inputs'] += [pin(path),*b['inputs']]
 for w,v in zip(m['workloads'],b['workloads']):
  for x in v['variants']:
   old=next((o for o in w['variants'] if o['name']==x['name']),None)
   if old:assert old==x
   else:assert x['command'][1:]==w['variants'][0]['command'][1:] and x['expected']==w['variants'][0]['expected'];w['variants'].append(x)
a.out.write_text(json.dumps(m,indent=2)+'\n')
