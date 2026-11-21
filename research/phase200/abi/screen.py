"""Measure checked ownership guards on integrated Phase199 objects and observe actual calls."""
import argparse
import json
import math
import os
from pathlib import Path
import re
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import bench, execute
CASE_NAMES=['raytrace','coverage-map-churn-128','coverage-record-aggregation-256']
def read(path): return json.loads(Path(path).read_text())
def checked(item):
    bench.verify(item)
    return str(Path(item['file']).resolve())
def oracle(product,args):
    argv=[product['artifact']['file'],*bench.native_runtime_arguments(product),'0','0',*map(str,args)]
    started=time.monotonic();p=subprocess.run(argv,capture_output=True,timeout=12)
    line,separator,_=p.stdout.partition(b'\n')
    assert separator
    want=line.decode()+'\n'
    bench.observation(p.stdout,p.stderr,p.returncode,dict(expectedStdout=want,repetitions=0,warmups=0),time.monotonic()-started)
    return want

def run(out,previous=None,only=None):
    assert os.sched_getaffinity(0)=={3}
    out=out.resolve();out.mkdir()
    api=ROOT/'selfhost/build/phase199/p200-ownership-api01/report.json'
    if previous:
        selector=read(api)
        emitted=read(previous)
        assert emitted['complete'] and emitted['apiReceipt']==bench.pin(api)
        assert emitted['api']==selector['api'] and emitted['checkedSource']==selector['source']
        assert emitted['method']==bench.pin(HERE/'emit.mjs') and selector['complete'] and selector['checked']
        for item in (selector['api'],selector['source'],emitted['nativeManifest'],emitted['binding']):
            checked(item)
        emission_path=previous
    else:
        cmd=['selfhost/.assets/bin/bun',str(HERE/'emit.mjs'),str(api),str(out/'emission'),*CASE_NAMES]
        subprocess.run(cmd,check=True)
        emission_path=out/'emission/report.json';emitted=read(emission_path)
    assert emitted['complete'] and [x['id'] for x in emitted['cases']]==CASE_NAMES
    assert all(x['changed'] for x in emitted['cases'])
    plan=ROOT/'selfhost/build/phase198/p199-integrated-live-plan02'
    recipe=read(plan/'report.json')
    assert recipe['complete'] and recipe['manifest']==bench.pin(plan/'manifest.json')
    catalog={x['id']:x for x in read(plan/'manifest.json')['cases']}
    report=dict(complete=False,method=bench.pin(__file__),observer=bench.pin(HERE/'count.c'),emission=bench.pin(emission_path),api=bench.pin(api),previous=bench.pin(plan/'report.json'),cases=[])
    save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    for ordinal,source in enumerate(emitted['cases']):
        if only and source['id']!=only:continue
        name=source['id'];base=recipe['cases'][name];row=catalog[name];point=row['point']
        assert source['baseline']==base['object'] and source['source']==row['source']
        built=read(checked(base['production']));links=[j for j in built['jobs'] if j['label']=='link']
        assert built['complete'] and len(links)==1 and links[0]['exitCode']==0
        original=links[0]['command'];cc=original[0]
        paths={'c':Path(checked(row['products']['c']['artifact'])),'baseline':Path(checked(base['live']))}
        folder=out/name;folder.mkdir()
        result=dict(id=name,source=source['source'],objects={},counts={},observations={},calibration={},samples={},link=[])
        report['cases'].append(result);save()
        for role,item in [('baseline',base['object']),('candidate',source['object'])]:
            obj=checked(item);result['objects'][role]=item
            for observed in (False,True):
                if role=='baseline' and not observed:continue
                path=folder/(role+('-count' if observed else ''))
                extra=['-O2','-Wl,--wrap=p111_rt_keep','-Wl,--wrap=p111_rt_sink',str(HERE/'count.c')] if observed else []
                link=[cc,'-no-pie',obj,*extra,checked(recipe['liveRuntime']),'-pthread','-lm','-o',str(path)]
                assert original[1]=='-no-pie' and original[4:7]==['-pthread','-lm','-o']
                subprocess.run(link,check=True,capture_output=True);result['link'].append(link)
                if not observed:
                    paths[role]=path;continue
                args=[str(path),*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'1','0',*map(str,point['runtimeArgs'])]
                start=time.monotonic();proc=subprocess.run(args,capture_output=True,timeout=20);wall=time.monotonic()-start
                counts={};stderr=[]
                for line in proc.stderr.splitlines(keepends=True):
                    seen=re.fullmatch(rb'P200 (keep|sink) (\d+) (\d+)\n',line)
                    if seen:counts[seen[1].decode()+' '+seen[2].decode()]=int(seen[3])
                    else:stderr.append(line)
                bench.observation(proc.stdout,b''.join(stderr),proc.returncode,dict(point,repetitions=1,warmups=0),wall)
                result['counts'][role]=counts
        before,after=result['counts'].values()
        for key in set(before)|set(after):
            if int(key.split()[1])>1:assert before.get(key,0)==after.get(key,0),key
            else:assert before.get(key,0)>=after.get(key,0),key
        result['skippedImmediateCalls']=sum(before.values())-sum(after.values())
        assert result['skippedImmediateCalls']>0;save()
        result['executables']={k:bench.pin(v) for k,v in paths.items()}
        for args in [[1,0],[5,17]]:
            expected=oracle(row['products']['c'],args)
            result['observations'][str(args)]={role:execute(path,args,0,0,expected)[0] for role,path in paths.items()}
        for role,path in paths.items():
            result['samples'][role]=[];n=max(1,min(point['repetitions'],512));cal=[]
            for _ in range(12):
                obs,_=execute(path,point['runtimeArgs'],n,point['warmups'],point['expectedStdout'])
                cal.append([n,obs])
                if 130<=obs['elapsedMs']<=360:break
                n=max(1,math.ceil(n*180/max(1,obs['elapsedMs'])))
            else:raise ValueError('calibration '+name)
            result['calibration'][role]=cal
        roles=list(paths)
        for r in range(3):
            ix=(r+ordinal)%3
            for role in roles[ix:]+roles[:ix]:
                n=result['calibration'][role][-1][0]
                obs,_=execute(paths[role],point['runtimeArgs'],n,point['warmups'],point['expectedStdout'])
                assert obs['elapsedMs']>=100,(role,obs)
                result['samples'][role].append(dict(n=n,**obs))
        med={k:statistics.median(x['elapsedMs']/x['n'] for x in obs) for k,obs in result['samples'].items()}
        result['candidateOverBaseline']=med['candidate']/med['baseline']
        result['candidateOverC']=med['candidate']/med['c'];save()
    report['complete']=True;save()
    print([(x['id'],x['skippedImmediateCalls'],x['candidateOverBaseline']) for x in report['cases']])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--emission',type=Path);p.add_argument('--only',choices=CASE_NAMES);args=p.parse_args();run(args.out,args.emission,args.only)
