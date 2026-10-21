"""Summarize frozen Phase123 screens and actual active-loop disassembly."""
import argparse,hashlib,json,math,re,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
r=dict(complete=True,inputs=[pin(__file__)],screens=[],hotLoops=[],controls=[])
for name in ['predicate-screen01','rle-screen02','transfer-screen02','scaled-screen04','ablation04']:
 file=ROOT/'selfhost/build/phase123'/name/'report.json';s=read(file);assert s['complete'] and all(x['correct'] for x in s['rows']);r['inputs'].append(pin(file));rows=[]
 for case in dict.fromkeys(x['name'] for x in s['rows']):
  roles=dict.fromkeys(x['role'] for x in s['rows'] if x['name']==case);samples={role:[x['elapsedMs'] for x in s['rows'] if x['name']==case and x['role']==role] for role in roles};medians={role:statistics.median(xs) for role,xs in samples.items()}
  row=dict(name=case,samplesMs=samples,mediansMs=medians,candidateOverParent=medians['candidate']/medians['baseline'],candidateOverUpstream=medians['candidate']/medians['upstream'])
  if 'predicate' in medians:row['candidateOverPredicate']=medians['candidate']/medians['predicate']
  rows.append(row)
 r['screens'].append(dict(name=name,observations=len(s['rows']),cases=rows))
for report,role,start,end in [('scaled-machine04','baseline',0x408490,0x408582),('predicate-machine01','candidate',0x4082f0,0x4083a4),('scaled-machine04','candidate',0x4082f0,0x408390)]:
 file=ROOT/'selfhost/build/phase123'/report/'report.json';s=read(file);assert s['complete'];row=next(x for x in s['rows'] if x['role']==role and x['decoded'].startswith('p113d'));assert pin(row['assembly']['file'])==row['assembly'];text=Path(row['assembly']['file']).read_text()
 ins=[(int(addr,16),op,arg) for addr,op,arg in re.findall(r'^\s*([0-9a-f]+):\s+([a-z][a-z0-9]*)\s*(.*?)$',text,re.M) if start<=int(addr,16)<end]
 assert ins and ins[0][0]==start and ins[-1][1].startswith('jmp') and hex(start)[2:] in ins[-1][2]
 r['inputs']+=[pin(file),row['assembly']];r['hotLoops'].append(dict(report=report,role=role,function=row['decoded'],start=hex(start),endExclusive=hex(end),instructions=len(ins),calls=sum(op.startswith('call') for _,op,_ in ins),stackMemoryOperands=sum(bool(re.search(r'\(%r(?:sp|bp)\)',arg)) for _,_,arg in ins),scaled4MemoryOperands=sum(bool(re.search(r'\([^)]*,4\)',arg)) for _,_,arg in ins)))
for name in ['final-predicate-controls04','address-controls04']:
 file=ROOT/'selfhost/build/phase123'/name/'report.json';s=read(file);assert s['complete'];r['inputs'].append(pin(file));r['controls'].append(dict(name=name,report=pin(file),**{k:s[k] for k in ['independentPairs','verifierAndAdmission','arithmeticChecks','addressChecks'] if k in s}))
r['scope']='Frozen short screens and longer ablation, complete oracles. RLE variants change source and are only ceilings. Static hot loops use explicit half-open address intervals verified to close with a back edge; they are not dynamic instruction counts. No aggregate full45/native compiler claim.'
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,hotLoops=r['hotLoops'])))
