#!/usr/bin/env python3
"""Plan/seal an exact current N1 diagnostic relink; metadata only, no targets."""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
PROF=ROOT/'selfhost/tools/profiler'
sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from owners import parse_qbe_owners
import runtime


def read(path):return json.loads(Path(path).read_text())
def need(value,message):
 if not value:raise ValueError(message)
def unique(items):return list({(p['file'],p['sha256']):p for p in items}.values())


def main():
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument('action',choices=['prepare','seal'])
 ap.add_argument('--out',type=Path,required=True)
 ap.add_argument('--cold-report',type=Path,default=ROOT/'selfhost/build/phase130/p143-current-native-cold01/report.json')
 a=ap.parse_args();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase143'),'Phase143 output required')
 candidate_path=ROOT/'implementation/phase142/candidate.json';c=read(candidate_path)
 need(c['complete'] and c['sourceChecked'] and c['nativeAcquired'] and not c['nativeQualified'] and not c['selected'],'Expected experimental current candidate')
 need(c['source']['sha256']=='15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1','Current source changed')
 built=read(verify(c['machineBuild']));emitted=read(verify(c['emission']));checked=read(verify(c['checkedApi']))
 need(built['complete'] and built['binary']==c['native'] and built['object'] and all(j['exitCode']==0 for j in built['jobs']),'Current machine build incomplete')
 need(emitted['complete'] and emitted['source']==c['source'] and emitted['image']==c['producer'],'Current QBE source/producer mismatch')
 qbe=emitted['product']
 need(qbe in built['inputs'] and built['jobs'][0]['command'][-1]==qbe['file'] and c['runtime'] in built['inputs'],'Object/QBE/runtime mismatch')
 need(checked['complete'] and checked['checked'] and c['source'] in checked['inputs'],'Exact checked source unavailable')
 parent_path=ROOT/'implementation/phase137/candidate.json';parent=read(parent_path)
 need(parent['nativeQualified'] and parent['preferredNative']==c['producer'],'QBE oracle producer is not qualified Phase137')
 spec=importlib.util.spec_from_file_location('request',ROOT/'selfhost/tools/performance/phase130/native-request.py')
 request=importlib.util.module_from_spec(spec);spec.loader.exec_module(request)
 carrier,base,carrier_inputs=request.carrier_inputs(Path(parent['preferredCarrierReceipt']['file']))
 command=[c['native']['file'],'--threads','1','--gpu','off','--','phase111',c['source']['file'],base['file'],'cache',carrier['carrier']['file'],carrier['stamp']]
 # Reuse only the existing diagnostic runtime, not an old compiler image.
 old=ROOT/'selfhost/build/phase131/context01';origin=read(old/'runtime-input.json');plan=read(old/'runtime/plan.json');rb=read(old/'build/report.json')
 clean_path=ROOT/'selfhost/build/phase128/runtime-borrow01/report.json';clean=read(clean_path)
 need(clean['complete'] and clean['object']==c['runtime'] and clean['source']==origin['runtime'],'Clean/diagnostic runtime source mismatch')
 need(plan['complete'] and plan['reverseExact'] and rb['complete'] and rb['plan']==pin(old/'runtime/plan.json'),'Diagnostic runtime provenance incomplete')
 compile_job=rb['jobs'][0]
 need(compile_job['command']==plan['jobs'][0]['command'] and compile_job['returncode']==0 and not compile_job['timedOut'],'Diagnostic runtime compile failed')
 diagnostic_runtime=compile_job['product'];need(diagnostic_runtime in rb['products'],'Runtime product not bound')
 reconstructed,edits=runtime.materialize(Path(verify(clean['source'])).read_bytes())
 need((old/'runtime/runtime.c').read_bytes()==reconstructed and read(old/'runtime/edits.json')==edits,'Runtime instrumentation recipe changed')
 outputs={Path(p['file']).name:p for p in plan['outputs']}
 for header in origin['headers']:
  verify(header)
  need(pin(old/'runtime'/Path(header['file']).name)==outputs[Path(header['file']).name],'Diagnostic header changed')
  need(any(p['bytes']==header['bytes'] and p['sha256']==header['sha256'] and Path(p['file']).name==Path(header['file']).name for p in clean['inputs']),'Clean header differs')
 need((old/'runtime/runtime-support.inc.c').read_bytes()==(PROF/'runtime-support.inc.c').read_bytes(),'Runtime support changed')
 sampler_path=ROOT/'selfhost/build/phase140/sampler01/report.json';sampler=read(sampler_path)
 need(sampler['complete'] and sampler['returncode']==0 and pin(PROF/'sample.c') in sampler['inputs'],'Current sampler lineage incomplete')
 table=pin(ROOT/'selfhost/build/phase127/libc-unwind01/table.json')
 evidence=unique([pin(__file__),pin(candidate_path),c['source'],c['sourceManifest'],c['checkedApi'],c['native'],c['runtime'],c['machineBuild'],built['object'],c['emission'],qbe,pin(parent_path),parent['qualification'],parent['preferredNative'],*carrier_inputs,pin(clean_path),clean['source'],pin(old/'runtime-input.json'),pin(old/'runtime/plan.json'),pin(old/'build/report.json'),diagnostic_runtime,*origin['headers'],*plan['outputs'],pin(PROF/'runtime.py'),pin(PROF/'runtime-support.inc.c'),pin(PROF/'owners.py'),pin(sampler_path),sampler['sampler'],*sampler['inputs'],table])
 for item in evidence:verify(item)
 if a.action=='prepare':
  need(not out.exists(),'Fresh profile directory required');out.mkdir(parents=True);(out/'runtime').mkdir()
  link=copy.deepcopy(plan['jobs'][1]);link['command'][2]=built['object']['file'];link['command'][-1]=str(out/'runtime/program')
  need(link['command'][3]==diagnostic_runtime['file'],'Wrong diagnostic runtime link input')
  save(out/'owners.json',parse_qbe_owners(qbe['file']))
  relink=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,
   inputs=evidence,outputs=[],jobs=[link],reusedRuntimeObject=diagnostic_runtime,
   scope='Relink exact Phase142 N1 program.o with authenticated unchanged Phase131 context runtime. No compiler, QBE or runtime compilation; no qualification claim.')
  save(out/'runtime/plan.json',relink)
  template=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=evidence,ownerMap=pin(out/'owners.json'),sampler=sampler['sampler'],unwindTable=table,
   workloads=[dict(name='current-self-source',timeoutSeconds=900,variants=[dict(name='phase142-indexed-n1-context',command=command,binary=c['native'],dispatchInstrumentation=True,inputs=[],expected=dict(exitCode=0,stdout=dict(kind='exact',bytes=qbe['bytes'],sha256=qbe['sha256']),stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest())))])],
   lineage=dict(nativeQualified=False,selected=False,source=c['source'],cleanImage=c['native'],programObject=built['object'],qbe=qbe,oracleProducer=c['producer'],oracleEmission=c['emission'],cleanRuntime=c['runtime'],diagnosticRuntime=diagnostic_runtime),
   resourcePlan=dict(cpu=3,outerGuardSeconds=960,innerTargetTimeoutSeconds=900,treeRssLimitMiB=4096,availableFloorMiB=16384,fileSizeLimitMiB=256,expectedStdoutBytes=qbe['bytes'],runtimeCountersEnabled=False),
   scope='One sample-only ordinary current-source cold self-build. Exact independent QBE oracle; low-overhead active contexts with counters disabled. Physical leaves, active dispatch and bounded callers are not inclusive logical stacks. CPU-order windows are approximate, not boundaries inferred from JS/Bun stage times.')
  save(out/'template.json',template)
 else:
  need(out.exists() and not (out/'manifest.json').exists(),'Existing unsealed profile required')
  relink=read(out/'runtime/plan.json');result=read(out/'build/report.json')
  need(result['complete'] and result['plan']==pin(out/'runtime/plan.json') and len(result['jobs'])==1,'Diagnostic relink incomplete')
  job=result['jobs'][0]
  need(job['command']==relink['jobs'][0]['command'] and job['returncode']==0 and not job['timedOut'] and job['product'] in result['products'],'Diagnostic link mismatch/failure')
  need(job['command'][2:4]==[built['object']['file'],diagnostic_runtime['file']],'Actual relink inputs changed')
  cold=read(a.cold_report)
  need(cold['complete'] and cold['image']==c['native'] and cold['source']==c['source'] and cold['command']==command,'Matching ordinary clean self-build required')
  need(cold['expectedQbe']==qbe and cold['product']['sha256']==qbe['sha256'] and cold['product']['bytes']==qbe['bytes'],'Clean self-build oracle differs')
  template=read(out/'template.json');variant=template['workloads'][0]['variants'][0]
  need(variant['command']==command and template['lineage']['qbe']==qbe,'Prepared request changed')
  variant['binary']=job['product'];variant['command'][0]=job['product']['file']
  variant['inputs']=[pin(p) for p in variant['command'] if Path(p).is_file()]
  template['diagnosticImage']=job['product'];template['adjacentCleanReceipt']=pin(a.cold_report)
  template['inputs']=unique([*template['inputs'],pin(out/'runtime/plan.json'),pin(out/'build/report.json'),pin(out/'owners.json'),job['product'],pin(a.cold_report),cold['product']])
  for item in all_pins(template):verify(item)
  save(out/'manifest.json',template)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(label,seconds,cmd):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','4096','--available-mib','16384','--file-mib','256','--cpu','3','--',*cmd]
 relink_cmd=[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan.json'),'--out',str(out/'build')]
 seal_cmd=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--out',str(out),'--cold-report',str(a.cold_report.resolve())]
 capture_cmd=[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--names','current-self-source','--modes','sample','--rounds','1','--periods-us','32000']
 sample=out/'capture/000-sample-current-self-source-phase142-indexed-n1-context'
 shared=['--analysis',str(sample/'analysis.json'),'--callers',str(sample/'callers.txt'),'--table',table['file'],'--contexts',str(sample/'contexts.txt'),'--owners',str(out/'owners.json')]
 jobs=dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(guard),pin(PROF/'build-runtime.py'),pin(PROF/'run.py'),pin(PROF/'attribute.py'),pin(PROF/'timeline.py')],jobs=[
  dict(name='relink-only',command=guarded('build',45,relink_cmd)),dict(name='seal-after-relink-and-clean-baseline',command=seal_cmd),dict(name='ordinary-cold-context-profile',command=guarded('capture',960,capture_cmd)),
  dict(name='offline-attribution',command=[sys.executable,'-B',str(PROF/'attribute.py'),*shared,'--summary-only','--out',str(out/'attribution')]),
  dict(name='offline-approximate-cpu-windows',command=[sys.executable,'-B',str(PROF/'timeline.py'),*shared,'--window-cpu-seconds','30','--out',str(out/'timeline')])],
  caveat='Only first three jobs touch linking/target execution; root must run serially. Preparation and sealing are metadata only. Counters disabled; sampled duration is not a clean performance metric.')
 # Preparation owns the plan. Sealing must not mutate its pinned job description.
 if a.action=='prepare':save(out/'jobs.json',jobs)
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))


if __name__=='__main__':main()
