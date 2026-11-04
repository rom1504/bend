#!/usr/bin/env python3
"""Seal exact Phase159 evidence, including bytes already archived by retention."""
import contextlib,gzip,hashlib,json,shutil,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'implementation/phase159/evidence'
OUT.mkdir(exist_ok=True)
archive=OUT/'phase159.tar.gz'
assert not archive.exists()
assert shutil.disk_usage(ROOT).free > 5*1024**3+12*1024**2

def digest(stream):
    h=hashlib.sha256();n=0
    for b in iter(lambda:stream.read(1024*1024),b''):h.update(b);n+=len(b)
    return dict(bytes=n,sha256=h.hexdigest())
def pin(path):
    with path.open('rb') as f:return digest(f)

entries={}
roots=['selfhost/build/phase159','experiments/phase159/tools','selfhost/tools/profiler']
files={p for root in roots for p in (ROOT/root).rglob('*')
       if p.is_file() and '__pycache__' not in p.parts}
files.update((ROOT/'selfhost/build-retention/phase159').rglob('*.json'))
files.update(ROOT/p for p in ['selfhost/tools/build/common.py','selfhost/tools/execution.py',
    'selfhost/tools/build-retention/guard.py','selfhost/tools/build-retention/close.py',
    'selfhost/tools/build-retention/archive-v02.py'])
for p in sorted(files):
    assert p.resolve()==p
    entries[str(p.relative_to(ROOT))]=dict(identity=pin(p),file=p,mode=p.stat().st_mode&0o777)

restored=[]
for close in sorted((ROOT/'selfhost/build-retention/phase159').glob('*-close/report.json')):
    d=json.loads(close.read_text());assert d['complete']
    if not d['pruneRequested']:continue
    for row in d['roots']:
        rp=Path(row['archiveReceipt']['file'])
        assert pin(rp)=={k:row['archiveReceipt'][k] for k in ['bytes','sha256']}
        rd=json.loads(rp.read_text());ap=rp.parent/rd['archive']['path']
        assert pin(ap)=={k:rd['archive'][k] for k in ['bytes','sha256']}
        prefix=str(Path(rd['rawRoot']).relative_to(ROOT))
        with tarfile.open(ap,'r:gz') as tf:
            for m in tf:
                assert m.isfile() and m.name in rd['files']
                name=prefix+'/'+m.name
                with tf.extractfile(m) as f:assert digest(f)==rd['files'][m.name]
                if name in entries: assert entries[name]['identity']==rd['files'][m.name]
                else: entries[name]=dict(identity=rd['files'][m.name],archive=ap,member=m.name,mode=m.mode)
        restored.append(dict(receipt=str(rp.relative_to(ROOT)),archiveIdentity=pin(ap)))

@contextlib.contextmanager
def open_entry(e):
    if 'file' in e:
        with e['file'].open('rb') as f:yield f
    else:
        with tarfile.open(e['archive'],'r:gz') as tf:
            with tf.extractfile(e['member']) as f:yield f

with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,filename='',mode='wb',mtime=0) as gz,tarfile.open(fileobj=gz,mode='w|') as tf:
    for name,e in sorted(entries.items()):
        info=tarfile.TarInfo(name);info.size=e['identity']['bytes'];info.mode=e['mode']
        with open_entry(e) as f:tf.addfile(info,f)
seen=set()
with tarfile.open(archive,'r:gz') as tf:
    for m in tf:
        assert m.isfile() and m.name in entries and m.name not in seen
        with tf.extractfile(m) as f:assert digest(f)==entries[m.name]['identity']
        seen.add(m.name)
assert seen==set(entries)
assert all(pin(e['file'])==e['identity'] for e in entries.values() if 'file' in e)
prerequisites=[]
for phase in [157,158]:
    p=ROOT/f'implementation/phase{phase}/evidence/capsule.json'
    prerequisites.append(dict(receipt=str(p.relative_to(ROOT)),**pin(p)))
r=dict(kind='phase159-exact-evidence',complete=True,archive=dict(path=archive.name,**pin(archive)),
    members=len(entries),files={n:e['identity'] for n,e in sorted(entries.items())},
    reopenedVerified=True,inputsUnchanged=True,restoredArchivedRoots=restored,
    prerequisiteCapsules=prerequisites,
    scope='Exact new artifacts, methods, raw captures, outputs and closures, including rejected/pruned captures restored virtually. Original external sources/binaries/book/oracles are in pinned Phase157/158 capsules; toolchains remain pinned external prerequisites. No production promotion.')
(OUT/'capsule.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({k:v for k,v in r.items() if k!='files'}))
