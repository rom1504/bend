"""Seal small Phase121 receipts; replay checks payloads without extraction."""
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
           'prepare.py', 'stage0-library.mjs'}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def pin(path, raw=None):
    raw = path.read_bytes() if raw is None else raw
    return dict(file=path.relative_to(ROOT).as_posix(), bytes=len(raw), sha256=digest(raw))


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


def source_roots():
    roots = [ROOT / 'selfhost/build/phase121']
    for parent, pattern in [('phase118', 'p120-*'), ('phase111', 'p120-*'),
                            ('phase111', 'p118-p120-*')]:
        roots.extend((ROOT / 'selfhost/build' / parent).glob(pattern))
    return sorted({p for p in roots if p.exists() and not p.is_symlink()}, key=str)


def receipt(path):
    return path.suffix in SUFFIXES or path.name in METHODS | {'stdout', 'stderr'}


def recorded_pins(payloads):
    """Keep existing artifact identities; do not read excluded large artifacts."""
    found, unparsed = {}, []
    for name, raw in sorted(payloads.items()):
        if not name.endswith('.json'):
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
                file, sha = item.get('file'), item.get('sha256')
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
        if not manifest['complete'] or names != ['manifest.json'] + [r['file'] for r in rows]:
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
    method = Path(__file__).resolve()
    payloads[method.relative_to(ROOT).as_posix()] = method.read_bytes()
    if any(len(raw) > PER_FILE for raw in payloads.values()) or sum(map(len, payloads.values())) > TOTAL:
        raise ValueError('Receipt payload exceeds configured size limits')
    pins, unparsed = recorded_pins(payloads)
    for row in omitted:
        row['recordedPins'] = sorted(pins.get(row['file'], []), key=lambda x: x['sha256'])
    rows = [pin(ROOT / name, raw) for name, raw in sorted(payloads.items())]
    manifest = dict(complete=True, method=pin(method), roots=[p.relative_to(ROOT).as_posix() for p in roots],
                    files=rows, rawBytes=sum(r['bytes'] for r in rows), omitted=omitted,
                    unparsedJsonReceipts=unparsed,
                    scope='Small receipts, outputs, logs, bounded function disassembly (.asm) and copied methods, including failures. Compiler/API sources, SSA/whole assembly (.s), ELF/object artifacts and other non-receipts remain external. recordedPins are copied from included receipts, not newly verified artifact hashes.',
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
    create.add_argument('--out', type=Path, default=ROOT / 'implementation/phase121/evidence')
    check = commands.add_parser('replay')
    check.add_argument('archive', type=Path)
    args = parser.parse_args()
    if args.mode == 'seal':
        seal(args.out.resolve())
    else:
        _, manifest = replay(args.archive)
        print(json.dumps(dict(complete=True, allPayloadsVerified=True, files=len(manifest['files']), rawBytes=manifest['rawBytes'])))


if __name__ == '__main__':
    main()
