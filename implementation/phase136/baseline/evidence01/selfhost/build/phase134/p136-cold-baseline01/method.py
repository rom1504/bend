#!/usr/bin/env python3
"""Supervised native Bend -> QBE stdin -> unchanged aligned machine build.

Transport, hashing and process supervision only; run inside a resource guard.
"""
import argparse, hashlib, importlib.util, json, os, selectors, shutil, signal, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase130/native-request.py'
spec=importlib.util.spec_from_file_location('native_request',METHOD);N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
ALIGNED=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):
 if pin(p['file'])!=p:raise ValueError('Changed input: '+p['file'])
def require(b,m):
 if not b:raise ValueError(m)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ('image','source','carrier-receipt','runtime','out'):ap.add_argument('--'+n,type=Path,required=True)
 ap.add_argument('--expected-qbe',type=Path);ap.add_argument('--expected-stdout',type=Path)
 ap.add_argument('--retain-ir',action='store_true');ap.add_argument('--seconds',type=float,default=600)
 a=ap.parse_args();out=a.out.resolve();require(not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase134'),'Fresh Phase134 output required')
 require(0<a.seconds<=3600,'Finite bounded timeout required')
 require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS','BEND_PROFILE_EVENTS_OUT')),'No ambient diagnostic instrumentation')
 image=N.P125.member(a.image,'program');source=a.source.resolve();runtime=N.P125.member(a.runtime,'runtime.o')
 require(os.access(image,os.X_OK),'Executable producer required')
 carrier,base,carrier_inputs=N.carrier_inputs(a.carrier_receipt.resolve())
 qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe';assembler=Path(shutil.which('as'));linker=Path(shutil.which('gcc'))
 inputs=[pin(__file__),pin(METHOD),pin(ALIGNED),pin(image),pin(source),pin(runtime),pin(qbe),pin(assembler),pin(linker),*carrier_inputs]
 for parent in (image.parent/'report.json',runtime.parent/'report.json'):
  if parent.is_file():inputs.append(pin(parent))
 expected=pin(a.expected_qbe)if a.expected_qbe else None
 if expected:inputs.append(expected)
 if a.expected_stdout:inputs.append(pin(a.expected_stdout))
 for p in inputs:verify(p)
 out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
 emit=[str(image),'--threads','1','--gpu','off','--','phase111',str(source),base['file'],'cache',carrier['carrier']['file'],carrier['stamp']]
 qcmd=[str(qbe),'-t','amd64_sysv','-o',str(out/'program.s'),'-']
 r=dict(kind='phase134-supervised-qbe-stdin-build',complete=False,inputs=inputs,source=pin(source),image=pin(image),runtime=pin(runtime),
  compilerCommand=emit,qbeCommand=qcmd,jobs=[],retainIR=a.retain_ir,comparedToReference=False,expectedQbe=expected,
  machineDiagnosticPolicy='Phase123: assembler/linker zero exit required; stderr retained, not promoted to failure. Compiler/QBE/execution stderr still fails.',
  relayLimitBytes=65536,maximumRelayBytes=0,inheritedAffinity=sorted(os.sched_getaffinity(0)),
  scope='Host byte transport only. Existing Bend verification stays in the supplied compiler; unchanged Phase123 QBE/assembler/link flags. Digest equality is claimed only with an independently supplied reference. No installed selection change.')
 start=time.monotonic();deadline=start+a.seconds;children=[];sel=selectors.DefaultSelector();retained=None
 def save():
  r['wallSeconds']=time.monotonic()-start;p=out/'report.tmp';p.write_text(json.dumps(r,indent=2)+'\n');p.replace(out/'report.json')
 def left():
  t=deadline-time.monotonic()
  if t<=0:raise TimeoutError('Whole pipeline deadline exceeded')
  return t
 def stop():
  for p in children:
   if p.poll()is None:
    try:os.killpg(p.pid,signal.SIGKILL)
    except ProcessLookupError:pass
  for p in children:
   try:p.wait(timeout=5)
   except subprocess.TimeoutExpired:pass
 def stage(label,cmd):
  row=dict(label=label,command=list(map(str,cmd)));r['jobs'].append(row);save();t=time.monotonic()
  with (out/(label+'.stdout')).open('xb')as so,(out/(label+'.stderr')).open('xb')as se:
   p=subprocess.Popen(row['command'],cwd=ROOT,stdout=so,stderr=se,start_new_session=True);children.append(p);code=p.wait(timeout=left())
  row.update(exitCode=code,seconds=time.monotonic()-t,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')));save()
  require(code==0 and (label in ('assemble','link') or row['stderr']['bytes']==0),label+' failed or diagnosed an error')
 save()
 try:
  with (out/'compiler.stderr').open('xb')as ce,(out/'qbe.stderr').open('xb')as qe,(out/'qbe.stdout').open('xb')as qo:
   consumer=subprocess.Popen(qcmd,cwd=ROOT,stdin=subprocess.PIPE,stdout=qo,stderr=qe,bufsize=0,start_new_session=True);children.append(consumer)
   producer=subprocess.Popen(emit,cwd=ROOT,stdout=subprocess.PIPE,stderr=ce,bufsize=0,start_new_session=True);children.append(producer)
   os.set_blocking(producer.stdout.fileno(),False);os.set_blocking(consumer.stdin.fileno(),False)
   sel.register(producer.stdout,selectors.EVENT_READ,'read');buffer=bytearray(65536);view=memoryview(buffer);pending=0;offset=0;eof=False;h=hashlib.sha256();size=0
   if a.retain_ir:retained=(out/'program.ssa').open('xb')
   while not eof or pending:
    remaining=left()
    require(consumer.poll()is None,'QBE exited before complete producer EOF')
    for key,mask in sel.select(min(remaining,.25)):
     if key.data=='read':
      count=producer.stdout.readinto(buffer)
      if count is None:continue
      if count==0:
       eof=True;sel.unregister(producer.stdout);producer.stdout.close();consumer.stdin.close()
      else:
       h.update(view[:count]);size+=count
       if retained:retained.write(view[:count])
       pending=count;offset=0;r['maximumRelayBytes']=max(r['maximumRelayBytes'],count)
       sel.unregister(producer.stdout);sel.register(consumer.stdin,selectors.EVENT_WRITE,'write')
     else:
      try:n=os.write(consumer.stdin.fileno(),view[offset:pending])
      except BlockingIOError:continue
      require(n>0,'Zero pipe write');offset+=n
      if offset==pending:
       pending=0;offset=0;sel.unregister(consumer.stdin);sel.register(producer.stdout,selectors.EVENT_READ,'read')
   r['compilerExitCode']=producer.wait(timeout=left());r['qbeExitCode']=consumer.wait(timeout=left())
   r['emitAndQbeSeconds']=time.monotonic()-start;r['irDigest']=dict(bytes=size,sha256=h.hexdigest())
  if retained:retained.close();retained=None;r['retainedIR']=pin(out/'program.ssa')
  r['compilerStderr']=pin(out/'compiler.stderr');r['qbeStderr']=pin(out/'qbe.stderr');r['qbeStdout']=pin(out/'qbe.stdout');save()
  require(r['compilerExitCode']==0 and r['qbeExitCode']==0,'Compiler/QBE nonzero exit')
  require(size>0 and not r['compilerStderr']['bytes']and not r['qbeStderr']['bytes']and not r['qbeStdout']['bytes'],'Empty IR or unexpected diagnostics')
  if expected:
   require(r['irDigest']==dict(bytes=expected['bytes'],sha256=expected['sha256']),'Exact IR digest mismatch')
   r['comparedToReference']=True
  r['assembly']=pin(out/'program.s');save()
  stage('assemble',[assembler,'-mbranches-within-32B-boundaries','-o',out/'program.o',out/'program.s'])
  stage('link',[linker,'-no-pie',out/'program.o',runtime,'-pthread','-lm','-o',out/'program'])
  r['object']=pin(out/'program.o');r['binary']=pin(out/'program')
  if a.expected_stdout:
   stage('execute',[out/'program','--threads','1','--gpu','off'])
   require(N.same_bytes(out/'execute.stdout',a.expected_stdout),'Independent execution output differs');r['outputExact']=True
  for p in inputs:verify(p)
  require(a.retain_ir or not (out/'program.ssa').exists(),'Unexpected retained textual IR')
  r['complete']=True
 except BaseException as e:r['error']=repr(e);r['timedOut']=isinstance(e,(TimeoutError,subprocess.TimeoutExpired));stop()
 finally:
  if retained:retained.close()
  sel.close();r['processes']=[dict(pid=p.pid,status=p.poll(),command=p.args)for p in children]
  for k,name in [('compilerStderr','compiler.stderr'),('qbeStderr','qbe.stderr')]:
   if(out/name).exists():r[k]=pin(out/name)
  save()
 print(json.dumps({k:r.get(k)for k in ('complete','wallSeconds','irDigest','comparedToReference','maximumRelayBytes','error')}));return 0 if r['complete']else 1
if __name__=='__main__':sys.exit(main())
