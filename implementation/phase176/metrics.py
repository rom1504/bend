#!/usr/bin/env python3
"""Read existing receipts only; preserve measurement boundaries."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BUILD=ROOT/'selfhost/build/phase176'
read=lambda name:json.loads((BUILD/name/'report.json').read_text())
metrics=dict(kind='phase176-measured-results',complete=True,
    sourceParent='de627cb',productionChanged=False,installedChanged=False,
    fullFrontendMeasured=False,completeColdBuildMeasured=False,
    calibration=[],nativeWorkloads={},parseTransfer={},gates={},cost={})
serial=read('calibration-serial02')['seconds']
for name in ['calibration-serial02','calibration-parallel01','calibration-four01','calibration-medium01']:
    r=read(name);g=json.loads((BUILD/(name+'-guard')/'process.json').read_text());assert r['complete']and g['complete']
    row=dict(run=name,seconds=r['seconds'],childCpuSeconds=r['childCpuSeconds'],cpus=r['cpus'],
             peakTreeRssMiB=g['peakTreeRssBytes']/2**20,comparisons=[])
    if name!='calibration-medium01':row['throughputVsSerial']=serial/r['seconds']
    for j in r['jobs']:
        q=json.loads(Path(j['result']['file']).read_text());assert q['complete']
        row['comparisons'].append(dict(id=j['id'],cases=q['cases']))
    metrics['calibration'].append(row)
for label,name in [('mutual','pattern-timing01'),('single','pattern-single-timing01')]:
    r=read(name);assert r['complete'];metrics['nativeWorkloads'][label]={k:r[k]for k in ['medians','ratio','seconds']}
    metrics['nativeWorkloads'][label]['pairs']=len(r['rows'])//2
for label,name in [('small-medium','parse-transfer01'),('full','parse-full01')]:
    r=read(name);assert r['complete'];metrics['parseTransfer'][label]=dict(cases=r['cases'],seconds=r['seconds'],rounds=r['rounds'])
for name in ['pattern-values02','pattern-single-values01','parse-values02','batch-controls01']:
    r=read(name);assert r['complete'];metrics['gates'][name]=dict(complete=True,rows=len(r.get('rows',[])),checks=r.get('checks'))
for name in ['pattern-native-baseline01','pattern-native-candidate02','pattern-single-native01','parse-single-native01']:
    r=read(name);assert r['complete'];metrics.setdefault('acquisition',{})[name]=dict(wallSeconds=r['wallSeconds'],binary=r['binary'],qbeBytes=r.get('retainedIR',{}).get('bytes'))
guards=[]
for f in sorted(BUILD.glob('*-guard/process.json')):
    r=json.loads(f.read_text());life=json.loads((f.parent/'retention.json').read_text());assert life['closed']and life['state']=='sealed',str(f)
    guards.append(dict(run=f.parent.name,complete=r['complete'],seconds=r['wallSeconds'],
                       stoppedFor=r.get('stoppedFor'),peakTreeRssMiB=r['peakTreeRssBytes']/2**20))
metrics['cost']=dict(guards=guards,guardCount=len(guards),targetSeconds=sum(x['seconds']for x in guards),
    failedGuardCount=sum(not x['complete']for x in guards),failedGuardSeconds=sum(x['seconds']for x in guards if not x['complete']),
    scope='Outer supervised target wall time; no overlapping guarded runs. Metadata preparation, research, agent work, storage dedup and writing are outside this sum. Not quota measurement.')
(Path(__file__).parent/'metrics.json').write_text(json.dumps(metrics,indent=2)+'\n')
print(json.dumps({k:v for k,v in metrics['cost'].items()if k!='guards'}))
