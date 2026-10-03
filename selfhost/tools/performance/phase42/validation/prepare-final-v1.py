#!/usr/bin/env python3
"""Freeze complete argv-only Phase42 integration recipe and exact new-owner contract."""
import argparse,copy,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
def ident(f):
 f=Path(f).resolve();return dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--attempt',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--extension',type=Path,required=True);p.add_argument('--recipe',type=Path,required=True);a=p.parse_args()
 assert not a.out.exists() and not a.recipe.exists();extension=json.loads(a.extension.read_text());assert extension['reviewed'] is True and extension['selectedOwners']
 assert len(set(extension['selectedOwners']))==len(extension['selectedOwners']);assert {s['name'] for s in extension['requirements']}==set(extension['selectedOwners'])
 parent=a.recipe.with_suffix('.base.json');assert not parent.exists()
 subprocess.run(['python3',str(HERE/'bind-recipe-v1.py'),'--attempt',str(a.attempt),'--out',str(a.out),'--recipe',str(parent)],check=True)
 recipe=json.loads(parent.read_text());b=recipe['bindings'];b.update(API=recipe['candidateBinding']['api']['file'],API_SHA=recipe['candidateBinding']['api']['sha256'],ATTEMPT_SHA=recipe['candidateBinding']['attempt']['sha256'])
 def resolve(value):
  if isinstance(value,str):
   for key in sorted(b,key=len,reverse=True):value=value.replace('${'+key+'}',b[key])
   assert '${' not in value,'Unresolved extension binding';return value
  if isinstance(value,list):return [resolve(v) for v in value]
  if isinstance(value,dict):return {k:resolve(v) for k,v in value.items()}
  return value
 extension=resolve(extension)
 artifacts=[]
 for artifact in extension.get('artifacts',[]):
  f=Path(artifact['path']);assert str(f).startswith(b['OUT']+'/') and not f.exists();f.parent.mkdir(parents=True,exist_ok=True);f.write_text(json.dumps(artifact['data'],indent=2)+'\n');artifacts.append(ident(f))
 for spec in extension['requirements']:
  assert spec['assertions']['/complete'] is True and isinstance(spec['assertions']['/kind'],str)
  assert len(spec['assertions'])>=3 and spec['bindings'] and spec['execution']
  assert any(x['expected'] in [b['API_SHA'],b['ATTEMPT_SHA']] for x in spec['bindings']),'Every owner needs explicit selected-image identity binding'
  assert spec['report'].startswith(b['OUT']+'/') and spec['execution'].startswith(b['OUT']+'/')
 steps=[]
 for step in recipe['steps']:
  step=copy.deepcopy(step);name=step['name']
  if name in ['map-current-owners','map-inherited']:
   step=dict(name=name,argv=['python3',str(HERE/'materialize-mapping-v1.py'),str(a.recipe.resolve()),'current' if name=='map-current-owners' else 'inherited'])
  if name=='phase42-owner-admission':
   for extra in extension['steps']:assert extra.get('argv') and extra['name'].startswith('phase42-');steps.append(extra)
   step=dict(name='close-phase42',argv=['python3',str(HERE/'close-release-v1.py'),str(a.recipe.resolve()),'new',b['OUT']+'/phase42-close/report.json'])
  steps.append(step)
  if name in ['audit-preinstall','audit-postinstall']:
   scope=name.removeprefix('audit-');steps.append(dict(name='composite-'+scope,argv=['python3',str(HERE/'close-release-v1.py'),str(a.recipe.resolve()),scope,b['OUT']+'/composite-'+scope+'/report.json']))
 recipe.update(kind='phase42-materialized-final-integration-recipe',steps=steps,selectedOwners=extension['selectedOwners'],newOwnerRequirements=extension['requirements'],materialization=dict(producer=ident(__file__),parent=ident(parent),extension=ident(a.extension),mappingTemplate=ident(HERE.parents[4]/'selfhost/build/phase41/integration01/inherited-mapping.json'),artifacts=artifacts))
 names=[s['name'] for s in steps];assert len(names)==len(set(names))
 recipe['stages']={
  'semantic':[s['name'] for s in steps[:names.index('prepare-cost-baseline')]],
  'cost-prepare':['prepare-cost-baseline','freeze-cost-plan'],
  'postinstall':['postinstall','audit-postinstall','composite-postinstall'],
 }
 recipe['pendingDecisions']=['performance-cost-admission']
 for stage,values in recipe['stages'].items():
  assert all(next(s for s in steps if s['name']==name).get('argv') for name in values),(stage,'Unresolved manual command')
 # Pin every existing extension executable/fixture argument and all new adapter tools.
 root=HERE.parents[4];pinned={row['path']:row for row in recipe['toolInputs']}
 for f in [HERE/'materialize-mapping-v1.py',HERE/'close-release-v1.py',HERE/'run-final-v1.py',root/'selfhost/tools/performance/phase41/recipe-run.py',root/'selfhost/tools/performance/phase41/job.py',root/'selfhost/tools/performance/phase40/campaign-v2.py',__file__]:
  row=ident(f);pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 for step in extension['steps']:
  for arg in step['argv']:
   f=Path(arg);f=f if f.is_absolute() else root/f
   if f.is_file():row=ident(f);pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(pinned.values());a.recipe.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe),steps=len(steps),owners=extension['selectedOwners'])))
if __name__=='__main__':main()
