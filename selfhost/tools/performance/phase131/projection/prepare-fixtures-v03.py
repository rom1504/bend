"""Complete the corpus annotation, matching the final qualified Phase130 fixture."""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def pin(path):
    path=path.resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
old=json.loads((HERE/'cases-v02.json').read_text());rows=[];edits=[]
for c in old['cases']:
    source=Path(c['source']['file']);assert pin(source)==c['source'];text=source.read_text()
    typ='P130SCase' if c['name']=='projection-string' else 'P131LCase'
    before='+pairs =';after='+pairs : List<&2,'+typ+'> ='
    assert text.count(before)==1;new=text.replace(before,after)
    assert new.replace(after,before)==text
    if c['name']=='projection-string':
        assert new==(ROOT/'selfhost/tools/performance/phase130/scalar/baseline-v05.bend').read_text()
    target=HERE/(c['name']+'-v03.bend');assert not target.exists();target.write_text(new)
    rows.append(dict(c,source=pin(target)))
    edits.append(dict(parent=pin(source),candidate=pin(target),replacement=[before,after],annotationOnly=True))
out=HERE/'cases-v03.json';assert not out.exists()
out.write_text(json.dumps(dict(complete=True,targetsRun=False,cases=rows,edits=edits,
    inputs=[pin(Path(__file__)),pin(HERE/'cases-v02.json'),pin(ROOT/'selfhost/tools/performance/phase130/scalar/baseline-v05.bend')],
    scope='Only missing corpus type annotations. String source is exact final qualified Phase130 baseline-v05; all independent output oracles remain unchanged.'),indent=2)+'\n')
print(str(out))
