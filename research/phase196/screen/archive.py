"""Preserve raw model outputs, oracle streams, timings, guard and close receipts."""
import gzip
import io
import json
from pathlib import Path
import tarfile
from regions import BUILD, ROOT, digest

out=ROOT/'implementation/phase196'
root=BUILD/'phase196'
jobs=('model01','build01','build02','timingA','timingB','transfer01')
files=[root/'build02/build.json',root/'timingA/timing.json',root/'timingB/timing.json',
       root/'transfer01/transfer.json',*sorted((root/'model01').glob('*.stdout'))]
for job in jobs:
    guard=root/(job+'-guard')
    receipt=json.loads((guard/'process.json').read_text())
    assert receipt['finished'] and receipt['complete']==(job!='build01')
    files.extend([guard/'process.json',guard/'retention.json',guard/'stderr.log'])
    close=ROOT/'selfhost/build-retention/phase196'/(job+'-close')
    files.extend(sorted(close.glob('*.json')))
archive=out/'observations.tar.gz'
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',filename='',mtime=0) as compressed,tarfile.open(mode='w|',fileobj=compressed) as tar:
    for p in sorted(files):
        data=p.read_bytes()
        info=tarfile.TarInfo(str(p.relative_to(ROOT)));info.size=len(data)
        tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive) as tar:
    for p in files:
        assert tar.extractfile(str(p.relative_to(ROOT))).read()==p.read_bytes()
(out/'observations.json').write_text(json.dumps(dict(archive=archive.name,sha256=digest(archive),
     verified=len(files),files={str(p.relative_to(ROOT)):digest(p) for p in sorted(files)}),indent=2)+'\n')
