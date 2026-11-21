"""Small complete-result native screen; root dispatches under CPU3 disk guard."""
import argparse,hashlib,json,math,os,statistics,subprocess,sys,time
from pathlib import Path
P=Path(__file__).resolve().parent;ROOT=P.parents[2]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute

def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def checked(p):assert pin(p['file'])['sha256']==p['sha256'];return p['file']
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert os.sched_getaffinity(0)=={3}
out=a.out;out.mkdir(parents=True,exist_ok=False);start=time.monotonic();freeze=read(P/'freeze.json')
for v in freeze['pins']:checked(v)
r=dict(complete=False,scope='Source-level certified static-template token folding; unchanged catalog harness. Not an automatic compiler rule.',freeze=pin(P/'freeze.json'),method=pin(__file__),jobs=[],products={},oracles=[],samples={},calibration={})
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def job(cmd,stdout=None):
 t=time.monotonic();q=subprocess.run(cmd,stdout=stdout or subprocess.PIPE,stderr=subprocess.PIPE,timeout=max(1,26-(time.monotonic()-start)))
 r['jobs'].append(dict(argv=cmd,seconds=time.monotonic()-t,exit=q.returncode,stderr=q.stderr.decode(errors='replace')[:2000]));save();assert q.returncode==0,r['jobs'][-1]
 return q.stdout
save()
try:
 for name in ['controls','candidate']:
  obj=out/(name+'.o');exe=out/name;cmd=freeze['compilerCommand'][:];cmd[cmd.index(freeze['ordinarySource']['file'])]=checked(freeze[name+'Source'])
  with obj.open('wb') as f:job(cmd,f)
  assert obj.read_bytes()[:4]==b'\x7fELF'
  job([checked(freeze['linker']),'-no-pie',str(obj),checked(freeze['runtime']),'-pthread','-lm','-o',str(exe)])
  r['products'][name]=dict(object=pin(obj),binary=pin(exe));save()
  if name=='controls':
   got=job([str(exe),'+RTS','--threads','1','--gpu','off','-RTS','--RTS'])
   assert got.decode()==Path(checked(freeze['controlExpected'])).read_text(),got.decode()[:2000]
   r['controlRows']=25;save()
 products={'candidate':str(out/'candidate'),'baseline':checked(freeze['baseline']),'c':checked(freeze['c'])}
 for point in read(P/'oracles.json')['program']:
  row=dict(args=point['args'],expected=point['expected'],observations={})
  for role,exe in products.items():row['observations'][role]=execute(exe,point['args'],0,0,point['expected'],'bend-rts-v1')[0]
  r['oracles'].append(row);save()
 for role,exe in products.items():
  count=32;r['calibration'][role]=[]
  for _ in range(8):
   obs,_=execute(exe,[8,0],count,3,'1822208108\n','bend-rts-v1');ms=obs['elapsedMs'];r['calibration'][role].append([count,ms])
   if 115<=ms<=350:break
   count=max(1,math.ceil(count*150/max(1,ms)))
  else:raise AssertionError('calibration '+role)
  r['samples'][role]=[]
 order=list(products)
 for i in range(6):
  for role in order[i%3:]+order[:i%3]:
   count=r['calibration'][role][-1][0];obs,_=execute(products[role],[8,0],count,3,'1822208108\n','bend-rts-v1');assert obs['elapsedMs']>=100
   r['samples'][role].append(dict(repetitions=count,**obs));save()
 med={k:statistics.median(o['elapsedMs']/o['repetitions'] for o in v) for k,v in r['samples'].items()};r['medianMs']=med;r['candidateOverBaseline']=med['candidate']/med['baseline'];r['candidateOverC']=med['candidate']/med['c'];r['complete']=True
except Exception as e:r['error']=repr(e);raise
finally:r['seconds']=time.monotonic()-start;save()
print(json.dumps({k:r[k] for k in ['complete','candidateOverBaseline','candidateOverC','seconds']}))
