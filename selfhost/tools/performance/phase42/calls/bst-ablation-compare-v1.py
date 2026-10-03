"""Create exact mechanism-comparison config; no compiler/target execution."""
from pathlib import Path
import sys,json,hashlib
folder=Path(sys.argv[1]).resolve();controls=Path(sys.argv[2]).resolve();out=Path(sys.argv[3]).resolve();assert not out.exists()
d=json.loads((folder/'derive.json').read_text());c=json.loads(controls.read_text());assert d['kind']=='phase42-structural-actual-ablation';assert d['complete']and d['parentChecked']and not d['checked'];assert c['complete']and c['pass']and c['domain']==d['domain']
def identity(p):
 p=Path(p).resolve();return {'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
assert identity(folder/'derive.json')['sha256']==c['derive']['sha256']
modules={}
for r in d['modules']:
 row=r['clean'];assert identity(row['path'])['sha256']==row['sha256'];modules[{'original':'checked13-original','candidate':'candidate','typescript':'typescript'}[r['role']]]=row['path']
MASK=2**32-1
cases=[]
if d['domain']=='sequential':
 for size in [32,128]:
  for export,mode in [('sequence.right','sum'),('sequence.weight','weighted'),('sequence.reverse','mirror')]:
   value=17
   for i in range(size-1,-1,-1):
    value=((value+17+i)if mode=='sum'else(value*10+17+i)if mode=='weighted'else(17+i-value))&MASK
   cases.append({'id':export.replace('.','-')+'-'+str(size)+'-17','point':{'exportName':export,'args':[size,17],'expected':value},'modules':modules})
else:
 assert d['domain']=='bst'
 for size in [32,128]:
  seed=17;t=None
  # Independent plain integer insertion; duplicate words go right.
  for i in range(size):
   x=(((i*((seed*2+1)&MASK))&MASK)+seed)&MASK;x%=257
   if t is None:t=[None,x,None];continue
   cur=t
   while True:
    side=0 if x<cur[1]else 2
    if cur[side]is None:cur[side]=[None,x,None];break
    cur=cur[side]
  cur=t;stack=[];value=0
  while cur is not None or stack:
   while cur is not None:stack.append(cur);cur=cur[0]
   cur=stack.pop();value=(value*10+cur[1])&MASK;cur=cur[2]
  cases.append({'id':'bst-matched-'+str(size)+'-17','point':{'exportName':'bench','args':[size,17],'expected':value},'modules':modules})
report={'kind':'phase42-bst-private-worker-ablation-comparison','scope':'Exact checked13 original vs unchecked saved-JS private-worker derivative and pinnedTS; not a checked source candidate','inputs':[str(folder/'derive.json'),str(controls),d['baselineAttempt']['path'],d['attempt']['path']],'producer':identity(__file__),'cases':cases}
out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'output':str(out),'cases':len(cases)}))
