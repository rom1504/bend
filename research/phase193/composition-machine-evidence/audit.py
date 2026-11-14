#!/usr/bin/env python3
"""Read-only ELF symbol audit; executes only nm/objdump, never inspected products."""
import collections,gzip,hashlib,json,re,struct,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent
ROLES={
 'phase192_compiler_n2':'selfhost/build/phase192/native-self01/program',
 'kernel_baseline':'selfhost/build/phase193/compiler-hot-baseline-machine01/program',
 'kernel_candidate':'selfhost/build/phase193/compiler-hot-candidate-machine01/program',
}
OWNERS=['$direct.index_leaf','$direct.index_remove','$direct.p111v_put','$direct.p131i_insert','$direct.p193t_run','$direct.p193t_go','main']
def decode(s):
 def one(m):
  try:return m.group(1)+''.join(chr(int(z)) for z in m.group(2).split('_') if z)
  except ValueError:return m.group(0)
 return re.sub(r'(\w+_FID_)((?:\d+_)+)',one,s)
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def textsection(b):
 h=struct.unpack_from('<16sHHIQQQIHHHHHH',b,0);assert h[0][:6]==b'\x7fELF\x02\x01'
 sh=[struct.unpack_from('<IIQQQQIIQQ',b,h[6]+i*h[11]) for i in range(h[12])]
 names=b[sh[h[13]][4]:sh[h[13]][4]+sh[h[13]][5]]
 return next(s for s in sh if names[s[0]:].split(b'\0',1)[0]==b'.text')
report={'targetsRun':False,'method':'Bounded nm symbol selection, objdump --disassemble per selected public owner, exact ELF .text bytes. Counts are static, not executions or spills.','roles':{},'inputs':[]}
for role,rel in ROLES.items():
 p=ROOT/rel;b=p.read_bytes();sec=textsection(b);symbols={}
 for line in subprocess.check_output(['nm','-S','--defined-only',str(p)],text=True).splitlines():
  parts=line.split()
  if len(parts)==4:
   try:symbols[parts[3]]=(int(parts[0],16),int(parts[1],16))
   except ValueError:pass
 h=struct.unpack_from('<16sHHIQQQIHHHHHH',b,0)
 sections=[struct.unpack_from('<IIQQQQIIQQ',b,h[6]+i*h[11]) for i in range(h[12])]
 def read_address(addr,size):
  sh=next(z for z in sections if z[3]<=addr and addr+size<=z[3]+z[5] and z[1]!=8)
  return b[sh[4]+addr-sh[3]:sh[4]+addr-sh[3]+size]
 sa,ss=symbols['p111_segments'];addresses=struct.unpack('<'+'Q'*(ss//8),read_address(sa,ss))
 byaddr={addr:decode(sym) for sym,(addr,size) in symbols.items() if sym.startswith('p111_FID_')}
 targets=[byaddr.get(addr,hex(addr)) for addr in addresses]
 rr={'elf':pin(p),'owners':{}};texts=[]
 for owner in OWNERS:
  symbol='p111_FID_'+''.join(str(ord(c))+'_' for c in owner)
  if symbol not in symbols:
   rr['owners'][owner]={'present':False};continue
  addr,size=symbols[symbol];off=sec[4]+addr-sec[3];raw=b[off:off+size];assert len(raw)==size
  dis=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+symbol,str(p)],text=True)
  ins=[];calls=[]
  for line in dis.splitlines():
   m=re.match(r'^\s*([0-9a-f]+):\s+(.*)$',line)
   if not m:continue
   pc=int(m[1],16)
   if not addr<=pc<addr+size:continue
   op=m[2];ins.append((pc,op))
   c=re.search(r'\bcallq?\s+\S+\s+<([^>]+)>',op)
   if c:calls.append({'address':hex(pc),'target':decode(c[1])})
  normalized=[]
  for _,op in ins:
   op=decode(op)
   op=re.sub(r'\b[0-9a-f]+\s+<([^>]+)>',r'<\1>',op)
   if '#' in op and '(%rip)' in op:op=re.sub(r'-?0x[0-9a-f]+\(%rip\)', 'DISP(%rip)',op)
   normalized.append(op)
  counts=collections.Counter(c['target'] for c in calls)
  transitions=[]
  for i,(pc,op) in enumerate(ins):
   if re.match(r'mov\s+%r11d,0x20\(%r10\)',op) and i:
    m=re.search(r'movabs\s+\$0x([0-9a-f]+),%r11',ins[i-1][1])
    if m:
     fid=int(m[1],16);transitions.append(dict(address=hex(pc),fid=fid,target=targets[fid] if fid<len(targets) else 'INVALID'))
  stack_subtractions=[int(m[1],16) for _,op in ins if (m:=re.match(r'sub\s+\$0x([0-9a-f]+),%rsp',op))]
  rr['owners'][owner]={'present':True,'symbol':symbol,'address':hex(addr),'bytes':size,'symbolBytesSha256':hashlib.sha256(raw).hexdigest(),
    'relocationNormalizedInstructionsSha256':hashlib.sha256(('\n'.join(normalized)+'\n').encode()).hexdigest(),'instructionsIncludingPadding':len(ins),'frameMemoryInstructionsExceptLea':sum(bool(re.search(r'\(%r(?:bp|sp)\)',op)) and not op.startswith('lea') for _,op in ins),
    'selectedStateNextStores':transitions,'nativeFrameSubtractions':stack_subtractions,'stateR12SpStores':sum(bool(re.match(r'mov\s+%\w+,0x10\(%r12\)',op)) for _,op in ins),
    'conditionalBranches':sum(bool(re.match(r'j(?!mp)\w+\s',op)) for _,op in ins),'calls':dict(sorted(counts.items())),'callSites':calls}
  texts.append('\n'+role+' '+owner+' '+hex(addr)+' bytes='+str(size)+'\n'+'\n'.join(hex(pc)+' '+decode(op) for pc,op in ins)+'\n')
 with (OUT/(role+'.txt.gz')).open('wb') as sink:
  with gzip.GzipFile(fileobj=sink,mode='wb',mtime=0) as z:z.write(''.join(texts).encode())
 report['roles'][role]=rr
for rel in ['selfhost/build/phase193/compiler-hot-source01/manifest.json','selfhost/build/phase193/compiler-hot-baseline01/report.json','selfhost/build/phase193/compiler-hot-candidate01/report.json','selfhost/build/phase193/compiler-hot-baseline-machine01/report.json','selfhost/build/phase193/compiler-hot-candidate-machine01/report.json','selfhost/build/phase193/compiler-hot-source01/expected.stdout']:
 report['inputs'].append(pin(ROOT/rel))
def verify_record(record):
 p=Path(record['file']);actual=pin(p)
 assert actual['bytes']==record['bytes'] and actual['sha256']==record['sha256'],record['file']
 return actual
bindings={}
for role in ['baseline','candidate']:
 machine=json.loads((ROOT/('selfhost/build/phase193/compiler-hot-'+role+'-machine01/report.json')).read_text())
 emit=json.loads((ROOT/('selfhost/build/phase193/compiler-hot-'+role+'01/report.json')).read_text())
 assert machine['complete'] and emit['complete'] and machine['outputExact']
 for key in ['binary','runtime','sourceObject']:verify_record(machine[key])
 for key in ['source','object','api','compilerSource']:verify_record(emit[key])
 assert machine['sourceObject']['sha256']==emit['object']['sha256']
 bindings[role]={'binary':machine['binary'],'runtime':machine['runtime'],'source':emit['source'],'compilerSource':emit['compilerSource']}
assert bindings['baseline']['source']==bindings['candidate']['source']
assert bindings['baseline']['runtime']==bindings['candidate']['runtime']
report['bindingChecks']={'passed':True,'sameKernelSource':bindings['baseline']['source'],'sameRuntime':bindings['baseline']['runtime'],'roles':bindings}
report['evidence']=[pin(p) for p in sorted(OUT.glob('*.txt.gz'))]
(OUT/'metrics.json').write_text(json.dumps(report,indent=2)+'\n')
for owner in OWNERS:
 print(owner)
 for role,r in report['roles'].items():
  x=r['owners'][owner]
  if x['present']:print(role,x['bytes'],x['instructionsIncludingPadding'],{k:v for k,v in x['calls'].items() if k.startswith('p112w') or k in ['p111_rt_jump','p111_rt_frame','p111_rt_return']})
