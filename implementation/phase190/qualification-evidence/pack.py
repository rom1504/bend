#!/usr/bin/env python3
"""Plan or deterministically pack Phase190 supplementary metadata; never run targets."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOTS = (
    'selected-source01', 'selected-check01', 'native-image01', 'native-self01',
    'native64-01', 'native-reproduction01', 'native45-01', 'native45-02',
    'runtime10-01', 'native-generations-compare01', 'hosted-native-compare01',
    'broad-runtime02', 'broad-manifest01', 'unchanged-targets01',
    'machine-audit-final02', 'machine-audit-local-pair01', 'local-pair-path-audit01',
)
EXTRA = ('broad-summary01.json', 'broad-summary01.md', 'broad-runtime01-guard',
         'assets.json', 'installed-before.json')
REQUIRED = ('selected-check01', 'native-image01', 'native-self01', 'native64-01',
            'native-reproduction01', 'native45-01', 'native45-02', 'runtime10-01',
            'native-generations-compare01', 'hosted-native-compare01', 'broad-runtime02')
STREAMS = ('stdout', 'stderr', 'stdout.log', 'stderr.log')
MAX_STREAM = 131072

def sha(data):
    return hashlib.sha256(data).hexdigest()

def verify(out):
    index = json.loads((out/'inventory.json').read_text())
    blob = (out/index['archive']['file']).read_bytes()
    if len(blob) != index['archive']['bytes'] or sha(blob) != index['archive']['sha256']:
        raise ValueError('Archive identity mismatch')
    rows = {r['member']: r for r in index['members']}
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as archive:
        if len(archive.getmembers()) != len(rows): raise ValueError('Duplicate/extra members')
        for member in archive.getmembers():
            if not member.isfile() or member.name not in rows or Path(member.name).is_absolute() or '..' in Path(member.name).parts:
                raise ValueError('Unsafe/unlisted member')
            row = rows.pop(member.name); data = archive.extractfile(member).read()
            if len(data) != row['bytes'] or sha(data) != row['sha256']: raise ValueError('Member identity mismatch')
    if rows: raise ValueError('Missing members')
    print(json.dumps(dict(verified=True, members=len(index['members']), archiveBytes=len(blob), targetsRun=False)))

def allowed(path, build):
    rel = path.relative_to(build)
    if path.is_symlink() or path.name == 'source-map.json': return False
    stream = path.name in STREAMS or path.suffix in ('.stdout', '.stderr')
    if stream:
        if path.stat().st_size > MAX_STREAM: raise ValueError('Oversize stream requires explicit review: '+str(rel))
        return True
    # Root runtime report retains process metadata; nested raw oracle streams
    # remain verbatim, but duplicative per-observation JSON is omitted.
    if rel.parts[0] in ('runtime10-01', 'broad-runtime02') and len(rel.parts) > 2: return False
    return path.suffix in ('.json', '.asm', '.md') or path.name.endswith('.nm.txt')

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[3])
    p.add_argument('--out', type=Path, default=Path(__file__).resolve().parent)
    p.add_argument('--pack', action='store_true', help='Emit archive; default only prints selection/pending status')
    p.add_argument('--verify', action='store_true')
    p.add_argument('--selection', type=Path, help='Exactly reproduce an inventory, checking every original hash')
    p.add_argument('--include-root', action='append', default=[], help='Additional exact phase190 metadata directory/file (e.g. close receipt)')
    p.add_argument('--max-total-mib', type=float, default=4, help='Combined archive/inventory byte budget')
    a = p.parse_args()
    if a.verify: verify(a.out); return
    root = a.root.resolve(); build = root/'selfhost/build/phase190'
    names = set(ROOTS) | {n+'-guard' for n in ROOTS} | set(EXTRA) | set(a.include_root)
    if any(Path(n).name != n or n in ('.','..') for n in names): raise ValueError('Scope must use exact immediate child names')
    paths = set(); pending = []; skipped = []
    oldrows = None
    if a.selection:
        old = json.loads(a.selection.read_text()); oldrows = {r['member']: r for r in old['members']}
        paths = {root/r['original']['file'] for r in oldrows.values()}
        names = set(old['selectedRoots'])
    else:
        for name in sorted(names):
            base = build/name
            if not base.exists(): continue
            for path in ([base] if base.is_file() else sorted(base.rglob('*'))):
                if path.is_file():
                    if allowed(path, build): paths.add(path)
                    elif path.name == 'source-map.json': skipped.append(str(path.relative_to(root)))
        for name in REQUIRED:
            if not (build/name/'report.json').is_file(): pending.append(name+'/report.json missing')
        # Include the bounded interpretation, not the audit program/source.
        note = root/'implementation/phase190/local-pair-regression.md'
        if note.is_file(): paths.add(note)
    # Follow only authenticated close-receipt links from selected retention
    # metadata; do not walk the retention archive tree or previous capsules.
    if oldrows is None:
        for path in tuple(paths):
            if path.name != 'retention.json': continue
            closure = json.loads(path.read_text()).get('closure')
            if not isinstance(closure, dict): continue
            linked = Path(closure['file'])
            if not linked.is_absolute(): linked = root/linked
            if not linked.resolve().is_relative_to(root/'selfhost/build-retention/phase190') or linked.suffix != '.json':
                raise ValueError('Unexpected close receipt path')
            data = linked.read_bytes()
            if len(data) != closure['bytes'] or sha(data) != closure['sha256']:
                raise ValueError('Close receipt identity mismatch')
            paths.add(linked)
    entries = []; payloads = []; negatives = []
    for path in sorted(paths):
        resolved = path.resolve()
        if not resolved.is_relative_to(root) or path.is_symlink(): raise ValueError('Nonlocal/symlink evidence')
        data = path.read_bytes(); member = str(path.relative_to(root))
        pin = dict(file=member, bytes=len(data), sha256=sha(data))
        entry = dict(member=member, bytes=len(data), sha256=sha(data), original=pin, transformation='verbatim')
        if oldrows is not None and entry != oldrows.get(member): raise ValueError('Changed original evidence: '+member)
        if path.suffix == '.json':
            doc = json.loads(data)
            if isinstance(doc, dict):
                # Failed but finished receipts are retained; incomplete guard
                # receipts mean a writer may still be modifying this evidence.
                if path.name == 'process.json' and doc.get('complete') is False and doc.get('finished') is None:
                    pending.append(member+' guard incomplete')
                if doc.get('error') or doc.get('stoppedFor') or doc.get('passed') is False or doc.get('returncode') not in (None, 0):
                    negatives.append(dict(member=member, error=doc.get('error'), stoppedFor=doc.get('stoppedFor'), passed=doc.get('passed'), returncode=doc.get('returncode')))
        entries.append(entry); payloads.append((member, data))
    if not entries: raise ValueError('Empty selection')
    if not a.pack:
        print(json.dumps(dict(targetsRun=False, packWritten=False, selectedRoots=sorted(names), members=len(entries), uncompressedBytes=sum(r['bytes'] for r in entries), pending=pending, explicitlyOmitted=skipped), indent=2)); return
    if pending: raise ValueError('Not ready to freeze: '+ '; '.join(pending))
    archive_path = a.out/'receipts.tar.gz'; inventory_path = a.out/'inventory.json'
    if archive_path.exists() or inventory_path.exists(): raise ValueError('Fresh archive/inventory required; no overwrite')
    stream = io.BytesIO()
    with gzip.GzipFile(fileobj=stream, mode='wb', filename='', mtime=0, compresslevel=9) as gz:
        with tarfile.open(fileobj=gz, mode='w', format=tarfile.USTAR_FORMAT) as archive:
            for member, data in payloads:
                info = tarfile.TarInfo(member); info.size = len(data); info.mode = 0o644; info.mtime = 0
                archive.addfile(info, io.BytesIO(data))
    blob = stream.getvalue()
    # Detect receipts modified while the snapshot was being assembled.
    for row in entries:
        if sha((root/row['original']['file']).read_bytes()) != row['original']['sha256']:
            raise ValueError('Receipt changed during packing: '+row['member'])
    index = dict(kind='phase190-supplementary-metadata-evidence', version=1, targetsRun=False,
        scope='Selected-source identity/check; native generations and finite qualification; runtime and comparison receipts; guard/close records; bounded machine audits. No new qualification inferred.',
        exclusions=['compiler source', 'source-map.json', 'executables', 'object files', 'API modules', 'first evidence capsule', 'duplicative nested runtime JSON'],
        selectedRoots=sorted(names), originalRoot=str(root), explicitlyOmitted=skipped,
        archive=dict(file=archive_path.name, bytes=len(blob), sha256=sha(blob)), members=entries,
        negativeReceipts=negatives, uncompressedBytes=sum(r['bytes'] for r in entries),
        method=dict(file=str(Path(__file__).resolve().relative_to(root)), sha256=sha(Path(__file__).read_bytes())))
    encoded = (json.dumps(index, separators=(',', ':'))+'\n').encode()
    if len(blob)+len(encoded) > a.max_total_mib*1048576: raise ValueError('Archive/inventory exceed declared byte budget')
    a.out.mkdir(parents=True, exist_ok=True); archive_path.write_bytes(blob); inventory_path.write_bytes(encoded)
    verify(a.out)

if __name__ == '__main__': main()
