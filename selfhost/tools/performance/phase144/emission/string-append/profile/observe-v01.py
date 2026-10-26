"""Root-only exact outputs and additive concat event observations; no speed claims."""
import argparse,importlib.util,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];PROF=ROOT/'selfhost/tools/profiler';ORACLE=ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'
spec=importlib.util.spec_from_file_location('frozen_observer',ORACLE);O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser(description=__doc__)
for key in ['plan','build','control','out']:p.add_argument('--'+key,type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144') and os.sched_getaffinity(0)=={3}
assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS','BEND_PROFILE_EVENTS_OUT'])
m=O.read(a.plan);b=O.read(a.build);c=O.read(a.control);assert m['complete'] and m['reverseExact'] and b['complete'] and b['plan']==O.pin(a.plan)
assert c['complete'] and O.pin(a.plan) in c['inputs'] and O.pin(a.build) in c['inputs']
inputs=[O.pin(__file__),O.pin(ORACLE),O.pin(a.plan),O.pin(a.build),O.pin(a.control),*m['inputs'],*m['outputs'],*b['products']]
for x in inputs:O.verify(x)
out.mkdir();r=dict(kind='phase144-concat-diagnostic-events',complete=False,inputs=inputs,cases=[],timingClaim=False,scope=m['scope']);save=lambda:O.save(out/'report.json',r);save()
try:
 for case in m['cases']:
  binary=O.pin(case['binary']);assert binary in b['products'];records=[]
  for enabled in [False,True]:
   stem=case['name']+('-on' if enabled else '-off');event=out/(stem+'.events.json');env=dict(os.environ,BEND_PROFILE_EVENTS_OUT=str(event),BEND_PROFILE_COUNTERS='1' if enabled else '0')
   cmd=[binary['file'],'--threads','1','--gpu','off','--','1','0',*map(str,case['runtimeArgs'])]
   start=time.monotonic();p=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,timeout=30);wall=time.monotonic()-start
   so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(p.stdout);se.write_bytes(p.stderr);elapsed=O.observation(p.stdout,p.stderr,p.returncode,case,wall)
   e=O.read(event);assert e['schema']=='bend-native-dispatch-events-v1' and e['complete'] and not e['counter_overflow'] and e['invalid_context_events']==0 and e['counts_enabled'] is enabled
   names=e['counter_names'];assert len(names)==len(set(names))==23 and names[-7:]==m['addedCounters'];totals={n:0 for n in names}
   for row in e['rows']:
    assert len(row['counts'])==23 and all(type(x)==int and x>=0 for x in row['counts'])
    for n,v in zip(names,row['counts']):totals[n]+=v
    x=dict(zip(names,row['counts']));ends=sum(x[k] for k in m['addedCounters'][2:]);assert x['concat_attempts']==ends
    assert x['concat_nodes_examined']>=ends-x['concat_success_empty']
   if not enabled:assert not e['rows'] and e['counter_bytes']==0 and all(v==0 for v in totals.values())
   else:assert e['counter_bytes']==(e['segment_count']+5)*23*8
   records.append(dict(enabled=enabled,command=cmd,binary=binary,exitCode=p.returncode,stdout=O.pin(so),stderr=O.pin(se),events=O.pin(event),exactOutput=True,diagnosticElapsedMs=elapsed,wallSeconds=wall,totals=totals));save()
  on=records[1]['totals'];attempts=on['concat_attempts'];refusals=sum(on[k] for k in m['addedCounters'][4:])
  r['cases'].append(dict(name=case['name'],source=case['source'],object=case['object'],qbe=case['qbe'],runs=records,attempts=attempts,refusals=refusals,refusalFraction=refusals/attempts if attempts else None,nodesPerAttempt=on['concat_nodes_examined']/attempts if attempts else None,positiveCountersValidated='Branch insertion is source audited; existing16-channel fixture independently checks old channels and added zero channels. No separate positive branch-control fixture or per-allocation attribution claim.'));save()
 for x in inputs:O.verify(x)
 r['complete']=True
except BaseException as error:r['error']=repr(error);raise
finally:save()
print(json.dumps(dict(complete=True,cases=[{k:x[k] for k in ['name','attempts','refusals','refusalFraction','nodesPerAttempt']} for x in r['cases']])))
