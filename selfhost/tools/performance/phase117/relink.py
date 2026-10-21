"""Reuse authenticated QBE object bytes when only the cached runtime changes."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=int,default=30);p.add_argument('--prior',type=Path,required=True);a=p.parse_args();old=json.loads(a.prior.read_text());assert old['complete'];assert pin(a.source) in old['inputs']
for x in [old['object'],*old['inputs']]:assert pin(x['file'])==x
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase111');out.mkdir();linker=Path('/usr/bin/gcc').resolve();cmd=[str(linker),'-no-pie',old['object']['file'],str(a.runtime.resolve()),'-pthread','-lm','-o',str(out/'program')]
r=dict(kind='phase117-authenticated-object-relink',complete=False,object=old['object'],inputs=[pin(__file__),pin(a.prior),old['object'],pin(a.source),pin(a.runtime),pin(linker)],command=cmd,scope='Exact prior QBE object reused; only runtime object changes. No per-program C or QBE rerun.');save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();start=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=a.seconds);(out/'stdout').write_bytes(child.stdout);(out/'stderr').write_bytes(child.stderr);r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-start);assert r['complete'];r['binary']=pin(out/'program');save()
