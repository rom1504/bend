#!/usr/bin/env python3
"""Publish the already-verified capsule in bounded Git-sized parts; no raw writes."""
import hashlib,json
from pathlib import Path
here=Path(__file__).resolve().parent;dest=here/'raw';meta=dest/'archive.json'
def ident(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return {'path':p.name,'bytes':p.stat().st_size,'sha256':h.hexdigest()}
a=json.loads(meta.read_text());assert a['complete'] and a['reopenedVerified'] and a['inputStabilityVerified']
source=dest/a['archive']['path'];assert ident(source)==a['archive']
assert not (dest/'parts.json').exists()
parts=[];limit=40*1024*1024
with source.open('rb') as src:
 remaining=source.stat().st_size
 while remaining:
  name=source.name+'.part-'+str(len(parts)).zfill(3);out=dest/name;size=min(limit,remaining)
  with out.open('xb') as target:
   left=size
   while left:
    b=src.read(min(left,1024*1024));assert b;target.write(b);left-=len(b)
  parts.append(ident(out));assert parts[-1]['bytes']==size;remaining-=size
 assert not src.read(1)
h=hashlib.sha256();total=0
for row in parts:
 p=dest/row['path'];assert ident(p)==row
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b);total+=len(b)
assert h.hexdigest()==a['archive']['sha256'] and total==a['archive']['bytes']
assert ident(source)==a['archive']
result={'kind':'phase45-verified-archive-parts','complete':True,'producer':ident(Path(__file__)),'archiveMetadata':ident(meta),'archive':a['archive'],'maxPartBytes':limit,'parts':parts,'concatenationVerified':True,'scope':'Byte-identical publication of the previously reopened and source-verified closed raw capsule. Reassemble ordered parts to the original archive path before using archive.json or the selected-release index. No raw input changes.'}
with (dest/'parts.json').open('x') as f:json.dump(result,f,indent=2);f.write('\n')
with (dest/'.gitignore').open('x') as f:f.write('/raw-campaign.tar.gz\n')
print(json.dumps({'complete':True,'parts':len(parts),'bytes':total,'sha256':h.hexdigest()}))
