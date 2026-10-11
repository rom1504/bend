"""Preserve this closed campaign and its saved runtime baselines; CPU0 data work.

Run only after every facts/native-facts/inspect-workers writer has stopped.
Large system toolchains and pinned upstream checkout remain external inputs.
"""
import argparse, hashlib, json, zipfile
from pathlib import Path
p = argparse.ArgumentParser();p.add_argument('--out', type=Path, required=True)
p.add_argument('--resume', action='store_true', help='Verify and split the preserved oversized first archive')
a = p.parse_args();a.out.mkdir(exist_ok=a.resume)
root = Path(__file__).resolve().parents[5]
raw = root/'selfhost/build/phase68'
paths = {p for pattern in ['facts-*','native-facts*','inspect-workers*'] for p in raw.glob(pattern)}
paths.update(raw/p for p in ['build-config01.json','scalar-export-admission20.json','native-scalar20','native-scalar20-rest'])
paths.update(raw/p for p in ['scalar-build20/attempt.json','scalar-build20/equality/api.mjs','scalar-build20-b2/image-pins.json','scalar-build20-b2/full/compiler.mjs'])
paths.update(root/'selfhost/build/phase67'/p for p in ['native-baseline02','native-heldout-baseline02'])
files = sorted({f for p in paths for f in (p.rglob('*') if p.is_dir() else [p]) if f.is_file() and '__pycache__' not in f.parts})
assert files and all(f.is_relative_to(root) for f in files)
archive = a.out/'facts-and-fallback23.zip'
rows = []
if not a.resume:
    with zipfile.ZipFile(archive, 'x', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for f in files:
            z.writestr(str(f.relative_to(root)), f.read_bytes())
for f in files:
    data=f.read_bytes()
    rows.append(dict(path=str(f.relative_to(root)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest()))
with zipfile.ZipFile(archive) as z:
    assert sorted(z.namelist()) == sorted(r['path'] for r in rows)
    for r in rows:
        data = z.read(r['path'])
        assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256']
        assert hashlib.sha256((root/r['path']).read_bytes()).hexdigest()==r['sha256']
parts=[];joined=hashlib.sha256()
with archive.open('rb') as source:
    while data:=source.read(40*1024*1024):
        part=archive.with_name(archive.name+'.part'+str(len(parts)+1).zfill(3))
        with part.open('xb') as target:target.write(data)
        retained=part.read_bytes();assert retained==data;joined.update(retained)
        parts.append(dict(file=part.name,bytes=len(retained),sha256=hashlib.sha256(retained).hexdigest()))
assert joined.hexdigest()==hashlib.sha256(archive.read_bytes()).hexdigest()
report = dict(complete=True, parts=parts, members=rows, memberCount=len(rows),
    uncompressedBytes=sum(r['bytes'] for r in rows), archiveBytes=archive.stat().st_size,
    archiveSha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
    scope='All closed campaign raw files except Python bytecode, plus six-family saved C runtime baselines. External toolchains/upstream and unrelated historical compiler receipts remain external; this is not a hermetic build environment.')
(a.out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
archive.unlink() # Redundant only: verified parts preserve its exact complete bytes.
print(json.dumps({k:v for k,v in report.items() if k not in ['members','scope']}))
