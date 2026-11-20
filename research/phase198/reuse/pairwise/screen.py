"""Compare original, local permutation and complete recursive tree-fusion projections."""
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
sys.path.insert(0,str(HERE.parent))
from project import BASE, ROOT, project, sha
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, read, execute, save, bench
H='p114r_FID_'+''.join(str(ord(c))+'_' for c in '$direct.warp')

def run(cmd):
    st=time.monotonic();p=subprocess.run(cmd,capture_output=True,timeout=15)
    if p.returncode:raise RuntimeError((list(map(str,cmd)),p.returncode,p.stderr.decode()))
    return p,time.monotonic()-st

def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    AS=read(ASSETS);pol=AS['toolchains']['x86']
    as_,cc,rt=[checked_tool(AS['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    ref=next(r for r in read(REFERENCES)['cases'] if r['id']=='tree-bitonic')
    point=ref['point'];c=ref['products']['c'];cexe=checked_tool(c['artifact'])
    src=BASE.read_text();at=src.index('\n'+H+':\n')+len(H)+3
    assert src.count('call '+H+'\n')==1
    variants={'baseline':project(src,False,False),'permute':project(src,True,False),
              'fused':src[:at]+'  jmp p198_warp\n.globl p198_warp_original\np198_warp_original:\n'+src[at:]}
    res=dict(complete=False,base=sha(BASE),sources={p.name:sha(p) for p in [HERE/'fused.c',HERE/'control.c',Path(__file__),HERE.parent/'project.py']},products={},checks=[],samples=[],counts=[])
    checkpoint=lambda: save(out/'report.json',res)
    for k,s in variants.items():(out/(k+'.s')).write_text(s)
    def build(layout,role,kind=None):
        key=layout+'-'+role+('-'+kind if kind else '');obj=out/(key+'.o');exe=out/key
        run([as_,*(pol['assemblerFlags'] if layout=='project' else []),'-o',obj,out/(role+'.s')])
        if layout=='project' and role=='baseline':assert sha(obj)==sha(BASE.with_suffix('.o'))
        extra=([HERE/'fused.c'] if role=='fused' else [])
        if kind=='events':extra+=['-DP198_EVENTS=1']
        if kind=='controls':extra+=['-Wl,--wrap=p125_rt_ctor2','-Wl,--wrap=p198_warp_original',HERE/'control.c']
        run([cc,*pol['linkerFlags'],'-O2',obj,rt,*extra,*pol['libraries'],'-o',exe])
        res['products'][key]=dict(object=sha(obj),binary=sha(exe));return exe
    paths={l:{r:build(l,r) for r in variants} for l in ['default','project']}
    counts=build('project','fused','events');controls=build('project','fused','controls')
    checkpoint()
    for args in [[8,0],[0,0],[1,3],[2,17],[3,7],[5,0],[6,17],[9,123],[10,17],[11,9]]:
        rep=int(args==point['runtimeArgs'])
        co,ex=execute(cexe,args,rep,0,point['expectedStdout'] if rep else None,c['runtimeArgumentConvention'])
        vals={l+'-'+r:execute(exe,args,rep,0,ex)[0] for l,d in paths.items() for r,exe in d.items()}
        res['checks'].append(dict(args=args,expected=ex,c=co,observations=vals))
        argv=[*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'0','0',*map(str,args)]
        p,wall=run([counts,*argv]);bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=ex,repetitions=0,warmups=0),wall)
        m=re.fullmatch(rb'counts (\d+) (\d+) (\d+) (\d+) (\d+)\n',p.stderr);assert m
        res['counts'].append(dict(args=args,**dict(zip(('entries','hits','leaves','swaps','fallback'),map(int,m.groups())))))
        if rep:
            p,wall=run([controls,*argv]);(out/'boundaries.stderr').write_bytes(p.stderr)
            assert re.fullmatch(rb'checks=\d+\n',p.stderr),p.stderr
            bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=ex,repetitions=0,warmups=0),wall);res['boundaries']=p.stderr.decode()
        checkpoint()
    def calibrate(exe,conv,count):
        for _ in range(8):
            v,_=execute(exe,point['runtimeArgs'],count,4,point['expectedStdout'],conv)
            if 150<=v['elapsedMs']<=350:return count
            count=max(1,math.ceil(count*205/max(1,v['elapsedMs'])))
        raise ValueError('calibration')
    counts={r:calibrate(exe,'bend-rts-v1',point['repetitions']) for r,exe in paths['project'].items()}
    nc=calibrate(cexe,c['runtimeArgumentConvention'],point['repetitions'])
    for i in range(6):
        if i%2:layouts=['default','mature','project']
        else:layouts=['project','mature','default']
        for layout in layouts:
            if layout=='mature':
                v,_=execute(cexe,point['runtimeArgs'],nc,4,point['expectedStdout'],c['runtimeArgumentConvention'])
                res['samples'].append(dict(layout=layout,role='c',round=i,count=nc,**v));continue
            roles=list(variants);start=(i+(layout=='default'))%3;roles=roles[start:]+roles[:start]
            if i>=3:roles.reverse()
            for role in roles:
                v,_=execute(paths[layout][role],point['runtimeArgs'],counts[role],4,point['expectedStdout'])
                assert v['elapsedMs']>=100
                res['samples'].append(dict(layout=layout,role=role,round=i,count=counts[role],**v))
        checkpoint()
    res['summary']={}
    def rates(layout,role):
        return [x['elapsedMs']/x['count'] for x in res['samples'] if x['role']==role and x['layout']==layout]
    for layout in paths:
        row={}
        for role in ('baseline','permute'):
            ratio=[x/y for x,y in zip(rates(layout,'fused'),rates(layout,role))]
            row[role]=dict(paired=ratio,median=statistics.median(ratio),faster=sum(x<1 for x in ratio))
        row['fusedOverMatureC']=statistics.median(rates(layout,'fused'))/statistics.median(rates('mature','c'))
        res['summary'][layout]=row
    if all(v['baseline']['median']<=0.90 and v['baseline']['faster']>=5 for v in res['summary'].values()):
        cap=HERE/'capture.mjs'
        obs,wall=run([ROOT/'selfhost/.assets/bin/bun',cap,'--out',out/'checked'])
        res['sourceShapes']=dict(script=sha(cap),seconds=wall,evidence=sha(out/'checked/shapes.json'))
    res['complete']=True;checkpoint()
if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);main(a.parse_args().out)
