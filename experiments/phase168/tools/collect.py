#!/usr/bin/env python3
"""Offline receipts and scoped comparisons; never runs a compiler or program."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
RUN=ROOT/'selfhost/build/phase168'; OUT=ROOT/'implementation/phase168'
def read(p): return json.loads(p.read_text())
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def write(p,x):
 p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2)+'\n')
result=dict(phase=168,productionChanged=False,qualifiedCompiler='Phase152',
 fullNativeSelfBuildRun=False,builds=[],runtimes=[],guards=[],sources=[],
 scope='Fresh-process checked Bend compiler hosted on pinned Bun, authenticated prepared Base, complete source-to-QBE-to-native slice builds. Not native N1/N2 compilation or a full self-build gain.')
for p in sorted(RUN.glob('*/report.json')):
 r=read(p)
 if 'sourceToExecutableSeconds' in r:
  assert r['complete'];m=read(p.parent/'machine/report.json');assert m['complete']
  result['builds'].append(dict(name=p.parent.name,receipt=pin(p),role=r['role'],
   inputSource=r['inputs'][2],apiReceipt=r['inputs'][1],
   completeSeconds=r['sourceToExecutableSeconds'],stages=r['stages'],
   backendAndRenderSeconds=r['stages']['lowerVerifySeconds']+r['stages']['writeRenderSeconds'],
   machineJobs=[dict(label=x['label'],seconds=x['seconds']) for x in m['jobs']],
   functions=r['functions'],ir=r['ir'],binary=r['binary']))
 if 'rows' in r and 'samples' in r:
  assert r['complete'];baseline=next((x['median'] for x in r['rows'] if x['role']=='baseline'),None)
  result['runtimes'].append(dict(name=p.parent.name,receipt=pin(p),
   rows=[dict(**x,ratioToBaseline=x['median']/baseline if baseline is not None else None) for x in r['rows']]))
for p in sorted(RUN.glob('source*/manifest.json')):
 r=read(p);assert r['complete'] and r['protectedUnchanged'] and not r['replacements']
 result['sources'].append(dict(receipt=pin(p),source=r['source'],additiveReplacements=r['additiveReplacements']))
for p in sorted(RUN.glob('*-guard/process.json')):
 r=read(p);assert 'finished' in r
 close=ROOT/'selfhost/build-retention'/('phase168-'+p.parent.name.removesuffix('-guard')+'-close')
 assert (close/'report.json').exists(), 'Missing closed-run receipt '+str(close)
 result['guards'].append(dict(receipt=pin(p),complete=r['complete'],seconds=r['wallSeconds'],
  peakRssBytes=r['peakTreeRssBytes'],minimumFreeBytes=r['minimumDiskFreeBytes']))
result['executionLaneSeconds']=sum(x['seconds'] for x in result['guards'])
result['failedGuards']=sum(not x['complete'] for x in result['guards'])
result['experimentalBendLines']=sum(len(p.read_text().splitlines()) for p in (ROOT/'selfhost/tests/phase168').glob('*.bend'))
result['finalComparisons']={}
for label,bname,cname,rname in [('verifier','baseline03','imports01','runtime-final01'),('lookup','lookup-baseline01','lookup-candidate01','runtime-lookup01')]:
 if not (RUN/rname/'report.json').exists(): continue
 b=next(x for x in result['builds'] if x['name']==bname);c=next(x for x in result['builds'] if x['name']==cname)
 assert b['inputSource']==c['inputSource'] and b['apiReceipt']==c['apiReceipt']
 r=next(x for x in result['runtimes'] if x['name']==rname);rr={x['role']:x for x in r['rows']}
 result['finalComparisons'][label]=dict(baseline=bname,candidate=cname,runtime=rname,
  buildSpeedup=b['completeSeconds']/c['completeSeconds'],buildTimeReduction=1-c['completeSeconds']/b['completeSeconds'],
  runtimeRatio=rr['imports']['ratioToBaseline'],sharedSourceAndApi=True)
result['limits']=['Build observations are screening measurements unless explicitly repeated.',
 'Runtime medians belong to their alternating measurement block; inspect drift and raw samples.',
 'Guard wall time excludes reasoning, editing, source extraction and retention; quota telemetry unavailable.',
 'Source checks, structural gates and finite runtime outputs are not a compiler-correctness theorem.']
write(OUT/'metrics.json',result)
receipts=[]
for p in sorted(RUN.rglob('*')):
 if p.is_file() and (p.name in ['report.json','process.json','retention.json','manifest.json','exports.json','base-binding.json'] or (p.name=='stderr' and p.parent.name.startswith('api'))):
  dest=OUT/'evidence'/p.relative_to(RUN);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);receipts.append(pin(dest))
write(OUT/'evidence-index.json',dict(method=pin(Path(__file__)),files=receipts))
print(json.dumps(dict(builds=[(x['name'],x['completeSeconds']) for x in result['builds']],
 guards=len(result['guards']),seconds=result['executionLaneSeconds'],failed=result['failedGuards'])))
