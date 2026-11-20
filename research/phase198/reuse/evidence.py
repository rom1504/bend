"""Freeze bounded source-level and run receipts without copying compiler images."""
from pathlib import Path
import hashlib
import gzip
import io
import tarfile
import json

here=Path(__file__).resolve().parent
root=here.parents[2];build=root/'selfhost/build/phase198';close=root/'selfhost/build-retention/phase198'

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def pin(p):return dict(file=str(p.relative_to(root)),bytes=p.stat().st_size,sha256=digest(p))

def main():
    out=here/'evidence';out.mkdir(exist_ok=True);records=[]
    for receipt in sorted(close.glob('reuse-*-close')):
        name=receipt.name[:-6];run=build/name;guard=build/(name+'-guard');seal=read(receipt/'report.json');proc=read(guard/'process.json');report=run/'report.json'
        if not seal.get('complete') or not proc.get('complete'):continue
        d=read(report) if report.exists() else {};detail={}
        if d.get('summary'):detail['summary']=d['summary']
        if d.get('boundaries'):detail['boundaries']=d['boundaries']
        if d.get('checks'):detail['checksumPoints']=len(d['checks'])
        if d.get('sourceShapes'):detail['sourceShapes']=d['sourceShapes']
        if d.get('counts'):detail['counts']=d['counts']
        if d.get('controls'):detail['controls']=len(d['controls']) if isinstance(d['controls'],list) else d['controls']
        if d.get('events'):detail['events']=d['events']
        for key in ('source','api','checked','independent'):
            if key in d:detail[key]=d[key]
        if d.get('cases'):
            detail['cases']=[{k:v for k,v in r.items() if k in ('id','source','plans','owner','semantic','symbolic','controls','summary','object','assembly','error')} for r in d['cases']]
            for a,b in zip(detail['cases'],d['cases']):
                if 'oracles' in b:a['checksumPoints']=len(b['oracles'])
        if proc['returncode']:
            diagnostics=[p for p in (run/'stderr',guard/'stderr.log',run/'compiler.stderr') if p.exists() and p.stat().st_size]
            detail['diagnostic']='\n'.join(p.read_text()[-2600:] for p in diagnostics)
        records.append(dict(name=name,exit=proc['returncode'],seconds=proc['wallSeconds'],classification=seal['classification'],guard=pin(guard/'process.json'),retention=pin(receipt/'report.json'),report=pin(report) if report.exists() else None,detail=detail))
    (out/'runs.json').write_text(json.dumps(records,indent=2)+'\n')
    files=set()
    for rec in records:
        name=rec['name'];run=build/name;guard=build/(name+'-guard');seal=close/(name+'-close')
        for item in [run/'report.json',guard/'process.json',guard/'retention.json',seal/'report.json',run/'boundaries.stderr',run/'checked/shapes.json',run/'tree-bitonic/outer-shapes.json']:
            if item.is_file():files.add(item)
        if rec['exit']:
            for item in (run/'stderr',guard/'stderr.log',run/'compiler.stderr'):
                if item.is_file() and item.stat().st_size:files.add(item)
    for p in sorted(build.glob('reuse-layout*/report.json')):files.add(p)
    with (out/'receipts.tar.gz').open('wb') as sink:
        with gzip.GzipFile(fileobj=sink,mode='wb',mtime=0,filename='') as gz:
            with tarfile.open(fileobj=gz,mode='w') as tar:
                for p in sorted(files):
                    payload=p.read_bytes();h=tarfile.TarInfo(str(p.relative_to(root)));h.size=len(payload);h.mode=0o644
                    tar.addfile(h,io.BytesIO(payload))
if __name__=='__main__':main()
