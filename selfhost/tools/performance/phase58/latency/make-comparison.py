#!/usr/bin/env python3
"""Data-only final B1/B2 comparison bindings and commands; runs no compiler."""
import argparse, hashlib, json, shlex, sys
from pathlib import Path

HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; RAW=ROOT/'selfhost/build/phase58'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('out',type=Path)
p.add_argument('--attempt',type=Path,required=True,help='Candidate genuine checked attempt directory or attempt.json')
p.add_argument('--emission',type=Path,help='Candidate complete genuine B2 split-emission report; optional until it exists')
p.add_argument('--baseline-attempt',type=Path,default=ROOT/'selfhost/build/phase56/checked-string01/attempt.json')
p.add_argument('--baseline-emission',type=Path,default=ROOT/'selfhost/build/phase56/bootstrap-string01-plan/full/report.json')
p.add_argument('--method',type=Path,default=RAW/'latency-method04')
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
inputs={}
def identity(file):
 file=Path(file).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 return dict(file=str(file),sha256=h.hexdigest())
def pin(value):
 actual=identity(value['file'] if isinstance(value,dict) else value)
 if isinstance(value,dict):assert actual['sha256']==value['sha256']
 if actual['file'] in inputs:assert inputs[actual['file']]==actual
 inputs[actual['file']]=actual;return actual
def read(value):return json.loads(Path(pin(value)['file']).read_text())
def checked(file):
 file=file/'attempt.json' if file.is_dir() else file
 artifact=pin(file);attempt=read(artifact);assert Path(artifact['file']).name=='attempt.json'
 assert attempt['checked'] is True and isinstance(attempt['config']['strictExact'],bool)
 for key in ['api','checkedApi','bootstrapReport','runtime','base']:pin(attempt[key])
 bootstrap=read(attempt['bootstrapReport']);source=pin(bootstrap['source'])
 assert source['sha256']==bootstrap['sourceSha256']
 return dict(kind='checked',attempt=artifact),dict(api=pin(attempt['api']),source=source,
  strictExact=attempt['config']['strictExact'],productionQualified=False),attempt
def direct(file,role,attempt):
 artifact=pin(file);emission=read(artifact)
 assert emission['kind']=='phase55-split-compiler-emission' and emission['complete'] is True and emission['pass'] is True
 assert pin(emission['generator']['attempt'])==role['attempt']
 assert pin(emission['generator']['api'])==pin(attempt['api'])
 assert pin(emission['generator']['bootstrap'])==pin(attempt['bootstrapReport'])
 assert pin(emission['generator']['runtime'])==pin(attempt['runtime'])
 pin(emission['module']);pin(emission['directRuntime']);pin(emission['subject']['source'])
 assert emission['checking']['lane']=='inherited-exact-bootstrap' and emission['checking']['freshSelfCheck'] is False
 assert emission['checking']['sourceSha256']==emission['subject']['source']['sha256']
 return dict(kind='direct',attempt=role['attempt'],emission=artifact),dict(api=pin(emission['module']),
  subject=emission['subject'],generator=emission['generator'],productionQualified=False)
baseline,before,old=checked(a.baseline_attempt);candidate,after,new=checked(a.attempt)
suites=[('b1',baseline,candidate,before,after)]
if a.emission:
 b,bi=direct(a.baseline_emission,baseline,old);c,ci=direct(a.emission,candidate,new)
 suites.append(('b2',b,c,bi,ci))
method=a.method.resolve();runner=pin(method/'run.py');derivation=read(method/'derivation.json')
for item in derivation['derivations']:pin(item['parent']);pin(item['output'])
pin(derivation['producer']);pin(derivation['setup']);producer=pin(__file__)
files=[];plans=[]
for label,b,c,bi,ci in suites:
 binding=out/(label+'-bindings.json')
 body=dict(kind='phase58-compiler-image-bindings',version=1,comparison='changed-source',
  scope='Prior installed string01 versus new compiler source. Genuine '+label.upper()+' images; no fixed-source, self-check, release or code-generation-only claim. Actual pilot/qualification status remains explicit.',roles=dict(baseline=b,candidate=c))
 files.append((binding,body))
 base=[sys.executable,runner['file']];shared=['--bindings',str(binding),'--roles','baseline,candidate,typescript','--cases','test-evening-program,lexer']
 preparation=out/(label+'-preparation');clean=out/(label+'-clean')
 commands=dict(prepare=base+[str(preparation),*shared,'--prepare-only','--seconds','180'],
  clean=base+[str(clean),*shared,'--preparations',str(preparation/'report.json'),'--rounds','3','--warm-requests','3','--seconds','600'])
 for mode in ['cpu','allocation']:
  commands[mode]=base+[str(out/(label+'-'+mode)),'--bindings',str(binding),'--roles','baseline,candidate','--cases','lexer',
   '--preparations',str(preparation/'report.json'),'--mode',mode,'--warm-requests','3','--profile-ms','5000','--seconds','90']
 plans.append(dict(suite=label,baseline=bi,candidate=ci,bindings=str(binding),commands=commands,
  cleanWorkers=18,cleanRequests=72,profileWorkersPerMode=2))
for item in inputs.values():assert identity(item['file'])==item
out.mkdir(parents=True)
for file,body in files:file.write_text(json.dumps(body,indent=2)+'\n')
report=dict(kind='phase58-compiler-comparison-recipe',complete=True,dataOnly=True,
 producer=producer,inputs=list(inputs.values()),bindings=[identity(file) for file,_ in files],suites=plans,
 b2Pending=a.emission is None,
 validation='Static receipt/hash joins only. setup-v2 and the runner independently verify genuine checked/emitted provenance and per-role full output oracle before measurement.',
 scope='Two separately labelled changed-source matrices, not a pooled five-image statistic. First+three later ordinary requests per clean process. Same pinned TS, private API-keyed Base caches. Profiles include collected allocations and output checks; they never enter clean ratios. No targets launched, qualification or installation performed.')
report['pass']=True
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
(out/'commands.txt').write_text('\n\n'.join('# '+s['suite']+' '+name+'\n'+shlex.join(cmd) for s in plans for name,cmd in s['commands'].items())+'\n')
print(json.dumps(dict(report=identity(out/'report.json'),suites=[x['suite'] for x in plans],b2Pending=report['b2Pending'])))
