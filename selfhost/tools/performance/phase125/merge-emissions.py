"""Merge complete disjoint emission batches with identical producer identities."""
import argparse,hashlib,json
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('reports',nargs='+',type=Path);a=p.parse_args();assert not a.out.exists()
reports=[json.loads(f.read_text()) for f in a.reports];r=dict(reports[0]);r['cases']=[];r['inputs']=[];seen=set()
for file,e in zip(a.reports,reports):
 assert e['complete'] and all(e[k]==r[k] for k in ['source','api','runtime'])
 for x in e['inputs']:assert pin(x['file'])==x
 for c in e['cases']:
  assert c['name'] not in seen and c['verified'] and pin(c['qbe']['file'])==c['qbe'];seen.add(c['name']);r['cases'].append(c)
 r['inputs'] += [pin(file),*e['inputs']]
r['inputs'].append(pin(__file__));r['mergedFrom']=[pin(f) for f in a.reports];r['seconds']=sum(e['seconds'] for e in reports);r['prepareSeconds']=sum(e['prepareSeconds'] for e in reports)
a.out.write_text(json.dumps(r,indent=2)+'\n')
