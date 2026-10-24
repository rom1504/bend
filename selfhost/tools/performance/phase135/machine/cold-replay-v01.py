#!/usr/bin/env python3
"""Supervise cold or cached machine builds from explicitly retained current units.
No compiler process, text discovery, normalization or full-IR spool is involved.
Run under the same process-tree resource guard as other machine experiments.
"""
import argparse,importlib.util,json,pathlib,signal,subprocess,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[4]
s=importlib.util.spec_from_file_location('session',HERE/'session-build-v01.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
pin,verify=M.pin,M.verify

def main():
 entered=time.monotonic()
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['build','out','cache','expected-qbe']:ap.add_argument('--'+n,type=pathlib.Path,required=True)
 ap.add_argument('--seconds',type=float,default=180);ap.add_argument('--reuse-cache',action='store_true',help='Matched backend-only replay using an existing exact object cache');a=ap.parse_args();out=a.out.resolve();cache=a.cache.resolve();phase=ROOT/'selfhost/build/phase135';prior=json.loads(a.build.read_text())
 if out.exists()or (not cache.is_dir() if a.reuse_cache else cache.exists())or not out.is_relative_to(phase)or not cache.is_relative_to(phase)or cache.is_relative_to(out)or out.is_relative_to(cache)or not 0<a.seconds<=600:raise ValueError('Fresh disjoint output, correct cold/existing cache and bounded deadline required')
 if not prior['complete']or not prior['expectedPayloadExact']or not all(u['textRetained']for u in prior['units']):raise ValueError('Complete independently checked retained-current build required')
 expected=pin(a.expected_qbe)
 if prior['payloadDigest']!={k:expected[k]for k in ['bytes','sha256']}:raise ValueError('Independent current QBE oracle differs')
 inputs=[pin(__file__),pin(HERE/'session-build-v01.py'),pin(HERE/'replay-v01.py'),pin(HERE/'objects-v01.py'),pin(HERE/'protocol-v01.py'),pin(HERE/'elf-v01.py'),pin(sys.executable),pin(a.build),expected,*prior['inputs'],*[u['text']for u in prior['units']]]
 for p in inputs:verify(p)
 out.mkdir(parents=True);start=time.monotonic();deadline=start+a.seconds;children=[];tracker=M.S.ExecutionGuard()
 replay_cmd=[sys.executable,'-B',str(HERE/'replay-v01.py'),'--build',str(a.build.resolve())]
 machine_cmd=[sys.executable,'-B',str(HERE/'objects-v01.py'),'--stream','/dev/stdin','--out',str(out/'machine'),'--cache',str(cache),'--producer',prior['context']['producer']['file'],'--source',prior['source']['file'],'--runtime',prior['context']['runtime']['file'],'--expected-qbe',expected['file'],'--seconds',str(a.seconds)]
 if not a.reuse_cache:machine_cmd.append('--cold')
 r=dict(kind='phase135-supervised-cached-replay'if a.reuse_cache else'phase135-supervised-cold-replay',complete=False,inputs=inputs,currentBuild=pin(a.build),commands=[replay_cmd,machine_cmd],scope='Matched cached backend-only replay of authenticated current retained groups; no frontend/compiler/render cost or end-to-end edit-speed claim.'if a.reuse_cache else'Independent cold machine build of authenticated current retained groups; qualification retention exception, no compiler re-emission or native producer claim.',reuseCache=a.reuse_cache,preflightSeconds=start-entered)
 def save():r['seconds']=time.monotonic()-start;r['totalSeconds']=time.monotonic()-entered;M.O.save(out/'report.json',r)
 def interrupted(sig,frame):raise InterruptedError('Interrupted '+str(sig))
 old={sig:signal.signal(sig,interrupted)for sig in(signal.SIGINT,signal.SIGTERM)};save()
 try:
  with(out/'replay.stderr').open('xb')as re,(out/'machine.stdout').open('xb')as mo,(out/'machine.stderr').open('xb')as me:
   replay=subprocess.Popen(replay_cmd,cwd=ROOT,stdout=subprocess.PIPE,stderr=re,start_new_session=True);children.append(replay)
   machine=subprocess.Popen(machine_cmd,cwd=ROOT,stdin=replay.stdout,stdout=mo,stderr=me,start_new_session=True);children.append(machine);replay.stdout.close()
   while any(p.poll()is None for p in children):
    for p in children:tracker._tree(p.pid)
    if time.monotonic()>=deadline:raise TimeoutError('Cold replay deadline')
    if any(p.returncode not in(None,0)for p in children):raise ValueError('Replay/machine child failed')
    time.sleep(.05)
  r['exitCodes']=[p.returncode for p in children]
  if r['exitCodes']!=[0,0]:raise ValueError('Replay/machine child failed')
  build_path=out/'machine/report.json';build=json.loads(build_path.read_text())
  if not build['complete']or build['context']!=prior['context']or build['source']!=prior['source']or build['payloadDigest']!=prior['payloadDigest']or build['cold']!=(not a.reuse_cache)or (not a.reuse_cache and build['reusedUnits']!=0):raise ValueError('Current machine identity/replay mode mismatch')
  for p in inputs:verify(p)
  r.update(complete=True,machineReport=pin(build_path),binary=build['binary'],reusedUnits=build['reusedUnits'],builtUnits=build['builtUnits'],machineSeconds=build['seconds'],machineChildSeconds=build['childSeconds'])
 except BaseException as e:
  r['error']=repr(e)
  for p in children:tracker._tree(p.pid)
  tracker._stop()
  for p in children:
   try:p.wait(timeout=5)
   except subprocess.TimeoutExpired:pass
 finally:
  for sig,handler in old.items():signal.signal(sig,handler)
  r['processes']=[dict(pid=p.pid,status=p.poll(),command=p.args)for p in children]
  for n in ['replay.stderr','machine.stdout','machine.stderr']:
   if(out/n).exists():r[n]=pin(out/n)
  save()
 print(json.dumps({k:r.get(k)for k in ['complete','seconds','totalSeconds','machineReport','reusedUnits','builtUnits','error']}));return 0if r['complete']else 1
if __name__=='__main__':sys.exit(main())
