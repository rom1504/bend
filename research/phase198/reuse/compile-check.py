"""Build and exercise actual emitted direct and GNU-as objects under the real serial runtime."""
from pathlib import Path
import argparse
import json
import math
import os
import statistics
import subprocess
import sys
import time
from project import HERE, ROOT, OWNER
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, read, execute, save, bench, digest

def run(cmd):
    p=subprocess.run(cmd,capture_output=True,timeout=15)
    if p.returncode:
        raise RuntimeError((cmd,p.returncode,p.stderr.decode()))
    return p

def marker_boundaries():
    # The independently frozen ceiling tested eligibility counts too. Object
    # controls below cannot observe markers and assert identities/lifetimes only.
    src=(HERE/'boundaries.c').read_text()
    src=src[:src.index('W p198_controls(void *s,W wa,W wb)')]+src[src.index('W p198_controls(void *s,W wa,W wb)'):].replace('W p198_controls(void *s,W wa,W wb)','static void exercise(void *s)').replace('    return p198_subject(s,wa,wb);','')
    for line in ('            W before=p198_transpose_counts[1];\n','            check(p198_transpose_counts[1]-before==(i==RAW && j==RAW));\n',
                 '        W mixed=p198_transpose_counts[1];\n','        check(p198_transpose_counts[1]==mixed);\n'):
        assert src.count(line)==1
        src=src.replace(line,'')
    src=src.replace('p198_subject',OWNER)
    # Interpose only in this separate run. A real benchmark call supplies
    # real initialized serial state and data tables before testing the worker.
    return src+f'''
extern W __real_p125_rt_ctor2(void *,unsigned,const W *);
W __wrap_p125_rt_ctor2(void *s,unsigned cid,const W *fields) {{
    if (!exercised) exercise(s);
    return __real_p125_rt_ctor2(s,cid,fields);
}}
'''

def main(out,emitted):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    emission=read(emitted);assert emission['complete'] and len(emission['controls'])==267
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    assets=read(ASSETS); pol=assets['toolchains']['x86']
    as_,cc,rt=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    res=dict(inputs=dict(driver=digest(__file__),emission=digest(emitted)),cases=[],complete=False)
    for case in emission['cases']:
        name=case['id']; ref=refs[name]; given=ref['point']
        asm=checked_tool(case['assembly']); ob=checked_tool(case['object'])
        assert case['plans']==[OWNER],case
        base=ROOT/'selfhost/build/phase195/native45-02'/name/'machine'
        baseobj=checked_tool(read(base/'report.json')['object'])
        paths={}
        d=out/name;d.mkdir(); ctrl=d/'controls.c';ctrl.write_text(marker_boundaries())
        r=dict(id=name,controls={},products={},oracles=[],samples=[]);res['cases'].append(r)
        for layout in ('direct','project'):
            for role in ('base','candidate'):
                key=layout+'-'+role
                obj=Path(ob if role=='candidate' else baseobj)
                if layout=='project':
                    src=asm if role=='candidate' else ROOT/'selfhost/build/phase197/discoveryBTiming01/tree-bitonic/project-baseline/program.s'
                    obj=d/(key+'.o');run([as_,*pol['assemblerFlags'],'-o',obj,src])
                exe=d/key;run([cc,*pol['linkerFlags'],obj,rt,*pol['libraries'],'-o',exe])
                paths[key]=exe;r['products'][key]=dict(binary=digest(exe),object=digest(obj))
                if role=='candidate':
                    exe=d/(key+'-controls')
                    run([cc,*pol['linkerFlags'],'-Wl,--wrap=p125_rt_ctor2',obj,rt,ctrl,*pol['libraries'],'-o',exe])
                    cmd=[exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'1','0',*map(str,given['runtimeArgs'])]
                    st=time.monotonic();p=run(cmd);wall=time.monotonic()-st
                    bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=given['expectedStdout'],repetitions=1,warmups=0),wall)
                    assert p.stderr==b'boundaries=185\n',p.stderr
                    r['controls'][key]=dict(stderr=p.stderr.decode(),stdout=p.stdout.decode())
        for a in ([8,0],[6,17],[9,123],[0,0],[1,3],[2,5],[4,9],[8,371],[10,17]):
            n=int(list(a)==given['runtimeArgs']);c=ref['products']['c']
            cp,e=execute(checked_tool(c['artifact']),a,n,0,given['expectedStdout'] if n else None,c['runtimeArgumentConvention'])
            other={k:execute(v,a,n,0,e)[0] for k,v in paths.items()}
            r['oracles'].append(dict(args=a,c=cp,others=other))
        count=given['repetitions']
        for _ in range(8):
            v,_=execute(paths['direct-base'],given['runtimeArgs'],count,4,given['expectedStdout'])
            if 160<=v['elapsedMs']<=380: break
            count=max(1,math.ceil(count*210/max(1,v['elapsedMs'])))
        else: raise ValueError('calibration')
        mature=ref['products']['c']
        cexe=checked_tool(mature['artifact']); n_c=count
        for _ in range(8):
            v,_=execute(cexe,given['runtimeArgs'],n_c,4,given['expectedStdout'],mature['runtimeArgumentConvention'])
            if 155<=v['elapsedMs']<=380:break
            n_c=max(1,math.ceil(n_c*215/max(1,v['elapsedMs'])))
        else: raise ValueError('mature calibration')
        def mature_obs(i):
            ob,_=execute(cexe,given['runtimeArgs'],n_c,4,given['expectedStdout'],mature['runtimeArgumentConvention'])
            assert ob['elapsedMs']>=100
            r['samples'].append(dict(layout='mature',role='c',round=i,count=n_c,**ob))
        for i in range(6):
            if i%2==0: mature_obs(i)
            for layout in (('direct','project') if i%2 else ('project','direct')):
                for role in (('base','candidate') if (i+(layout=='direct'))%2 else ('candidate','base')):
                    ob,_=execute(paths[layout+'-'+role],given['runtimeArgs'],count,4,given['expectedStdout'])
                    assert ob['elapsedMs']>=100
                    r['samples'].append(dict(layout=layout,role=role,round=i,count=count,**ob))
            if i%2: mature_obs(i)
            save(out/'report.json',res)
        r['summary']={}
        for layout in ['direct','project']:
            by=lambda role:[x['elapsedMs'] for x in r['samples'] if x['layout']==layout and x['role']==role]
            ratios=[x/y for x,y in zip(by('candidate'),by('base'))]
            r['summary'][layout]=dict(paired=ratios,median=statistics.median(ratios),faster=sum(x<1 for x in ratios),
                                    candidateOverMatureC=statistics.median(by('candidate'))/count/(statistics.median(x['elapsedMs'] for x in r['samples'] if x['role']=='c')/n_c))
    res['complete']=True;save(out/'report.json',res)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--emission',type=Path,required=True)
    a=p.parse_args();main(a.out,a.emission)
