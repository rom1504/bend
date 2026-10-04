#!/usr/bin/env python3
"""Freeze exact actual-owner wrappers and extend all16 inherited owners; execute no targets."""
import argparse,hashlib,json,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
def ident(p):
 p=Path(p).resolve();data=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
def main():
 p=argparse.ArgumentParser(description=__doc__)
 for k in ['config','attempt','campaign','contracts','extension']:p.add_argument('--'+k,type=Path,required=True)
 a=p.parse_args();config=json.loads(a.config.read_text());assert config['reviewed'] is True
 assert not a.contracts.exists() and not a.extension.exists() and not a.contracts.resolve().is_relative_to(a.campaign.resolve())
 m=json.loads((a.attempt/'attempt.json').read_text());assert m['checked'];catalogue=json.loads((HERE/'owner-catalogue-v3.json').read_text())
 b={'ATTEMPT':str(a.attempt.resolve()),'OUT':str(a.campaign.resolve()),'NODE':m['node']['file']}
 def resolve(value):
  if isinstance(value,str):
   for key,actual in b.items():value=value.replace('${'+key+'}',actual)
   assert '${' not in value;return value
  if isinstance(value,list):return [resolve(x) for x in value]
  if isinstance(value,dict):return {k:resolve(v) for k,v in value.items()}
  return value
 config=resolve(config);names=[row['owner'] for row in config['owners']];assert len(names)==len(set(names)) and names
 a.contracts.mkdir(parents=True);steps=config['steps'];assert all(s['name'].startswith('phase43-') and s['argv'] for s in steps);requirements=[]
 for row in config['owners']:
  owner=row['owner'];policy=catalogue[owner];tool=ident(ROOT/policy['controller'])
  if 'controllerSha256' in policy:assert tool['sha256']==policy['controllerSha256'],'frozen actual owner controller required'
  snapshot=a.contracts/(owner+'-controller'+Path(tool['file']).suffix);shutil.copyfile(tool['file'],snapshot)
  contract=dict(kind='phase43-actual-owner-frozen-contract',complete=True,owner=owner,policy=policy,catalogueSha256=ident(HERE/'owner-catalogue-v3.json')['sha256'],attempt=ident(a.attempt/'attempt.json'),controller=tool,controllerSnapshot=ident(snapshot),rawReport=row['rawReport'],rawExecution=row['rawExecution'],rawCommandInput=row['rawCommandInput'],emittedModules=row.get('emittedModules',[]),derivations=row.get('derivations',[]),auxiliaryInputs=row.get('auxiliaryInputs',[]))
  if 'derivationController' in policy:contract['derivationController']=ident(ROOT/policy['derivationController'])
  file=a.contracts/(owner+'.json');file.write_text(json.dumps(contract,indent=2)+'\n');dest=a.campaign/('phase43-close-'+owner);execution=a.campaign/('run-phase43-close-'+owner)
  steps.append(dict(name='phase43-close-'+owner,lockOwner=True,argv=['python3',str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py'),'--seconds','120','--rss-mib','2048','--available-mib','2048',str(execution.resolve()),'--','python3',str(HERE/'wrap-owner-v3.py'),str(file.resolve()),str(dest.resolve())]))
  requirements.append(dict(name='phase43-'+owner,report=str(dest.resolve()/'report.json'),execution=str(execution.resolve()/'run.json'),producer=str(HERE/'wrap-owner-v3.py'),assertions={'/kind':'phase43-selected-image-owner-controls','/complete':True,'/pass':True,'/owner':owner,'/semanticAssertions':policy['assertions']},bindings=[{'pointer':'/attempt/sha256','expected':'${ATTEMPT_SHA}'},{'pointer':'/api/sha256','expected':'${API_SHA}'},{'pointer':'/runtime/sha256','expected':'${RUNTIME_SHA}'},{'pointer':'/contract/sha256','expected':ident(file)['sha256']},{'pointer':'/controller/sha256','expected':tool['sha256']}]))
 extension=dict(reviewed=True,steps=steps,requirements=requirements,producer=ident(__file__),config=ident(a.config),catalogue=ident(HERE/'owner-catalogue-v3.json'),contractFiles=[ident(a.contracts/(name+'.json')) for name in names])
 a.extension.parent.mkdir(parents=True,exist_ok=True);a.extension.write_text(json.dumps(extension,indent=2)+'\n');print(json.dumps(dict(complete=True,executed=False,extension=ident(a.extension),owners=names)))
if __name__=='__main__':main()
