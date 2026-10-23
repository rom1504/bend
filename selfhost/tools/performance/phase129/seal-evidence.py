"""Archive Phase129 evidence and verify every archived file against its source."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase129')
files=[]
for directory in [ROOT/'selfhost/build/phase129',ROOT/'selfhost/build/phase113/p129-profile01',ROOT/'selfhost/build/phase113/p129-context02']:
    files.extend(f for f in directory.rglob('*') if f.is_file() and not f.is_symlink()
                 and f.name!='program' and f.suffix not in {'.pyc','.o'})
manifest=json.loads((ROOT/'selfhost/build/phase129/profile01/manifest.json').read_text())
files += [Path(manifest['sampler']['file']),Path(manifest['unwindTable']['file'])]
for w in manifest['workloads']:
    for v in w['variants']:
        files += [Path(v['expected'][k]['file']) for k in ['stdout','stderr']]
files=sorted(set(files))
sha=lambda b:hashlib.sha256(b).hexdigest()
entries=[dict(path=str(f.relative_to(ROOT)),bytes=f.stat().st_size,sha256=sha(f.read_bytes())) for f in files]
scope='Raw samples, ordered contexts/callers, events, exact output observations/oracles, receipts, owner maps, diagnostic runtime source and analysis. Existing qualified compiler ELF/object and host libraries remain pinned external artifacts; no compiler selection change.'
inventory=dict(complete=True,methodSha256=sha(Path(__file__).read_bytes()),files=entries,scope=scope)
payload=(json.dumps(inventory,indent=2)+'\n').encode();out.mkdir(parents=True)
archive=out/'results.tar.gz'
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,filename='',mode='wb',mtime=0,compresslevel=6) as zipped,tarfile.open(fileobj=zipped,mode='w|') as tar:
    seen={}
    for name,file in [('INVENTORY.json',None),*((e['path'],f) for e,f in zip(entries,files))]:
        data=payload if file is None else file.read_bytes();digest=sha(data)
        info=tarfile.TarInfo(name);info.mode=0o644
        if digest in seen:info.type=tarfile.LNKTYPE;info.linkname=seen[digest];tar.addfile(info)
        else:info.size=len(data);tar.addfile(info,io.BytesIO(data));seen[digest]=name
with tarfile.open(archive,'r:gz') as tar:
    actual={}
    for member in tar:
        data=tar.extractfile(member).read();actual[member.name]=(len(data),sha(data))
assert actual.pop('INVENTORY.json')==(len(payload),sha(payload))
assert actual=={e['path']:(e['bytes'],e['sha256']) for e in entries}
for f,e in zip(files,entries):assert sha(f.read_bytes())==e['sha256']
index=dict(complete=True,archive=dict(file='results.tar.gz',bytes=archive.stat().st_size,sha256=sha(archive.read_bytes())),
    files=len(files),uncompressedBytes=sum(e['bytes'] for e in entries),everyArchivedFileHashVerified=True,scope=scope)
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n')
print(json.dumps(index))
