#!/usr/bin/env python3
"""Plan/seal bounded Phase112 receipts, preserving failures and exact identities.

No compiler/target execution, source edits, pruning or deletion. Run plan first;
seal requires its frozen plan and fresh output names. Source/API/IR/binary files
never become archive payloads. Hash-only entries cannot justify deleting inputs.
"""
import argparse
import collections
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import stat
import tarfile
import time

ROOT = Path(__file__).resolve().parents[4]
EVIDENCE = ROOT / 'implementation/phase112/evidence'
SOURCE = {'.bend', '.mjs', '.js', '.py', '.c', '.h', '.ts', '.sh', '.md'}
ARTIFACT = {'.ssa', '.ll', '.s', '.o', '.a', '.so', '.program', '.exe', '.bc'}
LOG = {'.log', '.stdout', '.stderr', '.jsonl'}
JSON_LIMIT = 16 * 1024**2
LOG_LIMIT = 64 * 1024
RAW_LIMIT = 64 * 1024**2
ARCHIVE_LIMIT = 8 * 1024**2
SOURCE_LIMIT = 8 * 1024**2


def encoded(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False) + '\n').encode()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def state(path):
    value = path.lstat()
    if not stat.S_ISREG(value.st_mode):
        raise ValueError('regular input required: ' + str(path))
    return (value.st_dev, value.st_ino, value.st_size, value.st_mtime_ns)


def pin(path):
    before = state(path)
    value = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(1024 * 1024):
            value.update(block)
    if state(path) != before:
        raise ValueError('input changed while hashing: ' + str(path))
    return dict(file=str(path.relative_to(ROOT)), bytes=before[2], sha256=value.hexdigest())


def checked(path):
    path = Path(path)
    path = path if path.is_absolute() else ROOT / path
    if '..' in path.parts or not path.is_relative_to(ROOT):
        raise ValueError('repository path required: ' + str(path))
    current = ROOT
    for part in path.relative_to(ROOT).parts:
        current /= part
        if current.is_symlink():
            raise ValueError('symlink input refused: ' + str(current))
    state(path)
    return path


def files(directory):
    if directory.is_file():
        yield checked(directory)
        return
    if not directory.is_dir() or directory.is_symlink():
        raise ValueError('missing/nonregular evidence scope: ' + str(directory))
    for base, dirs, names in os.walk(directory, followlinks=False):
        parent = Path(base)
        dirs[:] = sorted(x for x in dirs if x != '__pycache__' and parent / x != EVIDENCE)
        for name in dirs:
            if (parent / name).is_symlink():
                raise ValueError('symlink directory refused')
        for name in sorted(names):
            yield checked(parent / name)


def scopes():
    output = [ROOT / 'selfhost/build/phase112']
    output += sorted((ROOT / 'selfhost/build/phase111').glob('p112-*'))
    return output


def refs(value, pointer=''):
    if isinstance(value, dict):
        name = value.get('file', value.get('path'))
        sha = value.get('sha256')
        size = value.get('bytes')
        if isinstance(name, str) and isinstance(sha, str) and len(sha) == 64 and isinstance(size, int):
            yield pointer or '/', dict(file=name, bytes=size, sha256=sha)
        for key, child in value.items():
            yield from refs(child, pointer + '/' + str(key).replace('~', '~0').replace('/', '~1'))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from refs(child, pointer + '/' + str(index))


def capture(path, mode, limit):
    if mode == 'exact':
        return path.read_bytes()
    if mode == 'head-tail':
        half = limit // 2
        size = path.stat().st_size
        with path.open('rb') as stream:
            head = stream.read(half)
            stream.seek(max(0, size - half))
            tail = stream.read(half)
        omitted = max(0, size - len(head) - len(tail))
        return head + f'\n[Phase112 evidence excerpt: {omitted} original bytes omitted]\n'.encode() + tail
    raise ValueError('unknown capture mode')


def summary(documents):
    reports, guards = [], []
    keys = ('kind', 'complete', 'passed', 'checked', 'status', 'returncode', 'error',
            'diagnostic', 'seconds', 'wallSeconds', 'nativeSeconds', 'compilerSeconds',
            'buildSeconds', 'mode', 'scope', 'summary', 'gates')
    for name, document in sorted(documents.items()):
        if not isinstance(document, dict):
            continue
        if Path(name).name in {'report.json', 'process.json'}:
            reports.append(dict(file=name, facts={k: document[k] for k in keys if k in document}))
        if Path(name).name == 'process.json':
            guards.append(dict(file=name, **{k: document[k] for k in
                ('complete', 'returncode', 'started', 'finished', 'wallSeconds', 'peakTreeRssBytes') if k in document}))
    return dict(kind='phase112-retained-evidence-summary', reports=reports, guards=guards,
                guardReturncodes=dict(collections.Counter(str(x.get('returncode', 'unknown')) for x in guards)),
                scope='Receipts include failed, incomplete and superseded attempts. Nested and outer clocks overlap; no totals, qualified-test count, speedup, or promotion claim is inferred.')


def build_plan():
    roots = scopes()
    observed = {}
    documents = {}
    entries = []
    unique = {}
    for path in sorted({p for root in roots for p in files(root)}):
        relative = str(path.relative_to(ROOT))
        size = path.stat().st_size
        suffix = path.suffix
        # Large machine products remain excluded even if a caller renamed one
        # with a log-like suffix. Their receipt pins are retained separately.
        with path.open('rb') as stream:
            magic = stream.read(4)
        if suffix in ARTIFACT or magic == b'\x7fELF' or magic[:2] == b'MZ' or path.name in {'program', 'compiler'}:
            entries.append(dict(file=relative, bytes=size, payload=False,
                                reason='generated machine artifact; recorded receipt identities only'))
            continue
        if suffix == '.json':
            if size > JSON_LIMIT:
                raise ValueError('JSON receipt exceeds16MiB; preserve/partition explicitly before sealing: ' + relative)
            mode = 'exact'
        elif suffix in LOG or path.name in {'stdout', 'stderr', 'stdout.log', 'stderr.log'}:
            mode = 'exact' if size <= LOG_LIMIT else 'head-tail'
        elif suffix in SOURCE:
            entry = pin(path)
            observed[relative] = entry
            entries.append(dict(**entry, payload=False, reason='source/API identity only'))
            continue
        else:
            entries.append(dict(file=relative, bytes=size, payload=False, reason='unclassified artifact; no payload'))
            continue
        identity = pin(path)
        payload = capture(path, mode, LOG_LIMIT)
        if pin(path) != identity:
            raise ValueError('input changed during capture: ' + relative)
        blob = digest(payload)
        observed[relative] = identity
        entries.append(dict(**identity, payload=True, capture=mode, captureLimit=LOG_LIMIT,
                            payloadBytes=len(payload), payloadSha256=blob,
                            reason='exact receipt/log including failures' if mode == 'exact' else 'explicit bounded log excerpt; complete original remains local'))
        unique[blob] = len(payload)
        if suffix == '.json':
            try:
                documents[relative] = json.loads(payload)
            except (UnicodeError, ValueError) as error:
                entries[-1]['parseError'] = str(error)
    # Current tool/source identities are retained, never their contents. The
    # archived run receipts identify which frozen versions actually executed.
    for root in (ROOT / 'selfhost/tools/performance/phase112', ROOT / 'implementation/phase112'):
        for path in sorted(files(root)):
            if path.suffix not in SOURCE:
                continue
            relative = str(path.relative_to(ROOT))
            if relative not in observed:
                entry = pin(path)
                observed[relative] = entry
                entries.append(dict(**entry, payload=False, reason='current source/document identity only; historical run pins remain separate'))
    references = []
    for receipt, document in sorted(documents.items()):
        for pointer, expected in refs(document):
            row = dict(receipt=receipt, pointer=pointer, expected=expected)
            source = Path(expected['file'])
            source = source if source.is_absolute() else ROOT / source
            if not source.is_relative_to(ROOT) or '..' in source.parts:
                row['disposition'] = 'external tool identity from receipt; not read'
            else:
                name = str(source.relative_to(ROOT))
                actual = observed.get(name)
                if actual is None and source.suffix in SOURCE and expected['bytes'] <= SOURCE_LIMIT and source.is_file():
                    try:
                        actual = pin(checked(source))
                        observed[name] = actual
                        entries.append(dict(**actual, payload=False, reason='direct source/API dependency identity only; no recursive source scan'))
                    except (OSError, ValueError) as error:
                        row['diagnostic'] = str(error)
                if actual is not None:
                    row['matchesCurrent'] = all(actual[k] == expected[k] for k in ('bytes', 'sha256'))
                    row['observed'] = actual
                    row['disposition'] = 'verified source/API/receipt identity' if row['matchesCurrent'] else 'historical identity differs from current file; both retained'
                else:
                    row['disposition'] = 'receipt identity retained; payload and current-content verification excluded'
            references.append(row)
    raw = sum(unique.values())
    if raw > RAW_LIMIT:
        raise ValueError(f'Unique receipt/log payload exceeds64MiB: {raw}')
    return dict(kind='phase112-bounded-evidence-plan', complete=True, targetsRun=False,
                createdUtc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                roots=[str(p.relative_to(ROOT)) for p in roots], method=pin(Path(__file__).resolve()),
                limits=dict(jsonBytes=JSON_LIMIT, logBytes=LOG_LIMIT, rawPayloadBytes=RAW_LIMIT, archiveBytes=ARCHIVE_LIMIT),
                files=sorted(entries, key=lambda r: r['file']), references=references,
                uniquePayloadBytes=raw, summary=summary(documents),
                scope='Exact bounded JSON receipts and stdout/stderr/log captures, including failures. No generated binary/API/source/IR/assembly payload. Hash-only or excerpt entries do not support deleting originals.')


def fresh(path):
    path = path.resolve()
    if path.exists() or not path.is_relative_to(EVIDENCE):
        raise ValueError('Fresh path under implementation/phase112/evidence required')
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


class LimitedWriter:
    def __init__(self, stream, cap):
        self.stream, self.cap, self.count = stream, cap, 0
    def write(self, data):
        if self.count + len(data) > self.cap:
            raise ValueError('Compressed evidence exceeds8MiB cap; no archive promoted')
        self.count += len(data)
        return self.stream.write(data)
    def flush(self):
        return self.stream.flush()
    def tell(self):
        return self.count


def add(archive, name, data):
    item = tarfile.TarInfo(name)
    item.size, item.mode, item.mtime, item.uid, item.gid = len(data), 0o644, 0, 0, 0
    archive.addfile(item, io.BytesIO(data))


def seal(plan_path, output):
    plan_raw = plan_path.read_bytes()
    plan = json.loads(plan_raw)
    if plan.get('kind') != 'phase112-bounded-evidence-plan' or not plan.get('complete'):
        raise ValueError('Complete Phase112 plan required')
    if pin(Path(__file__).resolve()) != plan['method']:
        raise ValueError('Sealing method changed since plan')
    temporary = output.with_name(output.name + '.partial')
    manifest_path = output.with_name(output.name + '.manifest.json')
    summary_path = output.with_name(output.name + '.summary.json')
    if any(path.exists() for path in (temporary, manifest_path, summary_path)):
        raise ValueError('Fresh archive companions required')
    report = dict(kind='phase112-bounded-evidence-capsule', complete=False,
                  plan=dict(file=str(plan_path.relative_to(ROOT)), sha256=digest(plan_raw)),
                  method=plan['method'], limits=plan['limits'], allPayloadsVerified=False)
    try:
        included = {}
        with temporary.open('xb') as raw:
            bounded = LimitedWriter(raw, ARCHIVE_LIMIT)
            with gzip.GzipFile(fileobj=bounded, mode='wb', compresslevel=6, mtime=0, filename='') as compressed:
                with tarfile.open(fileobj=compressed, mode='w|') as archive:
                    add(archive, 'index.json', encoded(plan))
                    for row in plan['files']:
                        if 'sha256' in row:
                            actual = pin(checked(row['file']))
                            if any(actual[key] != row[key] for key in ('file', 'bytes', 'sha256')):
                                raise ValueError('Frozen input changed since plan: ' + row['file'])
                        if not row['payload']:
                            continue
                        payload = capture(checked(row['file']), row['capture'], row['captureLimit'])
                        if len(payload) != row['payloadBytes'] or digest(payload) != row['payloadSha256']:
                            raise ValueError('Capture changed: ' + row['file'])
                        sha = row['payloadSha256']
                        if sha not in included:
                            add(archive, 'blobs/sha256/' + sha, payload)
                            included[sha] = len(payload)
                    add(archive, 'summary.json', encoded(plan['summary']))
        # Reopen the bytes actually written and verify every archived blob.
        with tarfile.open(temporary, 'r:gz') as archive:
            expected = {'index.json': encoded(plan), 'summary.json': encoded(plan['summary'])}
            seen = set()
            for item in archive:
                if not item.isfile() or item.name in seen:
                    raise ValueError('Invalid or duplicate archive member')
                seen.add(item.name)
                content = archive.extractfile(item).read()
                if item.name in expected:
                    if content != expected[item.name]:
                        raise ValueError('Archive metadata mismatch')
                else:
                    sha = item.name.removeprefix('blobs/sha256/')
                    if sha not in included or digest(content) != sha or len(content) != included[sha]:
                        raise ValueError('Archive payload mismatch: ' + item.name)
            if seen != set(expected) | {'blobs/sha256/' + sha for sha in included}:
                raise ValueError('Archive members missing')
        # Preserve a failed partial archive rather than pruning evidence.
        os.replace(temporary, output)
        report.update(complete=True, archive=pin(output), allPayloadsVerified=True,
                      includedPaths=sum(r['payload'] for r in plan['files']),
                      uniquePayloads=len(included), uniquePayloadBytes=sum(included.values()),
                      excerpts=sum(r.get('capture') == 'head-tail' for r in plan['files']),
                      restore='index.json maps exact payloads and explicit excerpts to blobs/sha256/HASH. Only exact captures restore complete original bytes. Source/API and machine products are identity-only and stay local; no deletion authorized.')
        manifest_path.write_bytes(encoded(report))
        summary_path.write_bytes(encoded(plan['summary']))
        print(json.dumps(report))
    except BaseException as error:
        report['error'] = repr(error)
        manifest_path.write_bytes(encoded(report))
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    plan_parser = commands.add_parser('plan')
    plan_parser.add_argument('--out', type=Path, required=True)
    seal_parser = commands.add_parser('seal')
    seal_parser.add_argument('--plan', type=Path, required=True)
    seal_parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'plan':
        output = fresh(args.out)
        plan = build_plan()
        output.write_bytes(encoded(plan))
        print(json.dumps(dict(complete=True, plan=str(output), files=len(plan['files']),
                              uniquePayloadBytes=plan['uniquePayloadBytes'], excerpts=sum(x.get('capture') == 'head-tail' for x in plan['files']))))
    else:
        seal(checked(args.plan), fresh(args.out))


if __name__ == '__main__':
    main()
