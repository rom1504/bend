#!/usr/bin/env python3
import json,sys,shutil,os
from pathlib import Path
root=Path(__file__).resolve().parents[3];sys.path.insert(0,str(root/'selfhost/tools/build'))
import assets
from common import pin,verify,require,write_json
proposal=root/'selfhost/build/phase174/selectors-proposal01'
d=json.loads((proposal/'report.json').read_text());require(d['complete'] is True,'Incomplete selector proposal')
out=root/'selfhost/build/phase174/selector-install01';require(not out.exists(),'Fresh transaction required')
for dest,src in d['installableFiles'].items():
 actual=pin(root/dest);require(all(actual[k]==src[k] for k in ('bytes','sha256')),'Installed product differs: '+dest)
for original in d['originalManifests'].values():verify(original)
for proposed in d['proposedManifests'].values():verify(proposed)
out.mkdir()
report={'kind':'phase174-operational-selector-publication','complete':False,'proposal':pin(proposal/'report.json'),'before':{},'after':{},'mutations':[]}
for name in d['originalManifests']:
 dest=root/'selfhost/manifests'/name;backup=out/name;shutil.copy2(dest,backup);report['before'][name]=pin(backup)
write_json(out/'report.json',report)
try:
 for name,src in d['proposedManifests'].items():
  dest=root/'selfhost/manifests'/name;temp=dest.with_name(dest.name+'.phase174.tmp');require(not temp.exists(),'Unexpected staging file')
  shutil.copy2(src['file'],temp);os.replace(temp,dest);report['mutations'].append(str(dest));report['after'][name]=pin(dest);write_json(out/'report.json',report)
 for name in d['proposedManifests']:
  doc=assets.load_assets(root/'selfhost/manifests'/name,root)
  for key in doc['assets']:assets.asset(doc,key)
 report['complete']=True;report['allAssetsVerified']=True;write_json(out/'report.json',report)
except Exception as e:
 for name in reversed(list(d['originalManifests'])):
  dest=root/'selfhost/manifests'/name;temp=dest.with_name(dest.name+'.phase174.rollback');shutil.copy2(out/name,temp);os.replace(temp,dest)
 report['error']=str(e);report['rolledBack']=True;write_json(out/'report.json',report);raise
print(json.dumps({'complete':True,'maps':len(d['proposedManifests'])}))
