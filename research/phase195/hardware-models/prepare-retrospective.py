#!/usr/bin/env python3
"""Metadata/disassembly only; neither executes products nor runs prediction tools."""
import hashlib,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent

def pin(file):
 p=Path(file);p=p if p.is_absolute() else ROOT/p;b=p.read_bytes()
 return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(row):
 actual=pin(row.get('file',row.get('path')))
 assert all(actual[k]==row[k] for k in ['bytes','sha256']),row
 return actual
def read(p):return json.loads((ROOT/p).read_text())
def disassemble(binary,symbol):
 return subprocess.check_output(['/usr/bin/objdump','-d','--no-show-raw-insn','--disassemble='+symbol,binary],text=True)
def rows(text):
 return [(int(m[1],16),m[2].strip()) for l in text.splitlines() if (m:=re.match(r'\s*([0-9a-f]+):\s+(.+)',l))]
def select(text,header,positive,backedge):
 r=rows(text);prefix=[]
 for addr,op in r:
  if addr<header:continue
  prefix.append((addr,op))
  if op.split()[0].startswith('j'):break
 selected=prefix+[(a,o) for a,o in r if positive<=a<=backedge]
 assert len({a for a,o in selected})==len(selected)
 assert not any(o.split()[0].startswith(('call','ret')) for a,o in selected)
 return selected

def emit(case,role,binary,symbol,text,selected):
 out=OUT/'inputs'/(case+'-'+role+'.s');lines=['# Straight-line positive-path projection; original instruction order retained.','# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.','.text','.Lloop:']
 addresses={a for a,o in selected}
 for a,op in selected:
  lines.append('.Lpc_'+format(a,'x')+':')
  op=op.split('#')[0].strip()
  if op.split()[0].startswith('j'):
   match=re.match(r'(\S+)\s+([0-9a-f]+)\b',op);assert match,op
   target=int(match[2],16);assert target in addresses,(case,hex(target))
   op=match[1]+' .Lpc_'+format(target,'x')
  op=re.sub(r'\b(\S+)\s+<[^>]+>',r'\1',op)
  lines.append('  '+op)
 out.write_text('\n'.join(lines)+'\n')
 full=OUT/'inputs'/(case+'-'+role+'.objdump');full.write_text(text)
 return dict(binary=binary,symbol=symbol,assembly=pin(out),disassembly=pin(full),selectedAddresses=[hex(a) for a,o in selected],instructionCount=len(selected),moves=sum(o.split()[0].startswith('mov') for a,o in selected),stackReferences=sum(bool(re.search(r'\(%(?:r|e)(?:bp|sp)\)',o)) and not o.startswith(('lea','nop')) for a,o in selected),headerMod64=selected[0][0]%64)

diag=read('research/phase194/diagnostic-machine-witnesses/report.json')
timing=read('selfhost/build/phase194/diagnostic-commutative-runtime01/timing/report.json')
assert timing['complete'] and not timing.get('changedInputs')
pairs=[]
for case in ['register-pressure-few','register-pressure-many','value-identity-rebind']:
 pair=dict(id='p194-'+case,case=case,roles={},profileImportance=None,importanceEvidence='Source-defined repeated scalar kernel; no exact historical paired sampling fraction.')
 tc=next(c for c in timing['cases'] if c['id']==case)
 for role,source_role,runtime_role in [('before','selected','baseline'),('after','commutative','candidate')]:
  info=diag['cases'][case][source_role];binary=verify(info['binary']);f=info['functions'][0]
  assert any(x.get('sha256')==binary['sha256'] and x.get('bytes')==binary['bytes'] for x in timing['inputs']),('binary absent from timing',case,role)
  witness=verify(f['assembly']);text=Path(witness['file']).read_text();loop=f['positive_loop']
  selected=select(text,*[int(loop[k],16) for k in ['header','positive','backedge']]);assert len(selected)==loop['metrics']['instructions']
  pair['roles'][role]=emit(pair['id'],role,binary,f['symbol'],text,selected)
 pair['runtimeCase']=tc
 pair['machineReceipt']=pin('research/phase194/diagnostic-machine-witnesses/report.json')
 pair['runtimeReceipt']=pin('selfhost/build/phase194/diagnostic-commutative-runtime01/timing/report.json')
 pairs.append(pair)
summary=read('selfhost/build/phase192/runtime-summary01.json');case=next(c for c in summary['cases'] if c['id']=='coverage-closures-256')
verify(summary['report'])
symbol='p113d_FID_'+''.join(str(ord(c))+'_' for c in '$p121.callback.bench')
pair=dict(id='p192-closures256',case='coverage-closures-256',roles={},runtimeCase=case,runtimeReceipt=pin(summary['report']['file']),summaryReceipt=pin('selfhost/build/phase192/runtime-summary01.json'),profileImportance=None,importanceEvidence='Repeated callback established by source/CFG; no exact paired sampling fraction.')
for role,source_role,header,backedge in [('before','baseline',0x4083f7,0x40842b),('after','candidate',0x408379,0x4083ad)]:
 binary=verify(case['artifacts'][source_role]);text=disassemble(binary['file'],symbol);r=rows(text)
 # Both callback loops branch to the exit; fallthrough is the repeated body.
 selected=[(a,o) for a,o in r if header<=a<=backedge]
 # A taken exit is not part of the repeated path: retain its Jcc as an event,
 # redirect its symbolic target to the same-path continuation for MCA only.
 branch=next((a,o) for a,o in selected if o.split()[0].startswith('j'))
 nextaddr=next(a for a,o in selected if a>branch[0]);selected=[(a,re.sub(r'^(\S+)\s+[0-9a-f]+.*',r'\1 '+format(nextaddr,'x'),o)) if a==branch[0] else (a,o) for a,o in selected]
 pair['roles'][role]=emit(pair['id'],role,binary,symbol,text,selected)
 pair['roles'][role]['branchProjection']='Exit Jcc target redirected to fallthrough for static straight-line model; no real encoding/layout claim.'
pairs.append(pair)
manifest=dict(kind='phase195-hardware-retrospective-inputs',version=1,targetsRun=False,modelsRun=False,scope='Four preselected paired path projections. Known historical outcomes; not a blinded study. No fitting or changing model settings after outcomes.',pairs=pairs,inputs=[pin(__file__),pin('/usr/bin/objdump')])
(OUT/'pairs-v1.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('prepared',len(pairs),'pairs; model/target execution absent')
