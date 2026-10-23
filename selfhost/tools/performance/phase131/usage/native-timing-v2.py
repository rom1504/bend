"""Bounded paired proxy execution. Run inside ONE existing root CPU3 guard."""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import time

ROOT=Path(__file__).resolve().parents[5]


def pin(file):
    file=Path(file).resolve(); data=file.read_bytes()
    return dict(file=str(file),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--groups',nargs='+',choices=['usage','identity'],default=['usage','identity'])
    a=p.parse_args();out=a.out.resolve()
    assert len(set(a.groups))==len(a.groups)
    assert sorted(os.sched_getaffinity(0))==[3]
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    config=json.loads(a.config.read_text());assert config['complete'] and not config['targetsRun']
    inputs=[pin(__file__),pin(a.config),*config['inputs']]
    def add(row):
        assert pin(row['file'])==row,row['file'];inputs.append(row);return Path(row['file'])
    for row in inputs:assert pin(row['file'])==row
    spec=importlib.util.spec_from_file_location('identity_oracle',add(config['identityOracle']))
    oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)
    cases={}
    for case in config['cases']:
        if case['group'] not in a.groups: continue
        source=add(case['source']);add(case['expected'])
        emission=json.loads(add(pin(case['emission'])).read_text());build=json.loads(add(pin(case['build'])).read_text())
        assert emission['complete'] and emission['source']==case['source'] and emission['image']==config['image']
        assert build['complete'] and build['outputExact'] and emission['product'] in build['inputs'] and config['runtime'] in build['inputs']
        for row in emission['inputs']+build['inputs']:add(row)
        assert build['binary']['file']==case['binary'];add(build['binary']);cases[case['name']]=case
    out.mkdir(parents=True)
    r=dict(complete=False,inputs=inputs,groups=a.groups,rows=[],summaries={},timerUnits={'usage':'process wall seconds','identity':'IO.now integer milliseconds plus process wall seconds'},
           scope='Five alternating paired executions after ordinary output gates and bounded calibration. Fixed usage batch includes process startup; identity timer excludes initialization and warmups. This is generated proxy performance, not whole compiler speed.')
    def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save();start_all=time.monotonic()
    def run(name,phase,round_no,args,repeats=0):
        assert time.monotonic()-start_all<100,'Campaign budget'
        case=cases[name];command=[case['binary'],'--threads','1','--gpu','off',*args]
        start=time.monotonic();child=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=15);wall=time.monotonic()-start
        row=dict(name=name,phase=phase,round=round_no,command=command,status=child.returncode,wallSeconds=wall,
                 stdout=child.stdout.decode(),stderr=child.stderr.decode());r['rows'].append(row);save()
        assert child.returncode==0 and child.stderr==b''
        if case['group']=='usage':
            assert child.stdout==Path(case['expected']['file']).read_bytes();row['measuredSeconds']=wall
        else:
            result=oracle.validate(child.stdout,repeats,2,256);row.update(result);row['measuredSeconds']=result['runtimeSeconds']
        save();return row
    try:
        if 'usage' in a.groups:
            # Usage has a fixed explicit100×64-ID batch; retain startup in its clock.
            run('usage-original','calibration',-1,[])
            run('usage-candidate','calibration',-1,[])
            for i in range(5):
                for variant in ['original','candidate'] if i%2==0 else ['candidate','original']:
                    run('usage-'+variant,'paired',i,[])
        if 'identity' in a.groups:
            repeats=8
            for attempt in range(3):
                row=run('identity-original','calibration',attempt,['--',str(repeats),'2','256','0'],repeats)
                elapsed=row['runtimeSeconds']
                if elapsed>=0.2 or repeats>=65536:break
                repeats=min(65536,max(repeats+1,int(math.ceil(repeats*0.3/max(elapsed,0.001)))))
            r['identityRepeats']=repeats;save()
            for i in range(5):
                for variant in ['original','candidate'] if i%2==0 else ['candidate','original']:
                    run('identity-'+variant,'paired',i,['--',str(repeats),'2','256','0'],repeats)
        for group in a.groups:
            med={variant:statistics.median(row['measuredSeconds'] for row in r['rows'] if row['phase']=='paired' and row['name']==group+'-'+variant) for variant in ['original','candidate']}
            assert med['original']>0
            r['summaries'][group]=dict(medianSeconds=med,candidateOverOriginal=med['candidate']/med['original'],
               timerFloorPassed=all(row['measuredSeconds']>=0.02 for row in r['rows'] if row['phase']=='paired' and row['name'].startswith(group+'-')))
        for row in inputs:assert pin(row['file'])==row
        r['complete']=True
    except BaseException as error:r['error']=repr(error);raise
    finally:r['wallSeconds']=time.monotonic()-start_all;save()
    print(json.dumps(dict(complete=True,summaries=r['summaries'])))


if __name__=='__main__':main()
