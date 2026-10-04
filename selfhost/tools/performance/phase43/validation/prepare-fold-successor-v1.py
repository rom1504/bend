#!/usr/bin/env python3
"""Materialize reviewed fold wrapper/mapping/recipe successors; run no targets."""
import argparse,copy,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def ident(file):
 p=Path(file).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def read(p):return json.loads(Path(p).read_text())
def write(p,data):
 assert not p.exists(),str(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(data,indent=2)+'\n')
def verify(row):
 got=ident(row['file']);assert got['sha256']==row['sha256'],row['file'];return got
def replace(text,before,after,count):
 assert text.count(before)==count,(before,text.count(before),count)
 return text.replace(before,after),dict(before=before,after=after,count=count)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument('--parent',type=Path,required=True);ap.add_argument('--review',type=Path,required=True)
 ap.add_argument('--tools',type=Path,required=True);ap.add_argument('--fold-out',type=Path,required=True);ap.add_argument('--recipe',type=Path,required=True)
 a=ap.parse_args();r=read(a.parent);review=read(a.review);assert review['complete'] and review['staticReviewPassed']
 controller=verify(review['controller']);guards=verify(review['guards']);controller_receipt=Path(controller['file']).with_suffix('.json');cr=read(controller_receipt)
 assert cr['complete'] and cr['derived']['sha256']==controller['sha256'] and Path(cr['derived']['file']).resolve()==Path(controller['file'])
 out=Path(r['bindings']['OUT']);oldwrapper=out/'current-tools/fold-final-controls-v1.py';oldwrapper_receipt=oldwrapper.with_suffix('.json')
 assert not a.fold_out.exists() and a.fold_out.resolve().is_relative_to(out)
 tools=a.tools.resolve();tools.mkdir(parents=True,exist_ok=False)
 inputs=[ident(__file__),ident(a.parent),ident(a.review),controller,guards,ident(controller_receipt),ident(oldwrapper),ident(oldwrapper_receipt)]
 # Keep the original wrapper and controller receipts immutable and consumed.
 original=tools/'original-fold-final-controls-v1.py';original.write_bytes(oldwrapper.read_bytes())
 text=oldwrapper.read_text();changes=[]
 for before,after,count in [
  ("HERE.parent/'phase40/fold-controls-v3.mjs'",f"Path({controller['file']!r})",2),
  ("HERE.parent/'phase40/fold-controls-v3.json'",f"Path({str(controller_receipt)!r})",1),
  ("HERE/'fold-guards.mjs'",f"Path({guards['file']!r})",1),
  ("str(HERE/(name+'.mjs'))",f"str(Path({guards['file']!r}))",1),
 ]:
  text,delta=replace(text,before,after,count);changes.append(delta)
 wrapper=tools/'fold-final-controls-v2.py';wrapper.write_text(text)
 write(wrapper.with_suffix('.json'),dict(kind='phase43-reviewed-fold-wrapper-derivation',complete=True,executed=False,parent=ident(oldwrapper),parentDerivation=ident(oldwrapper_receipt),original=ident(original),derived=ident(wrapper),producer=ident(__file__),review=ident(a.review),controller=controller,guards=guards,changes=changes))
 mapper=ROOT/'selfhost/tools/performance/phase42/validation/materialize-mapping-v1.py';original_mapper=tools/'original-materialize-mapping-v1.py';original_mapper.write_bytes(mapper.read_bytes())
 old="[str(out/'preflight-fold/fold-controls/report.json'),str(out/'preflight-fold/fold-guards/report.json')]"
 new=repr([str(a.fold_out.resolve()/'fold-controls/report.json'),str(a.fold_out.resolve()/'fold-guards/report.json')])
 text,change=replace(mapper.read_text(),old,new,1)
 # Relocation cannot infer repository depth from a tools output directory.
 text,rootchange=replace(text,'ROOT=Path(__file__).resolve().parents[5]',f'ROOT=Path({str(ROOT)!r})',1)
 fold_control=str(a.fold_out.resolve()/'fold-controls/report.json')
 assertion="""  if str(ref)==FOLD_CONTROL:
   expected=[dict(name=name,iterative=True) for name in ['fold.value','fold.size','fold.weight']]
   assert data['structure'][:3]==expected and len(data['structure'])==7,'preserved three iterative folds plus exact four structural owners'
   for row,name in zip(data['structure'][3:],['fold.make','fold.share','fold.order.make','benchRecord']):
    assert row['name']==name and row['kind']==('recursive-producer' if name=='fold.make' else 'nonrecursive-wrapper')
    assert len(row['sha256'])==64 and all(c in '0123456789abcdef' for c in row['sha256'])
""".replace('FOLD_CONTROL',repr(fold_control))
 text,structurechange=replace(text,"  inputs.append(ident(ref))",assertion+"  inputs.append(ident(ref))",1)
 newmapper=tools/'materialize-mapping-v2.py';newmapper.write_text(text)
 write(newmapper.with_suffix('.json'),dict(kind='phase43-reviewed-fold-mapping-derivation',complete=True,executed=False,parent=ident(mapper),original=ident(original_mapper),derived=ident(newmapper),producer=ident(__file__),review=ident(a.review),changes=[change,rootchange,structurechange]))
 parentpath=str(a.parent.resolve());newpath=str(a.recipe.resolve());recipe=copy.deepcopy(r)
 # Closure tools/materializers consume the successor's exact frozen recipe bytes.
 for step in recipe['steps']:
  step['argv']=[newpath if arg==parentpath else arg for arg in step.get('argv',[])]
  if step['name']=='preflight-fold':
   assert step['argv']==['python3',str(oldwrapper),r['bindings']['ATTEMPT'],str(out/'preflight-fold')]
   step['argv']=['python3',str(wrapper),r['bindings']['ATTEMPT'],str(a.fold_out.resolve())]
   step['note']='Reviewed bounded fold-controller successor; original failed preflight remains immutable.'
  if step['name']=='map-current-owners':
   assert step['argv']==['python3',str(mapper),newpath,'current'];step['argv'][1]=str(newmapper)
 pins=[*inputs,ident(original),ident(wrapper),ident(wrapper.with_suffix('.json')),ident(mapper),ident(original_mapper),ident(newmapper),ident(newmapper.with_suffix('.json'))]
 existing={x['path']:x for x in recipe['toolInputs']}
 for row in pins:existing[row['file']]=dict(path=row['file'],sha256=row['sha256'],bytes=row['bytes'])
 recipe['toolInputs']=list(existing.values())
 recipe['foldSuccessor']=dict(kind='phase43-frozen-fold-recipe-successor',complete=True,executed=False,parent=ident(a.parent),review=ident(a.review),producer=ident(__file__),wrapper=ident(wrapper),mapping=ident(newmapper),failedRaw=str(out/'preflight-fold'),freshRaw=str(a.fold_out.resolve()),preservedSuccessfulPrefix=recipe['stages']['semantic'][:4],policy='Original recipe, tools and raw reports retained. All semantic stages and owner obligations preserved; only reviewed fold controller/guards, fresh fold output, current mapping and exact self-recipe references change. Resume explicit unfinished names; never rerun completed output directories.')
 write(a.recipe,recipe)
 print(json.dumps(dict(complete=True,executed=False,recipe=ident(a.recipe),wrapper=ident(wrapper),mapping=ident(newmapper))))
if __name__=='__main__':main()
