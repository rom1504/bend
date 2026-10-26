#!/usr/bin/env python3
"""Prepare root-owned profile gates. This program launches no compiler or target."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
OUT=ROOT/'selfhost/build/phase144/native-profile-plan01'
PROFILE=ROOT/'selfhost/build/phase144/native-profile-source02/compiler.bend'
API=ROOT/'selfhost/build/phase111/p144-native-profile-api01/report.json'
PRODUCER=ROOT/'selfhost/build/phase134/p144-integrated-n1-01/program'
IMAGE=ROOT/'selfhost/build/phase134/p144-native-profile-n1-01/program'
GUARD=ROOT/'selfhost/tools/performance/phase111/guard.py'
CARRIER=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
RUNTIME=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o'
HOST=ROOT/'selfhost/tools/performance/phase144/hosted-request-v01.py'
PIPE=ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py'
NATIVE=ROOT/'selfhost/tools/performance/phase130/native-request.py'
SESSION=ROOT/'selfhost/tools/performance/phase140/session/run-native-v01.py'
BATCH=ROOT/'selfhost/tools/performance/phase140/session/run-batch-v02.py'
REFERENCE=ROOT/'selfhost/build/phase134/reference03.json'
BATCH_PLAN=ROOT/'selfhost/build/phase140/batch-smoke-plan01.json'
PREVIOUS_SMOKE=ROOT/'selfhost/build/phase140/p141-incremental-smoke01/report.json'

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def write(name,v):(OUT/name).write_text(json.dumps(v,indent=2)+'\n')
def guard(name,command,seconds,rss=3072):
 return ['/usr/bin/python3','-B',str(GUARD),'--out',str(ROOT/'selfhost/build/phase144'/('native-profile-'+name+'-guard01')),'--seconds',str(seconds),'--rss-mib',str(rss),'--available-mib','16384','--file-mib','256','--cpu','3','--',*map(str,command)]
def job(name,command,seconds):return dict(name=name,command=guard(name,command,seconds),seconds=seconds+10)
def main():
 assert not OUT.exists()
 api=json.loads(API.read_text());profile=pin(PROFILE)
 assert api.get('complete') and api.get('checked') and api.get('status')==0
 assert profile in api['inputs']
 assert profile['sha256']=='24fcb6f429140ddca54e7be23319114d6a148403e8d36195a061719af8d44a4c'
 assert json.loads(PRODUCER.with_name('report.json').read_text())['complete']
 manifest=json.loads(PROFILE.with_name('manifest.json').read_text())
 retained=json.loads(Path(manifest['retainedDeclarations']['file']).read_text())
 names={x['name'] for x in retained}
 interface=['main','p111_native_args','p111_native_request','p140nb_start','p140n_args','p140n_start']
 assert all(n in names for n in interface)
 refs=json.loads(REFERENCE.read_text());assert refs['complete']
 cases=[next(x for x in refs['cases'] if x['name']==name) for name in ['lexer','coverage-closures-256','coverage-map-churn-128']]
 batch=json.loads(BATCH_PLAN.read_text());prior=json.loads(PREVIOUS_SMOKE.read_text())
 assert prior['complete'] and prior['independentProductsExact']
 assert [x['name'] for x in batch['jobs']]==['seed','edit','revert','edit-again']
 for current,old in zip(batch['jobs'],prior['jobs']):
  for k in ('name','source','hint','owner','mode','expected'):assert current[k]==old[k]
  assert old['exactOracle']
 inputs=[pin(p) for p in [__file__,PROFILE,PROFILE.with_name('manifest.json'),API,PRODUCER,PRODUCER.with_name('report.json'),GUARD,CARRIER,RUNTIME,HOST,PIPE,NATIVE,SESSION,BATCH,REFERENCE,BATCH_PLAN,PREVIOUS_SMOKE]]
 for c in cases:
  for key in ('source','expectedQbe'):
   assert pin(c[key]['file'])==c[key];inputs.append(c[key])
 for j in batch['jobs']:
  inputs.extend([pin(j['source']),pin(j['expected'])])
 OUT.mkdir(parents=True)
 write('batch-plan.json',batch)
 hosted=[];native=[]
 for c in cases:
  name=c['name']
  hosted.append(job('hosted-'+name,['/usr/bin/python3','-B',HOST,'--api-report',API,'--compiler-source',PROFILE,'--source',c['source']['file'],'--carrier-receipt',CARRIER,'--expected-qbe',c['expectedQbe']['file'],'--out',ROOT/'selfhost/build/phase144'/('native-profile-hosted-'+name+'01'),'--seconds','60'],75))
  native.append(job('ordinary-'+name,['/usr/bin/python3','-B',NATIVE,'--image',IMAGE,'--source',c['source']['file'],'--carrier-receipt',CARRIER,'--expected-qbe',c['expectedQbe']['file'],'--out',ROOT/'selfhost/build/phase130'/('p144-native-profile-'+name+'01'),'--seconds','40'],50))
 acquisition=[job('acquire',['/usr/bin/python3','-B',PIPE,'--image',PRODUCER,'--source',PROFILE,'--carrier-receipt',CARRIER,'--runtime',RUNTIME,'--out',IMAGE.parent,'--retain-ir','--seconds','700'],720)]
 a,b=batch['jobs'][:2]
 native.append(job('session',['/usr/bin/python3','-B',SESSION,'--image',IMAGE,'--a',a['source'],'--b',b['source'],'--hint',str(a['hint']),'--owner',a['owner'],'--mode','warm','--expected-a',a['expected'],'--expected-b',b['expected'],'--out',ROOT/'selfhost/build/phase140/p144-native-profile-session01','--seconds','100'],110))
 native.append(job('batch',['/usr/bin/python3','-B',BATCH,'--image',IMAGE,'--plan',OUT/'batch-plan.json','--out',ROOT/'selfhost/build/phase140/p144-native-profile-batch01','--seconds','150'],160))
 common=dict(complete=True,preparedOnly=True,targetsRun=False,inputs=inputs)
 write('hosted-jobs.json',dict(**common,jobs=hosted,precondition='Checked exact native profile API; execute before acquisition.'))
 write('acquire-jobs.json',dict(**common,jobs=acquisition,precondition='All three hosted byte-exact gates must pass first; root decides acquisition.',expectedImage=str(IMAGE),qualificationClaim=False))
 write('native-smoke-jobs.json',dict(**common,jobs=native,precondition='Acquisition report complete; native image pinned by each existing runner.',qualificationClaim='Bounded ordinary/session/batch smoke only, not full language or incremental qualification.'))
 write('report.json',dict(**common,interfaceRetained=interface,profile=profile,producer=pin(PRODUCER),runtime=pin(RUNTIME),futureImage=str(IMAGE),plans=[pin(OUT/n) for n in ['hosted-jobs.json','acquire-jobs.json','native-smoke-jobs.json','batch-plan.json']],scope='Preparation only. Existing exact oracles, carrier, runtime and validators. Original full compiler/API remains untouched. No same-source speed claim.'))
 print(json.dumps(dict(complete=True,targetsRun=False,out=str(OUT),hostedJobs=len(hosted),acquisitionJobs=1,nativeSmokeJobs=len(native))))
if __name__=='__main__':main()
