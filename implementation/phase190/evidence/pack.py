#!/usr/bin/env python3
"""Deterministically pack metadata only, or verify a portable evidence archive."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile


def digest(data):
    return hashlib.sha256(data).hexdigest()


def verify(directory):
    index = json.loads((directory/'inventory.json').read_text())
    blob = (directory/index['archive']['file']).read_bytes()
    assert len(blob) == index['archive']['bytes'] and digest(blob) == index['archive']['sha256']
    expected = {row['member']:row for row in index['members']}
    with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as archive:
        assert len(archive.getmembers()) == len(expected)
        for member in archive.getmembers():
            assert member.isfile() and member.name in expected
            assert not member.name.startswith('/') and '..' not in Path(member.name).parts
            data = archive.extractfile(member).read()
            row = expected.pop(member.name)
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
    assert not expected
    print(json.dumps(dict(verified=True,members=len(index['members']),archiveBytes=len(blob),targetsRun=False)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[3])
    parser.add_argument('--out',type=Path,default=Path(__file__).resolve().parent)
    parser.add_argument('--verify',action='store_true')
    parser.add_argument('--selection',type=Path,help='Recreate exactly the inventory selection, rejecting changed source bytes')
    args = parser.parse_args()
    if args.verify:
        verify(args.out);return
    root=args.root.resolve(); build=root/'selfhost/build/phase190'
    paths=[]
    if args.selection:
        selected=json.loads(args.selection.read_text())['members']
        paths=[(root/row['original']['file'],row) for row in selected]
    else:
        for path in sorted(build.rglob('*')):
            if not path.is_file():continue
            rel=path.relative_to(build); top=rel.parts[0]
            # Explicit capture cutoff: later selected-source checks and runtime07+
            # belong in a separately inventoried supplementary bundle.
            if top.startswith('selected-') or top.startswith('runtime07'):continue
            # Runtime root reports already retain each observation, full process
            # metrics, command, status, and stdout/stderr hashes. Avoid thousands
            # of duplicated per-observation transport files in this small capsule.
            if top.startswith('runtime') and not top.endswith('-guard') and len(rel.parts)>2:continue
            if path.name in ('source-map.json',):continue
            allowed=(path.suffix=='.json' or path.suffix=='.asm' or path.name.endswith('.nm.txt')
                     or path.name=='samples.txt' or path.name in ('stdout','stderr','stdout.log','stderr.log')
                     or path.suffix in ('.stdout','.stderr'))
            if not allowed:continue
            if path.suffix not in ('.json','.asm') and path.stat().st_size>131072:continue
            paths.append((path,None))
        # Portable region definitions are metadata, not source or executable copies.
        paths.extend((p,None) for p in sorted((root/'selfhost/tests/phase190').glob('local-fold-*-regions.json')))
    if not paths:raise ValueError('No evidence selected; check repository root')
    entries=[]; payloads=[]; failures=[]
    allowed_prep=('kind','version','complete','targetsRun','parent','inputs','source','exportManifest',
                  'binding','exports','nativeMain','protectedUnchanged','scope','snapshot','snapshotIdentity',
                  'sourceConstantOverrides','parentScope')
    for path,old in paths:
        original=path.read_bytes(); original_pin=dict(file=str(path.relative_to(root)),bytes=len(original),sha256=digest(original))
        if old and original_pin!=old['original']:raise ValueError('Changed source evidence: '+str(path))
        data=original; transformation='verbatim'; document=None
        if path.suffix=='.json':document=json.loads(original)
        if isinstance(document,dict) and document.get('kind')=='phase190-api-source':
            data=(json.dumps(dict(originalReceipt=original_pin,
                retained={key:document[key] for key in allowed_prep if key in document},
                omittedFields=sorted(set(document)-set(allowed_prep)),
                scope='Source-preparation identity and switch facts only; declaration bodies/maps omitted.'),indent=2)+'\n').encode()
            transformation='source-preparation-facts-v1'
        member=str(path.relative_to(root))
        if transformation!='verbatim':member += '.facts.json'
        entry=dict(member=member,bytes=len(data),sha256=digest(data),original=original_pin,transformation=transformation)
        if old and any(entry[k]!=old[k] for k in ('member','bytes','sha256','transformation')):
            raise ValueError('Derived evidence differs: '+str(path))
        entries.append(entry);payloads.append((member,data))
        if isinstance(document,dict) and (document.get('error') or document.get('stoppedFor')):
            failures.append(dict(member=member,error=document.get('error'),stoppedFor=document.get('stoppedFor')))
    stream=io.BytesIO()
    with gzip.GzipFile(fileobj=stream,mode='wb',filename='',mtime=0,compresslevel=9) as compressed:
        with tarfile.open(fileobj=compressed,mode='w',format=tarfile.USTAR_FORMAT) as archive:
            for member,data in payloads:
                info=tarfile.TarInfo(member);info.size=len(data);info.mode=0o644;info.mtime=0
                archive.addfile(info,io.BytesIO(data))
    blob=stream.getvalue();args.out.mkdir(parents=True,exist_ok=True)
    archive_path=args.out/'receipts.tar.gz'
    if archive_path.exists() or (args.out/'inventory.json').exists():raise ValueError('Fresh archive and inventory paths required')
    archive_path.write_bytes(blob)
    index=dict(kind='phase190-portable-metadata-evidence',version=1,targetsRun=False,
        scope='Frozen metadata through runtime06/final-build01/final-controls01/final-emit01; no binaries, APIs, compiler source copies or later selected-source checks.',
        archive=dict(file=archive_path.name,bytes=len(blob),sha256=digest(blob)),
        originalRoot=str(root),members=entries,negativeReceipts=failures,
        method=dict(file='implementation/phase190/evidence/pack.py',sha256=digest(Path(__file__).read_bytes())),
        uncompressedBytes=sum(row['bytes'] for row in entries))
    (args.out/'inventory.json').write_text(json.dumps(index,indent=2)+'\n')
    verify(args.out)


if __name__=='__main__':main()
