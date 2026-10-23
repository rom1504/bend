#!/usr/bin/env python3
"""Authenticate observed native-entry counts for the duplicated preparation hypothesis."""
import argparse
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
import attribute
from run import pin,save,verify

TARGETS=['p112s_prepare','p113pl_candidates','p113pl_inspect_request',
         'p113pl_inspect_prepared','p126bp_close','p113d_passes','p118t_original_done']


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--run',type=Path,required=True);p.add_argument('--owners-dir',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh result required')
    report=json.loads(a.run.read_text());assert report['complete']and report['passed']
    result=dict(complete=False,inputs=[pin(__file__),pin(a.run),pin(attribute.__file__)],rows=[],
        interpretation='Observed direct-segment dispatcher entries only, not all source invocations. Selected source call graph distinguishes repeated lowering preparation from Base-carrier decoding.')
    for row in report['rows']:
        if row['mode']!='events':continue
        variant=row['variant'].removesuffix('-diagnostic')
        owners=a.owners_dir/(variant+'-owners01.json')
        analyzed=attribute.attribute_events(row['events']['file'],row['command'][0],owners)
        assert analyzed['quality']['usableCounts']and analyzed['pairing']['verified']
        counts={r['loweredOwner']:r['dispatches']for r in analyzed['entrySegmentDispatches']if r['role']=='direct_segment'}
        result['rows'].append(dict(workload=row['workload'],variant=variant,
            counts={name:counts.get(name,0)for name in TARGETS},identities=analyzed['identities'],
            ownerBinding=analyzed['ownerBinding']))
    for r in result['inputs']:verify(r)
    result['complete']=True;save(a.out,result)
    print(json.dumps(dict(complete=True,rows=len(result['rows']))))


if __name__=='__main__':main()
