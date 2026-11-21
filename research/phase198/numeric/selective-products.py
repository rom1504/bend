"""Four actual programs after a static refusal; byte identity before fresh timing."""
from pathlib import Path
import argparse,json,subprocess,time,os,sys,statistics,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute,checked_tool,bench
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out
assert os.sched_getaffinity(0)=={3};out.mkdir(parents=True,exist_ok=False);start=time.monotonic()
def pin(p):
 p=Path(p);return dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
read=lambda p:json.loads(Path(p).read_text())
plan=ROOT/'selfhost/build/phase198/numeric-selective-plan01.json';assets=read(ROOT/'selfhost/build/phase194/assets.json')
measured=read(ROOT/'selfhost/build/phase198/numeric-products03/report.json');held=read(ROOT/'selfhost/build/phase198/numeric-heldout01/report.json')
r=dict(complete=False,method=pin(Path(__file__)),plan=pin(plan),predecessors=[pin(ROOT/'selfhost/build/phase198/numeric-products03/report.json'),pin(ROOT/'selfhost/build/phase198/numeric-heldout01/report.json')],commands=[],cases={},samples=[],pilots=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,timeout=15):
 before=time.monotonic();child=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=timeout);idx=len(r['commands'])
 for name,txt in [('stdout',child.stdout),('stderr',child.stderr)]: (out/(str(idx)+'-'+name)).write_text(txt)
 r['commands'].append(dict(argv=list(map(str,cmd)),exit=child.returncode,seconds=time.monotonic()-before,stdout=pin(out/(str(idx)+'-stdout')),stderr=pin(out/(str(idx)+'-stderr'))));save();assert child.returncode==0,(cmd,child.stderr[-3000:],child.stdout[-1000:]);return child
try:
 run([ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tests/phase195/prepared-emission/driver.mjs','--plan',plan,'--out',out/'emission'],65)
 emitted=read(out/'emission/selective/report.json');assert emitted['complete']
 linker,runtime=[checked_tool(assets['assets'][k]) for k in ['linker','qbe-runtime']]
 for row in emitted['rows']:
  id=row['id'];isHeld=id.startswith('orbit-');old=(held if isHeld else measured)['cases'][id]
  products={}
  for role,key in [('baseline','baseline'),('old','orbit' if isHeld else 'numeric'),('c','c')]:
   product=old['products'][key];products[role]=dict(product,convention=('plain-four' if role=='c' else 'bend-rts-v1') if isHeld else product['convention'])
  exe=out/(id+'-selective');run([linker,'-no-pie',checked_tool(row['product']),runtime,'-pthread','-lm','-o',exe]);products['selective']=dict(binary=pin(exe),object=row['product'],assembly=row['assembly'],convention='bend-rts-v1')
  expectedRole='baseline' if id=='orbit-cycling' else 'old'
  expectedObject=products[expectedRole].get('object')
  if not expectedObject:
   expectedObject=next(x for x in read(ROOT/'selfhost/build/phase198/numeric-heldout01/emission/baseline/report.json')['rows'] if x['id']==id)['product']
  actual=row['product'];assert actual['sha256']==expectedObject['sha256'] and actual['bytes']==expectedObject['bytes'],id+' unexpected machine bytes'
  point=old['point'] if isHeld else old['point']['runtimeArgs'];expected=old['expected'] if isHeld else old['point']['expectedStdout']
  checks={tuple(c['args']):c['expected'] for c in old['checks']}
  r['cases'][id]=dict(point=point,expected=expected,products=products,checks=[],counts={},ratios={},exactObjectRole=expectedRole,exactObject=expectedObject,objectBytesExact=True)
  for p in products.values():checked_tool(p['binary'])
  save()
 def observe(id,role,n,w,args=None,want=None):
  c=r['cases'][id];product=c['products'][role];exe=product['binary']['file'];args=args or c['point'];want=want or c['expected']
  if product['convention']!='plain-four':return execute(exe,args,n,w,want,product['convention'])[0]
  before=time.monotonic();child=subprocess.run([exe,str(n),str(w),*map(str,args)],capture_output=True,timeout=12);wall=time.monotonic()-before
  ms=bench.observation(child.stdout,child.stderr,child.returncode,dict(expectedStdout=want,repetitions=n,warmups=w),wall);return dict(stdout=child.stdout.decode(),elapsedMs=ms,wall=wall)
 for id,c in r['cases'].items():
  old=(held if id.startswith('orbit-') else measured)['cases'][id];points={tuple(v['args']):v['expected'] for v in old['checks']}
  for args,want in points.items():
   for role in c['products']:
    obs=observe(id,role,0,0,list(args),want);c['checks'].append(dict(role=role,args=list(args),expected=want,observation=obs))
  save()
  for role in c['products']:
   n=100
   for attempt in range(10):
    obs=observe(id,role,n,0);ms=obs['elapsedMs'];r['pilots'].append(dict(case=id,role=role,repetitions=n,**obs));save()
    if 120<=ms<=300:break
    n=max(1,int(n*160/max(1,ms)))
   else:raise ValueError('calibration '+id+'/'+role)
   c['counts'][role]=n
 for round in range(6):
  cases=list(r['cases']);shift=round%len(cases);cases=cases[shift:]+cases[:shift]
  if round%2:cases=cases[::-1]
  for idx,id in enumerate(cases):
   c=r['cases'][id];roles=list(c['products']);shift=(round+idx)%len(roles);roles=roles[shift:]+roles[:shift]
   if round%2:roles=roles[::-1]
   for role in roles:
    n=c['counts'][role];obs=observe(id,role,n,4);assert obs['elapsedMs']>=100;r['samples'].append(dict(case=id,role=role,round=round,repetitions=n,nsPerWork=obs['elapsedMs']*1e6/n,observation=obs));save()
 for id,c in r['cases'].items():
  for role in c['products']:
   pairs=[]
   for round in range(6):
    rows={x['role']:x['nsPerWork'] for x in r['samples'] if x['case']==id and x['round']==round};pairs.append(rows[role]/rows['baseline'])
   c['ratios'][role]=dict(median=statistics.median(pairs),pairs=pairs)
 r['complete']=True;r['seconds']=time.monotonic()-start;save();print({k:v['ratios'] for k,v in r['cases'].items()})
except Exception as e:r['error']=str(e);r['seconds']=time.monotonic()-start;save();raise
