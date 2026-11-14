#!/usr/bin/env python3
"""Offline bounded function disassembly; never executes a target."""
import hashlib,json,pathlib,re,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=pathlib.Path(__file__).resolve().parent
selected={
 'local-pair':[('p113d_','$product.row')],
 'editdist':[('p113d_','$product.row')],
 'coverage-numeric-recurrence-256':[('p113d_','$direct.p37.numeric')],
 'variation-ray-active-64-2440':[('p113d_','$product.trace'),('p113d_','$direct.subray'),('p113d_','$direct.trace')],
 'lexer':[('p113d_','$product.lex'),('p113d_','$direct.cls')],
 'tree-bitonic':[('p114r_','$direct.scan'),('p114r_','$direct.warp'),('p113d_','$direct.warp_leaf.go')],
}
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def metrics(rows):
 asm=[s for a,s in rows]
 frame=[s for s in asm if '%rbp)'in s and not s.startswith(('lea','nop'))]
 return dict(instructions=len(rows),frame_memory_instructions=len(frame),setcc=sum(s.startswith('set')for s in asm),cmov=sum(s.startswith('cmov')for s in asm),test=sum(s.startswith('test')for s in asm),calls=sum(s.startswith('call')for s in asm))
def symbols(p):
 result={}
 for line in subprocess.check_output(['nm','-S',str(p)],text=True).splitlines():
  cols=line.split()
  if len(cols)!=4 or 'FID_' not in cols[-1]:continue
  sym=cols[-1];prefix,encoded=sym.split('FID_',1)
  try:name=bytes(int(n)for n in encoded.strip('_').split('_')).decode()
  except (ValueError,UnicodeError):continue
  result[(prefix,name)]=(sym,int(cols[0],16),int(cols[1],16))
 return result
report=dict(kind='phase194-offline-predicate-machine',targetExecuted=False,method='nm exact symbol; objdump no raw bytes; counts include every instruction row; frame counts exclude LEA',cases={})
for case,queries in selected.items():
 caseout=report['cases'][case]={}
 for role,stage in [('baseline','phase193/budget-native45-02'),('predicate','phase194/predicate-dev-build01')]:
  binary=ROOT/'selfhost/build'/stage/case/'machine/program';syms=symbols(binary)
  sizes=subprocess.check_output(['size','-A',str(binary)],text=True)
  textbytes=int(re.search(r'^\.text\s+(\d+)',sizes,re.M).group(1))
  detail=caseout[role]=dict(binary=pin(binary),text_bytes=textbytes,functions=[])
  for i,key in enumerate(queries):
   sym,address,size=syms[key]
   asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+sym,str(binary)],text=True)
   path=OUT/(case+'-'+role+'-'+str(i)+'.asm');path.write_text(asm)
   rows=[(int(a,16),s)for a,s in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   frame=re.search(r'\bsub\s+\$0x([0-9a-f]+),%rsp',asm)
   entry=dict(symbol=sym,decoded=key[1],address=hex(address),symbol_bytes=size,frame_reservation=int(frame.group(1),16)if frame else None,assembly=pin(path),metrics=metrics(rows))
   if case in ('local-pair','editdist'):
    assert rows[-1][1].startswith('jmp')
    header=int(re.search(r'jmp\w*\s+([0-9a-f]+)',rows[-1][1]).group(1),16)
    h=next(i for i,(a,s)in enumerate(rows)if a==header)
    assert rows[h+1][1].startswith('jne')
    positive=int(re.search(r'jne\s+([0-9a-f]+)',rows[h+1][1]).group(1),16)
    body=rows[h:h+2]+[(a,s)for a,s in rows if positive<=a<=rows[-1][0]]
    entry['positive_loop']=dict(header=hex(header),positive=hex(positive),backedge=hex(rows[-1][0]),metrics=metrics(body))
   detail['functions'].append(entry)
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
for case,roles in report['cases'].items():
 print(case,'text',roles['baseline']['text_bytes'],roles['predicate']['text_bytes'])
 for a,b in zip(roles['baseline']['functions'],roles['predicate']['functions']):
  print(a['decoded'],'bytes',a['symbol_bytes'],b['symbol_bytes'],'frame',a['frame_reservation'],b['frame_reservation'],'metrics',a['metrics'],b['metrics'])
  if 'positive_loop'in a:print('LOOP',a['positive_loop'],b['positive_loop'])
