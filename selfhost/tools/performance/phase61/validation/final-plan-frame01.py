#!/usr/bin/env python3
"""Prepare separate root-run stages from existing methods; never execute targets/install."""
import argparse,hashlib,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];TOOLS=ROOT/'selfhost/tools/performance';RAW=ROOT/'selfhost/build/phase61'
BOOTSTRAP_PRODUCER=TOOLS/'phase61/validation/prepare-candidate-v4.py'
BOOTSTRAP_SHA='ccd302ef74f60696d9e9a474235d83b00e7363b983408847cf65a60a92dcb144'
PARENT=Path(__file__).with_name('final-plan.py');PARENT_SHA='219af6925e5fe967b8fdeb15b72ba9763d9cd42dbe8931f4048ed89f504d7678'
FACTORY=Path(__file__).with_name('prepare-methods-frame01.py');FACTORY_SHA='4aa369b4beb521f5ff37abcb1f44a6158f55efe6e1e025d77cab5c2e6a187d58'
p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='action',required=True)
s=sub.add_parser('plan');s.add_argument('--methods',type=Path,required=True);s.add_argument('--attempt',type=Path,required=True);s.add_argument('--out',type=Path,required=True);s.add_argument('--plans',type=Path,required=True);s.add_argument('--bootstrap-pins',type=Path)
s=sub.add_parser('release-commands');s.add_argument('--release-plan',type=Path,required=True);s.add_argument('--out',type=Path,required=True)
a=p.parse_args();inputs={}
def pin(f):
 f=Path(f).resolve(strict=True);r=dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest());assert str(f)not in inputs or inputs[str(f)]==r;inputs[str(f)]=r;return r
def read(f):pin(f);return json.loads(Path(f).read_text())
def fresh(f):
 f=Path(f).resolve();assert f.is_relative_to(RAW)and not f.exists(),f;return f
def write(f,v):
 f.parent.mkdir(parents=True,exist_ok=True)
 with f.open('x')as o:json.dump(v,o,indent=2);o.write('\n')
def command(name,argv,**kw):return dict(name=name,command=list(map(str,argv)),**kw)
def verify():
 for r in list(inputs.values()):assert pin(r['file'])==r
pin(__file__);assert pin(PARENT)['sha256']==PARENT_SHA
assert pin(FACTORY)['sha256']==FACTORY_SHA
policy=read(TOOLS/'phase55/semantic-plan-v1.json');clang=policy['nativeEnvironment']
assert set(clang)=={'CC','CPATH','LIBRARY_PATH','LD_LIBRARY_PATH'}
assert Path(clang['CC']).is_file();pin(clang['CC'])
for k in ['CPATH','LIBRARY_PATH','LD_LIBRARY_PATH']:assert Path(clang[k]).is_dir()
if a.action=='release-commands':
 q=read(a.release_plan);assert q['kind']=='phase53-default-release-qualification-plan'and q['executed']is False
 assert q['cwd']==str(ROOT)and Path(q['output']).is_relative_to(RAW)
 assert [x['name']for x in q['steps']]==['install','verify-before','legacy42','default24','verify-after']
 assert q['steps'][2]['expected']['steps']==42 and q['steps'][3]['expected']['steps']==24
 assert not Path(q['output']).exists();dest=fresh(a.out)
 rows=[command(x['name'],x['guardedArgv'],environment=clang,expected=x['expected'])for x in q['steps']]
 for x in q['tools']+[q['attempt'],q['api'],q['node'],q['directRuntime'],q['vendorManifest']]:assert pin(x['file'])['sha256']==x['sha256']
 verify();write(dest,dict(kind='phase58-root-release-launch-plan',cwd=str(ROOT),executed=False,sourcePlan=pin(a.release_plan),commands=rows,inputs=list(inputs.values()),barrier='Root explicitly admits installation only after final semantic, emitted-program, B2 and performance gates. This conversion grants no admission. Use the existing unpinned serial launcher; commands already own their guards.'))
 print(json.dumps(dict(plan=pin(dest),commands=5,executed=False)));sys.exit(0)
methods=a.methods.resolve(strict=True);assert methods.parent==RAW.resolve();HERE=methods/'qualification'
method=read(methods/'methods.json');assert method['kind']=='phase61-framed81-validation-methods'and method['complete']is True
assert method['producer']==pin(FACTORY)
for row in method['rows']:
 assert pin(row['parent']['file'])==row['parent'];text=Path(row['parent']['file']).read_text()
 for edit in row['edits']:
  assert edit['old'] in text;text=text.replace(edit['old'],edit['new'])
 assert Path(row['output']['file']).read_text()==text
 assert pin(row['output']['file'])==row['output']
assert pin(BOOTSTRAP_PRODUCER)['sha256']==BOOTSTRAP_SHA
attempt=a.attempt.resolve(strict=True);m=read(attempt/'attempt.json');assert m['checked']is True and m['config']['strictExact']is True
v=read(attempt/'validation-001/report.json');assert v['complete']and v['pass']and v['strictExact']is True and v['selected']['exactDifferences']==0
assert v['api']['sha256']==m['api']['sha256'];assert pin(v['attempt']['file'])['sha256']==v['attempt']['sha256']
for k in ['api','runtime','base','node','bootstrapReport']:assert pin(m[k]['file'])['sha256']==m[k]['sha256']
boot=read(m['bootstrapReport']['file']);roots=boot['exports'];assert len(roots)==len(set(roots))==81
assert {'base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix'}.issubset(roots)
assert m['node']['version']=='v24.18.0';node=m['node']['file'];out=fresh(a.out);plans=fresh(a.plans)
runner=TOOLS/'phase55/run-retention-plan.py';bounded=TOOLS/'phase32/bounded-run.py';bootstrap=HERE.parent/'bootstrap';release=TOOLS/'phase53/release-qualification-plan-v1.py'
for f in [runner,bounded,release,HERE/'plan.py',HERE/'b2-plan.py',HERE/'self-check.mjs',HERE/'benchmark-equality.mjs',BOOTSTRAP_PRODUCER,bootstrap/'reproduce.mjs']:pin(f)
stages=[]
def stage(name,rows,barrier,expected):
 f=plans/(name+'.json');stages.append(dict(name=name,plan=str(f),barrier=barrier,expected=expected,commands=rows))
def py(script,*args):return ['python3','-B',script,*args]
def run(plan,dest):return py(runner,plan,dest)
def bound(name,script,args,seconds):
 return command(name,py(bounded,'--seconds',seconds,'--rss-mib',2048,'--available-mib',4096,out/(name+'-supervisor'),'--','taskset','-c',3,node,'--max-old-space-size=1024','--stack-size=4096',script,*args),guard='one outer ExecutionGuard')
stage('checked',[
 command('prepare-checked-plan',py(HERE/'plan.py','--attempt',attempt,'--scope','final','--out',out/'checked','--plan',out/'checked-plan.json')),
 command('execute-checked-plan',run(out/'checked-plan.json',out/'checked-execution'))],
 'Selected mechanism-focused controls pass first. Root reconciles selected source before maintained8. This is the single final checked-B1 matrix.',
 dict(source=96,numeric=34,composition=18,overapplication=2,directCensus=26,maintainedSuites=8,programPoints=45,programSources=23,nativeBytePairs=3))
bootstrap_reuse=None
if a.bootstrap_pins:
 origin=read(a.bootstrap_pins);assert origin['kind']=='phase56-direct-image-pins'
 for key in ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference']:
  assert pin(origin[key]['file'])==origin[key]
 assert origin['producer']==pin(BOOTSTRAP_PRODUCER)
 assert origin['attempt']==pin(attempt/'attempt.json') and origin['b1']==pin(m['api']['file'])
 assert origin['source']==pin(boot['source']) and origin['source']['sha256']==boot['sourceSha256']
 assert origin['runtime']==pin(Path(m['snapshot']['root'])/'src/runtime/js/direct.mjs')
 assert origin['roots']==roots
 old_plan=read(origin['plan']['file']);emission=read(origin['emission']['file']);comparison=read(origin['comparison']['file'])
 assert old_plan['kind']=='phase56-candidate-image-plan' and old_plan['attempt']==origin['attempt']
 assert emission['complete'] and emission['pass'] and comparison['complete'] and comparison['pass'] and comparison['observations']==8
 assert emission['subject']['attempt']==emission['generator']['attempt']==origin['attempt']
 assert emission['subject']['source']==origin['source'] and emission['generator']['api']==origin['b1']
 assert emission['config']==old_plan['configs'][1] and emission['roots']==roots
 assert {k:emission['module'][k]for k in ['file','sha256']}==origin['b2']
 assert pin(emission['qualification']['file'])==emission['qualification'];tiny=read(emission['qualification']['file'])
 assert tiny['complete'] and tiny['pass'] and tiny['splitEqualsUnsplit'] and tiny['subject']==emission['subject']
 for row in old_plan['inputs']+old_plan['configs']+[d['output'] for d in old_plan['derivations']]:assert pin(row['file'])==row
 for role in ['source','direct']:
  assert pin(comparison[role]['file'])==comparison[role];driver=read(comparison[role]['file'])
  assert driver['complete'] and driver['pass'] and len(driver['observations'])==8
  assert driver['emission']==origin['emission'] and driver['subject']==emission['subject']
 bootstrap_reuse=dict(imagePins=pin(a.bootstrap_pins),plan=origin['plan'],emission=origin['emission'],comparison=origin['comparison'],image=origin['b2'],newEmission=False)
 pins=plans/'reused-bootstrap-image-pins.json'
 stage('bootstrap',[
  command('verify-and-rebind-existing-bootstrap',py(BOOTSTRAP_PRODUCER,'pins',origin['plan']['file'],origin['emission']['file'],origin['comparison']['file'],pins))],
  'Reuse the exact selected source/API B2 construction and completed tiny/driver gates. One data-only revalidation writes fresh image pins; no emission or driver target is repeated.',
  dict(exports=len(roots),driverObservations=8,tinyUnsplitEquality=True,generationReused=True,newTargetJobs=0))
else:
 stage('bootstrap',[
  command('prepare-bootstrap-plan',py(BOOTSTRAP_PRODUCER,'plan',attempt,out/'bootstrap')),
  command('execute-bootstrap-plan',run(out/'bootstrap/plan.json',out/'bootstrap-execution'))],
  'Checked final gate admitted; source frozen. Generate this selected own-source B2 once, with actual checked B1 provenance, actual81 checked exports and 8 driver observations.',dict(exports=len(roots),driverObservations=8,tinyUnsplitEquality=True))
 pins=out/'bootstrap/image-pins.json'
stage('b2',[
 bound('self-check',HERE/'self-check.mjs',[pins,out/'self-check'],300),
 bound('fixed-point',bootstrap/'reproduce.mjs',[pins,out/'fixed-point'],300),
 command('prepare-b2-semantics',py(HERE/'b2-plan.py','--image-pins',pins,'--out-base',out/'b2-semantics','--plan-file',out/'b2-semantics-plan.json')),
 command('execute-b2-semantics',run(out/'b2-semantics-plan.json',out/'b2-semantics-execution')),
 bound('b2-program-equality',HERE/'benchmark-equality.mjs',[pins,out/'checked/program45/manifest.json',out/'b2-program-equality'],180)],
 'Real emitted B2 image has passed its driver join. Fresh source type acceptance and expected unsafe trust verdict stay distinct; source-derived definition counts. Raw23 equality transfers only tested program artifacts, not compiler latency.',
 dict(freshTypeCheck=True,mathematicalProof=False,b2EqualsB3=True,source=96,numeric=34,composition=18,overapplication=2,rawProgramSources=23,programPoints=45))
stage('release-prepare',[
 command('prepare-standard-release',py(release,attempt,out/'release','--plan',out/'release-plan.json')),
 command('prepare-root-release-commands',py(Path(__file__).resolve(),'release-commands','--release-plan',out/'release-plan.json','--out',out/'release-commands.json'))],
 'STOP: root first admits final semantics, program performance and compiler cost, and preserves installed7/protected103/closed raw. This stage only prepares installation; it never installs.',dict(legacyCLI=42,defaultCLI=24))
verify();plans.mkdir(parents=True)
for s in stages:
 write(Path(s['plan']),dict(kind='phase58-final-stage-plan',cwd=str(ROOT),executed=False,attempt=pin(attempt/'attempt.json'),stage=s['name'],barrier=s['barrier'],expected=s['expected'],commands=s['commands'],inputs=list(inputs.values())))
 s['planIdentity']=pin(s['plan']);s['rootLaunch']=list(map(str,run(s['plan'],out/(s['name']+'-stage-execution'))));del s['commands']
write(plans/'index.json',dict(kind='phase58-final-orchestration',executed=False,attempt=pin(attempt/'attempt.json'),validation=pin(attempt/'validation-001/report.json'),producer=pin(__file__),out=str(out),bootstrapReuse=bootstrap_reuse,stages=stages,nativeEnvironment=clang,inputs=list(inputs.values()),policy='Root runs stages serially after their explicit barriers. No outer guard/taskset on the parent launcher. Each target command owns its guard, CPU3, 1GiB heap, 2GiB RSS, 4GiB available floor. No runtime timing job is implied; analysis owner prepares the selected45 paired timing method separately. Release commands require separate root execution; no automatic promotion/archive.'))
print(json.dumps(dict(index=pin(plans/'index.json'),stages=len(stages),executed=False)))
