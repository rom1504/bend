"""Root-granted small staged-frontend transfer/variation experiment."""
import argparse,json,math,os,statistics,subprocess,sys,time,hashlib
from pathlib import Path
P=Path(__file__).resolve().parent;ROOT=P.parents[2];sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute

def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(p):assert pin(p['file'])['sha256']==p['sha256'];return p['file']
a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);a=a.parse_args();assert os.sched_getaffinity(0)=={3};a.out.mkdir(parents=True,exist_ok=False)
f=read(P/'transfer-freeze.json');start=time.monotonic();r=dict(complete=False,method=pin(__file__),freeze=pin(P/'transfer-freeze.json'),jobs=[],cases=[])
for p in f['pins']:check(p)
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def build(name,source):
 obj=a.out/(name+'.o');exe=a.out/name;cmd=f['compiler'][:];cmd[cmd.index(f['originalSource'])]=check(source)
 for command,target in [(cmd,obj),([check(f['linker']),'-no-pie',str(obj),check(f['runtime']),'-pthread','-lm','-o',str(exe)],None)]:
  t=time.monotonic()
  if target:
   with target.open('wb') as out:q=subprocess.run(command,stdout=out,stderr=subprocess.PIPE,timeout=max(1,11.7-(time.monotonic()-start)))
  else:q=subprocess.run(command,capture_output=True,timeout=max(1,11.7-(time.monotonic()-start)))
  r['jobs'].append(dict(argv=command,seconds=time.monotonic()-t,exit=q.returncode,stderr=q.stderr.decode(errors='replace')[:2000]));save();assert q.returncode==0,r['jobs'][-1]
 assert obj.read_bytes()[:4]==b'\x7fELF';return dict(artifact=pin(exe),object=pin(obj))
try:
 for case in f['cases']:
  row=dict(id=case['id'],products={},oracles=[],calibration={},samples={});r['cases'].append(row)
  for role,p in case['products'].items():
   row['products'][role]=build(case['id']+'-'+role,p['source']) if 'source'in p else p
  for point in case['oracles']:
   obs={k:execute(check(v['artifact']),point['args'],0,0,point['expected'],'bend-rts-v1')[0] for k,v in row['products'].items()}
   row['oracles'].append(dict(point=point,observations=obs));save()
  point=case['oracles'][0];order=list(row['products'])
  for role,p in row['products'].items():
   count=16;row['calibration'][role]=[]
   for _ in range(7):
    obs,_=execute(check(p['artifact']),point['args'],count,2,point['expected'],'bend-rts-v1');ms=obs['elapsedMs'];row['calibration'][role].append([count,ms])
    if 120<=ms<=300:break
    count=max(1,math.ceil(count*150/max(1,ms)))
   else:raise AssertionError('calibration')
   row['samples'][role]=[]
  for rnd in range(len(order)):
   for role in order[rnd:]+order[:rnd]:
    count=row['calibration'][role][-1][0];obs,_=execute(check(row['products'][role]['artifact']),point['args'],count,2,point['expected'],'bend-rts-v1');assert obs['elapsedMs']>=100
    row['samples'][role].append(dict(repetitions=count,**obs));save()
  row['medianMs']={k:statistics.median(o['elapsedMs']/o['repetitions'] for o in v) for k,v in row['samples'].items()};row['ratios']={k:v/row['medianMs']['baseline'] for k,v in row['medianMs'].items()};save()
 r['complete']=True
except Exception as e:r['error']=repr(e);raise
finally:r['seconds']=time.monotonic()-start;save()
print(json.dumps([dict(id=c['id'],ratios=c['ratios']) for c in r['cases']]))
