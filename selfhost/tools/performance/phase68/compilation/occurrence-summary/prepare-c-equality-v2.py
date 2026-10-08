#!/usr/bin/env python3
"""Freeze an actual selected B1 emission-only successor; CPU0 data, no targets."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]
RAW=ROOT/'selfhost/build/phase68'
inputs={}


def pin(value):
    expected=value if isinstance(value,dict) else None
    p=Path(expected.get('file',expected.get('path')) if expected else value).resolve(strict=True)
    b=p.read_bytes();result=dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
    if expected:
        assert result['sha256']==expected['sha256']
        assert 'bytes' not in expected or result['bytes']==expected['bytes']
    inputs[str(p)]=result
    return result


def read(value):
    return json.loads(Path(pin(value)['path']).read_text())


p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
attempt_pin=pin(a.attempt);attempt=read(a.attempt)
assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind']=='derived-b1'
for item in attempt['snapshot']['sources']:pin(item['frozen'])
for key in ['checkedApi','derivationReport','bootstrapReport','base','runtime','node']:pin(attempt[key])
api=pin(attempt['api'])
strict=pin(a.attempt.parent/'validation-001/report.json');assert read(strict)['complete']
parent=read(RAW/'admission-c07/plan.json');closed=read(RAW/'admission-c07/report.json')
assert closed['complete'] and closed['passAll'] and len(closed['rows'])==3 and all(x['equal'] for x in closed['rows'])
assert pin(closed['plan'])==pin(RAW/'admission-c07/plan.json')
recipe=read(parent['recipe']);old_api=recipe['api']
assert sum(x['path']==old_api for x in recipe['inputs'])==1
for value in recipe['inputs']:pin(value)
recipe['api']=api['path'];recipe['verifyInstalled']=False
recipe['inputs']=[api if x['path']==old_api else x for x in recipe['inputs']]
pin(__file__);pin(ROOT/'selfhost/tools/performance/phase46/job.py')
pin(ROOT/'selfhost/tools/performance/phase67/benchmark/emit.mjs')
out.mkdir(parents=True);recipe_path=out/'recipe.json'
recipe_path.write_text(json.dumps(recipe,indent=2)+'\n');pin(recipe_path)
jobs=[]
for original in parent['jobs']:
    case=original['case'];proof=next(x for x in closed['rows'] if x['case']==case)
    baseline=pin(original['baselineIdentity']);pin(original['baselineEmission'])
    emitted=read(proof['emission']);assert emitted['complete']
    assert pin(emitted['output'])['sha256']==baseline['sha256']==proof['sha256']
    destination=out/case/'program.c';job=copy.deepcopy(original)
    changes={parent['recipe']:str(recipe_path),original['output']:str(destination),
        str(Path(original['output']).parent/'supervisor'):str(destination.parent/'supervisor')}
    job['command']=[changes.get(x,x) for x in job['command']]
    job['output']=str(destination);jobs.append(job)
plan=dict(kind='phase68-emission-only-occurrence-equality',recipe=str(recipe_path),jobs=jobs,
    attempt=attempt_pin,api=api,strict=strict,inputs=list(inputs.values()),targetExecuted=False,
    scope='Same reviewed Phase67 emission worker and one Phase46 guard per job. Actual selected C must equal runtime-qualified06 C, also reproduced by07. Prior producer identities remain unchanged. No Clang or executable target, no timing claim before execution.')
path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n')
print(json.dumps(dict(plan=pin(path),jobs=len(jobs),targetExecuted=False)))
