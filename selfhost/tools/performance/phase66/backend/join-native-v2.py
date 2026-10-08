#!/usr/bin/env python3
"""Data-only join of selected05 native/backend receipts; never run targets."""
from pathlib import Path
import argparse,json,hashlib
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase66'
INPUTS={}
def pin(p,expected=None):
 p=p.resolve(strict=True);b=p.read_bytes();h=hashlib.sha256(b).hexdigest()
 if expected is not None:assert h==expected,(str(p),h,expected)
 row={'file':str(p),'sha256':h,'bytes':len(b)};INPUTS[str(p)]=row;return row
def read(p):
 q=pin(p);return json.loads(p.read_text()),q
def suite(relative,count):
 d,q=read(RAW/relative);assert d['selectedComplete'] and d['changedInputs']==[] and len(d['results'])==count
 assert d['summary']['statuses']=={'pass':count}
 for name,h in d['inputHashes'].items():pin(Path(d['inputPaths'].get(name,name)),h)
 return d,{'report':q,'observations':count,'results':[{'id':r['id'],'lane':r['lane'],'status':r['status'],'evidence':r.get('evidence')} for r in d['results']]}
def pinned(row):
 return pin(Path(row.get('file',row.get('path'))),row['sha256'])
def same(row,want):
 x=pinned(row);y=pinned(want);assert x['file']==y['file'] and x['sha256']==y['sha256'];return x
def bind_image_recipe(relative,selected,selected_pin,role):
 d,q=read(RAW/relative);same(d['attempt'],selected_pin);image=next(x for x in d['images'] if x['role']==role)
 assert pinned(image['compilerImage'])['sha256']==selected['api']['sha256']
 snapshot=Path(selected['snapshot']['root']);catalog={str(Path(x['frozen']['file']).relative_to(snapshot)):x['frozen'] for x in selected['snapshot']['sources']}
 seen=set()
 for row in image['copies']:
  source=pinned(row['source']);rel=str(Path(source['file']).relative_to(snapshot));assert source['sha256']==catalog[rel]['sha256'];seen.add(rel)
  copy=row['copy']
  if rel=='tools/conformance/adapters/typed.mjs': assert pinned(copy|{'sha256':image['adapterAfter']['sha256']})['sha256']==image['adapterAfter']['sha256']
  else: assert pinned(copy)['sha256']==source['sha256']
 assert seen==set(catalog),('Incomplete image snapshot',len(seen),len(catalog))
 return q

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();assert not a.out.exists();pin(Path(__file__))
 attempt,ap=read(RAW/'checked-b1-05/attempt.json');assert attempt['checked'];snapshot=Path(attempt['snapshot']['root']);api=pin(Path(attempt['api']['file']),attempt['api']['sha256']);native=[]
 c,cp=read(ROOT/'selfhost/tools/performance/phase66/backend/native-effects-v1/candidate.json');recipe,rp=read(RAW/'native-effects-source02-recipe/recipe.json');image=next(x for x in recipe['images'] if x['role']=='bend-direct');project=Path(image['project'])
 assert pin(Path(image['compilerImage']['file']),image['compilerImage']['sha256'])['sha256']==api['sha256']
 overlay={x['relative']:x for x in image['overlays']};assert len(overlay)==8
 for row in c['files']:
  rel=str(Path(row['relative']).relative_to('selfhost'));expected=row['after']['sha256'];assert rel in overlay
  native.append({'relative':rel,'candidate':pin(Path(row['after']['file']),expected),'overlay':pin(project/rel,expected),'selected05':pin(snapshot/rel,expected)})
 snapshotEquality=[]
 for row in attempt['snapshot']['sources']:
  frozen=row['frozen'];path=Path(frozen['file']);rel=path.relative_to(snapshot);selected=pin(path,frozen['sha256']);prior=pin(project/rel)
  # The conformance adapter is explicitly derived in this role; validate its
  # exact recorded derivation independently rather than calling it unchanged.
  if str(rel)=='tools/conformance/adapters/typed.mjs':
   parent,_=read(RAW/'backend-native-controls04-recipe/recipe.json');source=next(x for x in parent['images'] if x['role']=='bend-direct');assert prior['sha256']==source['adapterAfter']['sha256']
  else:assert prior['sha256']==selected['sha256'],str(rel)
  snapshotEquality.append(str(rel))
 ts19,a19=suite('native-effects-source02-recipe/typescript-new/observations/report.json',19);b19,b19summary=suite('native-effects-source02-recipe/bend-direct/observations/report.json',19)
 assert [(x['id'],x['lane']) for x in ts19['results']]==[(x['id'],x['lane']) for x in b19['results']]
 assert all(r.get('evidence')=='checked-execution' for d in [ts19,b19] for r in d['results'])
 ts16,a16=suite('backend-native-controls04-clang01-recipe/typescript-new/observations/report.json',16);b16,b16summary=suite('backend-native-controls05-clang01-recipe/bend-direct/observations/report.json',16)
 assert [(x['id'],x['lane']) for x in ts16['results']]==[(x['id'],x['lane']) for x in b16['results']]
 n16r,n16rp=read(RAW/'backend-native-controls05-clang01-recipe/recipe.json');same(n16r['attempt'],ap);pinned(n16r['compiler']);[pinned(x) for x in n16r['compilerSharedLibraries']]
 native16parent=bind_image_recipe('backend-native-controls05-recipe/recipe.json',attempt,ap,'bend-direct');same(n16r['parent'],native16parent)
 n3,n3p=read(RAW/'native3-05/report.json');assert n3['pass'] and n3['complete'] and n3['inputsUnchanged'] and len(n3['rows'])==3 and all(r['pass'] for r in n3['rows'])
 for row in n3['inputs']:pinned(row)
 n3role=n3['roles']['candidate'];assert n3role['verification']['inputsUnchanged'] and n3role['verification']['copiesUnchanged'];n3image=n3role['image'];same(n3image['attempt'],ap)
 for key in ['api','runtime','base']:assert pinned(n3image[key])['sha256']==attempt[key]['sha256']
 for key,rel in [('driver','tools/typed-driver.mjs'),('directRuntime','src/runtime/js/direct.mjs')]:assert pinned(n3image[key])['sha256']==pin(snapshot/rel)['sha256']
 n3copied=set()
 for row in n3role['copies']:
  old=pinned(row['before']);new=pinned(row['after']);assert old['sha256']==new['sha256'];oldp=Path(old['file'])
  if oldp.is_relative_to(snapshot):n3copied.add(str(oldp.relative_to(snapshot)))
  else:assert oldp==Path(attempt['api']['file'])
 assert all(row['relative'] in n3copied for row in native),'Native3 must copy every selected native delta'

 mock,mp=read(RAW/'native-send-controls01/report.json');assert mock['pass'] and len(mock['cases'])==7
 for row in mock['inputs']:pin(Path(row['file']),row['sha256'])
 deep,ds=suite('backend-legacy-depth04-recipe/report.json',1);legacy,ls=suite('legacy-source-controls04-recipe/bend-legacy/observations/report.json',15)
 ending,ep=read(RAW/'private-ending-controls04/report.json');assert ending['pass'] and len(ending['cases'])==6 and all(r['pass'] for r in ending['cases'])
 reuse,up=read(RAW/'reuse04-to05.json');assert reuse['complete'] and reuse['eligibleForExactJavaScriptReuse'] and not reuse['nativeQualificationTransferred']
 same(reuse['candidate'],ap);baseline,bp=read(RAW/'checked-b1-04/attempt.json');same(reuse['baseline'],bp)
 for row in reuse['inputs']:pinned(row)
 legacyParent=bind_image_recipe('legacy-source-controls04-recipe/recipe.json',baseline,bp,'bend-legacy')
 depthParent=bind_image_recipe('backend-legacy-source-controls04-recipe/recipe.json',baseline,bp,'bend-legacy');depthRecipe,depthPin=read(RAW/'backend-legacy-depth04-recipe/recipe.json');same(depthRecipe['attempt'],bp);same(depthRecipe['parent'],depthParent)
 er,erp=read(RAW/'private-ending-controls04-recipe/recipe.json');same(er['associatedAttempt'],bp);same(ending['input'],er['transform']);same(ending['controller'],er['controller']);pinned(er['manifest'])
 for row in er['copies']:assert pinned(row['source'])['sha256']==pinned(row['copy'])['sha256']

 report={'kind':'phase66-selected05-native-backend-join','complete':True,'pass':True,'dataOnly':True,'version':2,'selectedAttempt':ap,'selectedApi':api,'nativeCandidate':cp,'source19Recipe':rp,'nativeFiles':native,'source19OverlayMatchesSelectedSnapshot':{'count':len(snapshotEquality),'paths':snapshotEquality,'adapterException':'Exact separately recorded direct adapter derivation; compiler and runtime match selected05.'},'gates':{'nativeSource19Reference':a19,'nativeSource19Bend':b19summary,'native16ReferenceReused':a16,'native16Selected05':b16summary,'native16RoleBinding':n16rp,'native3':n3p,'mockedSyscalls7':mp,'legacyDepthFresh04':ds,'legacyWider15':ls,'privateEndings6':ep,'privateEndingsRecipe':erp,'javascript04To05Identity':up},'unsupportedNative':['Chan.try_send','Chan.try_recv','TCP.try_accept','TCP.try_send','TCP.try_send_bytes','TCP.try_recv','TCP.try_recv_bytes','UDP.try_send_to','UDP.try_send_bytes_to','UDP.try_recv_from','UDP.try_recv_bytes_from','UDP.send_bytes_to','UDP.recv_bytes_from'],'scope':'Selected CPU/source/backend compatibility only; no fullnative/GPU or newAPI support claim. Source19 retains04API+overlay provenance admitted by exactselected05identity. Freshnative16/3 separate. Source counts overlap; no sum asuniqueprogramcoverage. Originalfailures andgeneratedCreplay preserved separately.','inputs':list(INPUTS.values())}
 for row in report['inputs']:pin(Path(row['file']),row['sha256'])
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'pass':True,'report':pin(a.out),'inputs':len(report['inputs'])}))
if __name__=='__main__':main()
