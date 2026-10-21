"""Freeze ordinary functional sources and existing independent literal oracles."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=ROOT/'selfhost/tools/performance/phase113/controls/field-array/source-manifest03.json';m=json.loads(old.read_text());rows=[]
for c in m['cases']:
 if c['name']=='shared-array-capture':continue
 rows.append(dict(name=c['name'],source=pin(ROOT/c['source']),expectedStdoutEvidence=pin(ROOT/c['expected']),expected=pin(ROOT/c['expected']),provenance=c['rationale']))
for n in ['array_split_join','array_wrap_index','array_size','array_boxed_get','array_atomic_fadd']:
 p=ROOT/f'tests/run/{n}.bend';so=''.join(x[2:]+'\n' for x in p.read_text().splitlines() if x.startswith('#|'));assert so and 'exit' not in so
 expected=HERE/(n+'.expected.json');assert not expected.exists();expected.write_text(json.dumps(dict(status=0,stdout=so,stderr=''),indent=2)+'\n')
 rows.append(dict(name=n,source=pin(p),expectedStdoutEvidence=pin(expected),expected=pin(expected),provenance='Unchanged upstream ordinary source #| literal oracle; compile and independent native output required.'))
f=ROOT/'selfhost/tools/performance/phase111/coverage/fixtures/arrays-io.bend';o=ROOT/'selfhost/tools/performance/phase111/coverage/expected/arrays-io.json';rows.append(dict(name='arrays-io',source=pin(f),expectedStdoutEvidence=pin(o),expected=pin(o),provenance='Frozen ordinary String array clone independence control.'))
out=HERE/'controls01.json';assert not out.exists();out.write_text(json.dumps(dict(kind='phase117-ordinary-array-transfer',complete=True,targetsRun=False,cases=rows,inputs=[pin(__file__),pin(old)],scope='Independent literal full outputs; no custom failure or memory fault probes.'),indent=2)+'\n');print(len(rows))
