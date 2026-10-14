#!/usr/bin/env python3
"""Serial pinned Bun/Node/native engine comparison; complete C is the gate."""
import argparse,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];P=ROOT/'selfhost/tools/performance'
sys.path.insert(0,str(P/'phase88'))
from broad import guard,pin,save,NODE
from native_support import native_args,DEFAULT_CACHE
from admission import authenticate
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('out',type=Path);parser.add_argument('--calls',type=int,choices=[1,5],default=1)
parser.add_argument('--rounds',type=int,default=2)
parser.add_argument('--roles',default='ts-bun,ts-node,b2-bun,b2-node,native')
parser.add_argument('--cases',default='small,numeric_closed,lexer_original,map_closed,functions65,unicode')
a=parser.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
baseline=json.loads((ROOT/'selfhost/build/phase88/screen01/report.json').read_text())
bun=json.loads((ROOT/'selfhost/build/phase89/bun-install.json').read_text())['binary'];assert pin(bun['file'])==bun
roles=a.roles.split(',');cases=a.cases.split(',');auth=authenticate(ROOT/'selfhost/build/phase89/compiler-native-self01',DEFAULT_CACHE)
sourcePins={name:pin(baseline['cases'][name]) for name in cases}
report=dict(complete=False,passed=False,method=pin(__file__),worker=pin(P/'phase86/reference.mjs'),bun=bun,node=pin(NODE),calls=a.calls,rounds=a.rounds,roles=roles,sourcePins=sourcePins,native=auth,rows=[])
save(out/'plan.json',report)
for rnd in range(a.rounds):
 for ix,name in enumerate(cases):
  order=roles[ix%len(roles):]+roles[:ix%len(roles)]
  if rnd%2:order=list(reversed(order))
  for role in order:
   source=Path(sourcePins[name]['file']);assert pin(source)==sourcePins[name]
   prefix=out/f'{rnd+1}-{name}-{role}'
   oracleRole='typescript' if role.startswith('ts-') else 'b2'
   if role=='native':cmd=native_args(auth,source,prefix,a.calls)
   else:
    engine,flags=(bun['file'],[]) if role.endswith('-bun') else (NODE,['--max-old-space-size=1024','--stack-size=4096'])
    cmd=[engine,*flags,str(P/'phase86/reference.mjs'),oracleRole,str(source),str(prefix),str(a.calls)]
   job=guard(Path(str(prefix)+'-guard'),cmd,60)
   logs='\n'.join((Path(job['guard'])/n).read_text() for n in ['stdout.log','stderr.log'])
   outputs=[pin(Path(str(prefix)+f'.{i}.c')) for i in range(1,a.calls+1) if Path(str(prefix)+f'.{i}.c').exists()]
   oracle=next(r['outputs'][0]['sha256'] for r in baseline['rows'] if r['case']==name and r['role']==oracleRole)
   exact=len(outputs)==a.calls and all(o['sha256']==oracle for o in outputs)
   metrics=dict(re.findall(r'(base_prepare_ms|runtime_prepare_ms)=(\d+)',logs))
   requests=list(map(int,re.findall(r'request=\d+ request_ms=(\d+)',logs)))
   reference=Path(str(prefix)+'.json');imports=None
   if reference.exists():
    ref=json.loads(reference.read_text());requests=[c['requestMs'] for c in ref['calls']];imports=ref.get('importsMs')
   process=json.loads((Path(job['guard'])/'process.json').read_text())
   row=dict(round=rnd+1,case=name,role=role,job=job,outputs=outputs,exact=exact,metrics=metrics,requestMs=requests,importsMs=imports,processWallSeconds=process['wallSeconds'],peakRssBytes=process.get('peakTreeRssBytes'))
   report['rows'].append(row);save(out/'report.json',report)
   print(json.dumps({k:row[k] for k in ['round','case','role','exact','requestMs','importsMs','processWallSeconds']}),flush=True)
   if not job['pass_'] or not exact:raise SystemExit('Failed job/output; evidence retained')
assert authenticate(ROOT/'selfhost/build/phase89/compiler-native-self01',DEFAULT_CACHE)==auth
assert pin(bun['file'])==bun
report.update(complete=True,passed=True);save(out/'report.json',report)
