"""Archive exact Phase128 receipts, raw observations and selected source evidence."""
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
assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase128')
files=[]
roots=[ROOT/'selfhost/build/phase128']
for phase in ['phase111','phase112','phase113','phase118']:
    roots.extend((ROOT/'selfhost/build'/phase).glob('p128-*'))
roots.append(ROOT/'selfhost/build/phase126/p128-screen01')
for directory in roots:
    if not directory.is_dir():continue
    for f in directory.rglob('*'):
        if not f.is_file() or f.is_symlink():continue
        if f.suffix in {'.json','.md','.py','.asm'} or (
            (f.suffix in {'.stdout','.stderr','.log'} or f.name in {'stdout','stderr'})
            and f.stat().st_size <= 65536):files.append(f)
for directory in ['phase128/native-source01','phase128/native-source02',
                  'phase128/field-source02','phase128/field-source03','phase128/field-source04']:
    files.extend((ROOT/'selfhost/build'/directory).glob('*.bend'))
for relative in ['phase128/runtime-borrow01/runtime.c','phase128/runtime-borrow01/runtime.h',
    'phase128/runtime-borrow01/runtime.o','phase128/field-oracle02/program.ssa',
    'phase111/p128-native-api02/api.mjs',
    'phase118/p128-field-emit01/compiler-name-search.ssa',
    'phase118/p128-field-emit01/borrow-controls.ssa',
    'phase118/p128-field-emit01/borrowed-observer-transfer.ssa']:
    files.append(ROOT/'selfhost/build'/relative)
files.extend((ROOT/'selfhost/build/phase128/field-machine01').glob('*.ssa'))
files=sorted(set(files))
digest=lambda b:hashlib.sha256(b).hexdigest()
entries=[dict(path=str(f.relative_to(ROOT)),bytes=f.stat().st_size,sha256=digest(f.read_bytes())) for f in files]
scope='Final source snapshots, exact receipts including failures, raw small outputs, machine excerpts, runtime and selected emitted kernels. Earlier checkpoint archives retain initial profiles and controls. Full native ELF/SSA/assembly remain at pinned build paths and are reproducible from the source/toolchain receipts. Absolute paths record original provenance.'
inventory=dict(complete=True,files=entries,scope=scope,methodSha256=digest(Path(__file__).read_bytes()))
payload=(json.dumps(inventory,indent=2)+'\n').encode();out.mkdir(parents=True)
archive=out/'results.tar.gz'
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',filename='',mtime=0,compresslevel=6) as zipped,tarfile.open(fileobj=zipped,mode='w|') as tar:
    content=[('INVENTORY.json',None),*((e['path'],f) for e,f in zip(entries,files))]
    seen={}
    for name,file in content:
        data=payload if file is None else file.read_bytes()
        h=digest(data);info=tarfile.TarInfo(name);info.mode=0o644
        if h in seen:
            info.type=tarfile.LNKTYPE;info.linkname=seen[h];tar.addfile(info)
        else:
            info.size=len(data);tar.addfile(info,io.BytesIO(data));seen[h]=name
with tarfile.open(archive,'r:gz') as tar:
    actual={member.name:(member.size if member.isfile() else len(tar.extractfile(member).read()),digest(tar.extractfile(member).read())) for member in tar}
assert actual.pop('INVENTORY.json')==(len(payload),digest(payload))
assert actual=={e['path']:(e['bytes'],e['sha256']) for e in entries}
for f,e in zip(files,entries):assert digest(f.read_bytes())==e['sha256'],'Changed during archive: '+str(f)
result=dict(complete=True,archive=dict(file='results.tar.gz',bytes=archive.stat().st_size,sha256=digest(archive.read_bytes())),files=len(files),uncompressedBytes=sum(e['bytes'] for e in entries),everyArchivedFileHashVerified=True,scope=scope)
(out/'index.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
