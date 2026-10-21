"""Reproduce additive capability adapter over exact qualified runtime bytes."""
import hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
parent=ROOT/'selfhost/build/phase113/runtime-products01';old=json.loads((parent/'manifest.json').read_text())
for r in old['outputs']+old['inputs']:assert pin(r['file'])==r
out=ROOT/'selfhost/build/phase117/runtime01';assert not out.exists();out.mkdir()
s=(parent/'runtime.c').read_text()
a='#define NATIVE_SCALAR_ARRAYS 0';b='#define NATIVE_SCALAR_ARRAYS ((p111_program_active->capabilities & UINT64_C(2)) != 0)'
c='program->capabilities == P111_SEQUENTIAL';d='(program->capabilities == P111_SEQUENTIAL || program->capabilities == (P111_SEQUENTIAL | UINT64_C(2)))'
assert s.count(a)==s.count(c)==1;s=s.replace(a,b).replace(c,d)
(out/'runtime.c').write_text(s)
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve();cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]
r=dict(complete=False,kind='phase117-additive-packed-runtime',inputs=[pin(__file__),pin(parent/'manifest.json'),*old['outputs'],pin(compiler)],patches=[dict(before=a,after=b),dict(before=c,after=d)],source=pin(out/'runtime.c'),command=cmd,capabilities={'1':'uniform64, original behavior','3':'checked packed32 scalar arrays'},scope='Exact existing layout/helpers, descriptor-controlled mode; shared handles still use term_peek; no unshared runtime flag.')
save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:child=subprocess.run(cmd,stdout=so,stderr=se,timeout=40)
r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-t);assert child.returncode==0;r['object']=pin(out/'runtime.o');save();print(json.dumps(r['object']))
