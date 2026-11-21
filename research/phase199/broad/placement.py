#!/usr/bin/env python3
"""Three fixed incumbent objects, same live runtime with/without scan leaf."""
import argparse,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
P=module('integrated_prepare',HERE/'integrated-prepare.py');B=P.B
A=module('analyze',ROOT/'selfhost/tests/phase186/analyze-runtime.py')
CASES=['mandelbrot','lexer','coverage-map-churn-128']
def execute(out):
 assert os.sched_getaffinity(0)=={3} and 'BENDRTS' not in os.environ
 out=out.resolve();out.mkdir(parents=True,exist_ok=False)
 config=B.read(HERE/'integrated-pins.json');B.verify(config['bundle']);B.verify(config['live'])
 prior=P.read_manifest(P.BASE/'manifest.json');proof=B.read(P.BASE/'report.json');assert proof['complete'] and proof['manifest']==B.pin(P.BASE/'manifest.json')
 rows={c['id']:c for c in prior['cases']};inputs=[B.pin(__file__),B.pin(HERE/'integrated-pins.json'),B.pin(P.BASE/'manifest.json'),B.pin(P.BASE/'report.json'),config['bundle'],config['live']]
 role=prior['roles']['live'];assert role['compilerSource']['sha256']=='72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d'
 recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'),reference='baseline',roles=dict(baseline=role,augmented=dict(role,runtime=config['live'],inputs=[*role['inputs'],*inputs])),cases=[])
 report=dict(complete=False,kind='phase199-incumbent-placement-control',inputs=inputs,selected=CASES,cases={},scope='Three fixed unmodified incumbent objects and same live runtime, with only the appended scan leaf; separate placement control, not a correction applied to main campaign ratios.')
 B.save(out/'preparation.json',report)
 for name in CASES:
  case=rows[name];old=case['products']['live'];retained=proof['cases'][name];B.verify(retained['production']);built=B.read(retained['production']['file']);obj=built['object']
  assert old['artifact']==retained['live'] and old['generatedSource']==obj==retained['object'];B.verify(obj)
  link=[j['command'] for j in built['jobs'] if j['label']=='link'];assert len(link)==1;cmd=link[0].copy()
  for value in (built['runtime']['file'],built['binary']['file'],obj['file']):assert cmd.count(value)==1
  folder=out/name;folder.mkdir();exe=folder/'augmented';cmd[cmd.index(built['runtime']['file'])]=config['live']['file'];cmd[cmd.index(built['binary']['file'])]=str(exe)
  subprocess.run(cmd,check=True,capture_output=True,timeout=15)
  new=dict(old,artifact=B.pin(exe));oracles={}
  for alias,product in [('baseline',old),('augmented',new)]:
   point=dict(case['point'],repetitions=1,warmups=0);argv=[product['artifact']['file'],*B.native_runtime_arguments(product),'1','0',*map(str,point['runtimeArgs'])]
   child=B.child(argv,folder/('oracle-'+alias),time.monotonic()+10,str(ROOT));assert not child['timedOut']
   elapsed=B.observation(B.verify(child['stdout']).read_bytes(),B.verify(child['stderr']).read_bytes(),child['exitCode'],point,child['seconds']);oracles[alias]=dict(process=child,elapsedMs=elapsed)
  report['cases'][name]=dict(object=obj,production=retained['production'],baseline=old['artifact'],augmented=new['artifact'],allocatedLayoutIdentical=P.L.loaded_layout(exe)==P.L.loaded_layout(old['artifact']['file']),oracles=oracles)
  recipe['cases'].append(dict(id=name,products=dict(baseline=old,augmented=new)))
 B.save(out/'recipe.json',recipe);B.freeze(out/'recipe.json',out/'manifest.json');report.update(complete=True,manifest=B.pin(out/'manifest.json'));B.save(out/'preparation.json',report)
 cmd=[sys.executable,'-B',str(HERE/'runtime.py'),'run','--manifest',str(out/'manifest.json'),'--out',str(out/'timing'),'--rounds','4','--target-ms','140','--seconds','20','--cpu','3','--guarded']
 subprocess.run(cmd,check=True)
 result=A.analyze(out/'timing/report.json');assert result['positionBalanced'] and result['oracleRevalidated']['samples']==24
 for case in result['cases']:
  assert case['artifacts']['baseline']==report['cases'][case['id']]['baseline'] and case['artifacts']['augmented']==report['cases'][case['id']]['augmented']
  for sample in B.read(out/'timing/report.json')['cases']:
   for row in sample['samples']:assert row['elapsedMs']>=100
 result.update(preparation=B.pin(out/'preparation.json'),scope=report['scope'],comparison=A.compare(result,result,'baseline','augmented',False));B.save(out/'summary.json',result);print(json.dumps(result['comparison']))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();execute(a.out)
