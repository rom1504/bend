#!/usr/bin/env python3
"""Write honest image bindings and replay argv; never launch a compiler."""
import argparse, hashlib, json, shlex, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];RAW=ROOT/'selfhost/build/phase61'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path)
p.add_argument('--method',type=Path,default=RAW/'latency-method05')
p.add_argument('--image',choices=['b1','b2'],default='b2')
p.add_argument('--candidate-attempt',type=Path);p.add_argument('--candidate-emission',type=Path)
p.add_argument('--candidate-admission',type=Path)
p.add_argument('--candidate-roots-reference',type=Path)
p.add_argument('--baseline-attempt',type=Path,default=ROOT/'selfhost/build/phase58/checked-last01/attempt.json')
p.add_argument('--baseline-emission',type=Path,default=ROOT/'selfhost/build/phase58/final-last01/bootstrap/full/report.json')
p.add_argument('--diagnostic',type=Path,help='Saved-image derivative of selected baseline B2; explicitly unqualified')
p.add_argument('--candidate-oracles',type=Path,help='Reviewed image-bound candidate qualification packet; default requires frozen catalog bytes')
p.add_argument('--without-typescript',action='store_true')
a=p.parse_args();out=a.out.resolve();assert RAW.is_dir() and out.is_relative_to(RAW.resolve()) and not out.exists()
inputs={}
def identity(file):
 file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest())
def pin(value):
 actual=identity(value['file'] if isinstance(value,dict) else value)
 if isinstance(value,dict):assert actual['sha256']==value['sha256']
 inputs[actual['file']]=actual;return actual
def read(value):return json.loads(Path(pin(value)['file']).read_text())
def checked(file):
 file=file/'attempt.json' if file.is_dir() else file
 item=pin(file);d=read(item);assert Path(item['file']).name=='attempt.json'
 assert d['checked'] is True and isinstance(d['config']['strictExact'],bool)
 for k in ['api','checkedApi','bootstrapReport','runtime','base']:pin(d[k])
 boot=read(d['bootstrapReport']);assert pin(boot['source'])['sha256']==boot['sourceSha256']
 return {'kind':'checked','attempt':item},d
def emission(file,spec,attempt):
 item=pin(file);d=read(item)
 assert d['kind']=='phase55-split-compiler-emission' and d['complete'] is True and d['pass'] is True
 assert pin(d['generator']['attempt'])==spec['attempt']
 for key in ['api','runtime']:assert pin(d['generator'][key])==pin(attempt[key])
 assert pin(d['generator']['bootstrap'])==pin(attempt['bootstrapReport'])
 assert d['checking']['lane']=='inherited-exact-bootstrap' and d['checking']['freshSelfCheck'] is False
 assert d['checking']['sourceSha256']==pin(d['subject']['source'])['sha256']
 pin(d['module']);pin(d['directRuntime'])
 return dict(kind='direct',attempt=spec['attempt'],emission=item)
baseline,old=checked(a.baseline_attempt)
if a.image=='b2':baseline=emission(a.baseline_emission,baseline,old)
roles={'baseline':baseline};comparison='fixed-source'
assert not (a.diagnostic and a.candidate_attempt)
assert bool(a.candidate_admission)==bool(a.candidate_roots_reference)
assert not a.candidate_admission or a.candidate_attempt
if a.candidate_attempt:
 candidate,new=checked(a.candidate_attempt)
 if a.image=='b2':
  assert a.candidate_emission,'Genuine B2 needs its complete emission receipt; use --image b1 before it exists'
  candidate=emission(a.candidate_emission,candidate,new)
 else:assert not a.candidate_emission
 if a.candidate_admission:
  admission_id=pin(a.candidate_admission);admission=read(admission_id)
  reference_id=pin(a.candidate_roots_reference);reference=read(reference_id)
  assert admission['kind']=='phase61-bootstrap-export-admission' and admission['version']==1
  assert reference['kind']=='phase61-checked-bootstrap-export-reference'
  assert reference['admission']==admission_id and reference['attempt']==candidate['attempt']
  assert pin(reference['bootstrap'])==pin(new['bootstrapReport'])
  assert reference['roots']==read(new['bootstrapReport'])['exports']
  assert pin(Path(new['snapshot']['root'])/'tools/typed-driver.mjs')['sha256']==pin(admission['driver'])['sha256']
  pin(reference['historical'])
  candidate={**candidate,'admission':admission_id,'rootsReference':reference_id}
 roles['candidate']=candidate;comparison='changed-source'
elif a.diagnostic:
 assert a.image=='b2' and not a.candidate_emission
 item=pin(a.diagnostic);d=read(item)
 assert d['complete'] is True and d['pass'] is True and d['diagnosticOnly'] is True and d['productionQualified'] is False
 assert isinstance(d['kind'],str) and isinstance(d['scope'],str)
 b=read(baseline['emission']);assert pin(d['parent'])==pin(b['module'])
 for key in ['output','producer','runtime']:pin(d[key])
 roles['candidate']=dict(kind='syntax',parentRole='baseline',derivation=item,receiptKind=d['kind'])
else:assert not a.candidate_emission and not a.candidate_oracles
policies={name:dict(kind='catalog',referenceRole='direct') for name in roles}
if a.candidate_oracles:
 assert 'candidate' in roles
 q=read(a.candidate_oracles);assert q['kind']=='phase61-qualified-compiler-output-oracles' and q['complete'] and q['pass']
 policies['candidate']=dict(kind='qualified',manifest=pin(a.candidate_oracles))
binding=dict(kind='phase61-compiler-image-bindings',version=1,comparison=comparison,roles=roles,outputPolicies=policies,
 scope='Real checked B1 / genuine own-source B2 or explicitly diagnostic saved image. No semantic qualification, installation, fixed point or speed claim from bindings alone.')
method=a.method.resolve();derivation=read(method/'derivation.json')
assert derivation['kind']=='phase61-candidate-fast-loop-method' and derivation['complete'] and derivation['pass']
for d in derivation['derivations']:pin(d['parent']);pin(d['output'])
runner=pin(method/'run.py');pin(derivation['producer']);producer=pin(__file__)
subset=pin(HERE.parents[1]/'phase60/analysis/fast-subsets-v1.json')
role_list=list(roles)+([] if a.without_typescript else ['typescript']);assert len(role_list)>=2
common=['--bindings',str(out/'bindings.json'),'--roles',','.join(role_list)]
base=[sys.executable,runner['file']];prep=out/'preparation'
commands={'prepare':base+[str(prep),*common,'--cases','all','--prepare-only','--seconds','180']}
for label,cases,rounds,seconds,warm in [
 ('screen20','numeric-recurrence,test-map-set-ops',1,20 if len(role_list)==2 else 35,0),
 ('screen60','numeric-recurrence,test-map-set-ops,raytrace-active',2,60 if len(role_list)==2 else 90,0),
 ('heldout','lexer,test-evening-program',3,180,0),('all','all',3,1200,3)]:
 commands[label]=base+[str(out/label),*common,'--preparations',str(prep/'report.json'),'--cases',cases,
  '--rounds',str(rounds),'--warm-requests',str(warm),'--seconds',str(seconds)]
for mode in ['cpu','allocation']:
 commands[mode]=base+[str(out/mode),*common,'--preparations',str(prep/'report.json'),
  '--cases','numeric-recurrence,test-map-set-ops','--rounds','1','--warm-requests','0','--mode',mode,'--seconds','90']
for x in inputs.values():assert identity(x['file'])==x
out.mkdir(parents=True);(out/'bindings.json').write_text(json.dumps(binding,indent=2)+'\n')
report=dict(kind='phase61-fast-loop-recipe',complete=True,dataOnly=True,targetExecuted=False,
 producer=producer,inputs=list(inputs.values()),bindings=identity(out/'bindings.json'),commands=commands,
 image=a.image,roles=role_list,candidatePending='candidate' not in roles,
 scope='20/60 labels retain tested Phase60 coverage, not guaranteed time. Three roles get larger explicit deadlines. Reusable Base preparation excluded. Profiles first-window only, not clean speed. No new runtime executions; complete emitted-byte checks after windows. Full23 remains population gate.')
report['pass']=True;(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
(out/'commands.txt').write_text('\n\n'.join('# '+k+'\n'+shlex.join(v) for k,v in commands.items())+'\n')
print(json.dumps(dict(report=identity(out/'report.json'),roles=role_list,candidatePending=report['candidatePending'])))
