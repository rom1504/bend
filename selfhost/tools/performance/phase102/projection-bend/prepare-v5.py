#!/usr/bin/env python3
"""Compose a bounded observer/projection certificate on an isolated Bend recipe."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--parent',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();parent=json.loads(a.parent.read_text());assert parent['complete'] and parent['inverseExact']
    for item in (parent['source'],parent['candidate']):assert pin(item['file'])==item
    source=Path(parent['candidate']['file']).read_text()
    old='        nfo_admit(book, nfo_aliases(workers, book_cached(entries, 0), oldReady, ready), ready, observers))'
    new='        nfp_finish(book, book_cached(entries, 0), nfo_admit(book, nfo_aliases(workers, book_cached(entries, 0), oldReady, ready), ready, observers)))'
    assert source.count(old)==1
    at=source.index(old);candidate=source[:at]+new+source[at+len(old):]
    helpers='\n'+(HERE/'helpers-v5.bend').read_text()
    edits=[dict(offset=at,old=old,new=new),dict(offset=len(candidate),old='',new=helpers)]
    candidate+=helpers;changes=parent['changes']+edits;inverse=candidate
    for c in reversed(changes):
        at=c['offset'];assert inverse[at:at+len(c['new'])]==c['new']
        inverse=inverse[:at]+c['old']+inverse[at+len(c['new']):]
    assert inverse==Path(parent['source']['file']).read_text()
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase102');out.mkdir(parents=True,exist_ok=False)
    dest=out/'compiler.bend';dest.write_text(candidate)
    report=dict(complete=True,targetsRun=False,releaseQualified=False,method=pin(__file__),helpers=pin(HERE/'helpers-v5.bend'),
        parentRecipe=pin(a.parent),parentCandidate=parent['candidate'],source=parent['source'],candidate=pin(dest),
        changes=changes,addedChanges=edits,inverseExact=True,physicalLineDelta=len(candidate.splitlines())-len(source.splitlines()),
        scope='Existing accepted NOObserverEntry authority plus bounded pure projection of its known wrapper. '
              'Reuses no_adapter owning cleanup; no runtime/public ABI change, name-specific rule or new observer proof.')
    (out/'changes.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ('candidate','physicalLineDelta')}))

if __name__=='__main__':main()
