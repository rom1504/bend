#!/usr/bin/env python3
"""Snapshot bounded Phase140 evidence and exact identity references; no targets.

Default roots are completed component/session metadata. --root adds later
Phase140 native receipt directories (including p140-prefixed build phases).
Payload exclusions are explicit; hashes are not substituted for missing bytes.
"""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import tarfile

ROOT = Path(__file__).resolve().parents[4]
PHASE = ROOT / 'selfhost/build/phase140'
DEST = ROOT / 'implementation/phase140/evidence'
PREFIXES = ('parser-', 'checker-', 'owner-', 'verify-', 'render-', 'registry-',
            'session-source', 'session-check', 'session-screen', 'edits')
API_PREFIX = 'p140-'
MAX_FILE = 8 * 1024 * 1024
MAX_TEXT = 256 * 1024
MAX_TOTAL = 32 * 1024 * 1024


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def rel(path):
    return str(Path(path).resolve().relative_to(ROOT))


def allowed_root(path):
    path = path.resolve()
    if path.is_relative_to(PHASE):
        return True
    build = ROOT / 'selfhost/build'
    if not path.is_relative_to(build):
        return False
    parts = path.relative_to(build).parts
    return len(parts) >= 2 and parts[0] in {'phase111', 'phase128', 'phase130', 'phase134'} and parts[1].startswith(API_PREFIX)


def terminal_report(obj):
    # A failed report with an explicit outcome is evidence too. A newly opened
    # incomplete report without an outcome is not snapshotted as completed.
    return (obj.get('complete') is True or bool(obj.get('error')) or
            (isinstance(obj.get('status'), int)) or
            ('returncode' in obj and obj['returncode'] is not None))


def walk_pins(value, found):
    if isinstance(value, dict):
        if isinstance(value.get('file'), str) and isinstance(value.get('bytes'), int) and re.fullmatch('[0-9a-f]{64}', str(value.get('sha256', ''))):
            found.add((value['file'], value['bytes'], value['sha256']))
        for child in value.values():
            walk_pins(child, found)
    elif isinstance(value, list):
        for child in value:
            walk_pins(child, found)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--root', type=Path, action='append', default=[])
    parser.add_argument('--no-default-roots', action='store_true')
    a = parser.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(DEST) and out != DEST and not out.exists(), 'Fresh Phase140 evidence output required'
    roots = []
    if not a.no_default_roots:
        roots += [p for p in PHASE.iterdir() if p.is_dir() and p.name.startswith(PREFIXES)]
        for parent in ['phase111', 'phase128']:
            roots += [p for p in (ROOT / 'selfhost/build' / parent).glob('p140-*') if p.is_dir()]
    roots += [p.resolve() for p in a.root]
    roots = sorted(set(roots))
    assert roots and all(allowed_root(p) and p.is_dir() for p in roots)
    selected = set()
    skipped = []
    for root in roots:
        for p in sorted(root.rglob('*')):
            if not p.is_file() or p.is_symlink():
                continue
            size = p.stat().st_size
            keep = p.suffix == '.json' or (size <= MAX_TEXT and
                (p.suffix in {'.log', '.txt', '.py', '.mjs', '.bend'} or p.name in {'stdout', 'stderr'}))
            if p.name in {'api.mjs', 'compiler.bend'} or p.suffix in {'.ssa', '.o', '.s', '.asm'}:
                keep = False
            if not keep or size > MAX_FILE:
                skipped.append(dict(file=str(p), bytes=size, reason='excluded payload or bounded size'))
                continue
            if p.suffix == '.json':
                obj = json.loads(p.read_text())
                if p.name in {'report.json', 'process.json'} and isinstance(obj, dict) and not terminal_report(obj):
                    skipped.append(dict(file=str(p), bytes=size, reason='no completed outcome yet'))
                    continue
            selected.add(p)
    # Versioned source/method modules are small reproducibility inputs; generated
    # complete compiler source/API/objects are represented by their recorded pins.
    toolroot = ROOT / 'selfhost/tools/performance/phase140'
    selected |= {p for p in toolroot.rglob('*') if p.is_file() and not p.is_symlink()
                 and p.suffix in {'.bend', '.py', '.mjs', '.json'} and p.stat().st_size <= MAX_TEXT}
    payloads = {}
    pins = set()
    processes = []
    outcomes = []
    for p in sorted(selected):
        data = p.read_bytes()
        payloads[rel(p)] = data
        if p.suffix == '.json':
            obj = json.loads(data)
            walk_pins(obj, pins)
            if isinstance(obj, dict):
                if p.name == 'process.json' and 'wallSeconds' in obj:
                    processes.append(dict(file=str(p), archiveMember=rel(p), complete=obj.get('complete'),
                        returncode=obj.get('returncode'), wallSeconds=obj['wallSeconds'],
                        peakTreeRssBytes=obj.get('peakTreeRssBytes'), started=obj.get('started'), finished=obj.get('finished')))
                if p.name == 'report.json':
                    outcomes.append(dict(file=str(p), archiveMember=rel(p), complete=obj.get('complete'),
                        checked=obj.get('checked'), kind=obj.get('kind'), status=obj.get('status'), error=obj.get('error')))
    total = sum(map(len, payloads.values()))
    assert total <= MAX_TOTAL and len(payloads) <= 2500, (total, len(payloads))
    current = {}
    identities = []
    for file, size, sha in sorted(pins):
        p = Path(file)
        identity = dict(file=file, bytes=size, sha256=sha)
        row = dict(recorded=identity)
        if p.is_file() and p.resolve().is_relative_to(ROOT):
            if file not in current:
                # Streaming identity reads do not retain large runtime/tool bytes.
                current[file] = pin(p)
            row['currentMatchesRecorded'] = current[file] == identity
            if not row['currentMatchesRecorded']:
                row['current'] = current[file]
        else:
            row['currentMatchesRecorded'] = None
        member = rel(p) if p.resolve().is_relative_to(ROOT) else None
        row['archiveMember'] = member if member in payloads else None
        row['payloadStatus'] = 'included' if row['archiveMember'] else 'identity only; payload not archived'
        identities.append(row)
    members = [dict(original=str(ROOT / name), member=name, bytes=len(data), sha256=digest(data))
               for name, data in sorted(payloads.items())]
    costs = dict(kind='phase140-guard-cost-ledger', scope='Sum of unique completed guarded process intervals; nested API report seconds are not added again. This is charged execution time, not elapsed research time or model quota.',
                 processes=processes, guardCount=len(processes),
                 failedGuardCount=sum(p['complete'] is not True for p in processes),
                 summedGuardSeconds=sum(p['wallSeconds'] for p in processes),
                 maximumSampledTreeRssBytes=max((p['peakTreeRssBytes'] or 0 for p in processes), default=0))
    out.mkdir(parents=True)
    bundle = out / 'metadata.tar.gz'
    # Deterministic metadata and byte-for-byte roundtrip, with no extraction.
    with bundle.open('wb') as raw:
        with gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0, compresslevel=9) as compressed:
            with tarfile.open(fileobj=compressed, mode='w|', format=tarfile.PAX_FORMAT) as archive:
                for name, data in sorted(payloads.items()):
                    info = tarfile.TarInfo(name); info.size = len(data); info.mtime = 0; info.mode = 0o644
                    archive.addfile(info, io.BytesIO(data))
    with tarfile.open(bundle, 'r:gz') as archive:
        got = {m.name: archive.extractfile(m).read() for m in archive.getmembers()}
    assert got.keys() == payloads.keys()
    assert all(got[name] == value for name, value in payloads.items())
    for p in selected:
        assert p.read_bytes() == payloads[rel(p)], 'Input changed during snapshot: ' + str(p)
    index = dict(kind='phase140-compact-evidence', complete=True,
                 createdUTC=datetime.now(timezone.utc).isoformat(), method=pin(__file__),
                 roots=[str(p) for p in roots], archive=pin(bundle), files=len(members), rawBytes=total,
                 byteExactRoundtrip=True, members=members, identities=identities,
                 outcomes=outcomes, excluded=skipped,
                 scope='Component and session evidence only. API/source checking is not a compiler correctness proof. Historical dependency pins are retained without copying unrelated experiment outputs. No selected compiler or target execution changes.')
    (out / 'index.json').write_text(json.dumps(index, indent=2) + '\n')
    (out / 'costs.json').write_text(json.dumps(costs, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), files=len(members), rawBytes=total, archiveBytes=bundle.stat().st_size,
                         guardCount=costs['guardCount'], summedGuardSeconds=costs['summedGuardSeconds'],
                         recordedIdentityMismatches=sum(r['currentMatchesRecorded'] is False for r in identities))))


if __name__ == '__main__':
    main()
