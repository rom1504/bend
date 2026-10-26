#!/usr/bin/env python3
"""Prepare/seal a small exact-output gate for the versioned generic profiler."""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def unique(items):return list({(p['file'],p['sha256']):p for p in items}.values())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','seal','finish']);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 gate directory required')
 base=ROOT/'selfhost/build/phase144/generic-stages01';plan_path=base/'runtime03/plan.json';spec_path=base/'spec.json';old_path=ROOT/'selfhost/build/phase144/stages02/manifest.json';small_path=ROOT/'selfhost/build/phase130/p143-milestone-lexer02/report.json'
 plan,spec,old,small=map(read,[plan_path,spec_path,old_path,small_path])
 for p in plan['inputs']+plan['outputs']:verify(p)
 need(plan['stageSpec']==pin(spec_path) and plan['complete'] and plan['reverseExact'] and len(plan['jobs'])==3,'Wrong prepared generic build plan')
 need(spec['programObject']==old['lineage']['programObject'] and spec['ownerMap']==old['ownerMap'],'Retained compiler object/owner map differs')
 pilot=copy.deepcopy(next(w for w in old['workloads'] if w['name']=='lexer-stage-pilot'));need(len(pilot['variants'])==1,'One pilot variant required')
 v=pilot['variants'][0];need(small['complete'] and v['command'][1:]==small['command'][1:],'Pilot argv changed')
 need(all(v['expected']['stdout'][k]==small['expectedQbe'][k] for k in ['bytes','sha256']),'Pilot independent oracle differs')
 old_variant=copy.deepcopy(v);v['name']='phase143-n2-generic-stages-v1'
 if a.action=='prepare':
  need(not out.exists(),'Fresh gate output required');out.mkdir(parents=True)
  template=copy.deepcopy(old);template['workloads']=[pilot];template.pop('cleanComparison',None);template.pop('stagePlan',None)
  template['lineage']['requestSource']=small['source'];template['lineage']['expectedOutput']=small['expectedQbe'];template['lineage']['oracleEmission']=pin(small_path)
  template['nativeStageSpec']=pin(spec_path);template['scope']='One small sampled generic-profiler qualification gate. Exact old command suffix/output oracle and immutable compiler object; no clean timing or compiler-promotion claim.'
  template['inputs']=unique([*template['inputs'],pin(__file__),pin(spec_path),pin(plan_path),pin(old_path),pin(small_path),*plan['inputs'],*plan['outputs'],pin(PROF/'stages_v1.py'),pin(PROF/'test_stages_v1.py')])
  save(out/'template.json',template)
 elif a.action=='seal':
  need(out.exists() and not(out/'manifest.json').exists(),'Unsealed gate required')
  built=read(out/'build/report.json');need(built['complete'] and built['plan']==pin(plan_path) and len(built['jobs'])==3,'Actual generic profiler build incomplete')
  for want,have in zip(plan['jobs'],built['jobs']):
   need(want['command']==have['command'] and have['returncode']==0 and not have['timedOut'],'Build command/status differs');verify(have['product'])
   need(have['product'] in built['products'],'Build product absent from receipt')
  need(built['jobs'][-1]['command'][2]==spec['programObject']['file'],'Wrong retained object linked')
  manifest=read(out/'template.json');variant=manifest['workloads'][0]['variants'][0];need(variant['command']==old_variant['command'] and variant['expected']==old_variant['expected'],'Prepared pilot changed')
  manifest['sampler']=built['jobs'][0]['product'];manifest['diagnosticImage']=built['jobs'][-1]['product'];manifest['lineage']['diagnosticRuntime']=built['jobs'][1]['product']
  variant['binary']=built['jobs'][-1]['product'];variant['command'][0]=variant['binary']['file'];variant['inputs']=[pin(p) for p in variant['command'] if Path(p).is_file()]
  manifest['inputs']=unique([*manifest['inputs'],pin(out/'build/report.json'),*built['products']])
  for p in all_pins(manifest):verify(p)
  save(out/'manifest.json',manifest)
 else:
  need(not(out/'qualification.json').exists(),'Fresh small qualification receipt required')
  manifest=read(out/'manifest.json');capture=read(out/'capture/report.json');observed=read(out/'stages.json');built=read(out/'build/report.json')
  need(capture['complete'] and capture['passed'] and not capture['changedInputs'] and len(capture['rows'])==1,'Exact small capture failed')
  row=capture['rows'][0];need(row['correct'] and row['command']==manifest['workloads'][0]['variants'][0]['command'],'Capture command/oracle mismatch')
  need(observed['complete'] and observed['requestExact'] and observed['stageAttributionValid'] and not observed['sidecar']['legacyFormat'],'Native generic sidecar gate failed')
  need(observed['sidecar']['run']==pin(out/'capture/report.json') and observed['sidecar']['row']==0 and observed['sidecar']['profile']==row['profile'],'Sidecar capture binding differs')
  need(pin(spec_path) in observed['inputs'] and observed['outputContract']['manifest']==pin(out/'manifest.json'),'Observer spec/manifest differs')
  verify(observed['sidecar']['identity'])
  save(out/'qualification.json',dict(schema='bend-native-generic-stage-small-gate-v1',complete=True,genericRuntimeCompiled=True,genericRuntimeExecuted=True,targetsRunByBinder=False,compilerQualifiedByThisGate=False,installed=False,inputs=[pin(__file__),pin(spec_path),pin(plan_path),pin(out/'build/report.json'),pin(out/'manifest.json'),pin(out/'capture/report.json'),pin(out/'stages.json'),observed['sidecar']['identity']],programObject=spec['programObject'],sampler=built['jobs'][0]['product'],runtime=built['jobs'][1]['product'],binary=built['jobs'][-1]['product'],output=row['stdout'],samples=observed['samples'],scope='One sequential actual native Lexer request with complete independent QBE oracle and generic-v1 stage sidecar. Not new compiler qualification, general workload coverage or an overhead-neutral timing. Synthetic tests are a separate recorded root command.'))
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(label,seconds,cmd):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','64','--cpu','3','--',*cmd]
 jobs=[dict(name='build-versioned-generic-runtime-and-sampler',command=guarded('build',60,[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(plan_path),'--out',str(out/'build')])),dict(name='bind-actual-built-products',command=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--out',str(out)]),dict(name='sample-one-independent-lexer',command=guarded('capture',55,[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--names','lexer-stage-pilot','--modes','sample','--rounds','1','--periods-us','8000'])),dict(name='observe-versioned-sidecar-offline',command=[sys.executable,'-B',str(PROF/'stages_v1.py'),'observe','--spec',str(spec_path),'--run',str(out/'capture/report.json'),'--out',str(out/'stages.json')]),dict(name='root-synthetic-tests',command=[sys.executable,'-B','-m','unittest','discover','-s',str(PROF),'-p','test_stages_v1.py']),dict(name='bind-completed-small-gate',command=[sys.executable,'-B',str(Path(__file__).resolve()),'finish','--out',str(out)])]
 if a.action=='prepare':save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(plan_path),pin(spec_path),pin(PROF/'run.py'),pin(PROF/'stages_v1.py'),pin(PROF/'test_stages_v1.py')],jobs=jobs,scope='Root executes serially on CPU3. Stop at any failed exact-output or stage gate; no full compiler request needed.'))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
