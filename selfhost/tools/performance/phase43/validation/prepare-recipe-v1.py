#!/usr/bin/env python3
"""Verify a checked attempt and rebind the repaired Phase42 release recipe; run no targets."""
import argparse, copy, hashlib, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
PARENT=ROOT/'selfhost/build/phase42/final-recipe07.json'
PARENT_SHA='ddae5d9f1a600515083c51252a41a35f07aac23d62ab6b45241ddf9f5c8e3cd8'
PIN='018751270e800bc222a93dad7f257083ee53a5f7'
def ident(p):
 p=Path(p).resolve();raw=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))
def main():
 p=argparse.ArgumentParser(description=__doc__)
 for key in ['attempt','out','recipe']:p.add_argument('--'+key,type=Path,required=True)
 p.add_argument('--extension',type=Path,help='Reviewed new-owner contract with steps and requirements; required for final promotion')
 a=p.parse_args();attempt=a.attempt.resolve();out=a.out.resolve();dest=a.recipe.resolve()
 assert not out.exists() and not dest.exists() and not dest.is_relative_to(out)
 assert out.is_relative_to(ROOT/'selfhost/build/phase43') and attempt.is_relative_to(ROOT/'selfhost/build/phase43')
 assert ident(PARENT)['sha256']==PARENT_SHA
 old=json.loads(PARENT.read_text());m=json.loads((attempt/'attempt.json').read_text())
 assert m['checked'] and m['kind']=='bend-development-attempt'
 assert m['node']['version']=='v24.18.0' and ident(m['node']['file'])['sha256']==m['node']['sha256']
 assert Path(m['config']['upstream']).resolve()==ROOT/'selfhost/.bootstrap/upstream-phase23'
 assert subprocess.check_output(['git','-C',m['config']['upstream'],'rev-parse','HEAD'],text=True).strip()==PIN
 code='const w=await import(process.argv[1]);const m=await w.verifyAttempt(process.argv[2]);console.log(JSON.stringify({checked:m.checked,api:m.api}));'
 v=json.loads(subprocess.check_output([m['node']['file'],'--input-type=module','-e',code,(ROOT/'selfhost/tools/development/workflow.mjs').as_uri(),str(attempt)],text=True))
 assert v['checked'] and v['api']==m['api']
 b=dict(old['bindings']);b.update(ATTEMPT=str(attempt),OUT=str(out),NODE=m['node']['file'],API=m['api']['file'],API_SHA=m['api']['sha256'],ATTEMPT_SHA=ident(attempt/'attempt.json')['sha256'],RUNTIME=m['runtime']['file'],RUNTIME_SHA=m['runtime']['sha256'],BASE_SHA=m['base']['sha256'])
 for key in ['DERIVED','PLAN','FULL','FULLDIR','HIST']:b[key]=old['bindings'][key].replace(old['bindings']['OUT'],str(out))
 replacements=sorted([(value,b[key]) for key,value in old['bindings'].items() if b[key]!=value],key=lambda x:len(x[0]),reverse=True)
 def rebind(value):
  if isinstance(value,str):
   for before,after in replacements:
    if before in value:return value.replace(before,after)
   return value
  if isinstance(value,list):return [rebind(v) for v in value]
  if isinstance(value,dict):return {k:rebind(v) for k,v in value.items()}
  return value
 r=rebind(copy.deepcopy(old));r['bindings']=b
 r['candidateBinding']=dict(attempt=ident(attempt/'attempt.json'),api=m['api'],runtime=m['runtime'],base=m['base'],node=m['node'],upstreamCommit=PIN)
 # Preserve every semantic assertion. A stale output-specific contract must fail,
 # then receive a separately reviewed successor, never silently learn new values.
 for before,after in zip(old['newOwnerRequirements'],r['newOwnerRequirements']):
  assert rebind(before['assertions'])==after['assertions'] and before.get('relations')==after.get('relations')
 assert r['selectedOwners']==old['selectedOwners'] and len(r['selectedOwners'])==16
 changes=[]
 for step,prior in zip(r['steps'],old['steps']):
  if not step.get('argv'):continue
  for i,arg in enumerate(step['argv']):
   if arg.startswith(str(ROOT/'selfhost/build/phase42/final-recipe')) and arg.endswith('.json'):step['argv'][i]=str(dest)
   if step['name'] in ['prepare-cost-baseline','freeze-cost-plan'] and arg=='selfhost/build/phase41/checked01':step['argv'][i]='selfhost/build/phase42/checked16'
  if step!=prior:changes.append(dict(name=step['name'],before=prior['argv'],after=step['argv']))
 extension_inputs=[]
 r['phase43NewOwners']=[]
 if a.extension:
  extension=json.loads(a.extension.read_text());assert extension['reviewed'] is True
  def resolve(x):
   if isinstance(x,str):
    for key,value in sorted(b.items(),key=lambda kv:len(kv[0]),reverse=True):x=x.replace('${'+key+'}',value)
    assert '${' not in x;return x
   if isinstance(x,list):return [resolve(v) for v in x]
   if isinstance(x,dict):return {k:resolve(v) for k,v in x.items()}
   return x
  extension=resolve(extension);names=[x['name'] for x in extension['requirements']]
  assert names and len(names)==len(set(names)) and not set(names)&set(r['selectedOwners'])
  for spec in extension['requirements']:
   assert spec['assertions']['/complete'] is True and spec['assertions']['/pass'] is True
   assert spec['report'].startswith(str(out)+'/') and spec['execution'].startswith(str(out)+'/')
   assert any(x['expected'] in [b['API_SHA'],b['ATTEMPT_SHA']] for x in spec['bindings'])
  extras=extension['steps'];assert extras and all(x['argv'] and x['name'].startswith('phase43-') for x in extras)
  idx=next(i for i,x in enumerate(r['steps']) if x['name']=='close-phase42');r['steps'][idx:idx]=extras
  idx=r['stages']['semantic'].index('close-phase42');r['stages']['semantic'][idx:idx]=[x['name'] for x in extras]
  r['selectedOwners']+=names;r['newOwnerRequirements']+=extension['requirements'];r['phase43NewOwners']=names
  extension_inputs.append(ident(a.extension))
  for step in extras:
   for arg in step['argv']:
    f=Path(arg);f=f if f.is_absolute() else ROOT/f
    if f.is_file():extension_inputs.append(ident(f))
 assert len({x['name'] for x in r['steps']})==len(r['steps'])
 # Adapt scalar comparison only through an explicit later reviewed contract.
 # Its exact normalized-runtime/region assertions intentionally remain frozen.
 stale=[]
 for spec in r.get('inheritedSupplementRequirements',[]):
  for binding in spec['bindings']:
   if binding['pointer'] in ['/inputs/2/sha256','/output/sha256']:
    stale.append(dict(owner=spec['name'],pointer=binding['pointer'],expected=binding['expected'],reason='Prior emitted bytes: require fresh acquisition identity and reviewed successor before closure if changed.'))
 artifact_rows=[]
 for prior in old['materialization']['artifacts']:
  assert ident(prior['file'])['sha256']==prior['sha256']
  target=Path(rebind(prior['file']));assert target.is_relative_to(out) and not target.exists()
  data=rebind(json.loads(Path(prior['file']).read_text()));target.parent.mkdir(parents=True,exist_ok=True);target.write_text(json.dumps(data,indent=2)+'\n');artifact_rows.append(ident(target))
 # Recipe provenance points to immutable original derivation; only current artifacts
 # and producer are replaced. Keep old reviewed instrument versions, not pre-repair ones.
 r['materialization']=dict(producer=ident(__file__),parent=ident(PARENT),extension=old['materialization']['extension'],mappingTemplate=old['materialization']['mappingTemplate'],artifacts=artifact_rows)
 r['phase43Lineage']=dict(parent=ident(PARENT),changes=changes,pendingOutputContracts=stale,preservedOwners=old['selectedOwners'],oldToolRebinding=old.get('sameImageToolRebinding'),scope='Fresh checked image; no prior PASS receipts imported. All semantic assertions retained. Output-specific failures require reviewed frozen successors.')
 # Rehash current static tools and pin derivation helpers; old generated tools will
 # be freshly derived and verified by their original derivation receipts.
 pinned={}
 for row in old['toolInputs']:
  f=Path(row['path'])
  if f.is_relative_to(Path(old['bindings']['OUT'])):continue
  assert ident(f)['sha256']==row['sha256'],str(f)
  pinned[str(f)]=row
 for f in [Path(__file__),HERE/'run-recipe-v1.py',ROOT/'selfhost/tools/development/workflow.mjs']:
  row=ident(f);pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 for row in extension_inputs:pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 r['toolInputs']=list(pinned.values());r['kind']='phase42-materialized-final-integration-recipe'
 r['pendingDecisions']=['phase43-new-owner-controls','phase43-output-contract-successors','performance-cost-admission']
 dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(json.dumps(r,indent=2)+'\n')
 print(json.dumps(dict(complete=True,executed=False,recipe=ident(dest),owners=r['selectedOwners'],pendingOutputContracts=stale)))
if __name__=='__main__':main()
