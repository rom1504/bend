"""Condense only completed, authenticated runtime-library comparisons."""
from pathlib import Path
import argparse
import hashlib
import json
import statistics

def pin(path):
    p=Path(path).resolve()
    return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}

def verify(item):
    if pin(item['file'])['sha256']!=item['sha256']:raise ValueError('input changed: '+item['file'])

p=argparse.ArgumentParser();p.add_argument('run',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=json.loads((a.run/'report.json').read_text());g=json.loads(a.run.with_name(a.run.name+'-guard').joinpath('process.json').read_text())
assert r['complete'] and g['complete'] and g['returncode']==0 and len(r['rows'])==7 and r['rounds']==5
for item in r['pins']:verify(item)
for b in r['builds'].values():verify(b['object'])
out={'complete':True,'scope':'Seven prespecified cases. Ratios of paired in-program elapsed times; 5 rotated positions. Same generated program objects and equal repetitions within each case; different link placements possible.',
     'method':pin(__file__),'receipt':pin(a.run/'report.json'),'guard':pin(a.run.with_name(a.run.name+'-guard')/'process.json'),
     'seconds':r['seconds'],'runtimeObjects':{k:v['object'] for k,v in r['builds'].items()},'cases':[]}
for c in r['rows']:
    verify(c['programObject']);verify(c['baseline'])
    assert c['binaries']['original']['sha256']==c['baseline']['sha256']
    row={'case':c['case'],'point':c['oracles'][0]['args'],'alternative':c['oracles'][1]['args'],'repetitions':c['repetitions'],
         'object':c['programObject'],'ratios':{},'elapsedMs':{},'medianPairedRatio':{}}
    for role,samples in c['byRole'].items():
        verify(c['binaries'][role]);assert len(samples)==5
        for z in c['oracles']: assert role in z['checks']
        med=[s['elapsedMs']/b['elapsedMs'] for s,b in zip(samples,c['byRole']['original'])]
        assert med==c['stats'][role]['paired']
        row['elapsedMs'][role]=[s['elapsedMs'] for s in samples]
        row['ratios'][role]=med;row['medianPairedRatio'][role]=statistics.median(med)
    out['cases'].append(row)
assert not a.out.exists();a.out.write_text(json.dumps(out,indent=2)+'\n')
