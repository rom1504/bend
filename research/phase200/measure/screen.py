#!/usr/bin/env python3
"""Bounded same-object runtime relink screen with existing native45 oracles."""
import argparse,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B

def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
R=module('p199_runtime',ROOT/'research/phase199/broad/runtime.py')
S=module('p193_summary',ROOT/'selfhost/tests/phase193/summarize.py')
S.S.PARTITION=ROOT/'research/phase198/runtime-broad/partition.json'
BASE=ROOT/'selfhost/build/phase198/p199-integrated-live-plan02'

def verify(pin):
 actual=B.pin(pin['file']);assert all(actual[k]==pin[k] for k in ('bytes','sha256')),pin['file'];return actual

def checked_bytes(pin):
 B.verify(pin);return Path(pin['file']).read_bytes()

def nested_pins(value):
 if isinstance(value,dict):
  if all(k in value for k in ('file','bytes','sha256')):yield value
  for item in value.values():yield from nested_pins(item)
 elif isinstance(value,list):
  for item in value:yield from nested_pins(item)

def manifest(path):
 doc=R.load(path);assert len({c['id'] for c in doc['cases']})==len(doc['cases']);return doc

def execute(plan_path,out):
 assert os.sched_getaffinity(0)=={3} and 'BENDRTS' not in os.environ
 plan=B.read(plan_path);assert plan['kind']=='phase200-frozen-runtime-screen' and plan['rounds']==3 and plan['targetMs']==140 and plan['minimumAcceptedMs']==100
 for pin in plan['inputs']:B.verify(pin)
 assert plan['baseline']==B.pin(BASE/'manifest.json') and plan['baselinePreparation']==B.pin(BASE/'report.json')
 base=manifest(plan['baseline']['file']);proof=B.read(plan['baselinePreparation']['file']);assert proof['complete'] and proof['manifest']==plan['baseline']
 assert base['roles']['candidate']['compilerSource']['sha256']=='a48b1532ec45ac23cb972796f0101a8bf1864ed8769c6a2daee114ee268ce313'
 runtime=plan['runtime'];receipt=B.read(plan['runtimeReceipt']['file']);assert receipt['complete'] and not receipt.get('changedInputs')
 assert receipt.get('runtimeABI',11102)==11102
 assert any(verify(p)==runtime for p in nested_pins(receipt)), 'Runtime object must occur in its receipt'
 for pin in receipt.get('inputs',[]):verify(pin)
 source=manifest(plan['nativeManifest']['file']);role=source['roles'][plan['nativeRole']]
 assert role['host']=='native' and role['target']=='x86' and role['emit']=='object'
 rows={c['id']:c for c in source['cases']};baseline={c['id']:c for c in base['cases']};names=plan['cases']
 assert len(names)==len(set(names)) and all(n in rows and n in baseline for n in names)
 out=out.resolve();out.mkdir(parents=True,exist_ok=False)
 inputs=B.unique_inputs([B.pin(plan_path),*plan['inputs']])
 candidate_role=dict(role,runtime=runtime,inputs=[*role['inputs'],*inputs],status='phase200-explicit-runtime-relink')
 recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(R.CATALOG),reference='c',roles=dict(c=base['roles']['c'],baseline=base['roles']['candidate'],candidate=candidate_role),cases=[])
 report=dict(kind='phase200-runtime-relink-preparation',complete=False,plan=B.pin(plan_path),inputs=inputs,cases={},scope='Fresh candidate links from authenticated native program objects; incumbent and C ELFs reused unchanged, all outputs freshly checked. Runtime/source difference is explicit; no installed release claim.')
 B.save(out/'preparation.json',report)
 for name in names:
  case,old=rows[name],baseline[name];assert all(case[k]==old[k] for k in ('point','source','expectedFile'))
  original=case['products'][plan['nativeRole']];production=B.pin(Path(original['artifact']['file']).with_name('report.json'));assert production in original['inputs']
  built=B.read(production['file']);obj=built['object']
  assert built['complete'] and not built.get('changedInputs') and built['assemblerSkipped'] and built['emit']=='object' and built['host']=='native' and built['target']=='x86' and built['stage']==role['stage']
  assert built['binary']==original['artifact'] and obj==original['generatedSource'] and built['request']['source']==case['source']
  assert built['request']['image']==role['compiler'] and built['request']['imageMetadata']['sourceIdentity']==role['compilerSource']
  for pin in (obj,original['artifact'],old['products']['candidate']['artifact'],case['source'],case['expectedFile']):B.verify(pin)
  previous=proof['cases'][name];assert old['products']['candidate']['artifact']==previous['live'] and old['products']['candidate']['generatedSource']==previous['object']
  if not plan['sourceChanged']:assert obj==previous['object']
  jobs=[j for j in built['jobs'] if j['label']=='link'];assert len(jobs)==1 and jobs[0]['exitCode']==0 and not jobs[0].get('timedOut')
  cmd=jobs[0]['command'].copy()
  for value in (built['runtime']['file'],built['binary']['file'],obj['file']):assert cmd.count(value)==1
  folder=out/'programs'/name;folder.mkdir(parents=True);exe=folder/'candidate'
  cmd[cmd.index(built['runtime']['file'])]=runtime['file'];cmd[cmd.index(built['binary']['file'])]=str(exe)
  subprocess.run(cmd,check=True,capture_output=True,timeout=20)
  candidate=dict(original,artifact=B.pin(exe));arms=dict(c=old['products']['c'],baseline=old['products']['candidate'],candidate=candidate);oracles={}
  for alias,product in arms.items():
   point=dict(case['point'],repetitions=int(case['point']['repetitions']>0),warmups=0)
   argv=[product['artifact']['file'],*B.native_runtime_arguments(product),str(point['repetitions']),'0',*map(str,point['runtimeArgs'])]
   proc=B.child(argv,folder/('oracle-'+alias),time.monotonic()+20,str(ROOT));assert not proc['timedOut']
   elapsed=B.observation(checked_bytes(proc['stdout']),checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds']);oracles[alias]=dict(process=proc,elapsedMs=elapsed)
  for alias,check in oracles.items():
   arms[alias]=dict(arms[alias],inputs=B.unique_inputs([*arms[alias]['inputs'],check['process']['stdout'],check['process']['stderr']]))
  report['cases'][name]=dict(object=obj,production=production,artifact=candidate['artifact'],oracles=oracles,linkCommand=cmd)
  recipe['cases'].append(dict(id=name,products=arms));B.save(out/'preparation.json',report)
 B.save(out/'recipe.json',recipe);B.freeze(out/'recipe.json',out/'manifest.json');report.update(complete=True,manifest=B.pin(out/'manifest.json'));B.save(out/'preparation.json',report)
 result=R.run(SimpleNamespace(manifest=out/'manifest.json',out=out/'timing',cases=None,rounds=3,target_ms=140,cpu=3,seconds=plan['timingSeconds'],guarded=True));assert result['complete']
 summary=S.S.summarize(SimpleNamespace(report=out/'timing/report.json',references=out/'manifest.json',c_role='c',baseline_role='baseline',spread_limit=1.10,emission=[]))
 assert summary['positionBalanced'] and summary['oracleRevalidated']['samples']==9*len(names) and summary['subsets']['all']['caseCount']==len(names)
 frozen={c['id']:c for c in B.read(out/'manifest.json')['cases']}
 for case in summary['cases']:
  fixed=frozen[case['id']]
  for alias,check in report['cases'][case['id']]['oracles'].items():
   proc=check['process'];point=dict(fixed['point'],repetitions=int(fixed['point']['repetitions']>0),warmups=0)
   expected=[fixed['products'][alias]['artifact']['file'],*B.native_runtime_arguments(fixed['products'][alias]),str(point['repetitions']),'0',*map(str,point['runtimeArgs'])]
   assert proc['command']==expected and not proc['timedOut']
   elapsed=B.observation(checked_bytes(proc['stdout']),checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds']);assert elapsed==check['elapsedMs']
  assert all(case['artifacts'][alias]==frozen[case['id']]['products'][alias]['artifact'] for alias in summary['roles'])
 summary.update(kind='phase200-authenticated-runtime-screen',complete=True,method=B.pin(__file__),plan=B.pin(plan_path),preparation=B.pin(out/'preparation.json'),runtime=runtime,sourceChanged=plan['sourceChanged'])
 summary['scope']+=' Same fixed selected cases and original workload/weights; all three roles freshly timed, with explicit runtime and source provenance.'
 for pin in inputs:B.verify(pin)
 B.save(out/'summary.json',summary);(out/'summary.md').write_text(S.markdown(summary).replace('# Phase193 runtime summary','# Phase200 runtime screen',1));print(json.dumps(dict(summary=str(out/'summary.json'),candidate=summary['subsets']['all']['roles']['candidate'],warnings=summary['warnings'])))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();execute(a.plan,a.out)
