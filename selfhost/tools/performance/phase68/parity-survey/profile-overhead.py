#!/usr/bin/env python3
"""Bracket profiler overhead at identical workload; diagnostic, not compiler speed."""
import importlib.util
import json
import sys
import time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('survey_run',HERE/'run.py')
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
S=R.S;ROOT=R.ROOT

def main():
    out=Path(sys.argv[1]).resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    parent=ROOT/'selfhost/build/phase68/parity-survey23-samples03/report.json'
    previous=R.read(parent);assert previous['complete']
    pins=[S.identity(__file__),S.identity(parent),previous['sampler']]
    jobs=[]
    for case,role in [('numeric','selfhost'),('closures','selfhost'),('closures','upstream')]:
        row=next(r for r in previous['records'] if r['job']['case']==case and r['job']['role']==role and r['job']['periodUs']==1000)
        jobs.append(row['job']);pins += [row['job']['executable'],row['job']['baseline']]
    R.verify(pins);S.save(out/'plan.json',dict(inputs=pins,jobs=jobs,order=['clean-before','sampled','clean-after'],scope='Single bracketed profiler-overhead screen on equal source/binary/work; clocks diagnostic only.'))
    report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            for job in jobs:
                for mode in ('clean-before','sampled','clean-after'):
                    dest=out/(job['case']+'-'+job['role']+'-'+mode)
                    prefix=[] if mode!='sampled' else ['env','LD_PRELOAD='+previous['sampler']['path'],'BEND_SAMPLE_OUT='+str(dest)+'.samples','BEND_SAMPLE_PERIOD_US=1000']
                    cmd=['taskset','-c','3',*prefix,job['executable']['path'],'--threads','1','--gpu','off','--',str(job['repetitions']),'0']
                    process=guard.run(cmd,dest,time.monotonic()+45)
                    obs=R.observed(dest,process,job['case'],job['repetitions'])
                    row=dict(job=job,mode=mode,process=process,**obs);report['records'].append(row)
                    assert obs['correct'];row['elapsedMs']=int(obs['stdout'][3])
                    assert not (dest/'stderr.log').read_text()
                    if mode=='sampled':row['samples']=S.identity(str(dest)+'.samples')
                    S.save(out/'report.json',report)
        R.verify(pins);report['complete']=True
    except BaseException as e:report['error']=repr(e);raise
    finally:report['finished']=time.time();S.save(out/'report.json',report)
    print(json.dumps([dict(case=r['job']['case'],role=r['job']['role'],mode=r['mode'],ms=r['elapsedMs']) for r in report['records']]))

if __name__=='__main__':main()
