#!/usr/bin/env python3
"""Reopen all portable benchmark roles and compare exact module identities; no targets."""
import argparse, json, sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from support import identity, save
from run import load_bundle, verify
p=argparse.ArgumentParser(description=__doc__)
for name in ['candidate','baseline','prepared','reference','catalog','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
inputs=[identity(x) for x in [__file__,PROGRAMS/'run.py',PROGRAMS/'support.py',a.catalog]]
catalog=json.loads(a.catalog.read_text());cases=catalog['cases'];assert len(cases)==45
bundles={}
for label,file,roles in [('candidate',a.candidate,['candidate']),('baseline',a.baseline,['baseline','typescript']),('prepared',a.prepared,['candidate']),('reference',a.reference,['baseline','typescript'])]:
 bundles[label]=load_bundle(file,catalog,identity(a.catalog)['sha256'],cases,roles,inputs)
 if label in ['candidate','baseline']:
  manifest=json.loads(file.read_text());assert 'archive' in manifest
  for field in ['provenance','preparation']:
   if field in manifest:inputs.append(verify(file.parent/manifest[field]['path'],manifest[field]))
rows=[]
for case in cases:
 for role,portable,original in [('candidate','candidate','prepared'),('baseline','baseline','reference'),('typescript','baseline','reference')]:
  new=bundles[portable]['points'][case['id']][role];old=bundles[original]['points'][case['id']][role]
  assert (new['sha256'],new['bytes'])==(old['sha256'],old['bytes'])
  assert bundles[portable]['roles'][role]['compiler']==bundles[original]['roles'][role]['compiler']
  rows.append(dict(id=case['id'],role=role,sha256=new['sha256'],bytes=new['bytes']))
for row in inputs:assert identity(row['path'])==row
save(a.out,dict(kind='phase52-portable-reader-verification',complete=True,passGate=True,dataOnly=True,
 scope='Maintained reader reopened archived bytes for all45 points/three roles; all135 module mappings equal exact measured loose acquisitions. No target execution or new timing.',
 cases=45,rolePointMappings=len(rows),inputs=inputs,inputsUnchanged=True,mappings=rows,
 archives={name:json.loads(file.read_text())['archive'] for name,file in [('candidate',a.candidate),('baseline',a.baseline)]}))
print(json.dumps(dict(complete=True,cases=45,rolePointMappings=len(rows),report=identity(a.out))))
