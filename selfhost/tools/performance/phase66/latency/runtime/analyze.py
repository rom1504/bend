#!/usr/bin/env python3
"""Compact data-only summary of complete Phase66 generated-program timing batches."""
import argparse, hashlib, json, math, statistics
from pathlib import Path

def pin(value):
    p=Path(value.get('file',value.get('path')) if isinstance(value,dict) else value).resolve(strict=True)
    b=p.read_bytes();row=dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
    if isinstance(value,dict):
        assert row['sha256']==value['sha256']
        if 'bytes' in value:assert row['bytes']==value['bytes']
    return row

p=argparse.ArgumentParser(description=__doc__);p.add_argument('--report',action='append',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists();rows=[];seen=set();reports=[];ratios={};total_samples=0;wall=0;peak=0
for file in a.report:
    report_id=pin(file);r=json.loads(file.read_text());assert r['complete'] and r['pass'] and r['status']=='measured'
    assert r['measuredCases']==r['selectedCases']==len(r['cases'])
    for value in r['inputs']:pin(value)
    reports.append(report_id);wall+=r['wallSeconds']
    for case in r['cases']:
        assert case['id'] not in seen;seen.add(case['id']);summary=case['summary'];assert summary['complete']
        assert summary['balancedRounds']==list(range(case['rounds']))
        roles=r['plan']['roles'];values={role:[] for role in roles}
        expected={(role,i) for role in roles for i in range(case['rounds'])};actual=set()
        for sample in case['samples']:
            key=sample['role'],sample['round'];assert key in expected and key not in actual;actual.add(key)
            result=sample['result'];assert sample['complete'] and sample['process']['complete'] and sample['process']['returncode']==0 and result['complete'] and result['pass']
            assert all(result['config'][k]==case['point'][k] for k in ['exportName','args','expected'])
            assert result['firstResult']==case['point']['expected'];pin(result['module'])
            values[sample['role']].append(result)
            peak=max(peak,sample['process']['peakTreeRssBytes'])
        assert actual==expected;total_samples+=len(actual)
        stats={role:dict(medianMs=statistics.median(v['msPerCall'] for v in vs),
            samplesMs=[v['msPerCall'] for v in vs],firstCallMs=[v['firstCallMs'] for v in vs],
            importMs=[v['importMs'] for v in vs],halfDriftPercent=[v['halfDriftPercent'] for v in vs]) for role,vs in values.items()}
        for role in roles:assert stats[role]['medianMs']==summary['stats'][role]['medianMs']
        for name,value in summary['ratios'].items():
            numerator,denominator=name.split('/');assert stats[numerator]['medianMs']/stats[denominator]['medianMs']==value
            ratios.setdefault(name,[]).append(value)
        rows.append(dict(id=case['id'],rounds=case['rounds'],stats=stats,ratios=summary['ratios'],roleLabels=r['plan']['variants']))
result=dict(kind='phase66-generated-program-timing-summary',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=pin(__file__),reports=reports,points=len(rows),samples=total_samples,wallSeconds=wall,peakTreeRssBytes=peak,cases=rows,
    aggregate={k:dict(equalPointGeometricMean=math.exp(statistics.mean(map(math.log,vs))),minimum=min(vs),maximum=max(vs),belowOne=sum(v<1 for v in vs),points=len(vs)) for k,vs in ratios.items()},
    scope='Unchanged fixed workload execution, exact expected values and complete paired rounds only. Compilation excluded; import and first call separate. '
          'Equal-point aggregate is descriptive for this selection, not typical production runtime. Preserve samples/drift and original held-out families; short presets are rejection screens.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(output=pin(a.out),points=len(rows),samples=total_samples,aggregate=result['aggregate'])))
