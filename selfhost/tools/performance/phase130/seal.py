"""Archive bounded Phase130 receipts/controls; large binaries remain hash-addressed."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase130')
 paths=set()
 for phase in ['phase130','phase111','phase112','phase113','phase118']:
  folder=ROOT/'selfhost/build'/phase
  roots=[folder] if phase=='phase130' else [p for p in folder.glob('p130-*') if p.is_dir()]
  for base in roots:
   for p in base.rglob('*'):
    if not p.is_file() or p.is_symlink() or p.stat().st_size>2*1024**2:continue
    if p.suffix in ['.json','.log'] or p.name in ['stdout','stderr','emit.stderr','execute.stdout','execute.stderr'] or p.name.endswith(('.stdout','.stderr')):
     paths.add(p)
 for p in (ROOT/'selfhost/tools/performance/phase130').rglob('*'):
  if p.is_file() and p.suffix in ['.py','.mjs','.bend','.json','.md']:paths.add(p)
 out.mkdir(parents=True);rows=[]
 with (out/'evidence.tar.gz').open('xb') as raw:
  with gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as gz:
   with tarfile.open(fileobj=gz,mode='w') as tar:
    for p in sorted(paths):
     data=p.read_bytes();identity=pin(p);assert identity['bytes']==len(data) and identity['sha256']==hashlib.sha256(data).hexdigest()
     name=str(p.relative_to(ROOT));entry=tarfile.TarInfo(name);entry.size=len(data);entry.mode=0o644;tar.addfile(entry,io.BytesIO(data));rows.append(dict(original=identity,archivePath=name))
 with tarfile.open(out/'evidence.tar.gz','r:gz') as tar:
  for row in rows:
   data=tar.extractfile(row['archivePath']).read();assert hashlib.sha256(data).hexdigest()==row['original']['sha256']
 index=dict(complete=True,method=pin(Path(__file__).resolve()),archive=pin(out/'evidence.tar.gz'),files=rows,
            scope='Exact bounded receipts/methods/fixtures including failures; large images, SSA and full preparation graphs remain pinned in receipts. Frozen compiler source has a separate committed archive.')
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(dict(complete=True,files=len(rows),archive=index['archive'])))
if __name__=='__main__':main()
