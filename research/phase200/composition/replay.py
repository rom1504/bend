"""Replay an authenticated maintained source patch after storage is allocated."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source

def digest(data):return {'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}

def replay(record,parent,out):
    data=json.loads(record.read_bytes())
    patch=gzip.decompress(record.with_suffix('.patch.gz').read_bytes())
    assert digest(patch)==data['patch']
    parent=parent.resolve()
    current=(parent/'compiler.bend').read_bytes()
    assert digest(current)['sha256']==data['parent']['sha256']
    assert source.maintained_assemble(parent/'maintained/src/compiler.json',parent/'maintained','x86')==current
    create=out.resolve()
    create.mkdir(parents=True,exist_ok=False)
    tree=create/'maintained'
    shutil.copytree(parent/'maintained',tree)
    subprocess.run(['patch','--batch','--fuzz=0','-p1','-d',str(tree)],input=patch,capture_output=True,check=True)
    result=source.maintained_assemble(tree/'src/compiler.json',tree,'x86')
    assert digest(result)==data['selectedSource']
    final=create/'compiler.bend';final.write_bytes(result)
    (create/'report.json').write_text(json.dumps({'parent':source.pin(parent/'compiler.bend'),
        'source':source.pin(final),'record':source.pin(record),'method':source.pin(__file__)},indent=2)+'\n')
    print(data['selectedSource'])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--record',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--parent',type=Path,default=ROOT/'selfhost/build/phase198/p199-integrated01');a=p.parse_args()
    replay(a.record.resolve(),a.parent,a.out)
