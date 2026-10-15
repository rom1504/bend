#!/usr/bin/env python3
"""One doubled-repetition diagnostic per pilot product, separate from main timing."""
import json, statistics, time
from pathlib import Path
from run import ROOT, collect_products, pin, read, sample, save
out=ROOT/'selfhost/build/phase93/scaling01';out.mkdir(exist_ok=False)
acquired=ROOT/'selfhost/build/phase93/pilot02/report.json'
baseline=ROOT/'selfhost/build/phase93/measure-pilot01/report.json'
cases=collect_products([acquired]);timing=read(baseline);assert timing['complete']
report=dict(complete=False,method=pin(__file__),baseline=pin(baseline),acquired=pin(acquired),records=[],started=time.time())
try:
    for name,case in cases.items():
        plan=timing['plan'][name]
        for role in ['own','upstream']:
            row=sample(out/(name+'-'+role),case,role,2*plan['repetitions'],plan['warmups'])
            assert row['qualified']
            old=statistics.median(r['elapsedMs'] for r in timing['records'] if r['case']==name and r['role']==role)
            row['ratioToHalfRepetitionsMedian']=row['elapsedMs']/old
            report['records'].append(row);save(out/'report.json',report)
    report['complete']=True
finally:
    report['finished']=time.time();save(out/'report.json',report)
print(json.dumps([{k:r[k] for k in ['case','role','ratioToHalfRepetitionsMedian']} for r in report['records']]))
