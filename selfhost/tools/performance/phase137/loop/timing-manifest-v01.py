"""Freeze native query timing inputs for the existing general profiler."""
import argparse,hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--builds',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--query-repeats',type=int,default=2000);p.add_argument('--record-repeats',type=int,default=262143);a=p.parse_args()
assert not a.out.exists();r=json.loads(a.builds.read_text());assert r['complete']
m=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),scope='Phase137 exact query extraction and unrelated record transfer; not a whole-compiler or representative-program score.',inputs=[pin(__file__),pin(a.builds)],workloads=[])
for name,n,once in [('queries',a.query_repeats,127),('record',a.record_repeats,1)]:
 assert n>0
 w=dict(name=name,timeoutSeconds=30,variants=[])
 for row in r['rows']:
  if not row['name'].startswith(name+'-'):continue
  assert pin(row['binary']['file'])==row['binary'];m['inputs'] += [row['receipt'],row['qbe']]
  w['variants'].append(dict(name=row['role']+'-'+row['name'].split('-',1)[1],binary=row['binary'],command=[row['binary']['file'],'--threads','1','--gpu','off','--',str(n)],expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix=f'{once}\n{once*n%(2**32)}\n'),stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
 assert w['variants'];m['workloads'].append(w)
a.out.write_text(json.dumps(m,indent=2)+'\n')
