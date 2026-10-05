#!/usr/bin/env python3
"""Data-only exact legacy output comparison; never normalize or execute modules."""
import argparse
import hashlib
import json
from pathlib import Path

def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest(),bytes=file.stat().st_size)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for key in ['candidate','previous','catalog','out']:
        parser.add_argument('--'+key,type=Path,required=True)
    args=parser.parse_args();assert not args.out.exists()
    candidate=json.loads(args.candidate.read_text());previous=json.loads(args.previous.read_text());catalog=json.loads(args.catalog.read_text())
    expected=catalog['sets']['core'];assert len(expected)==8
    for bundle in [candidate,previous]:
        assert bundle['kind']=='bend-program-bundle' and bundle['schemaVersion']==1 and bundle['complete']
        assert set(bundle['roles'])=={'candidate'}
        assert bundle['catalogSha256']==identity(args.catalog)['sha256']
    assert [c['id']for c in candidate['cases']]==expected
    lookup={c['id']:c for c in previous['cases']};cache={};rows=[]
    for case in candidate['cases']:
        old=lookup[case['id']];assert case['sourceSha256']==old['sourceSha256'] and case['point']==old['point']
        modules={}
        for role,item,parent in [('selected06',case,args.candidate),('phase51Current',old,args.previous)]:
            ref=item['modules']['candidate'];name=Path(ref['path']);assert not name.is_absolute() and '..' not in name.parts
            file=(parent.resolve().parent/name).resolve(strict=True);assert file.is_relative_to(parent.resolve().parent)
            if str(file)not in cache:cache[str(file)]=identity(file)
            actual=cache[str(file)];assert actual['sha256']==ref['sha256'] and actual['bytes']==ref['bytes'];modules[role]=actual
        rows.append(dict(case=case['id'],sourceSha256=case['sourceSha256'],point=case['point'],modules=modules,byteIdentical=modules['selected06']['sha256']==modules['phase51Current']['sha256']))
    report=dict(kind='phase52-legacy-core-byte-comparison',complete=True,executed=False,normalization=False,inputs=[identity(__file__),identity(args.candidate),identity(args.previous),identity(args.catalog)],rows=rows,counts=dict(total=8,byteIdentical=sum(r['byteIdentical']for r in rows)),scope='Exact emitted module bytes for the unchanged core8 points. Different compiler attempts may yield identical output; byte identity is additional compatibility evidence, never substitutes for runtime oracles, the RNFA baseline screen, full conformance or installation.')
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x')as stream:stream.write(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report['counts']))

if __name__=='__main__':main()
