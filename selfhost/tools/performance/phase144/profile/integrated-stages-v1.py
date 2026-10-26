#!/usr/bin/env python3
"""Prepare/seal new-image native stage capture; retained object, unchanged input."""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from owners import parse_qbe_owners
from stages_v1 import validate_spec

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def unique(ps):return list({(p['file'],p['sha256']):p for p in ps}.values())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','ready','seal']);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase144'),'Phase144 output required')
 source_path=ROOT/'selfhost/build/phase144/integrated-source01/manifest.json';source=read(source_path)
 need(source['complete'] and source['source']['sha256']=='992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b','Exact integrated source required')
 build_path=ROOT/'selfhost/build/phase134/p144-integrated-n1-01/report.json';built=read(build_path)
 check_path=ROOT/'selfhost/build/phase111/p144-integrated-api01/report.json';checked=read(check_path)
 parent_path=ROOT/'implementation/phase143/candidate.json';parent=read(parent_path)
 cold_path=ROOT/'selfhost/build/phase130/p144-integrated-fixed-cold01/report.json';cold=read(cold_path)
 before_path=ROOT/'selfhost/build/phase130/p144-parent-fixed-cold01/report.json';before=read(before_path)
 need(built['complete'] and built['compilerExitCode']==0 and built['qbeExitCode']==0 and all(j['exitCode']==0 for j in built['jobs']),'Integrated image build incomplete')
 need(built['source']==source['source'] and built['image']==parent['native'] and parent['nativeQualified'] and built['runtime']==parent['runtime'],'Source/qualified producer/runtime mismatch')
 need(checked['complete'] and checked['checked'] and source['source'] in checked['inputs'],'Exact integrated independent source check missing')
 need(cold['complete'] and cold['image']==built['binary'] and before['complete'] and before['image']==parent['native'] and cold['source']==before['source'],'Fresh matched clean pair missing')
 need(cold['command'][1:]==before['command'][1:] and all(cold['product'][k]==before['product'][k] for k in ['bytes','sha256']),'Frozen clean request/output changed')
 oracle_path=ROOT/'selfhost/build/phase130/p142-indexed-emit01/report.json';oracle=read(oracle_path)
 need(oracle['complete'] and oracle['source']==cold['source'] and all(oracle['product'][k]==cold['product'][k] for k in ['bytes','sha256']),'Independent fixed142 oracle differs')
 prior_path=ROOT/'selfhost/build/phase144/generic-gate01/manifest.json';prior=read(prior_path)
 qualification_path=ROOT/'selfhost/build/phase144/generic-gate01/qualification.json';qualification=read(qualification_path)
 need(qualification['complete'] and qualification['genericRuntimeCompiled'] and qualification['genericRuntimeExecuted'],'Successful generic native pilot required')
 spec_path=ROOT/'selfhost/build/phase144/generic-stages01/spec.json';oldspec=read(spec_path)
 inherited=[pin(__file__),pin(source_path),source['source'],pin(build_path),*built['inputs'],built['binary'],built['object'],built['retainedIR'],pin(check_path),pin(parent_path),parent['qualification'],pin(cold_path),*cold['inputs'],cold['product'],pin(before_path),before['product'],pin(oracle_path),oracle['product'],pin(prior_path),pin(qualification_path),*qualification['inputs'],qualification['sampler'],pin(spec_path),pin(PROF/'stages_v1.py'),pin(PROF/'stages-build-v1.py')]
 for item in inherited:verify(item)
 if a.action=='prepare':
  need(not out.exists(),'Fresh integrated profile output required');out.mkdir(parents=True)
  owners=parse_qbe_owners(built['retainedIR']['file']);save(out/'owners.json',owners)
  replacements={'nr_prepare_annotated':'p144o_prepare_annotated','p128raw_lower_request':'p144o_lower_request','p128raw_prepared':'p144o_prepared'}
  spec=copy.deepcopy(oldspec);spec['ownerMap']=pin(out/'owners.json');spec['programObject']=built['object']
  for marker in spec['markers']:
   name=replacements.get(marker['label'],marker['label']);matches=[r for r in owners['fids'] if r['decoded']=='$direct.'+name and r['role']=='direct_segment'];need(len(matches)==1,'Unique new direct marker absent: '+name)
   marker.update(label=name,fid=matches[0]['fid'],symbol=matches[0]['symbol'])
  spec['requiredOrder']=[replacements.get(n,n) for n in spec['requiredOrder']]
  for interval in spec['intervals']:
   interval['begin']=replacements.get(interval['begin'],interval['begin']);interval['end']=replacements.get(interval['end'],interval['end'])
  spec['scope']='Fresh integrated992893e N1 direct entries. Pure forwarding wrappers are replaced by actual p144o entries; interval labels retain comparable semantic boundaries. Independent final verifier stays enabled.';spec['boundaryMapping']=replacements;validate_spec(spec,owners);save(out/'spec.json',spec)
  template=copy.deepcopy(prior);template['ownerMap']=spec['ownerMap'];template['nativeStageSpec']=pin(out/'spec.json')
  pilot=copy.deepcopy(template['workloads'][0]);pilot['variants'][0]['name']='phase144-integrated-n1-stages';pilot['variants'][0]['binary']=built['binary'];pilot['variants'][0]['command'][0]=built['binary']['file']
  full=copy.deepcopy(pilot);full['name']='fixed-phase142-source';full['timeoutSeconds']=600;fv=full['variants'][0];fv['command']=list(cold['command']);fv['expected']['stdout']={**{k:oracle['product'][k] for k in ['bytes','sha256']},'kind':'exact'}
  template['workloads']=[pilot,full];template['inputs']=unique([*template['inputs'],*inherited,pin(out/'owners.json'),pin(out/'spec.json')]);template['lineage']=dict(nativeQualified=False,sourceChecked=True,selected=False,compilerSource=source['source'],cleanImage=built['binary'],programObject=built['object'],qbe=built['retainedIR'],cleanRuntime=built['runtime'],producer=built['image'],sourceCheck=pin(check_path),acquisition=pin(build_path),requestSource=cold['source'],expectedOutput=oracle['product'])
  template['cleanComparison']=dict(parent=pin(before_path),candidate=pin(cold_path),parentSeconds=before['nativeSeconds'],candidateSeconds=cold['nativeSeconds'],ratio=cold['nativeSeconds']/before['nativeSeconds'],scope='Actual fresh same-source clean pair. Diagnostic stage differences do not form an exact causal decomposition of this gain.')
  template['scope']='Fresh integrated N1 retained-object stage profile. Independent small Lexer gate before frozen142 full source. Generic instrumentation already has a separate small qualification; new FID mapping must pass again. No new compiler qualification or clean timing claim.';save(out/'template.json',template)
 elif a.action=='ready':
  need(not(out/'runtime/plan-reuse.json').exists(),'Fresh derived runtime plan required');plan=read(out/'runtime/plan.json');need(plan['stageSpec']==pin(out/'spec.json') and len(plan['jobs'])==3,'Generic prepared plan differs')
  oldbuild_path=ROOT/'selfhost/build/phase144/generic-gate01/build/report.json';oldbuild=read(oldbuild_path);need(oldbuild['complete'] and oldbuild['jobs'][0]['product']==qualification['sampler'],'Reusable sampler receipt differs')
  oldsampler=Path(qualification['sampler']['file']).parent
  for name in ['sample.c','unwind-table.h']:
   need((out/'runtime'/name).read_bytes()==(oldsampler/name).read_bytes(),'Sampler/header changed; reuse invalid')
  plan['jobs']=plan['jobs'][1:];plan['inputs']=unique([*plan['inputs'],pin(out/'runtime/plan.json'),pin(oldbuild_path),qualification['sampler'],pin(oldsampler/'sample.c'),pin(oldsampler/'unwind-table.h')]);plan['reusedSampler']=qualification['sampler'];plan['scope']+=' Reuse already qualified byte-identical ordinal sampler; compile only new marker runtime and relink new compiler object.';save(out/'runtime/plan-reuse.json',plan)
 else:
  need(not(out/'manifest.json').exists(),'Unsealed capture required');plan=read(out/'runtime/plan-reuse.json');actual=read(out/'build/report.json');need(actual['complete'] and actual['plan']==pin(out/'runtime/plan-reuse.json') and len(actual['jobs'])==2,'Marker runtime build incomplete')
  for want,have in zip(plan['jobs'],actual['jobs']):need(want['command']==have['command'] and have['returncode']==0 and not have['timedOut'],'Build command/status mismatch');verify(have['product'])
  need(actual['jobs'][-1]['command'][2]==built['object']['file'],'Actual relink used another program object')
  manifest=read(out/'template.json');image=actual['jobs'][-1]['product'];manifest['sampler']=qualification['sampler'];manifest['diagnosticImage']=image;manifest['lineage']['diagnosticRuntime']=actual['jobs'][0]['product']
  for workload in manifest['workloads']:
   v=workload['variants'][0];need(v['command'][0]==built['binary']['file'],'Prepared compiler image changed');v['command'][0]=image['file'];v['binary']=image;v['inputs']=[pin(x) for x in v['command'] if Path(x).is_file()]
  manifest['inputs']=unique([*manifest['inputs'],pin(out/'runtime/plan.json'),pin(out/'runtime/plan-reuse.json'),pin(out/'build/report.json'),*plan['outputs'],*actual['products'],qualification['sampler']])
  for item in all_pins(manifest):verify(item)
  save(out/'manifest.json',manifest)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(label,seconds,command):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*command]
 def capture(name,label,seconds,period):return guarded(label,seconds,[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/label),'--names',name,'--modes','sample','--rounds','1','--periods-us',str(period)])
 def observe(label):return [sys.executable,'-B',str(PROF/'stages_v1.py'),'observe','--spec',str(out/'spec.json'),'--run',str(out/label/'report.json'),'--out',str(out/(label+'-stages.json'))]
 jobs=[dict(name='compile-marker-runtime-and-relink-new-object',command=guarded('build',60,[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan-reuse.json'),'--out',str(out/'build')])),dict(name='seal-actual-products',command=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--out',str(out)]),dict(name='new-mapping-small-exact-lexer-gate',command=capture('lexer-stage-pilot','pilot',55,8000)),dict(name='verify-small-gate-offline',command=observe('pilot')),dict(name='fixed142-full-only-after-pilot-pass',command=capture('fixed-phase142-source','capture',660,32000)),dict(name='full-stage-association-offline',command=observe('capture'))]
 if a.action=='prepare':save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(PROF/'stages_v1.py'),pin(PROF/'run.py'),pin(PROF/'build-runtime.py')],jobs=jobs,gate='Root serial lane. Before executing, generic runtime plan must be materialized and ready action must bind byte-identical sampler reuse. Stop before full capture if small output/marker gate fails.'))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
