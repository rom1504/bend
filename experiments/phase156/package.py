#!/usr/bin/env python3
"""Seal exact Phase156 evidence after retention closes; never execute targets.

Usage: python3 -B experiments/phase156/package.py --disk-mib 128
The gzip archive stores one payload for each distinct (SHA256, size, mode).
capsule.json records every original path; restore aliases by copying their
payload and applying their mode. Keep that sidecar beside the archive.
External compiler/toolchain pins are evidence, not bundled dependencies.
"""
import argparse
import fcntl
import gzip
import hashlib
import json
import os
import shutil
import stat
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESERVE = 5 * 1024**3
LOCK = ROOT / 'selfhost/build/phase32/execution.lock'
TREES = (
    'selfhost/build/phase156', 'experiments/phase156', 'selfhost/tests/phase156',
    'design/phase156', 'research/phase156', 'implementation/phase156',
    'selfhost/build-retention/phase156', 'selfhost/tools/build',
    'selfhost/tools/build-retention', 'selfhost/src',
)
FILES = (
    'selfhost/tests/phase154/model.bend', 'selfhost/tests/phase154/scalar.bend',
    'selfhost/tests/phase154/lower.bend', 'selfhost/tests/phase154/codec.bend',
    'experiments/phase154/tools/graph.mjs',
    'experiments/phase147/tools/prepare.py', 'selfhost/tools/stage0-library.mjs',
    'selfhost/manifests/assets-native.json', 'implementation/phase152/qualification.json',
    'implementation/phase153/README.md', 'implementation/phase154/README.md',
    'implementation/phase156/README.md', 'implementation/phase156/metrics.json',
    'implementation/phase156/cost.json', 'implementation/phase156/retention.json',
    'implementation/phase152/evidence/capsule.json',
    'implementation/phase154/evidence/capsule.json',
    'implementation/phase155/evidence/capsule.json',
)


class Budget:
    """One archive and its sidecar; no extra uncompressed tar or restoration tree."""
    def __init__(self, limit):
        self.limit, self.written = limit, 0
        require(shutil.disk_usage(ROOT).free >= RESERVE + limit + 1024**2,
                '5 GiB reserve plus explicit archive budget/metadata allowance required')

    def charge(self, size):
        require(self.written + size <= self.limit, 'capsule output exceeds --disk-mib')
        require(shutil.disk_usage(ROOT).free >= RESERVE + size + 1024**2,
                '5 GiB reserve reached during packaging')
        self.written += size


class BudgetWriter:
    def __init__(self, stream, budget):
        self.stream, self.budget = stream, budget

    def write(self, data):
        self.budget.charge(len(data))
        return self.stream.write(data)

    def __getattr__(self, name):
        return getattr(self.stream, name)


def stream_digest(stream):
    digest, size = hashlib.sha256(), 0
    for data in iter(lambda: stream.read(1024 * 1024), b''):
        digest.update(data)
        size += len(data)
    return size, digest.hexdigest()


def sealed_guards(retention):
    rows = {r['guard']: r for r in retention['rows']}
    found = set()
    for path in (ROOT / 'selfhost/build/phase156').rglob('retention.json'):
        state = json.loads(path.read_bytes())
        if state.get('kind') != 'build-retention-run-v1':
            continue
        name = str(path.parent.relative_to(ROOT)); found.add(name)
        require(name in rows and state['state'] == 'sealed' and state['closed'], 'unsealed or unlisted guard: ' + name)
        require(state['closure'] == rows[name]['closure'], 'closure identity differs')
        actual = fingerprint(Path(state['closure']['file']))
        require(all(actual[k] == state['closure'][k] for k in ('bytes', 'sha256')), 'closure receipt changed')
        close = json.loads(Path(state['closure']['file']).read_bytes())
        require(close['complete'] and not close['pruneRequested'] and all(r['keptHot'] for r in close['roots']),
                'Phase156 roots must remain hot until this capsule verifies')
    require(found == set(rows) and len(found) == retention['closedGuards'], 'retention inventory differs')
    for path in (ROOT / 'selfhost/build/phase156').rglob('process.json'):
        process = json.loads(path.read_bytes())
        if process.get('kind') == 'build-retention-disk-guard-v1':
            require(str(path.parent.relative_to(ROOT)) in found, 'guard process lacks a sealed lifecycle')


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
            if path.is_relative_to(out) or path.is_relative_to(ROOT / 'implementation/phase156/evidence'):
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
        if path.suffix != '.json' or path.name.endswith('.graph.json'):
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


def recovery_links(externals):
    """Point to prior exact archive payloads without duplicating historical images."""
    capsules, index = [], {}
    for phase in (152, 154, 155):
        path = ROOT / ('implementation/phase%d/evidence/capsule.json' % phase)
        value = json.loads(path.read_bytes())
        capsules.append(dict(index=fingerprint(path), archive=value['archive']))
        for row in value['payloads'] + value.get('aliases', []):
            index.setdefault((row['bytes'], row['sha256']), []).append(
                dict(capsuleIndex=str(path.relative_to(ROOT)), member=row.get('payload', row['file']),
                     originalPath=row['file']))
    for row in externals:
        matches = index.get((row['bytes'], row['sha256']))
        if matches:
            exact = [m for m in matches if m['originalPath'] == row['file']]
            # One exact-content payload per capsule is sufficient for recovery;
            # do not expand every alias of common/empty historical artifacts.
            selected = {}
            for match in exact or matches:
                selected.setdefault(match['capsuleIndex'], match)
            row['recoveryCandidates'] = list(selected.values())
    return capsules


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk-mib', type=int, required=True,
                        help='Maximum new archive plus sidecar bytes; fixed 5 GiB mount reserve remains')
    parser.add_argument('--out', type=Path, default=ROOT / 'implementation/phase156/evidence')
    parser.add_argument('--compresslevel', type=int, choices=range(1, 10), default=9)
    args = parser.parse_args()
    require(args.disk_mib > 0, 'positive explicit disk budget required')
    budget = Budget(args.disk_mib * 1024**2)
    out = args.out.resolve()
    require(out.is_relative_to(ROOT / 'implementation/phase156/evidence'),
            'output must be implementation/phase156/evidence or one of its subdirectories')
    archive, sidecar = out / 'phase156.tar.gz', out / 'capsule.json'
    require(not archive.exists() and not sidecar.exists(), 'refusing to overwrite evidence')
    retention = json.loads((ROOT / 'implementation/phase156/retention.json').read_bytes())
    require(retention.get('allSealed') is True and retention.get('pruned') is False,
            'close all retention runs without pruning before packaging')
    sealed_guards(retention)
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
    recovery = recovery_links(externals)
    payloads, aliases, known = [], [], {}
    out.mkdir(parents=True, exist_ok=True)
    temporary = out / 'phase156.tar.gz.partial'
    partial_index = out / 'capsule.json.partial'
    require(not temporary.exists() and not partial_index.exists(), 'inspect prior incomplete capsule first')
    try:
        raw = temporary.open('xb')
        with raw, gzip.GzipFile(filename='', fileobj=BudgetWriter(raw, budget), mode='wb',
                               mtime=0, compresslevel=args.compresslevel) as gz:
            with tarfile.open(fileobj=gz, mode='w|') as tar:
                for path, record in zip(files, members):
                    key = (record['sha256'], record['bytes'], record['mode'])
                    if key in known:
                        aliases.append(dict(record, payload=known[key]))
                        continue
                    known[key] = record['file']
                    entry = tarfile.TarInfo(record['file'])
                    entry.mode, entry.size = record['mode'], record['bytes']
                    with path.open('rb') as source:
                        tar.addfile(entry, source)
                    payloads.append(record)
        with temporary.open('rb') as durable:
            os.fsync(durable.fileno())
        expected_members = {r['file']: r for r in payloads}
        with tarfile.open(temporary, 'r:gz') as tar:
            for member in tar:
                require(member.isfile() and member.name in expected_members, 'unexpected archive member')
                record = expected_members.pop(member.name)
                with tar.extractfile(member) as source:
                    size, digest = stream_digest(source)
                require(size == record['bytes'] and member.mode == record['mode'] and
                        digest == record['sha256'], 'archive verification failed')
        require(not expected_members, 'archive members missing')
        # Read to physical gzip EOF as well as tar EOF, authenticating its CRC/footer.
        with gzip.open(temporary, 'rb') as source:
            while source.read(1024 * 1024):
                pass
        require(files == collect(out, qualification), 'input inventory changed during packaging')
        for path, record in zip(files, members):
            require(fingerprint(path) == record, 'input changed during packaging: ' + record['file'])
        archive_record = fingerprint(temporary)
        archive_record['file'] = label(archive)
        result = dict(kind='phase156-evidence-capsule', version=1, verified=True,
                      archive=archive_record, payloads=payloads, aliases=aliases,
                      files=len(members), logicalBytes=sum(r['bytes'] for r in members),
                      payloadBytes=sum(r['bytes'] for r in payloads),
                      requiredQualifiedImage=qualification['selectedNative']['image'],
                      recoveryCapsules=recovery,
                      diskBudgetBytes=budget.limit, diskReserveBytes=RESERVE,
                      referencedExternalPins=externals,
                      externalPinScope='Recorded references not present with matching bytes in this capsule. '
                        'Includes required image/toolchain/upstream assets and historical versions or prior-phase '
                        'evidence; not every reference is a direct execution dependency. These files were not '
                        'bundled or revalidated by packaging. Recovery candidates bind prior capsule indexes, '
                        'archive identities and exact payload hashes; those archives must be authenticated before restoration. '
                        'See each preserved build request/inputs for its dependencies.',
                      restore='Extract payloads, then copy each alias.payload to alias.file and apply alias.mode. '
                        'Verify every payload and alias SHA256/size/mode. Keep capsule.json with the archive.',
                      scope='All Phase156 build files, methods, prototypes, design, reports, audit and retention '
                        'receipts; canonical source/build methods and Phase154 model dependencies. '
                        'No pruning, target execution, or claim of hermetic reproduction.')
        data = (json.dumps(result, indent=2) + '\n').encode()
        with partial_index.open('xb') as handle:
            BudgetWriter(handle, budget).write(data)
            handle.flush()
            os.fsync(handle.fileno())
        # Publish without replacement after both files are written and verified.
        # Partial files remain recoverable if publication is interrupted.
        os.link(temporary, archive)
        os.link(partial_index, sidecar)
        temporary.unlink()
        partial_index.unlink()
    except BaseException:
        # Preserve incomplete evidence; never reclaim input files on a failure.
        raise
    print(json.dumps(dict(archive=result['archive'], files=len(members),
                          payloads=len(payloads), aliases=len(aliases),
                          newOutputBytes=budget.written, diskBudgetBytes=budget.limit)))


if __name__ == '__main__':
    # Serialize maintenance with compiler runs using the existing lock inode.
    require(LOCK.is_file() and LOCK.resolve() == LOCK, 'existing execution lock required')
    with LOCK.open('r') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        inode = LOCK.stat().st_ino
        try:
            main()
            require(LOCK.stat().st_ino == inode, 'execution lock inode changed')
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)
