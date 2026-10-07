#!/usr/bin/env python3
"""Derive the bounded Phase60 compiler survey from frozen Phase59 methods."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];TOOLS=HERE.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase60') and not out.exists()
assert (ROOT/'selfhost/build/phase60').is_dir()
def identity(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def literal(f):return repr(str(Path(f).resolve()))
parent=ROOT/'selfhost/build/phase59/latency-method01';stage=ROOT/'selfhost/build/phase59/stage-method01'
clock=TOOLS/'phase60/stages/clock.mjs';deriver=TOOLS/'phase60/stages/derive-driver.py'
assert identity(clock)['sha256']=='d606d5c9ef43e3afbc60d60ca31bbb5972daf1831c63aee5d4e058822c2f2c37'
assert identity(deriver)['sha256']=='997f955151abae64ccc35839167393e361229df1cd2438052f6d603d3a901142'
parents={
 'setup.mjs':(parent/'setup.mjs','5641ba8e71cb64a9c56add28186db4810c6812784bb3987e9b84bd3da46df78a'),
 'profile.mjs':(parent/'profile.mjs','58748e46cc15960e36b0ccd922a167bcb7bbf7f64dd5db09cc82a5237ca1c254'),
 'worker.mjs':(parent/'worker.mjs','5a1bff2254d1aeec69268a38f03542ef49148c54976cad8ede865966a7d5d20e'),
 'worker-stages.mjs':(stage/'worker.mjs','1d02dd8e7e7e967ae0fb1aa733eccd48711cebec565b9a5ba795cdc5b3db8bca'),
 'run.py':(parent/'run.py','6f115dd34ebba3e3ea1984819878d726de933c3e46e28ba989f1d10494da5717'),
}
outputs={};derivations=[]
for name,(file,sha) in parents.items():
 before=identity(file);assert before['sha256']==sha;text=file.read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if name in ['setup.mjs','profile.mjs']:
  edit('phase59','phase60',text.count('phase59'))
 elif name in ['worker.mjs','worker-stages.mjs']:
  edit((parent/'setup.mjs').as_uri(),(out/'setup.mjs').as_uri())
  edit((parent/'profile.mjs').as_uri(),(out/'profile.mjs').as_uri())
  if name=='worker-stages.mjs':
   edit((TOOLS/'phase59/stages/clock.mjs').as_uri(),clock.as_uri(),2)
  edit('phase59','phase60',text.count('phase59'))
  start=text.index('    for(const row of config.cases) {')
  end=text.index('    if(staged) {',start)
  edit(text[start:end],'''    // Compiler/API/runtime/source and raw-output lineage were qualified previously.
    // Do not execute 45 program benchmarks or claim their copied values are fresh.
    report.oracleFreshness='inherited-qualified; fresh measured compilations must match complete raw bytes';
    for(const row of config.cases) {
      const output=row.references[request.role];verify(output);check(row.files);
      assert.equal(row.options.mode,'library');assert.equal(row.options.backend,'direct');
      report.outputs.push({id:row.id,source:row.source,output,
        observation:{freshCompilation:false,freshRuntimeExecution:false},
        oracle:{kind:'inherited-qualified-raw-module',pass:true,freshlyExecuted:false,
          catalog:config.catalog,pointIds:row.pointIds,points:row.oracles}});
    }
''')
 elif name=='run.py':
  edit("HERE=Path('/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase59/latency')",'HERE=Path('+literal(HERE)+')')
  edit(str(parent/'worker.mjs'),str(out/'worker.mjs'))
  edit(str(parent/'bindings.json'),str(out/'bindings.json'))
  edit(str(parent/'profile.mjs'),str(out/'profile.mjs'),2)
  edit(str(parent/'setup.mjs'),str(out/'setup.mjs'))
  edit('phase59','phase60',text.count('phase59'));edit('Phase59','Phase60',text.count('Phase59'))
  edit("p.add_argument('--cases',default='test-evening-program,lexer')", "p.add_argument('--cases',default='all')\np.add_argument('--catalog',type=Path,default=HERE.parent/'catalog.json')\np.add_argument('--driver-receipt',type=Path,help='Required only for stage mode; adjacent private instrumented driver')")
  edit("choices=['clean','cpu','allocation']", "choices=['clean','cpu','allocation','stages']")
  edit("p.add_argument('--seconds',type=int,default=300)", "p.add_argument('--seconds',type=int,default=1800)")
  edit('20<=a.seconds<=3600','20<=a.seconds<=7200')
  edit("upstream=a.upstream.resolve();node=a.node.resolve();catalog=HERE.parents[1]/'phase37/catalog.json'", "upstream=a.upstream.resolve();node=a.node.resolve();catalog=a.catalog.resolve()")
  start=text.index("cat=read(catalog);assert cat['upstreamCommit']==PIN")
  end=text.index('assert identity(',start)
  edit(text[start:end],'''cat=read(catalog);assert cat['kind']=='phase60-compiler-corpus-catalog' and cat['complete'] and cat['pass']
assert cat['upstreamCommit']==PIN and len(cat['compileInputs'])==23 and len(cat['points'])==45
assert len({x['id'] for x in cat['compileInputs']})==23 and len({x['id'] for x in cat['points']})==45
verify(cat['inputs'])
all_cases={x['id']:x for x in cat['compileInputs']}
assert set(x['compileInputId'] for x in cat['points'])==set(all_cases)
if names==['all']:names=list(all_cases)
assert set(names)<=set(all_cases)
cases=[all_cases[name] for name in names]
for case in cases:
 assert case['options']=={'mode':'library','backend':'direct'} and case['roots']=='ordinary-library-exports'
 assert set(case['references'])=={'direct','typescript'} and case['pointIds']
 assert set(case['pointIds'])=={x['id'] for x in cat['points'] if x['compileInputId']==case['id']}
 verify([case['source'],*case['files'],*case['emissionInputs'],*case['references'].values()])
''')
  edit('58748e46cc15960e36b0ccd922a167bcb7bbf7f64dd5db09cc82a5237ca1c254',hashlib.sha256(outputs['profile.mjs'].encode()).hexdigest())
  edit("]]+[x['source'] for x in cases]", "]]+[x['source'] for x in cases]+[i for x in cases for i in [*x['files'],*x['emissionInputs'],*x['references'].values()]]")
  edit('reuse=None\n', '''stage_driver=None
if a.mode=='stages':
 assert a.preparations and a.driver_receipt and not a.prepare_only
 stage_driver=read(a.driver_receipt)
 assert stage_driver['kind']=='phase60-private-driver-stage-derivation' and stage_driver['complete'] and stage_driver['pass'] and stage_driver['exactInverse']
 assert stage_driver['producer']['sha256']=='''+repr(identity(deriver)['sha256'])+''' and stage_driver['clock']['sha256']=='''+repr(identity(clock)['sha256'])+'''
 assert Path(stage_driver['output']['file']).resolve().is_relative_to(ROOT/'selfhost/build/phase60')
 inputs += [identity(a.driver_receipt),stage_driver['source'],stage_driver['output'],stage_driver['producer'],stage_driver['clock'],identity(Path('''+literal(out/'worker-stages.mjs')+'''))]
reuse=None
''')
  edit("reuse['complete'] and reuse['pass']", "reuse['complete']")
  edit(" prepareOnly=a.prepare_only,", " prepareOnly=a.prepare_only,catalog=identity(catalog),stageDriver=identity(a.driver_receipt) if stage_driver else None,")
  edit(" preparations=[],rows=[],statistics={},inputs=inputs)", " preparations=[],rows=[],statistics={},failures=[],inputs=inputs,\n coverage=dict(compileInputIds=names,pointIds=[p['id'] for p in cat['points'] if p['compileInputId'] in names],oracleFreshness='inherited-qualified',freshRuntimeExecutions=0))")
  edit("  str(WORKER),str(request_file),str(result_file)]", "  str(Path("+literal(out/'worker-stages.mjs')+") if a.mode=='stages' and request['stage']=='sample' else WORKER),str(request_file),str(result_file)]")
  edit(" observation=read(result_file) if result_file.exists() else None\n entry=dict(execution=execution,observation=observation,result=identity(result_file) if result_file.exists() else None)", ''' observation=None;observation_error=None
 if result_file.exists():
  try:observation=read(result_file)
  except Exception as error:observation_error=repr(error)
 success=bool(execution['complete'] and execution.get('returncode')==0 and observation and observation.get('complete') and observation.get('pass'))
 entry=dict(execution=execution,observation=observation,result=identity(result_file) if result_file.exists() else None,success=success,request=request,observationError=observation_error)
 if not success:report['failures'].append(dict(stage=request['stage'],role=request['role'],case=request.get('case'),sample=request.get('sample'),process=str(prefix)+'-process',reason=execution.get('stoppedFor') or observation_error or (observation or {}).get('error') or 'worker failure'))''')
  edit(" assert execution['complete'] and execution.get('returncode')==0 and observation and observation['complete'] and observation['pass'],entry\n assert observation['affinity'].split(':',1)[1].strip()=='3'", " if success:assert observation['affinity'].split(':',1)[1].strip()=='3'")
  edit("    row=next(x for x in reuse['preparations'] if x['observation']['role']==role)\n    verify([row['result']]);assert row['observation']==read(row['result']['file'])", "    row=next(x for x in reuse['preparations'] if (x.get('observation') or {}).get('role',x.get('request',{}).get('role'))==role)\n    if row.get('result'):verify([row['result']]);assert row['observation']==read(row['result']['file'])\n    if not row['success']:report['failures'].append(dict(stage='prepare',role=role,reason='retained preparation failed'))")
  start=text.index("  report['exactBendOutputComparisons']=[]")
  end=text.index("  report['preparationSeconds']",start)
  edit(text[start:end],'''  report['qualifiedRawOutputReferences']=[dict(case=case['id'],pointIds=case['pointIds'],references=case['references']) for case in cases]
''')
  old="""     row=launch(guard,dict(stage='sample',role=role,case=case['id'],sample=sample,
      preparation=preparations[role]['result'],output=str(prefix)+'.mjs',profileOut=str(prefix)+'-profile'),prefix)
     row.update(case=case['id'],sample=sample,role=role);save(out/'report.json',report)"""
  new="""     reason=('preparation-failed' if not preparations[role]['success'] else
       'signal' if guard.interrupted else 'campaign-deadline' if time.monotonic()>=started+a.seconds else None)
     if reason:
      row=dict(success=False,skipped=True,reason=reason,execution=None,observation=None,result=None)
      report['rows'].append(row);report['failures'].append(dict(stage='sample',role=role,case=case['id'],sample=sample,reason=reason))
     else:
      row=launch(guard,dict(stage='sample',role=role,case=case['id'],sample=sample,
       preparation=preparations[role]['result'],output=str(prefix)+'.mjs',profileOut=str(prefix)+'-profile'),prefix)
     row.update(case=case['id'],sample=sample,role=role);save(out/'report.json',report)"""
  edit(old,new)
  edit("     rows=[x for x in report['rows'] if x['case']==case['id'] and x['role']==role];assert len(rows)==a.rounds", "     rows=[x for x in report['rows'] if x['case']==case['id'] and x['role']==role and x['success']]\n     if len(rows)!=a.rounds:\n      report['statistics'][case['id']][role]=dict(complete=False,expectedSamples=a.rounds,successfulSamples=len(rows));continue")
  edit("  verify(inputs);report['complete']=report['pass']=True", "  verify(inputs);verify(cat['inputs']);report['complete']=True;report['pass']=not report['failures']\n  report['successfulWorkers']=sum(x['success'] for x in report['rows']);report['expectedWorkers']=0 if a.prepare_only else len(cases)*len(roles)*a.rounds")
  edit("print(json.dumps(dict(pass_=True,rows=len(report['rows']),mode=a.mode,report=str(out/'report.json'))))", "print(json.dumps(dict(pass_=report['pass'],rows=len(report['rows']),failed=len(report['failures']),mode=a.mode,report=str(out/'report.json'))))\nif not report['pass']:raise SystemExit(1)")
  ast.parse(text)
 outputs[name]=text;derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
bindings=json.loads((parent/'bindings.json').read_text());assert bindings['kind']=='phase59-compiler-image-bindings';bindings['kind']='phase60-compiler-image-bindings'
bindings['scope']='Unchanged selected genuine Phase58 B2 versus pinned TypeScript; broad source compilation only.'
for f,sha in parents.values():assert identity(f)['sha256']==sha
result=dict(kind='phase60-survey-method-derivation',complete=True,dataOnly=True,targetExecuted=False,producer=identity(__file__),
 bindingsParent=identity(parent/'bindings.json'),clock=identity(clock),driverDeriver=identity(deriver),derivations=derivations,
 scope='Unchanged first/later compile clocks and first-window profiles. All45 inherited runtime oracles mapped to23 raw compile inputs; no program benchmark execution. Each attempted worker is retained; failures/skips prevent campaign PASS and incomplete roles have no medians.')
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
(out/'bindings.json').write_text(json.dumps(bindings,indent=2)+'\n');(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({n:identity(out/n) for n in [*outputs,'bindings.json','derivation.json']}))
