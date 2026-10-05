#!/usr/bin/env python3
"""Data-only protocol successor over identical checked TS source/module bytes."""
import argparse,json,hashlib
from pathlib import Path

def identity(p):
    p=Path(p).resolve(strict=True)
    return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['reference','catalog','out']:p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();assert not a.out.exists()
    old=json.loads(a.reference.read_text());assert old['complete'] and old['passed'] and set(old['roles'])=={'typescript'}
    priorFile=Path(old['catalog']['file']);assert identity(priorFile)['sha256']==old['catalog']['sha256']
    prior=json.loads(priorFile.read_text());new=json.loads(a.catalog.read_text());assert prior['upstreamCommit']==new['upstreamCommit']
    before={c['id']:c for c in prior['cases']};assert set(before)=={c['id']for c in new['cases']}
    inputs=[identity(__file__),identity(a.reference),identity(priorFile),identity(a.catalog)]
    for case in new['cases']:
        assert case['source']==before[case['id']]['source'] and case['mode']==before[case['id']]['mode']
        source=(a.catalog.resolve().parent/case['source']['path']).resolve(strict=True);assert identity(source)['sha256']==case['source']['sha256']
        module=Path(old['roles']['typescript']['modules'][case['id']]);receiptFile=Path(str(module)+'.json');receipt=json.loads(receiptFile.read_text())
        assert receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status']=='ok'
        assert receipt['compiler']['kind']=='checked-pinned-typescript' and receipt['compiler']['upstreamCommit']==new['upstreamCommit']
        assert receipt['input']['sha256']==case['source']['sha256'] and receipt['output']['sha256']==identity(module)['sha256']
        assert receipt['catalog']['sha256']==old['catalog']['sha256']
        inputs += [identity(source),identity(module),identity(receiptFile)]
    out=dict(kind='phase53-semantic-reference-protocol-rebind',complete=True,passed=True,executed=False,catalog=identity(a.catalog),roles=old['roles'],retainedEmissionCatalog=identity(priorFile),inputs=inputs,scope='Checked source/module bytes unchanged. Only independently documented observation protocol catalog changes; original receipts/catalog remain retained. No re-emission or semantic PASS.')
    with a.out.open('x')as f:f.write(json.dumps(out,indent=2)+'\n')
    print(json.dumps(dict(complete=True,executed=False,manifest=identity(a.out))))

if __name__=='__main__':main()
