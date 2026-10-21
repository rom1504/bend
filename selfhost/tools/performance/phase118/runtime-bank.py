"""Explicit capability8 honors checked constructor hot facts in all creators."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
parent=ROOT/'selfhost/build/phase118/runtime-transport01';old=json.loads((parent/'report.json').read_text());assert old['complete']
for r in [*old['inputs'],old['source'],old['object']]:assert pin(r['file'])==r
s=(parent/'runtime.c').read_text();changes=[]
def replace(before,after):
 global s
 assert s.count(before)==1,(before,s.count(before));s=s.replace(before,after);changes.append(dict(before=before,after=after))
replace('#define WL_BANK Term p111_regs[P111_REG_CAP];',
 '#define WL_BANK const bool p118_live_bank = (p111_program_active->capabilities & UINT64_C(4)) != 0; Term p118_local_regs[P111_REG_CAP]; Term *p111_regs = p118_live_bank ? wl->regs : p118_local_regs;')
replace('#define WL_INIT_BANK memset(p111_regs, 0, sizeof(Term) * p111_transport_words);',
 '#define WL_INIT_BANK if (!p118_live_bank) memset(p111_regs, 0, sizeof(Term) * p111_transport_words);')
replace('#define WL_READ_STATE(V) memcpy(p111_regs, (V), sizeof(Term) * p111_transport_words);',
 '#define WL_READ_STATE(V) if (!p118_live_bank) memcpy(p111_regs, (V), sizeof(Term) * p111_transport_words);')
replace('#define WL_WRITE_STATE(V) memcpy((V), p111_regs, sizeof(Term) * p111_transport_words);',
 '#define WL_WRITE_STATE(V) if (!p118_live_bank) memcpy((V), p111_regs, sizeof(Term) * p111_transport_words);')
replace('#define WL_SAVE(V) memcpy((V), p111_regs, sizeof(Term) * p111_transport_words);',
 '#define WL_SAVE(V) memcpy((V), p111_regs, sizeof(Term) * (p118_live_bank ? n : p111_transport_words));')
replace('#define WL_TAKE(V) memcpy(p111_regs, (V), sizeof(Term) * p111_transport_words);',
 '#define WL_TAKE(V) memcpy(p111_regs, (V), sizeof(Term) * (p118_live_bank ? n : p111_transport_words));')
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir();(out/'runtime.c').write_text(s)
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve();cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]
r=dict(complete=False,kind='phase118-capability4-in-place-builtin-bank-runtime',inputs=[pin(__file__),pin(parent/'report.json'),old['source'],pin(parent/'runtime.h'),pin(parent/'primitives.h'),pin(compiler)],source=pin(out/'runtime.c'),command=cmd,changes=changes,scope='Cap4 builtins operate on the invocation-local state bank directly; FID_EXIT snapshots only explicit n results. Other capabilities retain local bank copy/clear. No physical layout, ownership or initial-state change.')
save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:child=subprocess.run(cmd,stdout=so,stderr=se,timeout=45)
r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-t)
if r['complete']:r['object']=pin(out/'runtime.o')
save();print(json.dumps(dict(complete=r['complete'],seconds=r['seconds'])));raise SystemExit(child.returncode)
