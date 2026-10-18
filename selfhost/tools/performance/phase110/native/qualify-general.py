#!/usr/bin/env python3
"""Root-run native checked entry requests and exact machine-product qualification.

Run serially under the outer process-tree guard. This script does not compile or
execute emitted workers; independent semantic harness execution is a later gate.
"""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','image','expected','semantics','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda file:dict(file=str(Path(file).resolve()),bytes=Path(file).stat().st_size,sha256=hashlib.sha256(Path(file).read_bytes()).hexdigest())
def verify(row):
 file=Path(row['file']);file=file if file.is_absolute() else ROOT/file
 actual=pin(file)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(file))
 return file
read=lambda file:json.loads(Path(file).read_text())
source_file=a.source.resolve()/'manifest.json';m=read(source_file)
build_file=a.image.resolve()/'report.json';build=read(build_file)
expected_file=a.expected.resolve()/'report.json';expected=read(expected_file)
semantics_file=a.semantics.resolve();semantics=read(semantics_file)
if not m['complete'] or not m.get('generalEntry') or not build['complete'] or not expected['complete']:raise ValueError('incomplete input')
if expected['kind']!='phase110-native-general-expected' or len(expected['rows'])!=4:raise ValueError('four expected roots required')
if semantics.get('kind')!='phase110-frozen-native-closure-semantics-v1':raise ValueError('wrong frozen semantics manifest')
if [row['name'] for row in expected['rows']]!=[row['name'] for row in semantics['roots']]:raise ValueError('semantic root mapping differs')
if not any(row==pin(source_file) for row in expected['inputs']):raise ValueError('expected products came from another native source')
binary=verify(build['binary'])
if binary.parent!=a.image.resolve():raise ValueError('image binary path differs')
# Authenticate acquisition source -> emitted C -> metadata bridge -> built image.
emit=a.image.resolve().parent/'emit'
emit_file=emit/'report.json';emitted=read(emit_file);metadata_file=emit/'metadata.json';metadata=read(metadata_file)
if not emitted['complete'] or emitted['source']!=m['source']:raise ValueError('native acquisition source differs')
portable=ROOT/metadata['output'];generated=ROOT/metadata['input']
if pin(portable)['sha256']!=metadata['outputSha256'] or pin(generated)['sha256']!=metadata['inputSha256']:raise ValueError('metadata bridge differs')
if not any(Path(row['file']).resolve()==generated.resolve() and row['sha256']==metadata['inputSha256'] for row in emitted['outputs']):raise ValueError('metadata input is not actual emitted C')
if not any(Path(row['file']).resolve()==portable.resolve() and row['sha256']==metadata['outputSha256'] for row in build['inputs']):raise ValueError('image did not build exact portable C')
closure_manifest_file=HERE.parent/'controls/admission/closure-manifest.json';closure_manifest=read(closure_manifest_file)
closure_source=verify(closure_manifest['source']);oracle_file=verify(closure_manifest['oracle']);oracle=read(oracle_file)
unreachable=semantics['unreachable'];unreachable_source=verify(unreachable['source'])
inputs=[pin(Path(__file__)),pin(source_file),m['source'],m['assets']['base'],pin(build_file),build['binary'],pin(emit_file),pin(metadata_file),pin(portable),pin(generated),pin(expected_file),pin(semantics_file),pin(closure_manifest_file),pin(oracle_file),pin(closure_source),pin(unreachable_source),*expected['inputs'],*semantics['inputs']]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-general-qualification',complete=False,inputs=inputs,policy=expected['policy'],jobs=[],rows=[],refusals=[],scope='Actual native mature checker, canonical entry/closed-call admission and exact QBE/C emission; emitted-worker semantics are a separate gate.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
def run(label,input,entry,fmt='qbe',status=0,mode='live'):
 for row in inputs:verify(row)
 command=[str(binary),'--threads','1','--gpu','off','--','phase110',str(input),'general',entry,fmt,expected['policy'],mode]
 job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic()
 so=out/(label+'.stdout');se=out/(label+'.stderr')
 with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=45)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
 if child.returncode!=status:raise ValueError(label+' unexpected status '+str(child.returncode))
 return so.read_bytes(),se.read_bytes()
try:
 for test in expected['rows']:
  for fmt,key in [('qbe','expectedQbe'),('c','expectedC')]:
   expected_path=verify(test[key]);inputs.append(pin(expected_path));save()
   label=test['name']+'-'+fmt;actual,error=run(label,closure_source,test['name'],fmt)
   if error or actual!=expected_path.read_bytes()+b'\n':raise ValueError(label+' exact product differs')
   report['rows'].append(dict(name=test['name'],format=fmt,output=pin(out/(label+'.stdout')),exactExpectedPlusPrintNewline=True));save()
 for test in oracle['roots']:
  if test['closedLibraryAccepted']:continue
  label='refuse-'+test['name'];actual,error=run(label,closure_source,test['name'],status=1)
  if actual or test['refusedDependency'].encode() not in error or b'checked entry closure refused' not in error:raise ValueError(label+' wrong refusal')
  report['refusals'].append(dict(name=test['name'],reason=error.decode(),source=pin(closure_source)));save()
 actual,error=run('refuse-unreachable',unreachable_source,unreachable['requestedEntry'],status=1)
 if actual or b'missing or mismatched erased fact' not in error:raise ValueError('wrong unreachable-entry refusal')
 report['refusals'].append(dict(name='unreachable-entry',reason=error.decode(),source=pin(unreachable_source)));save()
 actual,error=run('refuse-general-cache',closure_source,expected['rows'][0]['name'],status=2,mode='cache')
 if actual or b'POLICY live' not in error:raise ValueError('general cached seed accepted')
 report['refusals'].append(dict(name='general-cache',reason=error.decode()));save()
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,products=len(report['rows']),refusals=len(report['refusals']))))
except BaseException as error:report['error']=repr(error);save();raise
