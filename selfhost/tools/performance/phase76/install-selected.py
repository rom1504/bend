#!/usr/bin/env python3
"""Execute reviewed deferred release commands, then verify preserved lineage."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];R=ROOT/'selfhost/build/phase76'
def read(p):return json.loads(p.read_text())
def pin(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
promotion=R/'promotion12.json';decision=read(promotion);assert decision['complete'] and decision['selected']=='compiler12'
plan=read(R/'compiler12-qualification-method/plan.json');checks=[]
for job in plan['deferredReleaseCommands']:
 print('starting release '+job['name'],flush=True)
 with (R/('release12-'+job['name']+'-controller.log')).open('x') as f:
  result=subprocess.run(job['command'],stdout=f,stderr=subprocess.STDOUT)
 assert result.returncode==0,job['name']
 receipt=R/'compiler12-release'/('job-'+job['name'])/'process.json';j=read(receipt);assert j['complete'] and j['returncode']==0;checks.append(pin(receipt));print('passed release '+job['name'],flush=True)
api=ROOT/'selfhost/dist/typed-api.mjs';assert pin(api)['sha256']==decision['images']['b1']['sha256']
old_api=next(x['sha256'] for x in plan['installedBefore'] if x['file'].endswith('/typed-api.mjs'))
history=ROOT/'selfhost/dist/release-history'/old_api
preserved=[]
for old in plan['installedBefore']:
 p=history/Path(old['file']).relative_to(ROOT/'selfhost/dist');now=pin(p);assert now['sha256']==old['sha256'] and now['bytes']==old['bytes'];preserved.append(now)
release=dict(complete=True,**{'pass':True},decision=pin(promotion),installed=pin(ROOT/'selfhost/dist/release.json'),api=pin(api),checks=checks,priorSevenFilesPreserved=True,preserved=preserved)
p=ROOT/'implementation/phase76/qualification.json';p.write_text(json.dumps(dict(promotion=decision,release=release),indent=2)+'\n');print(json.dumps(dict(complete=True,installedApi=pin(api),priorSevenFilesPreserved=True)))
