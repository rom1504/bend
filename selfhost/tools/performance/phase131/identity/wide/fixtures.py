"""Freeze identical independent controls and two timed whole-query workloads."""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
def pin(p):
    p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def put(p,text):
    if p.exists():assert p.read_text()==text
    else:p.write_text(text)

source=(HERE/'prefix.bend').read_text()+'\n'+(HERE/'workload.bend').read_text()
old='U32.add(Bool.to_u32(p131w_query(record,key)),Bool.to_u32(p131w_query(record,"different")))'
new='U32.add(Bool.to_u32(p131w_query9(other,key)),Bool.to_u32(p131w_query9(other,"different")))'
assert source.count(old)==1
expected='1\n0\n1\n1\n17\n1\n0\n3\n1\n0\n1\n'
for file,data in [('expected.stdout',expected),('expected.json',json.dumps(dict(status=0,stdout=expected,stderr=''),indent=2)+'\n')]:
    put(HERE/file,data)
cases=[]
for name,text in [('compiler-kdef',source),('record-transfer',source.replace(old,new))]:
    p=HERE/(name+'.bend');put(p,text)
    cases.append(dict(name=name,source=pin(p),expected=pin(HERE/'expected.json'),expectedStdoutEvidence=pin(HERE/'expected.json')))
(HERE/'cases.json').write_text(json.dumps(dict(complete=True,cases=cases),indent=2)+'\n')
(HERE/'oracle.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(HERE/'prefix.bend'),pin(HERE/'workload.bend')],
    expected=pin(HERE/'expected.stdout'),cases=cases,
    explanation='Actual selected KDef/dn/da bodies and KTerm representation. Equal/mismatched name, index leaf empty-name, retainedarity17, unrelated nine-field record names, retainedopaque list length3, sixteen-field record names and Unicode. Timed hit+miss returns1 per iteration in either unrelated family. Expected values derived from construction, not target outputs.'),indent=2)+'\n')
