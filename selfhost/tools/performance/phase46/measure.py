#!/usr/bin/env python3
"""Four-way fixed-work measurement; calibration and timing have separate receipts."""
import argparse, importlib.util, json, math, statistics, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def module(name,file):
 spec=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
s=module('support',ROOT/'selfhost/tools/performance/programs/support.py')
o=module('oracle',HERE/'oracle.py')
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path)
p.add_argument('--acquired',required=True,nargs='+',type=Path)
p.add_argument('--plan',type=Path);p.add_argument('--cases',default='numeric,closures,tree,array,map,lexer')
p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
cases=json.loads((HERE/'cases.json').read_text());assert set(a.cases.split(',')) <= {c['name'] for c in cases}
oracles=json.loads((ROOT/'selfhost/build/phase46/oracles.json').read_text())
for item in oracles['inputs']:
 assert s.identity(item['path'])['sha256']==item['sha256'],item['path']
oracles['cases']={r['name']:r for r in oracles['cases']}
roles=[('upstream','js'),('selfhost','js'),('upstream','c'),('selfhost','c')]
node='/home/ai/.nvm/versions/node/v24.18.0/bin/node';records=[];started=time.time()
plans=json.loads(a.plan.read_text()) if a.plan else None
frozenInputs=[s.identity(HERE/f) for f in ['measure.py','execute.py','oracle.py','cases.json']]
frozenInputs += [s.identity(ROOT/'selfhost/build/phase46/oracles.json'),s.identity(node)]
if a.plan:frozenInputs.append(s.identity(a.plan))
artifacts={}
for case in cases:
 if case['name'] not in a.cases.split(','):continue
 for role,target in roles:
  name=case['name']+'-'+role+'-'+target
  roots=[d.resolve()/name for d in a.acquired if (d/name).is_dir()]
  assert len(roots)==1,name
  d=roots[0];file=d/('program' if target=='c' else 'program.'+('cjs' if role=='upstream' else 'mjs'))
  assert file.is_file(),str(file)
  receiptFile=d/('program.c.json' if target=='c' else file.name+'.json')
  frozenInputs.append(s.identity(receiptFile))
  receipt=json.loads(receiptFile.read_text())
  assert receipt['complete']
  emitted=d/('program.c' if target=='c' else file.name)
  assert s.identity(emitted)['sha256']==receipt['output']['sha256']
  wrapper=ROOT/next(c['wrapper'] for c in cases if c['name']==case['name'])
  wrapper=wrapper.with_name(wrapper.stem+'-batch.bend')
  assert s.identity(wrapper)['sha256']==receipt['input']['sha256']==oracles['cases'][case['name']]['wrapper']['sha256']
  if target=='c':
   cc=json.loads((d/'toolchain/process.json').read_text());assert cc['complete']
   assert cc['command'][-1]==str(file) and str(emitted) in cc['command']
  artifacts[name]=dict(path=str(file),identity=s.identity(file),acquisition=str(d))
with s.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 for case in cases:
  name=case['name']
  if name not in a.cases.split(','):continue
  reps=plans[name]['repetitions'] if plans else {'numeric':1024,'closures':4096,'tree':256,'array':128,'map':32,'lexer':128}[name]
  warm=plans[name]['warmups'] if plans else reps
  values=oracles['cases'][name]['values']
  expected=[case['expected'],o.digest(values,warm),o.digest(values,reps)]
  for round_index in range(a.rounds if plans else 1):
   order=roles[round_index%4:]+roles[:round_index%4]
   for role,target in order:
    key=name+'-'+role+'-'+target;artifact=artifacts[key];file=artifact['path']
    assert s.identity(file)==artifact['identity']
    cmd=([node,'--max-old-space-size=1024',file] if target=='js' else [file])+['--threads','1','--gpu','off','--',str(reps),str(warm)]
    dest=a.out/(key+'-r'+str(round_index));child=dest/'child.json'
    proc=guard.run(['taskset','-c','3','python3',str(HERE/'execute.py'),str(child),*cmd],dest,time.monotonic()+45)
    r=dict(case=name,role=role,target=target,round=round_index,repetitions=reps,warmups=warm,expected=expected,process=proc,correct=False)
    if child.exists():
     r['child']=json.loads(child.read_text());words=r['child']['stdout'].strip().splitlines()
     if len(words)==4 and all(w.isdecimal() for w in words):
      r['observed']=list(map(int,words));r['correct']=proc['complete'] and r['observed'][:3]==expected
      r['elapsedMs']=r['observed'][3]
      r['validClock']=0<r['elapsedMs']<=r['child']['processSeconds']*1000+2
      r['timingQualified']=r['correct'] and r['validClock'] and r['elapsedMs']>=100
    records.append(r)
    s.save(a.out/'report.json',dict(kind='fixed-work-timing' if plans else 'calibration',started=started,finished=time.time(),artifacts=artifacts,
      inputs=frozenInputs,plan=str(a.plan) if plans else None,records=records))
    print(json.dumps({k:r.get(k) for k in ['case','role','target','round','repetitions','correct','elapsedMs','validClock']}),flush=True)
    if not r['correct']:raise SystemExit('Correctness failure; stop timing')
    if guard.interrupted:raise SystemExit(1)
if not plans:
 plans={}
 for case in cases:
  rows=[r for r in records if r['case']==case['name']]
  if not rows:continue
  low=min(max(1,r['elapsedMs']) for r in rows);high=max(max(1,r['elapsedMs']) for r in rows)
  # Fixed inputs/counts across roles. Bound slowest prediction to 8 seconds.
  count=rows[0]['repetitions']
  n=max(32,min(100000,math.ceil(120/low*count/16)*16,math.floor(8000/high*count/16)*16))
  plans[case['name']]=dict(repetitions=n,warmups=n,targetFastMs=120,maxPredictedSlowMs=8000,
      calibrationMinMs=low,calibrationMaxMs=high,predictedFastMs=low*n/count,predictedSlowMs=high*n/count,calibrationRepetitions=count,
      feasiblePredicted=low*n/count>=100 and high*n/count<=8000,
      warmupPolicy='Same fixed count as measured batch; no claim of JIT stationarity')
 s.save(a.out/'plan.json',plans)

for item in oracles['inputs']:
 assert s.identity(item['path'])['sha256']==item['sha256']
for artifact in artifacts.values():assert s.identity(artifact['path'])==artifact['identity']
if plans and a.plan and not all(r.get('validClock',False) for r in records):raise SystemExit('Invalid final clock observations; retained as inconclusive')

for item in frozenInputs:assert s.identity(item['path'])==item
