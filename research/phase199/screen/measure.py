"""One frozen balanced campaign; existing Phase93 output/count validation."""
import argparse,hashlib,json,os,statistics,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute
p=argparse.ArgumentParser();p.add_argument('--products',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--only-folds',action='store_true');a=p.parse_args()
assert os.sched_getaffinity(0)=={3};a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(v):assert pin(v['file'])==v,v['file']
products=read(a.products);assert products['complete'];study=read(products['study']['file']);verify(products['study'])
for v in products['inputs']:verify(v)
for c in products['cases'].values():
 for arm in c['arms'].values():
  for v in arm['products'].values():verify(v['artifact'])
r=dict(complete=False,method=pin(__file__),products=pin(a.products),study=products['study'],rounds=5,targetMs=160,roles=study['roles'],reference='baseline',samples=[],pilots=[],groups=[],scope='Two live-runtime link layouts plus original-runtime fold3 cross-check. Five cyclic role positions over five rounds. Baseline and SIMD share helper/runtime/link order; delegate uses identical candidate object and scalar helper. No whole-catalog timing claim.')
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
groups=[]
for name,c in products['cases'].items():
 if a.only_folds and 'local-fold' not in name:continue
 for arm,data in c['arms'].items():
  if arm.startswith('live/') or ('local-fold' in name and arm=='original/'+study['layouts'][0]):groups.append((name,arm,data))
def observe(name,data,role,n,w):
 c=products['cases'][name];prod=data['products'][role];return execute(prod['artifact']['file'],c['point']['runtimeArgs'],n,w,c['point']['expectedStdout'],prod['runtimeArgumentConvention'])[0]
r['selectedCases']=sorted({x[0] for x in groups});r['onlyFolds']=a.only_folds
counts={};start=time.monotonic();save()
try:
 for name,arm,data in groups:
  for role in study['roles']:
   n=100
   for attempt in range(15):
    obs=observe(name,data,role,n,0);ms=obs['elapsedMs'];r['pilots'].append(dict(case=name,arm=arm,role=role,repetitions=n,**obs));save()
    if 130<=ms<=240:break
    n=max(1,min(100000000,int(n*160/max(1,ms))))
   else:raise ValueError('calibration '+name+'/'+arm+'/'+role)
   counts[name,arm,role]=n
 for round in range(5):
  ordered=list(enumerate(groups));ordered=ordered[::-1] if round%2 else ordered
  for group,(name,arm,data) in ordered:
   roles=study['roles'];shift=(round+group)%len(roles);roles=roles[shift:]+roles[:shift]
   for position,role in enumerate(roles):
    n=counts[name,arm,role];obs=observe(name,data,role,n,4);assert obs['elapsedMs']>=100
    r['samples'].append(dict(case=name,arm=arm,role=role,round=round,position=position,repetitions=n,nsPerWork=obs['elapsedMs']*1e6/n,observation=obs));save()
 for name,arm,data in groups:
  rates={role:[x['nsPerWork'] for x in r['samples'] if x['case']==name and x['arm']==arm and x['role']==role] for role in study['roles']}
  ratios={}
  for role in study['roles']:
   pairs=[rates[role][i]/rates['baseline'][i] for i in range(5)];ratios[role]=dict(median=statistics.median(pairs),pairs=pairs)
  r['groups'].append(dict(case=name,arm=arm,nsPerWork={k:statistics.median(v) for k,v in rates.items()},againstMatchedBaseline=ratios,simdOverC=statistics.median([rates['simd'][i]/rates['c'][i] for i in range(5)]),simdOverDelegate=statistics.median([rates['simd'][i]/rates['delegate'][i] for i in range(5)])))
 for c in products['cases'].values():
  for arm in c['arms'].values():
   for v in arm['products'].values():verify(v['artifact'])
 r.update(complete=True,positionBalanced=True,seconds=time.monotonic()-start);save();print([(g['case'],g['arm'],g['againstMatchedBaseline']['simd']['median']) for g in r['groups']])
except BaseException as error:r.update(error=repr(error),seconds=time.monotonic()-start);save();raise
