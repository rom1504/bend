#!/usr/bin/env python3
"""Create or verify a bounded Phase107 evidence capsule. Never execute targets."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import stat
import tarfile

ROOT = Path(__file__).resolve().parents[4]
PHASE = ROOT / 'selfhost/build/phase107'
LIMIT = 100_000_000
SELECTED = PHASE / 'native-source04/compiler'
SOURCE_EXT = {'.py', '.mjs', '.js', '.ts', '.bend', '.c', '.h', '.rs', '.toml', '.lock', '.lean', '.md', '.sh'}


def digest(stream):
    h = hashlib.sha256(); size = 0
    while True:
        block = stream.read(1024 * 1024)
        if not block: return size, h.hexdigest()
        size += len(block); h.update(block)


def pin(path):
    before = path.stat()
    assert path.is_file() and not path.is_symlink(), str(path)
    with path.open('rb') as stream: size, sha = digest(stream)
    after = path.stat()
    assert (before.st_size, before.st_mtime_ns, before.st_ino) == (after.st_size, after.st_mtime_ns, after.st_ino), str(path)
    return dict(file=str(path.relative_to(ROOT)), bytes=size, sha256=sha, mode=stat.S_IMODE(after.st_mode))


def walk(folder, out):
    assert folder.is_dir() and not folder.is_symlink(), str(folder)
    result = []
    def fail(error): raise error
    for directory, dirs, files in os.walk(folder, followlinks=False, onerror=fail):
        dirs.sort(); files.sort()
        for name in list(dirs):
            path = Path(directory) / name
            assert not path.is_symlink(), str(path)
            if path == out: dirs.remove(name)
        for name in files:
            path = Path(directory) / name
            assert not path.is_symlink(), str(path)
            result.append(path)
    return result


def reason(path):
    relative = path.relative_to(ROOT)
    if '__pycache__' in relative.parts or path.suffix == '.pyc': return 'Python cache'
    if path.is_relative_to(PHASE / 'toolchain'): return 'External QBE source/build tree; acquisition/build receipts retained'
    if path == SELECTED: return None
    if path.suffix in {'.zip', '.gz', '.xz', '.zst', '.tar'}: return 'Historical compressed capsule or acquisition archive; exact identity retained'
    if path.suffix in {'.o', '.a', '.so', '.bin'} and path.stat().st_size > 1024 * 1024: return 'Large rebuildable object/binary product; exact identity retained'
    if path.suffix == '.c' and path.stat().st_size > 1024 * 1024: return 'Large generated C; source and acquisition/emission receipts retained'
    if path.suffix == '.mjs' and 'api' in path.name.lower() and path.stat().st_size > 512 * 1024: return 'Rebuildable generated API bundle; exact identity retained'
    with path.open('rb') as stream: prefix = stream.read(4)
    if (prefix == b'\x7fELF' or prefix[:2] == b'MZ') and path.stat().st_size > 1024 * 1024: return 'Rebuildable executable; selected native-source04 image is retained separately'
    return None


def references(value, pointer=''):
    if isinstance(value, dict):
        key = 'file' if isinstance(value.get('file'), str) else 'path'
        if isinstance(value.get(key), str) and isinstance(value.get('sha256'), str) and len(value['sha256']) == 64:
            yield pointer, dict(file=value[key], **{k: value[k] for k in ['bytes', 'sha256'] if k in value})
        for key, item in value.items(): yield from references(item, pointer + '/' + str(key))
    elif isinstance(value, list):
        for index, item in enumerate(value): yield from references(item, pointer + '/' + str(index))


class BoundedWriter:
    def __init__(self, stream, limit): self.stream, self.limit, self.size = stream, limit, 0
    def write(self, data):
        assert self.size + len(data) <= self.limit, 'Compressed archive budget exceeded; partial output retained'
        count = self.stream.write(data); self.size += count; return count
    def flush(self): return self.stream.flush()
    def tell(self): return self.size


def verify(archive, entries):
    with tarfile.open(archive, 'r|gz') as tar:
        count = 0
        for member in tar:
            assert count < len(entries), 'Unexpected member'
            expected = entries[count]; count += 1
            assert member.isfile() and member.name == expected['file']
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            assert member.mode == expected['mode'] and member.size == expected['bytes']
            assert member.uid == member.gid == member.mtime == 0
            with tar.extractfile(member) as stream: size, sha = digest(stream)
            assert (size, sha) == (expected['bytes'], expected['sha256']), member.name
        assert count == len(entries), 'Missing archive member'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--writers-closed', action='store_true', help='Coordinator declares selected source/receipt writers closed')
    parser.add_argument('--verify-only', type=Path)
    args = parser.parse_args()
    if args.verify_only:
        assert args.out is None and not args.writers_closed
        directory = args.verify_only.resolve(); report = json.loads((directory / 'manifest.json').read_text())
        assert report['complete'] and report['archive']['file'] == 'observations.tar.gz'
        expected_names = {'observations.tar.gz', 'FILES.sha256', 'manifest.json'}
        assert {p.name for p in directory.iterdir()} == expected_names
        assert all(p.is_file() and not p.is_symlink() for p in directory.iterdir())
        assert (directory / 'FILES.sha256').read_text() == ''.join(f"{e['sha256']}  {e['file']}\n" for e in report['files'])
        archive = directory / report['archive']['file']
        with archive.open('rb') as stream: size, sha = digest(stream)
        assert (size, sha) == (report['archive']['bytes'], report['archive']['sha256'])
        assert sum(p.stat().st_size for p in directory.iterdir() if p.is_file()) <= LIMIT
        verify(archive, report['files'])
        print(json.dumps(dict(complete=True, verified=True, members=len(report['files'])))); return
    assert args.out is not None and args.writers_closed, '--out and explicit --writers-closed are required'
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase107') and not out.exists()
    roots = [PHASE, ROOT / 'selfhost/tools/performance/phase107', ROOT / 'selfhost/tools/performance/phase106',
             ROOT / 'selfhost/tools/native', ROOT / 'selfhost/src', ROOT / 'implementation/phase107', ROOT / 'design/phase107']
    proof_roots = sorted((ROOT / 'selfhost/build/phase98').glob('phase107-*'))
    assert proof_roots, 'No Phase107 proof evidence roots'
    roots += proof_roots
    assert PHASE.is_dir() and SELECTED.is_file()
    explicit = [p for p in (ROOT / 'selfhost/tools').iterdir() if p.is_file() and p.suffix in SOURCE_EXT]
    explicit += [ROOT / name for name in [
        'AGENTS.md', 'selfhost/tools/laws/phase98/check.py',
        'selfhost/tools/performance/phase86/guard.py',
        'selfhost/tools/performance/programs/support.py',
        'selfhost/tools/performance/phase46/execute.py',
        'selfhost/tests/conformance/typed-smoke/bad-type.bend',
        'selfhost/proofs/phase67/reject-unequal-labels.bendtt']]
    assert all(path.is_file() and not path.is_symlink() for path in explicit)
    inventory = sorted(set(explicit + [p for root in roots for p in walk(root, out)]))
    entries = {}; exclusions = {}; reference_rows = []; json_errors = []
    for path in inventory:
        item = pin(path); why = reason(path)
        if why: exclusions[item['file']] = dict(**item, reason=why)
        else: entries[item['file']] = item
    # Read every campaign/proof JSON, including failed/malformed fixture bytes.
    # Old referenced JSON is copied when small, but is NOT recursively traversed:
    # historical campaign closures remain named prerequisites, not a silent rearchive.
    for path in inventory:
        if path.suffix != '.json' or path.is_relative_to(PHASE / 'toolchain'): continue
        try: document = json.loads(path.read_text())
        except (UnicodeError, json.JSONDecodeError) as error:
            json_errors.append(dict(file=str(path.relative_to(ROOT)), parseError=str(error))); continue
        for pointer, declared in references(document):
            named = Path(declared['file']); named = named if named.is_absolute() else ROOT / named
            named = named.resolve()
            row = dict(receipt=str(path.relative_to(ROOT)), pointer=pointer, declared=declared)
            if named.is_relative_to(ROOT) and named.is_file() and not named.is_symlink():
                rel = str(named.relative_to(ROOT)); row['localPath'] = rel
                eligible = named.suffix in SOURCE_EXT or (named.suffix == '.json' and named.stat().st_size <= 2 * 1024 * 1024)
                if rel not in entries and rel not in exclusions and eligible:
                    why = reason(named)
                    if named.stat().st_size > 4 * 1024 * 1024: why = 'Large historical dependency; expected identity retained'
                    item = pin(named)
                    if why: exclusions[rel] = dict(**item, reason=why)
                    else: entries[rel] = item
            reference_rows.append(row)
    files = sorted(entries.values(), key=lambda row: row['file'])
    by_content = {}
    for item in files: by_content.setdefault(item['sha256'], []).append(item)
    unresolved = 0; content_index = {}
    for row in reference_rows:
        declared = row['declared']
        # Missing byte length is distinct from every declared JSON value.
        content_key = declared['sha256'] + '/' + (json.dumps(declared['bytes'], sort_keys=True, separators=(',', ':')) if 'bytes' in declared else '*')
        if content_key not in content_index:
            matches = [x['file'] for x in by_content.get(declared['sha256'], []) if 'bytes' not in declared or declared['bytes'] == x['bytes']]
            content_index[content_key] = dict(sha256=declared['sha256'],
                **({'bytes': declared['bytes']} if 'bytes' in declared else {}), capsuleMatches=matches)
        row['contentKey'] = content_key
        if not content_index[content_key]['capsuleMatches']: unresolved += 1
    acquisition = json.loads((PHASE / 'native-source04/acquisition.json').read_text())
    assert acquisition['complete']
    for key in ['source', 'binary', 'generatedC']:
        declared = acquisition[key]; relative = str(Path(declared['file']).relative_to(ROOT))
        item = entries.get(relative, exclusions.get(relative))
        assert item is not None
        assert item['sha256'] == declared['sha256'] and item['bytes'] == declared['bytes']
    # Reserve metadata space BEFORE writing. No uncompressed tar/copy tree exists.
    report = dict(kind='phase107-evidence-capsule', complete=False, writersClosed=True, files=files,
        exclusions=sorted(exclusions.values(), key=lambda row: row['file']), receiptReferences=reference_rows,
        referenceContentIndex=content_index, referenceEncoding='Occurrence contentKey resolves to referenceContentIndex; each original receipt/pointer/declared pin is retained',
        unresolvedReferenceOccurrences=unresolved, malformedJsonPreserved=json_errors,
        roots=[str(p.relative_to(ROOT)) for p in roots], selectedNativeAcquisition=acquisition,
        externalPrerequisiteScope='Declared unmatched references include installed compiler/Phase103 assets, historical Cranelift adapter, QBE, Clang, Bun and Lean toolchains. QBE source tree has a complete local hash inventory but its empty build inputs receipt does not establish a pinned upstream source acquisition. Historical JSON closure is not recursively rearchived.',
        scope='All selected source/receipt/method bytes and failures; exact member verification. Unmatched historical/tool pins remain explicit external prerequisites, not claimed present or rerun. No target execution or compiler qualification.')
    manifest_bytes = len(json.dumps(report, indent=2).encode())
    checksum_reserve = sum(len(x['file'].encode()) + 68 for x in files)
    metadata_reserve = manifest_bytes + checksum_reserve + 65536
    metadata_sizes = dict(manifestBytes=manifest_bytes, checksumReserveBytes=checksum_reserve,
        safetyReserveBytes=65536, totalReserveBytes=metadata_reserve, limitBytes=LIMIT,
        receiptReferences=len(reference_rows), distinctContentKeys=len(content_index),
        includedFiles=len(files), excludedFiles=len(exclusions))
    print(json.dumps(dict(stage='metadata-budget', **metadata_sizes)), flush=True)
    assert metadata_reserve < LIMIT, json.dumps(metadata_sizes, sort_keys=True)
    out.mkdir(parents=True)
    partial = out / 'observations.tar.gz.partial'
    with partial.open('xb') as raw:
        bounded = BoundedWriter(raw, LIMIT - metadata_reserve)
        with gzip.GzipFile(fileobj=bounded, mode='wb', filename='', mtime=0) as zipped:
            with tarfile.open(fileobj=zipped, mode='w|', format=tarfile.PAX_FORMAT) as tar:
                for entry in files:
                    path = ROOT / entry['file']; info = tarfile.TarInfo(entry['file'])
                    info.size = entry['bytes']; info.mode = entry['mode']; info.mtime = info.uid = info.gid = 0
                    with path.open('rb') as content: tar.addfile(info, content)
    verify(partial, files)
    current_top = [p for p in (ROOT / 'selfhost/tools').iterdir() if p.is_file() and p.suffix in SOURCE_EXT]
    initial_top = [p for p in explicit if p.parent == ROOT / 'selfhost/tools']
    assert sorted(current_top) == sorted(initial_top), 'Top-level method inventory changed'
    assert sorted((ROOT / 'selfhost/build/phase98').glob('phase107-*')) == proof_roots, 'Proof root inventory changed'
    current = sorted(set(explicit + [p for root in roots for p in walk(root, out)]))
    assert current == inventory, 'Input inventory changed'
    for entry in [*files, *exclusions.values()]:
        assert pin(ROOT / entry['file']) == {k: entry[k] for k in ['file', 'bytes', 'sha256', 'mode']}, entry['file']
    with partial.open('rb') as stream: size, sha = digest(stream)
    report.update(complete=True, inputsUnchanged=True, archive=dict(file='observations.tar.gz', bytes=size, sha256=sha),
                  verification='Every tar member name/type/mode/size/hash verified by streaming; inventory and all included/excluded local bytes rechecked')
    manifest = (json.dumps(report, indent=2) + '\n').encode()
    sums = ''.join(f"{e['sha256']}  {e['file']}\n" for e in files).encode()
    assert size + len(manifest) + len(sums) <= LIMIT
    assert {p.name for p in out.iterdir()} == {'observations.tar.gz.partial'}, 'Unexpected output directory member'
    assert not partial.is_symlink()
    partial.rename(out / 'observations.tar.gz')
    (out / 'FILES.sha256').write_bytes(sums)
    (out / 'manifest.json').write_bytes(manifest)  # Complete is published last.
    print(json.dumps(dict(complete=True, files=len(files), excluded=len(exclusions), externalReferenceOccurrences=unresolved, compressedBytes=size, totalBytes=size+len(manifest)+len(sums), archiveSha256=sha)))


if __name__ == '__main__': main()
