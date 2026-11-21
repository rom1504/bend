"""Static checked-equation admission census and exact-fallback controls."""
from pathlib import Path
import json,hashlib
from stage import transform
P=Path(__file__).resolve().parent

def pin(f):
 f=Path(f);b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
original=Path('selfhost/tools/bench/catalogs/native45/fixtures/lexer.bend').read_text()
output,proof=transform(original);assert proof['admitted'] and output==(P/'candidate-v2.bend').read_text()
rows=[]
for path in sorted(Path('selfhost/tools/bench/catalogs/native45/fixtures').glob('*.bend')):
 source=path.read_text();out,result=transform(source)
 if not result['admitted']:assert out==source
 rows.append(dict(source=pin(path),admitted=result['admitted'],entry=result.get('entry'),outputSha256=hashlib.sha256(out.encode()).hexdigest()))
controls=[]
for label,s in [('changed classifier',original.replace('U32.is_le(c, 122)','U32.is_le(c, 123)')),('changed producer length',original.replace('1 + U32.and(t, 7)','2 + U32.and(t, 7)')),('changed checksum order',original.replace('mix(mix(acc, 1, h), 3, c)','mix(mix(acc, 3, c), 1, h)')),('unsafe attribute',original.replace('def prng(', '@unsafe\ndef prng(')),('adjacent identifiers',original.replace('"i = ( n o i ) o ( n o i ) o ( n o i ) ;"','"ii nn"'))]:
 out,result=transform(s);assert not result['admitted'] and out==s;controls.append(dict(name=label,inputSha256=hashlib.sha256(s.encode()).hexdigest(),unchanged=True))
a=(P/'alternate-original.bend').read_text();out,alternate=transform(a);assert alternate['admitted'] and out==(P/'alternate-staged.bend').read_text()
r=dict(complete=True,scope='Offline source-equation checks, not compiler or target execution.',method=pin(__file__),stage=pin(P/'stage.py'),schema=pin(P/'schema.json'),primaryOutput=pin(P/'candidate-v2.bend'),primaryByteIdentical=True,catalog=rows,controls=controls,alternate=alternate)
(P/'admission.json').write_text(json.dumps(r,indent=2)+'\n');print('admitted',sum(c['admitted'] for c in rows),'of',len(rows),'refusal controls',len(controls))
