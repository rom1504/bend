#!/usr/bin/env python3
"""Bounded offline disassembly only; does not execute products."""
import hashlib,json,pathlib,re,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=pathlib.Path(__file__).resolve().parent
cases=['value-identity-rebind','value-identity-helpers','register-pressure-few','register-pressure-many','memory-dependence-sequential','memory-dependence-dependent']
roles={'baseline':'diag-baseline-build04','selected':'diag-selected-build02','commutative':'diag-commutative-build01'}
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def metrics(rows):
 asm=[s for a,s in rows]
 return {'instructions':len(rows),'explicit_stack_memory':sum(bool(re.search(r'%r(?:bp|sp)\)',s))and not s.startswith(('lea','nop'))for s in asm),
  'moves':sum(s.startswith('mov')for s in asm),'calls':sum(s.startswith('call')for s in asm),'imul':sum(s.startswith('imul')for s in asm),'xor':sum(s.startswith('xor')for s in asm)}
def symbols(p):
 out=[]
 for line in subprocess.check_output(['nm','-S',str(p)],text=True).splitlines():
  q=line.split()
  if len(q)!=4 or 'FID_'not in q[-1]:continue
  sym=q[-1]
  try:name=bytes(map(int,sym.split('FID_')[1].strip('_').split('_'))).decode()
  except(ValueError,UnicodeError):continue
  if sym.startswith('p113d_')and name in ['$direct.p194.kernel','$direct.p194.read_loop','$direct.p194.read_cell','$product.p194.read_step']:
   out.append((sym,name,int(q[0],16),int(q[1],16)))
 return out
report={'kind':'phase194-offline-diagnostic-machine','targetExecuted':False,'cases':{},'scope':'Static bounded disassembly, not timing. Explicit stack counts exclude LEA and do not include memory through scratch-address registers.'}
for case in cases:
 record=report['cases'][case]={}
 for role,stage in roles.items():
  binary=ROOT/'selfhost/build/phase194'/stage/case/'machine/program'
  if not binary.exists():continue
  functions=[]
  for i,(sym,name,addr,size)in enumerate(symbols(binary)):
   asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+sym,str(binary)],text=True)
   p=OUT/f'{case}-{role}-{i}.asm';p.write_text(asm)
   rows=[(int(a,16),s)for a,s in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   frame=re.search(r'\bsub\s+\$0x([a-f0-9]+),%rsp',asm)
   row={'symbol':sym,'decoded':name,'address':hex(addr),'symbol_bytes':size,'frame_reservation':int(frame[1],16)if frame else 0,'assembly':pin(p),'metrics':metrics(rows),'call_symbols':[re.search(r'<([^>]+)>',s)[1]for a,s in rows if s.startswith('call')and '<'in s]}
   if name in ['$direct.p194.kernel','$direct.p194.read_loop']:
    assert rows[-1][1].startswith('jmp')
    header=int(re.search(r'jmp\w*\s+([a-f0-9]+)',rows[-1][1])[1],16)
    h=next(i for i,(a,s)in enumerate(rows)if a==header)
    assert rows[h+1][1].startswith('jne')
    positive=int(re.search(r'jne\w*\s+([a-f0-9]+)',rows[h+1][1])[1],16)
    path=rows[h:h+2]+[(a,s)for a,s in rows if a>=positive]
    row['positive_loop']={'header':hex(header),'positive':hex(positive),'backedge':hex(rows[-1][0]),'metrics':metrics(path)}
   if name in ['$direct.p194.read_cell','$product.p194.read_step']:
    byaddr={a:i for i,(a,s)in enumerate(rows)};path=[];i=0
    while i<len(rows):
     a,s=rows[i];path.append((a,s))
     if s.startswith('ret'):break
     if s.startswith('jmp'):
      dest=int(re.search(r'jmp\w*\s+([a-f0-9]+)',s)[1],16);i=byaddr[dest]
     else:i+=1
     assert len(path)<len(rows)+1
    row['valid_fast_path']={'rule':'All conditionals fall through (valid tuple tags and inline array fast path), unconditional forward jumps followed, stops at first return. Includes prologue/epilogue.','metrics':metrics(path),'call_symbols':[re.search(r'<([^>]+)>',s)[1]for a,s in path if s.startswith('call')and '<'in s]}
   functions.append(row)
  sizes=subprocess.check_output(['size','-A',str(binary)],text=True)
  record[role]={'binary':pin(binary),'text_bytes':int(re.search(r'^\.text\s+(\d+)',sizes,re.M)[1]),'functions':functions}
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
for case,roles in report['cases'].items():
 for role,info in roles.items():
  print(case,role)
  for f in info['functions']:print(f['decoded'],f['symbol_bytes'],f['frame_reservation'],f.get('positive_loop',f.get('valid_fast_path',f))['metrics'])
