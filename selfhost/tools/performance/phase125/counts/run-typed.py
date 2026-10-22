"""Build and run diagnostic counters on pinned existing QBE objects, serially."""
import argparse,importlib.util,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--screen',type=Path,required=True);p.add_argument('--extra',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True);p.add_argument('--parent-role',default='baseline');p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3] and not a.out.exists();a.out.mkdir(parents=True)
m=O.read(a.runtime/'manifest.json');s=O.read(a.screen);assert s['complete']
for x in m['inputs']+m['outputs']+s['inputs']:O.verify(x)
cases=O.read(a.manifest)['cases'];case=cases[0]
r=dict(complete=False,diagnosticOnly=True,inputs=[O.pin(__file__),O.pin(a.runtime/'manifest.json'),O.pin(a.screen),O.pin(a.manifest),*m['inputs'],*m['outputs'],*s['inputs']],commands=[],rows=[],scope='Whole process adjacent repetition counter differences; instrumented times excluded.')
save=lambda:O.save(a.out/'report.json',r)
def run(cmd,label):
 t=time.monotonic();c=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=40);(a.out/(label+'.stdout')).write_bytes(c.stdout);(a.out/(label+'.stderr')).write_bytes(c.stderr)
 r['commands'].append(dict(command=list(map(str,cmd)),seconds=time.monotonic()-t,status=c.returncode,stdout=O.pin(a.out/(label+'.stdout')),stderr=O.pin(a.out/(label+'.stderr'))));save();assert c.returncode==0;return c
try:
 gcc=Path('/usr/bin/gcc').resolve();r['inputs'].append(O.pin(gcc))
 extra=a.extra.read_text();assert extra.count('uint64_t p125_rt_concat_typed(')==1 and 'term_ctr(' not in extra
 import re
 extra=extra.replace('  Term nil =', '  ++p125_append_calls;\n  Term nil =').replace('  while (node != nil) {','  while (node != nil) {\n    ++p125_append_visits;')
 extra=re.sub(r'(?m)^( +)return (?:left|right);', lambda m:m[1]+'++p125_append_success;\n'+m[0],extra)
 text=(a.runtime/'runtime.c').read_text()
 text=text.replace('#include "runtime.h"','#include "runtime.h"\nstatic uint64_t p125_append_calls, p125_append_visits, p125_append_success;')
 lines=text.splitlines(True);hits=[i for i,x in enumerate(lines) if 'fputs(' in x and 'constructors' in x];assert len(hits)==1
 lines.insert(hits[0], r'''  fprintf(stderr, ",\"append_calls\":%llu,\"append_visits\":%llu,\"append_success\":%llu", (unsigned long long)p125_append_calls, (unsigned long long)p125_append_visits, (unsigned long long)p125_append_success);'''+ '\n')
 source=a.out/'runtime.c';source.write_text(''.join(lines)+'\n'+extra);r['inputs'].append(O.pin(a.extra));r['derivedSource']=O.pin(source)
 run([gcc,'-O2','-std=gnu11','-ffp-contract=off','-I',a.runtime,'-c',source,'-o',a.out/'runtime.o'],'runtime')
 r['runtime']=O.pin(a.out/'runtime.o');save()
 for role in [a.parent_role,'candidate']:
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
