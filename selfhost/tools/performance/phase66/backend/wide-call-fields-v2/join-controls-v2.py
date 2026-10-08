#!/usr/bin/env python3
"""Data-only qualification receipt for the Min and bounded-field migration."""
from pathlib import Path
import argparse, hashlib, json
ROOT=Path(__file__).resolve().parents[6]
INPUTS={}
def pin(p,want=None):
 p=p.resolve(strict=True);b=p.read_bytes();h=hashlib.sha256(b).hexdigest();assert want is None or h==want,(str(p),h,want)
 x={'file':str(p),'sha256':h,'bytes':len(b)};INPUTS[str(p)]=x;return x
def read(p):
 return json.loads(p.read_text()),pin(p)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--recipe',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();assert not a.out.exists();pin(Path(__file__))
 r,rp=read(a.recipe);attempt,at=read(Path(r['attempt']['file']));assert at['sha256']==r['attempt']['sha256'];assert attempt['checked'];api=pin(Path(attempt['api']['file']),attempt['api']['sha256']);assert api['sha256']==r['api']['sha256']
 source,sp=read(Path(r['commands'][0]['report']));private,pp=read(Path(r['commands'][1]['report']))
 assert source['selectedComplete'] and not source['changedInputs'] and source['summary']['statuses']=={'pass':5}
 assert private['complete'] and private['pass'] and len(private['cases'])==18 and all(x['pass'] for x in private['cases'])
 assert private['api']['sha256']==api['sha256'] and private['attempt']['sha256']==at['sha256']
 for x in private['inputs']:pin(Path(x['file']),x['sha256'])
 for name,h in source['inputHashes'].items():pin(Path(source['inputPaths'].get(name,name)),h)
 parent,parent_pin=read(a.recipe.with_name('recipe.json'));assert parent['attempt']['sha256']==at['sha256'];image=next(x for x in parent['images'] if x['role']=='bend-direct');assert pin(Path(image['compilerImage']['file']),image['compilerImage']['sha256'])['sha256']==api['sha256']
 for row in image['copies']:
  before=pin(Path(row['source']['file']),row['source']['sha256']);after=row['copy'];expected=image['adapterAfter']['sha256'] if after['file']==image['adapterAfter']['file'] else before['sha256'];pin(Path(after['file']),expected)
 ts,tsp=read(ROOT/'selfhost/build/phase66/conformance-new-ts-js01/typescript-new/js/report.json');assert ts['finished'] and not ts['changedInputs'];reference={x['id']:x for x in ts['results']};rows=[]
 for x in source['results']:
  y=reference[x['id']];assert all(z['status']=='pass' and z['evidence']=='checked-execution' and z['result']['checked'] for z in [x,y]);assert x['result']['output']==y['result']['output'];rows.append({'id':x['id'],'pass':True,'output':x['result']['output']})
 here=Path(__file__).parent;patches=[]
 for directory,module in [(here,'calls.bend'),(here.parent/'min-erasure-v1','core.bend')]:
  c,cp=read(directory/'candidate.json');actual=pin(Path(attempt['snapshot']['root'])/'src/back/js/direct'/module,c['after']['sha256']);patches.append({'candidate':cp,'actualSource':actual})
 result={'kind':'phase66-min-wide-selected-controls','complete':True,'pass':True,'dataOnly':True,'attempt':at,'api':api,'recipe':rp,'sourceRoleRecipe':parent_pin,'patches':patches,'sourceReport':sp,'referenceReport':tsp,'referenceScope':{'wholeReportComplete':ts['complete'],'wholeReportSelectedComplete':ts['selectedComplete'],'admission':'Only the five individually passed checked executions are reused; no whole-reference pass is claimed.'},'sourceCases':rows,'privateReport':pp,'privateCases':private['cases'],'scope':'Five actual checked direct-JavaScript source executions equal the already-passing pinned TS outputs. Eighteen actual-image private controls verify complete scan values and explicit bounded admission. No general compiler proof, native transfer, broad performance or installation claim.','inputs':list(INPUTS.values())}
 for x in result['inputs']:pin(Path(x['file']),x['sha256'])
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'pass':True,'report':pin(a.out),'inputs':len(result['inputs'])}))
if __name__=='__main__':main()
