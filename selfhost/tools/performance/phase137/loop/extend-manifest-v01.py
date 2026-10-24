"""Add already built query variants to a frozen same-workload timing manifest."""
import argparse,hashlib,json,pathlib,copy
p=argparse.ArgumentParser();p.add_argument('--reference',type=pathlib.Path,required=True);p.add_argument('--builds',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--prefix',default='');a=p.parse_args()
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not a.out.exists();m=json.loads(a.reference.read_text());r=json.loads(a.builds.read_text());assert r['complete'];m['inputs'] += [pin(__file__),pin(a.reference),pin(a.builds)]
for row in r['rows']:
 name,variant=row['name'].split('-',1);w=next(w for w in m['workloads'] if w['name']==name)
 t=copy.deepcopy(w['variants'][0]);t['name']=a.prefix+row['role']+'-'+variant;assert all(v['name']!=t['name'] for v in w['variants'])
 assert pin(row['binary']['file'])==row['binary'];t['binary']=row['binary'];t['command'][0]=row['binary']['file'];w['variants'].append(t);m['inputs'] += [row['receipt'],row['qbe']]
a.out.write_text(json.dumps(m,indent=2)+'\n')
