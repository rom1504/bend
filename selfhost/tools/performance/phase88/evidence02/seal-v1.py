#!/usr/bin/env python3
"""Seal all Phase88 attempts and the exact assets needed for native requests."""
import hashlib,json,zipfile
from pathlib import Path
from native_support import ROOT, authenticate, DEFAULT_CACHE
HERE=Path(__file__).resolve().parent;RAW=ROOT/'selfhost/build/phase88';OUT=HERE/'evidence01'
def digest(b): return hashlib.sha256(b).hexdigest()
def pin(f):
 b=f.read_bytes();return dict(file=str(f.relative_to(ROOT)),sha256=digest(b),bytes=len(b))
auth=authenticate(RAW/'compiler-native02',DEFAULT_CACHE)
assets=set()
def collect(value):
 if isinstance(value,dict):
  file=value.get('file',value.get('path'))
  if isinstance(file,str) and 'sha256' in value:
   p=Path(file);assert p.is_relative_to(ROOT) and pin(p)['sha256']==value['sha256'];assets.add(p)
  for child in value.values():collect(child)
 elif isinstance(value,list):
  for child in value:collect(child)
collect(auth)
build=json.loads(Path(auth['build']['file']).read_text());assets.add(Path(build['guard'].get('path',build['guard'].get('file'))))
files=set(p for p in RAW.rglob('*') if p.is_file())|assets
for directory in json.loads((RAW/'native-launcher-logs.json').read_text()):
 files.update(p for p in (ROOT/directory).rglob('*') if p.is_file())
OUT.mkdir(exist_ok=False)
manifest=[];archive=OUT/'phase88.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as saved:
 for p in sorted(files):
  b=p.read_bytes();name=str(p.relative_to(ROOT));saved.writestr(name,b)
  manifest.append(dict(file=name,sha256=digest(b),bytes=len(b)))
manifestFile=OUT/'manifest.json';manifestFile.write_text(json.dumps(manifest,indent=2)+'\n')
assetsFile=OUT/'native-assets.json';assetsFile.write_text(json.dumps(dict(canonicalRoot=str(ROOT),files=[str(p.relative_to(ROOT)) for p in sorted(assets)],executable=str((RAW/'compiler-native02').relative_to(ROOT))),indent=2)+'\n')
with zipfile.ZipFile(archive) as saved:
 assert saved.namelist()==[r['file'] for r in manifest]
 for r in manifest:
  b=saved.read(r['file']);assert len(b)==r['bytes'] and digest(b)==r['sha256']
for r in manifest:assert pin(ROOT/r['file'])==r
receipt=dict(complete=True,archive=pin(archive),manifest=pin(manifestFile),nativeAssets=pin(assetsFile),files=len(files),rawBytes=sum(r['bytes'] for r in manifest),
 methods=[pin(p) for p in sorted(HERE.rglob('*')) if p.is_file() and OUT not in p.parents and '__pycache__' not in p.parts],
 scope='All Phase88 attempts including failed source/harness controls; full images/source/C/JS/profiles, broad C/execution evidence, first/repeated comparisons, JS development gate, launcher logs, and exact external assets needed by native02 authentication. Prior capsules remain unchanged. Not a portable cache or native B2 release.')
(ROOT/'implementation/phase88/evidence.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:v for k,v in receipt.items() if k!='methods'}))
