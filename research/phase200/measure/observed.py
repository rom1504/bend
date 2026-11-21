"""Recompute paired runtime directly from complete timed streams of the interrupted run."""
import json
from pathlib import Path
import statistics as stats
import sys
root = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(root/'selfhost/tools/bench'))
import bench as b
base = root/'selfhost/build/phase200/candidate-broad02'
raw = b.read(base/'timing/report.json')
manifest = b.read(base/'manifest.json')
products = {c['id']: c for c in manifest['cases']}
for pin in [*raw['inputs'],*manifest['inputs']]: b.verify(pin)
rows = []
seen = 0
for case in raw['cases']:
    spec = products[case['id']]
    point = case['point']
    assert point == spec['point'] and len(case['samples']) == 9
    vals = {r:[] for r in raw['roles']}
    order = []
    for sample in case['samples']:
        role = sample['role']
        p = sample['process']
        product = spec['products'][role]
        b.verify(product['artifact'])
        for stream in ('stdout','stderr'): b.verify(p[stream])
        assert not p['timedOut'] and p['exitCode']==0
        full = dict(point, repetitions=sample['repetitions'],warmups=sample['warmups'])
        cmd = [product['artifact']['file'],*b.native_runtime_arguments(product),str(full['repetitions']),str(full['warmups']),*map(str,point['runtimeArgs'])]
        assert p['command']==cmd
        ms = b.observation(Path(p['stdout']['file']).read_bytes(),Path(p['stderr']['file']).read_bytes(),p['exitCode'],full,p['seconds'])
        assert ms==sample['elapsedMs'] and (not point['ratioEligible'] or ms>=100)
        if point['ratioEligible']: vals[role].append(ms/full['repetitions'])
        order.append(role)
        seen+=1
    assert all(len(set(order[k::3]))==3 and set(order[3*k:3*k+3])==set(vals) for k in range(3))
    if point['ratioEligible']: rows.append(dict(n=point['repetitions'],id=case['id'],**{k:stats.median(v) for k,v in vals.items()}))
assert len(rows)==44 and seen==405 and len(products)==45
out={'kind':'independent timed-stream analysis of incomplete final report','observations':seen,'raw':b.pin(base/'timing/report.json'),'manifest':b.pin(base/'manifest.json'),'guard':b.pin(base.with_name(base.name+'-guard')/'process.json'),'roles':{}}
for k in ('baseline','candidate','c'):
    out['roles'][k]={'overC':stats.geometric_mean(r[k]/r['c'] for r in rows),'seconds':sum(r[k]*r['n'] for r in rows)/1000,'overBaseline':stats.geometric_mean(r[k]/r['baseline'] for r in rows),'above2':sum(r[k]>2*r['c'] for r in rows),'excludingAbsorbing':stats.geometric_mean(r[k]/r['c'] for r in rows if r['id']!='scalar-region-8192')}
print(json.dumps(out['roles']))
b.save(Path(__file__).with_name('observed.json'),out,fresh=True)
