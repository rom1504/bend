#!/usr/bin/env python3
"""Compare saved Phase70 compiler02/candidate/upstream C binaries; one guarded CPU3 lane."""
import argparse, importlib.util, json, math, statistics, time
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend')
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=module('support',ROOT/'selfhost/tools/performance/programs/support.py')
O=module('oracle',ROOT/'selfhost/tools/performance/phase46/oracle.py')
read=lambda p:json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--cases',default='numeric,array,closures,tree,map,lexer');p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
assert a.rounds>0
pins=[S.identity(__file__),S.identity(ROOT/'selfhost/tools/performance/phase46/oracle.py')]
products={}
paths=[('baseline72',ROOT/'selfhost/build/phase72/compiler02-native06/report.json')]
paths += [('upstream',ROOT/'selfhost/build/phase67'/n/'report.json') for n in ['native-baseline02','native-heldout-baseline02']]
paths += [('candidate',v/'report.json' if v.is_dir() else v) for v in a.candidate]
for role,path in paths:
 report=read(path);assert report['complete'];pins += [S.identity(path),report['recipe']]
 recipe=read(report['recipe']['path'])
 assert recipe['upstreamCommit']=='059266225b77c8ca256ac6b25ee5c21449bab151'
 if role=='candidate':
  pins += recipe['inputs']
 for row in report['records']:
  if row['role']!=('upstream' if role=='upstream' else 'selfhost'):continue
  assert row['correct'];key=(row['case'],role);assert key not in products
  for field in ('source','nativeSource','executable','emissionReceipt'):pins.append(row[field])
  emission=read(row['emissionReceipt']['path']);assert emission['complete'] and emission['output']==row['nativeSource']
  products[key]=dict(row,recipe=recipe)
names=a.cases.split(',');counts={'numeric':77504,'array':61440,'closures':57888,'tree':1280,'map':1152,'lexer':448}
plan={n:dict(repetitions=counts[n],warmups=(counts[n]//8//16)*16) for n in names}
catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')}
for name in names:
 rows=[products[(name,r)] for r in ['baseline72','candidate','upstream']]
 assert all(row['source']==rows[0]['source'] for row in rows)
 for field in ('clang','clangArgs','linkArgs','cpu','compilerEnvironment'):
  assert all(row['recipe'][field]==rows[0]['recipe'][field] for row in rows),field
for pin in pins:assert S.identity(pin['path'])==pin,pin['path']
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase73');out.mkdir(exist_ok=False)
S.save(out/'plan.json',dict(inputs=pins,counts=plan,rounds=a.rounds,roles=['baseline72','candidate','upstream'],scope='Fresh balanced saved-binary timings, identical sources and Clang recipe; compiler/runtime changes intentional. Old emission provenance preserved, no historical target reruns.'))
report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),records=[])
try:
 with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  for name in names:
   n,warm=plan[name]['repetitions'],plan[name]['warmups'];values=O.points(catalog[name]);expected=[catalog[name]['expected'],O.digest(values,warm),O.digest(values,n)]
   for round in range(a.rounds):
    roles=['baseline72','candidate','upstream'];roles=roles[round%3:]+roles[:round%3]
    for role in roles:
     dest=out/(name+'-'+role+'-'+str(round));binary=products[(name,role)]['executable'];assert S.identity(binary['path'])==binary
     command=['taskset','-c','3','python3',str(ROOT/'selfhost/tools/performance/phase46/execute.py'),str(dest/'child.json'),binary['path'],'--threads','1','--gpu','off','--',str(n),str(warm)]
     row=dict(case=name,role=role,round=round,repetitions=n,warmups=warm,expected=expected)
     row['process']=guard.run(command,dest,time.monotonic()+45);row['child']=read(dest/'child.json')
     words=row['child']['stdout'].strip().splitlines();row['correct']=row['process']['complete'] and row['child']['returncode']==0 and not row['child']['stderr'] and len(words)==4 and all(s.isdecimal() for s in words) and list(map(int,words[:3]))==expected
     if row['correct']:row['elapsedMs']=int(words[3])
     row['qualified']=row['correct'] and 100<=row['elapsedMs']<=row['child']['processSeconds']*1000+2
     report['records'].append(row);S.save(out/'report.json',report);print(json.dumps({k:row[k] for k in ['case','role','round','correct','qualified']}),flush=True)
     assert row['correct'] and row['qualified'],row
 for pin in pins:assert S.identity(pin['path'])==pin,pin['path']
 report['rows']=[]
 for name in names:
  ms={role:statistics.median(r['elapsedMs'] for r in report['records'] if r['case']==name and r['role']==role) for role in ['baseline72','candidate','upstream']}
  report['rows'].append(dict(case=name,mediansMs=ms,candidateOverUpstream=ms['candidate']/ms['upstream'],baseline72OverCandidate=ms['baseline72']/ms['candidate']))
 report['geomeanCandidateOverUpstream']=math.exp(statistics.mean(math.log(r['candidateOverUpstream']) for r in report['rows']))
 report['geomeanBaseline69OverCandidate']=math.exp(statistics.mean(math.log(r['baseline72OverCandidate']) for r in report['rows']))
 report['complete']=True
finally:
 report['finished']=time.time();S.save(out/'report.json',report)
print(json.dumps(report['rows']))
