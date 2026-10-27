#!/usr/bin/env python3
"""Root-only engine-warm hosted diagnostic, independent of cold ratios."""
import argparse,importlib.util,json,statistics,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('p145r',HERE/'run-v01.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
def main():
 p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--case',default='lexer');a=p.parse_args();out=a.out.resolve();R.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh Phase145 output');plan=json.loads(a.plan.read_text());R.require(plan['complete'],'Incomplete plan');cases=[c for c in plan['cases'] if c['name']==a.case];R.require(len(cases)==1,'Unique case');case=cases[0]
 inputs=[R.pin(a.plan),R.pin(__file__),R.pin(HERE/'warm-driver-v02.mjs'),R.pin(HERE/'run-v01.py'),R.pin(HERE/'hosted-v01.mjs'),*plan['inputs']]
 for item in inputs:R.verify(item)
 out.mkdir(parents=True);configs=[];observers=[]
 for i in range(4):
  work=out/f'iteration-{i:02d}';work.mkdir();observer=work/'hosted-observer.mjs';observer.write_bytes((HERE/'hosted-v01.mjs').read_bytes());R.require(observer.read_bytes()==(HERE/'hosted-v01.mjs').read_bytes(),'Observer copy mismatch');inputs.append(R.pin(observer));observers.append(str(observer));config=dict(api=plan['api'],source=case['source'],base=plan['base'],carrier=plan['carrier'],stamp=plan['stamp'],output=str(work/'program.ssa'),observation=str(work/'observation.json'),instrumented=False);path=work/'input.json';path.write_text(json.dumps(config,indent=2)+'\n');configs.append(str(path))
 driver=dict(iterations=configs,observers=observers,output=str(out/'iterations.json'));(out/'driver.json').write_text(json.dumps(driver,indent=2)+'\n')
 report=dict(kind='phase145-engine-warm-diagnostic-v02',complete=False,inputs=inputs,case=case,iterations=[]);start=time.monotonic()
 try:
  report['process']=R.child([plan['bun']['file'],str(HERE/'warm-driver-v02.mjs'),str(out/'driver.json')],out,150);R.require(report['process']['stdout']['bytes']==0,'Unexpected output')
  iterations=json.loads((out/'iterations.json').read_text());R.require(iterations['complete'],'Incomplete warm observations');report['driver']=R.pin(out/'iterations.json')
  for i,row in enumerate(iterations['rows']):
   work=out/f'iteration-{i:02d}';obs=json.loads((work/'observation.json').read_text());R.require(obs['complete'] and R.N.same_bytes(work/'program.ssa',Path(case['expectedQbe']['file'])),'Warm complete-QBE mismatch');report['iterations'].append(dict(**row,observation=R.pin(work/'observation.json'),stages=obs['timings'],product=R.pin(work/'program.ssa'),byteExact=True))
  report['warmMedianSeconds']=statistics.median(r['seconds'] for r in report['iterations'] if not r['warmup']);report['scope']=iterations['scope']
  for item in inputs:R.verify(item)
  report['complete']=True
 except BaseException as e:report['error']=repr(e)
 finally:report['totalSeconds']=time.monotonic()-start;(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({k:report.get(k) for k in ['complete','totalSeconds','warmMedianSeconds','error']}));return 0 if report['complete'] else 1
if __name__=='__main__':sys.exit(main())
