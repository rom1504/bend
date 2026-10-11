#!/usr/bin/env python3
"""Root-only paired native CPU samples. No profiled clock is a speed result."""
import argparse
import importlib.util
import json
import math
import shutil
import sys
import time
from pathlib import Path

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('survey_run',HERE/'run.py')
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
S=R.S
read=R.read

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--debug',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--cases',default='numeric,array,tree,lexer,closures,map')
    p.add_argument('--periods',default='1000,1307')
    a=p.parse_args()
    debug=read(a.debug/'report.json');assert debug['complete']
    products,pins=R.products()
    pins += [S.identity(a.debug/'report.json'),S.identity(a.debug/'plan.json'),
             S.identity(__file__),S.identity(HERE/'sample-preload.c'),S.identity(HERE/'sample-analysis.py')]
    for tool in ('objcopy','readelf','addr2line','objdump'):
        pins.append(S.identity(shutil.which(tool)))
    samples={}
    for row in debug['records']:
        assert row['complete'] and row['textIdentical']
        key=(row['job']['case'],row['job']['role'])
        samples[key]=row['executable']
        pins.append(row['executable'])
        assert products[key]['executable']==row['job']['originalExecutable']
    historical=ROOT/'selfhost/build/phase68/facts-native-comparison23/report.json'
    clocks=read(historical);assert clocks['complete']
    pins.append(S.identity(historical))
    fixed=read(ROOT/'selfhost/build/phase68/facts-native-comparison23/plan.json')['counts']
    pins.append(S.identity(ROOT/'selfhost/build/phase68/facts-native-comparison23/plan.json'))
    ms={(r['case'],role):r['mediansMs']['candidate' if role=='selfhost' else 'upstream']
        for r in clocks['rows'] for role in ('selfhost','upstream')}
    names=a.cases.split(',');periods=list(map(int,a.periods.split(',')))
    assert set(names)<= {'numeric','array','tree','lexer','closures','map'}
    assert len(periods)==len(set(periods)) and all(250<=p<=100000 for p in periods)
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    jobs=[]
    for case in names:
        for period in periods:
            for role in ('selfhost','upstream'):
                count=fixed[case]['repetitions']*math.ceil(2500/ms[(case,role)])
                jobs.append(dict(case=case,role=role,periodUs=period,repetitions=count,
                    executable=samples[(case,role)],baseline=products[(case,role)]['executable']))
    R.verify(pins)
    S.save(out/'plan.json',dict(inputs=pins,jobs=jobs,scope='Main-thread CPU sampling only; full process incl startup; per-role count chosen for roughly2.5seconds from historical clocks, no speed comparison. Different timer periods check stability.'))
    report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(cmd,dest,seconds=45,cpu=3):
                return guard.run(['taskset','-c',str(cpu),*map(str,cmd)],dest,time.monotonic()+seconds)
            so=out/'sample-preload.so'
            clang=products[(names[0],'selfhost')]['recipe']['clang']
            report['samplerBuild']=run([clang,'-std=c11','-O2','-Wall','-Wextra','-Werror','-fPIC','-shared',HERE/'sample-preload.c','-o',so,'-lrt'],out/'sampler-build')
            assert report['samplerBuild']['complete']
            report['sampler']=S.identity(so)
            S.save(out/'report.json',report)
            for job in jobs:
                case,role=job['case'],job['role']
                dest=out/(case+'-'+role+'-'+str(job['periodUs']));dest.mkdir()
                sample=dest/'profile.samples'
                command=['env','LD_PRELOAD='+str(so),'BEND_SAMPLE_OUT='+str(sample),
                    'BEND_SAMPLE_PERIOD_US='+str(job['periodUs']),job['executable']['path'],
                    '--threads','1','--gpu','off','--',job['repetitions'],0]
                item=dict(job=job)
                report['records'].append(item)
                item['process']=run(command,dest/'run')
                item.update(R.observed(dest/'run',item['process'],case,job['repetitions']))
                S.save(out/'report.json',report)
                assert item['correct'],(case,role,'oracle')
                assert not (dest/'run/stderr.log').read_text(),(case,role,'stderr')
                item['samples']=S.identity(sample)
                analysis=dest/'analysis.json'
                item['analysisProcess']=run(['python3',HERE/'sample-analysis.py','--samples',sample,
                    '--baseline',job['baseline']['path'],'--debug',job['executable']['path'],
                    '--output',analysis],dest/'symbolize',45,cpu=0)
                assert item['analysisProcess']['complete'],(case,role,'symbolization')
                item['analysis']=S.identity(analysis)
                header=read(analysis)['header']
                item['usable']=header['samples']>=500 and header['dropped']==0 and header['handler_intact']==1
                assert item['usable'],(case,role,'insufficient samples')
                S.save(out/'report.json',report)
                print(json.dumps(dict(case=case,role=role,period=job['periodUs'],correct=True,samples=header['samples'],overruns=header['overruns'])),flush=True)
        R.verify(pins)
        assert S.identity(so)==report['sampler']
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error)
        raise
    finally:
        report['finished']=time.time()
        S.save(out/'report.json',report)

if __name__=='__main__':main()
