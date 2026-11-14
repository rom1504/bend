#!/usr/bin/env python3
"""Offline heldout disassembly and exact manifest pin verification."""
from pathlib import Path
import subprocess,re,json,hashlib
ROOT=Path(__file__).resolve().parents[3];OUT=Path(__file__).resolve().parent
base_manifest=ROOT/'selfhost/build/phase194/references01/manifest.json'
current_manifest=ROOT/'selfhost/build/phase194/native45-02/programs.manifest.json'
base=json.loads(base_manifest.read_text());current=json.loads(current_manifest.read_text())
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def metrics(rows):
 ss=[s for a,s in rows]
 return dict(instructions=len(rows),moves=sum(s.startswith('mov')for s in ss),setcc=sum(s.startswith('set')for s in ss),test=sum(s.startswith('test')for s in ss),cmov=sum(s.startswith('cmov')for s in ss),explicit_stack=sum(bool(re.search(r'%r(?:bp|sp)\)',s))and not s.startswith(('lea','nop'))for s in ss),calls=sum(s.startswith('call')for s in ss))
report={'kind':'phase194-heldout-offline-machine','targetExecuted':False,'manifests':[pin(base_manifest),pin(current_manifest)],'cases':{}}
for case,names in [('scalar-region-8192',['$direct.mit','$direct.bench','$direct.p93.loop']),('coverage-closures-256',['$p121.callback.bench','$direct.bench','$direct.p93.loop'])]:
 report['cases'][case]={}
 for role,manifest in [('baseline',base),('current',current)]:
  row=next(x for x in manifest['cases']if x['id']==case)
  product=row['products']['baseline']if role=='baseline'else next(iter(row['products'].values()))
  p=Path(product['artifact']['file']);assert pin(p)==product['artifact']
  fs=[]
  for i,name in enumerate(names):
   sym='p113d_FID_'+''.join(str(x)+'_'for x in name.encode())
   asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+sym,str(p)],text=True)
   f=OUT/f'{case}-{role}-{i}.asm';f.write_text(asm)
   raw=subprocess.check_output(['objdump','-d','--disassemble='+sym,str(p)],text=True)
   code=b''.join(bytes.fromhex(x)for x in re.findall(r'^\s*[a-f0-9]+:\s*((?:[a-f0-9]{2}\s)+)',raw,re.M))
   rows=[(int(a,16),s)for a,s in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   frame=re.search(r'sub\s+\$0x([a-f0-9]+),%rsp',asm)
   item={'symbol':sym,'decoded':name,'bytes':len(code),'codeSha256':hashlib.sha256(code).hexdigest(),'address':hex(rows[0][0]),'frameReservation':int(frame[1],16)if frame else 0,'wholeFunction':metrics(rows),'assembly':pin(f)}
   backs=[]
   for a,s in rows:
    m=re.match(r'jmp\w*\s+([a-f0-9]+)',s)
    if m and (h:=int(m[1],16))<a:
     hi=next(j for j,(b,t)in enumerate(rows)if b==h)
     if rows[hi+1][1].startswith('jne'):
      positive=int(re.search(r'jne\w*\s+([a-f0-9]+)',rows[hi+1][1])[1],16)
      body=rows[hi:hi+2]+[(b,t)for b,t in rows if positive<=b<=a]
     else:body=[(b,t)for b,t in rows if h<=b<=a]
     backs.append({'header':hex(h),'headerMod64':h%64,'backedge':hex(a),'metrics':metrics(body)})
   item['positiveLoops']=backs;fs.append(item)
  text=subprocess.check_output(['size','-A',str(p)],text=True)
  report['cases'][case][role]={'binary':pin(p),'textBytes':int(re.search(r'^\.text\s+(\d+)',text,re.M)[1]),'functions':fs}
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
for case,roles in report['cases'].items():
 for role,d in roles.items():
  print(case,role,'text',d['textBytes'])
  for f in d['functions']:print(f['decoded'],f['bytes'],f['frameReservation'],f['positiveLoops'])
