#!/usr/bin/env python3
"""Seal root-frozen Phase70 evidence; never run while campaign writers are active.

Python 3.9; derives hashing/mode checks from Phase68 parity-survey/capsule-v2.py.
No compiler or benchmark target is invoked. Original inputs are never modified.
"""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import stat
import time
import zipfile

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
TOOLS = HERE.parent
RAW = ROOT / 'selfhost/build/phase70'
CHUNK = 1024 * 1024
PUBLICATION_LIMIT = 50 * CHUNK
PART_LIMIT = 40 * CHUNK
EXTERNAL = [
    ROOT / 'selfhost/tools/performance/phase69/artifacts/evidence01',
    ROOT / 'selfhost/tools/performance/phase68/facts-calls/evidence',
    ROOT / 'selfhost/tools/performance/phase68/parity-survey/evidence02',
]


def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def save(path, value):
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        while True:
            block = stream.read(CHUNK)
            if not block:
                break
            h.update(block)
    return h.hexdigest()


def inventory():
    paths = []

    def walk(path):
        if '__pycache__' in path.parts or path.suffix in ('.pyc', '.pyo'):
            return
        mode = path.lstat().st_mode
        # This folder contains producer/docs; all its subdirectories are outputs.
        if path.parent == HERE and stat.S_ISDIR(mode):
            return
        if not (stat.S_ISREG(mode) or stat.S_ISLNK(mode) or stat.S_ISDIR(mode)):
            raise RuntimeError('Unsupported input type: ' + str(path))
        paths.append(path)
        if stat.S_ISDIR(mode):
            for child in sorted(path.iterdir()):
                walk(child)

    for path in (RAW, TOOLS):
        if not path.is_dir():
            raise RuntimeError('Missing campaign input root: ' + str(path))
        walk(path)
    return sorted(paths, key=lambda p: p.relative_to(ROOT).as_posix())


def snapshot(path):
    before = path.lstat()
    if stat.S_ISLNK(before.st_mode):
        kind = 'symlink'
        data = os.fsencode(os.readlink(path))
        size, sha = len(data), hashlib.sha256(data).hexdigest()
    elif stat.S_ISDIR(before.st_mode):
        kind, size, sha = 'directory', 0, hashlib.sha256(b'').hexdigest()
    elif stat.S_ISREG(before.st_mode):
        kind, size, sha = 'file', before.st_size, digest(path)
    else:
        raise RuntimeError('Unsupported dependency/input: ' + str(path))
    after = path.lstat()
    identity = lambda s: (s.st_mode, s.st_size, s.st_mtime_ns, s.st_ino)
    if identity(before) != identity(after):
        raise RuntimeError('Input changed during hash: ' + str(path))
    return dict(path=path.relative_to(ROOT).as_posix(), kind=kind,
                bytes=size, sha256=sha, mode=before.st_mode,
                mtimeNs=before.st_mtime_ns)


def assert_same(row):
    if snapshot(ROOT / row['path']) != row:
        raise RuntimeError('Input changed after freeze: ' + row['path'])


def member_name(row):
    return row['path'] + ('/' if row['kind'] == 'directory' else '')


def write_member(archive, row):
    path = ROOT / row['path']
    assert_same(row)
    date = time.gmtime(row['mtimeNs'] / 1_000_000_000)[:6]
    if not 1980 <= date[0] <= 2107:
        date = (1980, 1, 1, 0, 0, 0)
    info = zipfile.ZipInfo(member_name(row), date_time=date)
    info.create_system = 3
    info.external_attr = (row['mode'] & 0xFFFF) << 16
    if row['kind'] == 'directory':
        info.external_attr |= 0x10
    info.compress_type = zipfile.ZIP_DEFLATED
    info.file_size = row['bytes']
    h, count = hashlib.sha256(), 0
    with archive.open(info, 'w', force_zip64=True) as dest:
        if row['kind'] == 'file':
            with path.open('rb') as source:
                while True:
                    block = source.read(CHUNK)
                    if not block:
                        break
                    dest.write(block)
                    h.update(block)
                    count += len(block)
        elif row['kind'] == 'symlink':
            block = os.fsencode(os.readlink(path))
            dest.write(block)
            h.update(block)
            count += len(block)
    if count != row['bytes'] or h.hexdigest() != row['sha256']:
        raise RuntimeError('Input changed during archive write: ' + str(path))
    assert_same(row)


def verify_zip(path, rows):
    with zipfile.ZipFile(path, 'r') as archive:
        if sorted(archive.namelist()) != sorted(member_name(r) for r in rows):
            raise RuntimeError('Archive member inventory mismatch')
        for row in rows:
            info = archive.getinfo(member_name(row))
            if (info.file_size != row['bytes'] or
                    info.external_attr >> 16 != row['mode'] & 0xFFFF):
                raise RuntimeError('Archive size/mode mismatch: ' + row['path'])
            h, count = hashlib.sha256(), 0
            with archive.open(info) as source:
                while True:
                    block = source.read(CHUNK)
                    if not block:
                        break
                    h.update(block)
                    count += len(block)
            if count != row['bytes'] or h.hexdigest() != row['sha256']:
                raise RuntimeError('Archive content mismatch: ' + row['path'])
            assert_same(row)


def publish(pending):
    original_size, original_sha = pending.stat().st_size, digest(pending)
    parts = []
    if original_size <= PUBLICATION_LIMIT:
        final = pending.with_name('phase70.zip')
        pending.rename(final)
        parts.append(dict(file=final.name, bytes=original_size, sha256=original_sha))
    else:
        # These are byte partitions of one ZIP, as in the Phase68 facts capsule.
        with pending.open('rb') as source:
            while True:
                block = source.read(CHUNK)
                if not block:
                    break
                part = pending.with_name('phase70.zip.part%03d' % (len(parts) + 1))
                h, size = hashlib.sha256(), 0
                with part.open('xb') as dest:
                    while block:
                        dest.write(block)
                        h.update(block)
                        size += len(block)
                        if size == PART_LIMIT:
                            break
                        block = source.read(min(CHUNK, PART_LIMIT - size))
                parts.append(dict(file=part.name, bytes=size, sha256=h.hexdigest()))
        # Re-read every partition and verify its concatenation against the exact
        # reopened-verified ZIP before removing only the redundant generated copy.
        h, size = hashlib.sha256(), 0
        for part in parts:
            path = pending.parent / part['file']
            if path.stat().st_size != part['bytes'] or digest(path) != part['sha256']:
                raise RuntimeError('Partition hash/size mismatch: ' + str(path))
            with path.open('rb') as source:
                while True:
                    block = source.read(CHUNK)
                    if not block:
                        break
                    h.update(block)
                    size += len(block)
        if size != original_size or h.hexdigest() != original_sha:
            raise RuntimeError('Partition concatenation differs from verified ZIP')
        pending.unlink()
    if any(p['bytes'] > PUBLICATION_LIMIT for p in parts):
        raise RuntimeError('Publication part exceeds 50 MiB')
    return dict(bytes=original_size, sha256=original_sha, parts=parts,
                maximumPartBytes=PUBLICATION_LIMIT,
                concatenation='Concatenate parts in manifest order to recreate one ZIP.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frozen', action='store_true',
                        help='Root confirms all raw and method writers have stopped')
    parser.add_argument('--out', type=Path, default=HERE / 'evidence01')
    args = parser.parse_args()
    if not args.frozen:
        parser.error('Root-owned freeze required; pass --frozen only after confirmation')
    output = args.out.resolve()
    if output.parent != HERE or output.exists():
        parser.error('Output must be a fresh direct child directory of artifacts/')
    prior_outputs = sorted(p for p in HERE.iterdir()
                           if p.is_dir() and not p.is_symlink() and p.name != '__pycache__')
    output.mkdir()
    receipt = dict(schema='phase70-seal-verification-v1', complete=False, started=stamp())
    try:
        inputs = inventory()
        rows = [snapshot(p) for p in inputs]
        dependencies = []
        for directory in EXTERNAL + prior_outputs:
            if not directory.is_dir():
                raise RuntimeError('Missing external capsule: ' + str(directory))
            dependencies.extend(snapshot(p) for p in sorted(directory.rglob('*'))
                                if p.is_file() or p.is_symlink())
        manifest = dict(schema='phase70-capsule-v1', created=stamp(),
                        scope='All root-frozen Phase70 raw evidence and tools, including failures.',
                        exclusions=['Python bytecode/cache directories',
                                    'Generated subdirectories of phase70/artifacts/'],
                        memberCount=len(rows), fileCount=sum(r['kind'] != 'directory' for r in rows),
                        uncompressedBytes=sum(r['bytes'] for r in rows), members=rows,
                        externalDependencies=dependencies,
                        dependencyScope='Prior Phase69 sealed campaign plus Phase68 facts-calls and parity-survey capsules; previous packaging attempts remain external. Upstream/system toolchains and further historical dependencies named in receipts remain external.')
        save(output / 'manifest.json', manifest)
        receipt['manifestSha256'] = digest(output / 'manifest.json')
        pending = output / 'phase70.partial.zip'
        with zipfile.ZipFile(pending, 'x', compression=zipfile.ZIP_DEFLATED,
                             compresslevel=6, allowZip64=True) as archive:
            for row in rows:
                write_member(archive, row)
        verify_zip(pending, rows)
        archive_row = publish(pending)
        if inventory() != inputs:
            raise RuntimeError('Input path set changed after freeze')
        for row in rows + dependencies:
            assert_same(row)
        receipt.update(complete=True, finished=stamp(), archive=archive_row,
                       checkedMembers=len(rows), originalInputsUnchanged=True,
                       inputPathSetUnchanged=True, unixModesVerified=True,
                       pinnedExternalDependencyFilesUnchanged=True)
        with (output / 'README.md').open('x', encoding='utf-8') as stream:
            stream.write('# Phase70 sealed evidence\n\n'
                         + str(manifest['fileCount']) + ' files/symlinks and their directories are preserved. '
                         + 'Every member was reopened and verified against its manifest and unchanged original.\n\n'
                         + 'Archive SHA-256: `' + archive_row['sha256'] + '`. '
                         + 'Part sizes and hashes are in `verification.json`; each is at most 50 MiB. '
                         + 'For split output, concatenate parts in recorded order before opening the ZIP.\n\n'
                         + 'Extract only into an empty scratch directory with an extractor preserving Unix '
                         + 'modes and symbolic links (Python extractall does not preserve these reliably). '
                         + 'Verify extracted paths, bytes and modes against manifest.json before replay. '
                         + 'Absolute paths in receipts need fresh replay plans.\n\n'
                         + 'External dependencies: Phase69 artifacts/evidence01, Phase68 facts-calls/evidence and '
                         + 'parity-survey/evidence02; their exact files are pinned in manifest.json. '
                         + 'System tools, upstream checkout and dependencies of those capsules remain external. '
                         + 'Repository design/reports remain tracked separately. No hermetic-build claim.\n')
        save(output / 'verification.json', receipt)
        print(json.dumps(dict(complete=True, output=str(output), members=len(rows),
                              bytes=archive_row['bytes'], parts=len(archive_row['parts']))))
    except BaseException as error:
        receipt.update(complete=False, finished=stamp(), error=repr(error))
        if not (output / 'verification.json').exists():
            save(output / 'verification.json', receipt)
        raise


if __name__ == '__main__':
    main()
