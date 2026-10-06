#!/usr/bin/env python3
"""Data-only final command selection from an already verified comparison recipe."""
import argparse, hashlib, json, shlex
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; RAW=ROOT/'selfhost/build/phase58'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('comparison',type=Path,help='Completed make-comparison.py report.json')
p.add_argument('out',type=Path,help='Fresh final-matrix.json beside the comparison')
p.add_argument('--emission-method',type=Path,default=RAW/'emission-method02')
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists() and not out.with_suffix('.txt').exists()
inputs={}
def pin(value):
 file=Path(value['file'] if isinstance(value,dict) else value).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 row=dict(file=str(file),sha256=h.hexdigest())
 if isinstance(value,dict):assert row['sha256']==value['sha256']
 if str(file) in inputs:assert inputs[str(file)]==row
 inputs[str(file)]=row;return row
def read(value):return json.loads(Path(pin(value)['file']).read_text())
recipe=read(a.comparison);assert recipe['kind']=='phase58-compiler-comparison-recipe' and recipe['complete'] and recipe['pass'] and not recipe['b2Pending']
assert pin(recipe['producer'])['sha256']=='28245ffc0d03b83bc298f79954f8e449d2ef4ae52494cc07453c98906223e321'
for item in recipe['inputs']+recipe['bindings']:pin(item)
assert {x['suite'] for x in recipe['suites']}=={'b1','b2'} and len(recipe['suites'])==2
suites={x['suite']:x for x in recipe['suites']};commands=[]
for stage in ['prepare','clean','allocation','cpu']:
 for name in ['b1','b2']:
  cmd=list(suites[name]['commands'][stage])
  if stage in ['allocation','cpu']:
   at=cmd.index('--roles');assert cmd[at+1]=='baseline,candidate';cmd[at+1]='baseline,candidate,typescript'
  commands.append(dict(name=name+'-'+stage,command=cmd,guard='Runner owns the sole ExecutionGuard; do not nest',
   workers=18 if stage=='clean' else 3,ordinaryRequests=72 if stage=='clean' else None,
   scope='Profiles are separate from clean timings; allocation includes objects collected by both GC generations.' if stage in ['allocation','cpu'] else 'Per-role private preparation; first+three later ordinary requests in clean workers.'))
emitter=pin(a.emission_method/'emission.mjs');read(a.emission_method/'derivation.json');pin(a.emission_method/'profile.mjs')
bounded=pin(ROOT/'selfhost/tools/performance/phase32/bounded-run.py')
node=pin('/home/ai/.nvm/versions/node/v24.18.0/bin/node');base=Path(suites['b2']['bindings']).parent
def emission(role):
 target=base/('own-source-'+role)
 return ['python3','-B',bounded['file'],'--seconds','420','--rss-mib','2048','--available-mib','4096',str(target)+'-supervisor','--',
  'taskset','-c','3',node['file'],'--stack-size=4096','--max-old-space-size=1024',emitter['file'],suites['b2']['bindings'],role,str(target),'clean']
commands.append(dict(name='own-source-baseline',command=emission('baseline'),guard='One outer bounded-run guard; emitter has none',
 scope='Fresh one-shot clean old B2 own-source emission. Preserve source identity and exact B2/B3 equality; matched method clocks, different sources.'))
commands.append(dict(name='own-source-candidate',command=emission('candidate'),guard='One outer bounded-run guard; emitter has none',
 scope='Required fresh candidate observation with the same method as baseline. Exact B2/B3 equality; no fresh source self-check or isolated lookup claim.'))
producer=pin(__file__)
for item in list(inputs.values()):pin(item)
result=dict(kind='phase58-final-compiler-measurement-matrix',complete=True,executed=False,producer=producer,
 comparison=pin(a.comparison),commands=commands,inputs=list(inputs.values()),
 scope='Data-only launch recipe. Two separate changed-source old/new/TS clean matrices; allocation and CPU cover lexer with all three roles in fresh processes. Sampling totals are not peak memory. Own-source images compile their own different sources; this is not isolated lookup causality.')
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
text=out.with_suffix('.txt');assert not text.exists()
text.write_text('\n\n'.join('# '+x['name']+'\n'+shlex.join(x['command']) for x in commands)+'\n')
print(json.dumps(dict(plan=pin(out),commands=len(commands),executed=False)))
