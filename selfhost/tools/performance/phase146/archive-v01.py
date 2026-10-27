#!/usr/bin/env python3
"""Freeze compact Phase146 evidence; metadata only, no compiler/target execution.

Run after final receipts exist. Large generated products stay at their recorded
paths, with identities retained in the original reports and inventory.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]
MIB = 1024 * 1024
SOURCE_SHA = '96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80'
SCOPES = ['selfhost/build/phase146', 'selfhost/tools/performance/phase146',
          'design/phase146', 'research/phase146', 'implementation/phase146', 'experiments/phase146']
REQUIRED = ['selfhost/build/phase146/source03/manifest.json',
            'selfhost/build/phase111/p146-api03/report.json',
            'selfhost/build/phase146/source03/controls/report.json',
            'selfhost/build/phase146/hosted-screen01/report.json',
            'selfhost/build/phase146/counts01/report.json',
            'selfhost/build/phase146/native-screen01/report.json',
            'selfhost/build/phase134/p146-context01-n1/report.json',
            'selfhost/build/phase134/p146-context01-n2/report.json']
EXPLICIT = ['implementation/phase144/final04/candidate.json',
            'implementation/phase144/final04/qualification.json',
            'selfhost/build/phase144/final04-source01/manifest.json',
            'selfhost/build/phase111/p144-integrated-api04/report.json',
            'selfhost/build/phase134/p144-final04-n2/report.json',
            'selfhost/build/phase130/base-carrier01/receipt.json',
            'selfhost/build/phase144/serial-rfc01/build.json']


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda: handle.read(MIB), b''):
            h.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def pins(value):
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= value.keys() and isinstance(value['file'], str) and type(value['bytes']) is int:
            yield {key: value[key] for key in ('file', 'bytes', 'sha256')}
        for child in value.values():
            yield from pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from pins(child)


def excluded(path):
    if path.is_symlink():
        return 'symlink-not-followed'
    if '__pycache__' in path.parts or path.suffix in {'.pyc', '.tmp', '.lock'}:
        return 'transient'
    if path.suffix in {'.ssa', '.s', '.o', '.a', '.so', '.zip', '.xz', '.gz', '.tar'}:
        return 'generated-IR-machine-or-other-archive'
    if path.name in {'stdout', 'compiler.stdout'} and path.stat().st_size > 65536:
        return 'large-generated-output'
    if path.suffix == '.mjs' and path.stat().st_size > MIB:
        return 'large-generated-api-pinned-in-receipts'
    if path.stat().st_size > 8 * MIB:
        return 'over8MiB'
    with path.open('rb') as handle:
        if handle.read(4) == b'\x7fELF':
            return 'executable-image'
    return None


def select(out):
    roots = [ROOT / name for name in SCOPES]
    for phase in ('phase111', 'phase130', 'phase134'):
        roots.extend(sorted((ROOT / 'selfhost/build' / phase).glob('p146-*')))
    files, omitted = set(), []
    for root in roots:
        if not root.exists():
            continue
        paths = [root] if root.is_file() else sorted(root.rglob('*'))
        for path in paths:
            if not path.is_file() or (out and (path == out or out in path.parents)):
                continue
            reason = excluded(path)
            if reason:
                omitted.append(dict(file=str(path), bytes=path.stat().st_size, reason=reason))
            else:
                files.add(path.resolve())
    for name in EXPLICIT:
        path = ROOT / name
        assert path.is_file(), path
        files.add(path.resolve())
    # One bounded dependency pass preserves exact referenced methods and small
    # fixtures without recursively copying historical campaigns or toolchains.
    dependencies = {}
    for path in sorted(files):
        if path.suffix != '.json':
            continue
        for item in pins(read(path)):
            dependencies[(item['file'], item['sha256'], item['bytes'])] = item
    records = []
    for item in sorted(dependencies.values(), key=lambda row: (row['file'], row['sha256'])):
        path = Path(item['file']).resolve()
        inside = path.is_relative_to(ROOT)
        rel = str(path.relative_to(ROOT)) if inside else ''
        include = inside and item['bytes'] <= 8 * MIB and (
            rel.startswith('selfhost/tools/') or
            rel.startswith('selfhost/.bootstrap/upstream-phase66/bend2/') or
            path.suffix == '.bend' and item['bytes'] <= 512 * 1024)
        status = 'external-pin-retained-not-rehashed'
        if path in files or include:
            if not path.is_file():
                status = 'missing-historical-dependency'
            elif pin(path) != item:
                status = 'historical-pin-differs-from-current-file'
            elif excluded(path):
                status = 'excluded-product-pin-retained'
            else:
                files.add(path)
                status = 'included-and-rehashed'
        records.append(dict(recorded=item, status=status))
    return files, dict(roots=[str(path) for path in roots], omitted=omitted, dependencies=records)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--inventory-only', action='store_true')
    parser.add_argument('--require', action='append', type=Path, default=[],
                        help='Additional final successful receipt; repeat for qualification/Q3/suites.')
    args = parser.parse_args()
    out = args.out.resolve() if args.out else None
    if not args.inventory_only:
        assert out and out.is_relative_to(ROOT / 'implementation/phase146') and not out.exists()
        assert args.require, 'Supply final successful qualification/report receipt with --require'
    files, detail = select(out)
    if args.inventory_only:
        print(json.dumps(dict(kind='phase146-evidence-preview', targetsRun=False,
                              files=len(files), rawBytes=sum(path.stat().st_size for path in files),
                              omitted=len(detail['omitted'])), indent=2))
        return
    required = [ROOT / name for name in REQUIRED] + [path.resolve() for path in args.require]
    for path in required:
        assert path.is_relative_to(ROOT) and read(path).get('complete') is True, path
        files.add(path)
    source = ROOT / 'selfhost/build/phase146/source03/compiler.bend'
    source_pin = pin(source)
    assert source_pin['sha256'] == SOURCE_SHA and source in files
    checked = read(ROOT / 'selfhost/build/phase111/p146-api03/report.json')
    assert checked['checked'] is True and checked['status'] == 0 and source_pin in checked['inputs']
    failed = ROOT / 'selfhost/build/phase111/p146-api01/report.json'
    assert failed in files and read(failed).get('complete') is False, 'Retain initial failed source check'
    guards = []
    for path in sorted(files):
        if path.name == 'process.json' and path.parent.name.endswith('-guard'):
            value = read(path)
            assert 'finished' in value and 'returncode' in value, ('Guard still active', path)
            guards.append(pin(path))
    files = sorted(files)
    rows = [dict(pin(path), file=str(path.relative_to(ROOT))) for path in files]
    total = sum(row['bytes'] for row in rows)
    assert total <= 96 * MIB, ('Archive raw budget exceeded', total)
    scope = ['Evidence archive only; no compiler/target execution or qualification by this tool.',
             'Source03 and failed source attempts are included as compressed archive members.',
             'Large APIs, QBE, assembly, objects, ELF images and tool executables are omitted; original receipts preserve identities and paths.',
             'Frozen small methods/modules, diagnostics, guards and measured clocks are retained; nested guard costs must not be summed blindly.',
             'Historical missing/changed dependencies remain explicitly labeled; this is not a hermetic compiler distribution.']
    inventory = dict(kind='phase146-compact-evidence-inventory', complete=True, targetsRun=False,
                     method=pin(__file__), source=source_pin, required=[pin(path) for path in required],
                     failedSourceAttempt=pin(failed), guards=guards, files=rows, rawBytes=total,
                     scope=scope, **detail)
    out.mkdir(parents=True)
    manifest = out / 'inventory.json'
    manifest.write_text(json.dumps(inventory, indent=2) + '\n')
    archive = out / 'evidence.tar.gz'
    with archive.open('xb') as target, gzip.GzipFile(fileobj=target, mode='wb', filename='', mtime=0, compresslevel=6) as zipped, tarfile.open(fileobj=zipped, mode='w|') as tar:
        for path in [manifest, *files]:
            name = 'inventory.json' if path == manifest else str(path.relative_to(ROOT))
            info = tar.gettarinfo(str(path), arcname=name)
            info.uid = info.gid = 0
            info.uname = info.gname = ''
            info.mtime = 0
            with path.open('rb') as handle:
                tar.addfile(info, handle)
    assert archive.stat().st_size <= 16 * MIB, 'Compressed budget exceeded; no complete receipt issued'
    expected = {row['file']: {key: row[key] for key in ('bytes', 'sha256')} for row in rows}
    expected['inventory.json'] = {key: pin(manifest)[key] for key in ('bytes', 'sha256')}
    seen = set()
    with tarfile.open(archive, 'r:gz') as tar:
        for member in tar:
            assert member.isfile() and member.name in expected and member.name not in seen
            seen.add(member.name)
            h, size = hashlib.sha256(), 0
            with tar.extractfile(member) as handle:
                for block in iter(lambda: handle.read(MIB), b''):
                    h.update(block)
                    size += len(block)
            assert dict(bytes=size, sha256=h.hexdigest()) == expected[member.name]
    assert seen == set(expected)
    for path, row in zip(files, rows):
        actual = pin(path)
        assert actual['bytes'] == row['bytes'] and actual['sha256'] == row['sha256'], path
    receipt = dict(kind='phase146-compact-evidence-archive', complete=True, targetsRun=False,
                   method=pin(__file__), archive=pin(archive), inventory=pin(manifest),
                   members=len(seen), rawBytes=total, allMembersRehashed=True,
                   sourceFilesUnchanged=True, scope=scope)
    (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))


if __name__ == '__main__':
    main()
