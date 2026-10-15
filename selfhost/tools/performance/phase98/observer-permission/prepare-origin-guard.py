#!/usr/bin/env python3
"""Freeze minimal lazy root-origin refusal on59b36; no targets/cost changes."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
BASE=ROOT/'selfhost/build/phase98/permission-tag-source02/compiler.bend'

def pin(p):
    p=Path(p).resolve();data=p.read_bytes();return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    out=args.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase98') and not out.exists()
    parent=json.loads(BASE.with_name('changes.json').read_text());source=BASE.read_text()
    assert pin(BASE)['sha256']=='59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714'
    old='''@unsafe
def noa_below(+origin: KTerm, +want: KTerm) -> Bool:
  nt_choose(Bool, norm_exact(origin, want), u => True{}, u => p98_tag_eq(origin, "OField") && noa_below(kid(origin, 0), want))
'''
    new='''@unsafe
def noa_below(+origin: KTerm, +want: KTerm) -> Bool:
  nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>
    nt_choose(Bool, p98_tag_eq(origin, "OField"), v => noa_below(kid(origin, 0), want), v => False{}))
'''
    assert source.count(old)==1
    edit=dict(function='noa_below',old=old,new=new,offset=source.index(old))
    result=source.replace(old,new);changes=parent['changes']+[edit]
    original=Path(parent['source']['file']).read_text();replay=original
    for row in changes:
        at=row['offset'];assert replay[at:at+len(row['old'])]==row['old'];replay=replay[:at]+row['new']+replay[at+len(row['old']):]
    assert replay==result
    inverse=result
    for row in reversed(changes):
        at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
    assert inverse==original
    out.mkdir(parents=True);(out/'compiler.bend').write_text(result)
    receipt=dict(kind='phase98-lazy-observer-origin-refusal',complete=True,targetsRun=False,method=pin(__file__),
        source=parent['source'],parentSource=pin(BASE),parentRecipe=pin(BASE.with_name('changes.json')),
        candidate=pin(out/'compiler.bend'),changes=changes,localChanges=[edit],physicalLineDelta=1,
        forwardReplayExact=True,inverseRecoversSource=True,
        scope='Only guard ancestor recursion on OField. Nonmatching non-field origins return False; prior eager conjunction recurses through Absent indefinitely. No cache/redirect/planning-budget changes. Existing successful observer decisions intended unchanged.')
    (out/'changes.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt['candidate']))

if __name__=='__main__':main()
