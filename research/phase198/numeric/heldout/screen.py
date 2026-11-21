"""Two ordinary newly authored programs: native baseline/orbit and independent C."""
from pathlib import Path
import argparse,json,subprocess,time,os,sys,statistics,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute,checked_tool,bench
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out
assert os.sched_getaffinity(0)=={3};out.mkdir(parents=True,exist_ok=False);start=time.monotonic()
def pin(p):
 p=Path(p);return dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
read=lambda p:json.loads(Path(p).read_text())
frozen=read(HERE/'frozen.json');plan=ROOT/'selfhost/build/phase198/numeric-heldout-plan01.json';assets=read(ROOT/'selfhost/build/phase194/assets.json')
r=dict(complete=False,method=pin(Path(__file__)),freeze=pin(HERE/'frozen.json'),plan=pin(plan),commands=[],cases={},samples=[],pilots=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,timeout=15):
 before=time.monotonic();child=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=timeout);idx=len(r['commands'])
 for name,txt in [('stdout',child.stdout),('stderr',child.stderr)]: (out/(str(idx)+'-'+name)).write_text(txt)
 r['commands'].append(dict(argv=list(map(str,cmd)),exit=child.returncode,seconds=time.monotonic()-before,stdout=pin(out/(str(idx)+'-stdout')),stderr=pin(out/(str(idx)+'-stderr'))));save();assert child.returncode==0,(cmd,child.stderr[-3000:]);return child
try:
 run([ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tests/phase195/prepared-emission/driver.mjs','--plan',plan,'--out',out/'emission'],55)
 emitted={role:read(out/'emission'/role/'report.json') for role in ['baseline','orbit']};assert all(x['complete'] for x in emitted.values())
 linker,runtime,clang=[checked_tool(assets['assets'][k]) for k in ['linker','qbe-runtime','clang']]
 for case in frozen['cases']:
  id=case['id'];products={}
  for role in ['baseline','orbit']:
   row=next(x for x in emitted[role]['rows'] if x['id']==id);obj=checked_tool(row['product']);exe=out/(id+'-'+role)
   run([linker,'-no-pie',obj,runtime,'-pthread','-lm','-o',exe]);products[role]=dict(binary=pin(exe),object=row['product'],assembly=row['assembly'])
  exe=out/(id+'-c');run([clang,*assets['toolchains']['c']['includeFlags'],'-std=c11','-O3','-D_POSIX_C_SOURCE=200809L','-DCYCLING='+str(int(id.endswith('cycling'))),HERE/'oracle.c','-o',exe]);products['c']=dict(binary=pin(exe),source=pin(HERE/'oracle.c'),scope='Independent handwritten C, same unsigned iterative semantics, no fixed-state shortcut; not a mature Bend C-backend product.')
  r['cases'][id]=dict(point=case['point'],expected=str(case['expected'])+'\n',products=products,checks=[],counts={},ratios={})
  for point in case['oracle']:
   for role in products:
    exe=products[role]['binary']['file'];expected=str(point['expected'])+'\n'
    if role=='c':
     child=subprocess.run([exe,'0','0',*map(str,point['args'])],capture_output=True,timeout=10);wall=0;bench.observation(child.stdout,child.stderr,child.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),wall)
    else:execute(exe,point['args'],0,0,expected)
    r['cases'][id]['checks'].append(dict(role=role,args=point['args'],expected=expected))
  save()
 def observe(id,role,n,w):
  c=r['cases'][id];exe=c['products'][role]['binary']['file']
  if role!='c':return execute(exe,c['point'],n,w,c['expected'])[0]
  before=time.monotonic();child=subprocess.run([exe,str(n),str(w),*map(str,c['point'])],capture_output=True,timeout=12);wall=time.monotonic()-before
  ms=bench.observation(child.stdout,child.stderr,child.returncode,dict(expectedStdout=c['expected'],repetitions=n,warmups=w),wall);return dict(stdout=child.stdout.decode(),elapsedMs=ms,wall=wall)
 for id,c in r['cases'].items():
  for role in c['products']:
   n=100
   for attempt in range(10):
    obs=observe(id,role,n,0);ms=obs['elapsedMs'];r['pilots'].append(dict(case=id,role=role,repetitions=n,**obs));save()
    if 120<=ms<=300:break
    n=max(1,int(n*160/max(1,ms)))
   else:raise ValueError('calibration '+id+'/'+role)
   c['counts'][role]=n
 for round in range(6):
  cases=list(r['cases']);cases=cases[::-1] if round%2 else cases
  for idx,id in enumerate(cases):
   c=r['cases'][id];roles=list(c['products']);shift=(round+idx)%3;roles=roles[shift:]+roles[:shift]
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
