#!/usr/bin/env python3
"""Offline Phase161 measurements. No target execution or promotion."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'implementation/phase161';OUT.mkdir(exist_ok=True)
def read(p):return json.loads((ROOT/p).read_text())
def pin(p):
 p=Path(p);p=p if p.is_absolute() else ROOT/p
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def count(p):
 p=Path(p);p=p if p.is_absolute() else ROOT/p
 b=p.read_bytes();ls=b.splitlines()
 return dict(**pin(p),physicalLines=len(ls),nonblankNoncommentLines=sum(bool(x.strip()) and not x.lstrip().startswith(b'#') for x in ls))
def save(name,value):(OUT/name).write_text(json.dumps(value,indent=2)+'\n')
paths=[Path('selfhost/build/phase158/current')/n for n in ['bendc.bend','check.bend','core.bend','rt/rtjs.bend','rt/rtchan.bend','asm.bend']]
rows=[count(p) for p in paths]
full=read('selfhost/build/phase161/full01/report.json');closure=read('selfhost/build/phase161/closure01/report.json')
assert full['complete'] and closure['complete'] and full['equalToFullCompiler']
r=dict(kind='phase161-source-request-screen',complete=True,method=pin(__file__),inputs=[pin(Path('selfhost/build/phase161')/(k+'01/report.json')) for k in ['full','closure']],sameExecutable=full['image']==closure['image'],sameBase=full['base']==closure['base'],rows=[dict(case=x['case'],source=count(x['source']['file']),wallSeconds=x['process']['wallSeconds'],cpuSeconds=x['process']['cpuSeconds'],peakRssKiB=x['process']['peakRssKiB'],output=x['product'],equalToQualifiedFullQbe=x['equalToFullCompiler']) for x in [full,closure]],timeReduction=1-closure['process']['wallSeconds']/full['process']['wallSeconds'],sourceByteReduction=1-closure['source']['bytes']/full['source']['bytes'],outputByteReduction=1-closure['product']['bytes']/full['product']['bytes'],bendcCurrentModules=rows,bendcModuleTotal={k:sum(x[k] for x in rows) for k in ['bytes','physicalLines','nonblankNoncommentLines']},scope='One clean observation per input, closure then full, same original Phase156 compiler and live Base. Complete compiler request, excluding QBE/assembler/link machine construction. Input source differs; closure output differs and is unqualified. No median, confidence interval, cold-cache guarantee or generated-program speed claim.')
assert r['sameExecutable'] and r['sameBase'];save('source-metrics.json',r)
profiles={}
for role in ['full','closure']:
 p=Path(f'selfhost/build/phase161/profile-{role}01/stages.json')
 if not (ROOT/p).is_file():continue
 d=read(p);capture=read(f'selfhost/build/phase161/profile-{role}01/capture/report.json')
 assert d['complete'] and d['requestExact'] and d['stageAttributionValid']
 profiles[role]=dict(receipt=pin(p),process=capture['rows'][0],quality=d['quality'],markers=[{k:x[k] for k in ['label','multiplicity','entries']} for x in d['markers']],intervals=d['intervals'],scope='Diagnostic same-object prepared-Base request; separate protocol from clean live-Base screen.')
if profiles:
 comparison=[]
 if set(profiles)=={'full','closure'}:
  f={x['label']:x for x in profiles['full']['intervals']};c={x['label']:x for x in profiles['closure']['intervals']}
  assert f.keys()==c.keys()
  for name in f:
   if '(nested)' in name or not(f[name]['available'] and c[name]['available']):continue
   a=f[name]['processCpuSeconds'];b=c[name]['processCpuSeconds']
   comparison.append(dict(label=name,fullCpuSeconds=a,closureCpuSeconds=b,differenceSeconds=a-b))
 save('profile-metrics.json',dict(complete=set(profiles)=={'full','closure'},method=pin(__file__),profiles=profiles,disjointComparison=comparison,scope='Stage clocks include diagnostic overhead and are not clean performance estimates. Sample attribution admitted only per recorded quality; nested final verifier excluded from summed comparison.'))
print(json.dumps(dict(complete=True,cleanTimeReduction=r['timeReduction'],profiles=list(profiles))))
