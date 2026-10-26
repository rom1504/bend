#!/usr/bin/env python3
"""Materialize a reversible runtime-only milestone delta; execute no tools."""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins

def read(p):return json.loads(Path(p).read_text())
def need(value,message):
 if not value:raise ValueError(message)
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--profile',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();profile=a.profile.resolve();out=a.out.resolve()
 need(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase143'),'Fresh Phase143 output required')
 manifest=read(profile/'manifest-v02.json');lineage=manifest['lineage'];owners=read(verify(manifest['ownerMap']))
 need(not lineage['nativeQualified'] and lineage['qbe']['sha256']=='1dca2d0ea568b2e28db87066ed10dbef01a385f4e38dd4d18c99e1074d128643','Exact current image required')
 for p in all_pins(manifest):verify(p)
 old=ROOT/'selfhost/build/phase131/context01';old_plan=read(old/'runtime/plan.json')
 current_support=PROF/'runtime-support.inc.c';before=Path(verify(pin(current_support))).read_text()
 need(before==(old/'runtime/runtime-support.inc.c').read_text(),'Authenticated diagnostic support changed')
 rows=[('include','static inline void bend_profile_count(unsigned event, uint64_t amount) {', '#include "milestones.inc.c"\n\nstatic inline void bend_profile_count(unsigned event, uint64_t amount) {'),
       ('enter','  bend_profile_count(BP_DISPATCH, 1);','  bend_milestone_enter(fid);\n  bend_profile_count(BP_DISPATCH, 1);'),
       ('initialize','  bp_functions = functions;','  bp_functions = functions;\n  bend_milestone_initialize(segments, functions);')]
 text=before;edits=[]
 for label,previous,replacement in rows:
  need(text.count(previous)==1 and replacement not in text,'Unique support insertion required: '+label)
  text=text.replace(previous,replacement,1);edits.append(dict(label=label,original=previous,diagnostic=replacement))
 recovered=text
 for row in reversed(edits):recovered=recovered.replace(row['diagnostic'],row['original'],1)
 need(recovered==before,'Support delta is not reversible')
 names=['p88_cache_prepare','p86_plan','p86_plan_loaded','p86_plan_checked','p86_plan_reported','p86_plan_owned','p86_plan_entry','p86_plan_context','p86_plan_annotated','nr_prepare_annotated','p134e_plan']
 markers=[]
 for name in names:
  found=[x for x in owners['fids'] if x['decoded']=='$direct.'+name and x['role']=='direct_segment']
  need(len(found)==1,'Unique actual direct entry required: '+name)
  markers.append(dict(label=name,fid=found[0]['fid'],symbol=found[0]['symbol']))
 max_fid=max(x['fid'] for x in markers);count=len(markers);segments=len(owners['fids'])
 need(count<=32 and max_fid<segments and segments<=65532,'Bounded milestone table required')
 header='/* Exact current object mapping; no heuristic owner aliases. */\n#include <stdint.h>\n'
 header+=f'#define BM_COUNT {count}u\n#define BM_MAX_FID {max_fid}u\n#define BM_SEGMENTS {segments}u\n'
 header+='static const uint8_t bm_rank[BM_MAX_FID+1] = {'+','.join(f'[{m["fid"]}]={i+1}' for i,m in enumerate(markers))+'};\n'
 header+='static const uint32_t bm_fids[BM_COUNT] = {'+','.join(str(m['fid']) for m in markers)+'};\n'
 header+='static const char *const bm_labels[BM_COUNT] = {'+','.join(json.dumps(m['label']) for m in markers)+'};\n'
 out.mkdir(parents=True);runtime=out/'runtime';runtime.mkdir()
 (runtime/'runtime.c').write_bytes((old/'runtime/runtime.c').read_bytes())
 (runtime/'runtime-support.inc.c').write_text(text)
 (runtime/'milestones.inc.c').write_bytes(Path(__file__).with_name('milestones-v01.inc.c').read_bytes())
 (runtime/'milestones-map.h').write_text(header)
 origin=read(old/'runtime-input.json')
 for h in origin['headers']:(runtime/Path(h['file']).name).write_bytes(Path(verify(h)).read_bytes())
 save(out/'edits.json',edits)
 inputs=[pin(__file__),pin(Path(__file__).with_name('milestones-v01.inc.c')),pin(profile/'manifest-v02.json'),manifest['ownerMap'],lineage['source'],lineage['qbe'],lineage['programObject'],lineage['cleanRuntime'],pin(current_support),pin(old/'runtime/runtime.c'),pin(old/'runtime/plan.json'),*origin['headers']]
 jobs=copy.deepcopy(old_plan['jobs']);jobs[0]['command']=[v.replace(str(old/'runtime'),str(runtime)) for v in jobs[0]['command']]
 jobs[1]['command'][2]=lineage['programObject']['file'];jobs[1]['command'][3]=str(runtime/'runtime.o');jobs[1]['command'][-1]=str(runtime/'program')
 for j in jobs:inputs.append(pin(j['command'][0]))
 outputs=[pin(p) for p in runtime.iterdir() if p.is_file()]
 plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=outputs,jobs=jobs,
  scope='Diagnostic support-only reversible delta; unchanged current compiler object/QBE and unchanged runtime computation. Small exact-output marker-order/uniqueness gate required before full run. No new compiler image qualification.')
 save(runtime/'plan.json',plan)
 save(out/'manifest.json',dict(kind='phase143-optional-native-milestones',complete=True,targetsRun=False,nativeQualified=False,selected=False,inputs=inputs,outputs=outputs,lineage=lineage,markers=markers,expectedSegments=segments,plan=pin(runtime/'plan.json'),environment={'BEND_MILESTONES_OUT':'Fresh dedicated JSON sidecar path; emitted only at process exit. Stdout and successful stderr unchanged.'},limitations=['Sequential one-request command only; no thread-safe or batch attribution claim.','A missing, repeated or reordered direct entry invalidates all stage timings. Private/inlined bypass is a falsifier, not grounds to fabricate a boundary.','Times are dispatch-entry intervals including scheduler/reference-management costs, not exclusive function-body times.','Counters disabled; every dispatch performs a bounded optional rank lookup. Measure overhead before treating timestamps as neutral.']))
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
 build=[sys.executable,'-B',str(PROF/'build-runtime.py'),'--plan',str(runtime/'plan.json'),'--out',str(out/'build')]
 command=[sys.executable,'-B',str(guard),'--out',str(out/'build-guard'),'--seconds','45','--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*build]
 save(out/'jobs.json',dict(complete=True,targetsRun=False,jobs=[dict(name='compile-small-diagnostic-runtime-and-relink-only',command=command)],next='Before any full-source run: use unchanged phase130/native-request.py with this image, an existing small exact-QBE oracle and fresh BEND_MILESTONES_OUT; data-only verify-v01.py must accept all eleven exact ordered unique markers.'))
 print(json.dumps(dict(complete=True,targetsRun=False,out=str(out),markers=count,rankTableBytes=max_fid+1)))
if __name__=='__main__':main()
