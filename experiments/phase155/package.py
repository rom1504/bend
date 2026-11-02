#!/usr/bin/env python3
"""Seal exact Phase155 evidence after retention closes; never execute targets.

Usage: python3 -B experiments/phase155/package.py
The gzip archive stores one payload for each distinct (SHA256, size, mode).
capsule.json records every original path; restore aliases by copying their
payload and applying their mode. Keep that sidecar beside the archive.
External compiler/toolchain pins are evidence, not bundled dependencies.
"""
import argparse
import gzip
import hashlib
import io
import json
import os
import stat
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TREES = (
    'selfhost/build/phase155', 'experiments/phase155', 'selfhost/tests/phase155',
    'design/phase155', 'research/phase155', 'implementation/phase155',
    'selfhost/build-retention/phase155', 'selfhost/tools/build',
    'selfhost/tools/build-retention', 'selfhost/src',
)
FILES = (
    'selfhost/tests/phase154/model.bend', 'selfhost/tests/phase154/scalar.bend',
    'experiments/phase147/tools/prepare.py', 'selfhost/tools/stage0-library.mjs',
    'selfhost/manifests/assets-native.json', 'implementation/phase152/qualification.json',
    'implementation/phase153/README.md', 'implementation/phase154/README.md',
    'implementation/phase155/README.md', 'implementation/phase155/metrics.json',
    'implementation/phase155/cost.json', 'implementation/phase155/retention.json',
    'research/phase155/independent-screen-audit.md',
)


def require(ok, message):
    if not ok:
        raise SystemExit(message)


def label(path):
    return str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)


def fingerprint(path):
    info = path.lstat()
    require(stat.S_ISREG(info.st_mode), 'regular file required: ' + str(path))
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    after = path.lstat()
    require((info.st_size, info.st_mtime_ns, info.st_mode, info.st_ino) ==
            (after.st_size, after.st_mtime_ns, after.st_mode, after.st_ino),
            'input changed while hashing: ' + str(path))
    return dict(file=label(path), bytes=info.st_size, sha256=digest.hexdigest(),
                mode=stat.S_IMODE(info.st_mode))


def collect(out, qualification):
    files = set()
    for name in TREES:
        directory = ROOT / name
        require(directory.is_dir() and not directory.is_symlink(), 'missing input tree: ' + name)
        for path in directory.rglob('*'):
            # Never recursively package this or an earlier capsule.
            if path.is_relative_to(out) or path.is_relative_to(ROOT / 'implementation/phase155/evidence'):
                continue
            require(not path.is_symlink(), 'symlink refused: ' + str(path))
            if not path.is_dir():
                require(path.is_file(), 'special input refused: ' + str(path))
                files.add(path)
    names = list(FILES) + [qualification['source']['file'],
                          qualification['selectedNative']['receipt']['file']]
    names.extend(row['file'] for row in qualification['receipts'])
    for name in names:
        path = ROOT / name
        require(path.is_relative_to(ROOT) and path.is_file() and not path.is_symlink(),
                'missing regular input: ' + name)
        files.add(path)
    return sorted(files)


def pins(value):
    """Recorded identities only; do not rewrite historical pins from live files."""
    if isinstance(value, dict):
        if (isinstance(value.get('file'), str) and isinstance(value.get('bytes'), int)
                and isinstance(value.get('sha256'), str) and len(value['sha256']) == 64):
            yield {key: value[key] for key in ('file', 'bytes', 'sha256')}
        for child in value.values():
            yield from pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from pins(child)


def external_pins(files, members):
    included = {(r['file'], r['bytes'], r['sha256']) for r in members}
    external = {}
    for path in files:
        if path.suffix != '.json':
            continue
        try:
            value = json.loads(path.read_bytes())
        except (ValueError, UnicodeDecodeError):
            continue  # Preserve even partial/failed-run JSON bytes in the archive.
        for record in pins(value):
            recorded_path = Path(record['file'])
            normalized = Path(os.path.abspath(recorded_path if recorded_path.is_absolute() else ROOT / recorded_path))
            record['file'] = label(normalized)
            key = (record['file'], record['bytes'], record['sha256'])
            if key in included:
                continue
            if key not in external:
                external[key] = dict(record, referencedBy=[])
            origin = label(path)
            if origin not in external[key]['referencedBy']:
                external[key]['referencedBy'].append(origin)
    return [external[key] for key in sorted(external)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'implementation/phase155/evidence')
    parser.add_argument('--compresslevel', type=int, choices=range(1, 10), default=9)
    args = parser.parse_args()
    out = args.out.resolve()
    require(out.is_relative_to(ROOT / 'implementation/phase155/evidence'),
            'output must be implementation/phase155/evidence or one of its subdirectories')
    archive, sidecar = out / 'phase155.tar.gz', out / 'capsule.json'
    require(not archive.exists() and not sidecar.exists(), 'refusing to overwrite evidence')
    retention = json.loads((ROOT / 'implementation/phase155/retention.json').read_bytes())
    require(retention.get('allSealed') is True and retention.get('pruned') is False,
            'close all retention runs without pruning before packaging')
    qualification = json.loads((ROOT / 'implementation/phase152/qualification.json').read_bytes())
    require(qualification.get('complete') is True, 'complete Phase152 qualification required')
    files = collect(out, qualification)
    members = [fingerprint(path) for path in files]
    by_file = {r['file']: r for r in members}
    for expected in (qualification['source'], qualification['selectedNative']['receipt']):
        actual = by_file[expected['file']]
        require(all(actual[key] == expected[key] for key in ('bytes', 'sha256')),
                'qualified input changed: ' + expected['file'])
    externals = external_pins(files, members)
    payloads, aliases, known = [], [], {}
    out.mkdir(parents=True, exist_ok=True)
    temporary = out / 'phase155.tar.gz.partial'
    require(not temporary.exists(), 'remove or inspect prior incomplete capsule first')
    created_temporary = False
    try:
        raw = temporary.open('xb')
        created_temporary = True
        with raw, gzip.GzipFile(filename='', fileobj=raw, mode='wb',
                               mtime=0, compresslevel=args.compresslevel) as gz:
            with tarfile.open(fileobj=gz, mode='w|') as tar:
                for path, record in zip(files, members):
                    key = (record['sha256'], record['bytes'], record['mode'])
                    if key in known:
                        aliases.append(dict(record, payload=known[key]))
                        continue
                    data = path.read_bytes()
                    require(len(data) == record['bytes'] and hashlib.sha256(data).hexdigest() == record['sha256'],
                            'input changed before archive write: ' + record['file'])
                    known[key] = record['file']
                    entry = tarfile.TarInfo(record['file'])
                    entry.mode, entry.size = record['mode'], len(data)
                    tar.addfile(entry, io.BytesIO(data))
                    payloads.append(record)
        expected_members = {r['file']: r for r in payloads}
        with tarfile.open(temporary, 'r:gz') as tar:
            for member in tar:
                require(member.isfile() and member.name in expected_members, 'unexpected archive member')
                record = expected_members.pop(member.name)
                data = tar.extractfile(member).read()
                require(len(data) == record['bytes'] and member.mode == record['mode'] and
                        hashlib.sha256(data).hexdigest() == record['sha256'], 'archive verification failed')
        require(not expected_members, 'archive members missing')
        require(files == collect(out, qualification), 'input inventory changed during packaging')
        for path, record in zip(files, members):
            require(fingerprint(path) == record, 'input changed during packaging: ' + record['file'])
        archive_record = fingerprint(temporary)
        archive_record['file'] = label(archive)
        result = dict(kind='phase155-evidence-capsule', version=1, verified=True,
                      archive=archive_record, payloads=payloads, aliases=aliases,
                      files=len(members), logicalBytes=sum(r['bytes'] for r in members),
                      payloadBytes=sum(r['bytes'] for r in payloads),
                      sizeGoalBytes=20 * 1024 * 1024,
                      withinSizeGoal=archive_record['bytes'] < 20 * 1024 * 1024,
                      requiredQualifiedImage=qualification['selectedNative']['image'],
                      referencedExternalPins=externals,
                      externalPinScope='Recorded references not present with matching bytes in this capsule. '
                        'Includes required image/toolchain/upstream assets and historical versions or prior-phase '
                        'evidence; not every reference is a direct execution dependency. These files were not '
                        'bundled or revalidated by packaging. See each preserved build request/inputs for its dependencies.',
                      restore='Extract payloads, then copy each alias.payload to alias.file and apply alias.mode. '
                        'Verify every payload and alias SHA256/size/mode. Keep capsule.json with the archive.',
                      scope='All Phase155 build files, methods, prototypes, design, reports, audit and retention '
                        'receipts; canonical source/build methods and Phase154 model dependencies. '
                        'No pruning, target execution, or claim of hermetic reproduction.')
        # An existing destination must never be replaced, including a racing seal.
        os.link(temporary, archive)
        temporary.unlink()
        with sidecar.open('x') as handle:
            handle.write(json.dumps(result, indent=2) + '\n')
    except BaseException:
        if created_temporary and temporary.exists():
            temporary.unlink()
        raise
    print(json.dumps(dict(archive=result['archive'], files=len(members),
                          payloads=len(payloads), aliases=len(aliases),
                          withinSizeGoal=result['withinSizeGoal'])))


if __name__ == '__main__':
    main()
