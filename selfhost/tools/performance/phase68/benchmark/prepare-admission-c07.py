#!/usr/bin/env python3
"""Prepare only: reuse the reviewed emission worker for exact 06/07 C equality."""
import hashlib, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase68'
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return {'path':str(p),'sha256':h.hexdigest(),'bytes':p.stat().st_size}
def read(p):return json.loads(Path(p).read_text())
previous=RAW/'templates-c05/plan.json';prior=read(previous)
attempt_path=RAW/'admission-build07/attempt.json';attempt=read(attempt_path)
assert attempt['checked'] is True and attempt['artifactKind']=='derived-b1'
api=Path(attempt['api']['file']);assert pin(api)['sha256']==attempt['api']['sha256']=='d647757d2fd4c0e72facd7165c7da9eb24c0f8c6991cd2c8c80024a4e16d4da5'
snapshots=[]
for item in attempt['snapshot']['sources']:
 row=pin(item['frozen']['file']);assert row['sha256']==item['frozen']['sha256'];snapshots.append(row)
strict=RAW/'admission-build07/validation-001/report.json';s=read(strict)
assert s.get('complete') is True, 'Strict checked qualification must be complete'
baseline_report=RAW/'native-flat06/report.json';b=read(baseline_report);assert b['complete'] is True
records={r['case']:r for r in b['records'] if r['role']=='selfhost'}
assert {'numeric','array','lexer'}<=records.keys()
recipe=RAW/'native-admission07-recipe.json';out=RAW/'admission-c07'
assert not recipe.exists() and not out.exists()
freezer=ROOT/'selfhost/tools/performance/phase67/benchmark/freeze.py'
subprocess.run(['python3',str(freezer),'--out',str(recipe),'--api',str(api)],check=True)
r=read(recipe);assert r['api']==str(api) and r['cpu']==3
for item in r['inputs']:assert pin(item['path'])==item
out.mkdir()
plan={**prior,'kind':'phase68-emission-only-admission-equality','recipe':str(recipe),'jobs':[],'scope':'Unchanged reviewed Phase67 emit worker with one Phase46 guard per job. New checked07 C compared in full with actually compiled/executed06 C. No new Clang/runtime targets; no timing or equality claim before execution.'}
for j in prior['jobs']:
 case=j['case'];assert records[case]['correct'] is True
 base=RAW/'native-flat06'/(case+'-selfhost')/'program.c';emission=read(str(base)+'.json')
 assert emission['complete'] is True and pin(base)==emission['output']
 destination=out/case/'program.c';command=list(j['command'])
 replacements={j['output']:str(destination),str(Path(j['output']).parent/'supervisor'):str(destination.parent/'supervisor'),prior['recipe']:str(recipe)}
 command=[replacements.get(arg,arg) for arg in command]
 assert command.count(str(ROOT/'selfhost/tools/performance/phase46/job.py'))==1
 assert command.count(str(ROOT/'selfhost/tools/performance/phase67/benchmark/emit.mjs'))==1
 plan['jobs'].append({**j,'command':command,'baseline':str(base),'baselineIdentity':pin(base),'baselineEmission':pin(str(base)+'.json'),'output':str(destination)})
plan['inputs']=[pin(previous),pin(Path(__file__)),pin(freezer),pin(recipe),pin(attempt_path),pin(strict),pin(api),pin(baseline_report),pin(ROOT/'selfhost/tools/performance/phase46/job.py'),pin(ROOT/'selfhost/tools/performance/phase67/benchmark/emit.mjs'),*snapshots]
plan['targetExecuted']=False
plan['verification']='After all jobs close: require complete checked emission receipts, unchanged pins, and byte-for-byte output==baseline for all three full C files. Do not infer native equality from only successful source checking.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(json.dumps({'plan':pin(out/'plan.json'),'recipe':pin(recipe),'jobs':len(plan['jobs']),'frozenSourcesVerified':len(snapshots),'targetExecuted':False}))
