#!/usr/bin/env python3
"""Materialize a versioned stage sampler/runtime build plan; execute nothing.

Reuses an authenticated generic diagnostic runtime plan and CFI sampler receipt.
The caller owns root-lane compilation, independent output checks and qualification.
"""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from run import pin,verify,save
from stages_v1 import validate_spec,map_header,need,read

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['spec','runtime-plan','sampler-build','out']:ap.add_argument('--'+name,type=Path,required=True)
 a=ap.parse_args();out=a.out.resolve();need(not out.exists(),'Fresh output required')
 spec=read(a.spec);owners=read(verify(spec['ownerMap']));validate_spec(spec,owners);program=verify(spec['programObject'])
 base=read(a.runtime_plan);sampler=read(a.sampler_build)
 need(base['schema']=='bend-native-profile-runtime-plan-v1' and base['complete'] and base['reverseExact'],'Authenticated reversible runtime plan required')
 need(sampler['complete'] and sampler['returncode']==0,'Successful sampler build required')
 for item in base['inputs']+base['outputs']+sampler['inputs']+sampler['snapshots']:verify(item)
 outputs={Path(p['file']).name:p for p in base['outputs']};need('runtime.c'in outputs and 'runtime-support.inc.c'in outputs,'Runtime source/support missing')
 support=Path(verify(outputs['runtime-support.inc.c'])).read_text();expected=Path(__file__).with_name('runtime-support.inc.c');need(support==expected.read_text(),'Unsupported runtime hook version')
 edits=[('static inline void bend_profile_count(unsigned event, uint64_t amount) {','#include "stages-runtime-v1.inc.c"\n\nstatic inline void bend_profile_count(unsigned event, uint64_t amount) {'),('  bend_profile_count(BP_DISPATCH, 1);','  bend_stages_v1_enter(fid);\n  bend_profile_count(BP_DISPATCH, 1);'),('  bp_functions = functions;','  bp_functions = functions;\n  bend_stages_v1_initialize(segments, functions);')]
 changed=support
 for before,after in edits:need(changed.count(before)==1,'Runtime hook absent/ambiguous');changed=changed.replace(before,after,1)
 reverse=changed
 for before,after in reversed(edits):reverse=reverse.replace(after,before,1)
 need(reverse==support,'Stage runtime delta not reversible')
 frozen={Path(p['file']).name:p for p in sampler['snapshots']};need('sample.c'in frozen and 'unwind-table.h'in frozen,'CFI sampler snapshots required')
 source=Path(verify(frozen['sample.c'])).read_text();point='_Noreturn static void fail(const char *message) {'
 getter='__attribute__((visibility("default"), noinline))\nuint32_t bend_sample_delivered_count(void) {\n  return output_fd < 0 ? UINT32_MAX : atomic_load_explicit(&sample_count, memory_order_acquire);\n}\n\n'
 need(source.count(point)==1 and 'bend_sample_delivered_count' not in source,'Unsupported ordinal sampler version')
 extended=source.replace(point,getter+point,1);need(extended.replace(getter,'',1)==source,'Sampler delta not reversible')
 table=verify(spec['unwindTable']);need(spec['unwindTable'] in sampler['inputs'],'Sampler/table mismatch')
 compile_job=next(j for j in base['jobs'] if '-c'in j['command']);link_job=next(j for j in base['jobs'] if '-no-pie'in j['command'])
 need(len(base['jobs'])==2 and link_job['command'][1]=='-no-pie','Expected ordinary runtime compile and retained-object link')
 out.mkdir(parents=True)
 for name,p in outputs.items():
  if name not in ('method.py','edits.json'):(out/name).write_bytes(Path(verify(p)).read_bytes())
 (out/'runtime-support.inc.c').write_text(changed);(out/'stages-map-v1.h').write_text(map_header(spec,owners,pin(a.spec)['sha256']))
 runtime=Path(__file__).with_name('stages-runtime-v1.inc.c');(out/runtime.name).write_bytes(runtime.read_bytes());(out/'sample.c').write_text(extended);(out/'unwind-table.h').write_bytes(Path(verify(frozen['unwind-table.h'])).read_bytes())
 cc=copy.deepcopy(compile_job);oldruntime=Path(outputs['runtime.c']['file']).parent;cc['command']=[s.replace(str(oldruntime),str(out)) for s in cc['command']]
 link=copy.deepcopy(link_job);link['command'][2]=str(program);link['command'][3]=str(out/'runtime.o');link['command'][-1]=str(out/'program');link['command'].insert(-2,'-ldl')
 command=list(sampler['command']);oldsource=frozen['sample.c']['file'];oldheader=frozen['unwind-table.h']['file']
 command=[s.replace(oldsource,str(out/'sample.c')).replace(oldheader,str(out/'unwind-table.h')) for s in command];command[command.index('-o')+1]=str(out/'sampler.so')
 need(str(out/'sample.c')in command and any(s=='-DBEND_PROFILE_UNWIND_TABLE="'+str(out/'unwind-table.h')+'"' for s in command),'Pinned CFI compile command missing')
 jobs=[dict(label='stage-ordinal-sampler',command=command),cc,link]
 inputs=[pin(__file__),pin(Path(__file__).with_name('stages_v1.py')),pin(runtime),pin(a.spec),spec['ownerMap'],spec['programObject'],spec['unwindTable'],pin(a.runtime_plan),pin(a.sampler_build),*base['inputs'],*base['outputs'],*sampler['inputs'],*sampler['snapshots']]
 save(out/'stage-edits-v1.json',dict(runtime=[dict(original=x,diagnostic=y) for x,y in edits],sampler=dict(original=point,diagnostic=getter+point),signalHandlerUnchanged=True))
 plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=[pin(p) for p in out.iterdir() if p.is_file()],jobs=jobs,stageSpec=pin(a.spec),sidecarSchema='bend-native-stage-observations-v1',sidecarPath='BEND_SAMPLE_OUT + .stages-v1.json',scope='Versioned diagnostic only; signal handler and generated compiler object unchanged. Root must build, bind actual products into ordinary profiler manifest, and gate exact output/stage order on a small workload first.')
 save(out/'plan.json',plan);print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'))))
if __name__=='__main__':main()
