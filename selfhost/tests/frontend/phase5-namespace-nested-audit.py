from pathlib import Path
import sys,json,hashlib
root=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();assert not out.exists()
a=root/'tuple-raw-before.json';b=root/'tuple-raw-after.json';x=json.loads(a.read_text());y=json.loads(b.read_text());assert x==y
assert x['error']==''
def errors(t):
 if isinstance(t,dict):
  if t.get('tag')=='Error':yield t
  for v in t.values():yield from errors(v)
 elif isinstance(t,list):
  for v in t:yield from errors(v)
found=list(errors(x));assert found and any('lambda binder' in str(e)for e in found)
p=root/'error-order-v1/selected/paired.json';row=json.loads(p.read_text())['rows'][0];assert row['semanticAgreement'] and row['candidate']['phase']=='parse' and 'lambda binder' in row['candidate']['diagnostic'] and 'lambda binder' in row['reference']['diagnostic']
def id(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
r={'complete':True,'scope':'Earlier nested Error remains in exact raw book; public parser error field is empty in both. Loader rejects with lambda binder error in candidate/live TS. Earlier raw audit incorrectly required nonempty top-level error and remains retained.','inputs':[id(a),id(b),id(p),id(Path(__file__).resolve())],'nestedErrors':found};out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'complete':True,'nestedErrors':len(found)}))
