#!/usr/bin/env python3
"""Reduce frozen Phase88 runs; never run a compiler or select only passing jobs."""
import hashlib, json, statistics, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase88'
def read(p): return json.loads(p.read_text())
def pin(p): return dict(file=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def median(rows,key): return statistics.median(r[key] for r in rows)
paired,repeat,broad=[read(RAW/p) for p in ['paired01/report.json','repeat01/report.json','broad-qualified.json']]
assert all(p['complete'] and p['passed'] for p in [paired,repeat,broad])
medians=[]
for case in paired['cases']:
 roles={}
 for role in paired['roles']:
  rows=[r for r in paired['rows'] if r['case']==case and r['role']==role]
  assert len(rows)==2 and all(r['exact'] and r['job']['pass_'] for r in rows)
  roles[role]=dict(requestMs=statistics.median(r['requestMs'][0] for r in rows),processWallSeconds=median(rows,'processWallSeconds'),peakRssBytes=max(r['peakRssBytes'] for r in rows))
  if 'base_prepare_ms' in rows[0]['metrics']: roles[role]['basePrepareMs']=statistics.median(int(r['metrics']['base_prepare_ms']) for r in rows)
 medians.append(dict(case=case,roles=roles,liveRequestReduction=1-roles['native02']['requestMs']/roles['native01']['requestMs'],cachedWholeVsTypescript=roles['cached02']['processWallSeconds']/roles['typescript']['processWallSeconds']))
repeated=[]
for case in repeat['cases']:
 rows=[r for r in repeat['rows'] if r['case']==case]
 assert len(rows)==3 and all(r['exact'] and len(r['outputs'])==5 for r in rows)
 repeated.append(dict(case=case,requestMs={r['role']:r['requestMs'] for r in rows}))
controls={}
for name,file,flag in [('observer','observer-controls.json','pass'),('strings','strings-controls.json','passed'),('cacheProducts','cache-products01/report.json','complete'),('baseProducts','base-products05/report.json','complete'),('auth','auth-controls01/report.json','passed'),('launcher','launcher-controls03/report.json','passed'),('jsDevelopment','js-development01/validation-001/report.json','pass')]:
 data=read(RAW/file);assert data[flag],name
 controls[name]=dict(passed=True,evidence=pin(RAW/file))
profileOutputs=[pin(p) for p in sorted(RAW.glob('ownership02-map.*.c'))]
assert len(profileOutputs)==5 and all(p['sha256']=='01710772937dfa4736557a53823226f2f0652b005334073d72139d5bc5e6e67c' for p in profileOutputs)
# Only external resource guards have process.json; nested package timings are not summed.
processes=list(RAW.rglob('process.json'))
launchDirs=[]
for p in (ROOT/'selfhost/build/native/requests').glob('*/report.json'):
 data=read(p)
 if '/phase88/' in data.get('method',{}).get('file',''):
  launchDirs.append(p.parent)
  if (p.parent/'guard/process.json').exists(): processes.append(p.parent/'guard/process.json')
guards=[]
for p in sorted(set(processes)):
 data=read(p)
 if 'wallSeconds' not in data: continue
 guards.append(dict(evidence=pin(p),returncode=data.get('returncode'),complete=data.get('complete'),wallSeconds=data['wallSeconds'],peakRssBytes=data.get('peakTreeRssBytes',0),reason=data.get('reason')))
manifest=read(ROOT/'selfhost/src/compiler.json')
current=previous=0;changed=[]
for name in manifest['modules']:
 p=ROOT/'selfhost'/name
 n=len(p.read_text().splitlines());old=subprocess.check_output(['git','show','66e6c21:selfhost/'+name],cwd=ROOT).decode();b=len(old.splitlines())
 current+=n;previous+=b
 if p.read_text()!=old: changed.append(dict(file='selfhost/'+name,beforeLines=b,afterLines=n,delta=n-b))
report=dict(complete=True,kind='phase88-native-compiler-qualification',upstream=manifest['upstream'],nativeImage=pin(RAW/'compiler-native02'),installedJsRelease='Phase82 unchanged',nativeStage='Upstream-built native B1, not native self-produced B2',
 medians=medians,repeated=repeated,broad=dict(points=broad['points'],originalSources=broad['originalSources'],exactC=45,exactStdout=45,fixtureFailuresPreserved=len(broad['preservedFailures']),evidence=pin(RAW/'broad-qualified.json')),
 controls=controls,profileOutputs=profileOutputs,sourceCensus=dict(modules=len(manifest['modules']),beforePhysicalLines=previous,afterPhysicalLines=current,delta=current-previous,changed=changed),
 resourceUse=dict(guardJobs=len(guards),guardedWallSeconds=sum(g['wallSeconds'] for g in guards),peakTreeRssBytes=max(g['peakRssBytes'] for g in guards),nonzeroOrIncomplete=[g for g in guards if g['returncode']!=0 or not g['complete']],jobs=guards),
 scope='Linux x86_64, one native thread, pinned Base, one source and three audited scalar effects. Compilation-to-C clocks, not compiled-program execution speed. Cached native startup and ordinary reference startup use different prepared-Base mechanisms. Timings exclude Python authentication/guard startup, Clang and generated program execution. Two cold rounds; one five-request sequence. No universal/native-B2/full-conformance claim.',
 remaining=['Map cold whole process 1.76x TypeScript and warm fifth request about6.46x','General imports/effects and native B2 reproduction unqualified','Decoder and admission are experimental and bound to exact canonical paths'])
(ROOT/'implementation/phase88/summary.json').write_text(json.dumps(report,indent=2)+'\n')
(RAW/'native-launcher-logs.json').write_text(json.dumps([str(p.relative_to(ROOT)) for p in launchDirs],indent=2)+'\n')
print(json.dumps(dict(complete=True,guardJobs=len(guards),guardSeconds=report['resourceUse']['guardedWallSeconds'],peakGiB=report['resourceUse']['peakTreeRssBytes']/1024**3,census=report['sourceCensus'])))
