"""Authenticate and compare complete checked-Bend ordinary products, no targets."""
import argparse,filecmp,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
def pin(f):
 p=Path(f).resolve();h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def read(p):return json.loads(Path(p).read_text())
a=argparse.ArgumentParser(description=__doc__)
for k in ['manifest','baseline','candidate','out']:a.add_argument('--'+k,type=Path,required=True)
a=a.parse_args();assert not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase144')
m=read(a.manifest);assert [x['name'] for x in m['cases']]==['lexer','coverage-map-churn-128','coverage-closures-256']
inputs=[pin(__file__),pin(a.manifest),*m['inputs']];reports={}
for role in ['baseline','candidate']:
 r=read(getattr(a,role));ar=read(m[role+'Api']['file']);assert r['complete'] and ar['complete'] and ar['checked'] and ar['status']==0
 assert ar['api'] in r['inputs'] and m[role+'Api'] in r['inputs'] and m[role+'Source'] in ar['inputs']
 assert [x['name'] for x in r['cases']]==[x['name'] for x in m['cases']]
 assert r['runtime']==m['runtime'];inputs.extend([pin(getattr(a,role)),*r['inputs']]);reports[role]=r
for p in inputs:verify(p)
a.out.parent.mkdir(parents=True,exist_ok=True);result=dict(kind='phase144-predicate-complete-qbe-comparison',complete=False,inputs=inputs,cases=[],scope='Three current complete hosted QBE products from independently checked source02/source03. Exact source/expected-output identities retained. No program execution, performance or native self-hosting claim.')
try:
 for c,x,y in zip(m['cases'],reports['baseline']['cases'],reports['candidate']['cases']):
  assert x['source']==y['source']==c['source'] and x['expected']==y['expected']==c['stdoutEvidence']
  assert x['verified'] and y['verified'];verify(x['qbe']);verify(y['qbe'])
  exact=(x['qbe']['bytes'],x['qbe']['sha256'])==(y['qbe']['bytes'],y['qbe']['sha256']) and filecmp.cmp(x['qbe']['file'],y['qbe']['file'],shallow=False)
  result['cases'].append(dict(name=c['name'],source=c['source'],expected=c['stdoutEvidence'],baseline=x['qbe'],candidate=y['qbe'],exact=exact));assert exact,c['name']
 for p in inputs:verify(p)
 result['complete']=True
except BaseException as e:result['error']=repr(e);raise
finally:a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,cases=len(result['cases']),report=pin(a.out))))
