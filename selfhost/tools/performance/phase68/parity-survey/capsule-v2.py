#!/usr/bin/env python3
"""Archive a frozen parity survey; v2 fixes member ordering verification.

The first producer and failed evidence/ output are preserved unchanged.
This successor never writes or deletes input files.

Root owns the freeze handshake. Preparing this producer does not authorize its
execution while any campaign or documentation writer remains active.
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
RAW = ROOT / 'selfhost/build/phase68'
LIMIT = 50 * 1024 * 1024
CHUNK = 1024 * 1024


def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def save(path, value):
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(CHUNK):
            h.update(block)
    return h.hexdigest()


def inventory(output):
    paths = set()
    def walk(path):
        if '__pycache__' in path.parts or path.suffix in ('.pyc', '.pyo'):
            return
        if path == HERE / 'evidence' or path == output:
            return
        mode = path.lstat().st_mode
        if stat.S_ISREG(mode) or stat.S_ISLNK(mode):
            paths.add(path)
        elif stat.S_ISDIR(mode):
            for child in sorted(path.iterdir()):
                walk(child)
        else:
            raise RuntimeError(f'Unsupported input file type: {path}')
    roots = sorted(RAW.glob('parity-survey23*'))
    if not roots:
        raise RuntimeError('No parity-survey23 inputs found')
    for path in roots + [HERE]:
        walk(path)
    return sorted(paths)


def snapshot(path):
    before = path.lstat()
    link = stat.S_ISLNK(before.st_mode)
    content = os.fsencode(os.readlink(path)) if link else None
    sha = hashlib.sha256(content).hexdigest() if link else digest(path)
    after = path.lstat()
    observed = lambda st: (st.st_mode, st.st_size, st.st_mtime_ns, st.st_ino)
    if observed(before) != observed(after):
        raise RuntimeError(f'Input changed while hashing: {path}')
    return dict(path=path.relative_to(ROOT).as_posix(),
                kind='symlink' if link else 'file',
                bytes=len(content) if link else before.st_size,
                sha256=sha, mode=before.st_mode,
                executable=bool(before.st_mode & 0o111),
                mtimeNs=before.st_mtime_ns)


def assert_same(row):
    if snapshot(ROOT / row['path']) != row:
        raise RuntimeError(f'Input changed after freeze: {row["path"]}')


def write_member(archive, row):
    path = ROOT / row['path']
    assert_same(row)
    date = time.localtime(row['mtimeNs'] / 1_000_000_000)[:6]
    if not 1980 <= date[0] <= 2107:
        date = (1980, 1, 1, 0, 0, 0)
    info = zipfile.ZipInfo(row['path'], date_time=date)
    info.create_system = 3
    info.external_attr = (row['mode'] & 0xFFFF) << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    info.file_size = row['bytes']
    h = hashlib.sha256()
    count = 0
    with archive.open(info, 'w', force_zip64=True) as dest:
        if row['kind'] == 'symlink':
            data = os.fsencode(os.readlink(path))
            dest.write(data)
            h.update(data)
            count += len(data)
        else:
            with path.open('rb') as source:
                while block := source.read(CHUNK):
                    dest.write(block)
                    h.update(block)
                    count += len(block)
    if count != row['bytes'] or h.hexdigest() != row['sha256']:
        raise RuntimeError(f'Input changed during ZIP write: {path}')
    assert_same(row)


def readme(manifest, archive):
    return f'''# Compiler23 parity survey capsule

This verified archive preserves {manifest['memberCount']:,} files
({manifest['uncompressedBytes']:,} uncompressed bytes): every frozen
`selfhost/build/phase68/parity-survey23*` file and every parity-survey tool,
including failed attempts and preserved producer versions. Python bytecode
and the old/current generated evidence directories are excluded. Original raw files were
not edited, removed or deduplicated.

`manifest.json` records repository-relative member paths, SHA-256, byte count
and Unix modes. `verification.json` records the reopened archive check and a
second comparison against every unchanged original. `capsule.zip` is
{archive['bytes']:,} bytes, below the50MiB publication limit, SHA-256:

`{archive['sha256']}`

Inspect the manifest and extract into an empty scratch directory; never
overwrite an existing evidence tree:

```sh
sha256sum capsule.zip
unzip -l capsule.zip
mkdir /tmp/bend-c23-parity-survey
unzip capsule.zip -d /tmp/bend-c23-parity-survey
```

The ZIP stores Unix executable bits and symlink modes. Use an extractor that
preserves them; Python's basic `ZipFile.extractall` does not restore all Unix
attributes. Verify extracted bytes and modes against the manifest before
running saved binaries. Receipts retain their original absolute machine paths;
replay uses fresh output paths and may require a fresh plan.

The [first packaging attempt](../evidence/README.md) failed a name-order
comparison despite identical member sets. Its producer, manifest, failure
receipt and partial ZIP remain separately preserved; the successor manifest
binds their hashes as external dependencies. No earlier failure is relabeled
successful.

This is not a hermetic build environment. Earlier candidate/upstream C, native
binaries, compiler images and qualification receipts come from the
[facts-calls capsule](../../facts-calls/evidence/README.md), with its own stated
historical dependencies. System Clang/linker/binutils, pinned upstream checkout
and unrelated previous receipts remain external. Main reports and small
summaries are tracked repository files rather than duplicate ZIP members.

[Investigation methods](../README.md) ·
[Central report](../../../../../../implementation/phase68/c23-parity-survey.md).
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frozen', action='store_true',
                        help='Root confirms all raw/tool/report writers stopped')
    parser.add_argument('--out', type=Path, default=HERE / 'evidence02')
    args = parser.parse_args()
    if not args.frozen:
        parser.error('Run only after the root-owned freeze; pass --frozen then')
    output = args.out.resolve()
    if not output.is_relative_to(HERE) or output == HERE:
        parser.error('Output must be a fresh directory within parity-survey')
    if output.exists():
        parser.error('Output exists; preserve it and choose a fresh attempt path')
    inputs = inventory(output)
    rows = [snapshot(path) for path in inputs]
    if not rows or not any(row['path'].startswith('selfhost/build/') for row in rows):
        raise RuntimeError('Expected both raw evidence and tool inputs')
    dependency = ROOT / 'selfhost/tools/performance/phase68/facts-calls/evidence/manifest.json'
    dependency_rows = [snapshot(dependency)]
    # Failed archive bytes stay separate; their identities are bound without
    # needlessly duplicating a12MiB ZIP inside the successor ZIP.
    failure_files = [HERE / 'evidence' / name for name in
                     ('manifest.json', 'verification.json', 'capsule.partial.zip', 'README.md')]
    dependency_rows.extend(snapshot(path) for path in failure_files)
    manifest = dict(schema='phase68-c23-parity-capsule-v2', created=stamp(),
                    scope='Frozen parity-survey23 raw and parity-survey tools; failed attempts retained; no input mutation.',
                    exclusions=['Python bytecode', str(output.relative_to(ROOT)),
                                'selfhost/tools/performance/phase68/parity-survey/evidence'],
                    memberCount=len(rows), uncompressedBytes=sum(r['bytes'] for r in rows),
                    members=rows, externalDependencies=dependency_rows,
                    previousPackagingAttempt='evidence/verification.json',
                    memberComparison='Both member-name lists sorted as strings; duplicate names remain detectable.')
    output.mkdir(parents=False)
    save(output / 'manifest.json', manifest)
    pending = output / 'capsule.partial.zip'
    verification = dict(schema='phase68-c23-parity-capsule-verification-v2',
                        complete=False, started=stamp(),
                        manifestSha256=digest(output / 'manifest.json'))
    try:
        with zipfile.ZipFile(pending, 'x', compression=zipfile.ZIP_DEFLATED,
                             compresslevel=6, allowZip64=True) as archive:
            for row in rows:
                write_member(archive, row)
        if pending.stat().st_size > LIMIT:
            raise RuntimeError('Compressed archive exceeds50MiB; partial ZIP preserved, no publication archive created')
        checked = 0
        with zipfile.ZipFile(pending, 'r') as archive:
            if sorted(archive.namelist()) != sorted(r['path'] for r in rows):
                raise RuntimeError('ZIP members differ from manifest')
            for row in rows:
                info = archive.getinfo(row['path'])
                if info.file_size != row['bytes'] or info.external_attr >> 16 != row['mode'] & 0xFFFF:
                    raise RuntimeError(f'ZIP size/mode mismatch: {row["path"]}')
                h = hashlib.sha256()
                count = 0
                with archive.open(info) as source:
                    while block := source.read(CHUNK):
                        h.update(block)
                        count += len(block)
                if count != row['bytes'] or h.hexdigest() != row['sha256']:
                    raise RuntimeError(f'ZIP content mismatch: {row["path"]}')
                assert_same(row)
                checked += 1
        if inventory(output) != inputs:
            raise RuntimeError('Input file set changed after freeze')
        for row in rows:
            assert_same(row)
        for dependency_row in dependency_rows:
            assert_same(dependency_row)
        archive_row = dict(file='capsule.zip', bytes=pending.stat().st_size,
                           sha256=digest(pending), maximumBytes=LIMIT)
        final = output / 'capsule.zip'
        pending.rename(final)
        verification.update(complete=True, finished=stamp(), archive=archive_row,
                            checkedMembers=checked, originalInputsUnchanged=True,
                            inputFileSetUnchanged=True, unixModesVerified=True)
        with (output / 'README.md').open('x', encoding='utf-8') as stream:
            stream.write(readme(manifest, archive_row))
        save(output / 'verification.json', verification)
        print(json.dumps({k: v for k, v in verification.items() if k != 'schema'}))
    except BaseException as error:
        verification.update(complete=False, error=repr(error), finished=stamp())
        if not (output / 'verification.json').exists():
            save(output / 'verification.json', verification)
        raise


if __name__ == '__main__':
    main()
