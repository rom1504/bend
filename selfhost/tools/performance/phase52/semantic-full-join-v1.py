#!/usr/bin/env python3
"""Join full checked direct emissions with exact retained/new TypeScript sources."""
import argparse,hashlib,json
from pathlib import Path
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--typescript',type=Path,action='append',required=True)
 for n in ['direct','catalog','reference-controls','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists();c=read(a.catalog);d=read(a.direct);ref=read(a.reference_controls)
 assert d['complete'] and d['passed'] and d['catalog']==ident(a.catalog)
 assert ref['complete'] and ref['pass'] and not ref['candidateExecuted'] and ref['counts']=={'pass':59,'fail':0,'total':59}
 assert len(c['cases'])==22 and sum(len(x['tests'])for x in c['cases'])==64
 ts={};parents=[ident(a.direct),ident(a.catalog),ident(a.reference_controls)]
 for f in a.typescript:
  m=read(f);assert m['complete'] and m['passed'];parents.append(ident(f))
  for k,v in m['roles']['typescript']['modules'].items():
   if k in ts:assert ts[k]==v
   ts[k]=v
 selected={}
 for case in c['cases']:
  source=(a.catalog.parent/case['source']['path']).resolve();assert ident(source)['sha256']==case['source']['sha256']
  for role,modules in [('typescript',ts),('direct',d['roles']['direct']['modules'])]:
   p=Path(modules[case['id']]);receipt=read(str(p)+'.json');assert receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status']=='ok'
   assert receipt['input']['sha256']==case['source']['sha256'] and receipt['output']['sha256']==ident(p)['sha256']
   if role=='typescript':selected[case['id']]=str(p.resolve())
   else:assert receipt['attempt']['sha256']==d['roles']['direct']['attempt']['sha256']
 out=dict(kind='phase52-full-semantic-role-join',complete=True,executed=False,catalog=ident(a.catalog),roles=dict(typescript=dict(modules=selected),direct=d['roles']['direct']),parents=parents,selectedScope=c['selectedScope'],scope='22sources64scenarios. Reuseold18checkedTSoutputs andjoin4newF32sources; samefrozencheckedcandidateimage. Data-onlymanifestnotsemanticPASS; directESMprogramvsupstreamCommonJS hosts are explicit.')
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(dict(complete=True,manifest=ident(a.out))))
if __name__=='__main__':main()
