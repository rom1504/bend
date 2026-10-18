#!/usr/bin/env python3
"""Seal bounded Phase108 evidence; no compiler/target runs. Existing output refused."""
import argparse,hashlib,json,tarfile,itertools
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
    base=ROOT/'selfhost/build/phase108';rows=[];excluded=[]
    for path in sorted(base.rglob('*')):
        if path.is_symlink():excluded.append(dict(path=str(path.relative_to(ROOT)),reason='symlink'));continue
        if not path.is_file():continue
        relative=path.relative_to(base)
        skip=path.suffix=='.o' or '__pycache__' in path.parts or any(x in path.parts for x in ['cproc-src','qbe-1.3'])
        if skip:
            excluded.append(dict(path=str(path.relative_to(ROOT)),bytes=path.stat().st_size,sha256=sha(path),reason='rebuildable tool source/object'));continue
        rows.append(dict(path=str(path.relative_to(ROOT)),bytes=path.stat().st_size,sha256=sha(path)))
    archive=out/'observations.tar.gz'
    with tarfile.open(archive,'w:gz',compresslevel=6,dereference=True) as tar:
        for row in rows:
            path=ROOT/row['path'];assert sha(path)==row['sha256'];tar.add(path,arcname=row['path'],recursive=False)
    checked=[]
    with tarfile.open(archive,'r:gz') as tar:
        for member,row in itertools.zip_longest(tar,rows):
            assert member is not None and row is not None, 'archive member count differs'
            assert member.isfile() and member.name==row['path'] and member.size==row['bytes']
            h=hashlib.sha256();f=tar.extractfile(member)
            for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
            assert h.hexdigest()==row['sha256'];checked.append(member.name)
    assert len(checked)==len(rows)
    manifest=dict(kind='phase108-sealed-evidence',complete=True,files=rows,excluded=excluded,archive=dict(path=str(archive.relative_to(ROOT)),bytes=archive.stat().st_size,sha256=sha(archive)),verifiedMembers=len(checked),scope='Target receipts, complete generated C, experimental compiler images and controls. Rebuildable objects/tool source directories excluded with hashes; setup recipes retained in Git. Original selected assets remain in their earlier capsules.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');(out/'FILES.sha256').write_text(''.join(x['sha256']+'  '+x['path']+'\n' for x in rows));print(json.dumps(dict(complete=True,files=len(rows),archiveBytes=archive.stat().st_size,archiveSha256=sha(archive))))
if __name__=='__main__':main()
