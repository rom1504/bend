#!/usr/bin/env python3
"""Prepare/seal final03 N2 stage capture with the exact SERIAL runtime policy.

Metadata/source materialization only; generated jobs are root-owned target work.
"""
import argparse,copy,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from owners import parse_qbe_owners
from stages_v1 import validate_spec
import runtime

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def unique(rows):return list({(r['file'],r['sha256']):r for r in rows}.values())
def module(path,name):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def invoke(m,args):
 old=sys.argv
 try:sys.argv=[m.__file__,*map(str,args)];m.main()
 finally:sys.argv=old

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','seal']);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 output required')
 qualification_path=ROOT/'selfhost/build/phase144/final03-plan/plan.json';qualification=read(qualification_path)
 build_path=ROOT/'selfhost/build/phase134/p144-final03-n2/report.json';built=read(build_path)
 q3_path=ROOT/'selfhost/build/phase130/p144-final03-q3/report.json';q3=read(q3_path)
 source=qualification['sourceAdmission']['source'];need(source['sha256']=='31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2','Unexpected final source')
 need(built['complete'] and built['compilerExitCode']==built['qbeExitCode']==0 and all(j['exitCode']==0 for j in built['jobs']),'N2 acquisition failed')
 need(built['source']==source and built['runtime']==qualification['runtime'],'N2 source/actual linked runtime mismatch')
 need(q3['complete'] and q3['byteExact'] and q3['image']==built['binary'] and q3['source']==source and all(q3['product'][k]==built['retainedIR'][k] for k in ['bytes','sha256']),'Q2/Q3 reproduction missing')
 serial_path=ROOT/'selfhost/build/phase144/serial-rfc01/manifest.json';serial=read(serial_path)
 serial_files={Path(p['file']).name:p for p in serial['outputs']};serial_source=Path(verify(serial_files['runtime.c']))
 transform_path=ROOT/'selfhost/tools/performance/phase144/serial-rfc/prepare-v01.py';transform=module(transform_path,'serial_source_transform')
 original=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.c'
 need(transform.transform(original.read_text())==serial_source.read_text(),'Serial runtime no longer exact reviewed transformation')
 mode=next(j['argv'] for j in serial['commands'] if j['label']=='serial-rfc-compile')
 need('-DP144_SINGLE_MUTATOR_RFC=1' in mode and built['runtime']['file']==mode[-1],'Serial compilation mode/object mismatch')
 checked=read(qualification['sourceAdmission']['checkedApi']['file']);need(checked['complete'] and checked['checked'] and source in checked['inputs'],'Final exact source not independently checked')
 pilot_path=ROOT/'selfhost/build/phase144/final03-hosted-b01/report.json';pilot=read(pilot_path)
 need(pilot['complete'] and pilot['verified'] and pilot['compilerSource']==source,'Checked final Lexer revision oracle missing')
 generic_path=ROOT/'selfhost/build/phase144/generic-gate01/qualification.json';generic=read(generic_path)
 need(generic['complete'] and generic['genericRuntimeExecuted'],'Generic native marker qualification missing')
 inherited=[pin(__file__),pin(qualification_path),*all_pins(qualification),pin(build_path),*built['inputs'],built['binary'],built['object'],built['retainedIR'],pin(q3_path),q3['product'],pin(serial_path),*serial['inputs'],*serial['outputs'],pin(transform_path),pin(pilot_path),*all_pins(pilot),pin(generic_path),*generic['inputs'],generic['sampler']]
 for item in inherited:verify(item)
 if a.action=='prepare':
  need(not out.exists(),'Fresh output required');out.mkdir(parents=True)
  owners=parse_qbe_owners(built['retainedIR']['file']);save(out/'owners.json',owners)
  oldspec_path=ROOT/'selfhost/build/phase144/integrated-stages01/spec.json';spec=copy.deepcopy(read(oldspec_path));spec['ownerMap']=pin(out/'owners.json');spec['programObject']=built['object']
  for marker in spec['markers']:
   matches=[r for r in owners['fids'] if r['decoded']=='$direct.'+marker['label'] and r['role']=='direct_segment'];need(len(matches)==1,'Final exact stage absent: '+marker['label']);marker.update(fid=matches[0]['fid'],symbol=matches[0]['symbol'])
  spec['scope']='Final03 N2 source31e1b13a; exact direct dispatch entries with reviewed serial reference counts. Optional markers retain original multiplicity. No source01 timing is relabeled.';validate_spec(spec,owners);save(out/'spec.json',spec)
  base_manifest=dict(runtime=serial_files['runtime.c'],headers=[serial_files[n] for n in ['runtime.h','primitives.h']],compiler=mode[0],linker=mode[0],compileFlags=mode[1:mode.index('-c')],programObject=built['object'])
  save(out/'serial-runtime-input.json',base_manifest)
  invoke(runtime,['--manifest',out/'serial-runtime-input.json','--out',out/'base-runtime'])
  diagnostic=out/'base-runtime/runtime.c';diagnostic_text=diagnostic.read_text();recovered=diagnostic_text
  for edit in reversed(read(out/'base-runtime/edits.json')):recovered=recovered.replace(edit['diagnostic'],edit['original'],1)
  need(recovered.encode()==serial_source.read_bytes(),'Diagnostics do not reverse to exact serial runtime')
  # Stronger commuting check: the reviewed serial change applied to the known
  # original diagnostic source yields these same bytes, preserving every hook.
  old_diag=ROOT/'selfhost/build/phase131/context01/runtime/runtime.c'
  need(transform.transform(old_diag.read_text())==diagnostic_text,'Serial and diagnostic deltas do not commute')
  builder=module(PROF/'stages-build-v1.py','generic_stage_builder')
  invoke(builder,['--spec',out/'spec.json','--runtime-plan',out/'base-runtime/plan.json','--sampler-build',ROOT/'selfhost/build/phase127/sampler-cfi03/report.json','--out',out/'runtime'])
  plan=read(out/'runtime/plan.json');need(len(plan['jobs'])==3 and '-DP144_SINGLE_MUTATOR_RFC=1' in plan['jobs'][1]['command'],'Stage builder lost serial mode')
  oldsampler=Path(generic['sampler']['file']).parent
  for name in ['sample.c','unwind-table.h']:need((out/'runtime'/name).read_bytes()==(oldsampler/name).read_bytes(),'Ordinal sampler differs')
  plan['jobs']=plan['jobs'][1:];plan['inputs']=unique([*plan['inputs'],*inherited,pin(out/'runtime/plan.json'),generic['sampler']]);plan['reusedSampler']=generic['sampler'];plan['scope']+=' Exact serial mode1, runtime reverse/commutation checks passed; only compile diagnostic runtime and relink final03 N2 retained object.';save(out/'runtime/plan-reuse.json',plan)
  save(out/'ready.json',dict(complete=True,targetsRun=False,source=source,programObject=built['object'],cleanRuntime=built['runtime'],serialSource=serial_files['runtime.c'],serialCompileFlags=base_manifest['compileFlags'],diagnosticReverseExact=True,serialDiagnosticDeltasCommute=True,inputs=unique(inherited+[pin(oldspec_path),pin(old_diag),pin(out/'runtime/plan-reuse.json')]),coldOraclePending=str(ROOT/'selfhost/build/phase130/p144-final03-fixed-cold01/report.json')))
 else:
  need(not(out/'manifest.json').exists(),'Fresh seal required');ready=read(out/'ready.json');plan=read(out/'runtime/plan-reuse.json');actual=read(out/'build/report.json')
  need(actual['complete'] and actual['plan']==pin(out/'runtime/plan-reuse.json') and len(actual['jobs'])==2,'Actual diagnostic runtime build failed')
  for want,have in zip(plan['jobs'],actual['jobs']):need(want['command']==have['command'] and have['returncode']==0 and not have['timedOut'],'Build command/status differs');verify(have['product'])
  need('-DP144_SINGLE_MUTATOR_RFC=1' in actual['jobs'][0]['command'] and actual['jobs'][1]['command'][2]==built['object']['file'],'Actual serial mode or N2 object mismatch')
  cold_path=ROOT/'selfhost/build/phase130/p144-final03-fixed-cold01/report.json';cold=read(cold_path)
  need(cold['complete'] and cold['exitCode']==0 and not cold['changedInputs'] and cold['image']==built['binary'] and cold['source']['sha256']=='15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1','Final clean frozen142 request not ready')
  image=actual['jobs'][-1]['product'];prior_path=ROOT/'selfhost/build/phase144/integrated-stages01/manifest.json';manifest=copy.deepcopy(read(prior_path));manifest['ownerMap']=pin(out/'owners.json');manifest['nativeStageSpec']=pin(out/'spec.json');manifest['sampler']=generic['sampler'];manifest['diagnosticImage']=image
  small=copy.deepcopy(manifest['workloads'][0]);small['name']='lexer-revision-stage-pilot';v=small['variants'][0];v['name']='phase144-final03-n2-serial-stages';v['command']=list(cold['command']);v['command'][7]=pilot['request']['source']['file'];v['command'][0]=image['file'];v['binary']=image;v['expected']['stdout']=dict(kind='exact',**{k:pilot['qbe'][k] for k in ['bytes','sha256']})
  full=copy.deepcopy(small);full['name']='fixed-phase142-source';full['timeoutSeconds']=600;fv=full['variants'][0];fv['command']=list(cold['command']);fv['command'][0]=image['file'];fv['expected']['stdout']=dict(kind='exact',**{k:cold['product'][k] for k in ['bytes','sha256']})
  for work in [small,full]:work['variants'][0]['inputs']=[pin(x) for x in work['variants'][0]['command'] if Path(x).is_file()]
  manifest['workloads']=[small,full];manifest.pop('cleanComparison',None);manifest['lineage']=dict(source=source,cleanImage=built['binary'],programObject=built['object'],cleanRuntime=built['runtime'],diagnosticRuntime=actual['jobs'][0]['product'],runtimePolicy='Exact reviewed serial RFC mode1; one Bend heap mutator',n2Build=pin(build_path),q2q3=pin(q3_path),nativeQualifiedByProfile=False,installed=False)
  manifest['inputs']=unique([*inherited,*ready['inputs'],pin(out/'ready.json'),pin(out/'spec.json'),pin(out/'owners.json'),pin(out/'runtime/plan-reuse.json'),pin(out/'build/report.json'),*plan['outputs'],*actual['products'],pin(cold_path),*cold['inputs'],cold['product'],pilot['qbe']]);manifest['scope']='Fresh final03 N2 SERIAL runtime profile; output replay oracle from same-image clean fixed142 request, small checked-hosted Lexer revision oracle. Not a clean timing or new qualification.'
  for item in all_pins(manifest):verify(item)
  save(out/'manifest.json',manifest)
 if a.action=='prepare':
  guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
  def guarded(label,seconds,command):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*command]
  def capture(name,label,seconds,period):return guarded(label,seconds,[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/label),'--names',name,'--modes','sample','--rounds','1','--periods-us',str(period)])
  def observe(label):return [sys.executable,'-B',str(PROF/'stages_v1.py'),'observe','--spec',str(out/'spec.json'),'--run',str(out/label/'report.json'),'--out',str(out/(label+'-stages.json'))]
  jobs=[dict(name='compile-serial-marker-runtime-and-link-final-N2',command=guarded('build',60,[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan-reuse.json'),'--out',str(out/'build')])),dict(name='seal-after-clean-fixed142-receipt-exists',command=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--out',str(out)]),dict(name='checked-Lexer-revision-small-gate',command=capture('lexer-revision-stage-pilot','pilot',55,8000)),dict(name='require-small-marker-and-byte-gate',command=observe('pilot')),dict(name='full-frozen142-capture',command=capture('fixed-phase142-source','capture',660,32000)),dict(name='offline-full-stages',command=observe('capture'))]
  save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(out/'ready.json')],jobs=jobs,gate='Root serial lane only. Seal requires completed final03 clean fixed142 receipt. Do not run full capture unless small exact bytes and marker admission pass.'))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
