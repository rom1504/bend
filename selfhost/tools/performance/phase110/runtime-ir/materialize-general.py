#!/usr/bin/env python3
"""Freeze the class1 handoff import for generated generic Take2 templates."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    raw=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); base=a.base.resolve(); out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    mf=base/'manifest.json'; facts=json.loads(mf.read_text())
    if not facts.get('complete') or facts.get('kind')!='phase110-private-runtime-ir-core' or facts.get('genericTake'):
        raise ValueError('requires original authenticated private runtime core')
    for r in [*facts['inputs'],*facts['outputs']]:
        if pin(Path(r['file']))!=r: raise ValueError('changed input '+r['file'])
    adapter=HERE/'general-runtime.inc.c';out.mkdir(parents=True)
    (out/'runtime.c').write_text((base/'runtime.c').read_text()+'\n'+adapter.read_text())
    for name in ['abi.h','abi-extension.h']:
        (out/name).write_bytes((base/name).read_bytes())
    (out/'abi-private.h').write_text((base/'abi-private.h').read_text()+'\nuint32_t nx_rt_ir_hand1(NxRt*);\n')
    constants={**facts['constants'],'allocatorHead1ByteOffset':8,'allocatorLength1ByteOffset':264,'class1Words':2}
    record=dict(kind='phase110-private-runtime-ir-core',version=2,complete=True,targetsRun=False,genericTake=True,
      inputs=[pin(mf),*facts['outputs'],pin(Path(__file__)),pin(adapter)],constants=constants,
      scope='Generated generic Take2 plus generalized adjacent reconstruction; exact class0/class1 production hot lists and slow handoff',
      outputs=[pin(out/n) for n in ['runtime.c','abi.h','abi-extension.h','abi-private.h']])
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record))

if __name__=='__main__': main()
