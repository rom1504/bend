#!/usr/bin/env python3
"""Observe frozen diagnostic images with complete independent output gates.

Large QBE output is byte-compared while streamed through a job-owned FIFO.
This bounds retained storage; it is not a clean regular-file timing comparison.
"""
import argparse,hashlib,importlib.util,json,os,select,sys,threading
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,fresh_output,require
spec=importlib.util.spec_from_file_location('p162_profile',ROOT/'selfhost/tools/profiler/run.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser();p.add_argument('--role',choices=['ours','bendc'],required=True);p.add_argument('--build',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--case',choices=['map','full'],default='full');p.add_argument('--policy',choices=['old','publication'],default='old')
p.add_argument('--oracle-receipt',type=Path);p.add_argument('--seconds',type=int,default=240);a=p.parse_args()
out=fresh_output(a.out,ROOT);build=a.build.resolve();b=json.loads(build.read_text());require(b['complete'],'Build incomplete')
image=verify(b['binary']);base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend';source=ROOT/'selfhost/build/phase152/composite01/compiler.bend'
inputs=[pin(__file__),pin(P.__file__),pin(build),b['binary']];oracle=None
if a.role=='bendc':
 receipt=a.oracle_receipt.resolve();prior=json.loads(receipt.read_text());source=verify(prior['source']);base=verify(prior['base'])
 inputs+=[pin(receipt),prior['source'],prior['base'],prior['process']['stdout'],prior['process']['stderr']]
else:
 if a.case=='map':
  case=next(c for c in json.loads((ROOT/'selfhost/build/phase156/pilot01/report.json').read_text())['cases'] if c['name']=='map')
  source=verify(case['source']);oracle=case['oracle'];receipt=Path(oracle['file']).parent/'report.json'
 else:
  receipt=ROOT/'selfhost/build/phase152/native-n3/report.json';q=json.loads(receipt.read_text());oracle=q['retainedIR']
 q=json.loads(receipt.read_text());require(q['complete'],'Oracle incomplete');require(q['request']['source']==pin(source),'Source mismatch')
 base=verify(q['request']['base']);verify(oracle);inputs+=[pin(receipt),oracle,pin(source),pin(base)]
for row in inputs:verify(row)
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT','P162_DIAG_OUT']}
env['P162_DIAG_OUT']=str(out/'counts.json')
if a.role=='bendc':env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0')
r=dict(complete=False,role=a.role,policy=a.policy,inputs=inputs,environment={k:v for k,v in env.items() if k.startswith(('BEND_','P162_'))},scope='Diagnostic additive main-thread counts; not clean timing; unchanged complete outputs required.')
write_json(out/'report.json',r);stop=threading.Event();stream={};thread=None
if a.role=='ours':
 fifo=out/'output.fifo';os.mkfifo(fifo)
 def consume():
  h=hashlib.sha256();n=0;match=True;fd=os.open(fifo,os.O_RDONLY|os.O_NONBLOCK)
  try:
   with Path(oracle['file']).open('rb') as expected:
    while True:
     ready=select.select([fd],[],[],.05)[0]
     if not ready:continue
     chunk=os.read(fd,1024*1024)
     if not chunk:
      if stop.is_set():break
      stop.wait(.01);continue
     h.update(chunk);n+=len(chunk);match=(expected.read(len(chunk))==chunk) and match
    match=match and expected.read(1)==b''
   stream.update(bytes=n,sha256=h.hexdigest(),byteExact=match,oracle=oracle)
  except BaseException as e:stream['error']=repr(e)
  finally:os.close(fd)
 thread=threading.Thread(target=consume,daemon=True);thread.start()
 cmd=[str(image),'--threads','1','--gpu','off','--',str(base),str(source),a.policy,str(fifo)]
else:cmd=[str(image),'--threads','1','--gpu','off','--','--'+prior['mode'],str(base),str(source)]
try:r['process']=P.execute(cmd,out/'child',ROOT,a.seconds,env,argv0='transfer' if a.role=='ours' else None)
finally:
 stop.set()
 if thread:
  thread.join(5);require(not thread.is_alive(),'Output reader did not finish');fifo.unlink()
q=r['process'];r['stream']=stream
if a.role=='bendc':
 r['outputExact']=q['returncode']==prior['process']['returncode'] and all(Path(q[k]['file']).read_bytes()==Path(prior['process'][k]['file']).read_bytes() for k in ['stdout','stderr'])
else:r['outputExact']=q['returncode']==0 and q['stdout']['bytes']==q['stderr']['bytes']==0 and stream.get('byteExact',False)
r['complete']=r['outputExact'] and not q['timedOut'] and (out/'counts.json').is_file()
if (out/'counts.json').exists():r['counts']=pin(out/'counts.json');json.loads((out/'counts.json').read_text())
for row in inputs:verify(row)
write_json(out/'report.json',r);print(json.dumps(dict(complete=r['complete'],seconds=q['wallSeconds'],rssKiB=q['peakRssKiB'],outputExact=r['outputExact'])))
require(r['complete'],'Diagnostic observation failed')
