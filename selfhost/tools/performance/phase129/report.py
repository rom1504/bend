"""Seal a compact Phase129 research measurement table; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[4]
def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(relative):return json.loads((ROOT/relative).read_text())
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
physical=read('selfhost/build/phase129/profile-comparison01.json')
complete=read('selfhost/build/phase129/complete-comparison01.json')
contexts=read('selfhost/build/phase129/context-summary01/report.json')
decoder=ROOT/'selfhost/build/phase88/cache-js01/entry.bend'
names=set(re.findall(r'^def (\w+)\(',decoder.read_text().split('# Phase88 native-host entry.')[0],re.M))
rows=[];observations=0
for name,vs in physical['workloads'].items():
    v=vs['phase128'];profile=v['profile']
    assert profile['adequate'] and profile['estimateAvailable'] and not profile['rejectedCaptures']
    ctx=next(x for x in contexts['workloads'] if x['name']==name)
    assert ctx['adequatePooledSamples'] and not ctx['rejected']
    owners={x['owner']:x['periodWeightedFraction'] for x in ctx['contexts']}
    event_file=ROOT/f'selfhost/build/phase129/context-summary01/{name}-events.json'
    events=json.loads(event_file.read_text())
    diag=complete['workloads'][name]['phase128-context']
    assert diag['profile']['adequate'] and not diag['profile']['rejectedCaptures']
    for mode in ['profile01','context02']:
        report=read(f'selfhost/build/phase129/{mode}/{name}/report.json')
        assert report['complete'] and report['passed']
        observations+=len(report['rows'])
    rows.append(dict(name=name,cleanWallSeconds=v['clean']['wallSeconds']['median'],
        cleanCpuSeconds=v['clean']['cpuSeconds']['median'],physicalSamples=profile['samples'],
        physicalGroups=profile['groups'],contextSamples=ctx['acceptedSamples'],
        decoderContextFraction=sum(owners.get(n,0) for n in names),
        decimalContextFraction=sum(owners.get(n,0) for n in ['p88_digits','p88_digit','p88_number']),
        useQueryContextFraction=sum(owners.get(n,0) for n in ['nq_uses','nq_uses_list']),
        stringOrderContextFraction=owners.get('String.order',0),
        indexContextFraction=sum(owners.get(n,0) for n in ['index_find','index_bucket','index_insert','index_hash']),
        contextOnlyWallOverClean=diag['contextOnlyOverCleanWallRatio'],
        countersWallOverClean=diag['countersOverCleanWallRatio'],
        eventTotals=events['totals'],
        selectedEntries=[e for e in events['entrySegmentDispatches'] if e['loweredOwner'] in
            ['p88_digits','p88_digit','p88_number','p88_field','nq_uses','nq_uses_list','String.order','index_find']],
        eventReceipt=pin(event_file)))
guards=[]
for name in ['profile01-guard','context02-build-guard','context02-run-guard']:
    path=ROOT/f'selfhost/build/phase129/{name}/process.json'
    value=json.loads(path.read_text());assert value['complete'] and value['returncode']==0
    guards.append(dict(receipt=pin(path),seconds=value['wallSeconds'],peakRss=value['peakTreeRssBytes']))
result=dict(complete=True,targetsRunByThisTool=False,head='a4ecad0e2e33944814fbad0b53705c2460e60f8a',
    selected=pin(ROOT/'implementation/phase128/candidate.json'),observations=observations,
    inputs=[pin(ROOT/'selfhost/build/phase129/profile-comparison01.json'),
            pin(ROOT/'selfhost/build/phase129/complete-comparison01.json'),
            pin(ROOT/'selfhost/build/phase129/context-summary01/report.json'),pin(decoder),pin(__file__)],
    decoderNames=sorted(names),workloads=rows,guards=guards,
    guardedSeconds=sum(x['seconds'] for x in guards),
    peakGuardedRssBytes=max(x['peakRss'] for x in guards),
    scope='No new compiler or upstream comparison. Original-image physical profiles, diagnostic active contexts and counters are separate overlapping views. Cold three-request screen; full compiler and broad generated-program runtime remain Phase128 evidence.')
a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,observations=observations,guardedSeconds=result['guardedSeconds'],out=str(a.out))))
