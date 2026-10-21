"""Serial transport around frozen per-source replay; no compiler logic."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('names',nargs='+');a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase115');out.mkdir()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
manifest=HERE/'manifest03.json';names={x['name'] for x in json.loads(manifest.read_text())['cases']};assert set(a.names)<=names
r=dict(complete=False,inputs=[pin(__file__),pin(HERE/'replay-v3.mjs'),pin(manifest)],jobs=[]);save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
start=time.monotonic();save()
try:
 for name in a.names:
  destination=out/name;command=[ROOT/'selfhost/.bootstrap/bun-1.4.3/bun',HERE/'replay-v3.mjs',name,destination]
  t=time.monotonic()
  with (out/(name+'.stdout')).open('xb') as so,(out/(name+'.stderr')).open('xb') as se:
   child=subprocess.run(list(map(str,command)),cwd=ROOT,stdout=so,stderr=se,timeout=100)
  r['jobs'].append(dict(name=name,command=list(map(str,command)),seconds=time.monotonic()-t,returncode=child.returncode,report=pin(destination/'report.json')));save()
  if child.returncode:raise RuntimeError(name+' replay failed')
  print(name,round(r['jobs'][-1]['seconds'],3),flush=True)
 r['complete']=True
finally:r['totalSeconds']=time.monotonic()-start;save()
