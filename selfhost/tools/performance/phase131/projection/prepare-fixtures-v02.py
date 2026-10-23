"""Add only explicit local types; preserve failed sources and independent oracles."""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def pin(path):
    path=path.resolve();b=path.read_bytes()
    return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=json.loads((HERE/'cases-v01.json').read_text());rows=[];edits=[]
for case in old['cases']:
    source=Path(case['source']['file']);assert pin(source)==case['source'];text=source.read_text()
    changes=([('+suffix =','+suffix : String ='),('+left =','+left : String ='),('+right =','+right : String =')]
        if case['name']=='projection-string' else
        [('+tail =','+tail : P131List ='),('+a =','+a : P131List ='),('+b =','+b : P131List =')])
    for before,after in changes:
        assert text.count(before)==1;(text,count)=(text.replace(before,after),text.count(before))
    target=HERE/(case['name']+'-v02.bend');assert not target.exists();target.write_text(text)
    restored=text
    for before,after in changes:restored=restored.replace(after,before)
    assert restored==source.read_text()
    rows.append(dict(case,source=pin(target)))
    edits.append(dict(parent=pin(source),candidate=pin(target),replacements=changes,annotationOnly=True))
manifest=dict(complete=True,targetsRun=False,cases=rows,edits=edits,
    inputs=[pin(Path(__file__)),pin(HERE/'cases-v01.json')],
    scope='Only explicit local String/P131List annotations; same sources for both compiler variants. All comparison algorithms and independent ordinary oracles unchanged.')
target=HERE/'cases-v02.json';assert not target.exists();target.write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(target),edits=edits)))
