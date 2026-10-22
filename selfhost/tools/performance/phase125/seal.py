"""Seal bounded Phase125 evidence; audit/replay execute no compiler or target.

Source: the Phase124 sealer, extended for native jobs, original controls and
small directly pinned recipe inputs. Root selects the final sealing time/path.
"""
import argparse
import gzip
import hashlib
import io
import json
import re
import tarfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[4]
PER_FILE = 8 * 1024**2
TOTAL = 64 * 1024**2
SUFFIXES = {'.json', '.stdout', '.stderr', '.samples', '.log', '.asm'}
METHODS = {'method.py', 'method.mjs', 'method.js', 'method.sh',
           'prepare.py', 'stage0-library.mjs', 'native-emit-method.py'}
SOURCE_SUFFIXES = {'.py', '.mjs', '.js', '.sh', '.bend', '.c', '.h', '.md', '.diff', '.txt'}
SOURCE_LIMIT = 512 * 1024
EXCLUDED_NAMES = {'compiler.bend', 'api.mjs', 'program', 'program.s', 'program.ssa', 'program.o', 'runtime.o'}
SOURCE_ROOT = ROOT / 'selfhost/tools/performance/phase125'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def pin(path, raw=None):
    raw = path.read_bytes() if raw is None else raw
    return dict(file=path.relative_to(ROOT).as_posix(), bytes=len(raw), sha256=digest(raw))


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


def source_roots():
    roots = [ROOT / 'selfhost/build/phase125', SOURCE_ROOT]
    for parent, pattern in [('phase118', 'p125-*'), ('phase111', 'p125-*'),
                            ('phase111', 'p118-p125-*'), ('phase113', 'p125-*'),
                            ('phase112', 'p125-*')]:
        roots.extend((ROOT / 'selfhost/build' / parent).glob(pattern))
    # Final report/results/selection are included when present; prior capsules
    # in evidence subdirectories are never recursively embedded.
    for parent in [ROOT / 'implementation/phase125', ROOT / 'design/phase125']:
        if parent.is_dir():
            roots.extend(p for p in parent.iterdir() if p.is_file())
    return sorted({p for p in roots if p.exists() and not p.is_symlink()}, key=str)


def receipt(path):
    if path.name in EXCLUDED_NAMES:
        return False
    if path.suffix in SUFFIXES or path.name in METHODS | {'stdout', 'stderr'} or path.name.endswith('.json.tmp'):
        return True
    if path.suffix not in SOURCE_SUFFIXES or path.stat().st_size > SOURCE_LIMIT:
        return False
    return (path.is_relative_to(SOURCE_ROOT) or
            path.is_relative_to(ROOT / 'implementation/phase125') or
            path.is_relative_to(ROOT / 'design/phase125') or
            bool(re.fullmatch(r'module[0-9]+\.bend', path.name)) or
            path.name in {'runtime.c', 'runtime.h', 'primitives.h'})


def referenced_input(path):
    # One direct pin hop, not a recursive archive of the entire bootstrap.
    return (path.name not in EXCLUDED_NAMES and
            (path.suffix in SOURCE_SUFFIXES or path.suffix in {'.json', '.stdout', '.stderr'}) and
            path.stat().st_size <= SOURCE_LIMIT)


def recorded_pins(payloads):
    """Keep existing artifact identities; do not read excluded large artifacts."""
    found, unparsed = {}, []
    for name, raw in sorted(payloads.items()):
        if not name.endswith(('.json', '.json.tmp')):
            continue
        try:
            pending = [json.loads(raw)]
        except (ValueError, UnicodeError):
            unparsed.append(name)  # A partial failure receipt is still archived.
            continue
        while pending:
            item = pending.pop()
            if isinstance(item, list):
                pending.extend(item)
            elif isinstance(item, dict):
                pending.extend(item.values())
                file, sha = item.get('file', item.get('path')), item.get('sha256')
                if not isinstance(file, str) or not isinstance(sha, str) or not re.fullmatch('[0-9a-f]{64}', sha):
                    continue
                path = Path(file)
                path = path if path.is_absolute() else ROOT / path
                try:
                    key = path.relative_to(ROOT).as_posix()
                except ValueError:
                    continue
                entry = dict(sha256=sha)
                if isinstance(item.get('bytes'), int):
                    entry['bytes'] = item['bytes']
                records = found.setdefault(key, [])
                if entry not in records:
                    records.append(entry)
    return found, unparsed


def collect():
    roots = source_roots()
    files = sorted({p for root in roots for p in ([root] if root.is_file() else root.rglob('*')) if p.is_file()}, key=str)
    payloads, omitted = {}, []
    for path in files:
        name = path.relative_to(ROOT).as_posix()
        if path.is_symlink():
            omitted.append(dict(file=name, reason='symlink; not followed'))
        elif not receipt(path):
            omitted.append(dict(file=name, bytes=path.stat().st_size, reason='artifact/non-receipt'))
        elif path.stat().st_size > PER_FILE:
            omitted.append(dict(file=name, bytes=path.stat().st_size, reason='receipt exceeds 8 MiB'))
        else:
            payloads[name] = path.read_bytes()
    pins, _ = recorded_pins(payloads)
    added = []
    for name, records in sorted(pins.items()):
        path = ROOT / name
        if (name in payloads or not path.is_file() or path.is_symlink() or
                path.resolve() != path.absolute() or not referenced_input(path)):
            continue
        raw = path.read_bytes()
        # A referenced snapshot must match an archived authority. Stale or
        # intentionally superseded pins remain recorded rather than substituted.
        if any(digest(raw) == row['sha256'] and row.get('bytes', len(raw)) == len(raw) for row in records):
            payloads[name] = raw
            added.append(name)
    omitted = [row for row in omitted if row['file'] not in payloads]
    method = Path(__file__).resolve()
    payloads[method.relative_to(ROOT).as_posix()] = method.read_bytes()
    parent = ROOT / 'selfhost/tools/performance/phase124/seal.py'
    payloads[parent.relative_to(ROOT).as_posix()] = parent.read_bytes()
    if any(len(raw) > PER_FILE for raw in payloads.values()) or sum(map(len, payloads.values())) > TOTAL:
        raise ValueError('Receipt payload exceeds configured size limits')
    return roots, payloads, omitted, added


def stream_pin(path):
    """Identity for a failed/partial omitted artifact absent from its receipts."""
    before, sha, size = path.stat(), hashlib.sha256(), 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            sha.update(chunk)
            size += len(chunk)
    after = path.stat()
    if (before.st_ino, before.st_size, before.st_mtime_ns) != (after.st_ino, after.st_size, after.st_mtime_ns):
        raise ValueError('Omitted artifact changed while pinning: ' + str(path))
    return dict(file=path.relative_to(ROOT).as_posix(), bytes=size, sha256=sha.hexdigest())


def replay(archive):
    with tarfile.open(archive, 'r:gz') as stream:
        members = stream.getmembers()
        names = [m.name for m in members]
        if len(names) != len(set(names)) or 'manifest.json' not in names:
            raise ValueError('Duplicate members or missing manifest')
        for member in members:
            name = PurePosixPath(member.name)
            if not member.isfile() or name.is_absolute() or '..' in name.parts or member.size > PER_FILE:
                raise ValueError('Unsafe or oversized archive member: ' + member.name)
        if sum(m.size for m in members) > TOTAL + PER_FILE:
            raise ValueError('Archive exceeds bounded payload size')
        manifest_raw = stream.extractfile('manifest.json').read()
        manifest = json.loads(manifest_raw)
        rows = manifest['files']
        if (manifest.get('kind') != 'phase125-evidence-capsule' or not manifest['complete'] or
                names != ['manifest.json'] + [r['file'] for r in rows]):
            raise ValueError('Unexpected member set/order')
        for row in rows:
            raw = stream.extractfile(row['file']).read()
            if len(raw) != row['bytes'] or digest(raw) != row['sha256']:
                raise ValueError('Payload mismatch: ' + row['file'])
        if sum(r['bytes'] for r in rows) != manifest['rawBytes']:
            raise ValueError('Payload total mismatch')
    return manifest_raw, manifest


def seal(out):
    out.relative_to(ROOT)  # All manifest identities are repository-relative.
    if out.exists():
        raise FileExistsError('Fresh output directory required: ' + str(out))
    roots, payloads, omitted, added = collect()
    method = Path(__file__).resolve()
    pins, unparsed = recorded_pins(payloads)
    unrecorded = {}
    for row in omitted:
        row['recordedPins'] = sorted(pins.get(row['file'], []), key=lambda x: x['sha256'])
        if not row['recordedPins'] and row['reason'] != 'symlink; not followed':
            path = ROOT / row['file']
            stat = path.stat()
            key = (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns)
            if key not in unrecorded:
                unrecorded[key] = stream_pin(path)
            row['observedPin'] = dict(unrecorded[key], file=row['file'])
    rows = [pin(ROOT / name, raw) for name, raw in sorted(payloads.items())]
    manifest = dict(kind='phase125-evidence-capsule', complete=True, method=pin(method), roots=[p.relative_to(ROOT).as_posix() for p in roots],
                    files=rows, rawBytes=sum(r['bytes'] for r in rows), omitted=omitted,
                    directlyPinnedInputsIncluded=added,
                    unparsedJsonReceipts=unparsed,
                    scope='Small receipts, outputs, logs, bounded disassembly, methods, original controls/oracles, Phase125 source modules and one-hop small pinned recipe inputs, including failures. Full compiler/API sources, SSA/whole assembly, ELF/object artifacts remain external. recordedPins are copied from included receipts; only unrecorded omitted files receive streaming observedPin hashes. Replay verifies archived bytes, not external artifacts or experiment success.',
                    limits=dict(perFileBytes=PER_FILE, totalPayloadBytes=TOTAL))
    payload = encoded(manifest)
    if len(payload) > PER_FILE:
        raise ValueError('Manifest exceeds 8 MiB')
    out.mkdir(parents=True)
    archive = out / 'receipts01.tar.gz'
    # Set both gzip and tar timestamps/ownership; filename is deliberately empty.
    with archive.open('xb') as sink, gzip.GzipFile(filename='', mode='wb', fileobj=sink, mtime=0, compresslevel=6) as zipped:
        with tarfile.open(fileobj=zipped, mode='w', format=tarfile.PAX_FORMAT) as stream:
            for name, raw in [('manifest.json', payload)] + sorted(payloads.items()):
                if name != 'manifest.json' and (ROOT / name).read_bytes() != raw:
                    raise ValueError('Input changed during sealing: ' + name)
                info = tarfile.TarInfo(name)
                info.size, info.mtime, info.mode = len(raw), 0, 0o644
                info.uid = info.gid = 0
                info.uname = info.gname = ''
                stream.addfile(info, io.BytesIO(raw))
    actual, _ = replay(archive)
    if actual != payload:
        raise ValueError('Archived manifest mismatch')
    (out / 'manifest.json').write_bytes(payload)
    summary = dict(complete=True, allPayloadsVerified=True, archive=pin(archive),
                   files=len(rows), rawBytes=manifest['rawBytes'], omittedFiles=len(omitted))
    (out / 'summary.json').write_bytes(encoded(summary))
    print(json.dumps(summary, sort_keys=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='mode', required=True)
    create = commands.add_parser('seal')
    create.add_argument('--out', type=Path, default=ROOT / 'implementation/phase125/evidence')
    check = commands.add_parser('replay')
    check.add_argument('archive', type=Path)
    commands.add_parser('audit', help='Read/list bounded inputs without packaging or hashing omitted artifacts')
    args = parser.parse_args()
    if args.mode == 'seal':
        seal(args.out.resolve())
    elif args.mode == 'replay':
        _, manifest = replay(args.archive)
        print(json.dumps(dict(complete=True, allPayloadsVerified=True, files=len(manifest['files']), rawBytes=manifest['rawBytes'])))
    else:
        roots, payloads, omitted, added = collect()
        pins, unparsed = recorded_pins(payloads)
        print(json.dumps(dict(targetsRun=False, archiveCreated=False,
            roots=[p.relative_to(ROOT).as_posix() for p in roots], files=len(payloads),
            rawBytes=sum(map(len, payloads.values())), omittedFiles=len(omitted),
            omittedWithoutRecordedPin=sum(not pins.get(row['file']) for row in omitted),
            directlyPinnedInputsIncluded=len(added), unparsedJsonReceipts=unparsed), sort_keys=True))


if __name__ == '__main__':
    main()
