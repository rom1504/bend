#!/usr/bin/env python3
"""Freeze actual emitted loop machine instructions before runtime measurement."""
import hashlib,json,pathlib,re,subprocess,difflib
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=ROOT/'research/phase198/loops/emission-evidence03'
OUT.mkdir(exist_ok=False)
CASES=['editdist','local-fold','variation-local-fold-8192-123','mandelbrot']
def pin(p):return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def parse(s):return [(int(m[1],16),' '.join(m[2].split()))for line in s.splitlines()if(m:=re.match(r'^\s*([0-9a-f]+):\s+(.+)',line))]
rows=[]
for case in CASES:
 row={'case':case,'objects':{},'loop':{}}
 symbol='p113d_FID_'+'_'.join(str(ord(c))for c in ('$product.row' if case=='editdist' else '$product.fold.loop'))+'_'
 bodies={}
 for role in ['baseline','loops']:
  p=ROOT/(f'selfhost/build/phase198/native45-01/{case}/machine/program.o'if role=='baseline' else f'selfhost/build/phase198/loops-emission03/loops/{case}/program.o')
  row['objects'][role]=pin(p)
  if case=='mandelbrot':continue
  args=['objdump','-d','-M','intel','--disassemble='+symbol,str(p)]
  raw=subprocess.check_output(args,text=True)
  (OUT/f'{case}-{role}.objdump').write_text(raw)
  text=subprocess.check_output(args[:1]+['--no-show-raw-insn']+args[1:],text=True)
  ins=parse(text);back=ins[-1];assert back[1].startswith('jmp ')
  target=int(back[1].split()[1],16);header=next(i for i,v in enumerate(ins)if v[0]==target)
  assert ins[header][1].startswith('cmp ') and ins[header+1][1].startswith('jne ')
  start=int(ins[header+1][1].split()[1],16);body=[x for x in ins if start<=x[0]<back[0]]
  assert not any(t.startswith(('j','ret','call'))for a,t in body)
  bodies[role]=[t for a,t in body]
  row['loop'][role]={'symbol':symbol,'start':hex(start),'backedge':hex(back[0]),'header':hex(target),'bodyInstructions':len(body),'bodyBytes':back[0]-start,'iterationInstructions':len(body)+3,'frameOperands':sum('[rbp' in t or '[rsp' in t for a,t in body),'headerCompare':ins[header][1]}
  (OUT/f'{case}-{role}.body').write_text('\n'.join(f'{a:x}: {t}'for a,t in body)+'\n')
 row['objectIdentical']=row['objects']['baseline']['sha256']==row['objects']['loops']['sha256']
 if bodies:
  (OUT/f'{case}.diff').write_text(''.join(difflib.unified_diff([t+'\n'for t in bodies['baseline']],[t+'\n'for t in bodies['loops']],fromfile='baseline',tofile='loops')))
 rows.append(row)
report={'complete':True,'targetsExecuted':False,'method':pin(pathlib.Path(__file__)),'rows':rows,'scope':'Actual ELF positive loop body, final backedge excluded from body but included with header CMP/JNE in iteration count. Frame operands are not cache misses.'}
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
