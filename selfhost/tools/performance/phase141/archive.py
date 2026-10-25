"""Archive bounded Phase141 evidence, excluding large rebuildable native products."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT/'implementation/phase141') and not out.exists()
roots = [ROOT/'selfhost/build/phase141']
for phase in ['phase111', 'phase130', 'phase140']:
    roots.extend(sorted((ROOT/'selfhost/build'/phase).glob('p141-*')))
files = {ROOT/'selfhost/build/phase140/native-source18/compiler.bend'}
files.update((ROOT/'selfhost/tools/performance/phase141').rglob('*'))
for root in roots:
    files.update(root.rglob('*') if root.is_dir() else [root])
selected = []
for f in sorted(files):
    if not f.is_file() or f.is_symlink():
        continue
    if any(x in f.parts for x in ['census01', 'census02', 'census03']) and f.name != 'report.json':
        continue
    small = f.suffix in ['.json', '.py', '.bend', '.md', '.txt', '.log', '.stdout', '.stderr']
    method = f.name in ['method.mjs', 'method.py']
    code = '/tools/performance/phase141/' in str(f) and f.suffix == '.mjs'
    machine = 'static-inspect01' in f.parts and f.suffix in ['.ssa', '.asm']
    if not (small or method or code or machine):
        continue
    assert f.stat().st_size < 16*1024*1024, 'Unexpected large evidence member: '+str(f)
    b = f.read_bytes()
    selected.append((f, b, dict(file=str(f.relative_to(ROOT)), bytes=len(b),
        sha256=hashlib.sha256(b).hexdigest())))
assert sum(len(b) for _, b, _ in selected) < 160*1024*1024
out.mkdir(parents=True)
archive = out/'evidence.tar.gz'
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0, filename='') as gz:
    with tarfile.open(fileobj=gz, mode='w|') as tar:
        for f, b, row in selected:
            info = tarfile.TarInfo(row['file'])
            info.size, info.mode, info.mtime = len(b), 0o644, 0
            tar.addfile(info, io.BytesIO(b))
# Read the archive back and independently check every member; no extraction.
with tarfile.open(archive, 'r:gz') as tar:
    members = tar.getmembers()
    assert len(members) == len(selected)
    for member, (_, _, row) in zip(members, selected):
        b = tar.extractfile(member).read()
        assert member.name == row['file'] and len(b) == row['bytes']
        assert hashlib.sha256(b).hexdigest() == row['sha256']
data = archive.read_bytes()
report = dict(kind='phase141-evidence-capsule', complete=True, roundTripVerified=True,
    members=[row for _, _, row in selected], rawBytes=sum(len(b) for _, b, _ in selected),
    archive=dict(file=str(archive.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest()),
    scope='Reports, source snapshots, methods, logs, canonical census and scoped machine excerpts. '
          'Large QBE/assembly/object/executable/API products remain hash-pinned in receipts and rebuildable; '
          'this is not a self-contained toolchain distribution. Superseded census inventories omitted; reports retained.')
(out/'inventory.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['complete', 'rawBytes', 'archive']}))
