#!/usr/bin/env python3
"""Offline bounded function evidence; never execute compiler/target products."""
import gzip, hashlib, json, re, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent

def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def decode(s):
 if '_FID_' not in s:return s
 prefix,tail=s.split('_FID_',1)
 try:return prefix+':'+''.join(chr(int(x)) for x in tail.split('_') if x)
 except ValueError:return s
summary=json.loads((ROOT/'implementation/phase194/runtime-summary.json').read_text())
rows=[]
for case in ['coverage-map-churn-128','coverage-record-aggregation-256','tree-bitonic']:
 record=next(r for r in summary['cases'] if r['id']==case)
 for role in ['candidate','qbe','c']:
  p=Path(record['artifacts'][role]['file']);assert pin(p)['sha256']==record['artifacts'][role]['sha256']
  wanted=['$direct.Map.seek.go','$product.Map.bit.go','$p118borrow.read.Map.bit.go'] if case!='tree-bitonic' else ['$direct.warp_zip','$direct.warp']
  for line in subprocess.check_output(['nm','-S',str(p)],text=True).splitlines():
   fields=line.split()
   if len(fields)!=4:continue
   symbol=fields[3];name=decode(symbol)
   if ':' not in name or name.split(':',1)[1] not in wanted:continue
   if name.startswith(('p112w:','p117v:')):continue
   text=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+symbol,str(p)],text=True)
   stem=f'{case}-{role}-{name.replace(":","-").replace("$","")}.asm.gz'
   with (OUT/stem).open('wb') as raw,gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as z:z.write(text.encode())
   instructions=[x for x in text.splitlines() if re.match(r'^\s*[0-9a-f]+:\s',x)]
   calls={}
   for x in instructions:
    m=re.search(r'\bcall\w*\s+.*<([^>]+)>',x)
    if m:
     target=decode(m.group(1));calls[target]=calls.get(target,0)+1
   rows.append(dict(case=case,role=role,artifact=record['artifacts'][role],symbol=symbol,decoded=name,
     address=fields[0],bytes=int(fields[1],16),instructions=len(instructions),staticCalls=calls,evidence=pin(OUT/stem)))
result=dict(kind='phase195-ownership-static-witness',programsExecuted=False,method=pin(Path(__file__)),
 source=pin(ROOT/'selfhost/build/phase194/selected-source02/compiler.bend'),
 baselineRuntime=pin(ROOT/'implementation/phase194/runtime-summary.json'),functions=rows,
 scope='Bounded whole-function disassemblies, including cold/error paths. Static call counts are not invocation frequencies or removable dynamic-cost estimates. References are retained mature C/QBE products authenticated by current runtime report.')
(OUT/'machine.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps([dict(case=r['case'],role=r['role'],name=r['decoded'],bytes=r['bytes'],instructions=r['instructions']) for r in rows]))
