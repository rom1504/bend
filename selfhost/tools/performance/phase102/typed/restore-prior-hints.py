#!/usr/bin/env python3
"""Offline ablation: restore common NF inline hints from an exact prior emitted C."""
import argparse, hashlib, json, re
from pathlib import Path

def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
def hints(source):
    result={}
    for hint,symbol in re.findall(r'(?m)^(NF_INLINE|INLINE|OUTLINE) Term (NF_FID_[A-Za-z0-9_]+)\(',source):
        assert symbol not in result or result[symbol]==hint
        result[symbol]=hint
    return result
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();before=a.before.read_text();after=a.after.read_text();old=hints(before);new=hints(after);changes=[];source=after
for symbol in sorted(old.keys()&new.keys()):
    if old[symbol]==new[symbol]:continue
    lhs=new[symbol]+' Term '+symbol+'(';rhs=old[symbol]+' Term '+symbol+'('
    assert source.count(lhs)==2
    start=0
    for _ in range(2):
        at=source.index(lhs,start);changes.append(dict(offset=at,old=lhs,new=rhs))
        source=source[:at]+rhs+source[at+len(lhs):];start=at+len(rhs)
inverse=source
for row in reversed(changes):
    at=row['offset'];assert inverse[at:at+len(row['new'])]==row['new'];inverse=inverse[:at]+row['old']+inverse[at+len(row['new']):]
assert inverse==after
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);dest=out/'program.c';dest.write_text(source)
r=dict(complete=True,targetsRun=False,method=pin(__file__),before=pin(a.before),after=pin(a.after),candidate=pin(dest),changes=changes,inverseExact=True,
    changedWorkers=len(changes)//2,scope='Change only declaration/definition inline hint tokens of common named NF workers to their prior values. All candidate bodies and remaining C bytes unchanged. No production changes or performance claim.')
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(candidate=pin(dest),changedWorkers=r['changedWorkers'])))
