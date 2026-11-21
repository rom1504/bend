#!/usr/bin/env python3
"""Separate source/acquisition/harness costs from fresh program timing ratios."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B
def checked(pin):
 B.verify(pin);return Path(pin['file'])
p=argparse.ArgumentParser();p.add_argument('--run',required=True,type=Path);p.add_argument('--acquisition-plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--summary',type=Path);a=p.parse_args();assert not a.out.exists()
summary_path=a.summary or a.run/'summary.json';s=B.read(summary_path);recovered=bool(s.get('completeObservedEvidence'));assert s.get('complete') or recovered;plan=B.read(checked(s['plan']));np=B.read(a.acquisition_plan);native=B.read(checked(plan['nativeManifest']));raw=B.read(checked(s['report']));prep=B.read(checked(s['preparation']))
assert native['roles'][plan['nativeRole']]['compilerSource']==np['source'];B.verify(np['source']);B.verify(np['imageReceipt'])
base=B.read(checked(plan['baselinePreparation']));native_dir=Path(plan['nativeManifest']['file']).parent;native_report=B.read(native_dir/'report.json')
assert native_report['complete'] and native_report['programManifest']==plan['nativeManifest']
changed=[];emission=0;link=0
for row in native_report['rows']:
 build=B.read(checked(row['buildReceipt']));assert build['complete']
 emission+=build['emissionSeconds'];link+=sum(job['seconds'] for job in build['jobs'] if job['label']=='link')
 if any(build['object'][k]!=base['cases'][row['id']]['object'][k] for k in ('bytes','sha256')):changed.append(row['id'])
counts={stage:sum(len(case[stage]) for case in raw['cases']) for stage in ('pilots','samples')};process={stage:sum(row['process']['seconds'] for case in raw['cases'] for row in case[stage]) for stage in counts}
guards={}
for label,directory in [('native45',native_dir),('broad',a.run.resolve())]:
 path=directory.with_name(directory.name+'-guard')/'process.json';g=B.read(path);assert (g['complete'] and g['returncode']==0) or (recovered and label=='broad' and g['stoppedFor']=='disk-budget');guards[label]=dict(receipt=B.pin(path),wallSeconds=g['wallSeconds'],guardSucceeded=g['complete'],stoppedFor=g.get('stoppedFor'),peakRunAllocatedBytes=g['peakRunAllocatedBytes'])
image=B.read(np['imageReceipt']['file']);result=dict(kind='phase200-physical-campaign-cost-summary',complete=True,targetsRun=False,method=B.pin(__file__),strictSummary=B.pin(summary_path),recoveredAfterFailedGuard=recovered,acquisitionPlan=B.pin(a.acquisition_plan),source=np['source'],sourceCheck=np['sourceCheck'],image=np['image'],imageReceipt=np['imageReceipt'],native45Seconds=native_report['seconds'],nativeEmissionSeconds=emission,nativeLinkSeconds=link,imageReportedWallSeconds=image.get('wallSeconds'),objectsChangedFromPhase199=changed,objectsObserved=len(native_report['rows']),runtimeCounts=counts,runtimeProcessSeconds=process,runtimeHarnessWallSeconds=raw.get('wallSeconds'),runtimeOtherHarnessSeconds=raw['wallSeconds']-sum(process.values()) if 'wallSeconds' in raw else None,physicalGuards=guards,candidate=s['subsets']['all']['roles']['candidate'],warnings=s['warnings'],scope='Single actual source/acquisition observations. Native emission/link, complete acquisition, and harness wall seconds are separate quantities; role performance ratios come only from fresh normalized program intervals. No historical C/incumbent timing substitution and no compiler-throughput significance claim.')
B.save(a.out,result,fresh=True);print(json.dumps(dict(out=str(a.out),changedObjects=len(changed),counts=counts,physicalGuards=guards)))
