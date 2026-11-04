#!/usr/bin/env python3
"""Offline Phase159 aggregation. Keeps different compiler/workload revisions separate."""
import collections, importlib.util, json, statistics
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase159'
OUT=ROOT/'implementation/phase159'
spec=importlib.util.spec_from_file_location('comparison',ROOT/'selfhost/tools/profiler/compare.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
reader=C.Reader()

def read(path): return reader.read(C.pin(path))
def report(name):
    p=BUILD/name/'report.json'; d=read(p)
    assert d['complete'] and d['passed'] and not d['changedInputs']
    manifest=read(p.parent/'manifest.json')
    assert any(x['sha256']==C.pin(p.parent/'manifest.json')['sha256'] for x in d['inputs'])
    variants={(w['name'],v['name']):v for w in manifest['workloads'] for v in w['variants']}
    for row in d['rows']:
        assert row['correct'] and not row['timedOut']
        v=variants[row['workload'],row['variant']]
        assert row['command']==v['command'] and row.get('argv0')==v.get('argv0',v['command'][0])
        reader.verify(v['binary'])
        for item in v.get('inputs',[]): reader.verify(item)
        row['_identity']=(v['binary']['sha256'],tuple(v['command']),v.get('argv0'))
        for stream in ['stdout','stderr']:
            assert C._output_matches(reader.verify(row[stream]),v['expected'][stream])
        assert row['returncode']==v['expected'].get('exitCode',0)
    return d

def groups(names):
    rows=collections.defaultdict(list)
    for name in names:
        for row in report(name)['rows']: rows[row['workload'],row['variant']].append(row)
    out={}
    for (work,variant),rs in rows.items():
        assert len({r['_identity'] for r in rs})==1
        clean=[r for r in rs if r['mode']=='clean']; captures=[]
        for r in rs:
            if r['mode']!='sample': continue
            a=reader.read(r['analysis']);reader.verify(r['profile'])
            assert a['identities']['capture']['sha256']==r['profile']['sha256']
            assert a['identities']['binary']['sha256']==r['_identity'][0]
            captures.append(dict(identity=r['analysis'],analysis=a,childCpuSeconds=r['cpuSeconds']))
        cpu=statistics.median(r['cpuSeconds'] for r in clean) if clean else None
        out.setdefault(work,{})[variant]=dict(clean=C.timing(clean),profile=C.pool_captures(captures,cpu,500))
    return out

historical=groups(['self02','self03'])
common=groups(['common-time01','common-sample01'])
refill=groups(['refill-time01','refill-sample02'])
# Original GC physical captures are identical to the reference executable/workload
# in the paired run. No pooling across executable revisions or runtime changes.
original=groups(['refill-time01','common-sample01'])['bench16']['gc03']
refill['bench16']['gc03']=original
stage=read(BUILD/'stage-run01/report.json');assert stage['complete']
for call in stage['calls']:
    assert call['passed'] and call['diagnostic']['diagnostic_errors']==0
    reader.verify(call['process']['stdout']);reader.verify(call['process']['stderr'])
counted=next(c for c in stage['calls'] if c['allocationFlag']=='1')
timed=next(c for c in stage['calls'] if c['allocationFlag']=='0')
old,new=refill['bench16']['gc03'],refill['bench16']['gc-cap64']
a,b=[x['clean']['wallSeconds']['median'] for x in [old,new]]
controls={n:dict(passed=report(n)['passed'],observations=len(report(n)['rows']))
          for n in ['common-control01','common-control02','refill-control01','refill-control02']}
result=dict(schema='phase159-measurements-v1',complete=True,method=C.pin(__file__),
    historical=historical,common=common,refill=refill,controls=controls,
    causalResult=dict(originalSeconds=a,cappedSeconds=b,speedup=a/b,timeReduction=1-b/a,
        medianRssRatio=new['clean']['peakRssKiB']['median']/old['clean']['peakRssKiB']['median'],
        scope='Private GC reuse-search cap on one captured five-owner compiler computation; not our whole compiler.'),
    historicalStages=timed['diagnostic'],historicalAllocations=dict(
        calls=sum(r['allocation_calls'] for r in counted['diagnostic']['rows']),
        requestedBytes=8*sum(r['requested_words'] for r in counted['diagnostic']['rows']),
        countedSeconds=counted['process']['seconds'],countDisabledSeconds=timed['process']['seconds'],
        countsByStage=counted['diagnostic']['rows'],
        scope='gc_alloc_x requests before size-class rounding; not malloc calls, live bytes or a clean timing.'),
    limitations=['Historical self-emission and the current bendc common workload use different source/runtime revisions.',
      'Common scaling has two rounds; paired runtime ablation has four. No confidence interval claimed.',
      'Equivalent C/GC and QBE CLI argument adapters differ explicitly; no cross-variant sample pooling.',
      'Bench batches run the existing verifier and sink output; complete independent oracle is checked before/after at batch1.',
      'Physical leaf costs do not identify logical callers; inclusive stage clocks overlap.',
      'No production compiler promotion or broad GC/runtime qualification.'],evidence=list(reader.identities.values()))
OUT.mkdir(exist_ok=True)
with (OUT/'metrics.json').open('x') as f: json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(result['causalResult']))
