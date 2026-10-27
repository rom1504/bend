#!/usr/bin/env python3
"""Offline interpretation of bounded upstream work observations; no targets."""
import argparse,hashlib,json
from pathlib import Path

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 assert not a.out.exists();plan=json.loads(a.plan.read_text());inputs=[pin(__file__),pin(a.plan)];rows=[]
 for case in plan['cases']:
  row=dict(name=case['name'],mode=case['mode'],source=case['source'],variants={});rows.append(row)
  for variant in ['original','clean','counted']:
   path=Path(plan['out'])/(case['name']+'-'+variant)/'report.json'
   if not path.exists():row['variants'][variant]=dict(status='missing');continue
   r=json.loads(path.read_text());inputs.append(pin(path));assert r['fixture']==case and r['variant']==variant
   for item in r['inputs']:assert pin(item['file'])==item
   row['variants'][variant]=dict(status='passed'if r['complete']else'failed',timings=r['timings'],seconds=r['seconds'],peakRssBytes=r['peakRssBytes'],error=r.get('error'),loaded=r.get('loaded'),checked=r.get('checked'),product=r.get('product'),exactOriginalC=r.get('exactOriginalC'))
   if variant=='counted' and r['complete']:
    row['counts']=r['counts'];row['observedInternalStages']=r['stages']
    starts=r['counts'].get('emit:comp.fixedpoint_start',{}).get('values',[]);ends=r['counts'].get('emit:comp.fixedpoint_end',{}).get('values',[])
    if starts:
     assert len(ends)==1
     states=[*starts,ends[0]];deltas=[[b-a for a,b in zip(left,right)]for left,right in zip(states,states[1:])]
     assert all(x>=0 for d in deltas for x in d)
     row['emissionFixedPoint']=dict(rounds=len(starts),fields=['owned','hot','static'],initial=starts[0],final=ends[0],newFactsByRound=deltas,finalRoundStable=sum(deltas[-1])==0)
  if all(r['status']=='passed'for r in row['variants'].values()):
   original=row['variants']['original'];clean=row['variants']['clean'];counted=row['variants']['counted']
   phases=['load']+(['check','emit']if case['mode']=='compile'else[])
   row['compilerActionSeconds']={label:sum(role['timings'][k]for k in phases)for label,role in row['variants'].items()}
   row['diagnosticOverCleanRatio']=row['compilerActionSeconds']['counted']/row['compilerActionSeconds']['clean']
   assert original['loaded']==clean['loaded']==counted['loaded']
   if case['mode']=='compile':assert clean['exactOriginalC']and counted['exactOriginalC'];assert original['checked']==clean['checked']==counted['checked']
 report=dict(kind='phase145-upstream-operation-summary',complete=all(all(r['status']=='passed'for r in row['variants'].values())for row in rows),targetsRun=False,inputs=inputs,rows=rows,
  limits=['Each variant is one fresh process, not repeated paired performance evidence. Imports/output digest outside compiler action subtotal. Original and transpiled clean clocks are separate.',
   'Upstream loads and checks source Base per process; selfhost prepared-Base decoding is a different amount of work. Do not divide these totals into a fair same-work throughput claim.',
   'Entry counts, input-object identity revisits and WNF focus dispatch counts differ. There is no universal total-node-visit number, allocation-byte count, or direct equivalence to selfhost helper calls.',
   'Erasure is fused into checker result construction; no independent erasure-clock claim. C emission includes planning, repeated fact rounds and rendering, and differs from QBE emission.',
   'Counted variants add wrappers, WeakSet probes, clock calls and extra memo lookup; their elapsed times are diagnostic overhead, not production performance.',
   'Loaded/checked summaries compare names/kinds/event order and erased-body availability, not arbitrary checked-body theorem equivalence. Complete emitted C is independently byte-compared against original.',
   'Compiler prefix1024 is parse-only and not established dependency-closed. Positive index slice is real compiler code but not full-compiler scalability evidence.'])
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=report['complete'],out=str(a.out))))
if __name__=='__main__':main()
