#!/usr/bin/env python3
"""Join exact checked direct acquisition with unchanged checked TypeScript emissions."""
import argparse,hashlib,json
from pathlib import Path
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['typescript','direct','catalog','reference-controls','out']:ap.add_argument('--'+name,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists();ts=read(a.typescript);direct=read(a.direct);catalog=read(a.catalog);reference=read(a.reference_controls)
 assert ts['complete'] and ts['passed'] and direct['complete'] and direct['passed']
 assert reference['complete'] and reference['pass'] and not reference['candidateExecuted'] and reference['differentialObservations']==0 and reference['counts']=={'pass':59,'fail':0,'total':59}
 assert direct['catalog']==ident(a.catalog) and catalog['selectedScope']['selectedFixtures']==14 and catalog['selectedScope']['selectedScenarios']==55
 assert len(catalog['cases'])==14 and sum(len(c['tests'])for c in catalog['cases'])==55 and all(c['mode']=='library' for c in catalog['cases'])
 assert Path(catalog['parent']['file']).resolve().is_file() and ident(catalog['parent']['file'])==catalog['parent']
 roles=dict(typescript=dict(modules={}),direct=direct['roles']['direct']);assert len(roles['direct']['modules'])==14
 for c in catalog['cases']:
  source=Path(a.catalog.parent/c['source']['path']).resolve();assert ident(source)['sha256']==c['source']['sha256']
  for role,record in [('typescript',ts['roles']['typescript']),('direct',roles['direct'])]:
   p=Path(record['modules'][c['id']]);receipt=read(str(p)+'.json');assert receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status']=='ok'
   assert receipt['input']['sha256']==c['source']['sha256'] and receipt['output']['sha256']==ident(p)['sha256']
   if role=='typescript':roles['typescript']['modules'][c['id']]=str(p.resolve())
   else:assert receipt['attempt']['sha256']==roles['direct']['attempt']['sha256']
 out=dict(kind='phase52-explicit-semantic-role-join',complete=True,executed=False,catalog=ident(a.catalog),roles=roles,parents=[ident(a.typescript),ident(a.direct),ident(a.reference_controls),catalog['parent']],selectedScope=catalog['selectedScope'],scope='Reuse exact same checked TypeScript source emissions without recompiling. Catalog parent explicitly retains full18/59 and four unsupported CLI obligations; current direct03 prototype execution scope is14library55. This join executes no target and is not semantic PASS.')
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,manifest=ident(a.out))))
if __name__=='__main__':main()
