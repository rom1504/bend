#!/usr/bin/env python3
"""Root-run frozen QBE transfer comparison; no policy search or source algorithm."""
import argparse,hashlib,json,math,shutil,statistics,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['plan','runtime-object','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe')
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text());lines=lambda path:[json.loads(line) for line in Path(path).read_text().splitlines()]
plan_file=a.plan.resolve()/'manifest.json';plan=read(plan_file)
if plan.get('kind')!='phase110-frozen-native-transfer' or not plan['complete'] or plan['rounds']!=5 or plan['baseline']!='fused' or plan['selected']!='runtime-ir-single' or plan['backend']!='qbe':raise ValueError('exact frozen transfer plan required')
tools={name:Path(shutil.which(name)).resolve() for name in ['gcc','as']};tools['qbe']=a.qbe.resolve()
inputs=[pin(Path(__file__)),pin(plan_file),pin(a.runtime_object),*plan['inputs'],*plan['outputs'],*map(pin,tools.values())]
unique={}
for row in inputs:
 name=str(Path(row['file']).resolve())
 if name in unique and (unique[name]['sha256'],unique[name]['bytes'])!=(row['sha256'],row['bytes']):raise ValueError('conflicting pinned input '+name)
 unique[name]=row
inputs=list(unique.values())
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-fixed-policy-transfer',complete=False,inputs=inputs,plan=pin(plan_file),jobs=[],semantics=[],timings=[],paired=[],summary=[],scope=plan['scope'],selectionChanged=False)
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
 for i,algorithm in enumerate(plan['algorithms']):
  expected=lines(verify(algorithm['expected']));prepared=Path(algorithm['prepared']);harness=out/(str(i)+'-harness.o')
  run(str(i)+'-harness',[tools['gcc'],'-O2','-std=gnu11','-I',prepared,'-c',verify(algorithm['harness']),'-o',harness])
  if algorithm['mode']=='fixed':args=[verify(algorithm['source']),algorithm['entry'],'qbe','fused','cache']
  else:args=[verify(algorithm['source']),'general',algorithm['entry'],'qbe','fused','live']
  baseline,error=run(str(i)+'-baseline-native',[verify(plan['image']),'--threads','1','--gpu','off','--','phase110',*args])
  if error.read_bytes() or not baseline.stat().st_size:raise ValueError('baseline native output missing or stderr nonempty')
  if 'baselineExpected' in algorithm and baseline.read_bytes()!=verify(algorithm['baselineExpected']).read_bytes()+b'\n':raise ValueError('baseline fixed product differs from qualified fused product')
  for policy,product in [('fused',pin(baseline)),('runtime-ir-single',algorithm['selected'])]:
   actual=verify(product);inputs.append(product);label=str(i)+'-'+policy;assembly=out/(label+'.s');worker=out/(label+'.o');binary=out/(label+'.worker')
   run(label+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',assembly,actual]);run(label+'-assemble',[tools['as'],'-o',worker,assembly]);run(label+'-link',[tools['gcc'],'-no-pie',worker,a.runtime_object.resolve(),harness,'-pthread','-lm','-o',binary])
   stdout,stderr=run(label+'-semantics',[binary])
   if lines(stdout)!=expected:raise ValueError(label+' original complete oracle differs')
   diagnostics=lines(stderr)
   if [row['name'] for row in diagnostics]!=list(dict.fromkeys(row['name'] for row in expected)) or any(row['repetitions']!=1 for row in diagnostics):raise ValueError('semantic diagnostic identities differ')
   binaries[i,policy]=binary;inputs.append(pin(binary));report['semantics'].append(dict(algorithm=algorithm['name'],policy=policy,observations=len(expected),nativeProduct=product,worker=pin(binary),stdout=pin(stdout)));save()
 for round_index in range(plan['rounds']):
  policies=['fused','runtime-ir-single'] if round_index%2==0 else ['runtime-ir-single','fused']
  for i,algorithm in enumerate(plan['algorithms']):
   expected=lines(verify(algorithm['expected']))
   for case_index,case in enumerate(algorithm['cases']):
    times={}
    for policy in policies:
     label='r'+str(round_index)+'-a'+str(i)+'-c'+str(case_index)+'-'+policy;stdout,stderr=run(label,[binaries[i,policy],case,str(algorithm['repetitions'])])
     if lines(stdout)!=[row for row in expected if row['name']==case]:raise ValueError(label+' repeated-worker oracle differs')
     diagnostics=lines(stderr)
     if len(diagnostics)!=1 or diagnostics[0]['name']!=case or diagnostics[0]['repetitions']!=algorithm['repetitions']:raise ValueError('timing identity differs')
     diagnostic=diagnostics[0];seconds=diagnostic['workerSeconds']
     if not math.isfinite(seconds) or seconds<=0:raise ValueError('invalid worker time')
     calls=algorithm['repetitions']*algorithm['callsPerRepetition']
     if 'workerCalls' in diagnostic and diagnostic['workerCalls']!=calls:raise ValueError('wrong timed call count')
     times[policy]=seconds/calls;report['timings'].append(dict(round=round_index,algorithm=algorithm['name'],case=case,policy=policy,calls=calls,workerSeconds=seconds,secondsPerCall=seconds/calls,stdout=pin(stdout),diagnostics=pin(stderr)));save()
    report['paired'].append(dict(round=round_index,algorithm=algorithm['name'],case=case,selectedOverFused=times['runtime-ir-single']/times['fused']));save()
 for algorithm in plan['algorithms']:
  for case in algorithm['cases']:
   ratios=[row['selectedOverFused'] for row in report['paired'] if row['algorithm']==algorithm['name'] and row['case']==case]
   report['summary'].append(dict(algorithm=algorithm['name'],case=case,rounds=len(ratios),medianSelectedOverFused=statistics.median(ratios),minSelectedOverFused=min(ratios),maxSelectedOverFused=max(ratios)))
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,algorithms=2,cases=len(report['summary']),pairedRounds=len(report['paired']),selectionChanged=False)))
except BaseException as error:report['error']=repr(error);save();raise
