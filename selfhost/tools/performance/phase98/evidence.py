#!/usr/bin/env python3
"""Seal/verify/restore frozen Phase98 evidence with deduplicated content blobs."""
import argparse
import bisect
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import tempfile
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PACKAGES = HERE / 'artifacts'
CHUNK = 1024 * 1024
PART_BYTES = 64 * CHUNK
RESERVE = 160 * CHUNK
DEFAULT_ROOTS = [
    'selfhost/build/phase98', 'selfhost/tools/performance/phase98',
    'selfhost/proofs/phase98', 'selfhost/tools/laws/phase98',
    'implementation/phase98', 'experiments/phase98',
    'selfhost/tools/native', 'selfhost/native.py', 'selfhost/build/native/requests',
    'design/phase98', 'research/phase98', 'experiments/STEERING.md', 'selfhost/README.md', 'README.md',
    'docs/self_hosted/NATIVE_HOST.md', 'docs/self_hosted/NATIVE_OBSERVERS.md',
    'docs/self_hosted/NATIVE_PHASE98.md', 'docs/self_hosted/COMPILER_LAWS.md',
]


def digest(stream):
    h = hashlib.sha256(); size = 0
    for data in iter(lambda: stream.read(CHUNK), b''): h.update(data); size += len(data)
    return h.hexdigest(), size


def safe(name):
    relative = PurePosixPath(name)
    assert not relative.is_absolute() and '..' not in relative.parts and str(relative) == name
    path = ROOT / name
    for parent in (path, *path.parents):
        assert not parent.is_symlink(), 'Symlink in evidence path: ' + str(parent)
        if parent == ROOT: break
    assert path.resolve().is_relative_to(ROOT)
    return path


def identity(path):
    path = Path(path).absolute(); name = str(path.relative_to(ROOT)); safe(name)
    assert path.is_file(), str(path)
    with path.open('rb') as stream: sha, size = digest(stream)
    return dict(file=name, sha256=sha, bytes=size)


def check(record):
    path = safe(record['file']); assert identity(path) == record, 'Changed evidence: ' + str(path)
    return path


def snapshot(path):
    name = str(path.relative_to(ROOT)); safe(name); before = path.stat()
    mode = stat.S_IMODE(before.st_mode); assert not mode & 0o7000
    if path.is_dir(): return dict(file=name, type='directory', mode=mode)
    assert stat.S_ISREG(before.st_mode), 'Unsupported evidence type: ' + name
    row = dict(**identity(path), type='file', mode=mode)
    after = path.stat()
    assert (before.st_ino, before.st_size, before.st_mtime_ns, before.st_mode) == (after.st_ino, after.st_size, after.st_mtime_ns, after.st_mode)
    return row


def inventory(roots):
    files = {}
    def visit(path):
        if path.is_relative_to(PACKAGES) or path.is_relative_to(ROOT/'selfhost/tools/native/releases'):
            return
        if '__pycache__' in path.parts or path.suffix in ('.pyc', '.pyo'): return
        row = snapshot(path); files[row['file']] = row
        if row['type'] == 'directory':
            for child in sorted(path.iterdir()): visit(child)
    for name in roots: visit(safe(name))
    return sorted(files.values(), key=lambda row: row['file'])


def exclusive_json(path, value):
    with path.open('x') as stream: json.dump(value, stream, indent=2); stream.write('\n')


class Parts(io.RawIOBase):
    """Seekable concatenation for ZIP verification without a joined archive."""
    def __init__(self, paths):
        super().__init__(); self.paths = paths; self.offsets = [0]; self.position = 0
        for path in paths: self.offsets.append(self.offsets[-1] + path.stat().st_size)
    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.position
    def seek(self, offset, whence=0):
        target = offset if whence == 0 else self.position + offset if whence == 1 else self.offsets[-1] + offset
        if target < 0: raise ValueError('Negative archive seek')
        self.position = target; return target
    def read(self, size=-1):
        remaining = max(0, self.offsets[-1] - self.position)
        if size >= 0: remaining = min(remaining, size)
        result = bytearray()
        while remaining:
            index = bisect.bisect_right(self.offsets, self.position) - 1
            count = min(remaining, self.offsets[index + 1] - self.position)
            with self.paths[index].open('rb') as stream:
                stream.seek(self.position - self.offsets[index]); data = stream.read(count)
            assert len(data) == count, 'Truncated archive part'
            result.extend(data); remaining -= count; self.position += count
        return bytes(result)


def archive_check(receipt, manifest):
    paths = [check(row) for row in receipt['parts']]
    assert paths and all(0 < row['bytes'] <= PART_BYTES for row in receipt['parts'])
    assert len({str(path) for path in paths}) == len(paths)
    with Parts(paths) as stream: sha, size = digest(stream)
    assert (sha, size) == (receipt['archiveSha256'], receipt['archiveBytes'])
    assert receipt['archiveBytes'] == sum(row['bytes'] for row in receipt['parts'])
    blobs = manifest['blobs']; assert len({row['sha256'] for row in blobs}) == len(blobs)
    with Parts(paths) as stream, zipfile.ZipFile(stream) as archive:
        assert archive.namelist() == ['blobs/' + row['sha256'] for row in blobs]
        for row in blobs:
            info = archive.getinfo('blobs/' + row['sha256'])
            assert info.file_size == row['bytes'] and stat.S_IMODE(info.external_attr >> 16) == 0o600
            with archive.open(info) as content: sha, size = digest(content)
            assert (sha, size) == (row['sha256'], row['bytes'])
    return paths


def seal(args):
    assert args.frozen, 'Root must confirm all evidence/method/document writers are closed'
    out = args.out.resolve(); assert out.is_relative_to(PACKAGES) and out != PACKAGES and not out.exists()
    roots = args.root or [name for name in DEFAULT_ROOTS if (ROOT/name).exists()]
    assert 'selfhost/build/phase98' in roots
    rows = inventory(roots); files = [row for row in rows if row['type'] == 'file']
    by_sha = {}
    for row in files:
        previous = by_sha.setdefault(row['sha256'], row)
        assert previous['bytes'] == row['bytes']
    blobs = [dict(sha256=sha, bytes=row['bytes']) for sha, row in sorted(by_sha.items())]
    external = []
    for path in args.public_assets:
        rp = identity(path.resolve()); r = json.loads(check(rp).read_text())
        assert r['complete']
        external.append(dict(receipt=rp, archive=identity(check(r['archive'])), manifest=identity(check(r['manifest']))))
    # The compressed spool coexists with all split parts until copying finishes.
    # Allow raw-deflate expansion and ZIP headers even for incompressible blobs.
    zip_bound = sum(row['bytes'] + ((row['bytes'] + 16382)//16383)*5 + 1024 for row in blobs) + 1024
    assert shutil.disk_usage(ROOT).free >= 2*zip_bound + RESERVE, 'Need spool and split archive space plus160MiB reserve'
    out.mkdir(parents=True)
    manifest = dict(kind='phase98-content-evidence-manifest', version=1, complete=True,
        canonicalRoot=str(ROOT), roots=roots, entries=rows, blobs=blobs,
        rawBytes=sum(row['bytes'] for row in files), uniqueBytes=sum(row['bytes'] for row in blobs),
        externalPublicCapsules=external,
        exclusions=['Python bytecode', 'Evidence package outputs under phase98/artifacts', 'Public request capsules under tools/native/releases'],
        scope='Exact frozen phase files, methods and failures plus native public request logs. Identical bytes share one blob; original paths and modes remain independent. Historical upstream/toolchain and other-phase inputs remain external. No target or qualification result inferred.')
    exclusive_json(out/'manifest.json', manifest)
    parts = []; combined = hashlib.sha256(); total = 0
    with tempfile.TemporaryFile(dir=out) as temporary:
        with zipfile.ZipFile(temporary, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
            for blob in blobs:
                row = by_sha[blob['sha256']]; path = safe(row['file']); assert snapshot(path) == row
                info = zipfile.ZipInfo('blobs/' + blob['sha256'], (2026, 10, 15, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED; info.external_attr = 0o100600 << 16
                with archive.open(info, 'w', force_zip64=True) as target, path.open('rb') as source:
                    shutil.copyfileobj(source, target, CHUNK)
                assert snapshot(path) == row
        temporary.seek(0)
        while True:
            data = temporary.read(PART_BYTES)
            if not data: break
            path = out/('evidence.zip.part%03d' % (len(parts)+1))
            with path.open('xb') as stream: stream.write(data)
            combined.update(data); total += len(data); parts.append(identity(path))
    receipt = dict(kind='phase98-content-evidence-capsule', version=1, complete=False, targetJobsRun=0,
        manifest=identity(out/'manifest.json'), method=identity(__file__), parts=parts,
        archiveSha256=combined.hexdigest(), archiveBytes=total, maxPartBytes=PART_BYTES)
    archive_check(receipt, manifest)
    assert inventory(roots) == rows, 'Evidence changed while sealing'
    for item in external:
        for row in item.values(): check(row)
    receipt.update(complete=True, allBlobsReopened=True, inputsUnchanged=True)
    exclusive_json(out/'receipt.json', receipt)
    print(json.dumps(dict(complete=True, targetJobsRun=0, files=len(files), blobs=len(blobs),
        rawBytes=manifest['rawBytes'], uniqueBytes=manifest['uniqueBytes'], archiveBytes=total, parts=len(parts), receipt=identity(out/'receipt.json'))))


def restore(args):
    receipt = json.loads(args.receipt.read_text())
    assert receipt['kind'] == 'phase98-content-evidence-capsule' and receipt['version'] == 1 and receipt['complete']
    assert receipt['method'] == identity(__file__), 'Evidence method differs from sealed method'
    manifest = json.loads(check(receipt['manifest']).read_text())
    assert manifest['kind'] == 'phase98-content-evidence-manifest' and manifest['version'] == 1 and manifest['complete']
    assert manifest['canonicalRoot'] == str(ROOT), 'Absolute receipt paths require the original checkout root'
    rows = manifest['entries']; assert len({row['file'] for row in rows}) == len(rows)
    blobs = {row['sha256']: row['bytes'] for row in manifest['blobs']}
    assert all(row['type'] in ('file', 'directory') and 0 <= row['mode'] <= 0o777 for row in rows)
    assert all(blobs.get(row['sha256']) == row['bytes'] for row in rows if row['type'] == 'file')
    assert manifest['rawBytes'] == sum(row['bytes'] for row in rows if row['type'] == 'file')
    assert manifest['uniqueBytes'] == sum(blobs.values())
    paths = archive_check(receipt, manifest); missing = []
    for row in rows:
        path = safe(row['file'])
        if path.exists(): assert snapshot(path) == row, 'Refusing changed existing evidence: ' + row['file']
        else: missing.append(row)
    missing_bytes = sum(row['bytes'] for row in missing if row['type'] == 'file')
    if not args.verify_only:
        assert shutil.disk_usage(ROOT).free >= missing_bytes + RESERVE, 'Need restoration space plus160MiB reserve'
        for row in sorted((row for row in missing if row['type'] == 'directory'), key=lambda row: len(PurePosixPath(row['file']).parts)):
            path = safe(row['file']); path.mkdir(parents=True, exist_ok=True)
            os.chmod(path, row['mode'])
        with Parts(paths) as stream, zipfile.ZipFile(stream) as archive:
            for row in missing:
                if row['type'] != 'file': continue
                path = safe(row['file']); path.parent.mkdir(parents=True, exist_ok=True)
                with tempfile.NamedTemporaryFile(dir=path.parent) as temporary:
                    with archive.open('blobs/' + row['sha256']) as source: shutil.copyfileobj(source, temporary, CHUNK)
                    temporary.flush(); os.fchmod(temporary.fileno(), row['mode'])
                    assert identity(temporary.name)['sha256'] == row['sha256']
                    os.link(temporary.name, path)
        assert all(snapshot(safe(row['file'])) == row for row in rows)
    print(json.dumps(dict(complete=True, targetJobsRun=0, mode='verify' if args.verify_only else 'restore-missing',
        files=sum(row['type'] == 'file' for row in rows), blobs=len(blobs), missingEntries=len(missing), missingBytes=missing_bytes)))


def main():
    assert __debug__, 'Run without Python -O: validation uses assertions'
    parser = argparse.ArgumentParser(description=__doc__); sub = parser.add_subparsers(dest='mode', required=True)
    make = sub.add_parser('seal'); make.add_argument('--frozen', action='store_true')
    make.add_argument('--out', type=Path, required=True); make.add_argument('--root', action='append')
    make.add_argument('--public-assets', type=Path, action='append', default=[])
    recover = sub.add_parser('restore'); recover.add_argument('receipt', type=Path); recover.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    if args.mode == 'seal': seal(args)
    else: restore(args)


if __name__ == '__main__': main()
