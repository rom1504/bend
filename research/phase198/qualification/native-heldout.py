#!/usr/bin/env python3
"""Actual final N2 compilation of the two authored orbit transfer controls."""
import argparse,hashlib,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute,bench
p=argparse.ArgumentParser();p.add_argument('--prefix',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert os.sched_getaffinity(0)=={3};a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(p):
 assert pin(p['file'])==p,p['file'];return p['file']
b=ROOT/'selfhost/build/phase198';trialpath=b/'numeric-products04/report.json';trial=read(trialpath);assert trial['complete']
plan=read(verify(trial['plan']));assert plan['complete'];cases={x['id']:x for x in plan['cases']}
image=b/(a.prefix+'-native-self01')/'program';receipt=image.parent/'report.json';ir=read(receipt);assert ir['complete'] and ir['imageBinding']['stage']=='N2';verify(ir['binary'])
r=dict(complete=False,method=pin(__file__),image=pin(image),imageReceipt=pin(receipt),trial=pin(trialpath),plan=trial['plan'],rows=[],scope='Fresh actual final N2 object emission and independent C checks on authored converging/cycling sources. Exact object identity with the independently checked corrected API trial; no new performance measurement.')
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save();start=time.monotonic()
try:
 for name in ['orbit-converging','orbit-cycling']:
  case=cases[name];source=verify(case['source']);old=trial['cases'][name];want=old['products']['selective']['object'];verify(want)
  directory=a.out/name
  command=['python3','-B',str(ROOT/'selfhost/tools/build/native.py'),'--assets',str(ROOT/'selfhost/build/phase194/assets.json'),'--host','native','--target','x86','--emit','object','--mode','cache','--image',str(image),'--image-receipt',str(receipt),'--stage','N2','--source',source,'--out',str(directory),'--seconds','30']
  row=dict(id=name,source=case['source'],expectedObject=want,command=command,complete=False,checks=[]);r['rows'].append(row);save()
  child=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=35)
  (a.out/(name+'.stdout')).write_bytes(child.stdout);(a.out/(name+'.stderr')).write_bytes(child.stderr)
  row['buildStdout']=pin(a.out/(name+'.stdout'));row['buildStderr']=pin(a.out/(name+'.stderr'));assert child.returncode==0,child.stderr[-2000:]
  build=read(directory/'report.json');assert build['complete'] and not build.get('changedInputs')
  actual=pin(directory/'program.o');assert actual['sha256']==want['sha256'] and actual['bytes']==want['bytes'],name+' native/API object differs'
  row.update(buildReceipt=pin(directory/'report.json'),object=actual,binary=pin(directory/'program'),objectBytesExact=True)
  c=old['products']['c'];exe=verify(c['binary']);verify(c['source']);row.update(cOracle=c['binary'],cSource=c['source'])
  points={tuple(v['args']):v['expected'] for v in old['checks']}
  for args,expected in points.items():
   observation,_=execute(directory/'program',args,0,0,expected)
   child=subprocess.run([exe,'0','0',*map(str,args)],capture_output=True,timeout=8)
   bench.observation(child.stdout,child.stderr,child.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),0)
   row['checks'].append(dict(args=list(args),expected=expected,native=observation,cStdout=child.stdout.decode(),cStderr=child.stderr.decode(),cExit=child.returncode))
  observation,_=execute(directory/'program',old['point'],2,4,old['expected']);row['countCheck']=observation
  row['complete']=True;save()
 r.update(complete=True,seconds=time.monotonic()-start,nativeObjectsExact=2,independentCPoints=sum(len(x['checks']) for x in r['rows']),countChecks=2);save()
except BaseException as error:
 r.update(error=repr(error),seconds=time.monotonic()-start);save();raise
