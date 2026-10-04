#!/usr/bin/env python3
"""Bind an independently reviewed exact BST inventory/metric aggregation successor."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def read(p):return json.loads(Path(p).read_text())
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['parent','review','inventory','recipe']:ap.add_argument('--'+name,type=Path,required=True)
 a=ap.parse_args();assert not a.recipe.exists();r=read(a.parent);review=read(a.review);inventory=read(a.inventory)
 assert review['complete'] and review['staticReviewPassed'] and inventory['complete'] and not inventory['executedTargets']
 assert inventory['checks']==472 and inventory['documentsRead']==45 and not inventory['missing']
 assert len(inventory['mismatches'])==2 and {m['pointer'] for m in inventory['mismatches']}=={'/selected','/hostControls'}
 assert all(m['owner']=='bst-structural' and m['group']=='newOwnerRequirements' for m in inventory['mismatches'])
 report=Path(next(m['document'] for m in inventory['mismatches']));assert all(Path(m['document'])==report for m in inventory['mismatches'])
 assert review['report']['sha256']==ident(report)['sha256'] and Path(review['report']['file']).resolve()==report
 assert review['inventory']['sha256']==ident(a.inventory)['sha256']
 desired=['inorder','bst.up','insert.fin','bst.down','p37.bst.insert','p37.bst.build'];old=['inorder','bst.up','bst.down']
 assert review['selectedBefore']==old and review['selectedAfter']==desired
 recipe=copy.deepcopy(r);spec=next(x for x in recipe['newOwnerRequirements'] if x['name']=='bst-structural');assert Path(spec['report'])==report
 assert spec['assertions']['/selected']==old
 priorHost=copy.deepcopy(spec['assertions']['/hostControls']);newHost=copy.deepcopy(priorHost)
 assert newHost[0]['key']=='isArray' and newHost[0]['requiresZeroEntry'] is False
 assert newHost[0]['metrics']==[dict(role='original',callbacks=0,entries=0),dict(role='candidate',callbacks=0,entries=92)]
 assert review['isArrayCandidateEntries']==dict(before=92,after=30)
 newHost[0]['metrics'][1]['entries']=30
 actual=read(report);assert actual['selected']==desired and actual['hostControls']==newHost
 assert review['retainedSemanticCounts']==dict(boundaries=38,aliases=24,deepRows=3)
 assert actual['boundaries']==38 and actual['aliases']==24 and len(actual['deep'])==3
 spec['assertions']['/selected']=desired;spec['assertions']['/hostControls']=newHost
 oldrecipe=str(a.parent.resolve());newrecipe=str(a.recipe.resolve());out=Path(r['bindings']['OUT'])
 for step in recipe['steps']:
  step['argv']=[newrecipe if x==oldrecipe else x for x in step.get('argv',[])]
  if step['name']=='close-phase42':
   before=str(out/'phase42-close/report.json');after=str(out/'phase42-close-successor01/report.json');assert step['argv'].count(before)==1;step['argv'][step['argv'].index(before)]=after
 failed=out/'phase42-close/report.json';assert failed.exists() and not (out/'phase42-close-successor01').exists()
 pins=[ident(__file__),ident(a.parent),ident(a.review),ident(a.inventory),ident(report),ident(failed)]
 existing={x['path']:x for x in recipe['toolInputs']}
 for row in pins:existing[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(existing.values());assert recipe['selectedOwners']==r['selectedOwners'] and len(recipe['selectedOwners'])==34
 recipe['inventorySuccessor']=dict(kind='phase43-frozen-report-inventory-recipe-successor',complete=True,executed=False,parent=ident(a.parent),producer=ident(__file__),review=ident(a.review),inventory=ident(a.inventory),report=ident(report),failedClosure=ident(failed),changes=[dict(owner='bst-structural',pointer='/selected',before=old,after=desired),dict(owner='bst-structural',pointer='/hostControls/0/metrics/1/entries',before=92,after=30)],scope='Aggregation only. Exact reviewed source14 expanded worker inventory and nondependency activity metric; the other470 matched checks, semantic/proof/zero-refusal clauses and frozen image/module identities remain. Runtime plan continues to bind immutable recipe04 and the same selected image. No target rerun.')
 a.recipe.parent.mkdir(parents=True,exist_ok=True);a.recipe.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe))))
if __name__=='__main__':main()
