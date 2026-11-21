#!/usr/bin/env python3
import json,hashlib,math,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=ROOT/'research/phase198/loops'
BUILD=ROOT/'selfhost/build/phase198'
def read(p):return json.loads(p.read_text())
def pin(p):return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def gm(xs):return math.exp(sum(math.log(x)for x in xs)/len(xs))
reports=[read(BUILD/f'loops-runtime0{i}/report.json')for i in [3,4]]
machine=read(OUT/'emission-evidence02/report.json')
for r in reports:
 assert r['complete'] and not r.get('error') and not r.get('changedInputs')
 assert r['positionBalanced'] and r['rounds']==4 and r['reference']=='baseline'
rows=[]
for m in machine['rows']:
 case=m['case'];sessions=[]
 for report in reports:
  c=next(c for c in report['cases']if c['id']==case);s=c['summary']
  assert s['admitted'] and len(c['samples'])==8 and all(x['correct']and not x['lowResolution']for x in c['samples'])
  sessions.append({'ratio':s['ratios']['loops'],'stats':s['stats'],'dispersionRoles':[role for role,st in s['stats'].items()if(st['maximumMs']-st['minimumMs'])/st['medianMs']>0.05]})
 rows.append({'case':case,'sessions':sessions,'geometricRatio':gm([s['ratio']for s in sessions]),'objectIdentical':m['objectIdentical'],'loop':m['loop']})
result={'complete':True,'baseline':'Phase197 combined, fresh Phase198 N1 ordinary objects','rows':rows,'allFourGeometricRatio':gm([r['geometricRatio']for r in rows]),'developmentGeometricRatio':gm([r['geometricRatio']for r in rows if r['case']in ['editdist','local-fold']]),'inputs':[pin(BUILD/f'loops-runtime0{i}/report.json')for i in [3,4]]+[pin(OUT/'emission-evidence02/report.json')],'scope':'Two balanced four-round finite screens. Per-role calibration, original complete value/count oracles, all cases/dispersion retained. Does not establish compiler speed, native reproduction, full-suite improvement or a correctness theorem.'}
p=OUT/'runtime-summary02.json';assert not p.exists();p.write_text(json.dumps(result,indent=2)+'\n')
lines=['# Recurrence residency screen','','Candidate / Phase197-combined runtime; lower is faster.','','| Case | Session1 | Session2 | Geometric ratio |','| --- | ---: | ---: | ---: |']
for r in rows:lines.append('| '+r['case']+' | '+' | '.join(f"{s['ratio']:.4f}"for s in r['sessions'])+f" | {r['geometricRatio']:.4f} |")
lines+=['',f"Development geometric ratio: {result['developmentGeometricRatio']:.4f}. All four cases: {result['allFourGeometricRatio']:.4f}.",'',result['scope'],'','Dispersion flags (>5% range/median):']
for r in rows:
 for i,s in enumerate(r['sessions']):
  if s['dispersionRoles']:lines.append(f"- {r['case']}, session{i+1}: {', '.join(s['dispersionRoles'])}")
(OUT/'runtime-summary02.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({'rows':[(r['case'],[s['ratio']for s in r['sessions']])for r in rows],'developmentGeometricRatio':result['developmentGeometricRatio'],'allFourGeometricRatio':result['allFourGeometricRatio']}))
