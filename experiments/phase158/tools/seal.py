#!/usr/bin/env python3
"""Package this completed experiment; verify every archived file against disk."""
import gzip, hashlib, json, shutil, tarfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'implementation/phase158/evidence'
OUT.mkdir(exist_ok=True)
archive = OUT / 'phase158.tar.gz'
assert not archive.exists()
assert shutil.disk_usage(ROOT).free > 5 * 1024**3 + 16 * 1024**2
roots = [ROOT/'selfhost/build/phase158', ROOT/'experiments/phase158/tools']
files = {p for root in roots for p in root.rglob('*') if p.is_file()}
files.update((ROOT/'selfhost/build-retention/phase158').rglob('*.json'))
files.update(ROOT/p for p in ['selfhost/tools/build/common.py',
    'selfhost/tools/execution.py', 'selfhost/tools/build-retention/guard.py',
    'selfhost/tools/build-retention/close.py', 'selfhost/tools/build-retention/archive-v02.py'])
def sha(stream):
    h = hashlib.sha256()
    for chunk in iter(lambda:stream.read(1024*1024), b''): h.update(chunk)
    return h.hexdigest()
def digest(path):
    with path.open('rb') as f:
        return {'bytes':path.stat().st_size, 'sha256':sha(f)}
expected = {}
for p in sorted(files):
    assert p.resolve() == p and p.is_file(), p
    expected[str(p.relative_to(ROOT))] = digest(p)
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, filename='', mode='wb',mtime=0) as encoded, tarfile.open(fileobj=encoded,mode='w|') as tar:
    for name in expected:
        p = ROOT/name
        info = tar.gettarinfo(str(p),arcname=name)
        assert info.isfile()
        with p.open('rb') as f: tar.addfile(info,f)
seen = set()
with tarfile.open(archive,'r:gz') as tar:
    for member in tar:
        assert member.isfile() and member.name in expected and member.name not in seen
        with tar.extractfile(member) as f:
            actual = {'bytes':member.size, 'sha256':sha(f)}
        assert actual == expected[member.name]
        seen.add(member.name)
assert seen == set(expected)
assert all(digest(ROOT/name) == identity for name,identity in expected.items())
receipt = {'kind':'phase158-exact-evidence','complete':True,'archive':{'path':archive.name,**digest(archive)},
    'members':len(expected),'files':expected,'reopenedVerified':True,'inputsUnchanged':True,
    'scope':'Exact Phase158 raw source, seed, methods, outputs and receipts. External toolchain binaries are pinned prerequisites. No production compiler promotion.'}
(OUT/'capsule.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:v for k,v in receipt.items() if k!='files'}))
