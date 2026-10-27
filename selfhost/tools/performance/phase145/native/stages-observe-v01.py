#!/usr/bin/env python3
"""Root-only three short exact-QBE requests with existing native stage clocks."""
import argparse,json,os,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,execute
from analyze import parse_capture,capture_quality
from stages_v1 import normalize,check_observations,CLOCKS
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert os.sched_getaffinity(0)=={3} and not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145')
assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS'])
m=json.loads(a.plan.read_text());b=json.loads(a.build.read_text());assert m['complete'] and b['complete'] and b['plan']==pin(a.plan)
binary=pin(a.plan.resolve().parent/'program');assert binary in b['products'];spec=json.loads(verify(m['stageSpec']).read_text());owners=json.loads(verify(spec['ownerMap']).read_text());nm=Path('/usr/bin/nm').resolve()
inputs=[pin(__file__),pin(PROF/'run.py'),pin(PROF/'analyze.py'),pin(PROF/'stages_v1.py'),pin(a.plan),pin(a.build),binary,pin(nm),*m['inputs'],*m['outputs']]
for x in inputs:verify(x)
pn=subprocess.run([str(nm),'-n','--defined-only',binary['file']],capture_output=True,timeout=10);assert pn.returncode==0 and not pn.stderr
symbols={x[2]:int(x[0],16) for line in pn.stdout.decode().splitlines() if len(x:=line.split())==3};linked={x['fid']:dict(elfAddress=symbols[x['symbol']]) for x in owners['fids']}
out.mkdir();r=dict(kind='phase145-native-stage-observations-v1',complete=False,inputs=inputs,rows=[],compilerSource=m['compilerSource'],programObject=m['programObject'],stageSpec=m['stageSpec'],scope=m['scope'],quantitativeSampleDistributionClaimed=False);save(out/'report.json',r);start=time.monotonic()
try:
 for case in m['cases']:
  d=out/case['name'];sample=d/'samples.txt';env=dict(os.environ,LD_PRELOAD=m['sampler']['file'],BEND_SAMPLE_OUT=str(sample),BEND_SAMPLE_PERIOD_US='8000',BEND_PROFILE_COUNTERS='0')
  command=[binary['file'],'--threads','1','--gpu','off','--','phase111',case['source']['file'],m['base']['file'],'cache',m['carrier']['file'],m['stamp']]
  q=execute(command,d,str(ROOT),45,env);q.update(name=case['name'],source=case['source'],expected=case['expected']);r['rows'].append(q);save(out/'report.json',r)
  assert q['returncode']==0 and not q['timedOut'] and q['stderr']['bytes']==0 and all(q['stdout'][k]==case['expected'][k] for k in ['bytes','sha256']);q['exactQbe']=True
  header,maps,pcs=parse_capture(sample);assert Path(header['exe']).resolve()==Path(binary['file']) and header['period_us']==8000;q['sampleHeader']=header;q['sampleQuality']=capture_quality(header);q['sampleFile']=pin(sample)
  sidepath=Path(str(sample)+'.stages-v1.json');side=normalize(json.loads(sidepath.read_text()),spec,m['stageSpec']['sha256']);observed=check_observations(spec,owners,side,linked,header['samples']);q['stageSidecar']=pin(sidepath);q['intervals']=[]
  for interval in spec['intervals']:
   def endpoint(label):
    if label=='@exit':return side['finish']
    item=observed[label];return item['observations'][0] if item['entries']==1 or item['multiplicity']=='first' else None
   left,right=endpoint(interval['begin']),endpoint(interval['end']);row=dict(interval,available=False);q['intervals'].append(row)
   if left is None or right is None:row['reason']='Optional marker absent or repeated; no single interval inferred';continue
   assert all(left[k]<=right[k] for k in CLOCKS)
   delivered=right['sampleOrdinal']-left['sampleOrdinal'];row.update(available=True,wallSeconds=(right['wallNs']-left['wallNs'])/1e9,processCpuSeconds=(right['cpuNs']-left['cpuNs'])/1e9,threadCpuSeconds=(right['threadNs']-left['threadNs'])/1e9,deliveredSampleOrdinals=delivered,quantitativeSampleDistributionClaimed=False,limitation='Direct diagnostic boundary clocks; no sample distribution or clean timing claim. Below500 samples is descriptive only.')
  q['markers']=[dict(label=x['label'],entries=x['entries'],multiplicity=x['multiplicity']) for x in side['markers']];save(out/'report.json',r)
 for x in inputs:verify(x)
 r['complete']=True
except BaseException as error:r['error']=repr(error);raise
finally:r['seconds']=time.monotonic()-start;save(out/'report.json',r)
print(json.dumps(dict(complete=True,report=pin(out/'report.json'),rows=[dict(name=x['name'],samples=x['sampleHeader']['samples'],intervals=x['intervals']) for x in r['rows']])))
