#!/usr/bin/env python3
"""Bind actual checked/emitted candidates after their own point-qualified module acquisition."""
import argparse, hashlib, json, shlex, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase66'
inputs={}
def pin(value):
    p=Path(value.get('file',value.get('path')) if isinstance(value,dict) else value).resolve(strict=True)
    x=dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
    if isinstance(value,dict):assert x['sha256']==value['sha256']
    inputs[str(p)]=x;return x
def read(x):return json.loads(Path(pin(x)['file']).read_text())
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt',type=Path,required=True);p.add_argument('--oracles',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--method',type=Path,default=RAW/'latency-method04')
p.add_argument('--image',choices=['b1','b2'],default='b1');p.add_argument('--emission',type=Path)
p.add_argument('--admission',type=Path);p.add_argument('--roots-reference',type=Path)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
attempt_id=pin(a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt);attempt=read(attempt_id)
assert attempt['checked'] and attempt['artifactKind'] in ['checked-b1','derived-b1']
boot=read(attempt['bootstrapReport']);assert boot['revision']=='059266225b77c8ca256ac6b25ee5c21449bab151'
source=pin(boot['source']);assert source['sha256']==boot['sourceSha256']
baseline=read(ROOT/'selfhost/build/phase65/state10-b2-latency/bindings.json')['roles']['candidate']
assert baseline['kind']=='direct';old=read(baseline['attempt'])
assert pin(old['api'])['sha256']=='3a7fedb77003aecc797cd9a9ac4c6d1bd15bd21dd1230806b6719565eca10f72'
assert pin(read(baseline['emission'])['module'])['sha256']=='239f79702c13339d1044e7fe497c4946299d36ce2d7b5eb7850d0d43514a8fae'
candidate=dict(kind='checked',attempt=attempt_id)
selected=pin(attempt['api'])
if a.image=='b1':
    assert not a.emission;baseline={k:v for k,v in baseline.items() if k!='emission'};baseline['kind']='checked'
else:
    assert a.emission;e_id=pin(a.emission);e=read(e_id)
    assert e['kind']=='phase55-split-compiler-emission' and e['complete'] and e['pass']
    assert pin(e['generator']['attempt'])==attempt_id and pin(e['generator']['api'])==pin(attempt['api'])
    assert pin(e['subject']['source'])==source and e['checking']['lane']=='inherited-exact-bootstrap'
    candidate.update(kind='direct',emission=e_id);selected=pin(e['module'])
assert bool(a.admission)==bool(a.roots_reference)
if a.admission:
    admission_id=pin(a.admission);reference_id=pin(a.roots_reference);admission=read(admission_id);reference=read(reference_id)
    assert reference['attempt']==attempt_id and reference['admission']==admission_id and reference['roots']==boot['exports']
    assert pin(admission['driver'])['sha256']==pin(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs')['sha256']
    candidate.update(admission=admission_id,rootsReference=reference_id)
q_id=pin(a.oracles);q=read(q_id)
assert q['kind']=='phase61-qualified-compiler-output-oracles' and q['complete'] and q['pass'] and q['backend']=='direct'
assert pin(q['image']['api'])==selected and pin(q['image']['source'])==source
for key in ['runtime','base']:assert pin(q['image'][key])['sha256']==pin(attempt[key])['sha256']
for key,file in [('driver','tools/typed-driver.mjs'),('directRuntime','src/runtime/js/direct.mjs')]:
    assert pin(q['image'][key])['sha256']==pin(Path(attempt['snapshot']['root'])/file)['sha256']
catalog=read(ROOT/'selfhost/tools/performance/phase60/catalog.json');available={x['id'] for x in q['cases']}
assert available and len(available)==len(q['cases']) and available<={x['id'] for x in catalog['compileInputs']}
ordered=[x['id'] for x in catalog['compileInputs'] if x['id'] in available]
binding=dict(kind='phase61-compiler-image-bindings',version=1,comparison='changed-source',roles=dict(baseline=baseline,candidate=candidate),
    outputPolicies=dict(baseline=dict(kind='catalog',referenceRole='direct'),candidate=dict(kind='qualified',manifest=q_id)),
    scope='Actual old and new compiler generation with their own Base/host; no raw output cross-target equivalence presumed.')
method=a.method.resolve();m=read(method/'derivation.json');assert m['complete'] and m['pass']
for row in m['derivations']:assert pin(row['output'])==row['output']
head_id=pin(RAW/'head-ts-oracles01.json');head=read(head_id);assert head['complete'] and head['pass']
roles=['baseline','candidate','typescript_head'];runner=pin(method/'run.py')
common=[sys.executable,runner['file'],'PLACEHOLDER','--bindings',str(out/'bindings.json'),'--roles',','.join(roles),'--head-oracles',head_id['file']]
commands={}
def command(label,cases,rounds=3,prepare=False):
    cmd=common.copy();cmd[2]=str(out/label);cmd+=['--cases',','.join(cases),'--seconds','600' if len(cases)==23 else '180']
    cmd+=['--prepare-only'] if prepare else ['--preparations',str(out/'preparation/report.json'),'--rounds',str(rounds),'--warm-requests','0']
    commands[label]=cmd
command('preparation',ordered,prepare=True)
four=['numeric-recurrence','lexer','test-map-set-ops','raytrace-active']
if set(four)<=available:command('four',four)
screen=['numeric-recurrence','test-map-set-ops']
if set(screen)<=available:command('screen',screen,1)
if len(available)==23:command('broad',ordered)
out.mkdir(parents=True);(out/'bindings.json').write_text(json.dumps(binding,indent=2)+'\n')
recipe=dict(kind='phase66-qualified-candidate-latency-recipe',complete=True,dataOnly=True,targetExecuted=False,producer=pin(__file__),
    method=pin(method/'derivation.json'),bindings=pin(out/'bindings.json'),inputs=list(inputs.values()),roles=roles,image=a.image,
    qualifiedSources=ordered,commands=commands,scope='Three roles/three cyclic rounds for four or broad; screen one triple/source only. Cache/products prepared outside clocks. No unqualified source can be timed by this recipe.')
(out/'recipe.json').write_text(json.dumps(recipe,indent=2)+'\n');(out/'commands.txt').write_text('\n\n'.join('# '+k+'\n'+shlex.join(v) for k,v in commands.items())+'\n')
print(json.dumps(dict(recipe=pin(out/'recipe.json'))))
