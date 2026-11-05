#!/usr/bin/env python3
"""Collect immutable receipts and calculate scoped Phase167 comparisons offline."""
import json,hashlib,statistics,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'selfhost/build/phase167';OUT=ROOT/'implementation/phase167'
def read(p):return json.loads(p.read_text())
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def write(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2)+'\n')
def build(name):
 p=RUN/name/'report.json';r=read(p);assert r['complete'];m=read(p.parent/'machine/report.json');assert m['complete']
 return dict(receipt=pin(p),role=r['role'],completeSeconds=r['sourceToExecutableSeconds'],baseSeconds=r['stages']['baseSeconds'],frontendSeconds=r['stages']['frontendSeconds'],backendAndRenderSeconds=r['stages']['lowerVerifySeconds']+r['stages']['writeRenderSeconds'],machineJobs=[dict(label=x['label'],seconds=x['seconds'])for x in m['jobs']],functions=r['functions'],ir=r['ir'],binary=r['binary'])
rows=[build('clean01/'+role)for role in ['baseline','plain-live','single','single-region']]
runtime=read(RUN/'clean-runtime01/report.json');assert runtime['complete'];rt={x['role']:x['median'] for x in runtime['rows']}
for row in rows:row.update(runtimeMedianSeconds=rt[row['role']],buildSpeedup=rows[0]['completeSeconds']/row['completeSeconds'],runtimeRatio=rt[row['role']]/rt['baseline'])
result=dict(phase=167,qualifiedCompilerChanged=False,productionChanged=False,fullNativeSelfBuildRun=False,scope='Fresh-process upstream-checked Bend compiler hosted by pinned Bun; same real 39333-byte verifier source, authenticated prepared Base, QBE/runtime/toolchain. Complete source-to-executable slice, not native N1/N2 compiler speed or 250-second self-build.',cleanBuilds=rows,runtime=pin(RUN/'clean-runtime01/report.json'),newBuildObservationsPerTreatment=1,runtimePairs=4)
if (RUN/'observer-baseline01/report.json').exists() and read(RUN/'observer-baseline01/report.json').get('complete'):
 a,b=build('observer-baseline01'),build('observer-build01');rr=read(RUN/'observer-runtime02/report.json');tt={x['role']:x['median']for x in rr['rows']};assert a['ir']['sha256']==rows[0]['ir']['sha256'];result['observerComparison']=dict(baseline=a,candidate=b,buildSpeedup=a['completeSeconds']/b['completeSeconds'],runtimeRatio=tt['observers']/tt['baseline'],runtime=pin(RUN/'observer-runtime02/report.json'),runtimeRows=rr['rows'],runtimeBaselineQbeIdentical=True)
result['admissionCensus']=pin(ROOT/'experiments/phase167/admission-obstructions.json')
result['demandCensus']=pin(RUN/'inspect01/report.json')
result['observerCensus']=pin(RUN/'observer-inspect01/report.json')
result['guards']=[]
for p in sorted(RUN.glob('*-guard/process.json')):
 r=read(p);assert 'finished'in r;result['guards'].append(dict(receipt=pin(p),complete=r['complete'],seconds=r['wallSeconds'],peakRssBytes=r['peakTreeRssBytes'],minimumFreeBytes=r['minimumDiskFreeBytes']))
result['executionLaneSeconds']=sum(x['seconds']for x in result['guards']);result['failedGuards']=sum(not x['complete']for x in result['guards']);result['sourceExperimentLines']=sum(len(p.read_text().splitlines())for p in (ROOT/'selfhost/tests/phase167').glob('*.bend'))
result['costLimits']=['Guard seconds exclude agent reasoning, editing, source-only extraction and retention; quota/cost telemetry unavailable.','Native Phase161 diagnostic CPU intervals are not clean wall-time components of these hosted pilots.','No claim of whole-build 2x,5x or10x; no broad runtime or conformance promotion.']
write(OUT/'metrics.json',result)
receipts=[]
for p in sorted(RUN.rglob('*')):
 if p.is_file() and (p.name in ['report.json','process.json','retention.json'] or (p.name=='stderr' and p.parent.name.startswith(('api','observer-api','closure-api','why-api','verifier-oracle')))):
  dest=OUT/'evidence'/p.relative_to(RUN);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);receipts.append(pin(dest))
write(OUT/'evidence-index.json',dict(method=pin(Path(__file__)),files=receipts))
print(json.dumps(dict(builds=[(r['role'],round(r['completeSeconds'],3),round(r['runtimeRatio'],3))for r in rows],observer=result.get('observerComparison',{}).get('buildSpeedup'),guards=len(result['guards']),seconds=result['executionLaneSeconds'],receipts=len(receipts))))
