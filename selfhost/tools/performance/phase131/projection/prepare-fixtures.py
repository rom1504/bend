"""Pin unchanged String workload and unrelated product; ordinary mathematical oracle."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
def pin(path):
    path=path.resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def pairs(n):
    p=[7]*n
    return [(p,p),(p,p+[1]),(p+[1],p),(p+[2],p+[9]),(p+[9],p+[2]),
            (p+[5],p+[5]),(p,[0]+p),([0]+p,p),([0]+p,[1]+p),(p+[57344],p+[65536])]
def digest(n):
    value=2166136261
    for a,b in pairs(n): value=(value*16777619+(1 if a<b else 3 if a>b else 2)) & 0xffffffff
    return value
expected=HERE/'list-expected-v01.json'
data=dict(status=0,stdout=''.join(str(n)+'\n' for n in [*(digest(n)for n in [0,1,17,128]),1,129]),stderr='')
assert not expected.exists() and not (HERE/'cases-v01.json').exists()
expected.write_text(json.dumps(data,indent=2)+'\n')
old=ROOT/'selfhost/tools/performance/phase130/scalar'
manifest=dict(complete=True,targetsRun=False,inputs=[pin(Path(__file__)),pin(old/'cases-v04.json')],cases=[
    dict(name='projection-string',source=pin(old/'baseline-v04.bend'),expected=pin(old/'expected.json'),expectedStdoutEvidence=pin(old/'expected.json')),
    dict(name='projection-list',source=pin(HERE/'list-workload-v01.bend'),expected=pin(expected),expectedStdoutEvidence=pin(expected))],
    scope='Same ordinary source for parent and candidate compilers. Existing String oracle; independent lexicographic U32-list oracle. No target executed or output learned.')
(HERE/'cases-v01.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest))
