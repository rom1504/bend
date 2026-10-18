#!/usr/bin/env python3
"""Plan or seal bounded Phase111 evidence. Never builds, runs, deletes or prunes targets."""
import argparse
import collections
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[4]
SCOPES = ('selfhost/build/phase111', 'selfhost/tools/performance/phase111',
          'implementation/phase111')
EVIDENCE = ROOT / 'implementation/phase111/evidence'
MANDATORY = (
    'selfhost/build/phase111/full-source05/compiler.bend',
    'selfhost/build/phase111/full-source05/modules.bend',
    'selfhost/build/phase111/full-source05/manifest.json',
    'selfhost/build/phase111/full-api05/api.mjs',
    'selfhost/build/phase111/full-api05/report.json',
    'selfhost/build/phase111/runtime-source03/runtime.c',
    'selfhost/build/phase111/runtime-source03/runtime.h',
    'selfhost/build/phase111/runtime-source03/primitives.h',
    'selfhost/build/phase111/runtime-source03/manifest.json',
)
SOURCE = {'.bend', '.py', '.mjs', '.js', '.c', '.h', '.sh', '.md', '.txt'}
DEPENDENCY_SOURCE = {'.bend', '.py', '.mjs', '.js', '.c', '.h', '.sh'}
RECEIPT = {'.json', '.jsonl', '.log', '.stdout', '.stderr'}
COMPILED = {'.s', '.o', '.a', '.so', '.program', '.exe'}
SMALL_LIMIT = 2 * 1024**2
SOURCE_LIMIT = 4 * 1024**2
RAW_LIMIT = 64 * 1024**2
ARCHIVE_LIMIT = 6 * 1024**2
DEPENDENCY_PREFIXES = ('selfhost/src/', 'selfhost/tools/', 'selfhost/build/phase',
                       'selfhost/.bootstrap/upstream-phase66/bend2/', 'bend2/')


def mandatory_snapshots():
    extra = ()
    if (ROOT / 'selfhost/build/phase111/runtime-source04').exists():
        extra = tuple('selfhost/build/phase111/runtime-source04/' + name
                      for name in ('runtime.c', 'runtime.h', 'primitives.h', 'manifest.json'))
    return MANDATORY + extra


def encoded(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False) + '\n').encode()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    h = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
            size += len(block)
    return dict(file=str(path.relative_to(ROOT)), bytes=size, sha256=h.hexdigest())


def number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def inventory():
    files = []
    for name in SCOPES:
        directory = ROOT / name
        if not directory.is_dir():
            raise ValueError('missing evidence scope: ' + name)
        for base, dirs, names in os.walk(directory, followlinks=False):
            parent = Path(base)
            dirs[:] = sorted(d for d in dirs if d != '__pycache__' and parent / d != EVIDENCE)
            if any((parent / d).is_symlink() for d in dirs):
                raise ValueError('symlink directory in evidence scope')
            for name in sorted(names):
                path = parent / name
                if path.is_symlink() or not path.is_file():
                    raise ValueError('non-regular evidence input: ' + str(path))
                files.append(path)
    files.sort()
    if len(files) != len(set(files)):
        raise ValueError('overlapping evidence scope')
    if not all(ROOT / name in files for name in mandatory_snapshots()):
        raise ValueError('missing mandatory frozen source/API/runtime snapshot')
    return files


def select(path, record):
    relative = record['file']
    if relative in mandatory_snapshots():
        return True, 'mandatory frozen source/API/runtime'
    with path.open('rb') as stream:
        magic = stream.read(4)
    if path.suffix in COMPILED or magic == b'\x7fELF' or magic[:2] == b'MZ':
        return False, 'compiled artifact retained locally; identity only'
    if path.suffix in RECEIPT or path.name in {'stdout', 'stderr', 'method', 'inputs'}:
        return True, 'receipt/log including incomplete and failed attempts'
    if path.suffix in SOURCE and record['bytes'] <= SOURCE_LIMIT:
        return True, 'source/method snapshot'
    if path.suffix in {'.ssa', '.ll'} and record['bytes'] <= SMALL_LIMIT:
        return True, 'bounded generated fixture IR'
    return False, 'large or unclassified artifact retained locally; identity only'


def references(value, pointer=''):
    if isinstance(value, dict):
        field = 'file' if isinstance(value.get('file'), str) else 'path'
        if (isinstance(value.get(field), str) and isinstance(value.get('sha256'), str)
                and len(value['sha256']) == 64 and number(value.get('bytes'))):
            yield pointer or '/', dict(file=value[field], bytes=value['bytes'],
                                       sha256=value['sha256'], identityField=field)
        for key, child in value.items():
            yield from references(child, pointer + '/' + str(key).replace('~', '~0').replace('/', '~1'))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from references(child, pointer + '/' + str(index))


def receipt_summary(documents):
    rows, guards = [], []
    kinds, seconds_by_kind = collections.Counter(), collections.Counter()
    flags = ('complete', 'passed', 'checked', 'prepared', 'targetsRun', 'perProgramC',
             'cproc', 'cachedRuntime', 'mode', 'status', 'returncode', 'error',
             'scope', 'seconds', 'wallSeconds', 'buildSeconds', 'summary')
    for name, doc in sorted(documents.items()):
        if not name.startswith('selfhost/build/phase111/') or not isinstance(doc, dict):
            continue
        if Path(name).name == 'report.json':
            kind = str(doc.get('kind', '<unspecified>'))
            kinds[kind] += 1
            if number(doc.get('seconds')):
                seconds_by_kind[kind] += doc['seconds']
            row = dict(receipt=name, kind=kind, facts={k: doc[k] for k in flags if k in doc})
            cases = doc.get('rows')
            if isinstance(cases, list):
                row['rowCount'] = len(cases)
                row['rowStatusCounts'] = dict(collections.Counter(str(x.get('status', '<unspecified>')) for x in cases if isinstance(x, dict)))
                row['explicitTrueCounts'] = {k: sum(isinstance(x, dict) and x.get(k) is True for x in cases)
                    for k in ('compiled', 'built', 'executed', 'semanticPass', 'expectedRefusal')}
            rows.append(row)
        if Path(name).name == 'process.json' and ('-guard/' in name or '/guard/' in name):
            guards.append(dict(receipt=name, **{k: doc[k] for k in
                ('complete', 'returncode', 'started', 'finished', 'wallSeconds',
                 'peakTreeRssBytes', 'minimumAvailableBytes') if k in doc}))
    intervals = sorted((g['started'], g['finished']) for g in guards
                       if number(g.get('started')) and number(g.get('finished')) and g['finished'] >= g['started'])
    union = 0
    end = None
    for start, stop in intervals:
        union += stop - max(start, end if end is not None else start) if end is None or stop > end else 0
        end = max(stop, end if end is not None else stop)
    return dict(kind='phase111-evidence-facts', receiptCount=len(rows), receiptKinds=dict(kinds),
        receipts=rows, guards=guards, guardCount=len(guards),
        guardReturncodes=dict(collections.Counter(str(g.get('returncode', '<unspecified>')) for g in guards)),
        recordedGuardWallSeconds=sum(g['wallSeconds'] for g in guards if number(g.get('wallSeconds'))),
        guardTimestampUnionSeconds=union,
        recordedTopLevelReceiptSecondsByKind=dict(seconds_by_kind),
        countingScope='Every archived report is represented, including failures and superseded attempts. Row counts are per receipt, not distinct tests. Top-level receipt seconds and guard wall seconds overlap and must not be added; timestamp union covers only recorded guard intervals. No aggregate qualified-test count or self-host claim is inferred.')


def build_plan():
    files = inventory()
    records, documents, skipped_json = {}, {}, []
    for path in files:
        record = pin(path)
        include, reason = select(path, record)
        records[record['file']] = dict(**record, archived=include, reason=reason)
        if path.suffix == '.json':
            try:
                documents[record['file']] = json.loads(path.read_text())
            except (ValueError, UnicodeError) as error:
                skipped_json.append(dict(file=record['file'], reason=str(error)))
    refs = []
    # Only direct pinned references in Phase111 JSON. No recursive prior-phase scan.
    for receipt, doc in sorted(documents.items()):
        for pointer, expected in references(doc):
            original = Path(expected['file'])
            path = original if original.is_absolute() else ROOT / original
            resolved = path.resolve()
            entry = dict(receipt=receipt, pointer=pointer, expected=expected)
            if not resolved.is_relative_to(ROOT):
                entry['disposition'] = 'external tool/platform identity only'
            elif not resolved.is_file() or path.is_symlink():
                entry['disposition'] = 'missing or symlink reference; recorded identity only'
            else:
                name = str(resolved.relative_to(ROOT))
                actual = records.get(name)
                if (actual is None and name.startswith(DEPENDENCY_PREFIXES)
                        and resolved.suffix in DEPENDENCY_SOURCE and expected['bytes'] <= SOURCE_LIMIT):
                    observed = pin(resolved)
                    if all(observed[k] == expected[k] for k in ('bytes', 'sha256')):
                        records[name] = dict(**observed, archived=True,
                            reason='direct pinned source/method dependency; no transitive scan')
                        actual = records[name]
                    else:
                        entry['observed'] = observed
                if actual is not None:
                    entry['matchesCurrent'] = all(actual[k] == expected[k] for k in ('bytes', 'sha256'))
                    entry['disposition'] = 'captured source' if actual['archived'] and entry['matchesCurrent'] else 'identity only or changed live version'
                else:
                    entry['disposition'] = 'non-source dependency identity only'
            refs.append(entry)
    # The required acquisition receipts must pin the mandatory current products.
    full = documents['selfhost/build/phase111/full-source05/manifest.json']
    api = documents['selfhost/build/phase111/full-api05/report.json']
    runtime = documents['selfhost/build/phase111/runtime-source03/manifest.json']
    expected_products = [full['source'], api['api'], *runtime['outputs']]
    if 'selfhost/build/phase111/runtime-source04/manifest.json' in documents:
        expected_products.extend(documents['selfhost/build/phase111/runtime-source04/manifest.json']['outputs'])
    for expected in expected_products:
        path = Path(expected['file'])
        path = path if path.is_absolute() else ROOT / path
        name = str(path.resolve().relative_to(ROOT))
        actual = records.get(name)
        if actual is None or any(actual[k] != expected[k] for k in ('bytes', 'sha256')):
            raise ValueError('mandatory acquisition identity differs: ' + name)
    included = [x for x in records.values() if x['archived']]
    blobs = {}
    for entry in included:
        old = blobs.setdefault(entry['sha256'], entry)
        if old['bytes'] != entry['bytes']:
            raise ValueError('inconsistent content address')
    raw = sum(row['bytes'] for row in blobs.values())
    if raw > RAW_LIMIT:
        raise ValueError('unique uncompressed payload exceeds 64 MiB; narrow explicit scope')
    summary = receipt_summary(documents)
    summary['unparsedJson'] = skipped_json
    plan = dict(kind='phase111-evidence-seal-plan', version=1, scopes=list(SCOPES),
        mandatory=list(mandatory_snapshots()), limits=dict(rawBytes=RAW_LIMIT, archiveBytes=ARCHIVE_LIMIT,
        smallIrBytes=SMALL_LIMIT, sourceBytes=SOURCE_LIMIT),
        files=[records[k] for k in sorted(records)], references=refs,
        includedPaths=len(included), uniquePayloads=len(blobs), uniquePayloadBytes=raw,
        hashOnlyPaths=sum(not x['archived'] for x in records.values()),
        summary=summary,
        restore='Content-addressed payloads are under blobs/sha256/HASH. index.json maps repository-relative original paths to hashes. Restore into a new empty checkout or staging directory, verify hashes, then copy only validated missing destinations. Never overwrite live source or tools. Hash-only artifacts stay local; no deletion or pruning is performed.')
    return plan


def add_bytes(archive, name, data):
    info = tarfile.TarInfo(name)
    info.size = len(data)
    info.mode = 0o644
    info.mtime = 0
    archive.addfile(info, io.BytesIO(data))


class LimitedWriter:
    """Enforce the compressed limit before writing, even for a large log blob."""
    def __init__(self, stream):
        self.stream = stream

    def write(self, data):
        if self.stream.tell() + len(data) > ARCHIVE_LIMIT:
            raise ValueError('compressed capsule exceeds 6 MiB')
        return self.stream.write(data)

    def __getattr__(self, name):
        return getattr(self.stream, name)


def seal(plan, plan_hash, out):
    if not out.is_relative_to(EVIDENCE) or not str(out).endswith('.tar.xz'):
        raise ValueError('output must be a fresh implementation/phase111/evidence/*.tar.xz')
    manifest_path = Path(str(out) + '.manifest.json')
    summary_path = Path(str(out) + '.summary.json')
    partial = Path(str(out) + '.partial')
    if any(p.exists() for p in (out, manifest_path, summary_path, partial)):
        raise ValueError('seal destinations must all be fresh')
    if shutil.disk_usage(ROOT).free < ARCHIVE_LIMIT + 2 * 1024**2:
        raise ValueError('less than archive bound plus 2 MiB free space')
    out.parent.mkdir(parents=True, exist_ok=True)
    index = encoded(dict(planSha256=plan_hash, **{k: v for k, v in plan.items() if k != 'summary'}))
    summary = encoded(plan['summary'])
    expected = {'index.json': (len(index), digest(index)), 'summary.json': (len(summary), digest(summary))}
    blobs = {row['sha256']: row for row in plan['files'] if row['archived']}
    try:
        with partial.open('xb') as stream, tarfile.open(fileobj=LimitedWriter(stream), mode='w:xz', preset=6) as archive:
            add_bytes(archive, 'index.json', index)
            add_bytes(archive, 'summary.json', summary)
            for sha, row in sorted(blobs.items()):
                name = 'blobs/sha256/' + sha
                info = tarfile.TarInfo(name)
                info.size = row['bytes']
                info.mode = 0o644
                info.mtime = 0
                with (ROOT / row['file']).open('rb') as source:
                    archive.addfile(info, source)
                expected[name] = (row['bytes'], sha)
                if stream.tell() > ARCHIVE_LIMIT:
                    raise ValueError('compressed capsule exceeds 6 MiB')
        if partial.stat().st_size > ARCHIVE_LIMIT:
            raise ValueError('compressed capsule exceeds 6 MiB')
        seen = set()
        with tarfile.open(partial, 'r:xz') as archive:
            for member in archive:
                if not member.isfile() or member.name not in expected or member.name in seen:
                    raise ValueError('unexpected archived member')
                stream = archive.extractfile(member)
                h = hashlib.sha256()
                length = 0
                for block in iter(lambda: stream.read(1024 * 1024), b''):
                    h.update(block)
                    length += len(block)
                if (length, h.hexdigest()) != expected[member.name]:
                    raise ValueError('archive member hash differs: ' + member.name)
                seen.add(member.name)
        if seen != set(expected) or digest(encoded(build_plan())) != plan_hash:
            raise ValueError('evidence changed during sealing; no capsule published')
        partial.rename(out)
    except BaseException:
        if partial.exists():
            partial.unlink()  # Only this invocation's unpublished partial output.
        raise
    report = dict(kind='phase111-evidence-capsule', complete=True, planSha256=plan_hash,
        method=pin(Path(__file__)), archive=pin(out), allMembersVerified=True,
        includedPaths=plan['includedPaths'], uniquePayloads=len(blobs),
        uniquePayloadBytes=plan['uniquePayloadBytes'], hashOnlyPaths=plan['hashOnlyPaths'],
        sourceInputsUnchanged=True, restores=plan['restore'])
    with manifest_path.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    with summary_path.open('xb') as stream:
        stream.write(summary)
    print(json.dumps(report, sort_keys=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--plan', action='store_true', help='read-only full inventory to stdout')
    mode.add_argument('--seal', action='store_true', help='write after coordinator validates exact inventory')
    parser.add_argument('--expect-plan-sha256')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    plan = build_plan()
    sha = digest(encoded(plan))
    if args.plan:
        if args.out or args.expect_plan_sha256:
            parser.error('--plan writes only stdout; no --out or expected hash')
        print(json.dumps(dict(planSha256=sha, plan=plan), indent=2))
    else:
        if not args.out or args.expect_plan_sha256 != sha:
            parser.error('--seal requires --out and the exact current validated --expect-plan-sha256')
        seal(plan, sha, args.out.resolve())


if __name__ == '__main__':
    main()
