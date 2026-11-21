#!/usr/bin/env python3
"""Two real gzip-native images; held-out packet hash oracle and alternating timing."""
import argparse,json,math,os,statistics,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(HERE.parent/'measure'))
import screen as BUILD
from support import B,R,REFERENCE,image_binding,checked_bytes

def execute(a):
 assert os.sched_getaffinity(0)=={3} and 'BENDRTS' not in os.environ
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);started=time.monotonic();deadline=started+a.seconds
 fixture=B.read(HERE/'cases.json');B.verify(fixture['source'])
 bindings={role:image_binding(getattr(a,role),getattr(a,role).with_name('results.json')) for role in ['baseline','candidate']}
 ref=B.read(REFERENCE);command=ref['compilerCommand'].copy();command[0]='{image}';command[9]='{source}';link=[j['command'] for j in ref['jobs'] if j['label']=='link'][0].copy();link[2]='{object}';link[3]='{runtime}';link[-1]='{output}'
 cfg=B.read(ROOT/'research/phase199/broad/integrated-pins.json');runtime=cfg['live'];B.verify(runtime)
 inputs=[B.pin(__file__),B.pin(HERE/'make-fixture.py'),B.pin(HERE/'cases.json'),fixture['source'],runtime,cfg['bundle'],B.pin(REFERENCE),B.pin(command[10]),B.pin(command[12]),B.pin(link[0]),B.pin(BUILD.__file__),B.pin(R.__file__),B.pin(B.__file__)]
 for binding in bindings.values():inputs.extend(binding[k] for k in ['gzip','receipt','source'])
 inputs.extend(c['expected'] for c in fixture['cases']);inputs=B.unique_inputs(inputs)
 for pin in inputs:B.verify(pin)
 report=dict(kind='phase205-packet-transfer-screen',complete=False,inputs=inputs,images=bindings,runtime=runtime,rounds=4,positionBalanced=True,targetMs=140,minimumAcceptedMs=100,builds={},cases=[],scope='Catalog-independent held-out dynamic packet source. Block generation occurs before timing, including zero-count long-block cases; every invocation hashes every returned U32 word and returns length plus two modular hashes. Python scalar expansion supplies independent expected digests. Four alternating rounds, same product runtime; no copied outputs or timing.')
 B.save(out/'report.json',report);products={};fds=[]
 try:
  for role,binding in bindings.items():
   fd,identity=BUILD.load_image(binding);fds.append(fd);products[role],built=BUILD.build(dict(compilerCommand=command,linkCommand=link,runtime=runtime),binding,fd,fixture['source'],out/role,deadline);report['builds'][role]=dict(nativeImage=identity,build=built)
  for fd in fds:os.close(fd)
  fds=[];roles=['baseline','candidate']
  for ci,case in enumerate(fixture['cases']):
   row=dict(id=case['id'],point=case['point'],expected=case['expected'],pilots=[],samples=[],calibration={});report['cases'].append(row)
   def observe(role,count,stage,index):
    product=products[role];point=dict(case['point'],repetitions=count);cmd=[product['artifact']['file'],*B.native_runtime_arguments(product),str(count),str(point['warmups']),*map(str,point['runtimeArgs'])]
    proc=B.child(cmd,out/stage/case['id']/(str(index)+'-'+role),min(deadline,time.monotonic()+30),str(ROOT));assert proc['exitCode']==0 and not proc['timedOut']
    elapsed=B.observation(checked_bytes(proc['stdout']),checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds'])
    item=dict(role=role,round=index,repetitions=count,warmups=point['warmups'],correct=True,elapsedMs=elapsed,metricMs=elapsed/count,lowResolution=elapsed<100,process=proc);row['pilots' if stage=='pilot' else 'samples'].append(item);return item
   for role in roles[ci%2:]+roles[:ci%2]:
    count=16
    for attempt in range(20):
     obs=observe(role,count,'pilot',attempt)
     if 140<=obs['elapsedMs']<=280 or count==1 and obs['elapsedMs']>=140:break
     count=R.next_count(count,obs['elapsedMs'],140)
    else:raise ValueError('Calibration did not converge')
    row['calibration'][role]=count
   for ri in range(4):
    for role in roles[(ci+ri)%2:]+roles[:(ci+ri)%2]:observe(role,row['calibration'][role],'timed',ri)
   result=B.summary(row['samples'],roles,'baseline',4,True);assert result['complete'] and result['ratios'] is not None
   # Reopen retained streams rather than trusting in-memory flags.
   for sample in row['pilots']+row['samples']:
    proc=sample['process'];point=dict(case['point'],repetitions=sample['repetitions']);assert B.observation(checked_bytes(proc['stdout']),checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds'])==sample['elapsedMs']
   row['summary']=result;row['dispersion']={r:max(result['stats'][r]['samplesMs'])/min(result['stats'][r]['samplesMs']) for r in roles};row['flagged']=any(v>1.10 for v in row['dispersion'].values());B.save(out/'report.json',report)
  ratios={row['id']:row['summary']['stats']['candidate']['medianMs']/row['summary']['stats']['baseline']['medianMs'] for row in report['cases']}
  groups={}
  for name,predicate in [('positive',lambda c:c['point']['runtimeArgs'][0]>0),('zeroAdverse',lambda c:c['point']['runtimeArgs'][0]==0),('all',lambda c:True)]:
   rows=[r for r in report['cases'] if predicate(r)];fixed={role:sum(r['summary']['stats'][role]['medianMs']*r['point']['repetitions'] for r in rows) for role in roles};groups[name]=dict(cases=[r['id'] for r in rows],geomean=math.exp(statistics.mean(math.log(ratios[r['id']]) for r in rows)),fixedMs=fixed,fixedRatio=fixed['candidate']/fixed['baseline'])
  for pin in inputs:B.verify(pin)
  report.update(complete=True,ratios=ratios,groups=groups)
 except BaseException as error:report['error']=repr(error)
 finally:
  for fd in fds:os.close(fd)
  report['wallSeconds']=time.monotonic()-started;B.save(out/'report.json',report)
 print(json.dumps({k:report.get(k) for k in ['complete','ratios','groups','error','wallSeconds']}));return 0 if report['complete'] else 1
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--baseline',type=Path,default=ROOT/'selfhost/build/phase201/p204image03/program.gz');p.add_argument('--candidate',type=Path,default=ROOT/'selfhost/build/phase201/p205image01/program.gz');p.add_argument('--seconds',type=float,default=110);a=p.parse_args();sys.exit(execute(a))
