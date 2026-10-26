#!/usr/bin/env python3
"""Prepare/seal runtime-only exact stage boundaries plus sampled ordinals."""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins

def read(p):return json.loads(Path(p).read_text())
def need(v,s):
 if not v:raise ValueError(s)
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','seal']);ap.add_argument('--profile',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();profile=a.profile.resolve();out=a.out.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase144'),'Phase144 output required')
 template=read(profile/'template.json');owners=read(profile/'owners.json')
 for p in all_pins(template):verify(p)
 names=['p88_cache_prepare','p86_plan','p86_plan_loaded','p86_plan_checked','p86_plan_reported','p86_plan_owned','p86_plan_entry','p86_plan_context','p86_plan_annotated','nr_prepare_annotated','p134e_plan','p128raw_lower_request','p128raw_prepared','p128raw_plan_finish','p128raw_session_finish','p128raw_lowered','p128raw_verified','p128raw_br_prepare','p128raw_br_scanned','p134w_plan','p134e_begin','p134e_registered','p134w_drain']
 labels=['Base preparation','parse/load','checking/publication','proof report','owned/foreign eligibility','main eligibility','checked context','annotation/reach','layout check','erasure/finalization','runtime admission/certificate','static preparation','raw generic/private lowering','initial private admission','initial optimizer','first independent verifier','observer permission','observer discovery','observer composition and selected final admission','output opening','registry preparation','registry finalization']
 final_entry=next(r for r in owners['fids'] if r['decoded']=='$direct.p126bp_complete' and r['role']=='direct_segment')
 markers=[]
 for name in names:
  hits=[r for r in owners['fids'] if r['decoded']=='$direct.'+name and r['role']=='direct_segment'];need(len(hits)==1,'Missing unique direct marker '+name)
  r=hits[0];markers.append(dict(label=name,fid=r['fid'],symbol=r['symbol'],firstEntryBoundary=name=='p134w_drain'))
 old=ROOT/'selfhost/build/phase131/context01';cfi=ROOT/'selfhost/build/phase127/sampler-cfi03';oldplan=read(old/'runtime/plan.json');cfibuild=read(cfi/'report.json')
 support=Path(verify(pin(PROF/'runtime-support.inc.c'))).read_text();need(support==(old/'runtime/runtime-support.inc.c').read_text(),'Runtime support changed')
 deltas=[('static inline void bend_profile_count(unsigned event, uint64_t amount) {','#include "stages.inc.c"\n\nstatic inline void bend_profile_count(unsigned event, uint64_t amount) {'),('  bend_profile_count(BP_DISPATCH, 1);','  bend_stage_enter(fid);\n  bend_profile_count(BP_DISPATCH, 1);'),('  bp_functions = functions;','  bp_functions = functions;\n  bend_stage_initialize(segments, functions);')]
 changed=support
 for before,after in deltas:need(changed.count(before)==1,'Unique runtime insertion required');changed=changed.replace(before,after,1)
 reverse=changed
 for before,after in reversed(deltas):reverse=reverse.replace(after,before,1)
 need(reverse==support,'Runtime delta not reversible')
 sampler=(cfi/'sample.c').read_text();point='_Noreturn static void fail(const char *message) {'
 getter='__attribute__((visibility("default"), noinline))\nuint32_t bend_sample_delivered_count(void) {\n  return output_fd < 0 ? UINT32_MAX : atomic_load_explicit(&sample_count, memory_order_acquire);\n}\n\n'
 need(sampler.count(point)==1,'Unique sampler insertion required');new_sampler=sampler.replace(point,getter+point,1);need(new_sampler.replace(getter,'',1)==sampler,'Sampler delta not reversible')
 if a.action=='prepare':
  need(not out.exists(),'Fresh stage directory required');out.mkdir(parents=True);rdir=out/'runtime';rdir.mkdir()
  (rdir/'runtime.c').write_bytes((old/'runtime/runtime.c').read_bytes());(rdir/'runtime-support.inc.c').write_text(changed);(rdir/'stages.inc.c').write_bytes(Path(__file__).with_name('stages-v02.inc.c').read_bytes());(rdir/'sample.c').write_text(new_sampler);(rdir/'unwind-table.h').write_bytes((cfi/'unwind-table.h').read_bytes())
  origin=read(old/'runtime-input.json')
  for h in origin['headers']:(rdir/Path(h['file']).name).write_bytes(Path(verify(h)).read_bytes())
  n=len(markers);mx=max(m['fid'] for m in markers);need(n<=32 and mx<len(owners['fids']),'Bounded exact map required')
  header=f'#include <stdint.h>\n#define BS_COUNT {n}u\n#define BS_MAX_FID {mx}u\n#define BS_SEGMENTS {len(owners["fids"])}u\n'
  header+=f'#define BS_FINAL_FID {final_entry["fid"]}u\n'
  header+='static const uint8_t bs_rank[BS_MAX_FID+1]={'+','.join(f'[{m["fid"]}]={i+1}' for i,m in enumerate(markers))+'};\n'
  header+='static const uint32_t bs_fids[BS_COUNT]={'+','.join(str(m['fid']) for m in markers)+'};\n'
  header+='static const uint8_t bs_first_only[BS_COUNT]={'+','.join('1' if m['firstEntryBoundary'] else '0' for m in markers)+'};\n'
  header+='static const char *const bs_labels[BS_COUNT]={'+','.join(json.dumps(m['label']) for m in markers)+'};\n';(rdir/'stages-map.h').write_text(header)
  jobs=copy.deepcopy(oldplan['jobs']);jobs[0]['command']=[s.replace(str(old/'runtime'),str(rdir)) for s in jobs[0]['command']];jobs[1]['command'][2]=template['lineage']['programObject']['file'];jobs[1]['command'][3]=str(rdir/'runtime.o');jobs[1]['command'][-1]=str(rdir/'program');jobs[1]['command'].insert(-2,'-ldl')
  sampler_cmd=[s.replace(str(cfi),str(rdir)).replace(str(cfi/'sampler.so'),str(rdir/'sampler.so')) for s in cfibuild['command']]
  jobs.insert(0,dict(label='ordinal-sampler',command=sampler_cmd))
  inputs=[pin(__file__),pin(Path(__file__).with_name('stages-v02.inc.c')),pin(profile/'template.json'),pin(profile/'owners.json'),*template['inputs'],pin(old/'runtime/plan.json'),pin(old/'runtime/runtime.c'),pin(PROF/'runtime-support.inc.c'),pin(cfi/'report.json'),pin(cfi/'sample.c'),pin(cfi/'unwind-table.h'),*origin['headers']]
  outputs=[pin(p) for p in rdir.iterdir() if p.is_file()]
  save(rdir/'plan.json',dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=outputs,jobs=jobs,scope='Exact retained compiler object; reversible diagnostic-only sampler getter and runtime markers. Signal handler unchanged.'))
  save(out/'stage-plan.json',dict(kind='phase144-sampled-stage-plan',complete=True,targetsRun=False,plan=pin(rdir/'plan.json'),template=pin(profile/'template.json'),ownerMap=pin(profile/'owners.json'),markers=markers,intervalLabels=labels,inputs=inputs,outputs=outputs,expectedSegments=len(owners['fids']),conditionalFinalVerifier=final_entry,policy='22 unique ordered markers plus first render drain. Optional p126bp_complete is recorded separately, never required on branches that do not call it; all its entries are counted, first8 retained.'))
 else:
  need(not(out/'manifest.json').exists(),'Unsealed stage plan required');stage=read(out/'stage-plan.json');build=read(out/'build/report.json');plan=read(out/'runtime/plan.json')
  need(build['complete'] and build['plan']==pin(out/'runtime/plan.json') and len(build['jobs'])==3,'Stage build incomplete')
  for want,have in zip(plan['jobs'],build['jobs']):need(want['command']==have['command'] and have['returncode']==0 and not have['timedOut'],'Stage build command/status differs');verify(have['product'])
  manifest=copy.deepcopy(template);manifest['sampler']=build['jobs'][0]['product'];binary=build['jobs'][-1]['product'];full=manifest['workloads'][0];v=full['variants'][0];v['name']='phase143-n2-stages';v['binary']=binary;v['command'][0]=binary['file'];v['inputs']=[pin(p) for p in v['command'] if Path(p).is_file()]
  small=read(ROOT/'selfhost/build/phase130/p143-milestone-lexer02/report.json');need(small['complete'],'Small independent product missing');pilot=copy.deepcopy(full);pilot['name']='lexer-stage-pilot';pilot['timeoutSeconds']=35;pv=pilot['variants'][0];pv['command']=list(small['command']);pv['command'][0]=binary['file'];pv['inputs']=[pin(p) for p in pv['command'] if Path(p).is_file()];pv['expected']['stdout']={k:small['expectedQbe'][k] for k in ['bytes','sha256']};pv['expected']['stdout']['kind']='exact'
  manifest['workloads']=[pilot,full];manifest['inputs']+=[pin(out/'stage-plan.json'),pin(out/'runtime/plan.json'),pin(out/'build/report.json'),*plan['outputs'],*build['products'],small['source'],small['expectedQbe'],pin(ROOT/'selfhost/build/phase130/p143-milestone-lexer02/report.json')];manifest['stagePlan']=pin(out/'stage-plan.json');manifest['scope']+=' Exact native stage clocks/ordinals are diagnostic; boundaries require separate complete sidecar validation.'
  for item in all_pins(manifest):verify(item)
  save(out/'manifest.json',manifest)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 def guarded(label,sec,cmd):return [sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(sec),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*cmd]
 def run(name,outname,sec,period):return guarded(outname,sec,[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/outname),'--names',name,'--modes','sample','--rounds','1','--periods-us',str(period)])
 jobs=[dict(name='build-small-profiler-and-relink',command=guarded('build',60,[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(out/'runtime/plan.json'),'--out',str(out/'build')])),dict(name='seal',command=[sys.executable,'-B',str(Path(__file__).resolve()),'seal','--profile',str(profile),'--out',str(out)]),dict(name='small-marker-falsifier',command=run('lexer-stage-pilot','pilot',55,8000)),dict(name='validate-pilot-before-full',command=[sys.executable,'-B',str(Path(__file__).with_name('stage-report-v02.py')),'--plan',str(out/'stage-plan.json'),'--run',str(out/'pilot/report.json'),'--out',str(out/'pilot-stages.json')]),dict(name='full-only-after-valid-pilot',command=run('fixed-phase142-source','capture',660,32000)),dict(name='offline-full-stage-profile',command=[sys.executable,'-B',str(Path(__file__).with_name('stage-report-v02.py')),'--plan',str(out/'stage-plan.json'),'--run',str(out/'capture/report.json'),'--out',str(out/'stage-profile.json')])]
 if a.action=='prepare':save(out/'jobs.json',dict(complete=True,targetsRun=False,jobs=jobs,gate='Stop before full capture if small marker order/identity fails. No clean throughput claim.'))
 print(json.dumps(dict(complete=True,targetsRun=False,action=a.action,out=str(out))))
if __name__=='__main__':main()
