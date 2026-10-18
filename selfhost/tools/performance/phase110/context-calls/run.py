#!/usr/bin/env python3
"""Root-run context-call machine ablation on frozen semantic/timing corpora."""
import argparse,hashlib,json,math,shutil,statistics,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['emission','admission','transfer-plan','runtime-object','runtime-build','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe')
p.add_argument('--clang',type=Path)
p.add_argument('--backends',nargs='+',choices=['qbe','clang'],default=['qbe','clang'])
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text());lines=lambda path:[json.loads(line) for line in Path(path).read_text().splitlines()]
emission_file=a.emission.resolve()/'report.json';emission=read(emission_file);admission_file=a.admission.resolve()/'manifest.json';admission=read(admission_file);transfer_file=a.transfer_plan.resolve()/'manifest.json';transfer=read(transfer_file)
if emission.get('kind')!='phase110-context-call-emission' or not emission['complete'] or len(emission['rows'])!=9 or len(emission['mutations'])!=54:raise ValueError('qualified context-call emissions required')
if admission.get('kind')!='phase110-context-call-admission' or not admission['complete'] or len(admission['controls'])!=7 or not all(row['ok'] for row in admission['controls']):raise ValueError('complete source/runtime admission required')
if not any(row==admission['inputs'][0] for row in emission['inputs']):raise ValueError('API source differs from admitted runtime-template source')
if transfer.get('kind')!='phase110-frozen-native-transfer' or not transfer['complete'] or transfer['rounds']!=5:raise ValueError('original frozen transfer plan required')
runtime_build_file=a.runtime_build.resolve();runtime_build_file=runtime_build_file/'report.json' if runtime_build_file.is_dir() else runtime_build_file;runtime_build=read(runtime_build_file)
if runtime_build.get('kind')!='phase110-context-runtime-build' or not runtime_build['complete']:raise ValueError('complete pinned context runtime build required')
if runtime_build['object']!=pin(a.runtime_object):raise ValueError('runtime object differs from admitted build product')
if not any(row==runtime_build['source'] for row in admission['inputs']):raise ValueError('runtime build source differs from exact context admission')
runtime_manifests=[row for row in admission['inputs'] if Path(row['file']).name=='manifest.json' and read(verify(row)).get('kind')=='phase110-context-call-runtime-core']
if len(runtime_manifests)!=1:raise ValueError('one admitted context runtime capsule required')
runtime_manifest=read(verify(runtime_manifests[0]))
if not runtime_manifest['complete'] or runtime_build['source']!=next(row for row in runtime_manifest['outputs'] if Path(row['file']).name=='runtime.c'):raise ValueError('runtime build did not compile the context assertion capsule')
if not any(row==runtime_build['source'] for row in runtime_build['inputs']):raise ValueError('runtime build does not pin its source')
process=read(verify(runtime_build['process']))
if not process.get('complete') or process.get('returncode')!=0:raise ValueError('runtime build process did not succeed')
string_plan=next(row for row in transfer['algorithms'] if row['name']=='String.append');list_plan=next(row for row in transfer['algorithms'] if row['name']=='nt_append')
reverse_dir=ROOT/'selfhost/build/phase109/p110-native-reverse13';reverse_manifest=read(reverse_dir/'manifest.json');reverse_control=ROOT/'selfhost/tools/performance/phase109/controls';reverse_expected=reverse_control/'expected.jsonl'
cases=[dict(name='string_append',harness=string_plan['harness'],prepared=string_plan['prepared'],expected=string_plan['expected'],count=20),dict(name='nt_append',harness=list_plan['harness'],prepared=list_plan['prepared'],expected=list_plan['expected'],count=6),dict(name='reverse',harness=pin(reverse_dir/'harness.c'),prepared=str(reverse_dir),expected=pin(reverse_expected),count=13)]
def executable(name):
 path=shutil.which(name)
 if path is None:raise ValueError('required executable missing from PATH: '+name)
 return Path(path).resolve()
tools={name:executable(name) for name in ['gcc','as']}
if 'qbe' in a.backends:tools['qbe']=a.qbe.resolve()
if 'clang' in a.backends:tools['clang']=a.clang.resolve() if a.clang else executable('clang')
products={(row['name'],row['mode']):row for row in emission['rows']}
inputs=[pin(Path(__file__)),pin(emission_file),pin(admission_file),pin(transfer_file),pin(runtime_build_file),*runtime_build['inputs'],runtime_build['source'],runtime_build['object'],runtime_build['process'],*runtime_manifest['inputs'],*runtime_manifest['outputs'],*emission['inputs'],*admission['inputs'],*admission['runtimeChain'],*transfer['inputs'],*transfer['outputs'],pin(reverse_dir/'manifest.json'),*reverse_manifest['inputs'],*reverse_manifest['outputs'],pin(reverse_control/'manifest.json'),pin(reverse_expected),*map(pin,tools.values())]
for product in emission['rows']:inputs += [product['library'],product['qbe'],product['c']]
unique={}
for row in inputs:
 key=str(Path(row['file']).resolve())
 if key in unique and (unique[key]['sha256'],unique[key]['bytes'])!=(row['sha256'],row['bytes']):raise ValueError('conflicting input pin')
 unique[key]=row
inputs=list(unique.values())
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-context-call-machine-ablation',complete=False,inputs=inputs,backends=a.backends,jobs=[],semantics=[],timings=[],paired=[],summary=[],selectionChanged=False,runtimeBuild=pin(runtime_build_file),runtimeObject=runtime_build['object'],runtimeByteIdenticalToOriginal=runtime_build.get('byteIdenticalToOriginalRuntimeObject',False),timingPlan=dict(algorithm='String.append',cases=string_plan['cases'],rounds=5,repetitions=string_plan['repetitions'],callsPerRepetition=2,order='baseline/threaded/context on even rounds; reversed on odd rounds'),scope='Separate post-selection context-call ablation. Same frozen two bounded String.append timing graphs, all original semantic oracles, QBE and matched Clang; native selected image unchanged.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
def run(label,command):
 for row in inputs:verify(row)
 command=list(map(str,command));job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic();so=out/(label+'.stdout');se=out/(label+'.stderr')
 with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=60)
 job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
 if child.returncode:raise ValueError(label+' failed '+str(child.returncode))
 return so,se
try:
 binaries={}
 for case in cases:
  expected=lines(verify(case['expected']))
  if len(expected)!=case['count']:raise ValueError('frozen semantic count differs')
  harness=out/(case['name']+'-harness.o');run(case['name']+'-harness',[tools['gcc'],'-O2','-std=gnu11','-I',case['prepared'],'-c',verify(case['harness']),'-o',harness])
  for mode in ['baseline','threaded','context']:
   for backend in a.backends:
    label=case['name']+'-'+mode+'-'+backend;product=products[case['name'],mode];actual=verify(product['qbe' if backend=='qbe' else 'c']);worker=out/(label+'.o');binary=out/(label+'.worker')
    if backend=='qbe':
     assembly=out/(label+'.s');run(label+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',assembly,actual]);run(label+'-assemble',[tools['as'],'-o',worker,assembly])
    else:run(label+'-compile',[tools['clang'],'-O2','-std=c11','-x','c','-c',actual,'-o',worker])
    run(label+'-link',[tools['gcc'],'-no-pie',worker,a.runtime_object.resolve(),harness,'-pthread','-lm','-o',binary]);stdout,stderr=run(label+'-semantics',[binary])
    if lines(stdout)!=expected:raise ValueError(label+' original oracle differs')
    diagnostics=lines(stderr)
    if [row['name'] for row in diagnostics]!=list(dict.fromkeys(row['name'] for row in expected)) or any(row['repetitions']!=1 for row in diagnostics):raise ValueError('semantic diagnostics differ')
    binaries[case['name'],mode,backend]=binary;inputs.append(pin(binary));report['semantics'].append(dict(name=case['name'],mode=mode,backend=backend,observations=len(expected),product=pin(actual),worker=pin(binary),stdout=pin(stdout)));save()
 expected=lines(verify(string_plan['expected']))
 for round_index in range(5):
  modes=['baseline','threaded','context'] if round_index%2==0 else ['context','threaded','baseline']
  for backend in a.backends:
   for case_index,case in enumerate(string_plan['cases']):
    times={}
    for mode in modes:
     label='r'+str(round_index)+'-c'+str(case_index)+'-'+mode+'-'+backend;stdout,stderr=run(label,[binaries['string_append',mode,backend],case,str(string_plan['repetitions'])])
     if lines(stdout)!=[row for row in expected if row['name']==case]:raise ValueError(label+' timed original oracle differs')
     diagnostics=lines(stderr)
     if len(diagnostics)!=1 or diagnostics[0]['name']!=case or diagnostics[0]['repetitions']!=string_plan['repetitions'] or diagnostics[0]['workerCalls']!=2*string_plan['repetitions']:raise ValueError('timing identity/call count differs')
     seconds=diagnostics[0]['workerSeconds']
     if not math.isfinite(seconds) or seconds<=0:raise ValueError('invalid worker duration')
     times[mode]=seconds;report['timings'].append(dict(round=round_index,case=case,mode=mode,backend=backend,calls=2*string_plan['repetitions'],workerSeconds=seconds,stdout=pin(stdout),diagnostics=pin(stderr)));save()
    for mode in ['threaded','context']:report['paired'].append(dict(round=round_index,case=case,mode=mode,backend=backend,variantOverBaseline=times[mode]/times['baseline']))
    save()
 for backend in a.backends:
  for case in string_plan['cases']:
   for mode in ['threaded','context']:
    ratios=[row['variantOverBaseline'] for row in report['paired'] if row['case']==case and row['mode']==mode and row['backend']==backend]
    report['summary'].append(dict(case=case,mode=mode,backend=backend,rounds=len(ratios),medianVariantOverBaseline=statistics.median(ratios),minVariantOverBaseline=min(ratios),maxVariantOverBaseline=max(ratios)))
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,workers=len(report['semantics']),paired=len(report['paired']),selectionChanged=False)))
except BaseException as error:report['error']=repr(error);save();raise
