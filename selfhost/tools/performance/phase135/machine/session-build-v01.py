#!/usr/bin/env python3
"""Join one native two-revision producer with bounded framed machine builds.
Run under the root process-tree resource guard. No semantic compilation in host.
"""
import argparse,importlib.util,json,os,pathlib,re,signal,subprocess,sys,time
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent

def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
O=load('object_tools',HERE/'objects-v01.py');N=load('request_tools',ROOT/'selfhost/tools/performance/phase130/native-request.py');S=load('process_supervision',ROOT/'selfhost/tools/performance/programs/support.py')
pin,verify=O.pin,O.verify

def parse_stats(path):
 rows={};stages={};prep=None
 for line in path.read_text().splitlines():
  m=re.fullmatch(r'phase134 prepare_ms (\d+)',line)
  if m:
   if prep is not None:raise ValueError('Duplicate preparation time')
   prep=int(m[1]);continue
  m=re.fullmatch(r'phase134 ([AB]) (\d+) (\d+) (\d+) (\d+) (\d+) ms=(\d+)',line)
  if m:
   if m[1]in rows:raise ValueError('Duplicate request timing')
   rows[m[1]]=dict(counts=[int(m[i])for i in range(2,7)],milliseconds=int(m[7]));continue
  m=re.fullmatch(r'phase135 stages ([AB]) frontend_ms=(\d+) lowering_ms=(\d+) optimize_ms=(\d+) render_ms=(\d+)',line)
  if not m or m[1]in stages:raise ValueError('Unknown/duplicate producer stdout: '+line)
  stages[m[1]]=dict(zip(['frontend','lowering','optimize','render'],map(int,m.groups()[1:])))
 if prep is None or set(rows)!={'A','B'}or set(stages)not in(set(),{'A','B'}):raise ValueError('Incomplete producer statistics')
 for key,value in stages.items():
  if sum(value.values())!=rows[key]['milliseconds']:raise ValueError('Stage intervals do not sum to request time')
 return dict(preparationMilliseconds=prep,requests=rows,stages=stages)

def main():
 entered=time.monotonic()
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['image','image-report','a','b','runtime','carrier-receipt','out','cache']:ap.add_argument('--'+n,type=pathlib.Path,required=True)
 ap.add_argument('--expected-a',type=pathlib.Path);ap.add_argument('--expected-b',type=pathlib.Path);ap.add_argument('--mode',choices=['warm','cold'],default='warm');ap.add_argument('--retain-b',action='store_true');ap.add_argument('--seconds',type=float,default=1800)
 a=ap.parse_args();out=a.out.resolve();phase=ROOT/'selfhost/build/phase135'
 if out.exists()or not out.is_relative_to(phase)or not 0<a.seconds<=3600:raise ValueError('Fresh Phase135 output and bounded deadline required')
 if any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')):raise ValueError('Ambient instrumentation must be unset')
 image=pin(a.image);build=json.loads(a.image_report.read_text())
 if not build['complete']or build['binary']!=image or not os.access(a.image,os.X_OK):raise ValueError('Completed exact producer image required')
 carrier,base,carrier_inputs=N.carrier_inputs(a.carrier_receipt.resolve());sources=[pin(a.a),pin(a.b)];runtime=pin(a.runtime);cache=a.cache.resolve()
 if not cache.is_relative_to(phase) or cache.is_relative_to(out) or out.is_relative_to(cache):raise ValueError('Disjoint Phase135 output and immutable cache required')
 methods=[pin(__file__),pin(sys.executable),pin(ROOT/'selfhost/tools/performance/phase125/native/native-emit.py'),pin(HERE/'objects-v01.py'),pin(HERE/'protocol-v01.py'),pin(HERE/'elf-v01.py'),pin(ROOT/'selfhost/tools/performance/phase130/native-request.py'),pin(ROOT/'selfhost/tools/performance/programs/support.py')]
 inputs=[*methods,image,pin(a.image_report),*build['inputs'],*sources,runtime,*carrier_inputs]
 for expected in (a.expected_a,a.expected_b):
  if expected:inputs.append(pin(expected))
 for x in inputs:verify(x)
 out.mkdir(parents=True);pipes=[out/'a.fifo',out/'b.fifo']
 for p in pipes:os.mkfifo(p,0o600)
 command=[image['file'],'--threads','1','--gpu','off','--','phase135-units',sources[0]['file'],sources[1]['file'],base['file'],carrier['carrier']['file'],carrier['stamp'],*[str(p)for p in pipes],a.mode]
 r=dict(kind='phase135-native-framed-machine-session',complete=False,producerExitCode=None,producer=image,sources=sources,runtime=runtime,inputs=inputs,producerCommand=command,machineReports=[],jobs=[],mode=a.mode,retainedBForIndependentCold=a.retain_b,scope='One native producer and serial bounded machine consumers. Complete requires producer success plus both exact current machine reports; no installed selection or full self-host qualification implied. Internal render timings include consumer backpressure; overlapping wall clocks must not be added.')
 start=time.monotonic();r['preflightSeconds']=start-entered;deadline=start+a.seconds;children=[];tracker=S.ExecutionGuard();tracker.active=None
 def persist():r['seconds']=time.monotonic()-start;O.save(out/'report.json',r)
 def stop():
  for child in children:tracker._tree(child.pid)
  tracker._stop()
  for child in children:
   try:child.wait(timeout=5)
   except subprocess.TimeoutExpired:pass
 def interrupted(sig,frame):raise InterruptedError('Session interrupted '+str(sig))
 old={sig:signal.signal(sig,interrupted)for sig in (signal.SIGINT,signal.SIGTERM)}
 persist()
 try:
  with(out/'producer.stdout').open('xb')as po,(out/'producer.stderr').open('xb')as pe:
   r['producerStartedSeconds']=time.monotonic()-start
   producer=subprocess.Popen(command,cwd=ROOT,stdout=po,stderr=pe,start_new_session=True);children.append(producer)
   for i,side in enumerate(['a','b']):
    consumer_out=out/('machine-'+side);expected=[a.expected_a,a.expected_b][i]
    cmd=[sys.executable,'-B',str(HERE/'objects-v01.py'),'--stream',str(pipes[i]),'--out',str(consumer_out),'--cache',str(cache),'--producer',image['file'],'--source',sources[i]['file'],'--runtime',runtime['file'],'--seconds',str(a.seconds)]
    if not cache.exists():cmd+=['--cold']
    if expected:cmd+=['--expected-qbe',str(expected.resolve())]
    if side=='b'and a.retain_b:cmd+=['--retain-units']
    j=dict(side=side,command=cmd,startedSeconds=time.monotonic()-start);r['jobs'].append(j);persist();t=time.monotonic()
    with(out/(side+'.stdout')).open('xb')as so,(out/(side+'.stderr')).open('xb')as se:
     consumer=subprocess.Popen(cmd,cwd=ROOT,stdout=so,stderr=se,start_new_session=True);children.append(consumer)
     while consumer.poll()is None:
      for child in children:tracker._tree(child.pid)
      if time.monotonic()>=deadline:raise TimeoutError('Whole producer/machine session deadline')
      if producer.poll()is not None:r.setdefault('producerExitObservedSeconds',time.monotonic()-start)
      if producer.returncode not in(None,0):raise ValueError('Native producer failed before machine completion')
      time.sleep(.1)
    j.update(exitCode=consumer.returncode,finishedSeconds=time.monotonic()-start,wallSeconds=time.monotonic()-t,stdout=pin(out/(side+'.stdout')),stderr=pin(out/(side+'.stderr')));persist()
    if consumer.returncode:raise ValueError('Machine consumer failed: '+side)
    receipt_path=consumer_out/'report.json';receipt=json.loads(receipt_path.read_text());assert receipt['complete']and receipt['context']['producer']==image and receipt['context']['runtime']==runtime and receipt['source']==sources[i]
    r['machineReports'].append(pin(receipt_path));persist()
   producer.wait(timeout=max(.001,deadline-time.monotonic()));r['producerExitCode']=producer.returncode;r.setdefault('producerExitObservedSeconds',time.monotonic()-start)
  r['producerStdout']=pin(out/'producer.stdout');r['producerStderr']=pin(out/'producer.stderr')
  if r['producerExitCode']!=0 or r['producerStderr']['bytes']:raise ValueError('Native producer failed or diagnosed error')
  r['stats']=parse_stats(out/'producer.stdout')
  if any(r['stats']['requests']['A']['counts'][i]for i in (0,2)):raise ValueError('A unexpectedly reused prior semantic cache')
  if a.mode=='cold'and any(r['stats']['requests']['B']['counts'][i]for i in (0,2)):raise ValueError('Cold B retained semantic cache')
  for x in inputs:verify(x)
  for p in r['machineReports']:verify(p)
  r['complete']=True
 except BaseException as exc:r['error']=repr(exc);stop()
 finally:
  for p in pipes:
   if p.exists():p.unlink()
  for sig,handler in old.items():signal.signal(sig,handler)
  r['processes']=[dict(pid=c.pid,status=c.poll(),command=c.args)for c in children]
  for name in ['producer.stdout','producer.stderr']:
   if(out/name).exists():r[name]=pin(out/name)
  persist()
 print(json.dumps({k:r.get(k)for k in ['complete','seconds','producerExitCode','machineReports','stats','error']}));return 0 if r['complete']else 1
if __name__=='__main__':sys.exit(main())
