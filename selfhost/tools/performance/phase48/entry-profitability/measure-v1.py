#!/usr/bin/env python3
"""ROOT ONLY: bounded audit or clean public-call measurement of saved entries.

Usage: measure-v1.py PROBE NEW_OUT --mode audit|timing
Default timing: three short/mid/long points, five rotated rounds, 45 fresh jobs.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p48_entry_support',ROOT/'selfhost/tools/performance/programs/support.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('probe',type=Path);ap.add_argument('out',type=Path)
ap.add_argument('--mode',choices=['audit','timing'],required=True)
ap.add_argument('--points',default='128-0,4096-17,8192-123')
ap.add_argument('--node',type=Path,default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
a=ap.parse_args();probe=a.probe.resolve();out=a.out.resolve();node=a.node.resolve()
manifest=json.loads((probe/'manifest.json').read_text())
assert manifest['complete'] and manifest['diagnosticOnly'] and not manifest['productionSafe']
def pure_identity(item):return {k:item[k] for k in ['path','sha256','bytes']}
items=[*manifest['inputs'],*[pure_identity(x) for x in manifest['variants'].values()],
       *manifest['audit'].values(),manifest['auditController'],*[x['config'] for x in manifest['points']]]
driver=ROOT/'selfhost/tools/performance/programs/execute.mjs'
inputs=[s.identity(x) for x in [__file__,probe/'manifest.json',driver,node]]+items
def verify():
    for item in inputs:assert s.identity(item['path'])==item,item['path']
verify();out.mkdir(parents=True,exist_ok=False)
(out/'consumed-measure-v1.py').write_bytes(Path(__file__).read_bytes())
report=dict(kind='phase48-entry-'+a.mode,complete=False,passed=False,diagnosticOnly=True,
            productionSafe=False,inputs=inputs,records=[],protocol=dict(cpu=3,heapMiB=1024,
            rssMiB=2048,availableMiB=4096,mode=a.mode))
s.save(out/'report.json',report);started=time.monotonic()
try:
    with s.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
        if a.mode=='audit':
            result=out/'audit-result.json'
            command=['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',
                     manifest['auditController']['path'],str(probe),str(result)]
            proc=guard.run(command,out/'job-audit',started+30)
            report['records'].append(dict(process=proc));s.save(out/'report.json',report)
            assert proc['complete'],'Audit failed or exceeded resource bound'
            observation=json.loads(result.read_text());report['records'][0]['result']=observation
            assert observation['complete'] and observation['pass']
        else:
            ids=a.points.split(',');assert 1<=len(ids)<=6 and len(set(ids))==len(ids)
            lookup={p['id']:p for p in manifest['points']};assert set(ids)<=set(lookup)
            points=[lookup[x] for x in ids];names=list(manifest['variants'])
            assert set(names)=={'original','allocation-free','unsafe-admission-bypass'}
            assert manifest['variants']['unsafe-admission-bypass']['unsafeUpperBound']
            report['protocol'].update(rounds=5,points=ids,variants=names,warmupMs=1000,
               calibrationMs=50,targetMs=200,secondsPerJob=15,totalSeconds=240,
               scope='Clean saved-output public calls; full admission bypass is an unsafe upper bound.')
            s.save(out/'report.json',report)
            for round in range(5):
                point_offset=round%len(points);name_offset=round%len(names)
                for point in points[point_offset:]+points[:point_offset]:
                    for name in names[name_offset:]+names[:name_offset]:
                        label=f'r{round}-{point["id"]}-{name}';result=out/(label+'.json')
                        command=['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',
                                 str(driver),manifest['variants'][name]['path'],point['config']['path'],str(result)]
                        proc=guard.run(command,out/('job-'+label),min(started+240,time.monotonic()+15))
                        row=dict(round=round,point=point['id'],variant=name,process=proc)
                        report['records'].append(row);s.save(out/'report.json',report)
                        assert proc['complete'],label
                        row['result']=json.loads(result.read_text());s.save(out/'report.json',report)
                        assert row['result']['complete'] and row['result']['pass'],label
            report['statistics']={}
            for point in points:
                report['statistics'][point['id']]={}
                for name in names:
                    rows=[x for x in report['records'] if x['point']==point['id'] and x['variant']==name]
                    assert len(rows)==5
                    # Preserve the maintained driver's result instead of guessing
                    # metric names; record numeric timing medians from its schema.
                    numeric={k:[x['result'][k] for x in rows] for k,v in rows[0]['result'].items()
                             if isinstance(v,(int,float)) and not isinstance(v,bool)}
                    report['statistics'][point['id']][name]={k:dict(median=statistics.median(v),min=min(v),max=max(v),samples=v)
                                                             for k,v in numeric.items()}
    verify();report['complete']=report['passed']=True
except Exception as error:
    report['error']=repr(error);raise
finally:
    report['wallSeconds']=time.monotonic()-started;s.save(out/'report.json',report)
print(json.dumps(dict(complete=True,mode=a.mode,records=len(report['records']),report=str(out/'report.json'))))
