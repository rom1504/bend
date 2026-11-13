#!/usr/bin/env python3
"""Pack bounded Phase192 JSON receipts and diagnostic streams; never run targets."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/build/phase192'
RETENTION = ROOT/'selfhost/build-retention/phase192'
IMPLEMENTATION = ROOT/'implementation/phase192'
JSON_NAMES = {'report.json', 'process.json', 'retention.json', 'manifest.json',
              'programs.manifest.json', 'programs.recipe.json', 'recipe.json',
              'oracle-process.json', 'receipt.json', 'intent.json', 'policy.json', 'plan.json'}
STREAM_NAMES = {'stdout', 'stderr', 'stdout.log', 'stderr.log'}
MAX_STREAM = 128*1024
MAX_JSON = 8*1024**2
MAX_TOTAL = 128*1024**2


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path, data=None):
    data = path.read_bytes() if data is None else data
    return dict(file=str(path), bytes=len(data), sha256=digest(data))


def active_guards():
    incomplete = []
    for directory in BUILD.glob('*-guard'):
        path = directory/'process.json'
        try:
            value = json.loads(path.read_text())
            if value.get('finished') is None or value.get('returncode') is None:
                incomplete.append(directory.name)
        except (OSError, ValueError):
            incomplete.append(directory.name)
    return sorted(incomplete)


def inventory(out):
    included, excluded = [], []
    for root in [BUILD, RETENTION, IMPLEMENTATION]:
        if not root.exists():
            continue
        for path in sorted(root.rglob('*')):
            if path == out or out in path.parents or not path.is_file():
                continue
            if path.is_symlink() or path.resolve() != path:
                raise ValueError('Symlinked evidence: '+str(path))
            relative = path.relative_to(root)
            top_implementation = root == IMPLEMENTATION and len(relative.parts) == 1 and path.suffix in ('.json', '.md', '.log')
            top_build = root == BUILD and len(relative.parts) == 1 and path.suffix == '.json'
            stream = path.name in STREAM_NAMES or path.suffix in ('.stdout', '.stderr')
            json_receipt = path.name in JSON_NAMES
            allowed = path.name != 'source-map.json' and (top_implementation or top_build or stream or json_receipt)
            if not allowed:
                continue
            maximum = MAX_STREAM if stream else MAX_JSON
            if path.stat().st_size > maximum:
                excluded.append(dict(file=str(path), bytes=path.stat().st_size,
                                     reason='Exceeds bounded stream/JSON member size; retained hot and omitted.'))
            else:
                included.append(path)
    if sum(p.stat().st_size for p in included) > MAX_TOTAL:
        raise ValueError('Receipt selection exceeds128MiB; review/split explicitly')
    return included, excluded


def verify(out):
    index = json.loads((out/'inventory.json').read_text())
    archive = out/index['archive']['member']
    assert pin(archive) == index['archive']['identity'], 'Archive identity changed'
    expected = {row['member']: row for row in index['members']}
    with tarfile.open(archive, 'r:gz') as stream:
        for member in stream:
            assert member.isfile() and member.name in expected, 'Unexpected or duplicate member'
            row = expected.pop(member.name)
            data = stream.extractfile(member).read()
            assert len(data) == row['bytes'] and digest(data) == row['sha256'], 'Member identity differs'
    assert not expected, 'Archive omitted members'
    # A full gzip read checks footer/CRC even beyond the final tar member.
    with gzip.open(archive, 'rb') as stream:
        while stream.read(1024*1024):
            pass
    return dict(verified=True, members=len(index['members']), archiveBytes=archive.stat().st_size,
                targetsRun=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--plan-only', action='store_true')
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    out = args.out.absolute()
    assert out.resolve() == out and out.is_relative_to(IMPLEMENTATION), 'Evidence output must be inside implementation/phase192'
    if args.verify:
        print(json.dumps(verify(out)))
        return
    files, excluded = inventory(out)
    active = active_guards()
    if args.plan_only:
        print(json.dumps(dict(planOnly=True, targetsRun=False, files=len(files),
            rawBytes=sum(p.stat().st_size for p in files), excludedLarge=excluded,
            activeGuards=active, canPack=not active, out=str(out))))
        return
    assert not out.exists(), 'Fresh evidence destination required'
    assert not active, 'Wait for outer guards to finish: '+', '.join(active)
    raw_bytes = sum(p.stat().st_size for p in files)
    assert shutil.disk_usage(ROOT).free >= 5*1024**3+raw_bytes+16*1024**2, 'Preserve5GiB reserve plus worst-case archive scratch'
    captured = [(p, p.read_bytes()) for p in files]
    rows = [dict(member=str(p.relative_to(ROOT)), bytes=len(data), sha256=digest(data),
                 original=pin(p, data), transformation='verbatim') for p, data in captured]
    out.mkdir(parents=True)
    archive = out/'receipts.tar.gz'
    with archive.open('xb') as raw, gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0, compresslevel=6) as compressed, tarfile.open(fileobj=compressed, mode='w|') as tar:
        for (path, data), row in zip(captured, rows):
            assert path.read_bytes() == data, 'Evidence changed before capture: '+str(path)
            member = tarfile.TarInfo(row['member'])
            member.size, member.mode, member.uid, member.gid, member.mtime = len(data), 0o644, 0, 0, 0
            tar.addfile(member, io.BytesIO(data))
    for path, data in captured:
        assert path.read_bytes() == data, 'Evidence changed during capture: '+str(path)
    assert not active_guards(), 'A target job started during evidence capture'
    index = dict(kind='phase192-bounded-metadata-evidence', complete=True, targetsRun=False,
        method=pin(Path(__file__)), archive=dict(member=archive.name, identity=pin(archive)),
        members=rows, uncompressedBytes=raw_bytes, excludedLarge=excluded,
        excludedClasses=['compiler/source files', 'source-map.json', 'API/JS/C/Bend source',
                         'objects and executables', 'assembly/disassembly', 'raw samples',
                         'preselection/IR dumps', 'retention recovery archives'],
        scope='Byte-exact selected JSON receipts and bounded diagnostic streams; native/compiler products and raw evidence remain hot at their pinned paths. This compact metadata bundle is not a complete historical binary backup or a qualification claim.')
    with (out/'inventory.json').open('x') as stream:
        json.dump(index, stream, indent=2)
        stream.write('\n')
    result = verify(out)
    with (out/'verification.json').open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
