"""Report broad runtime, fixed-batch cost and transfer from the same physical run."""
import argparse
import hashlib
import json
import math
from pathlib import Path
from statistics import geometric_mean, mean

def pin(path):
    data=path.read_bytes()
    return {'file':str(path),'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}

def analyze(receipt, partition, output):
    r=json.loads(receipt.read_bytes())
    assert r['complete'] and r['positionBalanced'] and r['fullCatalog']
    families=json.loads(partition.read_bytes())
    cases=r['cases']
    assert len(cases)==45 and {c['id'] for c in cases}==set(families['development']+families['otherFamilies'])
    timed=[c for c in cases if c['summary']['ratioEligible']]
    assert len(timed)==44
    def summarize(rows, role, reference):
        def at(c, arm):
            vals=c['summary']['stats'][arm]
            assert len(vals['samplesMs'])==r['rounds'] and min(vals['samplesMs'])>0
            return vals['medianMs']
        ratios=[at(c,role)/at(c,reference) for c in rows]
        grouped=sorted({c['family'] for c in rows})
        family={g:geometric_mean(q for c,q in zip(rows,ratios) if c['family']==g) for g in grouped}
        batch=lambda c,arm:c['point']['repetitions']*at(c,arm)
        sum_ms=sum(batch(c,role) for c in rows)
        ref_ms=sum(batch(c,reference) for c in rows)
        return {'cases':len(rows),'families':len(family),'geomean':geometric_mean(ratios),
                'familyWeighted':geometric_mean(family.values()),
                'meanPositiveLog':mean(max(0,math.log(x)) for x in ratios),'above1p1':sum(x>1.1 for x in ratios),
                'above2':sum(x>2 for x in ratios),'batchMs':sum_ms,'referenceBatchMs':ref_ms,
                'batchRatio':sum_ms/ref_ms,'positiveExcessMs':sum(max(0,batch(c,role)-batch(c,reference)) for c in rows),
                'byFamily':family}
    subsets={'all':timed,'exceptScalar8192':[c for c in timed if c['id']!='scalar-region-8192'],
             'investigatedFamilies':[c for c in timed if c['id'] in families['development']],
             'otherFamilies':[c for c in timed if c['id'] in families['otherFamilies']]}
    result={'run':pin(receipt),'partition':pin(partition),'method':pin(Path(__file__)),
            'scope':'Cold process startup and compilation excluded. Equal-case geomean, equal-family geomean, and fixed equivalent original repetitions are separate denominators. Development families reflect Bend rules only. Other families were previously profiled; the compact runtime has its own split.',
            'comparisons':{}}
    roles=set(r['roles'])
    assert {'c','phase197','candidate','live'}==roles
    for role,base in [('phase197','c'),('candidate','c'),('live','c'),('candidate','phase197'),('live','candidate')]:
        result['comparisons'][role+'/'+base]={k:summarize(rows,role,base) for k,rows in subsets.items()}
    output.write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('run',type=Path);p.add_argument('out',type=Path)
    a=p.parse_args();analyze(a.run,Path(__file__).with_name('transfer.json'),a.out)
