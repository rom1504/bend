"""Run the exact current qualified RLE worker with a named hot-spine diagnostic."""
from pathlib import Path
import argparse
import json
import math
import os
import re
import statistics
import subprocess
import sys
import time
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, read, execute, save, bench, digest
OWNER='p113d_FID_'+''.join(str(ord(c))+'_' for c in '$direct.lrevp.go')

def run(cmd,timeout=15):
    started=time.monotonic()
    p=subprocess.run(cmd,capture_output=True,timeout=timeout)
    if p.returncode:raise RuntimeError((list(map(str,cmd)),p.returncode,p.stderr.decode()))
    return p,time.monotonic()-started

def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    AS=read(ASSETS); pol=AS['toolchains']['x86']
    assembler,cc,rt=[checked_tool(AS['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    name='test-rle-roundtrip'; ref=next(r for r in read(REFERENCES)['cases'] if r['id']==name)
    cat=ref['point']; mature=ref['products']['c']
    machine=ROOT/'selfhost/build/phase195/native45-02'/name/'machine'; original=read(machine/'report.json')
    for p in original['inputs']: checked_tool(p)
    cmd=original['compilerCommand'].copy();assert cmd[8]=='x86-object';cmd[8]='x86'
    emission,se=run(cmd,60);src=emission.stdout.decode();at=src.index('\n'+OWNER+':\n')+len(OWNER)+3
    block=src[at:src.index('.size '+OWNER+',',at)]
    assert re.findall(r'^  call (\w+)$',block,re.M)==['p125_rt_take2','p125_rt_ctor2','p111_rt_fail']
    assert '  movabsq $17, %r11\n' in block and '  movabsq $18, %r11\n' in block
    def table(n,d):
        rows=src.split('\n'+n+':\n',1)[1].split('\n.size',1)[0]
        return [l.split()[1] for l in rows.splitlines() if l.startswith(d)]
    assert int(table('p111_cid_hot','.byte')[18])==1 and int(table('p111_cid_arity','.byte')[18])==2
    desc=table('p111_program','.quad');assert [int(desc[i]) for i in [0,1,8,11]]==[11102,192,52,15]
    baseline=out/'baseline.s';baseline.write_text(src)
    changed=out/'candidate.s';changed.write_text(src[:at]+'  jmp p198_reverse\n.globl p198_reverse_original\np198_reverse_original:\n'+src[at:])
    res=dict(complete=False,driver=digest(__file__),compilerSeconds=se,command=cmd,original=original['object'],sources={p.name:digest(p) for p in [baseline,changed,HERE/'rotate.c',HERE/'control.c']},products={},rows=[],checks=[],samples=[])
    def checkpoint():save(out/'report.json',res)
    checkpoint()
    def build(layout,variant,kind):
        key=layout+'-'+variant+('-'+kind if kind else '')
        obj=out/(key+'.o');exe=out/key
        inp=baseline if variant=='baseline' else changed
        run([assembler,*(pol['assemblerFlags'] if layout=='project' else []),'-o',obj,inp])
        extras=[]
        if variant=='candidate':
            extras+=[HERE/'rotate.c']
            if kind=='events':extras+=['-DP198_EVENTS=1']
            if kind=='controls':extras+=['-Wl,--wrap=p125_rt_ctor2',HERE/'control.c']
        run([cc,*pol['linkerFlags'],'-O2',obj,rt,*extras,*pol['libraries'],'-o',exe])
        res['products'][key]={'binary':digest(exe),'object':digest(obj)}
        return exe
    paths={l:{r:build(l,r,None) for r in ('baseline','candidate')} for l in ('project','default')}
    events=build('project','candidate','events');controls=build('project','candidate','controls');checkpoint()
    for opt in ([0,0],[7,11]):
        n=1
        c,ex=execute(checked_tool(mature['artifact']),opt,n,0,cat['expectedStdout'],mature['runtimeArgumentConvention'])
        results={l+'-'+r:execute(exe,opt,n,0,ex)[0] for l,d in paths.items() for r,exe in d.items()}
        direct=execute(checked_tool(original['binary']),opt,n,0,ex)[0]
        res['checks'].append(dict(args=opt,c=c,direct=direct,projected=results))
    for lbl,exe in [('events',events),('boundaries',controls)]:
        argv=[exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'0','0','0','0']
        q,wall=run(argv);(out/(lbl+'.stderr')).write_bytes(q.stderr)
        bench.observation(q.stdout,b'',q.returncode,dict(expectedStdout=cat['expectedStdout'],repetitions=0,warmups=0),wall)
        if lbl=='events':
            match=re.fullmatch(rb'ev (\d+) (\d+) (\d+) (\d+) (\d+)\n',q.stderr);assert match
            res[lbl]=dict(zip(('entries','rawSteps','rfcRotations','fallbacks','finished'),map(int,match.groups())))
        else:
            assert re.fullmatch(rb'checks=\d+\n',q.stderr),q.stderr
            res[lbl]=q.stderr.decode()
        checkpoint()
    n=200000
    for _ in range(8):
        v,_=execute(paths['project']['baseline'],cat['runtimeArgs'],n,4,cat['expectedStdout'])
        if 155<=v['elapsedMs']<=365:break
        n=max(1,math.ceil(n*210/max(1,v['elapsedMs'])))
    else:raise ValueError('calibration')
    cexe=checked_tool(mature['artifact']);cconv=mature['runtimeArgumentConvention'];nc=n
    for _ in range(8):
        v,_=execute(cexe,cat['runtimeArgs'],nc,4,cat['expectedStdout'],cconv)
        if 150<=v['elapsedMs']<=365:break
        nc=max(1,math.ceil(nc*190/max(1,v['elapsedMs'])))
    else:raise ValueError('mature-C calibration')
    def cobs(i):
        v,_=execute(cexe,cat['runtimeArgs'],nc,4,cat['expectedStdout'],cconv)
        assert v['elapsedMs']>=100
        res['samples'].append(dict(layout='mature',role='c',round=i,repetitions=nc,**v))
    for i in range(6):
        if i%2==0:cobs(i)
        for layout in (('default','project') if i%2 else ('project','default')):
            for role in (('candidate','baseline') if (i+(layout=='project'))%2 else ('baseline','candidate')):
                v,_=execute(paths[layout][role],cat['runtimeArgs'],n,4,cat['expectedStdout'])
                assert v['elapsedMs']>=100
                res['samples'].append(dict(layout=layout,role=role,round=i,repetitions=n,**v))
        if i%2:cobs(i)
        checkpoint()
    res['summary']={}
    for layout in paths:
        times=lambda r:[x['elapsedMs'] for x in res['samples'] if x['layout']==layout and x['role']==r]
        ratios=[c/b for c,b in zip(times('candidate'),times('baseline'))]
        res['summary'][layout]=dict(ratios=ratios,median=statistics.median(ratios),faster=sum(x<1 for x in ratios),candidateOverMatureC=(statistics.median(times('candidate'))/n)/(statistics.median(x['elapsedMs'] for x in res['samples'] if x['layout']=='mature')/nc))
    res['complete']=True;checkpoint()
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    main(p.parse_args().out)
