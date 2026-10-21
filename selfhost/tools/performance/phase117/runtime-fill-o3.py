"""One-flag cached-runtime experiment; exact source/QBE and unchanged FP policy."""
import hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
parent=ROOT/'selfhost/build/phase117/runtime01/report.json';j=json.loads(parent.read_text());assert j['complete']
for x in [j['source'],*j['inputs']]:assert pin(x['file'])==x
out=ROOT/'selfhost/build/phase117/runtime-fill-o3-01';assert not out.exists();out.mkdir();text=Path(j['source']['file']).read_text();needle='INLINE Term blk_new(';assert text.count(needle)==1;text=text.replace(needle,'__attribute__((optimize("O3"))) '+needle);(out/'runtime.c').write_text(text)
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((Path(j['source']['file']).parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve();cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')];r=dict(complete=False,inputs=[pin(__file__),pin(parent),j['source'],*j['inputs'],pin(compiler)],source=pin(out/'runtime.c'),headers=[pin(out/'runtime.h'),pin(out/'primitives.h')],command=cmd,scope='Only blk_new receives GCC optimize O3; rest remains O2. Exact original function body and FP policy; no generated QBE changes.');save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:c=subprocess.run(cmd,stdout=so,stderr=se,timeout=45)
r.update(complete=c.returncode==0,status=c.returncode,seconds=time.monotonic()-t);assert r['complete'];r['object']=pin(out/'runtime.o');save()
