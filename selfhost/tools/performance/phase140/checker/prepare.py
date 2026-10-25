#!/usr/bin/env python3
"""Append isolated checked-prefix experiment to an exact qualified source."""
import argparse, hashlib, json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT / 'selfhost/build/phase137/integrated-source03/compiler.bend'
PARENT_SHA = '2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
PAT = re.compile(rb'^(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
def pin(path):
    p=Path(path).resolve(); b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--module',type=Path,action='append',required=True)
    a=p.parse_args(); out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase140')
    parent=pin(PARENT); assert parent['sha256']==PARENT_SHA
    source=PARENT.read_bytes(); names=set(PAT.findall(source)); added=[]
    modules=[]
    for path in a.module:
        data=path.read_bytes(); ns=PAT.findall(data)
        assert len(ns)==len(set(ns)) and not (names & set(ns))
        names.update(ns); added.extend(n.decode() for n in ns); modules.append((path,data))
        source += b'\n' + data
    assert source.startswith(PARENT.read_bytes())
    out.mkdir(parents=True); (out/'compiler.bend').write_bytes(source)
    for i,(path,data) in enumerate(modules): (out/f'module{i}.bend').write_bytes(data)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    report=dict(complete=True,checked=False,targetsRun=False,parent=parent,source=pin(out/'compiler.bend'),overrides=[],added=added,
        inputs=[pin(__file__),parent,pin(PARENT.parent/'manifest.json'),*[pin(p) for p,_ in modules]],
        parentBytePrefixPreserved=True,scope='Append-only in-process checker-prefix experiment; all original declarations byte-identical; no production wiring or native qualification.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report['source']))
if __name__=='__main__': main()
