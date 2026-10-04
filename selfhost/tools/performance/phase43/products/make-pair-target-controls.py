"""Separate pair activation sources: leave scalar-precedence controls untouched."""
from pathlib import Path
import hashlib,json
base=Path(__file__).resolve().parent
observer='''\n# Binary recursion keeps this independent consumer outside the older Nat scalar island.\ntype P43Observe is Data:\n  P43Tip{v: U32}\n  P43Branch{l: P43Observe, r: P43Observe}\n\ndef p43.pair.observer(tree: P43Observe, acc: U32) -> U32:\n  match tree:\n    case P43Tip{v}:\n      U32.add(U32.mul(acc, 17), v)\n    case P43Branch{l, r}:\n      p43.pair.observer(r, p43.pair.observer(l, acc))\n'''
for old,new,catalog,out in [('pair-controls.bend','pair-target-controls.bend','fixture-catalog-v4.json','pair-target-catalog-v1.json'),('pair-ignored-controls.bend','pair-ignored-target-controls.bend','pair-ignored-catalog-v2.json','pair-ignored-target-catalog-v1.json')]:
 original=base/'fixtures'/old;s=original.read_text();assert 'U32.add(U32.mul(a, 17), b)'in s
 s=s.replace('U32.add(U32.mul(a, 17), b)','p43.pair.observer(P43Branch{P43Tip{a}, P43Tip{b}}, 0)')+observer
 target=base/'fixtures'/new;assert not target.exists();target.write_text(s);data=target.read_bytes()
 sourceCatalog=json.loads((base/catalog).read_text());cases=[]
 for c in sourceCatalog['cases']:
  if c['source']['path']!='fixtures/'+old:continue
  c['id']=c['id'].replace('products-','products-target-',1);c['source'].update(path='fixtures/'+new,sha256=hashlib.sha256(data).hexdigest(),bytes=len(data),provenance=dict(kind='phase43-independent-pair-target',parentSourceSha256=hashlib.sha256(original.read_bytes()).hexdigest(),design='design/phase43/products.md'));c['description']='Independent pair activation with binary recursive ADT consumer';cases.append(c)
 result=dict(schemaVersion=1,upstreamCommit=sourceCatalog['upstreamCommit'],scope='Actual source pair activation controls; original scalar precedence fixtures remain unchanged',cases=cases,sets={name:[c['id']for c in cases]for name in ['fast','core','broad','full']},oracleProducer=dict(path='make-pair-target-controls.py',sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()))
 (base/out).write_text(json.dumps(result,indent=2)+'\n');print(base/out)
