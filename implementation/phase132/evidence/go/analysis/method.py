"""Compare retained Go cache artifacts; no build or target execution."""
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
RUN=ROOT/'selfhost/build/phase132/go-cache02'
OUT=ROOT/'selfhost/build/phase132/go-analysis01'
assert not OUT.exists(); OUT.mkdir()


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


r=json.loads((RUN/'report.json').read_text());assert r['complete']
inputs=[pin(__file__),pin(RUN/'report.json'),pin(ROOT/'selfhost/build/phase132/go-cache02-guard/process.json')]
baseline={};rows=[]
for s in r['stages']:
    assert s['outputExact']
    row=dict(name=s['name'],buildSeconds=s['build']['wallSeconds'],compilePackages=s['compilePackages'],linkInvocations=s['linkInvocations'],packages=[])
    for p in s['packages']:
        name=p['name']; data=Path(p['exportData']['file']).read_bytes()
        assert pin(p['exportData']['file'])==p['exportData']
        header,marker,payload=data.partition(b'$$B\n');assert marker
        header,n=re.subn(br'(?m)^build id "[^"\n]+"\n',b'',header);assert n==1
        normalized=header+marker+payload
        identity=hashlib.sha256(normalized).hexdigest()
        if s['name']=='00-cold': baseline[name]=(p['buildID'],identity)
        baseid,baseexport=baseline[name]
        row['packages'].append(dict(name=name,buildID=p['buildID'],
            actionIDChanged=p['buildID'].split('/')[0]!=baseid.split('/')[0],
            contentIDChanged=p['buildID'].rsplit('/',1)[-1]!=baseid.rsplit('/',1)[-1],
            exportWithoutBuildIDChanged=identity!=baseexport,
            exportWithoutBuildIDSha256=identity))
        inputs.append(p['exportData'])
    rows.append(row)
out=dict(complete=True,targetsRun=False,inputs=inputs,rows=rows,
    scope='No-op/edit command attribution from original -x logs. Export comparison removes only the known Go object textual build-id header; this diagnostic normalization is not the Go cache algorithm or a complete semantic equivalence test.')
(OUT/'report.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(rows))
