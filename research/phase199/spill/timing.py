"""Compare actual checked compiler objects to the qualified progress image and C."""
import argparse
from collections import Counter
import hashlib
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
from measure import ASSETS, REFERENCES, checked_tool, execute, read

def pin(file):
    p=Path(file).resolve()
    return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def owner(obj,name):
    symbol='p113d_FID_'+''.join(str(ord(c))+'_' for c in name)
    lines=subprocess.check_output(['objdump','-dw','--no-show-raw-insn','--disassemble='+symbol,obj],text=True).splitlines()
    ins=[v for v in lines if re.match(r'^\s*[a-f0-9]+:\s+[a-z]',v)]
    offsets=Counter()
    for v in ins:
        m=re.search(r'-0x([a-f0-9]+)\(%rbp\)',v)
        if m:offsets[int(m[1],16)]+=1
    return dict(instructions=len(ins),frameAccesses=sum(offsets.values()),frameOffsets=dict(sorted(offsets.items())))

def run(out,emission):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True,exist_ok=False)
    r={'complete':False,'method':pin(__file__),'emission':pin(emission),'cases':[]}
    def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    auth=read(emission);assert auth['complete']
    manifest=BUILD/'phase198/progress-native45-01/programs.manifest.json'
    cases={c['id']:c for c in read(manifest)['cases']}
    refs={c['id']:c for c in read(REFERENCES)['cases']}
    assets=read(ASSETS);policy=assets['toolchains']['x86'];r['manifest']=pin(manifest);r['assets']=pin(ASSETS)
    asm,link,rt=[checked_tool(assets['assets'][n]) for n in ('assembler','linker','qbe-runtime')]
    def linkobj(obj,e):
        subprocess.run([link,*policy['linkerFlags'],obj,rt,*policy['libraries'],'-o',e],check=True,capture_output=True,timeout=12)
    for ci,row in enumerate(auth['cases']):
        case=row['id'];d=out/case;d.mkdir()
        orig=cases[case];direct=orig['products']['candidate'];c=refs[case]['products']['c']
        pt=orig['point'];assert row['source']==orig['source']==refs[case]['source'] and row['baseline']==direct['generatedSource']
        co=Path(checked_tool(row['object']));bo=Path(checked_tool(direct['generatedSource']))
        programs={'baseline':Path(checked_tool(direct['artifact'])),'candidate':d/'program','c':Path(checked_tool(c['artifact']))}
        linkobj(co,programs['candidate'])
        hot='$direct.mit' if case=='mandelbrot' else '$product.row'
        orig_owner=owner(bo,hot);candidate_owner=owner(co,hot)
        counts={str(v):candidate_owner['frameOffsets'].get(v,0)-orig_owner['frameOffsets'].get(v,0) for v in set(candidate_owner['frameOffsets'])|set(orig_owner['frameOffsets'])}
        rec=dict(id=case,objectChanged=row['objectChanged'],owner=hot,original=orig_owner,candidate=candidate_owner,
                 offsetChanges={k:v for k,v in counts.items() if v},binaries={},checks=[],times=[],calibration={},comparisons={})
        r['cases'].append(rec)
        if case=='editdist':
            legacy=BUILD/'phase197/shared-emission01/combined'/case/'program.s'
            assert pin(legacy.with_suffix('.o'))['sha256']==pin(bo)['sha256']
            rec['baselineRender']=pin(legacy)
            for lay,flags in [('project',policy['assemblerFlags']),('default',[])]:
                for role,source in [('baseline',legacy),('candidate',checked_tool(row['assembly']))]:
                    k=lay+'-'+role;o=d/(k+'.o');e=d/k
                    subprocess.run([asm,*flags,'-o',o,source],check=True,capture_output=True,timeout=15)
                    linkobj(o,e);programs[k]=e
        rec['binaries']={k:pin(p) for k,p in programs.items()}
        args=[[0,3],[1,4294967295],[2,29],[3,123]] if case!='complete-generic-row32' else [[0,3],[1,4294967295],[7,29],[32,123]]
        for j,v in enumerate([pt['runtimeArgs'],*args]):
            reps=int(j==0)
            oracle,expect=execute(programs['c'],v,reps,0,pt['expectedStdout'] if j==0 else None,c['runtimeArgumentConvention'])
            rec['checks'].append(dict(inputs=v,expected=expect,oracle=oracle,observations={
                k:execute(pr,v,reps,0,expect,direct['runtimeArgumentConvention'])[0] for k,pr in programs.items() if k!='c'}))
        save()
        ns={}
        for k in ['baseline','c']:
            n=max(1,pt['repetitions']//4)
            hist=[]
            for _ in range(12):
                obs,_=execute(programs[k],pt['runtimeArgs'],n,3,pt['expectedStdout'],(c if k=='c' else direct)['runtimeArgumentConvention'])
                ms=obs['elapsedMs'];hist.append([n,ms])
                if 115<=ms<=300:break
                n=max(1,math.ceil(n*165/max(ms,1)))
            else:raise ValueError('calibration '+case+' '+k)
            ns[k]=n;rec['calibration'][k]=hist
        # Physical direct-object counterbalance. Each role occupies all three
        # positions twice; C uses independently calibrated complete invocations.
        for turn in range(6):
            roles=['baseline','candidate','c']
            if turn>=3:roles.reverse()
            rot=(turn+ci)%3;roles=roles[rot:]+roles[:rot]
            for pos,k in enumerate(roles):
                n=ns['c' if k=='c' else 'baseline']
                obs,_=execute(programs[k],pt['runtimeArgs'],n,3,pt['expectedStdout'],(c if k=='c' else direct)['runtimeArgumentConvention'])
                rec['times'].append(dict(turn=turn,position=pos,role=k,count=n,**obs))
        if case=='editdist':
            for turn in range(4):
                for lay in (['project','default'] if turn%2==0 else ['default','project']):
                    roles=['baseline','candidate']
                    if (turn in (1,2)) == (lay=='project'):roles.reverse()
                    for pos,role in enumerate(roles):
                        k=lay+'-'+role;n=ns['baseline']
                        obs,_=execute(programs[k],pt['runtimeArgs'],n,3,pt['expectedStdout'],direct['runtimeArgumentConvention'])
                        rec['times'].append(dict(turn=turn,position=pos,role=k,count=n,**obs))
        def rates(k):
            return [v['elapsedMs']/v['count'] for v in rec['times'] if v['role']==k]
        def compare(a,b):
            ratios=[y/x for x,y in zip(rates(a),rates(b))]
            return dict(median=statistics.median(ratios),wins=sum(x<1 for x in ratios),raw=ratios)
        rec['comparisons']['direct']=compare('baseline','candidate')
        rec['comparisons']['candidateOverC']=compare('c','candidate')
        if case=='editdist':
            for lay in ['project','default']:rec['comparisons'][lay]=compare(lay+'-baseline',lay+'-candidate')
        save()
        print(case,{k:round(v['median'],5) for k,v in rec['comparisons'].items()},flush=True)
    r['complete']=True;save()

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--emission',required=True,type=Path)
    a=p.parse_args();run(a.out.resolve(),a.emission.resolve())
