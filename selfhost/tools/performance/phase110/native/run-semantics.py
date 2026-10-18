#!/usr/bin/env python3
"""Root-run native-produced closure worker semantics; supervise serially under guard."""
import argparse,hashlib,json,shutil,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['qualification','prepared','runtime-object','out']:p.add_argument('--'+name,type=Path,required=True)
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
qualification=a.qualification.resolve();q=read(qualification);prepared=a.prepared.resolve();prep_file=prepared/'manifest.json';prep=read(prep_file)
if q.get('kind')!='phase110-native-general-qualification' or not q.get('complete'):raise ValueError('complete native qualification required')
if prep.get('kind')!='phase110-prepared-native-closure-semantics' or not prep.get('complete'):raise ValueError('complete independent prepared harness required')
controls=HERE.parent/'controls/admission/native-semantics';manifest_file=controls/'manifest.json';manifest=read(manifest_file)
if prep['roots']!=manifest['roots'] or prep['observations']!=36:raise ValueError('frozen root/observation mapping differs')
if len(q['rows'])!=8 or len(q['refusals'])!=4:raise ValueError('native request qualification incomplete')
tools={name:Path(shutil.which(name)).resolve() for name in ['gcc','as']+(['clang'] if 'clang' in a.backends else [])}
if 'qbe' in a.backends:tools['qbe']=a.qbe.resolve()
outputs={(row['name'],row['format']):row['output'] for row in q['rows']}
inputs=[pin(Path(__file__)),pin(qualification),pin(prep_file),pin(manifest_file),pin(a.runtime_object),*q['inputs'],*prep['inputs'],*prep['outputs'],*outputs.values(),*map(pin,tools.values()),pin(Path(sys.executable))]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-closure-worker-semantics',complete=False,inputs=inputs,backends=a.backends,jobs=[],rows=[],scope='Actual native-emitted QBE/C compiled against one pinned GCC runtime object; frozen whole-value, alias-release and heap-balance observations.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
def run(label,command):
 for row in inputs:verify(row)
 command=list(map(str,command));job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic()
 so=out/(label+'.stdout');se=out/(label+'.stderr')
 with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=45)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
 if child.returncode:raise ValueError(label+' failed '+str(child.returncode))
 return so,se
try:
 for root in manifest['roots']:
  index=root['index'];name=root['name'];harness=out/('harness-'+str(index)+'.o')
  run('harness-'+str(index),[tools['gcc'],'-O2','-std=c11','-DP110_CLOSURE_ROOT='+str(index),'-I',prepared,'-c',prepared/'harness.c','-o',harness])
  for backend in a.backends:
   label=str(index)+'-'+backend;worker=out/(label+'.o');binary=out/(label+'.worker')
   actual=verify(outputs[name,'qbe' if backend=='qbe' else 'c'])
   if backend=='qbe':
    assembly=out/(label+'.s');run(label+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',assembly,actual]);run(label+'-assemble',[tools['as'],'-o',worker,assembly])
   else:run(label+'-compile',[tools['clang'],'-O2','-std=c11','-x','c','-c',actual,'-o',worker])
   run(label+'-link',[tools['gcc'],'-no-pie',worker,a.runtime_object.resolve(),harness,'-pthread','-lm','-o',binary])
   stdout,stderr=run(label+'-execute',[binary])
   if stderr.read_bytes():raise ValueError(label+' worker wrote stderr')
   checked,_=run(label+'-oracle',[sys.executable,'-B',controls/'check.py','--root',str(index),'--stdout',stdout])
   result=read(checked)
   if not result['complete'] or not result['savedOutputChecked']:raise ValueError(label+' oracle incomplete')
   report['rows'].append(dict(root=index,name=name,backend=backend,observations=result['observations'],worker=pin(binary),nativeProduct=pin(actual),stdout=pin(stdout)));save()
 for backend in a.backends:
  if sum(row['observations'] for row in report['rows'] if row['backend']==backend)!=36:raise ValueError('wrong observation total '+backend)
 for row in inputs:verify(row)
 report['complete']=True;report['observationsPerBackend']=36;save();print(json.dumps(dict(complete=True,workers=len(report['rows']),observationsPerBackend=36,backends=a.backends)))
except BaseException as error:report['error']=repr(error);save();raise
