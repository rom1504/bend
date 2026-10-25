"""Summarize completed Phase141 receipts; no targets or compiler decisions."""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
inputs = []
def pin(path):
    path = Path(path).resolve(); b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
def read(path):
    path = ROOT/path
    inputs.append(pin(path))
    return json.loads(path.read_text())
q = read('selfhost/build/phase141/qualification01.json')
assert q['complete'] and q['nativeQualified']
source = read('selfhost/build/phase141/integrated-source02/manifest.json')
small = read('selfhost/build/phase141/integrated-pairs01/report.json')
acquire = read('selfhost/build/phase130/p141-integrated-emit01/report.json')
self_run = read('selfhost/build/phase130/p141-integrated-self01/report.json')
parent_run = read('selfhost/build/phase130/p141-parent-integrated-source01/report.json')
repeat = read('selfhost/build/phase130/p141-final-same-source02/report.json')
load_sections = read('selfhost/build/phase141/native-load-sections01.json')
assert all(load_sections['equal'].values())
assert all(r['complete'] and r['source'] == source['source'] for r in [acquire,self_run,parent_run,repeat])
assert self_run['byteExact'] and parent_run['byteExact']
assert repeat['byteExact']
assert acquire['product']['sha256'] == self_run['product']['sha256'] == parent_run['product']['sha256'] == repeat['product']['sha256']
sessions = {}
for role in ['baseline','candidate']:
    r = read(f'selfhost/build/phase140/p141-full-edit-{role}01/report.json')
    guard = read(f'selfhost/build/phase111/p141-full-edit-{role}-guard01/process.json')
    assert r['complete'] and r['independentProductsExact'] and not r['changedInputs']
    assert guard['complete'] and guard['returncode'] == 0
    sessions[role] = dict(nativeSeconds=r['nativeSeconds'],totalSeconds=r['totalSeconds'],
        guardWallSeconds=guard['wallSeconds'],peakTreeRssBytes=guard['peakTreeRssBytes'],
        prepareMs=r['prepareMs'], jobs=[{k:j[k] for k in ['name','source','stages','ioMs',
            'transportSeconds','product','exactOracle','reusedBytes','freshBytes']} for j in r['jobs']])
for old,new in zip(sessions['baseline']['jobs'],sessions['candidate']['jobs']):
    assert old['source'] == new['source'] and old['name'] == new['name']
    assert old['product']['sha256'] == new['product']['sha256']
session_ratios = {k:sessions['candidate'][k]/sessions['baseline'][k] for k in ['nativeSeconds','totalSeconds','guardWallSeconds']}
session_ratios['jobs'] = [dict(name=b['name'],nativeCompileRatio=b['stages']['totalMs']/a['stages']['totalMs'],
    measuredRequestSubtotalRatio=(b['stages']['totalMs']/1000+b['ioMs']/1000+b['transportSeconds'])/
        (a['stages']['totalMs']/1000+a['ioMs']/1000+a['transportSeconds']))
    for a,b in zip(sessions['baseline']['jobs'],sessions['candidate']['jobs'])]
smoke = read('selfhost/build/phase140/p141-incremental-smoke01/report.json')
assert smoke['complete'] and smoke['independentProductsExact']
gates = {}
for name in ['p141-integrated-focused19','p141-n2-focused19','p141-n2-full45']:
    r = read(f'selfhost/build/phase111/{name}/report.json')
    assert r['complete'] and r['passed']
    gates[name] = r['summary']
    if name.endswith('full45'):
        emits = [read(str(Path(row['emission']['file']).relative_to(ROOT))) for row in r['rows']]
        assert len(emits) == 45 and all(e['comparison']['byteExact'] for e in emits)
guards = []
for file in sorted((ROOT/'selfhost/build/phase111').glob('p141*/process.json')):
    r = read(str(file.relative_to(ROOT)))
    command = ' '.join(r['command'])
    category = ('incremental sessions' if 'run-batch-' in command else
        'native source requests' if 'native-request.py' in command else
        'native acquisition/proxies' if 'native-emit.py' in command else
        'native semantic gates' if any(x in command for x in ['native-gate.py','coverage.py','full45.py']) else
        'native machine construction' if 'build-aligned.py' in command else
        'independent source checking' if 'check-api.py' in command else
        'other controls/probes/measurement')
    guards.append(dict(file=str(file.relative_to(ROOT)),category=category,
        seconds=r['wallSeconds'],started=r['started'],finished=r['finished'],
        exitCode=r.get('returncode'),complete=r.get('complete'),peakRssBytes=r['peakTreeRssBytes']))
totals = defaultdict(float)
for g in guards: totals[g['category']] += g['seconds']
intervals = sorted((g['started'],g['finished']) for g in guards)
merged = []
for begin,end in intervals:
    if merged and begin <= merged[-1][1]: merged[-1][1] = max(end,merged[-1][1])
    else: merged.append([begin,end])
now = time.time()
result = dict(kind='phase141-completed-evidence-summary',complete=True,
    source=dict(before=source['before'],after=source['after'],
        productionCodeDelta=-530,controlCodeDelta=-76,conceptsRetired=[
            'independent normal top-declaration grammar','handwritten list/comparator specialization family']),
    ordinaryNativeQualified=True,incrementalQualified=False,selected=False,
    smallRequests=small['summary'],
    sameSourceFullRequest=dict(source=source['source'],qualified137Seconds=acquire['nativeSeconds'],
        directParent140Seconds=parent_run['nativeSeconds'],candidate141Seconds=self_run['nativeSeconds'],
        candidate141RepeatSeconds=repeat['nativeSeconds'],
        candidateOverParent=self_run['nativeSeconds']/parent_run['nativeSeconds'],
        candidateRepeatOverParent=repeat['nativeSeconds']/parent_run['nativeSeconds'],
        candidateOverQualified137=self_run['nativeSeconds']/acquire['nativeSeconds'],
        candidateLoadSectionsExact=True,qbeExact=True,
        scope='One observation for qualified137 and direct parent140; initial candidate N1 observation plus '
        'a flagged-case N2 repeat on identical source02 and authenticated Base. All allocated file-backed '
        'ELF sections of N1/N2 match. Whole native process including reads and QBE writes; '
        'excludes machine construction. Both candidate observations retained; no confidence interval.'),
    incrementalSessions=dict(values=sessions,candidateOverBaseline=session_ratios,
        fourRevisionSmokeExact=True,scope='Same qualified compiler source and actual product-policy edit; '
        'one two-revision session per version. Native stages, measured transport and outer guard wall reported separately; '
        'no new machine build or upstream ratio.'),
    gates=gates,generatedCodeQuality=dict(full45QbeExact=True,newRuntimeCampaign=False),
    cost=dict(recordedAt=datetime.fromtimestamp(now,timezone.utc).isoformat(),
        campaignSeconds=now-datetime(2026,10,25,21,49,22,tzinfo=timezone.utc).timestamp(),
        guardSeconds=sum(g['seconds'] for g in guards),
        guardCoveredWallSeconds=sum(end-begin for begin,end in merged),
        guardSecondsByCategory=dict(totals),guardCount=len(guards),
        failedGuards=[g for g in guards if g['exitCode'] != 0],
        peakRecordedTreeRssBytes=max(g['peakRssBytes'] for g in guards),
        guards=guards,agentQuota='Not available; not inferred from target wall time.',
        scope='Guarded acquisition, checking, testing and measurement, including failures. '
        'Root/subagent reasoning, source-only tools, documentation and Git operations are not CPU-metered.'),
    inputs=[pin(__file__),*inputs])
a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,sameSource=result['sameSourceFullRequest'],sessions=session_ratios,cost=totals)))
