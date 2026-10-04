#!/usr/bin/env python3
"""Close and verify the small Phase46 evidence capsule, preserving failed attempts."""
import argparse,gzip,hashlib,json,tarfile,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase46'
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=True)
archive=a.out/'capsule.tar.gz';manifest=a.out/'capsule.json'
assert not archive.exists() and not manifest.exists()
tools=RAW/'final-tools';tools.mkdir(exist_ok=False)
for f in Path(__file__).resolve().parent.iterdir():
 if f.is_file():(tools/f.name).write_bytes(f.read_bytes())
files=sorted(p for p in RAW.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
files+=sorted(p for p in a.out.rglob('*') if p.is_file() and (p.parent.name.startswith('feasibility-') or p.name.startswith('numeric-upstream')))
rows=[]
with archive.open('xb') as raw:
 with gzip.GzipFile(fileobj=raw,mode='wb',mtime=0,filename='') as gz:
  with tarfile.open(fileobj=gz,mode='w|',format=tarfile.PAX_FORMAT) as tar:
   for f in files:
    name=str(f.relative_to(ROOT));data=f.read_bytes()
    rows.append(dict(path=name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
    tar.add(f,arcname=name,recursive=False)
with tarfile.open(archive,'r:gz') as tar:
 assert set(tar.getnames())=={r['path'] for r in rows}
 for row in rows:
  data=tar.extractfile(row['path']).read()
  assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']
  assert hashlib.sha256((ROOT/row['path']).read_bytes()).hexdigest()==row['sha256']
record=dict(kind='phase46-closed-evidence-capsule',created=time.time(),complete=True,
 archive=dict(path=str(archive.relative_to(ROOT)),bytes=archive.stat().st_size,sha256=hashlib.sha256(archive.read_bytes()).hexdigest()),
 files=rows,filesCount=len(rows),uncompressedBytes=sum(r['bytes'] for r in rows),
 restore='From a clean repository root: tar -xzf implementation/phase46/evidence/capsule.tar.gz. Refuse to overwrite any existing experiment directories; use a fresh checkout or separate inspection directory.',
 scope='All Phase46 raw generated sources/binaries, failed and successful attempts, profiles/counters, original and final tool snapshots. Installed compiler, maintained source fixtures and upstream pin remain repository prerequisites for recompilation.')
manifest.write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ['complete','filesCount','uncompressedBytes','archive']}))
