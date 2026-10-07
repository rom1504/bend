#!/usr/bin/env python3
"""Publish an already verified closed Phase60 capsule; split only at 100 MB."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024**2),b''):h.update(b)
 return dict(path=p.name,bytes=p.stat().st_size,sha256=h.hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--archive-dir',type=Path,required=True);a=p.parse_args()
dest=a.archive_dir.resolve();assert dest==ROOT/'selfhost/tools/performance/phase60/artifacts/raw'
meta=dest/'archive.json';capsule=json.loads(meta.read_text())
assert capsule['complete'] and capsule['reopenedVerified'] and capsule['inputStabilityVerified']
assert Path(capsule['rawRoot']).resolve()==ROOT/'selfhost/build/phase60'
assert capsule['archive']['path']=='raw-campaign.tar.gz'
source=dest/capsule['archive']['path'];assert ident(source)==capsule['archive']
out=dest/'publication.json';assert not out.exists()
limit=48*1024**2;split=source.stat().st_size>=100_000_000;parts=[]
if split:
 with source.open('rb') as src:
  remaining=source.stat().st_size
  while remaining:
   part=dest/(source.name+'.part-'+str(len(parts)).zfill(3));size=min(limit,remaining)
   with part.open('xb') as target:
    left=size
    while left:
     b=src.read(min(left,1024**2));assert b;target.write(b);left-=len(b)
   parts.append(ident(part));assert parts[-1]['bytes']==size;remaining-=size
  assert not src.read(1)
 h=hashlib.sha256();total=0
 for row in parts:
  f=dest/row['path'];assert ident(f)==row
  with f.open('rb') as stream:
   for b in iter(lambda:stream.read(1024**2),b''):h.update(b);total+=len(b)
 assert h.hexdigest()==capsule['archive']['sha256'] and total==capsule['archive']['bytes']
 with (dest/'.gitignore').open('x') as f:f.write('/raw-campaign.tar.gz\n')
assert ident(source)==capsule['archive']
report=dict(kind='phase60-verified-capsule-publication',complete=True,producer=ident(Path(__file__)),
 archiveMetadata=ident(meta),archive=capsule['archive'],split=split,maxPartBytes=limit,
 githubFileLimitBytes=100_000_000,parts=parts,concatenationVerified=split,
 scope='Publication only of the inherited reopened/member-verified capsule; no raw changes or target execution.')
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,split=split,parts=len(parts))))
