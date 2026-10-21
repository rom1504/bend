"""Capture exact machine functions associated with measured numeric hot leaves."""
import importlib.util,json,re,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('p116s',HERE/'survey-v2.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
m=S.read(ROOT/'selfhost/build/phase116/manifest01.json');r=S.read(ROOT/'implementation/phase116/results.json');out=ROOT/'implementation/phase116/numeric-machine';assert not out.exists();out.mkdir();rows=[]
for name in ['scalar-region-8192','variation-ray-active-256-2240']:
 c=next(c for c in m['cases'] if c['name']==name)
 for role in ['upstream_c','selfhost_c','qbe']:
  p=next(p for p in r['nativeProfiles'] if p['case']==name and p['role']==role)
  for i,leaf in enumerate(p['symbols'][:(1 if name.startswith('scalar') else 2)]):
   binary=c['products'][role];S.verify(binary);text=subprocess.check_output(['objdump','-d','-M','intel','--disassemble='+leaf['name'],binary['file']],text=True);path=out/(name+'-'+role+'-'+str(i)+'.asm');path.write_text(text)
   instructions=[]
   for line in text.splitlines():
    match=re.match(r'^\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*([a-z][a-z0-9]+)\s*(.*)',line)
    if match:instructions.append(dict(address='0x'+match[1],mnemonic=match[2],operands=match[3]))
   counts={k:sum(x['mnemonic'].startswith(k) for x in instructions) for k in ['call','j','cmov','set','sar','shr','shl','movd','movq','mulss','divss','addss','subss','sqrtss']}
   rows.append(dict(case=name,role=role,symbol=leaf,binary=binary,assembly=S.pin(path),instructions=len(instructions),mnemonicCounts=counts,scope='Static whole-function machine counts include all branches and inlined work. Names refer to physical leaves, not equivalent function boundaries.'))
S.save(out/'report.json',dict(complete=True,method=S.pin(__file__),rows=rows));print([(x['case'],x['role'],x['symbol']['decoded'],x['instructions'],x['mnemonicCounts']) for x in rows])
