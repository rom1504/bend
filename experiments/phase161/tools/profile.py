#!/usr/bin/env python3
"""Reuse a frozen compiler object; refine only diagnostic stage boundaries."""
import argparse, importlib.util, json, os, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('candidate',ROOT/'experiments/phase147/tools/profile-candidate.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
P=ROOT/'selfhost/build/phase153/prep01'
N=ROOT/'selfhost/build/phase161/profile-prep04'
B=ROOT/'selfhost/build/phase161/profile-build03'

def prepare():
    old=C.read(P/'ready.json')
    for row in old['inputs']:C.verify(row)
    proposal=C.read(ROOT/'experiments/phase161/lowering-stage-proposal.json')
    for key in ['oldSpec','ownerMap','programObject','unwindTable','qbe']:C.verify(proposal[key])
    stage=C.read(P/'spec.json');order=stage['requiredOrder']
    start=order.index('p144o_prepared');end=order.index('p128raw_session_finish')+1
    C.need(order[start:end]==['p144o_prepared','p128raw_plan_finish','p128raw_session_finish'],'Unexpected original order')
    stage['requiredOrder']=order[:start]+proposal['replaceRequiredSubsequence']+order[end:]
    intervals=stage['intervals'];first=intervals.index(proposal['replaceIntervals'][0])
    C.need(intervals[first:first+2]==proposal['replaceIntervals'],'Unexpected original intervals')
    stage['intervals']=intervals[:first]+proposal['newDisjointIntervals']+intervals[first+2:]
    stage['markers'] += [{k:r[k] for k in ['label','multiplicity','fid','symbol']} for r in proposal['addedMarkers']]
    by_name={r['label']:r for r in stage['markers']}
    stage['markers']=[by_name[n] for n in stage['requiredOrder']]+[r for r in stage['markers'] if r['multiplicity']=='optional']
    from stages_v1 import validate_spec
    validate_spec(stage,C.read(P/'owners.json'))
    stage['boundaryDerivation']=C.pin(ROOT/'experiments/phase161/lowering-stage-proposal.json')
    stage['scope']='Same authenticated Phase152 object as Phase153; six finer lowering boundaries; fresh pilot order/output admission required.'
    N.mkdir(parents=True,exist_ok=False)
    # Read-only aliases, never modify the authenticated shared files.
    for name in ['owners.json','source-owners.json','runtime-input.json','base-runtime/plan.json','unwind/table.json','unwind/unwind-table.h','inputs/assets-native.json']:
        dst=N/name;dst.parent.mkdir(parents=True,exist_ok=True);os.link(P/name,dst)
    stage['unwindTable']=C.pin(N/'unwind/table.json')
    C.save(N/'spec.json',stage)
    ready={**old,'spec':C.pin(N/'spec.json'),'inputs':old['inputs']+[C.pin(__file__),C.pin(P/'ready.json'),C.pin(N/'spec.json'),C.pin(ROOT/'experiments/phase161/lowering-stage-proposal.json')]}
    C.save(N/'ready.json',ready)

ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('action',choices=['prepare','build','pilot','full','closure'])
ap.add_argument('--out',type=Path)
a=ap.parse_args()
if a.action=='prepare':prepare()
elif a.action=='build':C.build(N,B)
else:
    C.need(a.out is not None,'Capture output required')
    if a.action=='pilot':
        src=ROOT/'selfhost/tools/performance/programs/fixtures/test-map-set-ops.bend'
        C.need(src.is_file(),'Explicit pilot source missing')
        oracle=None
    else:
        receipt=C.read(ROOT/'selfhost/build/phase161'/('full01' if a.action=='full' else 'closure01')/'report.json')
        src=C.verify(receipt['source']);oracle=C.verify(receipt['product'])
    C.capture(N,B,a.out.resolve(),src,oracle,32000,a.action=='pilot')
    # After exact-output admission, reuse original immutable bytes to limit disk.
    report=C.read(a.out/'capture/report.json')
    if oracle:
        for row in report.get('rows',[]):
            process=row.get('process',row)
            value=process.get('stdout')
            if isinstance(value,dict) and value.get('file'):
                path=C.verify(value)
                if path!=oracle and C.same(C.pin(path),C.pin(oracle)):
                    C.need(path.read_bytes()==oracle.read_bytes(),'Output comparison differs')
                    C.save(a.out/'dedup-intent.json',dict(output=C.pin(path),oracle=C.pin(oracle)))
                    path.unlink();os.link(oracle,path)
                    C.save(a.out/'dedup-result.json',dict(complete=True,output=C.pin(path)))
print(json.dumps(dict(complete=True,action=a.action)))
