#!/usr/bin/env python3
"""Independent operator correspondence probes; execute with the outer process guard."""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110';AUDIT=HERE/'controls/audit'
s=importlib.util.spec_from_file_location('p108',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser();p.add_argument('--api',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--split',choices=['training','heldout','all'],default='training');p.add_argument('--reuse',type=Path);p.add_argument('--kind',choices=['rebuild','take','spare','unique-overlap'],default='rebuild');a=p.parse_args();out=a.out.resolve();rt=a.runtime.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe';clang=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
prefix=(a.kind+'-') if a.kind in ['take','spare','unique-overlap'] else '';harness_name=(a.kind+'-controls.c') if a.kind in ['take','spare','unique-overlap'] else 'operator-controls.c'
manifest=json.loads((AUDIT/(prefix+'manifest.json')).read_text());recipes=json.loads((AUDIT/(prefix+'recipes.json')).read_text())['recipes'];cases=[c for c in recipes if a.split=='all' or c['split']==a.split];expected={(r['name'],r['dropOrder']):r for r in map(json.loads,(AUDIT/(prefix+'expected.jsonl')).read_text().splitlines())}
files=[Path(__file__),HERE/'emit-probe.mjs',a.api,rt/'runtime.c',rt/'abi.h',rt/'abi-extension.h',rt/'abi-private.h',rt/'manifest.json',AUDIT/(prefix+'manifest.json'),AUDIT/(prefix+'recipes.json'),AUDIT/harness_name,AUDIT/(prefix+'expected.jsonl'),qbe,clang,bun]
r=dict(kind='phase110-physical-operator-probes',complete=False,operator=a.kind,split=a.split,inputs=[R.pin(f) for f in files],jobs=[],binaries={},observations=[]);save=lambda:R.save(out/'report.json',r);save()
def run(label,args):
 row=dict(label=label,command=list(map(str,args)));r['jobs'].append(row);save();t=time.monotonic()
 with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:c=R.P.run(row['command'],cwd=ROOT,stdout=so,stderr=se,timeout=30)
 row.update(seconds=time.monotonic()-t,status=c.returncode);save()
 if c.returncode:raise ValueError(label+' failed')
try:
 for f in r['inputs']:R.N.verify(f)
 api_record=json.loads((a.api.parent/'report.json').read_text())
 if api_record.get('admission'):
  R.N.verify(api_record['source']);R.N.verify(api_record['admission'])
  source=Path(api_record['source']['file']);source_text=source.read_text();stem='wrapper-spare' if 'def nx110rtw_control_report(' in source_text else 'stored-field'
  version='-v2' if 'def nx110rtn_check(' in source_text else ''
  admission=json.loads(Path(api_record['admission']['file']).read_text());extra=[]
  if admission['kind']=='phase110-wrapper-combined-admission':
   stem='wrapper-combined';version='';extra=['--variant',admission['variant']]
  run('source-admission',[sys.executable,'-B',HERE/'runtime-ir'/(stem+'-admit'+version+'.py'),'--source',source,'--runtime',rt,'--out',out/'admission',*extra])
  r['inputs'].append(R.pin(out/'admission/manifest.json'));save()
 for key in ['harness','recipes','expected']:
  item=manifest[key];assert R.pin(ROOT/item['file'])['sha256']==item['sha256']
 if a.reuse:
  prior=json.loads((a.reuse/'report.json').read_text());assert prior['complete'];r['inputs'].append(R.pin(a.reuse/'report.json'));r['binaries']=prior['binaries'];save()
 else:
  (out/'method.py').write_bytes(Path(__file__).read_bytes());(out/'operator-controls.c').write_bytes((AUDIT/harness_name).read_bytes())
  run('runtime',['gcc','-O2','-std=gnu11','-c',rt/'runtime.c','-o',out/'runtime.o'])
  run('baseline',['gcc','-O2','-I',rt,out/'operator-controls.c',out/'runtime.o','-pthread','-lm','-o',out/'baseline']);r['binaries']['baseline']=R.pin(out/'baseline')
  run('harness',['gcc','-O2','-DP110_AUDIT_IR',*(['-DP110_AUDIT_SPARE'] if a.kind=='spare' else []),'-I',rt,'-c',out/'operator-controls.c','-o',out/'harness.o'])
  for view in ['single','atomic']:
   emit=out/('emit-'+view);run('emit-'+view,[bun,HERE/'emit-probe.mjs',a.api,emit,view,a.kind])
   for backend in ['qbe','clang']:
    name=view+'-'+backend;obj=out/(name+'.o')
    if backend=='qbe':
     run(name+'-qbe',[qbe,'-t','amd64_sysv','-o',out/(name+'.s'),emit/'program.ssa']);run(name+'-as',['as','-o',obj,out/(name+'.s')])
    else:run(name+'-object',[clang,'-O2','-std=gnu11','-isystem',clang.parents[1]/'include/clang','-c',emit/'program.c','-o',obj])
    run(name+'-link',['gcc','-no-pie',obj,out/'runtime.o',out/'harness.o','-pthread','-lm','-o',out/name]);r['binaries'][name]=R.pin(out/name);save()
 for name,binary in r['binaries'].items():
  R.N.verify(binary)
  for case in cases:
   for order in (case['dropOrders'] if 'dropOrders' in case else [order for name,order in expected if name==case['name']]):
    label='-'.join([name,case['name'],order]);run(label,[binary['file'],case['name'],order]);actual=json.loads((out/(label+'.stdout')).read_text());assert actual==expected[(case['name'],order)],label+' complete-value oracle differs'
    r['observations'].append(dict(name=name,case=case['name'],dropOrder=order,exact=True));save()
 for f in r['inputs']:R.N.verify(f)
 r['complete']=True;save();print(json.dumps(dict(complete=True,observations=len(r['observations']))))
except BaseException as e:r['error']=repr(e);save();raise
