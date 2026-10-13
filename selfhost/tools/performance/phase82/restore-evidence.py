#!/usr/bin/env python3
"""Restore content-addressed Phase82 evidence into a NEW directory: EVIDENCE OUT."""
import hashlib,json,os,sys,zipfile
from pathlib import Path
src,out=map(Path,sys.argv[1:]);v=json.loads((src/'verification.json').read_text());mfile=src/'manifest.json';assert hashlib.sha256(mfile.read_bytes()).hexdigest()==v['manifestSha256'];m=json.loads(mfile.read_text());assert not out.exists();out.mkdir(parents=True)
archive=out/'.phase82-restore.zip';joined=hashlib.sha256()
with archive.open('xb') as f:
 for r in v['parts']:
  p=src/r['path'];data=p.read_bytes();assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256'];joined.update(data);f.write(data)
assert joined.hexdigest()==v['archiveSha256']
with zipfile.ZipFile(archive) as z:
 for r in m['files']:
  rel=Path(r['path']);assert not rel.is_absolute() and '..' not in rel.parts
  data=z.read('objects/'+r['sha256']);assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256'];p=out/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data);os.chmod(p,r['mode'])
 for name in m['emptyDirectories']:
  rel=Path(name);assert not rel.is_absolute() and '..' not in rel.parts;(out/rel).mkdir(parents=True,exist_ok=True)
for r in m.get("symbolicLinks",[]):
 rel=Path(r["path"]);assert not rel.is_absolute() and ".." not in rel.parts
 p=out/rel;p.parent.mkdir(parents=True,exist_ok=True);p.symlink_to(r["target"])
archive.unlink();print(json.dumps(dict(complete=True,files=len(m['files']),restored=str(out))))
