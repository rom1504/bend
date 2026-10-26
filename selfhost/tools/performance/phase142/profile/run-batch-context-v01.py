"""Diagnostic context-only variant of frozen Phase140 native batch supervision.

Plan JSON: {logical, jobs:[{name, source, hint, owner, mode, expected?}]}.
Paths are resolved and pinned before launch; actual cache decisions stay in Bend.
"""
import argparse, importlib.util, json, os, re, subprocess, sys, time
from pathlib import Path
HERE=Path(__file__).resolve().parents[5]/'selfhost/tools/performance/phase140/session'
spec=importlib.util.spec_from_file_location('pair',HERE/'run-native-v01.py');pair=importlib.util.module_from_spec(spec);spec.loader.exec_module(pair)
pin,require,ROOT=pair.pin,pair.require,pair.ROOT
spec=importlib.util.spec_from_file_location('transport',HERE/'transport-v02.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for x in ['image','plan','out','profile-plan','diagnostic-build']:ap.add_argument('--'+x,type=Path,required=True)
 ap.add_argument('--seconds',type=int,default=1800);ap.add_argument('--sampler-receipt',type=Path);ap.add_argument('--period-us',type=int,default=20000);a=ap.parse_args();out=a.out.resolve()
 require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase142'),'Fresh output required')
 profile=json.loads(a.profile_plan.read_text());built=json.loads(a.diagnostic_build.read_text())
 require(profile.get('complete') and profile.get('targetsRun') is False,'Completed metadata-only profile plan required')
 require(built.get('complete') and built['plan']==profile['relinkPlan'] and len(built['jobs'])==1,'Authenticated diagnostic relink required')
 require(built['jobs'][0]['command']==profile['relinkCommand'] and built['jobs'][0]['returncode']==0 and not built['jobs'][0]['timedOut'],'Diagnostic build differs')
 require(pin(a.image)==built['jobs'][0]['product'] and pin(a.plan)==profile['batchPlan'],'Actual image/workload differs')
 require(a.sampler_receipt and pin(a.sampler_receipt)==profile['samplerReport'],'Pinned context-capable sampler required')
 require(all(pin(p['file'])==p for p in profile['inputs']),'Profile evidence drift')
 plan=json.loads(a.plan.read_text());logical=str(Path(plan['logical']).resolve());jobs=plan['jobs'];require(0<len(jobs)<=64,'Bounded nonempty jobs required')
 selected_path=ROOT/'implementation/phase137/candidate.json';s=json.loads(selected_path.read_text());require(s['nativeQualified'],'Qualified Base/runtime context required')
 spec=importlib.util.spec_from_file_location('p130',ROOT/'selfhost/tools/performance/phase130/native-request.py');n=importlib.util.module_from_spec(spec);spec.loader.exec_module(n)
 carrier,base,oldpins=n.carrier_inputs(Path(s['preferredCarrierReceipt']['file']))
 inputs=[pin(a.profile_plan),pin(a.diagnostic_build),*profile['inputs'],pin(__file__),pin(HERE/'run-native-v01.py'),pin(HERE/'transport-v02.py'),pin(a.plan),pin(a.image),pin(selected_path),s['runtime'],*oldpins]
 for j in jobs:
  j['source']=str(Path(j['source']).resolve());inputs.append(pin(j['source']))
  require(isinstance(j['hint'],int) and 0<=j['hint']<2**32 and j['mode']in['cold','warm'] and j['owner'],'Invalid job')
  if j.get('expected'):j['expected']=str(Path(j['expected']).resolve());inputs.append(pin(j['expected']))
 require(250<=a.period_us<=100000,'Bounded sampling period required')
 sample_receipt=None;sample_pin=None
 if a.sampler_receipt:
  sample_receipt=json.loads(a.sampler_receipt.read_text());require(sample_receipt.get('complete'),'Complete sampler build required')
  sample_pin=sample_receipt['sampler'];require(pin(sample_pin['file'])==sample_pin,'Sampler identity changed');inputs.extend([pin(a.sampler_receipt),sample_pin])
 require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')),'No ambient profiling')
 out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes());lines=[]
 for i,j in enumerate(jobs):
  j['frame']=str(out/f'{i:03}.frames')
  fields=[j['source'],j['frame'],str(j['hint']),j['owner'],j['mode']]
  require(not any('\n'in v or'\r'in v for v in fields),'No record separators in fields');lines.extend(fields)
 jobfile=out/'jobs.txt';jobfile.write_text('\n'.join(lines)+'\n');inputs.append(pin(jobfile))
 command=[str(a.image.resolve()),'--threads','1','--gpu','off','--','phase140-batch',logical,base['file'],carrier['carrier']['file'],carrier['stamp'],str(jobfile),'v1']
 r=dict(kind='phase142-native-batch-context',complete=False,experimental=True,selected=False,diagnostic=bool(sample_pin),sampler=sample_pin,periodUs=a.period_us if sample_pin else None,inputs=inputs,jobs=jobs,command=command,logicalSourcePath=logical,activeContextOnly=True,runtime=profile['diagnosticRuntime'],cleanRuntimeAbiIdentity=profile['runtime'],exactTimestamps=False,ownerMap=profile['ownerMap'],scope='Diagnostic native process and all transport counted separately. Fixed producer/Base/logical source; previous-success cache only. No compiler selection or whole-compiler qualification.')
 def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 save();start=time.monotonic();child_env=dict(os.environ)
 if sample_pin:child_env.update(LD_PRELOAD=sample_pin['file'],BEND_SAMPLE_OUT=str(out/'samples.txt'),BEND_SAMPLE_PERIOD_US=str(a.period_us),BEND_SAMPLE_CONTEXT_OUT=str(out/'contexts.txt'),BEND_PROFILE_COUNTERS='0')
 try:
  with(out/'stdout.log').open('xb')as so,(out/'stderr.log').open('xb')as se:
   child=subprocess.Popen(command,cwd=ROOT,stdout=so,stderr=se,env=child_env)
   try:child.wait(timeout=a.seconds)
   except subprocess.TimeoutExpired:child.kill();child.wait();raise
  r.update(nativeSeconds=time.monotonic()-start,exitCode=child.returncode,stdout=pin(out/'stdout.log'),stderr=pin(out/'stderr.log'))
  require(child.returncode==0 and r['stderr']['bytes']==0,'Native batch failed')
  if sample_pin:
   r['samples']=pin(out/'samples.txt');r['contexts']=pin(out/'contexts.txt');r['timingClaim']='Diagnostic sampling run; excluded from clean speed ratios.'
   context_lines=(out/'contexts.txt').read_text().splitlines()
   require(context_lines[0]=='BEND_DISPATCH_SAMPLES_V1' and context_lines[1]=='context_available\t1' and context_lines[-1]=='END','Authenticated dispatch getter unavailable or incomplete sidecar')
  stages={};stats={};ios={}
  for line in(out/'stdout.log').read_text().splitlines():
   line=line.rstrip();m=re.fullmatch(r'phase140 stages (\d+) frontend_ms=(\d+) raw_ms=(\d+) backend_ms=(\d+) registry_ms=(\d+) render_close_ms=(\d+) total_ms=(\d+)',line)
   if m:
    i=int(m[1]);require(i not in stages,'Duplicate stages');stages[i]=dict(zip(['frontendMs','rawMs','backendMs','registryMs','renderCloseMs','totalMs'],map(int,m.groups()[1:])));continue
   m=re.fullmatch(r'phase140 batch (\d+) io_ms=(\d+) stats=((?:\d+ ?)+)',line)
   if m:i=int(m[1]);require(i not in stats,'Duplicate stats');stats[i]=list(map(int,m[3].split()));ios[i]=int(m[2]);continue
   m=re.fullmatch(r'phase140 batch_prepare_ms (\d+)',line);require(m,'Unexpected stdout: '+line);r['prepareMs']=int(m[1])
  require(set(stages)==set(stats)==set(range(len(jobs))),'Incomplete timings')
  previous=None
  for i,j in enumerate(jobs):
   j.update(stages=stages[i],stats=stats[i],ioMs=ios[i],frames=pin(j['frame']))
   context=dict(kind='phase140-transport-context',protocol=2,session=str(out),producer=pin(a.image),runtime=profile['diagnosticRuntime'],cleanRuntimeAbiIdentity=profile['runtime'],source=pin(j['source']),policy=dict(kind='phase140-exact-output-v1',logicalSourcePath=logical),inputs=inputs)
   cp=out/f'{i:03}-context.json';cp.write_text(json.dumps(context,indent=2)+'\n');before=time.monotonic()
   with Path(j['frame']).open('rb')as stream:
    decoded=T.decode(stream,out/f'{i:03}-transport',cp,pin(cp)['sha256'],previous,pin(previous)['sha256']if previous else None,pin(j['expected'])['sha256']if j.get('expected')else None)
   previous=out/f'{i:03}-transport'/'report.json';j.update(transportSeconds=time.monotonic()-before,transport=pin(previous),product=decoded['payload'],exactOracle=bool(j.get('expected')),reusedBytes=decoded['reusedBytes'],freshBytes=decoded['freshBytes'],reusedPieces=decoded['reusedPieces'],pieces=decoded['pieces']);save()
  r['complete']=True;r['independentProductsExact']=all(j['exactOracle']for j in jobs)
 except BaseException as e:r['error']=repr(e)
 finally:
  r['totalSeconds']=time.monotonic()-start;r['changedInputs']=[p['file']for p in inputs if pin(p['file'])!=p]
  if r['changedInputs']:r['complete']=False
  save()
 print(json.dumps({k:r.get(k)for k in ['complete','nativeSeconds','totalSeconds','error']}));return 0 if r['complete']else 1
if __name__=='__main__':sys.exit(main())
