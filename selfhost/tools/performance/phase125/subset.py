"""Select already verified emission rows, retaining all original evidence pins."""
import argparse,hashlib,json
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--report',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('names',nargs='+');a=p.parse_args()
r=json.loads(a.report.read_text());assert r['complete'] and not a.out.exists()
for row in r['inputs']:assert pin(row['file'])==row
r['cases']=[c for c in r['cases'] if c['name'] in a.names];assert len(r['cases'])==len(a.names)
r['inputs'] += [pin(a.report),pin(__file__)];r['subsetOf']=pin(a.report)
a.out.write_text(json.dumps(r,indent=2)+'\n')
