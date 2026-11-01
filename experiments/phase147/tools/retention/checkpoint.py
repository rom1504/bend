#!/usr/bin/env python3
"""Data-only Phase147 checkpoint. Never executes targets, closes guards or prunes.

Exact small files are stored once by content hash. Large generated products and
profiler bundles remain hot, with their original receipt pins. A checkpoint is
not a full restorable archive or a qualification/promotion certificate.
"""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import tarfile
import time

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase147'
MIB = 1024 ** 2
MAX_TOTAL = 32 * MIB
TEXT = {'.py', '.mjs', '.bend', '.patch', '.c', '.h', '.md', '.before', '.after'}
LOGS = {'.log', '.stdout', '.stderr', '.txt'}


def stable(path):
    before = path.stat()
    data = path.read_bytes()
    after = path.stat()
    fields = ('st_dev', 'st_ino', 'st_size', 'st_mtime_ns', 'st_ctime_ns')
    if any(getattr(before, k) != getattr(after, k) for k in fields):
        raise ValueError('Changed while reading: ' + str(path))
    return data


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def relative(path):
    return str(path.relative_to(ROOT))


def covered(path, roots):
    return any(path == root or root in path.parents for root in roots)


def union_seconds(intervals):
    total, end = 0.0, None
    for start, finish in sorted(intervals):
        if finish < start:
            raise ValueError('Reversed clock interval')
        total += max(0.0, finish - max(start, end if end is not None else start))
        end = finish if end is None else max(finish, end)
    return total


def lane(name):
    if 'profile' in name:
        return 'profiler-build-capture-analysis'
    if 'baseline' in name and 'cold' in name:
        return 'full-baseline'
    if 'pairs' in name or 'time-' in name:
        return 'focused-measurement'
    if 'native' in name:
        return 'focused-native-build'
    if 'api-guard' in name or 'source-check' in name:
        return 'checked-api-acquisition'
    return 'focused-controls-or-capture'


def pins(value, pointer=''):
    if isinstance(value, dict):
        name = value.get('path', value.get('file'))
        if isinstance(name, str) and isinstance(value.get('sha256'), str):
            yield pointer, value
        for key, child in value.items():
            escaped = str(key).replace('~', '~0').replace('/', '~1')
            yield from pins(child, pointer + '/' + escaped)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from pins(child, pointer + '/' + str(index))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--cutoff', type=float, default=None,
                        help='Finished timestamps after this boundary are excluded')
    args = parser.parse_args()
    out = args.out.absolute()
    expected = ROOT / 'implementation/phase147/evidence'
    if out.exists() or not out.is_relative_to(expected) or out.resolve() != out:
        raise ValueError('Fresh unsymlinked implementation/phase147/evidence child required')
    cutoff = args.cutoff if args.cutoff is not None else time.time()
    closed, pending, blocked = [], [], set()
    for path in sorted(RAW.rglob('process.json')):
        if path.is_symlink():
            continue
        data = stable(path)
        obj = json.loads(data)
        if obj.get('kind') != 'build-retention-disk-guard-v1':
            continue
        record = dict(file=relative(path), identity=identity(data), process=obj)
        if isinstance(obj.get('finished'), (int, float)) and obj['finished'] <= cutoff:
            closed.append(record)
        else:
            pending.append(record)
            blocked.add(path.parent)
            blocked.update(Path(x) for x in obj.get('artifactRoots', []))
    objects, files, omitted, parsed, unstable = {}, {}, [], {}, []

    def add(path, reason):
        if path in files or path.is_symlink() or not path.is_file():
            return
        try:
            data = stable(path)
        except (OSError, ValueError) as error:
            unstable.append(dict(file=relative(path), error=str(error)))
            return
        pin = identity(data)
        if pin['sha256'] not in objects:
            if sum(len(v) for v in objects.values()) + len(data) > MAX_TOTAL:
                raise ValueError('Compact checkpoint exceeds 32 MiB; narrow explicit scope')
            objects[pin['sha256']] = data
        files[path] = dict(file=relative(path), **pin, object='objects/' + pin['sha256'], reason=reason)
        if path.suffix == '.json':
            try:
                parsed[path] = json.loads(data)
            except (ValueError, UnicodeError):
                pass

    for record in closed:
        path = ROOT / record['file']
        for child in sorted(path.parent.iterdir()):
            if child.is_file() and child.stat().st_size <= 2*MIB:
                add(child, 'finished-outer-guard')
        if files[path]['sha256'] != record['identity']['sha256']:
            raise ValueError('Finished guard changed during checkpoint')
    scan_roots = [RAW, ROOT/'experiments/phase147', ROOT/'selfhost/tests/phase147']
    for base in scan_roots:
        for path in sorted(base.rglob('*')):
            if not path.is_file() or path.is_symlink() or '__pycache__' in path.parts:
                continue
            if covered(path, blocked):
                continue
            size = path.stat().st_size
            is_log = path.suffix in LOGS or path.name in {'stdout', 'stderr'}
            allowed = ((path.suffix == '.json' and size <= 2*MIB) or
                       (is_log and size <= MIB) or
                       (path.suffix in TEXT and size <= 256*1024))
            if allowed:
                add(path, 'exact-small-evidence-or-current-method-snapshot')
            elif path not in files:
                omitted.append(dict(file=relative(path), bytes=size,
                                    reason='large/generated/binary; original stays hot; not copied or deleted'))
    for path in [ROOT/'AGENTS.md', ROOT/'docs/self_hosted/build-retention.md',
                 ROOT/'selfhost/tools/build-retention/close.py',
                 ROOT/'selfhost/tools/build-retention/guard.py',
                 ROOT/'selfhost/tools/execution.py', ROOT/'selfhost/manifests/current.json',
                 ROOT/'implementation/phase147/baseline.json']:
        add(path, 'policy-or-selected-root-record')
    retained_methods = ROOT/'implementation/phase147/evidence/method-history/inventory.json'
    archive_matches = defaultdict(list)
    if retained_methods.is_file():
        add(retained_methods, 'previously-verified-exact-renderer-method-capsule')
        capsule = json.loads(stable(retained_methods))
        archive = Path(capsule['archive'].get('path', capsule['archive'].get('file')))
        if not archive.is_absolute():
            archive = ROOT/archive
        add(archive, 'previously-verified-exact-renderer-method-capsule')
        if any(files[archive][key] != capsule['archive'][key] for key in ['bytes', 'sha256']):
            raise ValueError('Renderer method archive identity differs')
        expected_members = {row['member']:row for row in capsule['members']}
        with tarfile.open(archive, 'r:xz') as stream:
            members = stream.getmembers()
            if len(members) != len(expected_members):
                raise ValueError('Renderer archive member count differs')
            for member in members:
                if not member.isfile() or member.name not in expected_members:
                    raise ValueError('Unexpected renderer archive member')
                row = expected_members[member.name]
                found = identity(stream.extractfile(member).read())
                if any(found[key] != row[key] for key in ['bytes', 'sha256']):
                    raise ValueError('Renderer archive member identity differs')
                key = row['sha256'] + ':' + str(row['bytes'])
                archive_matches[key].append(dict(archive=relative(archive), member=member.name,
                                                  originalPath=row['originalPath']))
    # Freeze exact small command inputs; historical content may live in method-history.
    for record in closed:
        for _, pin in pins(record['process'].get('method', {})):
            name = pin.get('path', pin.get('file'))
            path = Path(name)
            if not path.is_absolute():
                path = ROOT/path
            if (path.is_relative_to(ROOT) and not covered(path, blocked) and path.is_file()
                    and path.stat().st_size <= 256*1024 and path.suffix in TEXT | {'.json'}):
                add(path, 'current-bytes-of-consumed-small-command-input')
    index = defaultdict(list)
    for entry in files.values():
        index[entry['sha256'] + ':' + str(entry['bytes'])].append(entry['file'])
    references = []
    for path, obj in sorted(parsed.items()):
        for pointer, pin in pins(obj):
            key = pin['sha256'] + ':' + str(pin.get('bytes'))
            references.append(dict(receipt=relative(path), pointer=pointer, declared=pin,
                                   exactExportContentKey=key if key in index else None,
                                   exactArchiveContentKey=key if key in archive_matches else None))
    rows, intervals, categories = [], [], defaultdict(list)
    for record in closed:
        process = record['process']
        start, finish = process['started'], process['finished']
        interval = (start, finish)
        intervals.append(interval)
        category = lane(record['file'])
        categories[category].append(interval)
        success = process.get('complete') is True and process.get('returncode') == 0
        guard = str(Path(record['file']).parent)
        classification = 'completed' if success else 'failed'
        command = ['python3', '-B', 'selfhost/tools/build-retention/close.py', '--run', guard,
                   '--out', 'selfhost/build-retention/phase147/' + guard.split('phase147/',1)[1].replace('/','--'),
                   '--classification', classification]
        for root in process['artifactRoots']:
            command += ['--keep-root', root]
        rows.append(dict(guard=guard, processIdentity=record['identity'], category=category,
                         started=start, finished=finish, elapsedSeconds=finish-start,
                         complete=process.get('complete'), returncode=process.get('returncode'),
                         stoppedFor=process.get('stoppedFor'), artifactRoots=process['artifactRoots'],
                         proposedClassification=classification, classificationExecuted=False,
                         allRootsKeepHot=True, reviewOnlyCloseArgv=command,
                         peakTreeRssBytes=process.get('peakTreeRssBytes')))
    wall_span = max((b for _, b in intervals), default=cutoff)-min((a for a, _ in intervals), default=cutoff)
    total = union_seconds(intervals)
    report = dict(kind='phase147-retention-checkpoint-v1', complete=True, dataOnly=True,
                  targetExecuted=False, archiveExecuted=False, pruningExecuted=False,
                  cutoff=cutoff, created=time.time(), method=files[Path(__file__).resolve()],
                  guardCount=len(rows), guardOutcomes=dict(Counter(r['proposedClassification'] for r in rows)),
                  pendingGuards=[dict(file=r['file'], identity=r['identity'], status='unfinished-or-after-cutoff') for r in pending],
                  cost=dict(outerGuardElapsedSumSeconds=sum(b-a for a,b in intervals),
                            outerGuardIntervalUnionSeconds=total, nestedChildSecondsAdded=0,
                            firstStartToLastFinishSeconds=wall_span, uncoveredSpanSeconds=wall_span-total,
                            categories={k:dict(guards=len(v),intervalUnionSeconds=union_seconds(v)) for k,v in categories.items()},
                            scope='Only finished outer disk guards; includes harness/build/check work. No CPU billing, performance ratio, or full campaign wall claim. Category unions can overlap.'),
                  guards=rows, files=list(files.values()), exactObjects=len(objects),
                  exportedUniqueBytes=sum(len(x) for x in objects.values()), omittedHotFiles=omitted,
                  unstableReads=unstable,
                  protectedPolicy=dict(allRawRootsRemainHot=True, selectedManifest='selfhost/manifests/current.json',
                    selectedN1N2=True, fullBaseline=True, allProfilerImagesMapsSamples=True,
                    sharedLock='selfhost/build/phase32/execution.lock',
                    promotion='No qualified/rejected decision inferred from successful command.'),
                  limitations=['Not a full archive. Omitted source/binary/profiler bytes remain required hot dependencies.',
                    'Exact export matches identify retained bytes; unmatched pins may be large, external, historical or intentionally invalid negative-control values.',
                    'Current method snapshots are not retroactively claimed as historical consumed methods. Receipt identities and matching history preserve that distinction.',
                    'No run is closed by this tool. Suggested close commands retain every declared root and require root review.',
                    'Active guards/artifacts are excluded. Unguarded small files are stable-read snapshots, not declarations that their owner has closed them.'])
    out.mkdir(parents=True)
    (out/'objects').mkdir()
    for digest, data in objects.items():
        path=out/'objects'/digest
        with path.open('xb') as stream:
            stream.write(data)
        if identity(path.read_bytes())['sha256'] != digest:
            raise ValueError('Export roundtrip mismatch')
    for name, data in [('report.json', report), ('references.json', dict(occurrences=references, contentMatches=index,
                                                                      archiveContentMatches=archive_matches))]:
        with (out/name).open('x') as stream:
            json.dump(data, stream, indent=2)
            stream.write('\n')
    print(json.dumps({k:report[k] for k in ['guardCount','guardOutcomes','exportedUniqueBytes','exactObjects']}))


if __name__ == '__main__':
    main()
