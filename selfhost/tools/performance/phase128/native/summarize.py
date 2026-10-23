"""Retain separate controlled timing blocks and explicit native role identities."""
import argparse
import json
from pathlib import Path
from qualify import pin, read, verify, pins, require

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--qualification',type=Path,required=True)
p.add_argument('--block',action='append',required=True,help='Label=complete timing report')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();require(not a.out.exists(),'Fresh report required')
q=read(a.qualification);require(q['complete'] and q['nativeQualified'] and q['byteExact'],'Qualification required')
blocks=[];inputs=[pin(Path(__file__)),pin(Path(__file__).with_name('qualify.py')),pin(a.qualification)]
for spec in a.block:
    label,file=spec.split('=',1);r=read(file)
    require(r['complete'] and r['passed'] and len(r['rows'])==27 and all(x['passed'] for x in r['rows']),'Complete three-round/three-case/three-role block required')
    m=read(verify(r['manifest']))
    require(q['n1'] in list(pins(m)) or q['n2'] in list(pins(m)),'Block does not measure selected compiler')
    for x in r['inputs']:verify(x)
    blocks.append(dict(label=label,report=pin(file),roles=m['roles'],lineage=m.get('lineage'),summary=r['summary']['cache'],buildPolicy=r['buildPolicy'],timingScope=r['timingScope']))
    inputs.append(pin(file))
result=dict(complete=True,nativeQualified=True,source=q['source'],n1=q['n1'],n2=q['n2'],blocks=blocks,inputs=inputs,
    scope='Within-block medians and ratios only. Separate blocks are not pooled. Request and ready child-stage sums have distinct clocks. Native prepared Base/cached runtime versus upstream source Base/full C-runtime build remain explicit. No controlled full-source speedup or recursive-acceleration claim.')
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({b['label']:b['summary']['threeCaseGeometricRatios'] for b in blocks},indent=2))
