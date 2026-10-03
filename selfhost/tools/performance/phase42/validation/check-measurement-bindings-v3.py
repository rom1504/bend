#!/usr/bin/env python3
"""Readonly final runtime/cost binding checks; queue with root, never during timing."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
PIN='018751270e800bc222a93dad7f257083ee53a5f7'
BASE_API='9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b'
CASES=['local-pair','tree-bitonic','coverage-numeric-recurrence-1024','coverage-list-pipeline-512']
def read(p):return json.loads(Path(p).read_text())
def identity(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verified(row):
 p=row.get('file',row.get('path'));assert p and identity(p)['sha256']==row['sha256'],p
 return identity(p)
def same(a,b):
 assert a['sha256']==b['sha256'] and Path(a.get('file',a.get('path'))).resolve()==Path(b.get('file',b.get('path'))).resolve()
 verified(a);verified(b)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('recipe',type=Path);p.add_argument('--cost',action='store_true');p.add_argument('--receipt',type=Path,required=True);a=p.parse_args()
 assert not a.receipt.exists(),'Receipt must be fresh'
 r=read(a.recipe);assert r['kind']=='phase42-materialized-final-integration-recipe' and r['complete'] and r['bound']
 b=r['candidateBinding'];verified(b['attempt']);m=read(b['attempt']['path']);assert m['checked'] and m['api']==b['api']
 for key in ['api','runtime','base','node']:same(m[key],b[key])
 out=Path(r['bindings']['OUT']);candidate=out/'full-preparation/manifest.json';baseline=ROOT/'selfhost/tools/performance/phase42/baseline/manifest.json';catalog=ROOT/'selfhost/tools/performance/phase37/catalog.json'
 c=read(candidate);z=read(baseline);cat=read(catalog)
 assert c['complete'] and z['complete'] and c['upstreamCommit']==z['upstreamCommit']==cat['upstreamCommit']==PIN
 assert c['catalogSha256']==z['catalogSha256']==identity(catalog)['sha256']
 ids=cat['sets']['full'];assert len(ids)==45 and len(set(ids))==45
 for bundle in [c,z]:
  assert len(bundle['cases'])==45 and {x['id'] for x in bundle['cases']}==set(ids)
 assert set(c['roles'])=={'candidate'} and set(z['roles'])=={'baseline','typescript'}
 comp=c['roles']['candidate']['compiler'];assert comp['kind']=='checked-development-attempt' and comp['artifact']=='derived-b1'
 for key in ['api','runtime','base']:same(comp[key],b[key])
 driver=Path(r['bindings']['ATTEMPT'])/'snapshot/tools/typed-driver.mjs';same(comp['driver'],identity(driver))
 bm_path=ROOT/'selfhost/build/phase41/checked01/attempt.json';bm=read(bm_path);assert bm['checked'] and bm['api']['sha256']==BASE_API
 bc=z['roles']['baseline']['compiler'];assert bc['api']['sha256']==BASE_API and bc['artifact']=='derived-b1'
 for key in ['api','runtime','base']:same(bc[key],bm[key])
 same(bc['driver'],identity(bm_path.parent/'snapshot/tools/typed-driver.mjs'))
 ts=z['roles']['typescript']['compiler'];assert ts['kind']=='checked-pinned-typescript' and ts['upstreamCommit']==PIN
 # Resolve only the existing exact generic-row observation adapter to its checked raw emission.
 preparation_path=candidate.parent/'preparation.json';preparation=read(preparation_path)
 assert preparation['complete'] and preparation['kind']=='bend-program-preparation'
 producer=verified(preparation['producer']);same(producer,identity(ROOT/'selfhost/tools/performance/programs/prepare.py'))
 adapters={}
 for adapter in preparation['adapters']:
  assert adapter['kind']=='complete-generic-row-serialization';same(adapter['producer'],preparation['producer'])
  raw=(candidate.parent/adapter['raw']['path']).resolve();adapted=(candidate.parent/adapter['adapted']['path']).resolve()
  assert raw.is_relative_to(candidate.parent.resolve()) and adapted.is_relative_to(candidate.parent.resolve())
  verified(dict(file=str(raw),sha256=adapter['raw']['sha256']));verified(dict(file=str(adapted),sha256=adapter['adapted']['sha256']))
  text=raw.read_text();assert text.count('export default ')==1
  expected=text.replace('export default ','const $Owned_exports = ',1)+'\nexport default {...$Owned_exports,bench:(n,seed)=>{const st=$Owned_exports["row.probe"](n,seed);return JSON.stringify(st.a.map(x=>x.array));}};\n'
  assert expected.encode()==adapted.read_bytes(),'generic-row observer differs from retained preparation'
  assert adapted not in adapters;adapters[adapted]=raw
 # Full acquisition receipts connect each candidate module to this exact attempt.
 for row in c['cases']:
  mod=row['modules']['candidate'];module=(candidate.parent/mod['path']).resolve();verified(dict(file=str(module),sha256=mod['sha256']))
  raw=adapters.get(module,module)
  receipt=read(str(raw)+'.json');assert receipt['complete'] and receipt['observation']['checked'] is True and receipt['observation']['status']=='ok'
  same(receipt['attempt'],b['attempt']);assert receipt['compiler']==comp
  assert receipt['output']['sha256']==identity(raw)['sha256'] and receipt['input']['sha256']==row['sourceSha256']
  assert (module in adapters)==(next(x for x in cat['cases'] if x['id']==row['id']).get('adapter')=='generic-row')
 result=dict(kind='phase42-frozen-measurement-bindings',complete=True,attempt=b['attempt'],api=b['api'],node=b['node'],baseline=identity(baseline),baselineAttempt=identity(bm_path),candidate=identity(candidate),catalog=identity(catalog),cases=45,producer=identity(__file__),preparation=identity(preparation_path),adapterCount=len(adapters),performanceAdmitted=False)
 if a.cost:
  config_path=out/'cost-plan/config.json';config=read(config_path)
  assert config['kind']=='phase35-normal-checked-library-cost-plan' and config['complete']
  assert config['cpu']=='3' and config['samples']==3 and config['timeoutMs']==180000 and config['heapMiB']==1024 and config['rssMiB']==config['availableMiB']==2048
  assert config['order']==['typescript','baseline','candidate'] and [x['id'] for x in config['cases']]==CASES
  same(config['node'],b['node'])
  for role,manifest,path in [('baseline',bm,bm_path),('candidate',m,Path(b['attempt']['path']))]:
   v=config['variants'][role];assert v['complete'];same(v['manifest'],identity(path))
   for key in ['api','runtime','base']:same(v[key],manifest[key])
  assert config['variants']['typescript']['complete'] and config['variants']['typescript']['typescript'] is True
  result['costConfig']=identity(config_path);result['costRequests']=36
 a.receipt.parent.mkdir(parents=True,exist_ok=True);a.receipt.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
