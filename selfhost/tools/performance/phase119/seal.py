"""Archive bounded exact measurements, preserving large artifacts by identity."""
import hashlib, io, json, tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase119';OUT=ROOT/'implementation/phase119/evidence'
assert not OUT.exists();OUT.mkdir()
def pin(p):return dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
files=sorted(p for p in BASE.rglob('*') if p.is_file() and p.suffix in ['.json','.stdout','.stderr','.samples','.log'])
assert all(p.stat().st_size<8*1024**2 for p in files)
assert sum(p.stat().st_size for p in files)<64*1024**2
rows=[pin(p) for p in files]
manifest=dict(complete=True,method=pin(Path(__file__).resolve()),files=rows,rawBytes=sum(x['bytes'] for x in rows),scope='Exact small reports, raw profiles and outputs. Native ELFs, compiler sources/toolchains and historical references remain external authenticated dependencies.')
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
(OUT/'summary.json').write_text(json.dumps(dict(complete=True,allPayloadsVerified=True,archive=pin(archive),files=len(rows),rawBytes=manifest['rawBytes']),indent=2)+'\n')
print(archive,len(rows),manifest['rawBytes'],archive.stat().st_size)
