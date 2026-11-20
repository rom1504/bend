"""Verify outputs and real heap boundaries and time both object encoders."""
from pathlib import Path
import argparse
import math
import os
import statistics
import subprocess
import sys
import time
from screen import H, HERE, ROOT, ASSETS, REFERENCES, checked_tool as checked_path, read, execute, save, bench, sha


def checked_tool(pin):
    return Path(checked_path(pin))

def run(args):
    p=subprocess.run(list(map(str,args)),capture_output=True,timeout=25)
    if p.returncode:raise RuntimeError((list(map(str,args)),p.returncode,p.stdout[-300:],p.stderr[-2000:]))
    return p


def observed(exe,conv,args,n,warm,expected):
    x,_=execute(exe,args,n,warm,expected,conv);return x


def count_for(exe,conv,point):
    n=point['repetitions']
    for _ in range(8):
        x=observed(exe,conv,point['runtimeArgs'],n,4,point['expectedStdout'])
        if 155<=x['elapsedMs']<=340:return n
        n=max(1,math.ceil(n*200/max(1,x['elapsedMs'])))
    raise ValueError('calibration')


def leaf_arrays(depth,seed):
    if depth==0:return [seed]
    return leaf_arrays(depth-1,(seed*29+3)%2**32)+leaf_arrays(depth-1,(seed*13+5)%2**32)


def signature(xs):
    if len(xs)==1:return xs[0]
    mid=len(xs)//2;return (71*signature(xs[:mid])+signature(xs[mid:]))%2**32


def main(emission,out):
    assert os.sched_getaffinity(0)=={3}
    data=read(emission);assert data['complete'];out.mkdir()
    refs={r['id']:r for r in read(REFERENCES)['cases']};assets=read(ASSETS)
    a,cc,rt=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    policy=assets['toolchains']['x86'];case=next(r for r in data['cases'] if r['id']=='tree-bitonic')
    asm=checked_tool(case['assembly']);ob=checked_tool(case['object']);assert case['plans']==[H]
    base_dir=ROOT/'selfhost/build/phase195/native45-02/tree-bitonic/machine'
    bobj=checked_tool(read(base_dir/'report.json')['object']);bassembly=ROOT/'selfhost/build/phase197/discoveryBTiming01/tree-bitonic/project-baseline/program.s'
    ref=refs['tree-bitonic'];pt=ref['point'];c=ref['products']['c'];mature=checked_tool(c['artifact'])
    native='bend-rts-v1';cconv=c['runtimeArgumentConvention']
    report=dict(complete=False,inputs=dict(emission=sha(emission),method=sha(Path(__file__)),controls=sha(HERE/'control.c')),products={},checks=[],controls={},samples=[])
    persist=lambda:save(out/'report.json',report)
    def assemble(name,src):
        obj=out/(name+'.o');run([a,*policy['assemblerFlags'],'-o',obj,src]);return obj
    def link(name,obj,extra=()):
        exe=out/name;run([cc,*policy['linkerFlags'],'-O2',obj,rt,*extra,*policy['libraries'],'-o',exe]);return exe
    object_paths={'direct-base':bobj,'project-base':assemble('project-base',bassembly),'direct-fused':ob,'project-fused':assemble('project-fused',asm)}
    paths={k:link(k,v) for k,v in object_paths.items()};paths['mature']=mature
    report['products']={k:dict(binary=sha(exe),object=sha(object_paths[k]) if k in object_paths else None) for k,exe in paths.items()};persist()
    for point in ([8,0],[0,0],[1,3],[2,17],[3,7],[5,0],[6,17],[9,123],[10,17],[11,9]):
        n=int(point==pt['runtimeArgs']);cobs,want=execute(mature,point,n,0,pt['expectedStdout'] if n else None,cconv)
        report['checks'].append(dict(args=point,expected=want,mature=cobs,observations={k:observed(exe,native,point,n,0,want) for k,exe in paths.items() if k!='mature'}));persist()
    # Direct and rendered products are untouched. A third, isolated derivative
    # observes the exact slow-label transition to validate precommit refusal.
    ctl=out/'positive-and-alias-controls.c';raw=(HERE/'control.c').read_text()
    old='check(seen_fallback==expect_fallback);';assert raw.count(old)==1
    ctl.write_text(raw.replace(old,'(void)expect_fallback;'))
    alias=lambda logical,physical:'-Wl,--defsym='+logical+'='+physical
    baseargs=[alias('p198_warp',H),'-Wl,--wrap=p198_warp_original','-Wl,--wrap=p125_rt_ctor2']
    slow='p198w_original_'+H
    text=asm.read_text();before='\n'+slow+':\n';assert text.count(before)==1
    tapped=out/'tapped.s';tapped.write_text(text.replace(before,before+'  jmp p198_test_observe\n.globl p198_test_untapped\np198_test_untapped:\n'))
    for k,v in [('direct',ob),('project',object_paths['project-fused']),('tapped',assemble('tapped',tapped))]:
        tap=k=='tapped';extra=[*baseargs,alias('p198_warp_original','p198_test_untapped' if tap else slow)]
        if tap:extra.append(alias('p198_test_observe','__wrap_p198_warp_original'))
        exe=link('controls-'+k,v,[*extra,HERE/'control.c' if tap else ctl]);tic=time.monotonic()
        p=run([exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':native}),'0','0',*map(str,pt['runtimeArgs'])]);wall=time.monotonic()-tic
        assert p.stderr.startswith(b'checks=') and int(p.stderr.split(b'=')[1])>=32500,p.stderr
        if tap:assert p.stderr==b'checks=32840\n',p.stderr
        x=bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=pt['expectedStdout'],repetitions=0,warmups=0),wall)
        report['controls'][k]=dict(stderr=p.stderr.decode(),stdout=p.stdout.decode(),observed=x,exe=sha(exe));persist()
    for row in data['cases']:
        if row['id']!='envelope':continue
        left=leaf_arrays(4,23);right=leaf_arrays(4,34);want=(signature(list(map(min,left,right)))*71+signature(list(map(max,left,right))))%2**32
        binaries=[]
        for k,obj in [('direct',checked_tool(row['object'])),('project',assemble('envelope-project',checked_tool(row['assembly'])))]:
            exe=link('envelope-'+k,obj);p=run([exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':native})]);assert p.stderr==b'' and p.stdout.strip()==str(want).encode(),(want,p.stdout,p.stderr);binaries.append(dict(layout=k,object=sha(obj),binary=sha(exe),stdout=p.stdout.decode()))
        report['independent']=dict(size=4,seed=23,oracle=want,binaries=binaries);persist()
    roles=list(paths);ns={k:count_for(exe,cconv if k=='mature' else native,pt) for k,exe in paths.items()}
    for i in range(6):
        start=i%len(roles);order=roles[start:]+roles[:start]
        if i%2:order.reverse()
        for k in order:
            obs=observed(paths[k],cconv if k=='mature' else native,pt['runtimeArgs'],ns[k],4,pt['expectedStdout']);assert obs['elapsedMs']>=100
            report['samples'].append(dict(round=i,role=k,count=ns[k],**obs))
        persist()
    rates=lambda k:[x['elapsedMs']/x['count'] for x in report['samples'] if x['role']==k]
    report['summary']={}
    for k in ['direct','project']:
        fused=rates(k+'-fused');base=rates(k+'-base');paired=[x/y for x,y in zip(fused,base)]
        report['summary'][k]=dict(paired=paired,median=statistics.median(paired),faster=sum(x<1 for x in paired),fusedOverMatureC=statistics.median(fused)/statistics.median(rates('mature')))
    report['complete']=True;persist();print(report['summary'])

if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--emission',type=Path,required=True);a.add_argument('--out',type=Path,required=True)
    p=a.parse_args();main(p.emission,p.out)
