#!/usr/bin/env python3
"""Publish an explicit scope correction without changing frozen measurements."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
base=ROOT/'selfhost/build/phase145/upstream-full-parse01'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=base/'summary01.json';doc=json.loads(old.read_text());assert doc['complete']
for group in doc['rows'].values():
 for row in group.values():
  assert row['loaded']['erasedBodies']==0
  assert not any(k.startswith(('check:','emit:')) for k in row['counts'])
for label in ['original','counted']:
 report=json.loads((base/('full-phase142-'+label)/'report.json').read_text())
 assert report['fixture']['mode']=='parse-only' and not any(k in report['timings']for k in ['check','emit'])
doc['kind']='phase145-full-upstream-parse-comparison-v2';doc['inputs'] += [pin(__file__),pin(old)]
doc['scopeCorrection']=dict(originalMeasurementsUnchanged=True,
 inaccurateBoilerplate='The generic worker scope says Base loaded and checked every request.',
 actual='In both prefix and full parse-only observations, Base is loaded and parsed, never checked. book_valid is not called; no check/emission timing occurs and erasedBodies remains0.',
 historicalNativeComparison='The31.175s Phase144 parser proxy uses the older atomic runtime and additional lexical/context/validation/freshening work. Its contrast with2.583s upstream cannot be attributed solely to String or called an equivalent parser replacement.')
out=base/'summary02.json';assert not out.exists();out.write_text(json.dumps(doc,indent=2)+'\n');print(out)
