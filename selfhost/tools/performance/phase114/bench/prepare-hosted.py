#!/usr/bin/env python3
"""Prepare authenticated Phase114 subset jobs; never execute compiler targets.

Derived from the frozen Phase113 hosted45-v2 planner. The original broad45
binder/measurement implementation and its source/profile definitions are reused.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
PRIOR=ROOT/'selfhost/tools/performance/phase113/bench'
BROAD=ROOT/'selfhost/tools/performance/phase112/benchmark45'
def module(name,p):
 spec=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
legacy=module('phase114_legacy_hosted45',PRIOR/'hosted45-v2.py')
m=legacy.m
transport=module('phase114_transport',PRIOR/'transport-v2.py')

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--api',type=Path,default=ROOT/'selfhost/build/phase111/p114-take-api01/api.mjs')
 p.add_argument('--runtime',type=Path,default=ROOT/'selfhost/build/phase113/runtime-products-build01/runtime.o')
 p.add_argument('--pipeline',choices=['direct','array'],default='array')
 p.add_argument('--names',nargs='+',help='Explicit subset of frozen eight; omitted means all eight')
 p.add_argument('--tag',required=True,help='Fresh p114- prefix for Phase111 products')
 p.add_argument('--label',help='New binding label; defaults to tag')
 p.add_argument('--reuse-reports',type=Path,help='Already complete subset from identical API/runtime/transport')
 p.add_argument('--observe-one-shot',action='store_true',help='Additionally build/observe frozen source88 companions; timed batches are checked by normal benchmark measure')
 p.add_argument('--out',type=Path,required=True)
 a=p.parse_args()
 if not re.fullmatch(r'p114-[A-Za-z0-9_-]+',a.tag):raise ValueError('Descriptive p114- tag required')
 label=a.label or a.tag
 if not re.fullmatch(r'[a-z][a-z0-9_-]*',label) or label in ['upstream','phase111','facts-n2']:raise ValueError('New lower-case candidate label required')
 out=a.out.resolve();mapping=out.with_name(out.stem+'-reports.json')
 binding=out.with_name(out.stem+'-binding.json');measure=out.with_name(out.stem+'-measure')
 if any(f.exists() for f in [out,mapping,binding,measure]):raise ValueError('Fresh plan/map/binding/measurement paths required')
 frozen=m.read(HERE/'manifest01.json');namesfile=HERE/'names01.txt'
 if frozen['names']!=namesfile.read_text().split() or len(frozen['names'])!=8:raise ValueError('Frozen eight names disagree')
 for key in ['sourceManifest','profile','baselineBinding']:m.verify(frozen[key])
 broad=m.read(frozen['sourceManifest']['file']);cases={c['name']:c for c in broad['cases']}
 if len(cases)!=45:raise ValueError('Original broad45 source manifest required')
 if frozen['cases']!=[cases[n] for n in frozen['names']]:raise ValueError('Phase114 cases differ from original frozen corpus')
 names=a.names or frozen['names']
 if not names or len(names)!=len(set(names)) or set(names)-set(frozen['names']):raise ValueError('Known nonempty unique Phase114 subset required')
 api=a.api.resolve();api=api/'api.mjs' if api.is_dir() else api
 runtime=a.runtime.resolve();runtime=runtime/'runtime.o' if runtime.is_dir() else runtime
 checkedpath=api.parent/'report.json';checked=m.read(checkedpath)
 contract=transport.select_exports(checked,a.pipeline)
 if not checked.get('complete') or not checked.get('checked') or 'p111_compile_source' not in checked.get('exports',[]) or m.verify(checked['api'])!=api:raise ValueError('Checked staged API plus unchanged binder compatibility export required')
 emitter=ROOT/'selfhost/tools/performance/phase113/staged-emit-v2.mjs'
 builder=ROOT/'selfhost/tools/performance/phase111/build.py';observer=ROOT/'selfhost/tools/performance/phase112/observe.py'
 api_pin=m.pin(api);runtime_pin=m.pin(runtime);emitter_pin=m.pin(emitter)
 inputs=[m.pin(__file__),m.pin(HERE/'manifest01.json'),m.pin(namesfile),m.pin(PRIOR/'hosted45-v2.py'),m.pin(PRIOR/'transport-v2.py'),
  frozen['sourceManifest'],frozen['profile'],frozen['baselineBinding'],m.pin(BROAD/'run.py'),m.pin(checkedpath),api_pin,runtime_pin,emitter_pin,
  m.pin(builder),m.pin(observer),m.pin(ROOT/'selfhost/tools/performance/phase112/run-jobs.py'),broad['base'],broad['carrier'],*checked['inputs']]
 reports=m.read(a.reuse_reports) if a.reuse_reports else {};reused=list(reports)
 if set(reports)-set(names):raise ValueError('Reused map contains a case outside the explicit requested subset')
 if reports:
  verified=legacy.authenticate(reports,broad,api_pin,runtime_pin,emitter_pin,label,a.pipeline,contract)
  inputs.append(m.pin(a.reuse_reports))
  for product in verified['products'].values():inputs.extend(product[k] for k in ['binary','emission','build','qbe','runtime','api','apiReport','compilerSource'])
 jobs=[];ordinary=[]
 for name in names:
  case=cases[name];inputs.extend([case['source'],case['expectedStdoutEvidence']])
  if name not in reports:
   emit=ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-emit');build=ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-build')
   if emit.exists() or build.exists():raise ValueError('Product path already exists: '+name)
   jobs.extend([
    dict(name=name+'-emit',seconds=60,command=[checked['command'][0],str(emitter),str(api),case['source']['file'],str(emit),'cache',a.pipeline]),
    dict(name=name+'-build',seconds=45,command=[sys.executable,'-B',str(builder),'--source',str(emit/'program.ssa'),'--runtime',str(runtime),'--out',str(build),'--seconds','12'])])
   reports[name]=dict(emission=str(emit/'report.json'),build=str(build/'report.json'))
  if a.observe_one_shot:
   source=case['source88'];inputs.append(source)
   emit=ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-ordinary-emit');build=ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-ordinary-build');obs=ROOT/'selfhost/build/phase114'/(a.tag+'-'+name+'-ordinary-observe')
   expected=out.with_name(out.stem+'-'+name+'-ordinary-expected.json')
   if any(f.exists() for f in [emit,build,obs,expected]):raise ValueError('Ordinary output already exists: '+name)
   expected.parent.mkdir(parents=True,exist_ok=True);m.save(expected,dict(status=0,stdout=case['expectedStdout'],stderr=''));inputs.append(m.pin(expected))
   jobs.extend([
    dict(name=name+'-ordinary-emit',seconds=60,command=[checked['command'][0],str(emitter),str(api),source['file'],str(emit),'cache',a.pipeline]),
    dict(name=name+'-ordinary-build',seconds=45,command=[sys.executable,'-B',str(builder),'--source',str(emit/'program.ssa'),'--runtime',str(runtime),'--out',str(build),'--seconds','12']),
    dict(name=name+'-ordinary-observe',seconds=15,command=[sys.executable,'-B',str(observer),'--binary',str(build/'program'),'--expected',str(expected),'--out',str(obs)])])
   ordinary.append(dict(name=name,source=source,expected=m.pin(expected),emission=str(emit/'report.json'),build=str(build/'report.json'),observation=str(obs/'report.json')))
 inputs=list({i['file']:i for i in inputs}.values())
 for i in inputs:m.verify(i)
 out.parent.mkdir(parents=True,exist_ok=True);m.save(mapping,reports)
 binder=[sys.executable,'-B',str(BROAD/'run.py'),'bind','--label',label,'--reports',str(mapping),'--out',str(binding),'--names',*names]
 measured=[sys.executable,'-B',str(BROAD/'run.py'),'measure','--bindings',frozen['baselineBinding']['file'],str(binding),'--profile',frozen['profile']['file'],'--names',*names,'--rounds','3','--seconds','30','--budget-seconds','300','--out',str(measure)]
 m.save(out,dict(kind='phase114-hosted-subset-plan',version=1,targetsRun=False,derivedFrom=m.pin(PRIOR/'hosted45-v2.py'),inputs=inputs,
  manifest=m.pin(HERE/'manifest01.json'),originalManifest=frozen['sourceManifest'],profile=frozen['profile'],baselineBinding=frozen['baselineBinding'],
  api=api_pin,runtime=runtime_pin,emitter=emitter_pin,pipeline=a.pipeline,transportVersion=2,transportContract=contract,requiredExports=contract['requiredExports'],
  reportsMap=m.pin(mapping),requestedNames=names,reusedNames=reused,frozenNames=frozen['names'],jobs=jobs,ordinaryControls=ordinary,bindCommand=binder,measureCommand=measured,
  scope='Unchanged frozen Phase114 subset of original45. Source algorithms and repetitions/outputs/profile unchanged. Normal benchmark measure validates complete output, warmups and success counts; Phase112 observe is optional for separate source88 one-shot companions. Planning does not qualify products or execute targets.'))
 print(json.dumps(dict(plan=str(out),reports=str(mapping),cases=len(names),jobs=len(jobs),targetsRun=False,bindCommand=binder,measureCommand=measured)))
if __name__=='__main__':main()
