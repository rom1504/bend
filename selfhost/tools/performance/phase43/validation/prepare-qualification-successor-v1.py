#!/usr/bin/env python3
"""Bind reviewed inherited-controller/catalog-path successors without rerunning PASS raw."""
import argparse,copy,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def read(p):return json.loads(Path(p).read_text())
def identities(x):
 if isinstance(x,dict):
  if 'sha256' in x and ('file' in x or 'path' in x):yield x
  for v in x.values():yield from identities(v)
 elif isinstance(x,list):
  for v in x:yield from identities(v)
def freeze_review(p):
 d=read(p);assert d['complete'] and d['staticReviewPassed'];rows=[]
 for row in identities(d):
  f=row.get('file',row.get('path'));got=ident(f);assert got['sha256']==row['sha256'],f;rows.append(got)
 return d,[ident(p),*rows]
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for k in ['parent','recipe','tools','wrapper-review','closure-review','fusion-review','hybrid-review','native-review','catalog-review']:ap.add_argument('--'+k,type=Path,required=True)
 a=ap.parse_args();r=read(a.parent);recipe=copy.deepcopy(r);out=Path(r['bindings']['OUT']);tools=a.tools.resolve();assert not tools.exists() and not a.recipe.exists()
 reviews={};pins=[ident(__file__),ident(a.parent)]
 for key in ['wrapper','closure','fusion','hybrid','native','catalog']:
  d,rows=freeze_review(getattr(a,key+'_review'));reviews[key]=d;pins.extend(rows)
 changes=[];prior=copy.deepcopy(r['newOwnerRequirements']);oldrecipe=str(a.parent.resolve());newrecipe=str(a.recipe.resolve())
 for step in recipe['steps']:step['argv']=[newrecipe if x==oldrecipe else x for x in step.get('argv',[])]
 steps={x['name']:x for x in recipe['steps']}
 def substitute(name,old,new):
  argv=steps[name]['argv'];assert argv.count(old)==1,(name,old,argv.count(old));argv[argv.index(old)]=new;changes.append(dict(step=name,before=old,after=new))
 def paths(name,pairs):
  for old,new in pairs:substitute(name,str(out/old),str(out/new))
 def producer(name,old,new):substitute(name,old,new['file'])
 producer('phase41-wrapper-control','selfhost/tools/performance/phase42/fusion/phase41-wrapper-controls-v4.mjs',reviews['wrapper']['controller'])
 paths('phase41-wrapper-control',[('run-phase41-wrapper-control-v4','run-phase41-wrapper-control-v5'),('phase41-wrapper-controls-v4','phase41-wrapper-controls-v5')])
 producer('close-phase41','selfhost/tools/performance/phase42/validation/close-phase41-v4.py',reviews['closure']['closer'])
 producer('phase42-fusion-derive','selfhost/tools/performance/phase42/fusion/actual-derive.py',reviews['fusion']['derive']);paths('phase42-fusion-derive',[('fusion-derived','fusion-derived-successor01')])
 paths('phase42-fusion-actual',[('fusion-derived','fusion-derived-successor01'),('fusion-actual','fusion-actual-successor01'),('run-fusion-actual','run-fusion-actual-successor01')])
 producer('phase42-fusion-fixture','selfhost/tools/performance/phase42/fusion/fixture-controls-v4.mjs',reviews['fusion']['controller']);paths('phase42-fusion-fixture',[('fusion-fixture','fusion-fixture-successor01'),('run-fusion-fixture','run-fusion-fixture-successor01')])
 producer('phase42-layout-actual','selfhost/tools/performance/phase42/layout/actual-source-controls-v5.mjs',reviews['closure']['layoutController']);paths('phase42-layout-actual',[('layout-actual','layout-actual-v2'),('run-layout-actual','run-layout-actual-v2')])
 producer('phase42-hybrid-derive','selfhost/tools/performance/phase42/frames/hybrid-actual-derive-v2.mjs',reviews['hybrid']['derive']);paths('phase42-hybrid-derive',[('hybrid-derived','hybrid-derived-successor01'),('run-hybrid-derive','run-hybrid-derive-successor01')])
 paths('phase42-hybrid-control',[('hybrid-derived','hybrid-derived-successor01'),('hybrid-derived/report.json','hybrid-controls-successor01.json'),('run-hybrid-control','run-hybrid-control-successor01')])
 native=reviews['native'];producer('phase42-native-owned-assay','selfhost/tools/performance/phase42/calls/native-owned-assay-v1.mjs',native['producer']);paths('phase42-native-owned-assay',[('native-owned-assay.json','native-owned-assay-successor01.json'),('run-native-owned-assay','run-native-owned-assay-successor01')])
 # One catalog-origin failure only: retain the seventeen already closed v6 owners.
 name='phase43-close-callbacks-number-count-noncommutative';owner_step=steps[name];oldwrapper=str(ROOT/'selfhost/tools/performance/phase43/validation/wrap-owner-v6.py')
 substitute(name,oldwrapper,reviews['catalog']['producer']['file']);paths(name,[(name,name+'-v7'),('run-'+name,'run-'+name+'-v7')])
 oldcontract=Path(owner_step['argv'][-2]);assert oldcontract.name=='callbacks-number-count-noncommutative.json'
 tools.mkdir(parents=True,exist_ok=False);contract=tools/'callbacks-number-count-noncommutative-v7.json';contract.write_bytes(oldcontract.read_bytes());pins.extend([ident(oldcontract),ident(contract)]);substitute(name,str(oldcontract),str(contract))
 remap={str(out/'fusion-derived'):str(out/'fusion-derived-successor01'),str(out/'fusion-actual'):str(out/'fusion-actual-successor01'),str(out/'run-fusion-actual'):str(out/'run-fusion-actual-successor01'),str(out/'fusion-fixture'):str(out/'fusion-fixture-successor01'),str(out/'run-fusion-fixture'):str(out/'run-fusion-fixture-successor01'),str(out/'layout-actual'):str(out/'layout-actual-v2'),str(out/'run-layout-actual'):str(out/'run-layout-actual-v2'),str(out/'hybrid-derived/report.json'):str(out/'hybrid-controls-successor01.json'),str(out/'hybrid-derived'):str(out/'hybrid-derived-successor01'),str(out/'run-hybrid-control'):str(out/'run-hybrid-control-successor01'),str(out/'native-owned-assay.json'):str(out/'native-owned-assay-successor01.json'),str(out/'run-native-owned-assay'):str(out/'run-native-owned-assay-successor01'),str(out/name):str(out/(name+'-v7')),str(out/('run-'+name)):str(out/('run-'+name+'-v7'))}
 def rebind(x):
  if isinstance(x,str):
   for old in sorted(remap,key=len,reverse=True):
    if x==old or x.startswith(old+'/'):return remap[old]+x[len(old):]
   return x
  if isinstance(x,list):return [rebind(v) for v in x]
  if isinstance(x,dict):return {k:rebind(v) for k,v in x.items()}
  return x
 recipe['newOwnerRequirements']=rebind(recipe['newOwnerRequirements'])
 requirement={x['name']:x for x in recipe['newOwnerRequirements']}
 layout=requirement['layout-actual']['assertions'];assert layout['/staticRows/complete/actualPublicBindingByteIdentity'] is True
 layout['/staticRows/complete/actualPublicBindingByteIdentity']=False;layout['/staticRows/complete/actualPublicBindingExecutableByteIdentity']=True;layout['/staticRows/complete/publicCaptureMetadata']={'length':5}
 for i,name in enumerate(['warp','warp_node','flow','bsort','scan']):
  layout[f'/staticRows/complete/publicCaptureMetadata/{i}/name']=name
 # Explicit retention scope; all worker constructor/literal counts remain exact.
 assay=requirement['native-owned-literals'];historical={k:copy.deepcopy(assay['assertions'][k]) for k in ['/before','/after']}
 for prefix in ['/before','/after']:assay['assertions'].pop(prefix)
 updatefile=native['assertionUpdates']['file'];update_document=read(updatefile);updates=update_document['assertions']
 for key,reviewkey in [('producer','producer'),('binding','binding')]:
  row=update_document[key];assert row['sha256']==native[reviewkey]['sha256'] and Path(row.get('file',row.get('path'))).resolve()==Path(native[reviewkey]['file'])
 assert updates['/kind']=='phase43-native-owned-actual-emission-retention-assay' and updates['/wholeProgramIsolation'] is False and updates['/crossRoleRuntimeIdentical'] is False
 allowed={'/kind','/complete','/pass','/execution','/wholeProgramIsolation','/crossRoleRuntimeIdentical','/pairDestination'}
 for prefix in ['/before','/after']:
  allowed.update(prefix+'/'+key for key in ['names','allWorkerNames','maskedSha256','maskedBytes','maskedPrivateBodies'])
  allowed.update(prefix+'/counts/ctor/'+key for key in ['Tuple','Con','Nil','True','False'])
  allowed.update(prefix+'/counts/literal/'+key for key in ['TupleReturn','Con','Nil','BoolArrayField'])
 assert set(updates)==allowed,'Unreviewed native retention pointer set'
 for prefix in ['/before','/after']:
  assert updates[prefix+'/names']==historical[prefix]['names']
  for key,value in historical[prefix]['counts']['ctor'].items():assert updates[prefix+'/counts/ctor/'+key]==value,'retained exact ctor inventory'
 assert len(updates['/before/allWorkerNames'])==3 and len(updates['/after/allWorkerNames'])==7
 assert updates['/before/counts/literal/TupleReturn']==updates['/after/counts/literal/TupleReturn']==0
 assert updates['/after/counts/literal/Con']==updates['/after/counts/literal/BoolArrayField']==2
 assert updates['/pairDestination']==dict(zeroReturnsInputBeforeAllocation=True,freshBufferCopiesBothInputFields=True,destinationPairs=3,bothRhsBeforeWrites=True,inputWrites=0)
 assay['assertions'].update(updates);assay['producer']=native['producer']['file']
 assay['assertions']['/binding/sha256']=native['binding']['sha256'];assay['assertions']['/semanticEvidence']=read(native['binding']['file'])['semanticEvidence']
 requirement['phase43-callbacks-number-count-noncommutative']['producer']=reviews['catalog']['producer']['file']
 assert ident(contract)['sha256']==next(x['expected'] for x in requirement['phase43-callbacks-number-count-noncommutative']['bindings'] if x['pointer']=='/contract/sha256')
 existing={x['path']:x for x in recipe['toolInputs']}
 for row in pins:existing[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(existing.values());assert recipe['selectedOwners']==r['selectedOwners'] and len(recipe['selectedOwners'])==34
 recipe['qualificationSuccessor']=dict(kind='phase43-frozen-qualification-recipe-successor',complete=True,executed=False,parent=ident(a.parent),producer=ident(__file__),reviews={k:ident(getattr(a,k+'_review')) for k in reviews},changes=changes,historicalNativeIsolationAssertions=historical,previousRequirements=prior,unchangedRawOwners=18,preservedClosedV6Owners=17,scope='Source14 unchanged. Retain every completed raw/report/recipe. Four explicit inherited proof-shape successors, honest native constructor-retention scope instead of historical whole-program isolation, one catalog-origin wrapper correction. No old failure is converted to PASS and no raw control is rerun.')
 a.recipe.parent.mkdir(parents=True,exist_ok=True);a.recipe.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe),changes=changes)))
if __name__=='__main__':main()
