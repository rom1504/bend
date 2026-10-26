#!/usr/bin/env python3
"""Root-guarded alternating native predicate ceiling, independent checksum oracle."""
import argparse,hashlib,importlib.util,json,os,statistics,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--plan',required=True,type=Path);ap.add_argument('--out',required=True,type=Path);a=ap.parse_args();out=a.out.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144');assert sorted(os.sched_getaffinity(0))==[3]
 assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS'])
 p=json.loads(a.plan.read_text());assert p['complete'];oracle=ROOT/'selfhost/tools/performance/phase131/identity/timing-oracle.py'
 spec=importlib.util.spec_from_file_location('oracle',oracle);O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
 inputs=[pin(__file__),pin(a.plan),pin(oracle),*p['inputs']];variants=p['variants']
 for mode,v in variants.items():
  build=json.loads(Path(v['build']).read_text());api=json.loads(Path(v['api']).read_text());controls=json.loads(Path(v['controls']).read_text())
  assert build['complete'] and build['outputExact'] and build['binary']==pin(v['binary']) and build['source']==v['source']==pin(v['source']['file'])
  assert api['complete'] and api['checked'] and v['source'] in api['inputs'];assert controls['complete'] and controls['caseCount']==336 and controls['queryCount']==11088
  inputs.extend([pin(v['build']),pin(v['api']),pin(v['controls']),build['binary'],v['source']])
 for x in inputs:assert pin(x['file'])==x
 out.mkdir(parents=True);r=dict(kind='phase144-native-predicate-ceiling-timing',complete=False,inputs=inputs,calibration=[],rows=[],scope='Same generated-program proxy and independent checksum, original runtime, alternating orders, IO.now milliseconds and whole child time. Not full compiler gain.')
 def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 def run(label,mode,repeats,size):
  cmd=[variants[mode]['binary'],'--threads','1','--gpu','off','--',str(repeats),'2',str(size),'0'];so=out/(label+'.stdout');se=out/(label+'.stderr');t=time.monotonic()
  with so.open('xb') as f,se.open('xb') as e:child=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=e,timeout=8)
  elapsed=time.monotonic()-t;observed=O.parse_timed(so.read_bytes(),se.read_bytes(),child.returncode,repeats,2,size)
  return dict(mode=mode,repeats=repeats,size=size,command=cmd,wallSeconds=elapsed,stdout=pin(so),stderr=pin(se),**observed)
 save()
 try:
  for size in [64,256]:
   repeats=8
   for step in range(4):
    row=run(f'cal-{size}-{step}','original',repeats,size);r['calibration'].append(row);save()
    if row['elapsedMilliseconds']>=100 or repeats>=65536:break
    repeats=min(65536,max(repeats+1,int(repeats*250/max(1,row['elapsedMilliseconds']))))
   for turn in range(5):
    calls=[]
    for mode in (['original','positive'] if turn%2==0 else ['positive','original']):calls.append(run(f'{size}-{turn}-{mode}',mode,repeats,size))
    by={x['mode']:x for x in calls};denom=by['original']['runtimeSeconds'];r['rows'].append(dict(size=size,round=turn,repeats=repeats,calls=calls,ratio=by['positive']['runtimeSeconds']/denom if denom else None,wallRatio=by['positive']['wallSeconds']/by['original']['wallSeconds']));save()
  r['sizes']={str(n):dict(medianPairedRatio=statistics.median(x['ratio'] for x in r['rows'] if x['size']==n),minimumElapsedMilliseconds=min(c['elapsedMilliseconds'] for x in r['rows'] if x['size']==n for c in x['calls'])) for n in [64,256]}
  for x in inputs:assert pin(x['file'])==x
  r['complete']=True
 except BaseException as e:r['error']=repr(e);raise
 finally:save()
 print(json.dumps({k:r.get(k) for k in ['complete','sizes','error']}))
if __name__=='__main__':main()
