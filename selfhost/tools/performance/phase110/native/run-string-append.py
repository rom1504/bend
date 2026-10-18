#!/usr/bin/env python3
"""Root-run actual Base String.append native request and independent semantics."""
import argparse,hashlib,json,shutil,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','image','qualification','prepared','runtime-object','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--policy',choices=['runtime-ir-single','runtime-ir-atomic'],default='runtime-ir-single')
p.add_argument('--backends',nargs='+',choices=['qbe','clang'],default=['qbe','clang'])
p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe')
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text())
source_file=a.source.resolve()/'manifest.json';m=read(source_file);image_file=a.image.resolve()/'report.json';image=read(image_file);qualification=a.qualification.resolve();q=read(qualification)
prepared=a.prepared.resolve();prep_file=prepared/'manifest.json';prep=read(prep_file);controls=HERE.parent/'controls/admission/string-append';controls_file=controls/'manifest.json';control=read(controls_file)
if not m['complete'] or not m.get('generalEntry') or not image['complete']:raise ValueError('completed native general image required')
if q.get('kind')!='phase110-native-general-qualification' or not q['complete']:raise ValueError('completed native general qualification required')
if not all(any(row==expected for row in q['inputs']) for expected in [pin(source_file),pin(image_file),image['binary']]):raise ValueError('qualification is for another image/source')
if prep.get('kind')!='phase110-prepared-base-string-append' or not prep['complete'] or prep['observations']!=20 or control['observations']!=20:raise ValueError('frozen String.append harness required')
if control['baseSource']['sha256']!=m['assets']['base']['sha256']:raise ValueError('frozen Base differs from compiled Base')
binary=verify(image['binary']);input_file=verify(control['source'])
tools={name:Path(shutil.which(name)).resolve() for name in ['gcc','as']+(['clang'] if 'clang' in a.backends else [])}
if 'qbe' in a.backends:tools['qbe']=a.qbe.resolve()
inputs=[pin(Path(__file__)),pin(source_file),pin(image_file),pin(qualification),pin(prep_file),pin(controls_file),pin(a.runtime_object),*m['inputs'],m['source'],*q['inputs'],*prep['inputs'],*prep['outputs'],*control['inputs'],*map(pin,tools.values()),pin(Path(sys.executable))]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-actual-base-string-append',complete=False,inputs=inputs,policy=a.policy,backends=a.backends,jobs=[],rows=[],entry=control['entry'],scope='Actual Base String.append through native live canonical admission; independent complete-value/alias/release observations, first-input depth at most 1024.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
def run(label,command):
 for row in inputs:verify(row)
 command=list(map(str,command));job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic();so=out/(label+'.stdout');se=out/(label+'.stderr')
 with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=45)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
 if child.returncode:raise ValueError(label+' failed '+str(child.returncode))
 return so,se
try:
 harness=out/'harness.o';run('harness',[tools['gcc'],'-O2','-std=c11','-I',prepared,'-c',prepared/'harness.c','-o',harness])
 for backend in a.backends:
  fmt='qbe' if backend=='qbe' else 'c';actual,error=run(backend+'-native',[binary,'--threads','1','--gpu','off','--','phase110',input_file,'general',control['entry'],fmt,a.policy,'live'])
  if error.read_bytes() or not actual.stat().st_size:raise ValueError('native product missing or stderr nonempty')
  inputs.append(pin(actual));worker=out/(backend+'.o');worker_binary=out/(backend+'.worker')
  if backend=='qbe':
   assembly=out/(backend+'.s');run(backend+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',assembly,actual]);run(backend+'-assemble',[tools['as'],'-o',worker,assembly])
  else:run(backend+'-compile',[tools['clang'],'-O2','-std=c11','-x','c','-c',actual,'-o',worker])
  run(backend+'-link',[tools['gcc'],'-no-pie',worker,a.runtime_object.resolve(),harness,'-pthread','-lm','-o',worker_binary])
  stdout,stderr=run(backend+'-execute',[worker_binary])
  if stderr.read_bytes():raise ValueError('worker stderr nonempty')
  checked,_=run(backend+'-oracle',[sys.executable,'-B',controls/'check.py','--stdout',stdout]);result=read(checked)
  if not result['complete'] or not result['savedOutputChecked'] or result['observations']!=20:raise ValueError('independent complete-value oracle failed')
  report['rows'].append(dict(backend=backend,observations=20,nativeProduct=pin(actual),worker=pin(worker_binary),stdout=pin(stdout)));save()
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,entry=control['entry'],workers=len(report['rows']),observationsPerBackend=20)))
except BaseException as error:report['error']=repr(error);save();raise
