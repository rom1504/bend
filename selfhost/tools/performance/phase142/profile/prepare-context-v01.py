"""Authenticate retained N2 objects and plan one diagnostic warm-edit capture.

Metadata/owner-map preparation only. No compiler, assembler, linker or target is
executed. Root executes the recorded build and capture jobs under the guard.
"""
import argparse, importlib.util, json, subprocess, sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
PROF=ROOT/'selfhost/tools/profiler'
sys.path.insert(0,str(PROF))
from run import pin,verify,save
import runtime

def read(p):return json.loads(Path(p).read_text())

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--out',type=Path,required=True);p.add_argument('--capture',type=Path,required=True)
 a=p.parse_args();out=a.out.resolve();capture=a.capture.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase142')
 assert not capture.exists() and capture.is_relative_to(ROOT/'selfhost/build/phase142')
 selection_path=ROOT/'implementation/phase141/candidate.json';selection=read(selection_path)
 assert selection['complete'] and selection['nativeQualified'] and not selection['incrementalQualified']
 build_path=ROOT/'selfhost/build/phase111/p141-integrated-n2/report.json';built=read(build_path)
 assert built['complete'] and built['binary']==selection['n2']==selection['preferredNative']
 qbe=next(x for x in built['inputs'] if x['file'].endswith('/program.ssa'))
 assert built['jobs'][0]['command'][-1]==qbe['file'] and all(x['exitCode']==0 for x in built['jobs'])
 assert built['jobs'][2]['command'][2:4]==[built['object']['file'],selection['runtime']['file']]
 assert pin(selection['source']['file'])==selection['source']
 # The clean and diagnostic runtimes have exact source/header identity, and
 # the old runtime object's completed compile receipt is retained. No old
 # compiler object/link product is needed to reuse that runtime object.
 clean_path=ROOT/'selfhost/build/phase128/runtime-borrow01/report.json';clean=read(clean_path)
 assert clean['complete'] and clean['object']==selection['runtime']
 olddir=ROOT/'selfhost/build/phase131/context01'
 input_path=olddir/'runtime-input.json';old_input=read(input_path)
 plan_path=olddir/'runtime/plan.json';old_plan=read(plan_path)
 report_path=olddir/'build/report.json';old_build=read(report_path)
 assert old_input['runtime']==clean['source']
 assert old_plan['complete'] and old_plan['reverseExact'] and old_build['complete']
 assert old_build['plan']==pin(plan_path)
 compile_job=old_build['jobs'][0]
 assert compile_job['command']==old_plan['jobs'][0]['command'] and compile_job['returncode']==0 and not compile_job['timedOut']
 runtime_object=compile_job['product'];assert runtime_object in old_build['products']
 diagnostic_source=olddir/'runtime/runtime.c'
 reconstructed,edits=runtime.materialize(Path(verify(clean['source'])).read_bytes())
 assert diagnostic_source.read_bytes()==reconstructed
 assert read(olddir/'runtime/edits.json')==edits
 old_outputs={Path(x['file']).name:x for x in old_plan['outputs']}
 for h in old_input['headers']:
  verify(h);assert pin(olddir/'runtime'/Path(h['file']).name)==old_outputs[Path(h['file']).name]
  assert any(x['bytes']==h['bytes'] and x['sha256']==h['sha256'] and Path(x['file']).name==Path(h['file']).name for x in clean['inputs'])
 assert (olddir/'runtime/runtime-support.inc.c').read_bytes()==(PROF/'runtime-support.inc.c').read_bytes()
 # The actual prior N2 batch ran this exact command form and these two source
 # revisions, with full independent QBE oracles. Ordinary qualification alone
 # is not silently extended to batch semantics.
 batch_path=ROOT/'selfhost/build/phase140/product-plan02.json';batch=read(batch_path)
 historical_path=ROOT/'selfhost/build/phase140/p141-full-edit-candidate01/report.json';historical=read(historical_path)
 assert historical['complete'] and historical['independentProductsExact'] and historical['command'][0]==selection['n2']['file']
 assert historical['command'][1:7]==['--threads','1','--gpu','off','--','phase140-batch'] and historical['command'][-1]=='v1'
 assert pin(batch_path) in historical['inputs'] and len(batch['jobs'])==len(historical['jobs'])==2
 assert [j['mode'] for j in batch['jobs']]==['cold','warm']
 for j,h in zip(batch['jobs'],historical['jobs']):
  assert all(j[k]==h[k] for k in ['name','source','hint','owner','mode','expected'])
  assert pin(j['source']) in historical['inputs'] and pin(j['expected']) in historical['inputs']
  assert h['exactOracle'] and pin(j['expected'])['sha256']==h['product']['sha256']
 sampler_path=ROOT/'selfhost/build/phase140/sampler01/report.json';sampler=read(sampler_path)
 assert sampler['complete'] and sampler['returncode']==0
 assert pin(PROF/'sample.c') in sampler['inputs']
 runner=Path(__file__).with_name('run-batch-context-v01.py')
 inputs=[pin(__file__),pin(runner),pin(selection_path),selection['source'],selection['n2'],selection['runtime'],
   pin(build_path),built['object'],qbe,pin(clean_path),clean['source'],pin(input_path),pin(plan_path),pin(report_path),runtime_object,
   *old_input['headers'],*old_plan['outputs'],pin(PROF/'runtime.py'),pin(PROF/'runtime-support.inc.c'),
   pin(batch_path),pin(historical_path),pin(sampler_path),sampler['sampler'],*sampler['inputs'],
   pin(ROOT/'selfhost/tools/performance/phase140/session/run-batch-v02.py'),
   pin(ROOT/'selfhost/tools/performance/phase140/session/run-native-v01.py'),
   pin(ROOT/'selfhost/tools/performance/phase140/session/transport-v02.py'),
   *[pin(j[k]) for j in batch['jobs'] for k in ['source','expected']]]
 for item in inputs:verify(item)
 out.mkdir(parents=True);(out/'runtime').mkdir();(out/'method.py').write_bytes(Path(__file__).read_bytes())
 # owners.py only streams QBE text and writes an authenticated mapping.
 owner_path=out/'owners.json'
 owner_command=[sys.executable,'-B',str(PROF/'owners.py'),'--qbe',qbe['file'],'--output',str(owner_path)]
 subprocess.run(owner_command,check=True,stdout=subprocess.DEVNULL)
 inputs.extend([pin(PROF/'owners.py'),pin(owner_path)])
 link=list(old_plan['jobs'][1]['command']);link[2]=built['object']['file'];link[-1]=str(out/'runtime/program')
 assert link[3]==runtime_object['file']
 link_plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,
  inputs=inputs,outputs=[],jobs=[dict(label='link-diagnostic',command=link)],reusedRuntimeObject=runtime_object,
  scope='Only relink retained exact Phase141 N2 program.o with authenticated existing context-only runtime.o. No QBE generation/assembly, compiler acquisition or selection change.')
 save(out/'runtime/plan.json',link_plan)
 profile=dict(kind='phase142-warm-native-context-plan-v1',complete=True,targetsRun=False,inputs=inputs,
  source=selection['source'],originalImage=selection['n2'],originalObject=built['object'],qbe=qbe,runtime=selection['runtime'],
  diagnosticRuntime=runtime_object,relinkPlan=pin(out/'runtime/plan.json'),relinkCommand=link,
  ownerMap=pin(owner_path),batchPlan=pin(batch_path),samplerReport=pin(sampler_path),historicalExactBatch=pin(historical_path),
  ordinaryNativeQualified=True,batchPreviouslyMeasured=True,incrementalQualified=False,
  estimatedNativeSeconds=[470,600],estimatedNewDiskBytes=450*1024**2,
  timing='Diagnostic only. Existing sample ordinals give approximate CPU coordinates; stage windows use conservative wall/CPU bounds, not exact timestamps or exclusive caller stacks.')
 save(out/'manifest.json',profile)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(name,seconds,cmd):return [sys.executable,'-B',str(guard),'--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--',*cmd]
 build_command=[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan.json'),'--out',str(out/'build')]
 run_command=[sys.executable,'-B',str(runner),'--image',link[-1],'--plan',str(batch_path),'--out',str(capture),'--seconds','700','--sampler-receipt',str(sampler_path),'--period-us','20000','--profile-plan',str(out/'manifest.json'),'--diagnostic-build',str(out/'build/report.json')]
 analyze_command=[sys.executable,'-B',str(Path(__file__).with_name('analyze-context-v01.py')),'--profile-plan',str(out/'manifest.json'),'--capture',str(capture/'report.json'),'--out',str(out/'analysis')]
 
 save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(out/'manifest.json'),pin(runner),pin(guard),pin(PROF/'build-runtime.py'),pin(PROF/'analyze.py'),pin(PROF/'attribute.py'),pin(Path(__file__).with_name('analyze-context-v01.py'))],
  jobs=[dict(name='diagnostic-relink-only',seconds=30,command=guarded('build',30,build_command)),dict(name='cold-plus-warm-context',seconds=750,command=guarded('capture',750,run_command)),
        dict(name='offline-leaf-owner-stage-analysis',seconds=60,command=analyze_command)],
  resourcePlan=dict(cpu=3,rssMiB=3072,availableMiB=16384,fileMiB=128,extraDiskBudgetMiB=450)))
 print(json.dumps(dict(complete=True,targetsRun=False,manifest=pin(out/'manifest.json'),jobs=pin(out/'jobs.json'),owners=pin(owner_path))))

if __name__=='__main__':main()
