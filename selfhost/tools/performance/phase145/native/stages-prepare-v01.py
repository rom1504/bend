#!/usr/bin/env python3
"""Prepare existing generic stage hooks with current exact FIDs; no targets."""
import argparse,copy,gzip,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save
from stages_v1 import validate_spec,map_header
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145')
basepath=ROOT/'selfhost/build/phase145/native-accounting02/plan.json';base=json.loads(basepath.read_text());assert base['complete'] and base['reverseExact']
for x in base['inputs']+base['outputs']:verify(x)
with gzip.open(base['ownerMap']['file'],'rt') as f:owners=json.load(f)
priorpath=ROOT/'selfhost/build/phase144/final03-stages01/spec.json';prior=json.loads(priorpath.read_text());by={x['decoded']:x for x in owners['fids']};markers=[];omitted=[]
for row in prior['markers']:
 current=by.get('$direct.'+row['label'])
 if not current:
  assert row['multiplicity']=='optional';omitted.append(dict(label=row['label'],reason='No exact current direct segment'));continue
 assert current['role']=='direct_segment';markers.append(dict(row,fid=current['fid'],symbol=current['symbol']))
names={x['label'] for x in markers};intervals=[x for x in prior['intervals'] if x['begin'] in names and x['end'] in names|{'@exit'}]
oldmanifestpath=ROOT/'selfhost/build/phase144/final03-stages01/manifest.json';oldmanifest=json.loads(oldmanifestpath.read_text());sampler=oldmanifest['sampler'];verify(sampler)
out.mkdir(parents=True);save(out/'owners.json',dict(fids=owners['fids'],compilerSource=owners['compilerSource'],qbe=owners['qbe'],source=base['ownerMap'],scope='Exact full dispatch owner rows; functions omitted because stage clocks use only FIDs.'))
spec=dict(schema='bend-native-stage-spec-v1',ownerMap=pin(out/'owners.json'),programObject=base['programObject'],unwindTable=prior['unwindTable'],markers=markers,requiredOrder=[x['label'] for x in markers if x['multiplicity']!='optional'],intervals=intervals,omitted=omitted,priorSpec=pin(priorpath));validate_spec(spec,owners);save(out/'spec.json',spec)
support=(PROF/'runtime-support.inc.c').read_text();edits=[('static inline void bend_profile_count(unsigned event, uint64_t amount) {','#include "stages-runtime-v1.inc.c"\n\nstatic inline void bend_profile_count(unsigned event, uint64_t amount) {'),('  bend_profile_count(BP_DISPATCH, 1);','  bend_stages_v1_enter(fid);\n  bend_profile_count(BP_DISPATCH, 1);'),('  bp_functions = functions;','  bp_functions = functions;\n  bend_stages_v1_initialize(segments, functions);')];changed=support
for old,new in edits:assert changed.count(old)==1;changed=changed.replace(old,new,1)
back=changed
for old,new in reversed(edits):assert back.count(new)==1;back=back.replace(new,old,1)
assert back==support
for name in ['runtime.c','runtime.h','primitives.h']:(out/name).write_bytes((basepath.parent/name).read_bytes())
(out/'runtime-support.inc.c').write_text(changed);(out/'stages-map-v1.h').write_text(map_header(spec,owners,pin(out/'spec.json')['sha256']));(out/'stages-runtime-v1.inc.c').write_bytes((PROF/'stages-runtime-v1.inc.c').read_bytes());save(out/'stage-edits.json',edits)
jobs=copy.deepcopy(base['jobs'])
for job in jobs:job['command']=[x.replace(str(basepath.parent),str(out)) for x in job['command']]
jobs[1]['command'].insert(-2,'-ldl')
inputs=[pin(__file__),pin(PROF/'stages-build-v1.py'),pin(PROF/'stages_v1.py'),pin(PROF/'stages-runtime-v1.inc.c'),pin(basepath),pin(priorpath),pin(oldmanifestpath),sampler,*base['inputs'],*base['outputs']]
for x in inputs:verify(x)
plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=[pin(out/n) for n in ['owners.json','spec.json','runtime.c','runtime.h','primitives.h','runtime-support.inc.c','stages-map-v1.h','stages-runtime-v1.inc.c','stage-edits.json']],jobs=jobs,cases=base['cases'],stageSpec=pin(out/'spec.json'),sampler=sampler,base=base['base'],carrier=base['carrier'],stamp=base['stamp'],compilerSource=base['compilerSource'],programObject=base['programObject'],scope='Existing generic stage observer and retained sampler, exact final04 object/FIDs, serial runtime. Three short ordinary requests; no full source capture or counter-enabled timing.')
save(out/'plan.json',plan);print(json.dumps(dict(complete=True,plan=pin(out/'plan.json'),markers=len(markers),omitted=omitted,targetsRun=False)))
