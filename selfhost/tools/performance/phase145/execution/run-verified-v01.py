#!/usr/bin/env python3
"""Root-owned, fresh-process comparison; no compiler transformations."""
import argparse,importlib.util,json,math,os,signal,statistics,subprocess,sys,threading,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p145native',ROOT/'selfhost/tools/performance/phase130/native-request.py');N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
pin,verify,require=N.pin,N.verify,N.require
def child(command,out,timeout):
 before=time.monotonic();p=None;finished=threading.Event();expired=threading.Event()
 with (out/'stdout').open('xb') as so,(out/'stderr').open('xb') as se:
  p=subprocess.Popen(command,cwd=ROOT,stdout=so,stderr=se,start_new_session=True)
  def stop():
   if not finished.is_set():
    expired.set()
    try:os.killpg(p.pid,signal.SIGKILL)
    except ProcessLookupError:pass
  timer=threading.Timer(timeout,stop);timer.daemon=True;timer.start()
  try:_,status,usage=os.wait4(p.pid,0);p.returncode=os.waitstatus_to_exitcode(status)
  finally:finished.set();timer.cancel()
 seconds=time.monotonic()-before
 row=dict(command=command,seconds=seconds,userSeconds=usage.ru_utime,systemSeconds=usage.ru_stime,cpuSeconds=usage.ru_utime+usage.ru_stime,peakRssBytes=usage.ru_maxrss*1024,exitCode=p.returncode,timedOut=expired.is_set(),stdout=pin(out/'stdout'),stderr=pin(out/'stderr'))
 (out/'process.json').write_text(json.dumps(row,indent=2)+'\n');require(p.returncode==0 and not expired.is_set(),'Child failed or exceeded deadline');require(row['stderr']['bytes']==0,'Unexpected child stderr');return row
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--mode',choices=['clean','counts'],default='counts');ap.add_argument('--case',action='append');ap.add_argument('--rounds',type=int,default=2);ap.add_argument('--child-seconds',type=int,default=90);a=ap.parse_args()
 out=a.out.resolve();require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh Phase145 output');require(1<=a.rounds<=4 and 1<=a.child_seconds<=180,'Bounded rounds/deadline');require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'Ambient instrumentation forbidden')
 require(a.mode=='counts','Fingerprint runner is diagnostic-only');plan=json.loads(a.plan.read_text());require(plan['complete'] and plan['kind']=='phase145-same-source-execution-plan','Wrong plan');inputs=[pin(a.plan),pin(__file__),pin(HERE/'hosted-v01.mjs'),plan['diagnosticApi'],*plan['inputs']]
 require(pin(__file__) in plan['inputs'] and pin(HERE/'hosted-v01.mjs') in plan['inputs'],'Methods changed after freeze')
 for p in inputs:verify(p)
 cases=[c for c in plan['cases'] if not a.case or c['name'] in a.case];require(cases and (not a.case or {x['name'] for x in cases}==set(a.case)),'Unknown selected case')
 out.mkdir(parents=True);report=dict(kind='phase145-verified-input-diagnostic',complete=False,mode=a.mode,inputs=inputs,observations=[],scope=plan['scope'],boundaries=plan['boundaries'],inheritedAffinity=sorted(os.sched_getaffinity(0)));start=time.monotonic()
 def save():
  report['totalSeconds']=time.monotonic()-start;(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 save()
 try:
  for case in cases:
   for repeat in range(a.rounds if a.mode=='clean' else 1):
    roles=(['js','native'] if repeat%2==0 else ['native','js']) if a.mode=='clean' else ['js-counts']
    for role in roles:
     work=out/f'{case["name"]}-{repeat:02d}-{role}';work.mkdir();product=work/'program.ssa'
     if role=='native':command=[plan['native']['file'],'--threads','1','--gpu','off','--','phase111',case['source']['file'],plan['base']['file'],'cache',plan['carrier']['file'],plan['stamp']]
     else:
      config=dict(api=plan['diagnosticApi'] if a.mode=='counts' else plan['api'],source=case['source'],base=plan['base'],carrier=plan['carrier'],stamp=plan['stamp'],output=str(product),observation=str(work/'observation.json'),instrumented=a.mode=='counts')
      (work/'input.json').write_text(json.dumps(config,indent=2)+'\n');command=[plan['bun']['file'],plan['verifiedDriver']['file'],str(work/'input.json')]
     row=child(command,work,a.child_seconds)
     if role=='native':os.link(work/'stdout',product)
     else:
      require(row['stdout']['bytes']==0,'Unexpected JS stdout');obs=json.loads((work/'observation.json').read_text());require(obs['complete'],'Hosted observation failed');row['hostedObservation']=pin(work/'observation.json');row['stages']=obs['timings'];witness=work/'observation.json.verified-inputs.json';w=json.loads(witness.read_text());require(w['records'] and all(r.get('completed') and all(x['unchanged'] and x['sameIdentity'] for x in r['arguments']) for r in w['records']),'Incomplete verifier witnesses');row['verifierInputs']=pin(witness)
     t=time.monotonic();require(N.same_bytes(product,Path(case['expectedQbe']['file'])),'Complete QBE differs from frozen ordinary oracle');row.update(case=case['name'],role=role,round=repeat,product=pin(product),byteExact=True,oracleComparisonSeconds=time.monotonic()-t);report['observations'].append(row);save()
  if a.mode=='clean':
   report['cases']=[]
   for c in cases:
    rows=[r for r in report['observations'] if r['case']==c['name']];medians={role:statistics.median(r['seconds'] for r in rows if r['role']==role) for role in ['js','native']};ratios=[next(r['seconds'] for r in rows if r['round']==i and r['role']=='native')/next(r['seconds'] for r in rows if r['round']==i and r['role']=='js') for i in range(a.rounds)]
    report['cases'].append(dict(name=c['name'],medians=medians,nativeOverJsGeometric=math.exp(sum(map(math.log,ratios))/len(ratios)),pairedRatios=ratios))
  for p in inputs:verify(p)
  report['complete']=True
 except BaseException as e:report['error']=repr(e)
 finally:save()
 print(json.dumps({k:report.get(k) for k in ['complete','totalSeconds','cases','error']}));return 0 if report['complete'] else 1
if __name__=='__main__':sys.exit(main())
