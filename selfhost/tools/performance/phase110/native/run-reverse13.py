#!/usr/bin/env python3
"""Root-run the unchanged Phase109 thirteen-case harness on native reverse output."""
import argparse,hashlib,json,shutil,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['qualification','prepared','runtime-object','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--backends',nargs='+',choices=['qbe','clang'],default=['qbe','clang'])
p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe')
p.add_argument('--clang',type=Path)
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text())
qualification=a.qualification.resolve();q=read(qualification);prepared=a.prepared.resolve();prep_file=prepared/'manifest.json';prep=read(prep_file);controls=HERE.parents[1]/'phase109/controls'
control_file=controls/'manifest.json';control=read(control_file);expected_file=controls/control['expected']['file'];expected=[json.loads(line) for line in expected_file.read_text().splitlines()]
if q.get('kind')!='phase110-native-fixed-qualification' or not q.get('complete') or len(q['rows'])!=8:raise ValueError('complete actual native fixed-contract qualification required')
if prep.get('kind')!='phase109-frozen-runtime-harness' or not prep['complete'] or control['ownershipCases']['count']!=13 or len(expected)!=13:raise ValueError('unchanged thirteen-case harness required')
if hashlib.sha256(expected_file.read_bytes()).hexdigest()!=control['expected']['sha256']:raise ValueError('frozen independent expected bytes differ')
products={row['format']:row['output'] for row in q['rows'] if row['contract']=='reverse'}
def executable(name):
 value=shutil.which(name)
 if value is None:raise ValueError('required executable is absent from PATH: '+name)
 return Path(value).resolve()
tools={name:executable(name) for name in ['gcc','as']}
if 'qbe' in a.backends:tools['qbe']=a.qbe.resolve()
if 'clang' in a.backends:tools['clang']=a.clang.resolve() if a.clang else executable('clang')
inputs=[pin(Path(__file__)),pin(qualification),pin(prep_file),pin(control_file),pin(expected_file),pin(controls/'check.py'),pin(a.runtime_object),*q['inputs'],*prep['inputs'],*prep['outputs'],*products.values(),*map(pin,tools.values()),pin(Path(sys.executable))]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-reverse-thirteen-case-semantics',complete=False,inputs=inputs,backends=a.backends,jobs=[],rows=[],scope='Actual native fixed-route reverse workers; unchanged Phase109 thirteen-case count/hash, aliases, scratch and release harness. Diagnostic harness timing is not a benchmark.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
def run(label,command):
 for row in inputs:verify(row)
 command=list(map(str,command));job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic();so=out/(label+'.stdout');se=out/(label+'.stderr')
 with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=45)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
 if child.returncode:raise ValueError(label+' failed '+str(child.returncode))
 return so,se
try:
 harness=out/'harness.o';run('harness',[tools['gcc'],'-O2','-std=gnu11','-I',prepared,'-c',prepared/'harness.c','-o',harness])
 for backend in a.backends:
  actual=verify(products['qbe' if backend=='qbe' else 'c']);worker=out/(backend+'.o');binary=out/(backend+'.worker')
  if backend=='qbe':
   assembly=out/(backend+'.s');run(backend+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',assembly,actual]);run(backend+'-assemble',[tools['as'],'-o',worker,assembly])
  else:run(backend+'-compile',[tools['clang'],'-O2','-std=c11','-x','c','-c',actual,'-o',worker])
  run(backend+'-link',[tools['gcc'],'-no-pie',worker,a.runtime_object.resolve(),harness,'-pthread','-lm','-o',binary])
  stdout,stderr=run(backend+'-execute',[binary]);diagnostics=[json.loads(line) for line in stderr.read_text().splitlines()]
  if [row['name'] for row in diagnostics]!=[row['name'] for row in expected] or any(row['repetitions']!=1 for row in diagnostics):raise ValueError('unexpected harness diagnostics')
  checked,_=run(backend+'-oracle',[sys.executable,'-B',controls/'check.py','--stdout',stdout]);result=read(checked)
  if not result['complete'] or not result['capturedOutputChecked'] or result['frozenControls']!=13:raise ValueError('independent old thirteen-case oracle failed')
  report['rows'].append(dict(backend=backend,controls=13,nativeProduct=pin(actual),worker=pin(binary),stdout=pin(stdout),diagnostics=pin(stderr)));save()
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,workers=len(report['rows']),controlsPerBackend=13)))
except BaseException as error:report['error']=repr(error);save();raise
