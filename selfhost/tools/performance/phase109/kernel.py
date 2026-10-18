#!/usr/bin/env python3
"""Matched production-ownership kernel builds and finite controls; guard externally."""
import argparse,hashlib,importlib.util,json,shutil,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase109'
s=importlib.util.spec_from_file_location('r',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--emitted',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--production-runtime',type=Path,required=True);p.add_argument('--harness',type=Path,required=True);p.add_argument('--rounds',type=int,default=3);p.add_argument('--repetitions',type=int,default=10);p.add_argument('--only',nargs='+',default=['direct-qbe','direct-clang','production-gcc','production-clang','production-qbe']);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists();out.mkdir(parents=True)
 clang=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe';cproc=ROOT/'selfhost/build/phase108/toolchain/cproc-src/cproc';shim=ROOT/'selfhost/build/phase108/toolchain/atomic-shim.o';inc=HERE.parent/'phase108/toolchain/include'
 runtime=a.runtime.resolve();prod=a.production_runtime.resolve();harness=a.harness.resolve();emitted=a.emitted.resolve();emission=json.loads((emitted/'report.json').read_text());assert emission['complete'];variant=emission.get('variant','reverse');assert variant in ['reverse','discard','duplicate']
 if variant!='reverse':assert all(v.startswith('direct-') for v in a.only),'production reference implements reverse only'
 expected=HERE/('controls/expected.jsonl' if variant=='reverse' else f'controls/derived/{variant}.expected.jsonl')
 paths=[Path(__file__),emitted/'program.ssa',emitted/'program.c',emitted/'report.json',runtime/'runtime.c',runtime/'abi.h',runtime/'manifest.json',prod/'runtime.c',prod/'abi.h',prod/'manifest.json',harness/'harness.c',harness/'cases.inc.c',harness/'abi.h',expected,clang,qbe,cproc,shim,inc/'bend-cproc.h',inc/'stdatomic.h',*[Path(shutil.which(t)) for t in ['gcc','as','ld']]]
 report=dict(kind='phase109-matched-owned-kernels',complete=False,inputs=[R.pin(p) for p in paths],jobs=[],builds={},controls={},timings=[],scope='Same frozen graphs and actual runtime semantics. Direct QBE/Clang share GCC-built runtime object; production workers compiled with their runtime in one TU. Worker-only timings exclude graph setup and observation; no whole-compiler projection.')
 save=lambda:R.save(out/'report.json',report);save()
 def cmd(label,argv,expect=0):
  start=time.monotonic();job=dict(label=label,command=list(map(str,argv)));report['jobs'].append(job);save()
  with (out/(label+'.stdout')).open('xb') as stdout,(out/(label+'.stderr')).open('xb') as stderr:child=R.P.run(job['command'],cwd=ROOT,stdout=stdout,stderr=stderr,timeout=60)
  job.update(seconds=time.monotonic()-start,status=child.returncode,stdout=R.pin(out/(label+'.stdout')),stderr=R.pin(out/(label+'.stderr')));save()
  if child.returncode!=expect:raise RuntimeError(label+' status '+str(child.returncode))
  return job
 try:
  for item in report['inputs']:R.N.verify(item)
  cflags=['-O2','-std=gnu11'];cf=[*cflags,'-isystem',str(clang.parents[1]/'include/clang')]
  cmd('runtime',['gcc',*cflags,'-c',runtime/'runtime.c','-o',out/'runtime.o']);cmd('harness',['gcc',*cflags,'-c',harness/'harness.c','-o',out/'harness.o'])
  for variant in a.only:
   start=time.monotonic();obj=out/(variant+'.o');binary=out/variant;extra=[]
   if variant=='direct-qbe':cmd(variant+'-qbe',[qbe,'-t','amd64_sysv','-o',out/(variant+'.s'),emitted/'program.ssa']);cmd(variant+'-as',['as','-o',obj,out/(variant+'.s')]);extra=[out/'runtime.o']
   elif variant=='direct-clang':cmd(variant+'-object',[clang,*cf,'-c',emitted/'program.c','-o',obj]);extra=[out/'runtime.o']
   elif variant=='production-gcc':cmd(variant+'-object',['gcc',*cflags,'-c',prod/'runtime.c','-o',obj])
   elif variant=='production-clang':cmd(variant+'-object',[clang,*cf,'-c',prod/'runtime.c','-o',obj])
   elif variant=='production-qbe':cmd(variant+'-object',[cproc,'-DWL_PORTABLE=1','-DBEND_CPROC=1','-I',inc,'-include',inc/'bend-cproc.h','-c',prod/'runtime.c','-o',obj]);extra=[shim]
   else:raise ValueError(variant)
   cmd(variant+'-link',['gcc','-no-pie',obj,*extra,out/'harness.o','-pthread','-lm','-o',binary]);report['builds'][variant]=dict(seconds=time.monotonic()-start,binary=R.pin(binary));save()
   cmd(variant+'-control',[binary]);actual=(out/(variant+'-control.stdout')).read_bytes();assert actual==expected.read_bytes(), variant+' differs independent oracle';report['controls'][variant]=dict(exact=True,cases=len(actual.splitlines()));save()
  for round in range(a.rounds):
   for variant in (a.only if round%2==0 else list(reversed(a.only))):
    job=cmd(variant+'-timing'+str(round),[out/variant,'list-deep',str(a.repetitions)])
    actual=json.loads((out/(job['label']+'.stdout')).read_text());oracle=next(json.loads(s) for s in expected.read_text().splitlines() if json.loads(s)['name']=='list-deep');assert actual==oracle
    timing=json.loads((out/(job['label']+'.stderr')).read_text());report['timings'].append(dict(variant=variant,round=round,**timing));save()
  for item in report['inputs']:R.N.verify(item)
  report['complete']=True;save();print(json.dumps(dict(complete=True,variants=a.only,rounds=a.rounds)))
 except BaseException as e:report['error']=repr(e);save();raise
if __name__=='__main__':main()
