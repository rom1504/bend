#!/usr/bin/env python3
"""Archive completed Phase136 evidence; no targets, generated IR or ELF payloads."""
import argparse
import importlib.util
import io
import json
import lzma
from pathlib import Path
import tarfile
import hashlib

SPEC = importlib.util.spec_from_file_location('phase136_evidence', Path(__file__).with_name('common-v01.py'))
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)
FILE_LIMIT = 64 * 1024**2
TOTAL_LIMIT = 192 * 1024**2


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--writers-closed', action='store_true', required=True,
                        help='Coordinator confirms all selected evidence writers have finished')
    parser.add_argument('--root', action='append', type=Path, default=[])
    a = parser.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(C.ROOT / 'implementation/phase136'):
        raise ValueError('Fresh Phase136 evidence directory required')
    roots = [*C.roots(), *a.root]
    paths, excluded = set(), []
    for root in roots:
        root = root.resolve()
        if not root.is_relative_to(C.ROOT) or not root.exists():
            raise ValueError('Existing repository root required: ' + str(root))
        for path in root.rglob('*') if root.is_dir() else [root]:
            if not path.is_file() or not C.metadata(path):
                continue
            size = path.stat().st_size
            # Native QBE often has the historical name `stdout`; retain its pin
            # in the producer report, never package the full product as a log.
            if (path.name == 'stdout' or path.suffix == '.stdout') and size > 1024**2:
                excluded.append(dict(file=str(path), bytes=size, reason='Large stdout product; identity retained by receipt'))
                continue
            if size > FILE_LIMIT:
                raise ValueError('Evidence member exceeds 64MiB bound: ' + str(path))
            if path.is_symlink():
                raise ValueError('Evidence symlinks are not archived: ' + str(path))
            paths.add(path.resolve())
    for path in C.TOOLS.rglob('*'):
        if path.is_file() and path.suffix in ('.py', '.mjs', '.bend', '.md', '.json'):
            paths.add(path.resolve())
    sources = []
    for label in ['stages-source01', 'query-source01']:
        path = C.PHASE / label / 'compiler.bend'
        if not path.is_file():
            raise ValueError('Required diagnostic source missing: ' + label)
        sources.append(C.pin(path))
        paths.add(path.resolve())
        paths.update(p.resolve() for p in path.parent.glob('module*.bend'))
    # Exact analysis implementation and the authenticated unwind metadata are
    # needed for raw sample/context/caller attribution. Binary artifacts remain
    # external and pinned, as required by the compact evidence policy.
    profiler = C.ROOT / 'selfhost/tools/profiler'
    paths.update(p.resolve() for p in profiler.iterdir() if p.is_file() and p.suffix in ('.py', '.c', '.h', '.md'))
    paths.add(C.ROOT / 'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py')
    profile_manifest = C.PHASE / 'profile01/manifest.json'
    profile_capture = C.PHASE / 'profile01/capture/report.json'
    if not profile_manifest.is_file() or not profile_capture.is_file():
        raise ValueError('Completed profiling manifest/capture required before final archive')
    manifest, capture = json.loads(profile_manifest.read_text()), json.loads(profile_capture.read_text())
    if not capture.get('complete') or not capture.get('passed'):
        raise ValueError('Final profiling capture has not passed')
    required_profile = [manifest['ownerMap'], manifest['unwindTable']]
    for row in capture['rows']:
        if row.get('mode') == 'sample':
            required_profile.extend(row[k] for k in ('profile', 'analysis', 'contexts', 'callers'))
    for value in required_profile:
        C.verify(value)
        path = Path(value['file'])
        if not path.is_relative_to(C.ROOT):
            raise ValueError('External raw metadata is outside this repository')
        paths.add(path.resolve())
    entries = [dict(name=str(path.relative_to(C.ROOT)), **C.pin(path)) for path in sorted(paths)]
    if any(entry['bytes'] > FILE_LIMIT for entry in entries):
        raise ValueError('Member exceeds 64MiB limit')
    total = sum(entry['bytes'] for entry in entries)
    if total > TOTAL_LIMIT:
        raise ValueError('Evidence exceeds 192MiB uncompressed bound')
    inventory = dict(kind='phase136-compact-evidence', method=C.pin(__file__),
        inventoryMethod=C.pin(C.__file__), members=entries, sources=sources,
        requiredProfileEvidence=required_profile, excluded=excluded,
        scope='Exact diagnostic sources, methods, successful/failed receipts, commands, diagnostics and raw sample/context/caller evidence. Excludes full generated QBE, assembly, objects, ELF and hosted APIs. Existing attribution replays additionally require the separately pinned exact executable and shared libraries; this archive is not a self-contained binary symbolization capsule.')
    raw = (json.dumps(inventory, indent=2) + '\n').encode()
    out.mkdir(parents=True)
    archive = out / 'evidence.tar.xz'
    with lzma.open(archive, 'wb', preset=4) as compressed, tarfile.open(fileobj=compressed, mode='w|') as tar:
        for entry in entries:
            C.verify({k: entry[k] for k in ('file', 'bytes', 'sha256')})
            info = tarfile.TarInfo(entry['name'])
            info.size, info.mode, info.mtime = entry['bytes'], 0o644, 0
            with Path(entry['file']).open('rb') as stream:
                tar.addfile(info, stream)
        info = tarfile.TarInfo('INVENTORY.json')
        info.size, info.mode, info.mtime = len(raw), 0o644, 0
        tar.addfile(info, io.BytesIO(raw))
    wanted = {entry['name']: entry for entry in entries}
    seen = set()
    with tarfile.open(archive, 'r:xz') as tar:
        for member in tar:
            if not member.isfile() or member.name in seen:
                raise ValueError('Unexpected archive member')
            seen.add(member.name)
            stream, digest, size = tar.extractfile(member), hashlib.sha256(), 0
            while chunk := stream.read(65536):
                digest.update(chunk)
                size += len(chunk)
            expected = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()) if member.name == 'INVENTORY.json' else wanted[member.name]
            if size != expected['bytes'] or digest.hexdigest() != expected['sha256']:
                raise ValueError('Archive member hash mismatch')
    if seen != set(wanted) | {'INVENTORY.json'}:
        raise ValueError('Missing archive member')
    for entry in entries:
        C.verify({k: entry[k] for k in ('file', 'bytes', 'sha256')})
    report = dict(complete=True, targetsRun=False, kind=inventory['kind'],
        method=C.pin(__file__), archive=C.pin(archive), members=len(entries),
        uncompressedMemberBytes=total, roundTripExact=True,
        roots=[str(p.resolve()) for p in roots], sources=sources,
        excluded=excluded, scope=inventory['scope'])
    (out / 'receipt.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
