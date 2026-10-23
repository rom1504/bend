"""Inspect immutable, already verified QBE; do not build or execute targets."""
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
OUT=ROOT/'selfhost/tools/performance/phase131/identity/missing-inspection'
RECEIPT=ROOT/'selfhost/build/phase131/missing-static-emit01/report.json'

def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def main():
    report=json.loads(RECEIPT.read_text());assert report['complete']
    rows=[]
    for row in report['rows']:
        p=Path(row['product']['file']);assert pin(p)==row['product'];s=p.read_text()
        functions=[]
        for m in re.finditer(r'^function[^\n]*\$([\w]+)\([^\n]*\) \{\n(.*?)^\}',s,re.M|re.S):
            symbol=m[1];i=symbol.find('FID_')
            name=''.join(chr(int(x)) for x in symbol[i+4:].split('_') if x) if i>=0 else symbol
            if name in ['missing','$direct.index_bucket','$direct.index_find']:
                functions.append(dict(name=name,symbol=symbol,qbeLines=len(m[0].splitlines()),
                    constructorCallsites=m[0].count('call $p111_rt_ctor(')))
        rows.append(dict(name=row['name'],product=pin(p),totalBytes=len(s.encode()),
            constructorCallsites=s.count('call $p111_rt_ctor('),functions=functions))
    OUT.mkdir(exist_ok=False)
    (OUT/'report.json').write_text(json.dumps(dict(complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(RECEIPT),*report['inputs']],rows=rows,
        scope='Static QBE evidence from already verified checked-Bend emissions. Callsite counts describe code shape, not dynamic allocation counts or runtime gain. No source semantics or runtime helper changed beyond exposing the same closed constructor tree.'),indent=2)+'\n')

if __name__=='__main__':main()
