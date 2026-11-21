#!/usr/bin/env python3
"""Authenticate two paired objects and their actual static tail transfers."""
from pathlib import Path
import hashlib,json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'selfhost/build/phase198/heap-witness01'
def pin(q):
 q=Path(q);b=q.read_bytes();return {'file':str(q),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def read(q):return json.loads(Path(q).read_text())
def verify(p):
 q=pin(p['file']);assert all(q[k]==p[k] for k in ('bytes','sha256')),p['file']
def same(a,b):return all(a[k]==b[k] for k in ('bytes','sha256'))
def tails(text):
 fn='';history=[];rows=[]
 for line in text.splitlines():
  m=re.match(r'^([0-9a-f]+) <(.+)>:$',line)
  if m:fn=m[2];history=[];continue
  m=re.match(r'^\s*([0-9a-f]+):\s+R_X86_64_PC32\s+(p111_FID_\S+?)(?:-0x4)?$',line)
  if m and history and history[-1][1] in ('jmp','jmpq'):
   preceding=history[-12:-1]
   stop=any(op in ('mov','movl') and args.replace(' ','')=='$0xffffffff,0x20(%rdi)' for at,op,args in preceding)
   pop=len(history)>1 and history[-2][1] in ('pop','popq') and history[-2][2].strip()=='%rbp'
   frame=len(history)>2 and history[-3][1] in ('mov','movq') and history[-3][2].replace(' ','')=='%rbp,%rsp'
   rows.append({'caller':fn,'offset':history[-1][0],'target':m[2],'stopReset':stop,'frameRestored':pop and frame,'instructions':history[-12:]})
  m=re.match(r'^\s*([0-9a-f]+):\s+([a-z][a-z0-9]*)\s*(.*)$',line)
  if m:history.append((m[1],m[2],m[3]))
 return rows
began=False
def main():
 global began
 assert not OUT.exists();OUT.mkdir();began=True
 mapfile=ROOT/'research/phase198/heap/source-mapping.json';mapping=read(mapfile);assert mapping['complete'] and mapping['changedDeclarations']==[['def','x190_step']]
 for k in ('nativeBaselineSourceAudit','nativeBaselineSource','checkedBaselineApiReceipt','checkedCandidateApiReceipt','candidatePreparation'):verify(mapping[k])
 nativefile=ROOT/'selfhost/build/phase198/native45-01/programs.manifest.json';native=read(nativefile)
 emissionfile=ROOT/'selfhost/build/phase198/heap-pair-emission01/heap/report.json';emission=read(emissionfile);assert emission['complete'] and not emission.get('error')
 for p in emission['inputs']:verify(p)
 assert set(emission['selected'])=={'test-map-set-ops','lexer'}
 known={c['id']:c for c in native['cases']};rows=[]
 for row in emission['rows']:
  assert row['complete'] and row['verified'];case=row['id'];base=known[case];assert row['source']==base['source'] and row['expectedFile']==base['expectedFile']
  product=base['products']['candidate'];assert same(native['roles']['candidate']['compilerSource'],mapping['nativeBaselineSource'])
  for p in product['inputs']:verify(p)
  a=product['generatedSource'];b=row['product'];verify(a);verify(b);verify(product['artifact']);verify(base['expectedFile'])
  objects={}
  for role,p in [('baseline',a),('heap',b)]:
   text=subprocess.check_output(['/usr/bin/objdump','-dr','--no-show-raw-insn',p['file']],text=True)
   f=OUT/(case+'-'+role+'.disassembly');f.write_text(text);ts=tails(text)
   objects[role]={'object':p,'disassembly':pin(f),'tailSites':ts,'tailCount':len(ts)}
  assert objects['heap']['tailCount']>objects['baseline']['tailCount'],case+' lacks new public-tail activation'
  assert all(x['stopReset'] and x['frameRestored'] for x in objects['heap']['tailSites']),case+' tail epilogue mismatch'
  rows.append({'case':case,'source':row['source'],'oracle':base['expectedFile'],'objects':objects,'sameObject':same(a,b)})
 report={'kind':'phase198-public-tail-object-witness','complete':True,'targetsRun':False,'method':pin(__file__),'objdump':pin('/usr/bin/objdump'),'sourceMapping':pin(mapfile),'baselineManifest':pin(nativefile),'candidateEmission':pin(emissionfile),'rows':rows,'scope':'Actual native198 baseline and checked-heap emitted objects. External public JMP relocations must have preceding STOP reset and restored frame. Catalog output oracles are separately required before timing; no performance claim.'}
 (OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({'complete':True,'tailSites':{r['case']:r['objects']['heap']['tailCount'] for r in rows}}))

try:
 main()
except Exception as error:
 if began:
  (OUT/'report.json').write_text(json.dumps({'kind':'phase198-public-tail-object-witness','complete':False,'targetsRun':False,'method':pin(__file__),'error':repr(error)},indent=2)+'\n')
 raise
