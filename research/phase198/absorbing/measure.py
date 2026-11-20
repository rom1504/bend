"""Compare finite direct-object and independently assembled whole programs on CPU3."""
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
BUILD=ROOT/'selfhost/build'
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute, checked_tool, read, digest, save, bench
sys.path.insert(0,str(ROOT/'research/phase197/discovery-b/absorbing'))
from run import instrument

def invoke(command,allow_link_warning=False):
    p=subprocess.run(command,capture_output=True,timeout=20)
    if p.returncode or (p.stderr and not (allow_link_warning and 'GNU-stack' in p.stderr.decode())):
        raise RuntimeError((command,p.returncode,p.stderr.decode()))
    return p.stdout

def extra_expected(name,n,seed):
    if name=='saturate':return min(7,seed%8+n)^seed
    left=seed%11
    return ((left-min(left,n))*257+seed+min(left,n)*(seed+1))&0xffffffff

def main(out,emission):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    data=read(emission)
    assert data['complete']
    checked_tool(data['nativeReceipt']);checked_tool(data['referenceReceipt'])
    assets=read(BUILD/'phase194/assets.json'); policy=assets['toolchains']['x86']
    as_,cc,runtime=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    refs={r['id']:r for r in read(BUILD/'phase195/references01/manifest.json')['cases']}
    result=dict(method=digest(__file__),emission=digest(emission),assets=digest(BUILD/'phase194/assets.json'),
                references=data['referenceReceipt'],native=data['nativeReceipt'],complete=False,cases={},
                qualification={'maxCellMedian':0.98,'minCellWins':3,'pairsPerCell':4})
    for case in data['cases']:
        name=case['id']
        if 'refusal' in case:
            result['cases'][name]=dict(authoredRefusal=case['refusal']);continue
        directory=out/name; directory.mkdir()
        paths={}; counters={}; stats=dict(products={},counts=[],correctness=[],privateABI={},samples=[],calibration=[],ratios=[])
        result['cases'][name]=stats
        for role,p in case['products'].items():
            original=Path(checked_tool(p['assembly']))
            obj=Path(checked_tool(p['object']))
            objects={'direct':obj}
            rendered=directory/(role+'-default.o')
            invoke([as_,'-o',rendered,original]);objects['default']=rendered
            if name.startswith('coverage-bst'):
                src=directory/(role+'-counts.s')
                lines=original.read_text().splitlines()
                src.write_text('\n'.join(instrument(lines))+'\n')
                counted=directory/(role+'-counts.o')
                invoke([as_,*policy['assemblerFlags'],'-o',counted,src]);objects['counts']=counted
            for layout,object_file in objects.items():
                key=layout+'-'+role
                exe=directory/key
                extras=[ROOT/'research/phase197/discovery-b/absorbing/counts.c'] if layout=='counts' else []
                invoke([cc,*policy['linkerFlags'],object_file,runtime,*extras,*policy['libraries'],'-o',exe],True)
                if layout=='counts':counters[role]=exe
                else:paths[key]=exe
                stats['products'][key]=dict(path=str(exe.relative_to(ROOT)),hash=digest(exe),object=digest(object_file))
                if name.startswith('coverage-bst') and layout!='counts':
                    observer=ROOT/'research/phase197/discovery-b/absorbing/boundaries.c'
                    private=directory/(key+'-boundaries')
                    invoke([cc,*policy['linkerFlags'],'-Wl,--wrap=main',object_file,runtime,observer,*policy['libraries'],'-o',private],True)
                    assert invoke([private])==b'72\n'
                    stats['privateABI'][key]=dict(checks=72,observer=digest(observer),binary=digest(private))
        if 'qualified' in case: paths['qualified']=checked_tool(case['qualified'])
        primary=case['inputs']
        if name in refs:
            more={'tree-bitonic':[[3,3],[6,17],[9,123]]}.get(name,[[0,17],[1,3],[32,0],[61,123],[64,17]])
        else:more=[[0,11],[1,6],[2,7],[7,21],[64,0],[257,4294967295]]
        for i,point in enumerate([primary,*more]):
            reps=int(i==0);expected=str(case['expected'])+'\n' if i==0 else None
            if name in refs:
                cr=refs[name]['products']['c']
                c,expected=execute(checked_tool(cr['artifact']),point,reps,0,expected,cr['runtimeArgumentConvention'])
                c['artifact']=cr['artifact']
            else:
                c=dict(independentFormula=extra_expected(name,*point))
                expected=str(c['independentFormula'])+'\n'
            checks={k:execute(path,point,reps,0,expected)[0] for k,path in paths.items()}
            stats['correctness'].append(dict(inputs=point,expected=expected,oracle=c,checks=checks))
            if counters:
                ev={}
                for role,path in counters.items():
                    cmd=[str(path),*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'0','0',*map(str,point)]
                    t=time.monotonic();p=subprocess.run(cmd,capture_output=True,check=True,timeout=8)
                    bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),time.monotonic()-t)
                    m=re.fullmatch(rb'calls=(\d+) steps=(\d+) leaves=(\d+)\n',p.stderr);assert m
                    ev[role]=dict(zip(['calls','steps','leaves'],map(int,m.groups())))
                assert ev['base']['calls']==ev['candidate']['calls']
                assert ev['base']['steps']-ev['candidate']['steps']==ev['base']['leaves']-ev['candidate']['leaves']>=0
                stats['counts'].append(dict(args=point,**ev))
        if not case['changed']:
            stats['timing']='unchanged object';save(out/'result.json',result);continue
        expected=str(case['expected'])+'\n'
        n=refs[name]['point']['repetitions'] if name in refs else 1000
        for _ in range(10):
            v,_=execute(paths['direct-base'],primary,n,2,expected)
            stats['calibration'].append(dict(count=n,**v))
            if 175<=v['elapsedMs']<=375:break
            n=max(1,math.ceil(n*235/max(1,v['elapsedMs'])))
        else:raise ValueError(name+' calibration')
        for session in [0,1]:
            for ri in range(4):
                for layout in (['direct','default'] if (ri+session)%2==0 else ['default','direct']):
                    roles=['base','candidate'] if (ri+session+(layout=='default'))%2==0 else ['candidate','base']
                    for role in roles:
                        v,_=execute(paths[layout+'-'+role],primary,n,4,expected)
                        assert v['elapsedMs']>0
                        stats['samples'].append(dict(session=session,round=ri,layout=layout,role=role,count=n,**v))
                save(out/'result.json',result)
            for layout in ['direct','default']:
                def times(role):
                    return [s['elapsedMs'] for s in stats['samples'] if (s['session'],s['layout'],s['role'])==(session,layout,role)]
                pairs=[b/a for a,b in zip(times('base'),times('candidate'))]
                stats['ratios'].append(dict(session=session,layout=layout,median=statistics.median(pairs),faster=sum(v<1 for v in pairs),pairs=pairs))
        stats['meetsThreshold']=all(r['median']<=0.98 and r['faster']>=3 for r in stats['ratios'])
        save(out/'result.json',result)
    result['complete']=True;save(out/'result.json',result)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--emission',type=Path,required=True)
    a=p.parse_args();main(a.out.resolve(),a.emission.resolve())
