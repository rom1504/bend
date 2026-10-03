#!/usr/bin/env python3
"""Materialize reviewed same-image tool/path repairs while retaining previous recipe receipts."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
ALLOWED={'inherited-component-derive','inherited-component','inherited-component-tail','map-inherited','close-inherited','scalar-island-precedence','phase42-owned-derive','phase42-owned-actual','phase42-owned-fixture-derive','phase42-owned-fixture','close-phase42','composite-preinstall','composite-postinstall'}
def ident(p):
 p=Path(p).resolve();raw=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))
def read(p):return json.loads(Path(p).read_text())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('parent',type=Path);p.add_argument('plan',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
 assert not a.out.exists();old=read(a.parent);r=copy.deepcopy(old);plan=read(a.plan)
 assert plan['reviewed'] is True and plan['selectedAttemptSha256']==r['candidateBinding']['attempt']['sha256']
 assert r['kind']=='phase42-materialized-final-integration-recipe' and r['bound'] and r['complete'] and not r['executed']
 for name in plan['freshPaths']:
  f=Path(name);assert str(f.resolve()).startswith(r['bindings']['OUT']+'/') and not f.exists(),str(f)
 reviews=[]
 for ref in plan['reviews']:
  assert ident(ref['file'])['sha256']==ref['sha256'];doc=read(ref['file']);assert doc['complete'] and doc['staticReviewPassed'];reviews.append(ref['file'])
 assert reviews
 steps={x['name']:x for x in r['steps']};declared=set(plan['stepReplacements']);assert declared<=ALLOWED
 for name,changes in plan['stepReplacements'].items():
  assert changes
  for change in changes:
   assert set(change)=={'before','after'};before,after=change['before'],change['after'].replace('${RECIPE}',str(a.out.resolve()))
   assert '/' in before and '/' in after and not before.startswith('-') and not after.startswith('-')
   assert steps[name]['argv'].count(before)==1,(name,before)
   steps[name]['argv']=[after if x==before else x for x in steps[name]['argv']]
 changed=[x['name'] for x,y in zip(r['steps'],old['steps']) if x!=y];assert set(changed)==declared
 def paths(value,changes):
  if isinstance(value,str):return changes.get(value,value)
  if isinstance(value,list):return [paths(x,changes) for x in value]
  if isinstance(value,dict):return {k:paths(x,changes) for k,x in value.items()}
  return value
 rewrites=plan.get('ownerPathRewrites',{});assert set(rewrites)<= {'owned-actual','owned-fixture'}
 r['newOwnerRequirements']=[paths(x,rewrites.get(x['name'],{})) for x in r['newOwnerRequirements']]
 for oldspec,spec in zip(old['newOwnerRequirements'],r['newOwnerRequirements']):
  assert oldspec['assertions']==spec['assertions'] and oldspec.get('relations')==spec.get('relations') and oldspec['name']==spec['name']
  assert [b['expected'] for b in oldspec['bindings']]==[b['expected'] for b in spec['bindings']]
 r['inheritedMappingOverrides']=plan.get('inheritedMappingOverrides',{})
 assert set(r['inheritedMappingOverrides'])<= {'component'}
 r['inheritedSupplementRequirements']=plan.get('inheritedSupplementRequirements',[])
 assert [s['name'] for s in r['inheritedSupplementRequirements']] in [[],['scalar-island-precedence']]
 for spec in r['inheritedSupplementRequirements']:
  assert spec['assertions']['/complete'] is True and spec['assertions']['/pass'] is True
  assert any(x['expected']==r['candidateBinding']['attempt']['sha256'] for x in spec['bindings'])
 assert r['bindings']==old['bindings'] and r['candidateBinding']==old['candidateBinding'] and r['materialization']==old['materialization'] and r['stages']==old['stages']
 pinned={x['path']:x for x in r['toolInputs']}
 for name in plan['toolInputs']+reviews+[str(a.parent.resolve()),str(a.plan.resolve()),__file__]:
  f=Path(name);f=f if f.is_absolute() else ROOT/f;row=ident(f);pinned[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 r['toolInputs']=list(pinned.values())
 r['sameImageToolRebinding']=dict(kind='phase42-reviewed-same-image-tools-successor',parent=ident(a.parent),plan=ident(a.plan),producer=ident(__file__),changedSteps=changed,preservedSteps=[x['name'] for x in old['steps'] if x['name'] not in declared],sameOutput=True,sameSelectedImage=True,scope='Original successful and failed receipts remain immutable; only explicit reviewed tool/output paths and corresponding report mappings change, with all old semantic assertion values preserved.')
 a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.out),changedSteps=changed)))
if __name__=='__main__':main()
