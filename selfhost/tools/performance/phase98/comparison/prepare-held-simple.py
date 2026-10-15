#!/usr/bin/env python3
"""Offline held-root equality simplification; no carrier datatype."""
import argparse, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    path=path.resolve();data=path.read_bytes()
    return dict(file=str(path),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,default=ROOT/'selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.bend')
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    original=a.source.read_text();helpers=(HERE/'held-helpers02.bend').read_text()
    old='def p88_string_eq(a: String, b: String) -> Bool:\n  p88_string_eq_go(a, b, True{})\n'
    assert original.count(old)==1
    new=helpers[helpers.index('def p98_eq_finish'):].replace('p98_eq_walk(a, b, True{})','p88_string_eq_go(a, b, True{})').replace('def p98_string_eq(','def p88_string_eq(')
    assert 'p98_eq_walk' not in new and original.count('def p88_string_eq_go(')==1
    candidate=original.replace(old,new);assert candidate.replace(new,old)==original
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase98');out.mkdir(parents=True)
    target=out/'compiler.bend';target.write_text(candidate)
    receipt=dict(kind='phase98-held-root-simple-equality-source-derivative',complete=True,targetsRun=False,
                 method=pin(Path(__file__)),source=pin(a.source),helpers=pin(HERE/'held-helpers02.bend'),candidate=pin(target),
                 changes=[dict(old=old,new=new,offset=original.index(old))],physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),
                 walkerBodyUnchanged=True,forwardReplayExact=True,inverseRecoversSource=True,
                 scope='Private direct finish consumes original roots after unchanged equality walker. No carrier type. Native borrowed code shape and full outputs require separate gates; no runtime or upstream edit.')
    assert a.source.read_text()==original
    (out/'changes.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps({k:receipt[k] for k in ['candidate','physicalLineDelta','walkerBodyUnchanged']}))

if __name__=='__main__':main()
