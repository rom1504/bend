#!/usr/bin/env python3
"""Build frozen owned-IR workers with one cached runtime; guard this script externally."""
import argparse, hashlib, importlib.util, json, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]; HERE=ROOT/'selfhost/tools/performance/phase110'
s=importlib.util.spec_from_file_location('p108',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)

def main():
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['out','api','capture','runtime','harness']:p.add_argument('--'+name,type=Path,required=True)
 p.add_argument('--profiles',nargs='+',default=['fused','tagged','specialized','pair'])
 p.add_argument('--backends',nargs='+',default=['qbe','clang','gcc'])
 p.add_argument('--variant',default='reverse',choices=['reverse','discard','duplicate','tail','last','append'])
 a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
 (out/'method.py').write_bytes(Path(__file__).read_bytes());(out/'emit-method.mjs').write_bytes((HERE/'emit.mjs').read_bytes())
 api,capture,runtime,harness=[getattr(a,n).resolve() for n in ['api','capture','runtime','harness']]
 clang=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
 paths=[Path(__file__),HERE/'emit.mjs',api,capture/'report.json',capture/'native-facts.json',runtime/'runtime.c',runtime/'abi.h',runtime/'manifest.json',*[harness/n for n in ['harness.c','cases.inc.c','abi.h','expected.jsonl','manifest.json']],clang,qbe,bun,*[Path(shutil.which(t)) for t in ['gcc','as']]]
 report=dict(kind='phase110-frozen-worker-build',complete=False,variant=a.variant,inputs=[R.pin(f) for f in paths],jobs=[],workers=[],semantics={},started=time.time(),scope='Candidate compiler algorithms in Bend; JS transport/Python supervision only. One GCC-built runtime object shared by all worker backends. Runtime setup/build, worker acquisition and execution are separate.')
 save=lambda:R.save(out/'report.json',report)
 def cmd(label,argv,seconds=60):
  row=dict(label=label,command=list(map(str,argv)));report['jobs'].append(row);save();start=time.monotonic()
  with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:c=R.P.run(row['command'],cwd=ROOT,stdout=so,stderr=se,timeout=seconds)
  row.update(seconds=time.monotonic()-start,status=c.returncode,stdout=R.pin(out/(label+'.stdout')),stderr=R.pin(out/(label+'.stderr')));save()
  if c.returncode:raise RuntimeError(label+' failed '+str(c.returncode))
  return row
 save()
 try:
  for item in report['inputs']:R.N.verify(item)
  flags=['-O2','-std=gnu11'];cf=[*flags,'-isystem',str(clang.parents[1]/'include/clang')]
  cmd('runtime',['gcc',*flags,'-c',runtime/'runtime.c','-o',out/'runtime.o'])
  cmd('harness',['gcc',*flags,'-c',harness/'harness.c','-o',out/'harness.o'])
  expected=(harness/'expected.jsonl').read_bytes()
  for profile in a.profiles:
   emission=out/('emit-'+profile)
   cmd('emit-'+profile,[bun,out/'emit-method.mjs',api,capture,emission,a.variant,profile])
   for backend in a.backends:
    label=profile+'-'+backend;obj=out/(label+'.o');binary=out/label;start=time.monotonic()
    if backend=='qbe':
     cmd(label+'-qbe',[qbe,'-t','amd64_sysv','-o',out/(label+'.s'),emission/'program.ssa'])
     cmd(label+'-as',['as','-o',obj,out/(label+'.s')])
    elif backend in ['clang','gcc']:cmd(label+'-object',[clang if backend=='clang' else 'gcc',*(cf if backend=='clang' else flags),'-c',emission/'program.c','-o',obj])
    else:raise ValueError('unknown backend')
    cmd(label+'-link',['gcc','-no-pie',obj,out/'runtime.o',out/'harness.o','-pthread','-lm','-o',binary])
    report['workers'].append(dict(profile=profile,backend=backend,name=label,buildSeconds=time.monotonic()-start,binary=R.pin(binary),object=R.pin(obj)));save()
    cmd(label+'-controls',[binary])
    actual=(out/(label+'-controls.stdout')).read_bytes()
    if actual!=expected:raise ValueError(label+' differs frozen independent oracle')
    report['semantics'][label]=dict(exact=True,cases=len(expected.splitlines()));save()
  for item in report['inputs']:R.N.verify(item)
  report.update(complete=True,finished=time.time());save();print(json.dumps(dict(complete=True,workers=len(report['workers']),cases=len(expected.splitlines()),out=str(out))))
 except BaseException as e:report['error']=repr(e);save();raise
if __name__=='__main__':main()
