"""Archive exact bounded diagnostic evidence; no binaries or production changes."""
from pathlib import Path
import hashlib,json,tarfile,io
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase116';OUT=ROOT/'implementation/phase116/evidence'
def pin(p):return dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
assert not OUT.exists();OUT.mkdir()
suffixes={'.json','.stdout','.stderr','.log','.txt','.samples','.cpuprofile','.mjs','.cjs'}
files=sorted(p for p in BASE.rglob('*') if p.is_file() and p.suffix in suffixes and 'matplotlib-cache' not in p.parts)
assert all(p.stat().st_size<=8*1024**2 for p in files)
assert sum(p.stat().st_size for p in files)<=32*1024**2
rows=[pin(p) for p in files];manifest=dict(kind='phase116-exact-diagnostic-capsule',method=pin(Path(__file__).resolve()),complete=True,files=rows,rawBytes=sum(x['bytes'] for x in rows),scope='Exact diagnostic receipts, source/producer manifests, raw PC/V8 profiles, generated JS and measured stdout/stderr. Native binaries and compiler APIs are external pinned dependencies. Archive membership is not correctness qualification.')
payload=json.dumps(manifest,indent=2).encode()+b'\n';archive=OUT/'receipts01.tar.gz'
with tarfile.open(archive,'w:gz',compresslevel=6) as t:
 info=tarfile.TarInfo('manifest.json');info.size=len(payload);info.mtime=0;t.addfile(info,io.BytesIO(payload))
 for p,row in zip(files,rows):
  assert pin(p)==row
  info=tarfile.TarInfo(row['file']);info.size=row['bytes'];info.mtime=0;t.addfile(info,io.BytesIO(p.read_bytes()))
with tarfile.open(archive,'r:gz') as t:
 assert len(t.getmembers())==len(rows)+1 and t.extractfile('manifest.json').read()==payload
 for row in rows:
  raw=t.extractfile(row['file']).read();assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
(OUT/'manifest.json').write_bytes(payload)
summary=dict(complete=True,allPayloadsVerified=True,archive=pin(archive),files=len(rows),rawBytes=manifest['rawBytes'],independentOutputCheck=pin(BASE/'independent-output-check01.json'))
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
