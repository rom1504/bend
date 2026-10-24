#!/usr/bin/env python3
"""Archive compact Phase135 validation evidence, excluding generated code/binaries."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil

ROOT=Path(__file__).resolve().parents[5]


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--mode',choices=['full','baseline'],required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'implementation/phase135/validation')
    if a.mode=='full':
        folders=['selfhost/build/phase135/full-session01','selfhost/build/phase135/full-session-plan01','selfhost/build/phase135/full-session-guard01']
        extras=['selfhost/build/phase132/source-edit01/report.json','selfhost/build/phase132/source-edit01/before.bend','selfhost/build/phase132/source-edit01/after.bend',
            'selfhost/build/phase130/p131-final-self01/report.json','selfhost/build/phase130/p132-edited-full01/report.json','selfhost/build/phase111/p132-edited-api01/report.json',
            'selfhost/tools/performance/phase135/validation/full-session-v01.py','design/phase135/edit-contract.md']
    else:
        folders=['selfhost/build/phase130/p135-session-ordinary-b01','selfhost/build/phase135/ordinary-baseline-plan01','selfhost/build/phase135/ordinary-baseline-guard01']
        extras=['selfhost/tools/performance/phase135/validation/ordinary-baseline-v01.py','selfhost/tools/performance/phase130/native-request.py']
    result=json.loads((ROOT/folders[0]/'report.json').read_text());assert result['complete']
    out.mkdir(parents=True);records=[]
    def copy(source,target):
        dest=out/target;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest)
        records.append(dict(source=pin(source),archive=pin(dest)))
    allowed={'report.json','plan.json','execution.json','process.json','inputs.json','method.json','stdout','stderr','stdout.log','stderr.log','emit.stderr'}
    for folder in folders:
        for p in sorted((ROOT/folder).iterdir()):
            if p.is_file()and p.name in allowed:copy(p,Path(Path(folder).name)/p.name)
    for relative in extras:copy(ROOT/relative,'provenance/'+relative)
    copy(Path(__file__),'archive-method.py')
    evidence=dict(complete=True,targetsRun=False,mode=a.mode,records=records,totalBytes=sum(r['archive']['bytes']for r in records),scope='Compact completed-result evidence only. Full compiler QBE, assembly, binaries and APIs intentionally excluded; exact identities remain in original receipts.')
    if a.mode=='full':
        archive=ROOT/'implementation/phase131/final/compiler-source01.bend.gz';base=gzip.decompress(archive.read_bytes())
        edit=json.loads((ROOT/'selfhost/build/phase132/source-edit01/report.json').read_text());before=Path(edit['before']['file']).read_bytes();after=Path(edit['after']['file']).read_bytes()
        plan=json.loads((ROOT/folders[1]/'plan.json').read_text());assert base.count(before)==1
        changed=base.replace(before,after,1)
        assert hashlib.sha256(base).hexdigest()==plan['revisions'][0]['source']['sha256']and hashlib.sha256(changed).hexdigest()==plan['revisions'][1]['source']['sha256']
        evidence['sourceReproduction']=dict(parentArchive=pin(archive),repositoryPath=str(archive.relative_to(ROOT)),before=edit['before'],after=edit['after'],parentSource=plan['revisions'][0]['source'],editedSource=plan['revisions'][1]['source'],exactReconstruction=True,scope='Reuse the already tracked Phase131 source archive; do not duplicate its2.67MB source or107MB products.')
    (out/'archive.json').write_text(json.dumps(evidence,indent=2)+'\n');print(json.dumps(dict(complete=True,files=len(records),bytes=evidence['totalBytes'])))


if __name__=='__main__':main()
