"""Bounded native A/B session supervisor; transports bytes, never compiler semantics.

Run under the shared guard. Each output directory is fresh; producer, inputs and
runtime are pinned before launch. Experimental only: does not select a compiler.
"""
import argparse, hashlib, importlib.util, json, os, re, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1<<20):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def require(ok,msg):
 if not ok:raise ValueError(msg)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for x in ['image','a','b','out','runtime']:ap.add_argument('--'+x,type=Path,required=True)
 ap.add_argument('--hint',type=int,required=True);ap.add_argument('--owner',required=True)
 ap.add_argument('--mode',choices=['warm','cold'],default='warm');ap.add_argument('--seconds',type=int,default=1200)
 ap.add_argument('--expected-a',type=Path);ap.add_argument('--expected-b',type=Path)
 args=ap.parse_args();out=args.out.resolve()
 require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 output required')
 selection=ROOT/'implementation/phase137/candidate.json';sel=json.loads(selection.read_text());require(sel['nativeQualified'],'Qualified seed context required')
 spec=importlib.util.spec_from_file_location('p130request',ROOT/'selfhost/tools/performance/phase130/native-request.py');n=importlib.util.module_from_spec(spec);spec.loader.exec_module(n)
 carrier,base,pins=n.carrier_inputs(Path(sel['preferredCarrierReceipt']['file']))
 image_receipt=args.image.resolve().parent/'report.json';linked=json.loads(image_receipt.read_text())
 require(linked['complete'] and linked['binary']==pin(args.image) and linked['runtime']==pin(args.runtime),'Actual image/runtime link required')
 inputs=[pin(__file__),pin(selection),pin(args.image),pin(image_receipt),pin(args.a),pin(args.b),pin(args.runtime),*pins]
 for p in [args.expected_a,args.expected_b]:
  if p:inputs.append(pin(p))
 require(args.hint>=0 and args.hint<=2**32-1,'Bounded edit offset required')
 require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')),'No ambient profiling')
 out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
 command=[str(args.image.resolve()),'--threads','1','--gpu','off','--','phase140-session',str(args.a.resolve()),str(args.b.resolve()),base['file'],carrier['carrier']['file'],carrier['stamp'],str(out/'a.frames'),str(out/'b.frames'),args.mode,str(args.hint),args.owner]
 report=dict(kind='phase140-native-session',complete=False,experimental=True,selected=False,inputs=inputs,command=command,mode=args.mode,sourceA=pin(args.a),sourceB=pin(args.b),logicalSourcePath=str(args.a.resolve()),timingScope='Process wall/CPU includes Base/source IO, A acquisition, B request, both closed output frames and teardown. Native stage clocks exclude host materialization and machine build, reported separately.',scope='No native qualification or installed selection change. In-process typed caches; source/runtime fixed. A and B use the same logical source path, actual bytes pinned separately.')
 def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 save();start=time.monotonic()
 try:
  with (out/'stdout.log').open('xb') as so,(out/'stderr.log').open('xb') as se:
   child=subprocess.Popen(command,cwd=ROOT,stdout=so,stderr=se)
   try:child.wait(timeout=args.seconds)
   except subprocess.TimeoutExpired:
    child.kill();child.wait();raise
  report.update(nativeSeconds=time.monotonic()-start,exitCode=child.returncode,stdout=pin(out/'stdout.log'),stderr=pin(out/'stderr.log'))
  require(child.returncode==0,'Native compiler failed: '+str(child.returncode));require((out/'stderr.log').stat().st_size==0,'Unexpected native diagnostics')
  report['frames']=[pin(out/'a.frames'),pin(out/'b.frames')]
  report['nativeCompleted']=True
  stage_re=re.compile(r'phase140 stages ([AB]) frontend_ms=(\d+) raw_ms=(\d+) backend_ms=(\d+) registry_ms=(\d+) render_close_ms=(\d+) total_ms=(\d+)')
  report['stages']={};report['stats']={}
  for line in (out/'stdout.log').read_text().splitlines():
   line=line.rstrip();m=stage_re.fullmatch(line)
   if m:
    label=m[1];require(label not in report['stages'],'Duplicate stage row')
    report['stages'][label]=dict(zip(['frontendMs','rawMs','backendMs','registryMs','renderCloseMs','totalMs'],map(int,m.groups()[1:])))
   elif line.startswith('phase140 prepare_ms '):report['prepareMs']=int(line.split()[-1])
   elif re.fullmatch(r'phase140 [AB](?: \d+)*',line):report['stats'][line.split()[1]]=list(map(int,line.split()[2:]))
   else:raise ValueError('Unexpected native stdout: '+line)
  require(set(report['stages'])==set(report['stats'])=={'A','B'},'Incomplete stage/count report')
  transport_path=ROOT/'selfhost/tools/performance/phase140/session/transport.py'
  spec=importlib.util.spec_from_file_location('p140transport',transport_path);transport=importlib.util.module_from_spec(spec);spec.loader.exec_module(transport)
  inputs.append(pin(transport_path));report['transport']=[]
  session=hashlib.sha256(str(out).encode()).hexdigest();previous=None
  for label,src,expected in [('a',args.a,args.expected_a),('b',args.b,args.expected_b)]:
   context=dict(kind='phase140-transport-context',protocol=2,session=session,producer=pin(args.image),runtime=pin(args.runtime),source=pin(src),policy=dict(kind='phase140-exact-output-v1',logicalSourcePath=str(args.a.resolve())),inputs=inputs)
   cp=out/(label+'-context.json');cp.write_text(json.dumps(context,indent=2)+'\n')
   before=time.monotonic()
   with (out/(label+'.frames')).open('rb') as stream:
    receipt=transport.decode(stream,out/(label+'-transport'),cp,pin(cp)['sha256'],previous,pin(previous)['sha256'] if previous else None,pin(expected)['sha256'] if expected else None)
   report['transport'].append(dict(label=label,seconds=time.monotonic()-before,receipt=pin(out/(label+'-transport')/'report.json'),payload=receipt['payload'],exactOracle=bool(expected),freshBytes=receipt['freshBytes'],reusedBytes=receipt['reusedBytes'],reusedPieces=receipt['reusedPieces'],pieces=receipt['pieces']))
   previous=out/(label+'-transport')/'report.json'
  report['independentProductsExact']=bool(args.expected_a and args.expected_b)
  report['complete']=True
 except BaseException as e:report['error']=repr(e)
 finally:
  report['totalSeconds']=time.monotonic()-start
  report['changedInputs']=[p['file'] for p in inputs if pin(p['file'])!=p]
  if report['changedInputs']:report['complete']=False
  save()
 print(json.dumps({k:report.get(k) for k in ['complete','nativeSeconds','error']}))
 return 0 if report['complete'] else 1
if __name__=='__main__':sys.exit(main())
