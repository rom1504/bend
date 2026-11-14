#!/usr/bin/env python3
"""Offline selected reference disassembly; no target execution."""
import hashlib,json,pathlib,re,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent
cases=['value-identity-rebind','value-identity-helpers','register-pressure-few','register-pressure-many','memory-dependence-sequential','memory-dependence-dependent']
def pin(p):
 b=p.read_bytes();return {'file':str(p.relative_to(ROOT)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
report={'kind':'phase194-offline-diagnostic-references','targetExecuted':False,'cases':{}}
for case in cases:
 record=report['cases'][case]={}
 for role,suffix in [('c','c/program'),('qbe','qbe/machine/program')]:
  binary=ROOT/'selfhost/build/phase194/diag-references02'/case/suffix
  if not binary.exists():continue
  functions=[]
  for line in subprocess.check_output(['nm','-S',str(binary)],text=True).splitlines():
   q=line.split()
   if len(q)!=4 or 'FID_'not in q[-1]:continue
   sym=q[-1]
   if not sym.startswith(('p113d_','WL_')):continue
   try:name=bytes(map(int,sym.split('FID_')[1].strip('_').split('_'))).decode()
   except(ValueError,UnicodeError):continue
   if name not in ['$direct.p194.kernel','$direct.p194.read_loop','$direct.p194.read_cell','$product.p194.read_step','$direct.p194.read_step']:continue
   asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+sym,str(binary)],text=True)
   p=OUT/f'{case}-{role}-{len(functions)}.asm';p.write_text(asm)
   rows=[(int(a,16),s)for a,s in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   frame=re.search(r'\bsub\s+\$0x([a-f0-9]+),%rsp',asm)
   functions.append({'symbol':sym,'decoded':name,'address':q[0],'symbol_bytes':int(q[1],16),
    'frame_reservation':int(frame[1],16)if frame else 0,'assembly':pin(p),'instructions':len(rows),
    'calls':[{'address':hex(a),'target':re.search(r'<([^>]+)>',s)[1]}for a,s in rows if s.startswith('call')and '<'in s]})
  for f in functions:
   asm=(ROOT/f['assembly']['file']).read_text()
   rows=[(int(a,16),x)for a,x in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   edges=[]
   for a,x in rows:
    match=re.match(r'j\w+\s+([a-f0-9]+)',x)
    if match and (dest:=int(match[1],16))<a and dest>=int(f['address'],16):
     body=[(b,y)for b,y in rows if dest<=b<=a]
     edges.append({'header':hex(dest),'backedge':hex(a),'instructions':len(body),
      'explicit_stack_memory':sum(bool(re.search(r'%r(?:bp|sp)\)',y))and not y.startswith(('lea','nop'))for b,y in body),
      'calls':sum(y.startswith('call')for b,y in body)})
   f['backward_edges']=edges
  record[role]={'binary':pin(binary),'functions':functions}
(OUT/'reference-report.json').write_text(json.dumps(report,indent=2)+'\n')
for case,roles in report['cases'].items():
 for role,info in roles.items():
  print(case,role)
  for f in info['functions']:print(f['decoded'],f['symbol_bytes'],f['frame_reservation'],f['instructions'],[c['target']for c in f['calls']])
