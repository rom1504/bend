#!/usr/bin/env python3
"""Pack only our exported checkpoints; optionally remove verified loose copies.

Never accepts selfhost/build, compiler images, or other agents' evidence roots.
"""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile
import time

ROOT = Path(__file__).resolve().parents[4]
EVIDENCE = ROOT/'implementation/phase147/evidence'


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def encode(value):
    return (json.dumps(value,indent=2)+'\n').encode()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--checkpoint',type=Path,required=True)
    p.add_argument('--supplement',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--compact',action='store_true',help='Remove only fully verified exported input copies')
    a=p.parse_args(); sources=[x.absolute() for x in [a.checkpoint,a.supplement]]; out=a.out.absolute()
    for source in sources:
        assert source.parent==EVIDENCE and source.resolve()==source and source.name.startswith('checkpoint')
        assert source.is_dir() and not source.is_symlink()
    assert len(set(sources))==2 and out.parent==EVIDENCE and out.resolve()==out and not out.exists()
    assert out not in sources
    report=json.loads((sources[0]/'report.json').read_text())
    supplement=json.loads((sources[1]/'report.json').read_text())
    assert report['kind']=='phase147-retention-checkpoint-v1' and report['complete']
    assert supplement['kind']=='phase147-small-method-dependency-supplement-v1' and supplement['complete']
    assert supplement['checkpoint']['sha256']==digest((sources[0]/'report.json').read_bytes())['sha256']
    rows=[]; total=0
    for source in sources:
        for path in sorted(source.rglob('*')):
            assert not path.is_symlink()
            if path.is_dir():continue
            assert path.is_file()
            data=path.read_bytes(); total+=len(data); assert total<=40*1024**2
            rows.append(dict(member=str(path.relative_to(EVIDENCE)),**digest(data)))
    index=encode(dict(kind='phase147-checkpoint-capsule-member-index-v1',members=rows))
    out.mkdir(); archive=out/'checkpoint.tar.gz'
    with archive.open('xb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
        for row in [dict(member='member-index.json',**digest(index)),*rows]:
            data=index if row['member']=='member-index.json' else (EVIDENCE/row['member']).read_bytes()
            assert digest(data)=={k:row[k]for k in ['bytes','sha256']}
            info=tarfile.TarInfo(row['member']);info.size=len(data);info.mode=0o644;info.mtime=0
            tar.addfile(info,io.BytesIO(data))
    expected={x['member']:x for x in [dict(member='member-index.json',**digest(index)),*rows]};seen=set()
    with tarfile.open(archive,'r:gz') as tar:
        for member in tar:
            assert member.isfile() and member.name in expected and member.name not in seen
            seen.add(member.name);actual=digest(tar.extractfile(member).read())
            assert actual=={k:expected[member.name][k]for k in ['bytes','sha256']}
    assert seen==set(expected)
    for row in rows:
        assert digest((EVIDENCE/row['member']).read_bytes())=={k:row[k]for k in ['bytes','sha256']}
    summary={k:report[k]for k in ['kind','cutoff','guardCount','guardOutcomes','cost','pendingGuards','protectedPolicy']}
    summary.update(kind='phase147-retention-checkpoint-summary-v1',complete=True,
                   failedGuards=[{k:r[k]for k in ['guard','elapsedSeconds','returncode','stoppedFor']}for r in report['guards']if r['proposedClassification']=='failed'],
                   smallMethodSupplement=dict(exactObjects=supplement['exactObjects'],bytes=supplement['exportedUniqueBytes'],
                     unresolved=[r for r in supplement['files']if r['status']!='exact bytes exported']),
                   sourceReport=dict(member=sources[0].name+'/report.json',**digest((sources[0]/'report.json').read_bytes())),
                   campaignGuardsSealed=report.get('campaignGuardsSealed',False),
                   scope=('Final data checkpoint of sealed guards and retained receipts; compiler qualification remains separate.'
                          if report.get('campaignGuardsSealed',False) else
                          'Interim data-only checkpoint; active target lane was open. No qualification or campaign closure claim.'))
    receipt=dict(kind='phase147-checkpoint-capsule-v1',complete=True,created=time.time(),
                 archive=dict(file=str(archive.relative_to(ROOT)),**digest(archive.read_bytes())),
                 memberIndex=dict(member='member-index.json',**digest(index)),members=len(expected),
                 fullMemberHashRoundtripVerified=True,sourceBytesReverified=True,exportedPayloadBytes=total,
                 compactRequested=a.compact,looseCopiesRemoved=False,rawBuildFilesChanged=False,
                 method=dict(file=str(Path(__file__).resolve().relative_to(ROOT)),**digest(Path(__file__).read_bytes())))
    if a.compact:
        # Explicitly authorized export compaction, never raw build retention.
        for row in rows:(EVIDENCE/row['member']).unlink()
        for source in sources:
            for path in sorted(source.rglob('*'),key=lambda x:len(x.parts),reverse=True):path.rmdir()
            source.rmdir()
        receipt['looseCopiesRemoved']=True
    (out/'summary.json').write_bytes(encode(summary));(out/'index.json').write_bytes(encode(receipt))
    print(json.dumps(dict(archiveBytes=receipt['archive']['bytes'],members=len(expected),looseCopiesRemoved=a.compact)))


if __name__=='__main__':main()
