"""Retain or reproduce exact compiler-source deltas between authenticated experiment parents."""
import argparse, difflib, gzip, hashlib, json, subprocess, tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(data):return hashlib.sha256(data).hexdigest()
def apply(base,delta):
    with tempfile.TemporaryDirectory() as tmp:
        target=Path(tmp)/'compiler.bend'
        target.write_bytes(base)
        subprocess.run(['patch','--batch','--fuzz=0','-s',target],input=delta,check=True)
        return target.read_bytes()
def main():
    p=argparse.ArgumentParser()
    p.add_argument('mode',choices=['freeze','restore'])
    p.add_argument('name');p.add_argument('parent',type=Path);p.add_argument('source',type=Path)
    a=p.parse_args();d=HERE/'snapshots';d.mkdir(exist_ok=True)
    assert a.name.isalnum()
    idx=d/(a.name+'.json');patch=d/(a.name+'.patch.gz')
    base=a.parent.read_bytes()
    if a.mode=='freeze':
        target=a.source.read_bytes()
        delta=b''.join(difflib.diff_bytes(difflib.unified_diff,base.splitlines(True),target.splitlines(True),fromfile=b'compiler.bend',tofile=b'compiler.bend'))
        assert apply(base,delta)==target
        patch.write_bytes(gzip.compress(delta,mtime=0))
        idx.write_text(json.dumps(dict(parentSha256=sha(base),sha256=sha(target),deltaSha256=sha(delta),bytes=len(target)),indent=2)+'\n')
    else:
        receipt=json.loads(idx.read_text());assert sha(base)==receipt['parentSha256']
        delta=gzip.decompress(patch.read_bytes());assert sha(delta)==receipt['deltaSha256']
        result=apply(base,delta)
        assert sha(result)==receipt['sha256'] and len(result)==receipt['bytes']
        with a.source.open('xb') as f:f.write(result)
if __name__=='__main__':main()
