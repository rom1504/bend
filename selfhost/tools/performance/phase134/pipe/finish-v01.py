#!/usr/bin/env python3
"""Finish a separately reviewed, preserved pipe build without rerunning compiler/QBE."""
import argparse,hashlib,json,os,pathlib,signal,subprocess,time
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
p=argparse.ArgumentParser();p.add_argument('--review',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--seconds',type=float,default=30);a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase134')and 0<a.seconds<=120
review=json.loads(a.review.read_text());assert review['complete']and review['kind']=='phase134-reviewed-split-immediate-warnings'
pipe=json.loads(pathlib.Path(review['originalPipe']['file']).read_text());assert not pipe['complete']and pipe['compilerExitCode']==pipe['qbeExitCode']==0
assert pipe['error']=="ValueError('assemble failed or diagnosed an error')"and len(pipe['jobs'])==1 and pipe['jobs'][0]['exitCode']==0
for k in ('source','runtime','irDigest','assembly'):assert review[k]==pipe[k]
as_path=pathlib.Path(pipe['jobs'][0]['command'][0]).resolve();gcc=next(x for x in pipe['inputs']if pathlib.Path(x['file']).name=='x86_64-linux-gnu-gcc-10');assembler=next(x for x in pipe['inputs']if x['file']==str(as_path))
inputs=[pin(__file__),pin(a.review),review['originalPipe'],*review['inputs'],review['assembly'],review['retainedObject'],assembler,gcc]
for x in inputs:verify(x)
out.mkdir(parents=True);(out/'method.py').write_bytes(pathlib.Path(__file__).read_bytes())
r=dict(kind='phase134-reviewed-pipe-machine-finish',complete=False,inputs=inputs,originalPipe=review['originalPipe'],warningReview=pin(a.review),source=pipe['source'],image=pipe['image'],runtime=pipe['runtime'],irDigest=pipe['irDigest'],assembly=pipe['assembly'],retainedObject=review['retainedObject'],jobs=[],compilerOrQbeRerun=False,scope='Fresh aligned assembly must exactly reproduce retained object; link identical established flags. Original incomplete receipt preserved; diagnostics admitted only by separately pinned split-store review. This is a machine build, not native semantic qualification.')
start=time.monotonic();deadline=start+a.seconds;child=None
def save():r['wallSeconds']=time.monotonic()-start;(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(label,cmd):
 global child
 row=dict(label=label,command=list(map(str,cmd)));r['jobs'].append(row);save();t=time.monotonic()
 with(out/(label+'.stdout')).open('xb')as so,(out/(label+'.stderr')).open('xb')as se:
  child=subprocess.Popen(row['command'],cwd=ROOT,stdout=so,stderr=se,start_new_session=True);status=child.wait(timeout=max(.001,deadline-time.monotonic()))
 row.update(exitCode=status,seconds=time.monotonic()-t,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')));save();assert status==0
save()
try:
 run('assemble',[assembler['file'],'-mbranches-within-32B-boundaries','-o',out/'program.o',review['assembly']['file']])
 # Same original assembly pathname gives byte-exact diagnostic text too.
 assert pin(out/'assemble.stderr')['sha256']==pipe['jobs'][0]['stderr']['sha256'];assert not(out/'assemble.stdout').stat().st_size
 obj=pin(out/'program.o');assert (obj['bytes'],obj['sha256'])==(review['retainedObject']['bytes'],review['retainedObject']['sha256']);r['object']=obj;r['retainedObjectExact']=True
 run('link',[gcc['file'],'-no-pie',out/'program.o',pipe['runtime']['file'],'-pthread','-lm','-o',out/'program'])
 assert not(out/'link.stdout').stat().st_size and not(out/'link.stderr').stat().st_size
 r['binary']=pin(out/'program');r['buildSeconds']=sum(x['seconds']for x in r['jobs'])
 for x in inputs:verify(x)
 r['complete']=True
except BaseException as e:
 r['error']=repr(e)
 if child is not None and child.poll()is None:
  try:os.killpg(child.pid,signal.SIGKILL)
  except ProcessLookupError:pass
  child.wait()
finally:save()
print(json.dumps({k:r.get(k)for k in ('complete','wallSeconds','binary','error')}));raise SystemExit(0 if r['complete']else 1)
