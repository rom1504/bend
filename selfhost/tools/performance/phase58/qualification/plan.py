#!/usr/bin/env python3
"""Materialize serial checked-B1 gates; no compiler or target execution."""
import argparse,hashlib,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;TOOLS=HERE.parents[1];ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--attempt',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path,required=True)
p.add_argument('--scope',choices=['focused','final'],required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase58')and not out.exists();assert not a.plan.exists()
inputs={}
def pin(file):
 file=Path(file).resolve(strict=True);row=dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest());inputs[str(file)]=row;return row
def read(file):pin(file);return json.loads(Path(file).read_text())
attempt=a.attempt.resolve(strict=True);m=read(attempt/'attempt.json');assert m['checked']and m['config']['strictExact'];node=m['node']['file']
assert m['node']['version']=='v24.18.0';baseline=ROOT/'selfhost/build/phase56/checked-string01/attempt.json';b=read(baseline)
assert b['api']['sha256']=='128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea'
for key in ['api','runtime','base']:
 assert pin(m[key]['file'])['sha256']==m[key]['sha256'];assert pin(b[key]['file'])['sha256']==b[key]['sha256']
commands=[]
def add(name,argv,guard,expected=None):commands.append(dict(name=name,command=list(map(str,argv)),guard=guard,expected=expected))
def acq(name,catalog):
 pin(TOOLS/catalog);pin(TOOLS/'phase52/acquire-semantics-v2.py')
 add('acquire-'+name,['python3','-B',TOOLS/'phase52/acquire-semantics-v2.py','--role','direct','--selection',attempt,'--catalog',TOOLS/catalog,'--out',out/(name+'-acquisition')],'internal sole ExecutionGuard')
def bounded(name,script,args,seconds,expected):
 pin(script);pin(TOOLS/'phase32/bounded-run.py')
 add(name,['python3','-B',TOOLS/'phase32/bounded-run.py','--seconds',seconds,'--rss-mib',2048,'--available-mib',4096,out/(name+'-supervisor'),'--','taskset','-c',3,node,'--max-old-space-size=1024','--stack-size=4096',script,*args],'one outer bounded supervisor',expected)
compositionReference=ROOT/'selfhost/build/phase53/semantic-composition-reference-rebind01.json';pin(compositionReference)
acq('composition','phase53/semantic-composition-catalog-v8.json')
bounded('composition-controls',TOOLS/'phase53/semantic-composition-v3.mjs',[out/'composition-acquisition/manifest.json',compositionReference,out/'composition-controls'],60,dict(candidate=18,typescript=18))
if a.scope=='final':
 reference=ROOT/'selfhost/build/phase53/semantic-overapplication-upstream01/manifest.json';pin(reference)
 acq('overapplication','phase53/semantic-overapplication-catalog-v1.json')
 bounded('overapplication-controls',TOOLS/'phase53/semantic-overapplication-v1.mjs',[out/'overapplication-acquisition/manifest.json',reference,out/'overapplication-controls'],60,dict(candidate=2,typescript=2))
 acq('source','phase52/semantic-catalog-v8.json');join=['python3','-B',TOOLS/'phase52/semantic-full-join-v4.py','--direct',out/'source-acquisition/manifest.json','--catalog',TOOLS/'phase52/semantic-catalog-v8.json'];pin(TOOLS/'phase52/semantic-full-join-v4.py')
 for name in ['semantic-upstream04','semantic-f32-upstream01','semantic-successor-upstream02','semantic-native-upstream01']:
  reference=ROOT/'selfhost/build/phase52'/name/'manifest.json';pin(reference);join+=['--typescript',reference]
 for flag,name in [('reference-controls','semantic-reference-controls03'),('successor-reference-controls','semantic-successor-reference-controls01'),('native-reference-controls','semantic-native-reference-controls01')]:
  reference=ROOT/'selfhost/build/phase52'/name/'report.json';pin(reference);join+=['--'+flag,reference]
 join+=['--out',out/'source-join.json'];add('source-role-join',join,'data only')
 bounded('source-controls',TOOLS/'phase53/semantic-source-v1.mjs',[out/'source-join.json',out/'source-controls'],110,dict(candidate=96,typescript=95,referenceFailuresRetained=1))
 acq('numeric','phase53/semantic-numeric-catalog-v3.json');reference=ROOT/'selfhost/build/phase53/semantic-numeric-reference-rebind01.json';pin(reference)
 bounded('numeric-controls',TOOLS/'phase53/semantic-runtime-v2.mjs',[out/'source-join.json',out/'numeric-acquisition/manifest.json',reference,out/'numeric-controls'],60,dict(candidate=34,typescript=28,referenceFailuresRetained=6))
 for name,script,args,expected in [
  ('direct-census',HERE/'direct-census.py',[attempt,out/'direct-census'],dict(semanticAgreement=26)),
  ('maintained8',TOOLS/'phase47/qualify.py',[attempt,out/'maintained8'],dict(suites=8)),
  ('program45-acquisition',TOOLS/'phase53/acquire.py',['--attempt',attempt,'--set','full','--role','candidate','--backend','direct','--cpu',3,'--heap-mib',1024,'--rss-mib',2048,'--available-mib',4096,'--node',node,'--out',out/'program45'],dict(points=45,sources=23)),
  ('program45-smoke',TOOLS/'phase52/smoke.py',['--manifest',out/'program45/manifest.json','--catalog',TOOLS/'phase37/catalog.json','--out',out/'program45-smoke','--node',node],dict(points=45,passed=True))]:
  pin(script);add(name,['python3','-B',script,*args],'internal sole ExecutionGuard',expected)
 bounded('native3',HERE/'native3.mjs',[baseline.parent,attempt,out/'native3'],240,dict(byteEqual=3,baselineOracles=3,candidateOracles=3))
 policy=read(TOOLS/'phase55/semantic-plan-v1.json');commands[-1]['environment']=policy['nativeEnvironment']
for item in list(inputs.values()):assert pin(item['file'])==item
result=dict(kind='phase58-checked-qualification-plan',executed=False,cwd=str(ROOT),scope=a.scope,attempt=pin(attempt/'attempt.json'),baseline=pin(baseline),producer=pin(__file__),outBase=str(out),commands=commands,inputs=list(inputs.values()),resources=dict(cpu=3,heapMiB=1024,treeRssMiB=2048,availableMiB=4096,stackKiB=4096),barrier='Owner-focused controls precede this plan. Final maintained8 requires live source manifest to match selected snapshot; root reconciles only reviewed selected files. Installed seven files stay unchanged until final release admission.',limits='Counts overlap. Program smoke checks independent values; changed JS bytes are not a failure by themselves. B2 generation/selfcheck/semantics/fixedpoint and release42+24 are separate final gates. No target execution or permission is implied.')
a.plan.parent.mkdir(parents=True,exist_ok=True)
with a.plan.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(executed=False,commands=len(commands),plan=pin(a.plan))))
