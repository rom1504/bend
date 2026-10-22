"""Build and run diagnostic counters on pinned existing QBE objects, serially."""
import argparse,importlib.util,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--screen',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3] and not a.out.exists();a.out.mkdir(parents=True)
m=O.read(a.runtime/'manifest.json');s=O.read(a.screen);assert s['complete']
for x in m['inputs']+m['outputs']+s['inputs']:O.verify(x)
cases=O.read(ROOT/'selfhost/tools/performance/phase125/ceilings/rle-cases.json')['cases'];case=cases[0]
r=dict(complete=False,diagnosticOnly=True,inputs=[O.pin(__file__),O.pin(a.runtime/'manifest.json'),O.pin(a.screen),*m['inputs'],*m['outputs'],*s['inputs']],commands=[],rows=[],scope='Whole process adjacent repetition counter differences; instrumented times excluded.')
save=lambda:O.save(a.out/'report.json',r)
def run(cmd,label):
 t=time.monotonic();c=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=40);(a.out/(label+'.stdout')).write_bytes(c.stdout);(a.out/(label+'.stderr')).write_bytes(c.stderr)
 r['commands'].append(dict(command=list(map(str,cmd)),seconds=time.monotonic()-t,status=c.returncode,stdout=O.pin(a.out/(label+'.stdout')),stderr=O.pin(a.out/(label+'.stderr'))));save();assert c.returncode==0;return c
try:
 gcc=Path('/usr/bin/gcc').resolve();r['inputs'].append(O.pin(gcc))
 run([gcc,'-O2','-std=gnu11','-ffp-contract=off','-c',a.runtime/'runtime.c','-o',a.out/'runtime.o'],'runtime')
 r['runtime']=O.pin(a.out/'runtime.o');save()
 for role in ['baseline','candidate']:
  binary=next(x['binary'] for x in s['rows'] if x['role']==role);O.verify(binary);obj=Path(binary['file']).parent/'program.o';r['inputs'].append(O.pin(obj))
  run([gcc,'-no-pie',obj,a.out/'runtime.o','-pthread','-lm','-o',a.out/role],role+'-link')
  for n in [1,2]:
   c=run([a.out/role,'--threads','1','--gpu','off','--',n,0,*case['runtimeArgs']],role+'-'+str(n))
   lines=c.stderr.decode().splitlines();assert len(lines)==1 and lines[0].startswith('P125_COUNTS ')
   counts=json.loads(lines[0][len('P125_COUNTS '):]);assert counts['status']==0 and counts['overflowOrInvalid']==0 and counts['normalReturn'];assert counts['parentSourceSha256']==m['parent']['sha256']
   O.observation(c.stdout,b'',0,dict(case,repetitions=n,warmups=0),r['commands'][-1]['seconds'])
   r['rows'].append(dict(role=role,repetitions=n,counts=counts,outputCorrect=True));save()
 r['complete']=True
finally:save()
