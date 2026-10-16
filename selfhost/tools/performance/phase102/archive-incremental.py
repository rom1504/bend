#!/usr/bin/env python3
"""Archive only additions/changes after the immutable Phase102 evidence capsule."""
import argparse
import hashlib
import importlib.util
import io
import json
import lzma
from pathlib import Path, PurePosixPath
import shutil
import stat
import sys
import tarfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'implementation/phase102/evidence'
RECEIPT_SHA = '9fc6691c321e296d0f2631d6e78e3dbda2361c9bdc3b2e71695accededb54631'
MANIFEST_SHA = 'aae3688afec896ed9c2284f505a235d6069bafc0d4fb689d5723c62d42326b4b'
PARENT = Path(__file__).with_name('archive-v2.py')
PARENT_SHA = '4950a05a3c29265134ad25d7b3b624aaaa9404599aa6756f3d4d2a684d45f5a2'
CHUNK = 80 * 1024**2
RESERVE = 160 * 1024**2
assert hashlib.sha256(PARENT.read_bytes()).hexdigest() == PARENT_SHA
spec = importlib.util.spec_from_file_location('phase102_incremental_archive_parent', PARENT)
A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)


def pin(path): return A.pin(path)


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2); stream.write('\n')


def baseline():
    receipt_pin = pin(BASE / 'receipt.json'); manifest_pin = pin(BASE / 'manifest.json')
    assert receipt_pin['sha256'] == RECEIPT_SHA and manifest_pin['sha256'] == MANIFEST_SHA
    receipt = json.loads((BASE / 'receipt.json').read_text())
    assert receipt['complete'] and receipt['everyMemberVerified'] and not receipt['targetsRun']
    archive = receipt['archive']; archive_pin = pin(ROOT / archive['path'])
    assert all(archive_pin[key] == archive[key] for key in ('sha256', 'bytes'))
    manifest = json.loads((BASE / 'manifest.json').read_text())
    assert len(manifest) == receipt['files']
    assert sum(row['bytes'] for row in manifest) == receipt['uncompressedBytes']
    rows = {}
    for row in manifest:
        name = PurePosixPath(row['path'])
        assert not name.is_absolute() and '..' not in name.parts and str(name) == row['path']
        assert row['path'] not in rows
        rows[row['path']] = row
    return receipt, rows, [receipt_pin, manifest_pin, archive_pin]


class SplitWriter:
    """One compressed stream, bounded files, no second/spool archive copy."""
    def __init__(self, out):
        self.out, self.stream, self.rows = out, None, []
        self.size, self.hash = 0, None

    def finish_part(self):
        if self.stream is not None:
            self.stream.flush(); self.stream.close()
            self.rows.append(dict(file=str(self.path), bytes=self.size, sha256=self.hash.hexdigest()))
            self.stream = None

    def write(self, data):
        total = len(data); view = memoryview(data)
        while view:
            assert shutil.disk_usage(ROOT).free >= RESERVE + len(view), 'Archive reserve exhausted; retain partial parts, do not claim completion'
            if self.stream is None:
                self.path = self.out / ('phase102-incremental.tar.xz.part%03d' % len(self.rows))
                self.stream = self.path.open('xb'); self.size = 0; self.hash = hashlib.sha256()
            take = min(len(view), CHUNK - self.size)
            self.stream.write(view[:take]); self.hash.update(view[:take]); self.size += take
            view = view[take:]
            if self.size == CHUNK: self.finish_part()
        return total

    def flush(self):
        if self.stream is not None: self.stream.flush()

    def finish(self):
        self.finish_part(); return self.rows


class ConcatReader(io.RawIOBase):
    def __init__(self, parts):
        self.paths = iter(Path(row['file']) for row in parts)
        self.stream = None

    def readable(self): return True

    def readinto(self, buffer):
        while True:
            if self.stream is None:
                try: self.stream = next(self.paths).open('rb')
                except StopIteration: return 0
            count = self.stream.readinto(buffer)
            if count: return count
            self.stream.close(); self.stream = None

    def close(self):
        if self.stream is not None: self.stream.close()
        super().close()


def verify_archive(parts, manifest):
    assert parts and all(0 < row['bytes'] <= CHUNK for row in parts)
    assert len({row['file'] for row in parts}) == len(parts)
    for row in parts: assert pin(row['file']) == row
    count = 0
    with ConcatReader(parts) as raw, lzma.LZMAFile(raw, 'rb') as unpacked:
        with tarfile.open(fileobj=unpacked, mode='r|') as saved:
            for member in saved:
                assert count < len(manifest), 'Extra tar member'
                expected = manifest[count]; count += 1
                assert member.isfile() and member.name == expected['path']
                assert member.size == expected['bytes'] and member.mode == expected['mode']
                with saved.extractfile(member) as stream:
                    assert A.digest(stream) == expected['sha256']
        assert unpacked.read().strip(b'\0') == b'', 'Unexpected trailing tar data'
    assert count == len(manifest), 'Missing tar member'


def inventory(roots, out):
    files = set()
    for root in roots:
        assert root.exists() and not root.is_symlink()
        values = [root] if root.is_file() else root.rglob('*')
        for path in values:
            if path.is_relative_to(BASE) or path.is_relative_to(out): continue
            assert not path.is_symlink()
            if path.is_file():
                assert path.resolve(strict=True) == path and path.is_relative_to(ROOT)
                files.add(path)
    return sorted(files)


def stamp(path):
    value = path.stat()
    return (value.st_size, value.st_mtime_ns, value.st_ino, stat.S_IMODE(value.st_mode))


def seal(args):
    prior, old, base_pins = baseline()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase102') and not out.exists()
    assert not out.is_relative_to(BASE) and not BASE.is_relative_to(out)
    roots = [ROOT / name for name in prior['roots'] if (ROOT / name).exists()]
    roots += sorted((ROOT / 'selfhost/build/phase99').glob('phase102-*'))
    roots += [ROOT / 'selfhost/tools/performance/phase102', *[path.resolve(strict=True) for path in args.include]]
    cli_pins, request_pins, request_dirs = [], [], []
    for path in args.cli_report:
        report, requests, directories = A.cli_requests(path.resolve(strict=True))
        cli_pins.append(report); request_pins.extend(requests); request_dirs.extend(directories)
    for path in args.request_report:
        record = pin(path.resolve(strict=True)); request_pins.append(record)
        request_dirs.append(A.request_directory(record))
    roots += sorted(set(request_dirs)); roots = sorted(set(roots))
    assert all(path.is_relative_to(ROOT) for path in roots)
    files = inventory(roots, out); manifest = []; unchanged = 0; changed = []; added = []
    snapshots = {}
    for path in files:
        before = stamp(path); record = pin(path); assert stamp(path) == before
        snapshots[path] = before
        row = dict(path=str(path.relative_to(ROOT)), bytes=record['bytes'], sha256=record['sha256'], mode=before[3])
        if old.get(row['path']) == row:
            unchanged += 1
        else:
            manifest.append(row)
            (changed if row['path'] in old else added).append(row['path'])
    assert manifest, 'No new or changed evidence'
    missing = sorted(name for name in old if not (ROOT / name).exists())
    assert shutil.disk_usage(ROOT).free >= RESERVE + 1024**2, 'Need incremental archive space plus reserve'
    out.mkdir(parents=True)
    sink = SplitWriter(out)
    try:
        with lzma.LZMAFile(sink, 'wb', preset=3) as compressed:
            with tarfile.open(fileobj=compressed, mode='w|', dereference=True) as saved:
                for row in manifest:
                    saved.add(ROOT / row['path'], arcname=row['path'], recursive=False)
    finally:
        parts = sink.finish()
    verify_archive(parts, manifest)
    assert inventory(roots, out) == files, 'Evidence paths changed during archive'
    assert all(stamp(path) == snapshots[path] for path in files), 'Evidence metadata changed during archive'
    for record in [*base_pins, *cli_pins, *request_pins]: assert pin(record['file']) == record
    save(out / 'manifest.json', manifest)
    receipt = dict(kind='phase102-incremental-evidence-archive', version=1, complete=True,
        targetsRun=False, method=pin(__file__), parentMethod=pin(PARENT), baseline=base_pins,
        baselineArchiveUnchanged=True, baselineManifestUnchanged=True, baselineLiveFilesHashed=True,
        roots=[str(path.relative_to(ROOT)) for path in roots], cliReports=cli_pins, requestReports=request_pins,
        explicitRequestDirectories=[str(path.relative_to(ROOT)) for path in sorted(set(request_dirs))],
        baselinePathsUnchanged=unchanged, changedPaths=changed, addedPaths=added,
        missingLiveBaselinePaths=missing, files=len(manifest), uncompressedBytes=sum(row['bytes'] for row in manifest),
        manifest=pin(out / 'manifest.json'), parts=parts, compressedBytes=sum(row['bytes'] for row in parts),
        everyMemberVerified=True, noBaselineArchiveCopy=True,
        scope='The pinned original archive retains all old versions. This stream contains only added/changed live paths, never deletes baseline history, and includes only explicitly referenced new native request directories. Missing live baseline files remain preserved by the original archive; no restore claim.')
    save(out / 'receipt.json', receipt)
    print(json.dumps(dict(complete=True, receipt=pin(out / 'receipt.json'), files=len(manifest),
                         parts=len(parts), compressedBytes=receipt['compressedBytes'], baselinePathsUnchanged=unchanged)))


def verify(args):
    receipt_pin = pin(args.receipt.resolve(strict=True)); receipt = json.loads(Path(receipt_pin['file']).read_text())
    assert receipt['kind'] == 'phase102-incremental-evidence-archive' and receipt['complete']
    _, _, base_pins = baseline(); assert base_pins == receipt['baseline']
    assert pin(__file__) == receipt['method'] and pin(PARENT) == receipt['parentMethod']
    assert pin(receipt['manifest']['file']) == receipt['manifest']
    manifest = json.loads(Path(receipt['manifest']['file']).read_text())
    assert len(manifest) == receipt['files'] and sum(row['bytes'] for row in manifest) == receipt['uncompressedBytes']
    verify_archive(receipt['parts'], manifest)
    print(json.dumps(dict(complete=True, targetsRun=False, receipt=receipt_pin, files=len(manifest), everyMemberVerified=True)))


def main():
    parser = argparse.ArgumentParser(description=__doc__); sub = parser.add_subparsers(dest='mode', required=True)
    create = sub.add_parser('seal'); create.add_argument('--frozen', action='store_true', required=True)
    for key in ('cli-report', 'request-report', 'include'):
        create.add_argument('--' + key, type=Path, action='append', default=[])
    create.add_argument('--out', type=Path, required=True)
    check = sub.add_parser('verify'); check.add_argument('receipt', type=Path)
    args = parser.parse_args()
    if args.mode == 'seal': seal(args)
    else: verify(args)


if __name__ == '__main__': main()
