#!/usr/bin/env python3
"""Short paired B1 request screen; startup/Base/Clang are separate clocks."""
import argparse, importlib.util, json, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('support', ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
p=argparse.ArgumentParser();p.add_argument('--candidate',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase72');out.mkdir(exist_ok=False)
recipes={'baseline':ROOT/'selfhost/build/phase70/compiler03-recipe.json','candidate':a.candidate.resolve()}
acquired={'baseline':ROOT/'selfhost/build/phase70/compiler02-native06/report.json','candidate':ROOT/'selfhost/build/phase72/compiler02-native06/report.json'}
case='numeric';oracles={}
for role,path in acquired.items():
 r=json.loads(path.read_text());assert r['complete']
 row=next(x for x in r['records'] if x['case']==case and x['role']=='selfhost');assert row['correct']
 oracles[role]=row
report=dict(complete=False,producer=S.identity(__file__),recipes={k:S.identity(v) for k,v in recipes.items()},oracles=oracles,records=[],clock='Fresh-process load/check/C emission, prepared Base excluded; no Clang or execution.')
def save():S.save(out/'report.json',report)
save()
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 for round in range(a.rounds):
  for role in (['baseline','candidate'] if round%2==0 else ['candidate','baseline']):
   r=json.loads(recipes[role].read_text());dest=out/f'{round}-{role}';dest.mkdir();target=dest/'program.c'
   cmd=['taskset','-c','3',r['node'],*r['nodeArgs'],str(ROOT/'selfhost/tools/performance/phase71/emit.mjs'),str(recipes[role]),'selfhost',oracles[role]['source']['path'],str(target)]
   result=guard.run(cmd,dest/'guard',time.monotonic()+60)
   row=dict(role=role,round=round,guard=result);report['records'].append(row);save()
   assert result['complete'],dest
   obs=json.loads(Path(str(target)+'.json').read_text());row['receipt']=S.identity(str(target)+'.json')
   row['correct']=obs['complete'] and S.identity(target)['sha256']==oracles[role]['nativeSource']['sha256']
   row['timings']=obs['timings'];save();assert row['correct'],dest
   print(json.dumps(dict(role=role,round=round,requestMs=row['timings']['loadCheckEmitMs'])),flush=True)
report['mediansMs']={r:statistics.median(x['timings']['loadCheckEmitMs'] for x in report['records'] if x['role']==r) for r in recipes}
report['candidateOverBaseline']=report['mediansMs']['candidate']/report['mediansMs']['baseline'];report['complete']=True;save();print(json.dumps(report['mediansMs']))
