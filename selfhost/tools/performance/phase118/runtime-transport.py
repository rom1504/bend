"""Explicit capability8 honors checked constructor hot facts in all creators."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
parent=ROOT/'selfhost/build/phase118/runtime-cold01';old=json.loads((parent/'report.json').read_text());assert old['complete']
for r in [*old['inputs'],old['source'],old['object']]:assert pin(r['file'])==r
s=(parent/'runtime.c').read_text();changes=[]
def replace(before,after):
 global s
 assert s.count(before)==1,(before,s.count(before));s=s.replace(before,after);changes.append(dict(before=before,after=after))
replace('(program->capabilities == 1 || program->capabilities == 3 || program->capabilities == 9 || program->capabilities == 11)',
 '(program->capabilities == 1 || program->capabilities == 3 || program->capabilities == 5 || program->capabilities == 7 || program->capabilities == 9 || program->capabilities == 11 || program->capabilities == 13 || program->capabilities == 15)')
replace('memset(state->regs + count, 0, (p111_transport_words - count) * sizeof(uint64_t));',
 'if (!(p111_program_active->capabilities & UINT64_C(4))) memset(state->regs + count, 0, (p111_transport_words - count) * sizeof(uint64_t));')
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir();(out/'runtime.c').write_text(s)
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve();cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]
r=dict(complete=False,kind='phase118-capability4-live-prefix-runtime',inputs=[pin(__file__),pin(parent/'report.json'),old['source'],pin(parent/'runtime.h'),pin(parent/'primitives.h'),pin(compiler)],source=pin(out/'runtime.c'),command=cmd,changes=changes,scope='Certified cap4 omits dead-tail clearing only. All live copies, initial zeroing, builtin bank behavior and old capabilities unchanged.')
save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:child=subprocess.run(cmd,stdout=so,stderr=se,timeout=45)
r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-t)
if r['complete']:r['object']=pin(out/'runtime.o')
save();print(json.dumps(dict(complete=r['complete'],seconds=r['seconds'])));raise SystemExit(child.returncode)
