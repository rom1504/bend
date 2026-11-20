#!/usr/bin/env python3
"""Authenticate the general-rule ablation and its transfer to native N1 objects."""
import importlib.util
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase198'
spec=importlib.util.spec_from_file_location('runtime_analysis',ROOT/'selfhost/tests/phase186/analyze-runtime.py')
A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
C,B=A.C,A.B
raw=B.read(BUILD/'ablation-runtime01/report.json')
a=A.analyze(BUILD/'ablation-runtime01/report.json',1.10)
assert a['positionBalanced'] and a['rounds']==4 and a['reference']=='baseline'
roles=['minimum','decrement','combined']
assert set(a['roles'])==set(['baseline',*roles])
native=B.read(BUILD/'native45-01/programs.manifest.json')
baseline=B.read(ROOT/'selfhost/build/phase195/native45-01/programs.manifest.json')
native={c['id']:c for c in native['cases']};baseline={c['id']:c for c in baseline['cases']}
products={}
for role in roles:
    m=B.read(BUILD/('ablation-'+role+'-build01')/'programs.manifest.json')
    for item in m['inputs']:C.verify(item)
    products[role]={c['id']:c for c in m['cases']}
rows=[]
for case in a['cases']:
    name=case['id'];objects={};unchanged={}
    for role in ['baseline',*roles]:
        product=(baseline[name]['products']['candidate'] if role=='baseline' else products[role][name]['products'][role])
        artifact=C.verify(product['artifact'])
        assert C.pin(artifact)==case['artifacts'][role]
        obj=product['generatedSource'];C.verify(obj);objects[role]=obj
    target=native[name]['products']['candidate']['generatedSource'];C.verify(target)
    assert all(objects['combined'][k]==target[k] for k in ['bytes','sha256']),name
    for role in roles:unchanged[role]=all(objects[role][k]==objects['baseline'][k] for k in ['bytes','sha256'])
    samples=next(c['samples'] for c in raw['cases'] if c['id']==name)
    assert all(s['elapsedMs']>=raw['minimumAcceptedMs']>=100 for s in samples)
    rows.append(dict(id=name,ratios={r:case['stats'][r]['medianMs']/case['stats']['baseline']['medianMs'] for r in roles},stats=case['stats'],flagged=case['flagged'],objects=objects,objectsEqualBaseline=unchanged,combinedMatchesNativeN1=True))
result=dict(kind='phase198-authenticated-general-rule-ablation',complete=True,method=C.pin(__file__),analyzer=C.pin(A.__file__),report=a['report'],plan=C.pin(BUILD/'ablation-plan01.json'),oracleRevalidated=a['oracleRevalidated'],inputPinsVerified=a['inputPinsVerified'],cases=rows,scope='Five cases selected before measurement after the separate fold128 regression confirmation. Each variant changes only the previously checked general compiler rule; no per-case rule gating. Qualified Phase195 baseline and native Phase198 combination are authenticated by exact object identity; all timings retained. This diagnostic does not replace the complete native45 aggregate.')
out=ROOT/'research/phase198/qualification/ablation-summary01.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps([dict(id=r['id'],ratios=r['ratios'],objectsEqualBaseline=r['objectsEqualBaseline'],flagged=r['flagged']) for r in rows],indent=2))
