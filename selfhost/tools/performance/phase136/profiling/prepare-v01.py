#!/usr/bin/env python3
"""Metadata-only qualified Phase134 N2 relink and one full-source profile plan.
Neither action runs the compiler, linker, sampler or target. Root owns execution.
"""
import argparse,copy,importlib.util,json,pathlib,sys
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from owners import parse_qbe_owners

def read(p):return json.loads(pathlib.Path(p).read_text())
def need(c,m):
 if not c:raise ValueError(m)
def distinct(pins):return list({(p['file'],p['sha256']):p for p in pins}.values())

def lineage():
 cp=ROOT/'implementation/phase134/final/candidate.json';c=read(cp);need(c['complete']and c['nativeQualified'],'Qualified Phase134 checkpoint required');q=read(verify(c['qualification']))
 need(q['complete']and q['nativeQualified']and all(q[k]==c[k]for k in('source','n1','n2','runtime')),'Qualification/source/image mismatch')
 bp=q['reports']['n2_build'];b=read(verify(bp));need(b['complete']and b['binary']==c['n2']and q['qbe']['q2']in b['inputs']and c['runtime']in b['inputs'],'Actual qualified N2 object lineage mismatch')
 old=ROOT/'selfhost/build/phase131/context01';rp=old/'runtime/plan.json';rb=old/'build/report.json';ri=old/'runtime-input.json';plan,built,origin=read(rp),read(rb),read(ri);clean=read(verify(c['runtimeReport']))
 need(plan['complete']and plan['reverseExact']and built['complete']and built['plan']==pin(rp),'Authenticated diagnostic runtime unavailable')
 need(clean['complete']and clean['object']==c['runtime']and clean['source']==origin['runtime'],'Clean/diagnostic source differs')
 for h in origin['headers']:
  same=[p for p in clean['inputs']if pathlib.Path(p['file']).name==pathlib.Path(h['file']).name];need(same and all((p['sha256'],p['bytes'])==(h['sha256'],h['bytes'])for p in same),'Runtime header mismatch')
 need([j['label']for j in plan['jobs']]==['compile-runtime','link-diagnostic']and[j['command']for j in built['jobs']]==[j['command']for j in plan['jobs']]and all(j['returncode']==0 and not j['timedOut']for j in built['jobs']),'Diagnostic build command/status mismatch')
 runtime=built['jobs'][0]['product'];need(runtime in built['products'],'Diagnostic runtime object missing')
 evidence=distinct([pin(__file__),pin(cp),c['qualification'],c['source'],c['sourceManifest'],c['runtime'],c['runtimeReport'],c['n2'],bp,b['object'],q['qbe']['q2'],pin(rp),pin(rb),pin(ri),*plan['inputs'],*plan['outputs'],runtime])
 for p in evidence:verify(p)
 return c,q,b,plan,runtime,evidence

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','seal']);ap.add_argument('--out',type=pathlib.Path,required=True);a=ap.parse_args();out=a.out.resolve();need(out.is_relative_to(ROOT/'selfhost/build/phase136'),'Phase136 output required')
 c,q,b,oldplan,runtime,evidence=lineage()
 oldpath=ROOT/'selfhost/build/phase131/final-full-context01/manifest.json';old=read(oldpath);physical=read(ROOT/'selfhost/build/phase131/profile01/manifest.json')
 # Reuse the exact old source, compact Base and independent complete 107MB output.
 work=copy.deepcopy(old['workloads'][0]);v=work['variants'][0];need(work['name']=='compiler-self-source'and v['command'][1:7]==['--threads','1','--gpu','off','--','phase111']and v['command'][10]==c['preferredCarrier']['file']and v['command'][11]==c['preferredStamp'],'Frozen full request/carrier differs')
 template=copy.deepcopy(old);template.pop('adjacentHistoricalClean',None);template['inputs']=distinct([pin(oldpath),*evidence,physical['sampler'],physical['unwindTable'],*v['inputs'],*list(all_pins(v['expected']))]);template['unwindTable']=physical['unwindTable'];template['sampler']=physical['sampler'];template['workloads']=[work]
 template['lineage']=dict(nativeQualified=True,source=c['source'],image=c['n2'],qbe=q['qbe']['q2'],programObject=b['object'],qualification=c['qualification']);template['scope']='One32ms sample-only ordinary cold compiler-A request on exact qualified Phase134 N2 program.o relinked with the authenticated unchanged diagnostic runtime. Physical leaf + active dispatch + bounded authenticated libc caller. Counters disabled. No clean speed ratio or175s frontend-stage attribution.'
 template['resourcePlan'].update(outerGuardSeconds=660,innerTargetTimeoutSeconds=600,treeRssLimitMiB=4096,availableFloorMiB=16384,fileSizeLimitMiB=256,cpu=3)
 work['timeoutSeconds']=600
 if a.action=='prepare':
  need(not out.exists(),'Fresh preparation directory required');out.mkdir(parents=True);(out/'runtime').mkdir()
  job=copy.deepcopy(oldplan['jobs'][1]);job['command'][2]=b['object']['file'];job['command'][-1]=str(out/'runtime/program');need(job['command'][3]==runtime['file'],'Diagnostic runtime argument differs')
  plan=copy.deepcopy(oldplan);plan.update(compiled=False,executed=False,jobs=[job],outputs=[],inputs=evidence,reusedRuntimeObject=runtime,scope='Relink only: exact qualified Phase134 N2 program.o; existing reversible Phase131 diagnostic runtime with identical clean Phase128 source/headers. No runtime or compiler generation.')
  save(out/'runtime/plan.json',plan);owners=parse_qbe_owners(q['qbe']['q2']['file']);save(out/'owners.json',owners)
  save(out/'lineage.json',dict(complete=True,targetsRun=False,inputs=[*evidence,pin(PROF/'owners.py'),pin(out/'owners.json')],source=c['source'],image=c['n2'],object=b['object'],qbe=q['qbe']['q2'],diagnosticRuntime=runtime,ownerScope='Exact current dispatch table; lexical grouping conditional on unchanged lowering contract, not logical/inclusive stacks. Runtime attribution checks linked FID addresses.'))
  template['ownerMap']=pin(out/'owners.json');template.pop('diagnosticImage',None);save(out/'template.json',template)
 else:
  need(out.exists()and not(out/'manifest.json').exists(),'Existing unsealed preparation required');plan=read(out/'runtime/plan.json');built=read(out/'build/report.json')
  need(built['complete']and built['plan']==pin(out/'runtime/plan.json')and len(built['jobs'])==1 and built['jobs'][0]['command']==plan['jobs'][0]['command']and built['jobs'][0]['returncode']==0 and not built['jobs'][0]['timedOut'],'Actual successful diagnostic relink required')
  need(plan['jobs'][0]['command'][2]==b['object']['file']and plan['reusedRuntimeObject']==runtime,'Wrong relinked object/runtime')
  diagnostic=built['jobs'][0]['product'];need(diagnostic in built['products'],'Diagnostic image product absent');template=read(out/'template.json');v=template['workloads'][0]['variants'][0];v['binary']=diagnostic;v['name']='phase134-qualified-n2-context';v['command'][0]=diagnostic['file'];v['dispatchInstrumentation']=True;v['inputs']=[pin(p)for p in v['command']if pathlib.Path(p).is_file()]
  template['diagnosticImage']=diagnostic;template['inputs']=distinct([*template['inputs'],pin(out/'runtime/plan.json'),pin(out/'build/report.json'),pin(out/'lineage.json'),pin(out/'owners.json'),diagnostic]);
  for p in all_pins(template):verify(p)
  save(out/'manifest.json',template)
  command=[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--names','compiler-self-source','--modes','sample','--rounds','1','--periods-us','32000']
  save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(out/'manifest.json'),pin(PROF/'run.py')],command=command,resourcePlan=template['resourcePlan'],runtimeCountersEnabled=False))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
