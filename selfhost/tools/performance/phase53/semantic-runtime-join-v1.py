#!/usr/bin/env python3
"""Data-only single-source role join for the independent cold numeric controller."""
import argparse,json,hashlib
from pathlib import Path

def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['attempt','direct-table','reference','out']:p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();assert not a.out.exists()
    attemptFile=a.attempt/'attempt.json';attempt=json.loads(attemptFile.read_text());assert attempt['checked']
    reference=json.loads(a.reference.read_text());assert reference['complete']
    catalogFile=Path(reference['catalog']['file']);assert identity(catalogFile)['sha256']==reference['catalog']['sha256']
    catalog=json.loads(catalogFile.read_text());case=next(c for c in catalog['cases'] if c['id']=='f32_table_nan_bits')
    source=(catalogFile.parent/case['source']['path']).resolve(strict=True);assert identity(source)['sha256']==case['source']['sha256']
    ts=Path(reference['roles']['typescript']['modules'][case['id']]).resolve(strict=True)
    inputs=[identity(__file__),identity(a.reference),identity(catalogFile),identity(source),identity(attemptFile)]
    for role,module in [('direct',a.direct_table),('typescript',ts)]:
        module=module.resolve(strict=True);receiptFile=Path(str(module)+'.json');r=json.loads(receiptFile.read_text())
        assert r['kind']=='bend-program-checked-emission' and r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok'
        assert identity(module)['sha256']==r['output']['sha256'] and r['input']['sha256']==case['source']['sha256']
        if role=='direct':
            assert r['compiler']['backend']=='direct' and r['attempt']['sha256']==identity(attemptFile)['sha256']
            for key in ['api','runtime','base']:assert r['compiler'][key]['sha256']==attempt[key]['sha256']
        else:assert r['compiler']['kind']=='checked-pinned-typescript'
        inputs.extend([identity(module),identity(receiptFile)])
    out=dict(kind='phase53-single-source-runtime-role-join',complete=True,executed=False,catalog=identity(catalogFile),roles={'direct':{'attempt':identity(attemptFile),'modules':{case['id']:str(a.direct_table.resolve())}},'typescript':{'modules':{case['id']:str(ts)}}},inputs=inputs,scope='Only the original NaN table checked module/receipt role join for cold controls; not29-source acquisition or96-scenario qualification. Runtime controller validates exact image and rehashes all consumed receipts.')
    with a.out.open('x')as f:f.write(json.dumps(out,indent=2)+'\n')
    print(json.dumps(dict(complete=True,executed=False,output=identity(a.out))))
if __name__=='__main__':main()
