"""Archive bounded exact experiment evidence; membership is not qualification."""
from pathlib import Path
import hashlib,json,tarfile,io
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase117';OUT=ROOT/'implementation/phase117/evidence'
def pin(p):return dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
assert not OUT.exists();OUT.mkdir();paths=[]
for p in BASE.rglob('*'):
 if p.is_file() and (p.suffix in {'.json','.log','.stdout','.stderr','.txt','.samples','.mjs','.py','.ssa','.c','.h'} or p.name in {'stdout','stderr'} or (p.suffix=='.bend' and p.name!='compiler.bend')):paths.append(p)
for d in (ROOT/'selfhost/build/phase111').glob('p117-*'):
 for p in d.rglob('*'):
  if p.is_file() and (p.suffix in {'.json','.log','.py','.s'} or p.name in {'stdout','stderr'}):paths.append(p)
for name in ['version-source03','unroll-source01','scalar-source01']:paths.append(BASE/name/'compiler.bend')
paths=sorted(set(paths));assert all(not p.is_symlink() and p.stat().st_size<8*1024**2 for p in paths);assert sum(p.stat().st_size for p in paths)<160*1024**2
rows=[pin(p) for p in paths];m=dict(complete=True,method=pin(Path(__file__).resolve()),files=rows,rawBytes=sum(r['bytes'] for r in rows),scope='Exact reports, raw outputs/profiles, emitted QBE/assembly, runtime C, selected/unroll/first-failed source snapshots and methods. APIs, ELF/object files and qualified parent dependencies remain externally pinned. Archive membership is not correctness qualification.');payload=json.dumps(m,indent=2).encode()+b'\n';archive=OUT/'receipts01.tar.gz'
with tarfile.open(archive,'w:gz',compresslevel=6) as t:
 info=tarfile.TarInfo('manifest.json');info.size=len(payload);info.mtime=0;t.addfile(info,io.BytesIO(payload))
 for p,r in zip(paths,rows):
  assert pin(p)==r;info=tarfile.TarInfo(r['file']);info.size=r['bytes'];info.mtime=0;t.addfile(info,io.BytesIO(p.read_bytes()))
with tarfile.open(archive,'r:gz') as t:
 assert len(t.getmembers())==len(rows)+1 and t.extractfile('manifest.json').read()==payload
 for r in rows:
  b=t.extractfile(r['file']).read();assert len(b)==r['bytes'] and hashlib.sha256(b).hexdigest()==r['sha256']
(OUT/'manifest.json').write_bytes(payload);s=dict(complete=True,allPayloadsVerified=True,archive=pin(archive),files=len(rows),rawBytes=m['rawBytes'],independentOutputCheck=pin(BASE/'independent-output-check02.json'));(OUT/'summary.json').write_text(json.dumps(s,indent=2)+'\n');print(json.dumps(s))
