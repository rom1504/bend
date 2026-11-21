"""Ablate a documented profitability restriction on verified scalar borrow adapters."""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'fusion'))
from screen import BUILD,checked_tool,pin,read,execute,extra_output,bench

CASES=['test-map-set-ops','coverage-map-churn-32','coverage-record-aggregation-256',
       'coverage-unicode-text-64','complete-generic-row32','test-morning-program']
def cmd(args,**kw):
    return subprocess.run(list(map(str,args)),check=True,capture_output=True,timeout=15,**kw)

def run(out):
    assert os.sched_getaffinity(0)=={3}
    out=out.resolve();out.mkdir(parents=True)
    p=BUILD/'phase198/portfolio-live-plan01/manifest.json'
    cases={r['id']:r for r in read(p)['cases']};ref=read(BUILD/'phase194/assets.json')
    cc=checked_tool(ref['assets']['linker']);tc=ref['toolchains']['x86']
    cfg=read(HERE.parent/'runtime-broad/portfolio-pins.json')
    rt=checked_tool(cfg['live']);src=HERE/'adapter.c'
    wrappers={}
    for i,role in enumerate(['delegate','read','owned','count']):
        obj=out/(role+'.o')
        cmd([cc,'-std=c11','-O2','-DMODE='+str(i),'-c',src,'-o',obj])
        wrappers[role]=obj
    r={'complete':False,'roles':{k:pin(v) for k,v in wrappers.items()},'manifest':pin(p),
       'method':pin(__file__),'wrapper':pin(src),'runtime':cfg['live'],'cases':[]}
    def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    start=time.monotonic()
    for id in CASES:
        c=cases[id];point=c['point'];world=c['products'];folder=out/id;folder.mkdir()
        original=checked_tool(world['live']['artifact']);original_obj=checked_tool(world['live']['generatedSource'])
        bins={k:folder/k for k in wrappers}
        for role,exe in bins.items():
            cmd([cc,*tc['linkerFlags'],'-Wl,--wrap=p118_rt_borrow_scalar_safe',original_obj,wrappers[role],rt,*tc['libraries'],'-o',exe])
        row={'id':id,'producers':{k:pin(v) for k,v in bins.items()},'program':world['live']['generatedSource'],
             'oracles':[],'deltas':[],'samples':{},'calibration':{}}
        r['cases'].append(row);save();args=point['runtimeArgs'];expected=point['expectedStdout']
        before=[]
        for reps in (1,2,3):
            t=time.monotonic()
            child=cmd([bins['count'],*bench.native_runtime_arguments(world['live']),str(reps),'0',*args])
            bench.observation(child.stdout,b'',child.returncode,dict(expectedStdout=expected,repetitions=reps,warmups=0),time.monotonic()-t)
            tokens=child.stderr.decode().split()
            assert tokens[:2]==['P198','guard'] and len(tokens)==6
            before.append(list(map(int,tokens[2:])))
        delta=[b-a for a,b in zip(*before[:2])];repeat=[b-a for a,b in zip(*before[1:])]
        row['observedCounts']=before;row['repeatDeltas']=repeat;row['stableCounts']=delta==repeat
        row['deltas']=dict(zip(['oneRefused','oneAccepted','twoRefused','twoAccepted'],delta))
        del bins['count'];bins['stock']=original
        for inp in ([0,0],[2,17],args):
            want=extra_output(world['c'],inp)
            row['oracles'].append({'input':inp,'expected':want,'outputs':{k:execute(e,inp,0,0,want)[0] for k,e in bins.items()}})
        # A program with zero observed adapter decisions cannot measure this intervention.
        if not any(delta) and not any(repeat):save();continue
        order=list(bins)
        for role,exe in bins.items():
            n=max(1,min(512,point['repetitions']))
            for _ in range(11):
                v,_=execute(exe,args,n,2,expected)
                if 95<=v['elapsedMs']<=320:break
                n=max(1,math.ceil(n*145/max(v['elapsedMs'],1)))
            else:raise ValueError('calibration')
            row['calibration'][role]=[n,v];row['samples'][role]=[]
        for i in range(4):
            for role in order[i:]+order[:i]:
                n=row['calibration'][role][0]
                v,_=execute(bins[role],args,n,2,expected)
                assert v['elapsedMs']>=60
                row['samples'][role].append({'repetitions':n,**v})
        med={k:statistics.median(v['elapsedMs']/v['repetitions'] for v in rows) for k,rows in row['samples'].items()}
        row['overStock']={k:v/med['stock'] for k,v in med.items()};save()
    r['complete']=True;r['wall']=time.monotonic()-start;save()
    print([(x['id'],x['deltas'],x.get('overStock')) for x in r['cases']])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();run(a.out)
