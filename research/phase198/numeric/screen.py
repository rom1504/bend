from pathlib import Path
import argparse,hashlib,json,os,random,re,statistics,subprocess,sys,time
from prepare import ROOT,HERE,SYMBOL,pin,read,verify
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS,execute,checked_tool

def main(out):
 assert os.sched_getaffinity(0)=={3}
 out.mkdir(parents=True,exist_ok=False);started=time.monotonic()
 f=read(HERE/'frozen.json');source=verify(f['source']);direct=verify(f['direct']);verify(f['object'])
 result=dict(complete=False,freeze=pin(HERE/'frozen.json'),method=pin(__file__),commands=[],model={},products={},checks=[],samples=[],pilots=[],started=started)
 def save(): (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
 def run(argv,seconds=10):
  start=time.monotonic();p=subprocess.run(list(map(str,argv)),capture_output=True,text=True,timeout=seconds)
  result['commands'].append(dict(argv=list(map(str,argv)),exit=p.returncode,stdout=p.stdout,stderr=p.stderr,wall=time.monotonic()-start));save()
  assert p.returncode==0,(argv,p.stderr,p.stdout)
  return p
 assets=read(ASSETS);policy=assets['toolchains']['x86']
 assembler,linker,runtime=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
 result['assets']=pin(ASSETS)
 acquisition=read(ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json')
 for p in [acquisition['tool'],*acquisition['libraries']]:assert pin(p['file'])['sha256']==p['sha256']
 result['acquisition']=acquisition
 for name,seq in [('before',f['beforeModel']),('typed',f['variants'][0]['model'])]:
  s=out/(name+'-model.s');s.write_text('.text\n'+'\n'.join(seq)+'\n')
  p=run([acquisition['tool']['file'],'-mtriple=x86_64-unknown-linux-gnu','-mcpu=ivybridge','-iterations=100','-noalias=true',s],3)
  assert not p.stderr
  metrics={k:float(re.search('^'+label+r':\s*([\d.]+)',p.stdout,re.M)[1]) for k,label in [('cycles','Total Cycles'),('throughput','Block RThroughput'),('instructions','Instructions')]}
  assert metrics['instructions']==len(seq)*100
  (out/(name+'-model.stdout')).write_text(p.stdout);result['model'][name]=metrics
 result['modelCycleRatio']=result['model']['typed']['cycles']/result['model']['before']['cycles'];save()
 original=source.read_text().splitlines()
 result['products']['direct']=dict(binary=pin(direct),convention='bend-rts-v1')
 for v in [None,*f['variants']]:
  name=v['name'] if v else 'baseline';d=out/name;d.mkdir();s=d/'program.s';o=d/'program.o';exe=d/'program'
  lines=original.copy()
  if v:lines[f['start']:f['end']]=v['after']
  s.write_text('\n'.join(lines)+'\n');assert v or s.read_bytes()==source.read_bytes()
  run([assembler,*policy['assemblerFlags'],'-o',o,s]);run([linker,*policy['linkerFlags'],o,runtime,*policy['libraries'],'-o',exe])
  result['products'][name]=dict(binary=pin(exe),source=pin(s),object=pin(o),convention='bend-rts-v1')
 for name in ('c','qbe'):
  p=f['reference']['products'][name];exe=checked_tool(p['artifact'])
  result['products'][name]=dict(binary=pin(exe),convention=p['runtimeArgumentConvention'])
 # Independent exact integer oracle for arbitrary loop state, including wrap and signed-shift edges.
 rng=random.Random(198);tests=[]
 def oracle(n,cr,ci,zr,zi,esc,it):
  def shr(x):return ((x&0xffffffff)>>8)|(0xff000000 if x&0x80000000 else 0)
  for _ in range(n):
   r2=shr((zr*zr)&0xffffffff);i2=shr((zi*zi)&0xffffffff)
   esc|=int(((r2+i2)&0xffffffff)>1024)
   nzr=(r2-i2+cr)&0xffffffff;nzi=(shr((2*zr*zi)&0xffffffff)+ci)&0xffffffff
   if not esc:zr=nzr;zi=nzi;it=(it+1)&0xffffffff
  return it
 for i in range(1024):
  n=i%65;args=[rng.getrandbits(32) for _ in range(6)]
  if i%3==0:args[2:5]=[0,0,0]
  if i%7==0:args[4]=0
  if i%11==0:args=[0xffffff00,0,0,0,0,0xffffffff]
  tests.append([n,*args,oracle(n,*args)])
 (out/'finite-inputs.json').write_text(json.dumps(tests)+'\n')
 baseobj=out/'finite-original.o';run(['/usr/bin/objcopy','--redefine-sym','main=p198_original_main',result['products']['baseline']['object']['file'],baseobj])
 testobjs=[]
 for v in f['variants']:
  name=v['name'].replace('-','_');s=out/(name+'-finite.s');s.write_text((HERE/(v['name']+'.s')).read_text().replace(SYMBOL,name));o=s.with_suffix('.o');run([assembler,'-o',o,s]);testobjs.append(o)
 control=out/'finite.c'
 control.write_text('#include <stdint.h>\n#include <stdio.h>\ntypedef uint64_t U;\n'+''.join('extern U '+name+'(U,U,U,U,U,U,U,U);\n' for name in [SYMBOL,'typed_scalar','typed_escape'])+'static U tests[][8]={\n'+',\n'.join('{'+','.join(str(x)+'ULL' for x in t)+'}' for t in tests)+'};\nint main(void){U (*fs[])(U,U,U,U,U,U,U,U)={'+SYMBOL+',typed_scalar,typed_escape};for(unsigned i=0;i<1024;i++)for(unsigned f=0;f<3;f++){U *a=tests[i];U got=fs[f](0,a[0],a[1],a[2],a[3],a[4],a[5],a[6]);if(got!=a[7]){printf("FAIL %u %u %llu %llu\\n",i,f,(unsigned long long)got,(unsigned long long)a[7]);return 1;}}puts("PASS 3072 exact loop observations");}\n')
 controlbin=out/'finite';run([linker,'-O2','-no-pie',control,baseobj,*testobjs,runtime,*policy['libraries'],'-o',controlbin]);p=run([controlbin]);result['finite']=dict(observations=3072,source=pin(control),inputs=pin(out/'finite-inputs.json'),stdout=p.stdout)
 for i,args in enumerate(f['points']):
  reps=int(i==0);c=result['products']['c'];obs,expected=execute(c['binary']['file'],args,reps,0,f['reference']['point']['expectedStdout'] if i==0 else None,c['convention'])
  for name,prod in result['products'].items():
   obs,_=execute(prod['binary']['file'],args,reps,0,expected,prod['convention']);result['checks'].append(dict(role=name,args=args,expected=expected,observation=obs));save()
 result['buildAndCheckWall']=time.monotonic()-started
 count={}
 for name,prod in result['products'].items():
  n=100
  for _ in range(8):
   obs,_=execute(prod['binary']['file'],[2,0],n,0,f['reference']['point']['expectedStdout'],prod['convention']);ms=obs['elapsedMs'];result['pilots'].append(dict(role=name,n=n,observation=obs));save()
   if 120<=ms<=300:break
   n=max(1,int(n*160/max(1,ms)))
  else:raise AssertionError('calibration')
  count[name]=n
 result['counts']=count
 roles=list(result['products'])
 for r in range(6):
  order=roles[r:]+roles[:r]
  if r%2:order=order[::-1]
  for name in order:
   prod=result['products'][name];obs,_=execute(prod['binary']['file'],[2,0],count[name],4,f['reference']['point']['expectedStdout'],prod['convention']);assert obs['elapsedMs']>=100
   result['samples'].append(dict(round=r,role=name,repetitions=count[name],observation=obs,nsPerWork=obs['elapsedMs']*1000000/count[name]));save()
 result['ratios']={}
 for name in roles:
  ratios=[]
  for r in range(6):
   pair={s['role']:s['nsPerWork'] for s in result['samples'] if s['round']==r};ratios.append(pair[name]/pair['baseline'])
  result['ratios'][name]=dict(median=statistics.median(ratios),pairs=ratios)
 result['wall']=time.monotonic()-started;result['complete']=True;save();print(json.dumps({'modelRatio':result['modelCycleRatio'],'ratios':result['ratios'],'wall':result['wall']}))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out)
