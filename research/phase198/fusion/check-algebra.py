#!/usr/bin/env python3
"""Bounded Lean word-algebra check with import control and durable timing/axioms."""
import argparse,hashlib,json,os,re,resource,signal,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--lean',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--seconds',type=float,default=45)
p.add_argument('--startup-control',action='store_true')
a=p.parse_args();assert 0<a.seconds<=60;a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
def pin(file):
 path=Path(file);digest=hashlib.sha256()
 with path.open('rb') as stream:
  for chunk in iter(lambda:stream.read(4*1024*1024),b''):digest.update(chunk)
 return {'file':str(path.resolve()),'bytes':path.stat().st_size,'sha256':digest.hexdigest()}
proof=Path(__file__).with_name('Affine.lean').resolve();lean=a.lean.resolve(strict=True)
(a.out/'Affine.lean').write_bytes(proof.read_bytes())
env=dict(os.environ);env.pop('LEAN_PATH',None);env.pop('LEAN_SYSROOT',None)
t=time.monotonic();r={'kind':'phase198-independent-word-algebra','complete':False,'method':pin(__file__),'proof':pin(proof),'checkedSource':pin(a.out/'Affine.lean'),'kernel':pin(lean),'timer':{'method':'Python monotonic plus resource.getrusage(RUSAGE_CHILDREN) deltas','runtime':pin(sys.executable)},'timeoutSeconds':a.seconds,'threads':1,'maxHeartbeats':200000,'librarySearch':'Explicit toolchain default; LEAN_PATH and LEAN_SYSROOT removed','jobs':[],'scope':'All finite Context values and every bit-vector width w (including zero). Only the affine accumulator algebra is modeled. Admission, source evaluation, worker loop, U64-to-U32 lowering, rendering and runtime remain outside this theorem.'}
def run(label,args):
 command=[str(lean),'-j1',*args]
 usage_before=resource.getrusage(resource.RUSAGE_CHILDREN)
 started=time.monotonic();timed_out=False
 proc=subprocess.Popen(command,cwd=a.out,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:stdout,stderr=proc.communicate(timeout=max(.01,a.seconds-(started-t)))
 except subprocess.TimeoutExpired:
  timed_out=True;os.killpg(proc.pid,signal.SIGKILL);stdout,stderr=proc.communicate()
 (a.out/(label+'-stdout')).write_text(stdout);(a.out/(label+'-stderr')).write_text(stderr)
 row=dict(label=label,command=command,status=proc.returncode,timedOut=timed_out,seconds=time.monotonic()-started,stdout=pin(a.out/(label+'-stdout')),stderr=pin(a.out/(label+'-stderr')))
 usage_after=resource.getrusage(resource.RUSAGE_CHILDREN)
 row['metrics']=dict(userSeconds=usage_after.ru_utime-usage_before.ru_utime,systemSeconds=usage_after.ru_stime-usage_before.ru_stime,cumulativeChildPeakRssKiB=usage_after.ru_maxrss,scope='CPU deltas for this child; peak RSS is the cumulative maximum over all children so far, not a per-phase delta')
 r['jobs'].append(row)
 if timed_out:raise TimeoutError(label+' exceeded the whole-check deadline')
 if proc.returncode:raise RuntimeError(label+' returned '+str(proc.returncode)+': '+(stdout+stderr)[-5000:])
 return stdout,stderr
try:
 r['kernelRuntime']=pin(lean.parent.parent/'lib/lean/libleanshared.so')
 r['bitVectorLibrary']=pin(lean.parent.parent/'lib/lean/Init/Data/BitVec/Lemmas.olean')
 r['version']=subprocess.check_output([lean,'--version'],env=env,text=True,timeout=min(3,a.seconds)).strip()
 if a.startup_control:
  (a.out/'ImportControl.lean').write_text('import Init.Data.BitVec.Lemmas\n#check BitVec.mul_add\n')
  r['startupControlSource']=pin(a.out/'ImportControl.lean');run('import-control',['ImportControl.lean'])
 stdout,stderr=run('proof',['-Dtrace.profiler=true','-Dtrace.profiler.useHeartbeats=true','-Dtrace.profiler.threshold=1000','-o','Affine.olean','Affine.lean'])
 axioms=dict(re.findall(r"'Bend.WordFusion\.(run_value|identity_entry)' depends on axioms:\s*\[([^\]]*)\]",stdout))
 for name in re.findall(r"'Bend.WordFusion\.(run_value|identity_entry)' does not depend on any axioms",stdout):axioms[name]=''
 r['axioms']={name:[x.strip() for x in value.split(',') if x.strip()] for name,value in axioms.items()}
 assert set(axioms)=={'run_value','identity_entry'},'Both theorem axiom reports required'
 assert all(set(names)<={'propext','Quot.sound','Classical.choice'} for names in r['axioms'].values()),'Unexpected axiom dependency'
 assert not re.search(r'\b(sorry|axiom|native_decide)\b',proof.read_text()),'Proof placeholder or new trust declaration'
 assert 'sorry' not in stdout+stderr and pin(proof)==r['proof']
 r['object']=pin(a.out/'Affine.olean');r['complete']=True
except Exception as e:r['error']=str(e)
r['seconds']=time.monotonic()-t
(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'complete':r['complete'],'seconds':r['seconds'],'axioms':r.get('axioms'),'error':r.get('error')}))
raise SystemExit(0 if r['complete'] else 1)
