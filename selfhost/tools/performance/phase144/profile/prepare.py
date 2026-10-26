#!/usr/bin/env python3
"""Prepare/seal qualified N2 residual profiling by retained-object relink only."""
import argparse,copy,hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from owners import parse_qbe_owners

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def unique(ps):return list({(p['file'],p['sha256']):p for p in ps}.values())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','seal']);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase144'),'Phase144 output required')
 old_path=ROOT/'selfhost/build/phase143/profile01/manifest-v02.json';old=read(old_path)
 # Retained Phase143 authority includes the corrected CFI sampler build/table and reversible runtime lineage.
 for item in all_pins(old):verify(item)
 candidate_path=ROOT/'implementation/phase143/candidate.json';c=read(candidate_path)
 need(c['complete'] and c['sourceChecked'] and c['nativeQualified'] and not c['selected'],'Qualified unselected Phase143 required')
 q=read(verify(c['qualification']));built=read(verify(c['nativeBuild']));checked=read(verify(c['checkedApi']))
 need(q['complete'] and q['nativeQualified'] and q['n2']==c['native'] and q['source']==c['source'],'Qualification binding failed')
 need(built['complete'] and built['binary']==c['native'] and c['runtime'] in built['inputs'] and all(j['exitCode']==0 for j in built['jobs']),'Native build failed')
 program_qbe=pin(built['jobs'][0]['command'][-1]);need(program_qbe in built['inputs'] and all(program_qbe[k]==q['qbe'][k] for k in ['sha256','bytes']),'Qualified QBE differs')
 need(checked['complete'] and checked['checked'] and c['source'] in checked['inputs'],'Source check missing')
 cold_path=ROOT/'selfhost/build/phase130/p143-candidate-current-cold01/report.json';cold=read(cold_path)
 oracle_path=ROOT/'selfhost/build/phase130/p142-indexed-emit01/report.json';oracle=read(oracle_path)
 need(cold['complete'] and cold['image']==c['n1'] and oracle['complete'] and cold['source']==oracle['source'],'Historical matched-source clean request missing')
 need(all(cold['product'][k]==oracle['product'][k] for k in ['bytes','sha256']),'Historical output mismatch')
 n1_path=ROOT/'selfhost/build/phase111/p143-integrated-n1/report.json';n1=read(n1_path)
 need(n1['complete'] and n1['binary']==c['n1'] and all(n1['object'][k]==built['object'][k] for k in ['sha256','bytes']),'N1/N2 object equality absent')
 spec=importlib.util.spec_from_file_location('native_request',ROOT/'selfhost/tools/performance/phase130/native-request.py');nr=importlib.util.module_from_spec(spec);spec.loader.exec_module(nr)
 carrier,base,carrier_inputs=nr.carrier_inputs(Path(c['preferredCarrierReceipt']['file']))
 command=[c['native']['file'],'--threads','1','--gpu','off','--','phase111',cold['source']['file'],base['file'],'cache',carrier['carrier']['file'],carrier['stamp']]
 need(command[1:]==cold['command'][1:],'Workload/Base/carrier differs from clean request')
 diagnostic=old['lineage']['diagnosticRuntime'];need(old['lineage']['cleanRuntime']==c['runtime'],'Diagnostic runtime lineage changed')
 evidence=unique([pin(__file__),pin(old_path),*old['inputs'],pin(candidate_path),*all_pins(c),pin(n1_path),n1['object'],built['object'],program_qbe,pin(cold_path),*cold['inputs'],cold['product'],pin(oracle_path),oracle['product'],*carrier_inputs])
 for item in evidence:verify(item)
 if a.action=='prepare':
  need(not out.exists(),'Fresh profile directory required');out.mkdir(parents=True);(out/'runtime').mkdir()
  old_relink=read(ROOT/'selfhost/build/phase143/profile01/runtime/plan.json');job=copy.deepcopy(old_relink['jobs'][0]);job['command'][2]=built['object']['file'];job['command'][-1]=str(out/'runtime/program')
  need(job['command'][3]==diagnostic['file'],'Wrong runtime link input')
  save(out/'owners.json',parse_qbe_owners(program_qbe['file']))
  save(out/'runtime/plan.json',dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=evidence,outputs=[],jobs=[job],reusedRuntimeObject=diagnostic,scope='Qualified Phase143 N2 object, unchanged authenticated context runtime; diagnostic relink only.'))
  template=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=evidence,ownerMap=pin(out/'owners.json'),sampler=old['sampler'],unwindTable=old['unwindTable'],workloads=[dict(name='fixed-phase142-source',timeoutSeconds=600,variants=[dict(name='phase143-n2-context',command=command,binary=c['native'],dispatchInstrumentation=True,inputs=[],expected=dict(exitCode=0,stdout=dict(kind='exact',bytes=oracle['product']['bytes'],sha256=oracle['product']['sha256']),stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest())))])],lineage=dict(nativeQualified=True,diagnosticNativeQualified=False,selected=False,compilerSource=c['source'],requestSource=cold['source'],cleanImage=c['native'],programObject=built['object'],qbe=program_qbe,expectedOutput=oracle['product'],oracleEmission=pin(oracle_path),cleanRuntime=c['runtime'],diagnosticRuntime=diagnostic),cleanComparison=dict(receipt=pin(cold_path),image=cold['image'],seconds=cold['nativeSeconds'],sameObjectN1N2=True,freshN2Timing=False,note='296.541s belongs to matched-source N1, whose object equals N2; ELF images differ. Not a new clean N2 measurement.'),resourcePlan=dict(cpu=3,treeRssLimitMiB=3072,availableFloorMiB=16384,fileSizeLimitMiB=256,countersEnabled=False),scope='One sample-only ordinary request on fixed Phase142 source, no previous-source reuse. Physical/context/callers overlap. Diagnostic duration is not a clean speed result.')
  save(out/'template.json',template)
 else:
  need(out.exists() and not(out/'manifest.json').exists(),'Existing unsealed profile required')
  relink=read(out/'runtime/plan.json');result=read(out/'build/report.json');need(result['complete'] and result['plan']==pin(out/'runtime/plan.json') and len(result['jobs'])==1,'Relink incomplete')
  job=result['jobs'][0];need(job['command']==relink['jobs'][0]['command'] and job['returncode']==0 and not job['timedOut'] and job['product'] in result['products'],'Relink mismatch')
  need(job['command'][2:4]==[built['object']['file'],diagnostic['file']],'Wrong object/runtime')
  template=read(out/'template.json');v=template['workloads'][0]['variants'][0];need(v['command']==command,'Prepared workload changed')
  v['binary']=job['product'];v['command'][0]=job['product']['file'];v['inputs']=[pin(p) for p in v['command'] if Path(p).is_file()]
  template['diagnosticImage']=job['product'];template['inputs']=unique([*template['inputs'],pin(out/'runtime/plan.json'),pin(out/'build/report.json'),pin(out/'owners.json'),job['product']])
  for item in all_pins(template):verify(item)
  save(out/'manifest.json',template)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(label,seconds,cmd):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*cmd]
 sample=out/'capture/000-sample-fixed-phase142-source-phase143-n2-context';shared=['--analysis',str(sample/'analysis.json'),'--callers',str(sample/'callers.txt'),'--table',old['unwindTable']['file'],'--contexts',str(sample/'contexts.txt'),'--owners',str(out/'owners.json')]
 jobs=[dict(name='relink-only',command=guarded('build',45,[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan.json'),'--out',str(out/'build')])),dict(name='seal',command=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--out',str(out)]),dict(name='residual-profile',command=guarded('capture',660,[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--names','fixed-phase142-source','--modes','sample','--rounds','1','--periods-us','32000'])),dict(name='offline-attribution',command=[sys.executable,'-B',str(PROF/'attribute.py'),*shared,'--summary-only','--out',str(out/'attribution')]),dict(name='offline-cpu-windows',command=[sys.executable,'-B',str(PROF/'timeline.py'),*shared,'--window-cpu-seconds','30','--out',str(out/'timeline')])]
 if a.action=='prepare':save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(guard),pin(PROF/'run.py'),pin(PROF/'build-runtime.py')],jobs=jobs,scope='Root executes serially. No source/compiler/machine build; relink and one sampled target only.'))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
