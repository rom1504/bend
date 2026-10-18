#!/usr/bin/env python3
"""Replace authenticated literal runtime parts; preserve all emitted program text.
A research fast loop, not a compiler or ordinary source compilation route.
"""
import argparse,hashlib,json
from pathlib import Path
def pin(p):
    raw=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def main():
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('old',type=Path);p.add_argument('new',type=Path);p.add_argument('output',type=Path);a=p.parse_args();assert not a.output.exists()
    original=a.source.read_bytes();text=original;edits=[]
    for path in [a.old,a.new]:assert path.read_bytes()==b''.join(Path(str(path)+'.part'+str(i)).read_bytes() for i in range(5))
    for i in range(5):
        old=Path(str(a.old)+'.part'+str(i)).read_bytes();new=Path(str(a.new)+'.part'+str(i)).read_bytes()
        if old==new:continue
        assert old and text.count(old)==1, ('literal runtime part not unique',i)
        text=text.replace(old,new,1);edits.append((old,new))
    inverse=text
    for old,new in reversed(edits):assert inverse.count(new)==1;inverse=inverse.replace(new,old,1)
    assert inverse==original
    a.output.write_bytes(text)
    receipt=dict(kind='phase108-literal-runtime-rebind',source=pin(a.source),old=pin(a.old),new=pin(a.new),output=pin(a.output),partsChanged=len(edits),inverseExact=True,programTextUnchanged=True,ordinaryPath=False)
    a.output.with_suffix('.rebind.json').write_text(json.dumps(receipt,indent=2)+'\n')
if __name__=='__main__':main()
