#!/usr/bin/env python3
"""Rebind the maintained 81-outcome backend census; data only, no target jobs."""
import argparse, copy, hashlib, json
from pathlib import Path

HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('attempt',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
attempt=a.attempt.resolve(strict=True);out=a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase51') and not out.exists()
assert not out.is_relative_to(attempt)
inputs={}
def pin(file,want=None):
 file=Path(file).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for chunk in iter(lambda:stream.read(2**20),b''):h.update(chunk)
 row=dict(file=str(file),sha256=h.hexdigest(),bytes=file.stat().st_size)
 if want:
  for k in ['sha256','bytes']:
   if k in want:assert row[k]==want[k],str(file)
  if want.get('canonicalPath'):assert str(file)==want['canonicalPath']
 if str(file) in inputs:assert row==inputs[str(file)]
 inputs[str(file)]=row;return row
def read(file):pin(file);return json.loads(Path(file).read_text())
def audit(v):
 if isinstance(v,list):
  for child in v:audit(child)
 elif isinstance(v,dict):
  file=v.get('file',v.get('canonicalPath',v.get('path')))
  if isinstance(file,str) and 'sha256' in v:pin(file,v)
  for child in v.values():audit(child)
def save(file,value):
 with file.open('x') as stream:json.dump(value,stream,indent=2);stream.write('\n')
pin(__file__);methodParent=pin(HERE.parent/'phase48/backend-plan.py',{'sha256':'815f82b615d2350e1eceb1f34e1e011c415ead4ddb79a50df59ba3c950d542fa'});manifest=read(attempt/'attempt.json')
assert manifest['checked'] and manifest['config']['strictExact'];audit(manifest)
focused=read(attempt/'validation-001/report.json');audit(focused)
assert focused['complete'] and focused['pass'] and focused['strictExact']
assert focused['attempt']['sha256']==pin(attempt/'attempt.json')['sha256']
assert focused['api']['sha256']==manifest['api']['sha256']
source=Path(manifest['config']['project']).resolve(strict=True)
snapshot=Path(manifest['snapshot']['root']).resolve(strict=True)
assert not out.is_relative_to(source)
compiler=read(snapshot/'src/compiler.json')
assert compiler['upstream']=='018751270e800bc222a93dad7f257083ee53a5f7'
bound=set()
for row in manifest['snapshot']['sources']:
 relative=Path(row['original']['file']).relative_to(source)
 assert Path(row['frozen']['file'])==snapshot/relative
 assert row['original']['sha256']==row['frozen']['sha256'];bound.add(str(relative))
assert set(compiler['modules'])|{'src/compiler.json','src/runtime.mjs'}<=bound
parent=ROOT/'selfhost/build/phase45/qualification23/backend/pilot.json'
pilot=read(parent);audit(pilot)
assert pilot['kind']=='phase30-retained-backend-renewal-plan'
assert pilot['complete'] and not pilot['executed'] and pilot['campaign']=='pilot'
assert pilot['expectedRows']==81 and pilot['expectedCounts']=={'pass':69,'not-applicable':8,'fail':4}
assert pilot['cpu']=='3' and pilot['jobs']==1 and len(pilot['batches'])==7
assert pilot['outerTimeoutSeconds']==900 and pilot['terminationGraceSeconds']==3
history=read(pilot['historicalRows']['file'])
assert pin(pilot['historicalRows']['file'])['sha256']=='22c2aded526f69e550d8f8da4151efdc38ae65ce13b162106a8967ba6db357b1'
assert len(history)==len({(r['id'],r['lane']) for r in history})==81
assert sum(len(b['cases']) for b in pilot['batches'])==81
tools=ROOT/'selfhost/build/phase43/integration01/final-plan/tools'
runner=pin(tools/'backend-run.py',{'sha256':'739a392b91dd2566169f8cdb516276610f9a75e6fb7afac212a19a8ef87fcc0d'})
helper=pin(tools/'backend-census.py',{'sha256':'2dc3fe206f950841181e3673bd43c7d7dc42e99a00160522314b2333677deb72'})
new=copy.deepcopy(pilot);new['attempt']=pin(attempt/'attempt.json')
old_attempt=str(Path(pilot['attempt']['file']).parent)
for b in new['batches']:
 command=b['command'];assert len(command)==8 and command[1]==helper['file']
 assert command[2]=='candidate' and command[4]=='pilot' and command[5]==str(b['index'])
 assert command[6]==b['output'] and command[7]==old_attempt
 assert str(Path(command[3]).resolve()) in inputs
 assert Path(b['name']).name==b['name'] and b['name'] not in ['.','..']
 b['output']=str(out/'pilot'/b['name']);b['command']=command[:6]+[b['output'],str(attempt)]
assert {k:v for k,v in new.items() if k not in ['attempt','inputs','batches']}=={
 k:v for k,v in pilot.items() if k not in ['attempt','inputs','batches']}
new['inputs']=list(inputs.values())
for row in list(inputs.values()):pin(row['file'],row)
out.mkdir(parents=True);save(out/'pilot.json',new)
save(out/'preparation.json',dict(kind='phase51-backend-plan-binding',complete=True,executed=False,
 selectedAttempt=pin(attempt/'attempt.json'),selectedApi=pin(manifest['api']['file']),
 selectedRuntime=pin(manifest['runtime']['file']),methodParent=methodParent,parent=pin(parent),runner=runner,helper=helper,
 inputs=list(inputs.values()),output=pin(out/'pilot.json'),sourceBindings=len(bound),expectedRows=81,
 scope='Candidate and fresh output rebinding only. Historical seven batches, fixture selection, expected outcomes, tools and deadlines unchanged. No frontend gate or target execution.'))
print(json.dumps(dict(complete=True,executed=False,plan=str(out/'pilot.json'),runner=runner['file'],expectedRows=81)))
