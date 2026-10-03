#!/usr/bin/env python3
"""Collect unchanged broad/owner auditors plus exact reviewed new-owner contracts."""
import argparse,hashlib,json
from pathlib import Path
def ident(f):
 f=Path(f).resolve();return dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size)
def read(f):return json.loads(Path(f).read_text())
def verify(row):
 f=row.get('file',row.get('path'));assert ident(f)['sha256']==row['sha256'];return Path(f)
def verify_embedded(data):
 if isinstance(data,dict):
  if 'sha256' in data and ('file' in data or 'path' in data) and 'commit' not in data:verify(data)
  for value in data.values():verify_embedded(value)
 elif isinstance(data,list):
  for value in data:verify_embedded(value)
def pointer(data,key):
 for part in key.lstrip('/').split('/'):
  part=part.replace('~1','/').replace('~0','~');data=data[int(part)] if isinstance(data,list) else data[part]
 return data
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('recipe',type=Path);p.add_argument('scope',choices=['new','preinstall','postinstall']);p.add_argument('out',type=Path);a=p.parse_args()
 assert not a.out.exists();r=read(a.recipe);b=r['bindings'];base=Path(b['OUT']);attempt=r['candidateBinding']['attempt'];verify(attempt);api=r['candidateBinding']['api'];verify(api)
 inputs=[ident(__file__),ident(a.recipe)];groups=[]
 supplements=r.get('inheritedSupplementRequirements',[]) if a.scope!='new' else []
 assert len({s['name'] for s in supplements})==len(supplements) and not {s['name'] for s in supplements}&set(r['selectedOwners'])
 for spec in r['newOwnerRequirements']+supplements:
  report=Path(spec['report']);data=read(report);verify_embedded(data)
  if 'producer' in spec:
   producer=ident(spec['producer']);assert data.get('producerSha256',data.get('producer',{}).get('sha256'))==producer['sha256'];inputs.append(producer)
  if 'derivation' in spec:
   derivation=ident(spec['derivation']);assert data.get(spec.get('derivationField','derivationSha256'),data.get('derivation',{}).get('sha256'))==derivation['sha256'];inputs.append(derivation)
  for key,wanted in spec['assertions'].items():
   actual=pointer(data,key)
   if isinstance(wanted,dict) and set(wanted)=={'length'}:assert len(actual)==wanted['length'],(spec['name'],key)
   else:assert type(actual)==type(wanted) and actual==wanted,(spec['name'],key,actual,wanted)
  for relation in spec.get('relations',[]):
   assert set(relation)=={'target','lengthOf','multiply','add'}
   actual=pointer(data,relation['target']);assert type(actual)==int
   assert actual==len(pointer(data,relation['lengthOf']))*relation['multiply']+relation['add'],(spec['name'],'exact observation relation')
  for binding in spec['bindings']:
   doc=report if binding.get('document') is None else Path(binding['document']);d=read(doc);assert pointer(d,binding['pointer'])==binding['expected'],(spec['name'],'selected-image binding');inputs.append(ident(doc))
  e=read(spec['execution']);assert e['complete'] and e['returncode']==0 and not e.get('stoppedFor');verify(e['producer'])
  assert e['rssLimitBytes']==2048*1024**2 and e['availableFloorBytes']==2048*1024**2 and 0<e['secondsLimit']<=180
  assert e['peakTreeRssBytes']<=e['rssLimitBytes'] and e['minimumAvailableBytes']>=e['availableFloorBytes']
  assert spec.get('executionOutput','directory') in ['directory','file']
  assert str(report if spec.get('executionOutput')=='file' else report.parent) in e['command'],'Execution must consume exact report output path'
  inputs.extend([ident(report),ident(spec['execution'])]);groups.append(dict(name=spec['name'],complete=True))
 assert groups and len(groups)==len(r['selectedOwners'])+len(supplements) and {g['name'] for g in groups}==set(r['selectedOwners'])|{s['name'] for s in supplements}
 if a.scope!='new':
  for path,kind,count in [('owner-report.json','phase35-final-owner-controls',15),('phase36-close/report.json','phase36-final-owner-controls',7),('phase37-owners/closure/report.json','phase37-final-new-owner-controls-v2',3),('inherited-close/report.json','phase40-inherited-owner-controls-v2',4),('phase41-close/report.json','phase42-inherited-phase41-owner-close',2)]:
   file=Path(r['inheritedClosureReport']) if path=='inherited-close/report.json' and 'inheritedClosureReport' in r else base/path;data=read(file);assert data['kind']==kind and data['complete'] and data['pass'];assert len(data.get('cases',data.get('groups',[])))==count
   assert data['attempt']['sha256']==attempt['sha256'];verify(data['attempt'])
   if 'api'in data:assert data['api']['sha256']==api['sha256'];verify(data['api'])
   inputs.append(ident(file));groups.append(dict(name=kind,complete=True,count=count))
  expanded=read(base/'expanded-correctness/report.json');assert expanded['complete'] and expanded['pass'] and expanded['counts']=={'pass':154,'fail':0,'not-run':0,'pending':0};assert len(expanded['observations'])==154
  assert expanded['candidate']['attempt']['sha256']==attempt['sha256'] and expanded['candidate']['api']['sha256']==api['sha256'];inputs.append(ident(base/'expanded-correctness/report.json'))
  audit_path=base/(a.scope+'-audit/gates.json');audit=read(audit_path);assert audit['complete'] and audit['pass'] and len(audit['gates'])==(15 if a.scope=='postinstall' else 14)
  assert audit['attempt']['sha256']==attempt['sha256'] and audit['api']['sha256']==api['sha256'];assert audit['postInstallChecked']==(a.scope=='postinstall');inputs.append(ident(audit_path))
  groups.append(dict(name='inherited-'+a.scope+'-audit',complete=True,count=len(audit['gates'])))
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps({'kind':'phase42-composite-owner-and-gate-closure','complete':True,'pass':True,'scope':a.scope,'attempt':attempt,'api':api,'inputs':inputs,'groups':groups,'performanceAdmission':'Separate mandatory reviewed decision; this receipt establishes only listed semantic/installed gates.'},indent=2)+'\n')
 print(json.dumps(dict(complete=True,groups=len(groups),scope=a.scope)))
if __name__=='__main__':main()
