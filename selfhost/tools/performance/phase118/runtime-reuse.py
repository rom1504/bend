"""Build an additive cached runtime from pinned Phase117 and explicit helpers."""
import argparse, hashlib, json, subprocess, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[4]
def pin(p):
    p=Path(p).resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--extra',type=Path,action='append',required=True);a=p.parse_args()
parent=ROOT/'selfhost/build/phase118/runtime-cold01';old=json.loads((parent/'report.json').read_text())
assert old['complete']
for r in [*old['inputs'],old['source'],old['object']]: assert pin(r['file'])==r
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir()
(out/'runtime.c').write_text((parent/'runtime.c').read_text()+'\n'+''.join('\n'+f.read_text() for f in a.extra))
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve()
cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]
r=dict(complete=False,kind='phase118-additive-runtime',inputs=[pin(__file__),pin(parent/'report.json'),old['source'],pin(parent/'runtime.h'),pin(parent/'primitives.h'),pin(compiler),*[pin(f) for f in a.extra]],source=pin(out/'runtime.c'),command=cmd,scope='Selected cap8 cold runtime remains intact; additive worker-local cell credit helpers.')
save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se: child=subprocess.run(cmd,stdout=so,stderr=se,timeout=45)
r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-t)
if r['complete']: r['object']=pin(out/'runtime.o')
save();print(json.dumps(r));raise SystemExit(child.returncode)
