"""Bind batch capture to generic profiler, then report conservative stage windows.

Offline only. Active dispatch owners are not complete caller stacks. Stage
coordinates use sample ordinals and bounded unknown wall/CPU gaps, not timestamps.
"""
import argparse,collections,json,math,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save
import analyze
from attribute import attribute

def read(p):return json.loads(Path(p).read_text())
def ranked(counts,n):return [dict(name=k,samples=v,fraction=v/n if n else None) for k,v in counts.most_common(40)]
def summarize(events):
 leaves=collections.Counter();owners=collections.Counter();drops=collections.Counter();families=collections.Counter()
 for e in events:
  leaf=e['leaf'].get('decoded')or e['leaf'].get('symbol')or '[unknown]'
  owner=e.get('dispatchContext',{}).get('loweredOwner')or '[unknown]'
  leaves[leaf]+=1;owners[owner]+=1
  if leaf in ['term_drop','span_fade']:drops[owner]+=1
  family=next((name for name,prefixes in [('loader',['p140pl_']),('owner-annotation',['p140of_','p140o_','p140oe_']),('verifier',['p140v_']),('optimizer',['p134u_','p134v_']),('late',['p140l_','p140le_']),('final-gate',['p126bp_']),('registry-render',['p140g_','p140gm_','p140r_','p134e_'])] if any(owner.startswith(p) for p in prefixes)),'other-or-unknown')
  families[family]+=1
 return dict(samples=len(events),physicalLeaves=ranked(leaves,len(events)),activeOwners=ranked(owners,len(events)),activeOwnerFamilies=ranked(families,len(events)),reclamationByActiveOwner=ranked(drops,len(events)))

def main():
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['profile-plan','capture','out']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();out=a.out.resolve();assert not out.exists()
 plan=read(a.profile_plan);r=read(a.capture)
 assert plan['complete'] and r['complete'] and r['diagnostic'] and r['activeContextOnly'] and not r['changedInputs']
 assert r['independentProductsExact'] and r['exitCode']==0 and r['stderr']['bytes']==0
 assert r['ownerMap']==plan['ownerMap'] and r['runtime']==plan['diagnosticRuntime'] and r['cleanRuntimeAbiIdentity']==plan['runtime']
 for item in r['inputs']:verify(item)
 for item in [r['samples'],r['contexts'],r['stdout'],r['stderr'],plan['ownerMap']]:verify(item)
 for j in r['jobs']:
  assert j['exactOracle'];verify(j['product']);assert pin(j['expected'])['sha256']==j['product']['sha256']
 binary=next(x for x in r['inputs'] if x['file']==r['command'][0]);verify(binary)
 out.mkdir(parents=True);(out/'capture').mkdir()
 analysis=analyze.analyze_capture(r['samples']['file'],binary['file'])
 analysis_path=out/'capture/analysis.json';save(analysis_path,analysis)
 # This explicit adapter certifies exactly the checks already completed by
 # the batch supervisor. It does not impersonate a clean generic timing run.
 adapter=dict(schema='bend-native-profile-run-v1',kind='phase142-authenticated-batch-capture-adapter',complete=True,passed=True,changedInputs=[],
  inputs=[pin(__file__),pin(a.profile_plan),pin(a.capture),*r['inputs'],r['samples'],r['contexts'],binary],
  rows=[dict(workload='full-compiler-cold-plus-warm-product-edit',variant='phase141-n2-context',mode='sample',round=0,correct=True,diagnosticRuntime=True,
    periodUs=r['periodUs'],analysis=pin(analysis_path),profile=r['samples'],contexts=r['contexts'],stdout=r['stdout'],stderr=r['stderr'],
    wallSeconds=analysis['header']['wall_ns']/1e9,cpuSeconds=analysis['header']['process_cpu_ns']/1e9,peakRssKiB=None)],
  scope='Adapter for generic sample/context identity pairing. Correctness comes from actual native exit/stdout protocol and two independent complete QBE products; no fixed timing-string oracle, clean timing, native qualification or new speed ratio.')
 save(out/'report.json',adapter)
 joined,events=attribute(analysis_path,None,None,Path(r['contexts']['file']),Path(plan['ownerMap']['file']))
 assert joined['pairing']['verified'] and joined['pairing']['correct'] and joined['contextHeader']['context_available']
 save(out/'attribution.json',joined)
 h=analysis['header'];q=analysis['quality'];wall=h['wall_ns']/1e9;cpu=h['main_thread_cpu_ns']/1e9
 known=(r['prepareMs']+sum(j['ioMs']+j['stages']['totalMs'] for j in r['jobs']))/1000
 assert wall+0.02>=known and wall+0.02>=cpu
 gaps=dict(captureWallSeconds=wall,captureMainCpuSeconds=cpu,knownStageAndIoSeconds=known,
  unknownWallSeconds=max(0,wall-known),wallMinusCpuSeconds=max(0,wall-cpu),marginSeconds=1.0)
 windows=[];prefix=r['prepareMs']/1000;period=h['period_us']/1e6
 usable=bool(q['usable_for_process_cpu_attribution'])
 for job_index,j in enumerate(r['jobs']):
  prefix+=j['ioMs']/1000;whole_start=prefix
  stages=j['stages'];assert sum(stages[k] for k in ['frontendMs','rawMs','backendMs','registryMs','renderCloseMs'])==stages['totalMs']
  for stage in ['frontendMs','rawMs','backendMs','registryMs','renderCloseMs']:
   duration=stages[stage]/1000;lo=prefix+gaps['unknownWallSeconds']+1;hi=prefix+duration-gaps['wallMinusCpuSeconds']-1
   begin=max(0,math.ceil(lo/period));end=min(len(events),math.floor(hi/period))
   row=dict(job=j['name'],jobIndex=job_index,mode=j['mode'],stage=stage,reportedStageSeconds=duration,
    knownWallInterval=[prefix,prefix+duration],conservativeCpuOrdinalInterval=[lo,hi],sampleStart=begin,sampleEndExclusive=end,
    coordinatesAvailable=usable and end>begin)
   if row['coordinatesAvailable']:row.update(summarize(events[begin:end]))
   windows.append(row);prefix+=duration
  assert abs(prefix-whole_start-stages['totalMs']/1000)<0.0001
 result=dict(kind='phase142-warm-context-analysis-v1',complete=True,targetsRun=False,
  inputs=[pin(__file__),pin(a.profile_plan),pin(a.capture),pin(analysis_path),pin(out/'report.json'),pin(out/'attribution.json'),plan['ownerMap'],pin(PROF/'analyze.py'),pin(PROF/'attribute.py')],
  quality=q,contextPairing=joined['pairing'],ownerBinding=joined['ownerBinding'],bounds=gaps,stages=windows,wholeCapture=summarize(events),
  cleanObservations=0,speedRatio=None,physicalCallerCapture=False,
  scope='Conservative interiors of approximate stage windows. Unknown time and unsampled/unsupported ownership stay explicit. Active owner/physical leaf distributions are separate observations, not exclusive semantic caller costs or allocation origins. No exact timestamps or inclusive Bend call stack.')
 save(out/'summary.json',result)
 print(json.dumps(dict(complete=True,qualityUsable=usable,samples=len(events),bounds=gaps,warmStages=[dict(stage=x['stage'],samples=x.get('samples'),owners=x.get('activeOwners',[])[:5]) for x in windows if x['mode']=='warm'])))

if __name__=='__main__':main()
