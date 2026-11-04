#!/usr/bin/env python3
"""Complete captured-owner outputs and balanced fresh-process measurements."""
import argparse,itertools,json,os,statistics,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,write_json,require,same_bytes
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--source',type=Path,default=ROOT/'selfhost/tests/phase157/workload-compatible.bend')
p.add_argument('--fixed-count',type=int,choices=[1])
p.add_argument('--roles',nargs='+',default=['upstream02','qbe02','gc03'])
p.add_argument('--control-only',action='store_true');p.add_argument('--budget',type=float,default=240)
a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
roles=a.roles;require(1<=len(roles)<=4,'Bounded role set required')
source=pin(a.source.resolve())
book=pin(ROOT/'selfhost/build/phase154/book-fixtures01/compiler-verifier-slice.book.txt')
oracle=pin(ROOT/'selfhost/build/phase154/native-plan03/0-expected.stdout')
require(oracle['sha256']=='9c08e21b3f5eac0bf17c1be4fcb76fe1fda79f8faadbf99469dfb03c3399f82e','Oracle changed')
inputs=[source,book,oracle,pin(__file__),pin(ROOT/'selfhost/tools/build/common.py')]
bins={k:pin(ROOT/'selfhost/build/phase157'/k/'program')for k in roles}
inputs+=list(bins.values());inputs +=[pin(ROOT/'selfhost/build/phase157'/k/'report.json')for k in roles]
for role in roles:
 receipt=json.loads((ROOT/'selfhost/build/phase157'/role/'report.json').read_text())
 require(receipt.get('complete'),'Unbuilt role: '+role)
 bound=receipt['request']['source']if role.startswith('qbe')else receipt['source']
 require(bound==source,'Roles must use identical source: '+role)
 require((receipt.get('binary')or receipt.get('product'))==bins[role],'Binary receipt differs: '+role)
env=dict(os.environ)
for k in list(env):
 if k.startswith('BEND_')or k in ['LD_PRELOAD','LD_AUDIT']:del env[k]
r=dict(kind='phase157-same-workload',complete=False,inputs=inputs,roles=roles,calls=[],affinity=sorted(os.sched_getaffinity(0)),runtime=['--threads','1','--gpu','off'],scope='Fresh process, complete input/context preparation, repeated five-owner lowering/scalar/verifier/render/write, teardown. Not a whole compiler request.')
started=time.monotonic()
def save():write_json(out/'report.json',r)
def invoke(role,mode,count,kind):
 require(time.monotonic()-started<a.budget,'Campaign budget exceeded')
 d=out/str(len(r['calls']));d.mkdir()
 # Upstream and bendc IO.args include argv[0]; qualified QBE omits it.
 # A common exec wrapper presents identical logical Bend arguments to each.
 args=['compiler-work',mode,str(count)] if role.startswith('qbe') else [mode,str(count)]
 process=run(['bash','-c','exec -a compiler-work "$@"','phase157',bins[role]['file'],'--threads','1','--gpu','off','--',*args],cwd=ROOT,stdout=d/'stdout',stderr=d/'stderr',seconds=min(30,a.budget-(time.monotonic()-started)),env=env)
 row=dict(role=role,mode=mode,repeats=count,kind=kind,process=process,passed=False);r['calls'].append(row);save()
 require(process['complete']and process['stderr']['bytes']==0,'Program failed: '+role)
 require(same_bytes(d/'stdout',oracle['file'])if mode=='oracle'else process['stdout']['bytes']==0,'Output differs: '+role)
 row['passed']=True;save();return row
try:
 for role in roles:invoke(role,'oracle',1,'before-oracle')
 if not a.control_only:
  zeros=[invoke(role,'bench',0,'zero-repeat')for role in roles]
  minimum=.2 if a.fixed_count else max(.2,3*max(x['process']['seconds']for x in zeros));r['minimumSeconds']=minimum
  r['countPolicy']='single-batch latency including setup'if a.fixed_count else 'amortized repeated-owner throughput including setup'
  count=1
  while not a.fixed_count:
   rows=[invoke(role,'bench',count,'calibration')for role in roles]
   if min(x['process']['seconds']for x in rows)>=minimum:break
   require(count<65536,'Insufficient signal');count*=4
  r['repeats']=count
  orders=([[0,1,2,3],[1,3,0,2],[2,0,3,1],[3,2,1,0]]if len(roles)==4 else list(itertools.permutations(range(len(roles))))* (2 if len(roles)==2 else 1))
  r['orders']=orders
  for i,order in enumerate(orders):
   for j in order:invoke(roles[j],'bench',count,'timed')
  for role in reversed(roles):invoke(role,'oracle',1,'after-oracle')
  r['summary']={}
  for role in roles:
   rows=[x['process']for x in r['calls']if x['role']==role and x['kind']=='timed']
   r['summary'][role]=dict(medianSeconds=statistics.median(x['seconds']for x in rows),medianCpuSeconds=statistics.median(x['userSeconds']+x['systemSeconds']for x in rows),maximumRssKiB=max(x['peakRssKiB']for x in rows),seconds=[x['seconds']for x in rows])
  r['resolved']=all(x['process']['seconds']>=.8*minimum for x in r['calls']if x['kind']=='timed')
 for x in inputs:verify(x)
 r['complete']=True
except Exception as e:r['error']=repr(e)
r['totalSeconds']=time.monotonic()-started;save();print(json.dumps({k:v for k,v in r.items()if k not in ['inputs','calls']}));sys.exit(0 if r['complete']else 1)
