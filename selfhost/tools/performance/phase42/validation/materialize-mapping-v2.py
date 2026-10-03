#!/usr/bin/env python3
"""Write fresh current/inherited owner mappings with immutable derivation receipts."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
TEMPLATE=ROOT/'selfhost/build/phase41/integration01/inherited-mapping.json'
TEMPLATE_SHA='e12b8fde1ff1808fb9b7782763e3b23705d81c593bc3d9b4dce58147e6df323f'
def ident(f):
 f=Path(f).resolve();return dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size)
def load(f):return json.loads(Path(f).read_text())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('recipe',type=Path);p.add_argument('scope',choices=['current','inherited']);a=p.parse_args()
 r=load(a.recipe);b=r['bindings'];out=Path(b['OUT']);inputs=[ident(__file__),ident(a.recipe)];changes=[]
 attempt=ident(Path(b['ATTEMPT'])/'attempt.json');m=load(attempt['file'])
 assert attempt['sha256']==r['candidateBinding']['attempt']['sha256'] and m['api']==r['candidateBinding']['api']
 if a.scope=='current':
  original=Path(b['PLAN'])/'owner/reports.json';mapping=load(original);plan=load(Path(b['PLAN'])/'plan.json');inputs.extend([ident(original),ident(Path(b['PLAN'])/'plan.json')]);source=original
  assert mapping['attempt']['sha256']==plan['attempt']['sha256']==attempt['sha256'] and mapping['api']['sha256']==plan['api']['sha256']==m['api']['sha256']
  assert len(mapping['cases'])==15 and set(mapping['cases'])==set(plan['ownerGates'])
  for key,paths in {'counters':[str(out/'final-counter/report.json')],'recursive-folds':[str(out/'preflight-fold/fold-controls/report.json'),str(out/'preflight-fold/fold-guards/report.json')]}.items():
   changes.append(dict(case=key,before=mapping['cases'][key],after=paths));mapping['cases'][key]=paths
  target=out/'owner-reports.json'
  refs=[Path(v) for paths in mapping['cases'].values() for v in paths]
 else:
  assert ident(TEMPLATE)['sha256']==TEMPLATE_SHA;inputs.append(ident(TEMPLATE));source=TEMPLATE
  old=str(ROOT/'selfhost/build/phase41/integration01');mapping=load(TEMPLATE)
  for group,fields in mapping.items():
   for key,value in fields.items():assert value.startswith(old+'/');fields[key]=str(out)+value[len(old):];changes.append(dict(group=group,field=key,before=value,after=fields[key]))
  assert set(mapping)=={'countdown','guard','component','unary'} and set(mapping['component'])=={'report','execution','cohort','derivation','tailReport','tailExecution'}
  overrides=r.get('inheritedMappingOverrides',{})
  assert set(overrides)<= {'component'}
  for group,fields in overrides.items():
   assert set(fields)<=set(mapping[group])-{'cohort'}
   for key,value in fields.items():
    assert isinstance(value,str) and value.startswith(str(out)+'/')
    changes.append(dict(group=group,field=key,before=mapping[group][key],after=value,reason='Reviewed same-image instrumentation successor'))
    mapping[group][key]=value
  target=out/'inherited-mapping.json';refs=[Path(v) for fields in mapping.values() for v in fields.values() if Path(v).suffix=='.json']
 assert not target.exists() and not target.with_suffix('.derivation.json').exists()
 for ref in refs:
  data=load(ref);assert data.get('complete') and not data.get('error'),str(ref)
  if ref.name=='report.json':assert data.get('pass'),str(ref)
  if ref.name=='run.json':assert data['returncode']==0 and not data.get('stoppedFor'),str(ref)
  inputs.append(ident(ref))
 # Preserve consumed mapping bytes separately; never rewrite the planner input.
 consumed=out/('consumed-'+a.scope+'-mapping.json');assert not consumed.exists();consumed.write_bytes(source.read_bytes());inputs.append(ident(consumed))
 target.write_text(json.dumps(mapping,indent=2)+'\n')
 target.with_suffix('.derivation.json').write_text(json.dumps(dict(kind='phase42-owner-mapping-materialization',complete=True,scope=a.scope,attempt=attempt,api=m['api'],inputs=inputs,changes=changes,output=ident(target)),indent=2)+'\n')
 print(json.dumps(dict(complete=True,mapping=ident(target))))
if __name__=='__main__':main()
