#!/usr/bin/env python3
"""Verify/restore the qualified native assets; --all restores every experiment."""
import argparse,hashlib,json,os,shutil,tempfile,zipfile
from pathlib import Path
from native_support import ROOT,authenticate,DEFAULT_CACHE,require
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--all',action='store_true',help='Restore all raw evidence, requiring more disk space')
p.add_argument('--verify-only',action='store_true',help='Verify selected archived members without writing')
a=p.parse_args();receipt=json.loads((ROOT/'implementation/phase88/evidence.json').read_text())
def sha(b): return hashlib.sha256(b).hexdigest()
def checked(record):
 path=ROOT/record['file'];data=path.read_bytes()
 require(len(data)==record['bytes'] and sha(data)==record['sha256'],'Changed capsule metadata: '+str(path))
 return path
archive,manifestFile,assetsFile=[checked(receipt[k]) for k in ['archive','manifest','nativeAssets']]
manifest=json.loads(manifestFile.read_text());assets=json.loads(assetsFile.read_text())
require(str(ROOT)==assets['canonicalRoot'],'This cache binds its original canonical path. Relocation requires new qualification.')
names=set(assets['files']) if not a.all else {r['file'] for r in manifest}
selected=[r for r in manifest if r['file'] in names];require(len(selected)==len(names),'Missing asset')
needed=0
for row in selected:
 dest=ROOT/row['file'];require(dest.resolve().is_relative_to(ROOT),'Escaping path')
 if dest.exists(): require(sha(dest.read_bytes())==row['sha256'],'Refusing changed existing file: '+str(dest))
 else: needed+=row['bytes']
if not a.verify_only: require(shutil.disk_usage(ROOT).free>=needed+160*1024**2,'Insufficient disk for restore plus160MiB reserve')
with zipfile.ZipFile(archive) as saved:
 require(saved.namelist()==[r['file'] for r in manifest],'Archive member list mismatch')
 for row in selected:
  data=saved.read(row['file']);require(len(data)==row['bytes'] and sha(data)==row['sha256'],'Corrupt archive member')
  dest=ROOT/row['file']
  if a.verify_only or dest.exists():continue
  dest.parent.mkdir(parents=True,exist_ok=True)
  with tempfile.NamedTemporaryFile(dir=dest.parent) as temp:
   temp.write(data);temp.flush();os.link(temp.name,dest)
if not a.verify_only:
 image=ROOT/assets['executable'];image.chmod(image.stat().st_mode|0o111)
 authenticate(image,DEFAULT_CACHE)
print(json.dumps(dict(complete=True,verifiedFiles=len(selected),mode='verify' if a.verify_only else 'restore')))
