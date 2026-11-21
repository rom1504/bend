"""Checked compiler emission, typed negative-path differential, and real ray screen."""
import argparse,hashlib,json,math,os,re,statistics,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute
def pin(p):
 p=Path(p);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(v):assert pin(v['file'])['sha256']==v['sha256'],v;return v['file']
def main(out,plan):
 assert os.sched_getaffinity(0)=={3};out.mkdir(parents=True,exist_ok=False);start=time.monotonic();study=read(plan/'study.json')
 r=dict(complete=False,method=pin(__file__),study=pin(plan/'study.json'),emissionPlan=pin(plan/'emission.json'),commands=[],cases={},pilots=[],samples=[])
 def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 def run(cmd,timeout=25):
  t=time.monotonic();p=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=timeout)
  r['commands'].append(dict(argv=list(map(str,cmd)),exit=p.returncode,seconds=time.monotonic()-t,stdout=p.stdout,stderr=p.stderr));save();assert p.returncode==0,(cmd,p.stderr[-2000:],p.stdout[-2000:]);return p.stdout
 try:
  for v in study['inputs']:verify(v)
  assets=read(verify(study['assets']));cc=verify(assets['assets']['linker']);bun=verify(assets['assets']['bun']);runtime=verify(study['runtime']);helper=verify(study['helper'])
  run([bun,HERE/'admission.mjs','--api',study['candidateApi']['file'],'--out',out/'admission'])
  run([bun,ROOT/'selfhost/tests/phase195/prepared-emission/driver.mjs','--plan',plan/'emission.json','--out',out/'emission'],35)
  emitted=read(out/'emission/sqrt/report.json');assert emitted['complete'];rows={x['id']:x for x in emitted['rows']}
  # Differential against actual runtime arithmetic, with values live across a negative sqrt.
  row=rows['sqrt-hold'];obj=verify(row['product']);symbols=run(['/usr/bin/nm','--defined-only',obj])
  names=[line.split()[-1] for line in symbols.splitlines() if line.split()]
  worker=next(n for n in names if n.startswith('p113d_FID_') and ''.join(chr(int(x)) for x in n[len('p113d_FID_'):].split('_') if x)=='$direct.sqrt_hold')
  renamed=out/'sqrt-hold-renamed.o';run(['/usr/bin/objcopy','--redefine-sym','main=p200_hold_original_main',obj,renamed])
  test=out/'worker-check';run([cc,'-std=c11','-O2','-msse2','-mno-avx','-no-pie','-DTEST_WORKER="'+worker+'"',HERE/'worker-check.c',renamed,helper,runtime,'-pthread','-lm','-o',test])
  r['typedControl']=dict(object=row['product'],worker=worker,source=pin(HERE/'worker-check.c'),binary=pin(test),result=json.loads(run([test])))
  r['typedControl']['sourceFixture']=pin(HERE/'sqrt-hold.bend');save()
  owner='p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_'
  for case in study['cases']:
   name=case['id'];d=out/name;d.mkdir();candidate=rows[name]['product'];base=case['baselineObject'];assert candidate['sha256']!=base['sha256'],name+' no activation'
   rel=run(['/usr/bin/objdump','-r',verify(candidate)]);assert 'p200_rt_f32_sqrt_keep' in rel,name+' missing sqrt helper'
   products={}
   for role,objpin in [('baseline',base),('candidate',candidate)]:
    exe=d/role;run([cc,'-no-pie',verify(objpin),helper,runtime,'-pthread','-lm','-o',exe]);products[role]=dict(binary=pin(exe),object=objpin)
    decoded=run(['/usr/bin/objdump','-d','-Mintel','--no-show-raw-insn','--disassemble='+owner,exe]);(d/(role+'-nearest.asm')).write_text(decoded)
   products['c']=dict(binary=case['c']['artifact'])
   for prod in products.values():verify(prod['binary'])
   entry=dict(point=case['point'],source=case['source'],products=products,checks=[],counts={});r['cases'][name]=entry
   for i,args in enumerate([case['point']['runtimeArgs'],*case['extra']]):
    reps=int(i==0);obs,expected=execute(products['c']['binary']['file'],args,reps,0,case['point']['expectedStdout'] if i==0 else None)
    entry['checks'].append(dict(role='c',args=args,observation=obs,expected=expected))
    for role in ['baseline','candidate']:
     obs,_=execute(products[role]['binary']['file'],args,reps,0,expected);entry['checks'].append(dict(role=role,args=args,observation=obs,expected=expected))
   save()
  r['buildAndCheckSeconds']=time.monotonic()-start
  for name,case in r['cases'].items():
   for role,p in case['products'].items():
    n=max(1,case['point']['repetitions']//2)
    for _ in range(4):
     obs,_=execute(p['binary']['file'],case['point']['runtimeArgs'],n,0,case['point']['expectedStdout']);r['pilots'].append(dict(case=name,role=role,repetitions=n,observation=obs));save()
     if 100<=obs['elapsedMs']<=220:break
     n=max(1,math.ceil(n*140/max(1,obs['elapsedMs'])))
    else:raise AssertionError('calibration '+name+'/'+role)
    case['counts'][role]=n
  for round_ in range(6):
   cases=list(r['cases']);cases=cases[round_%3:]+cases[:round_%3]
   for ci,name in enumerate(cases):
    case=r['cases'][name];roles=['baseline','candidate','c'];shift=(round_+ci)%3;roles=roles[shift:]+roles[:shift]
    for role in roles:
     n=case['counts'][role];obs,_=execute(case['products'][role]['binary']['file'],case['point']['runtimeArgs'],n,4,case['point']['expectedStdout']);assert obs['elapsedMs']>=90
     r['samples'].append(dict(case=name,role=role,round=round_,repetitions=n,observation=obs,nsPerCall=obs['elapsedMs']*1e6/n));save()
  for name,c in r['cases'].items():
   c['ratios']={}
   for denom in ['baseline','c']:
    pairs=[]
    for i in range(6):
     v={x['role']:x['nsPerCall'] for x in r['samples'] if x['case']==name and x['round']==i};pairs.append(v['candidate']/v[denom])
    c['ratios'][denom]=dict(median=statistics.median(pairs),pairs=pairs)
  r['complete']=True
 except Exception as e:r['error']=repr(e);raise
 finally:r['seconds']=time.monotonic()-start;save()
 print(json.dumps({n:c.get('ratios') for n,c in r['cases'].items()}))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path,required=True);a=p.parse_args();main(a.out,a.plan)
