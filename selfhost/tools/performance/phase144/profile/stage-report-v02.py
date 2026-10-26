#!/usr/bin/env python3
"""Offline exact-output/ELF/stage join; preserve measured clocks and sample bins."""
import argparse,collections,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
import attribute

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['plan','run','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();need(not a.out.exists(),'Fresh output receipt required')
 result=dict(kind='phase144-exact-stage-profile',complete=False,targetsRun=False,inputs=[pin(__file__),pin(a.plan),pin(a.run)])
 try:
  plan=read(a.plan);run=read(a.run)
  need(plan['complete'] and plan['kind']=='phase144-sampled-stage-plan','Unknown stage plan')
  for p in all_pins(plan):verify(p)
  need(run['complete'] and run['passed'] and not run['changedInputs'] and len(run['rows'])==1,'One successful immutable exact-output capture required')
  need(pin(a.plan) in run['inputs'],'Stage plan not authenticated by actual capture')
  row=run['rows'][0];need(row['correct'] and row['mode']=='sample' and row['diagnosticRuntime'] and row['timingKind']=='diagnostic','Diagnostic sampled row required')
  for key in ['profile','analysis','contexts','callers','stdout','stderr']:verify(row[key])
  sidepath=Path(row['profile']['file']+'.stages.json');side=read(sidepath);result['inputs'].append(pin(sidepath))
  document,events=attribute.attribute(row['analysis']['file'],row['callers']['file'],ROOT/'selfhost/build/phase127/libc-unwind01/table.json',row['contexts']['file'],plan['ownerMap']['file'])
  need(document['pairing']['verified'],'Capture/source/binary pairing unverified')
  binary=row['command'][0];_,linked,owner_binding=attribute.bind_owners(read(verify(plan['ownerMap'])),binary)
  need(owner_binding['elfType']==2,'Exact non-PIE dispatch addresses required')
  markers=plan['markers'];rows=side['rows'];need(side['schema']=='bend-sampled-dispatch-stages-v1' and side['sequentialOnly'] and side['expectedSegments']==plan['expectedSegments'],'Wrong stage schema/object')
  need(len(rows)==len(markers),'Stage count mismatch')
  result.update(requestExact=True,observedMarkers=rows,quality=document['quality'])
  for want,have in zip(markers,rows):
   need(have['label']==want['label'] and have['fid']==want['fid'] and have['firstEntryBoundary']==want['firstEntryBoundary'],'Marker identity changed')
   need(int(have['address'],16)==linked[want['fid']]['elfAddress'],'Marker address differs from actual object')
   need(have['entries']>=1 if want['firstEntryBoundary'] else have['entries']==1,'Missing/repeated unique stage')
  need(side['complete'] and side['observedInOrder']==len(markers) and not side['badOrderOrDuplicate'] and not side['clockError'],'Stage sequence invalid; no timing admitted')
  for key,finish in [('wallNs','finishWallNs'),('cpuNs','finishCpuNs'),('threadNs','finishThreadNs'),('sampleOrdinal','finishSampleOrdinal')]:
   values=[r[key] for r in rows]+[side[finish]];need(all(type(v) is int and v>=0 for v in values) and all(x<=y for x,y in zip(values,values[1:])),'Nonmonotonic stage evidence')
  need(side['finishSampleOrdinal']<=len(events),'Stage sample ordinal exceeds authenticated capture')
  optional=side['conditionalFinalVerifier'];want=plan['conditionalFinalVerifier']
  need(optional['fid']==want['fid'] and int(optional['address'],16)==linked[want['fid']]['elfAddress'],'Conditional final-verifier identity differs')
  need(type(optional['entries']) is int and optional['entries']>=0 and len(optional['observations'])==min(8,optional['entries']) and optional['truncated']==(optional['entries']>8),'Conditional invocation evidence incomplete')
  result['conditionalFinalVerifier']=optional
  if optional['entries']==1:
   split=optional['observations'][0];left=next(r for r in rows if r['label']=='p128raw_br_scanned');right=next(r for r in rows if r['label']=='p134w_plan')
   need(all(left[k]<=split[k]<=right[k] for k in ['wallNs','cpuNs','threadNs','sampleOrdinal']),'Conditional final verifier outside selected admission interval')
   result['conditionalFinalVerificationInterval']=dict(begin='p126bp_complete',end='p134w_plan',wallSeconds=(right['wallNs']-split['wallNs'])/1e9,processCpuSeconds=(right['cpuNs']-split['cpuNs'])/1e9,threadCpuSeconds=(right['threadNs']-split['threadNs'])/1e9,sampleStartInclusive=split['sampleOrdinal'],sampleEndExclusive=right['sampleOrdinal'],scope='One actual conditional final-verifier entry to writer; includes return/continuation overhead. Nested in observer-composition interval, do not add.')
  else:result['conditionalFinalVerificationInterval']=None
  quality=document['quality'];qualified=all(quality.get(k) for k in ['zero_loss','handler_intact','main_thread_shutdown','thread_lifecycle_complete','near_complete_process_cpu_coverage','delivery_plausible'])
  intervals=[]
  finish=dict(label='milestone-atexit',wallNs=side['finishWallNs'],cpuNs=side['finishCpuNs'],threadNs=side['finishThreadNs'],sampleOrdinal=side['finishSampleOrdinal'])
  interval_rows=rows+[finish]
  interval_labels=plan['intervalLabels']+['render/output and teardown until milestone exit']
  for label,left,right in zip(interval_labels,interval_rows,interval_rows[1:]):
   first,last=left['sampleOrdinal'],right['sampleOrdinal'];start=min(first+1,last);stop=max(start,last-1)
   samples=events[start:stop];owners=collections.Counter();leaves=collections.Counter()
   for event in samples:
    context=event.get('dispatchContext') or {};owners[context.get('loweredOwner')]+=1
    leaf=event['leaf'];leaves[leaf.get('decoded') or leaf.get('symbol')]+=1
   n=len(samples)
   def top(counts):return [dict(name=k,samples=v,fractionOfAllIntervalSamples=v/n) for k,v in counts.most_common(12)] if n else []
   intervals.append(dict(label=label,begin=left['label'],end=right['label'],wallSeconds=(right['wallNs']-left['wallNs'])/1e9,processCpuSeconds=(right['cpuNs']-left['cpuNs'])/1e9,threadCpuSeconds=(right['threadNs']-left['threadNs'])/1e9,sampleStartInclusive=start,sampleEndExclusive=stop,samples=n,boundarySamplesExcluded=(last-first)-n,quantitativeProfileAdmitted=qualified and n>=500,topActiveOwners=top(owners),topPhysicalLeaves=top(leaves)))
  result.update(complete=True,stageAttributionValid=True,ownerBinding=owner_binding,intervals=intervals,diagnosticWallSeconds=row['wallSeconds'],samples=len(events),pairing=document['pairing'],limits=['Stage clocks include continuations/reference management between exact entries; no causal speedup bound follows.','Only first entry to render drain is a boundary; subsequent drain calls are counted and intentionally permitted.','One sample at each end of an interval is excluded because clock/ordinal observations are not atomic with signal delivery.','Short or quality-failed stage histograms remain descriptive, not quantitative CPU estimates. No independent samples or confidence interval assumed.','After first render drain, render/output/final cleanup remain a combined tail, not exclusive render cost.','Diagnostic timing includes profiler overhead and must not replace the clean baseline.'])
 except BaseException as error:result['error']=repr(error)
 save(a.out,result);print(json.dumps({k:result.get(k) for k in ['complete','requestExact','stageAttributionValid','samples','error']}));return 0 if result['complete'] else 1
if __name__=='__main__':sys.exit(main())
