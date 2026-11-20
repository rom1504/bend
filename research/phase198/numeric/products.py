"""Checked numeric controls, exact whole-program emission, and focused transfer screen."""
from pathlib import Path
import argparse,json,os,statistics,subprocess,sys,time
from prepare import ROOT,HERE,read,pin,SYMBOL
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS,REFERENCES,checked_tool,execute
CASES=['mandelbrot','variation-mandelbrot-grid-4-7','variation-mandelbrot-grid-5-31','scalar-region-8192']
EXTRA={'mandelbrot':[(0,0),(4,7)],'variation-mandelbrot-grid-4-7':[(2,0),(3,31)],'variation-mandelbrot-grid-5-31':[(2,0),(3,1)],'scalar-region-8192':[(0,524800),(31,0),(64,524801)]}

def main(out):
 assert os.sched_getaffinity(0)=={3}
 out.mkdir(parents=True,exist_ok=False);started=time.monotonic()
 api=ROOT/'selfhost/build/phase198/numeric-api03/report.json';plan=ROOT/'selfhost/build/phase198/numeric-emission-plan01.json'
 native=ROOT/'selfhost/build/phase198/native45-02/report.json'
 result=dict(complete=False,method=pin(__file__),api=pin(api),plan=pin(plan),baseline=pin(native),references=pin(REFERENCES),assets=pin(ASSETS),commands=[],cases={},samples=[],pilots=[],clock='candidate/native N1-equivalent/C/QBE fresh processes; independent per-role counts, six rotated rounds; no broad-suite or native compiler qualification claim')
 def save(): (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
 def run(argv,timeout):
  i=len(result['commands']);start=time.monotonic();p=subprocess.run(list(map(str,argv)),capture_output=True,text=True,timeout=timeout)
  stdout=out/(str(i)+'-stdout');stderr=out/(str(i)+'-stderr');stdout.write_text(p.stdout);stderr.write_text(p.stderr)
  result['commands'].append(dict(argv=list(map(str,argv)),exit=p.returncode,wall=time.monotonic()-start,stdout=pin(stdout),stderr=pin(stderr)));save();assert p.returncode==0,(argv,p.stderr[-2500:],p.stdout[-2500:]);return p
 try:
  run([ROOT/'selfhost/.assets/bin/bun',HERE/'controls.mjs','--api',api,'--out',out/'controls'],25)
  assert read(out/'controls/controls.json')['complete']
  run([ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tests/phase195/prepared-emission/driver.mjs','--plan',plan,'--out',out/'emission'],85)
  emitted=read(out/'emission/numeric/report.json');assert emitted['complete']
  baselines=read(native);assert baselines['complete']
  refs={c['id']:c for c in read(REFERENCES)['cases']};old={c['id']:c for c in read(ROOT/'selfhost/build/phase195/native45-01/report.json')['rows']}
  assets=read(ASSETS);policy=assets['toolchains']['x86'];linker,runtime=[checked_tool(assets['assets'][k]) for k in ['linker','qbe-runtime']]
  for case in CASES:
   row=next(x for x in emitted['rows'] if x['id']==case);base=next(x for x in baselines['rows'] if x['id']==case);ref=refs[case]
   # Current incumbent has a real native image/ordinary-gate binding, and these
   # numeric objects are exactly the originally inspected qualified objects.
   assert base['object']['sha256']==old[case]['object']['sha256'],case+' baseline changed'
   obj=checked_tool(row['product']);exe=out/(case+'-numeric')
   run([linker,*policy['linkerFlags'],obj,runtime,*policy['libraries'],'-o',exe],10)
   products={'baseline':dict(binary=base['artifact'],convention='bend-rts-v1'),'numeric':dict(binary=pin(exe),object=row['product'],assembly=row['assembly'],convention='bend-rts-v1')}
   for role in ['c','qbe']:
    r=ref['products'][role];products[role]=dict(binary=r['artifact'],convention=r['runtimeArgumentConvention'])
   for p in products.values():checked_tool(p['binary'])
   result['cases'][case]=dict(point=ref['point'],source=ref['source'],products=products,checks=[],counts={},ratios={})
   for role in ['baseline','numeric']:
    p=run(['objdump','-d','--no-show-raw-insn','--disassemble='+SYMBOL,products[role]['binary']['file']],5)
    (out/(case+'-'+role+'-mit.disassembly')).write_text(p.stdout)
   assert products['numeric']['object']['sha256']!=base['object']['sha256'],case+' no activation'
   for i,args in enumerate([ref['point']['runtimeArgs'],*EXTRA[case]]):
    repetitions=int(i==0);c=products['c']
    obs,expected=execute(c['binary']['file'],args,repetitions,0,ref['point']['expectedStdout'] if i==0 else None,c['convention'])
    for role,p in products.items():
     obs,_=execute(p['binary']['file'],args,repetitions,0,expected,p['convention']);result['cases'][case]['checks'].append(dict(role=role,args=args,expected=expected,observation=obs));save()
  result['buildChecksWall']=time.monotonic()-started
  for case in CASES:
   c=result['cases'][case]
   for role,p in c['products'].items():
    n=100
    for attempt in range(8):
     obs,_=execute(p['binary']['file'],c['point']['runtimeArgs'],n,0,c['point']['expectedStdout'],p['convention']);ms=obs['elapsedMs'];result['pilots'].append(dict(case=case,role=role,n=n,observation=obs));save()
     if 120<=ms<=300:break
     n=max(1,int(n*160/max(1,ms)))
    else:raise AssertionError('calibration '+case+'/'+role)
    c['counts'][role]=n
  for r in range(6):
   order=CASES[r%len(CASES):]+CASES[:r%len(CASES)]
   if r%2:order=order[::-1]
   for ci,case in enumerate(order):
    c=result['cases'][case];roles=list(c['products']);shift=(r+ci)%len(roles);roles=roles[shift:]+roles[:shift]
    if r%2:roles=roles[::-1]
    for role in roles:
     p=c['products'][role];n=c['counts'][role];obs,_=execute(p['binary']['file'],c['point']['runtimeArgs'],n,4,c['point']['expectedStdout'],p['convention']);assert obs['elapsedMs']>=100
     result['samples'].append(dict(case=case,role=role,round=r,repetitions=n,observation=obs,nsPerWork=obs['elapsedMs']*1000000/n));save()
  for case,c in result['cases'].items():
   for role in c['products']:
    pairs=[]
    for r in range(6):
     rows={x['role']:x['nsPerWork'] for x in result['samples'] if x['case']==case and x['round']==r};pairs.append(rows[role]/rows['baseline'])
    c['ratios'][role]=dict(median=statistics.median(pairs),pairs=pairs)
  result['complete']=True;result['wall']=time.monotonic()-started;save()
  print(json.dumps({'complete':True,'wall':result['wall'],'ratios':{k:v['ratios'] for k,v in result['cases'].items()}}))
 except Exception as e:
  result['error']=str(e);result['wall']=time.monotonic()-started;save();raise
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out)
