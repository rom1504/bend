"""Explicit capability8 honors checked constructor hot facts in all creators."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
parent=ROOT/'selfhost/build/phase118/runtime01';old=json.loads((parent/'report.json').read_text());assert old['complete']
for r in [*old['inputs'],old['source'],old['object']]:assert pin(r['file'])==r
s=(parent/'runtime.c').read_text();changes=[]
def replace(before,after):
 global s
 assert s.count(before)==1,(before,s.count(before));s=s.replace(before,after);changes.append(dict(before=before,after=after))
replace('(program->capabilities == P111_SEQUENTIAL || program->capabilities == (P111_SEQUENTIAL | UINT64_C(2)))',
 '(program->capabilities == 1 || program->capabilities == 3 || program->capabilities == 9 || program->capabilities == 11)')
replace('for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);',
 'if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {\n    for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];\n  } else {\n    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);\n  }')
replace('for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \\\n',
 'if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \\\n    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i]; \\\n  } else { \\\n    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \\\n  } \\\n')
replace('for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);',
 'if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {\n    for (u32 i = 0; i < count; ++i) e.mem[at + i] = prefix[i];\n  } else {\n    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);\n  }')
replace('state->e.mem[slot] = rfc_seal(state->e, value);',
 'state->e.mem[slot] = ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid))\n    ? value : rfc_seal(state->e, value);')
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir();(out/'runtime.c').write_text(s)
for n in ['runtime.h','primitives.h']:(out/n).write_bytes((parent/n).read_bytes())
compiler=Path('/usr/bin/gcc').resolve();cmd=[str(compiler),'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]
r=dict(complete=False,kind='phase118-capability8-cold-runtime',inputs=[pin(__file__),pin(parent/'report.json'),old['source'],pin(parent/'runtime.h'),pin(parent/'primitives.h'),pin(compiler)],source=pin(out/'runtime.c'),command=cmd,changes=changes,scope='Only certified cap8 allows raw owned fields for cold parents. Parent CID controls deferred tail sealing. Legacy1/3 unchanged.')
save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();t=time.monotonic()
with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:child=subprocess.run(cmd,stdout=so,stderr=se,timeout=45)
r.update(complete=child.returncode==0,status=child.returncode,seconds=time.monotonic()-t)
if r['complete']:r['object']=pin(out/'runtime.o')
save();print(json.dumps(dict(complete=r['complete'],seconds=r['seconds'])));raise SystemExit(child.returncode)
