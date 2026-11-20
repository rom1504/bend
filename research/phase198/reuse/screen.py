"""Measure one frozen actual tree worker transformation, full-result checks included."""
import argparse
import json
import math
import os
import statistics
import subprocess
import sys
from pathlib import Path
from project import BASE, OWNER, ROOT, HERE, project, sha
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import checked_tool, ASSETS, REFERENCES, execute, bench


def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    assets=json.loads(ASSETS.read_text())
    refs={r['id']:r for r in json.loads(REFERENCES.read_text())['cases']}
    ref=refs['tree-bitonic']
    policy=assets['toolchains']['x86']
    as_,cc,rt=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    c=ref['products']['c']
    cexe=checked_tool(c['artifact'])
    point=ref['point']
    res={'source':sha(BASE),'inputs':{p.name:sha(p) for p in [HERE/'project.py',HERE/'screen.py',HERE/'counts.c',HERE/'boundaries.c']},'builds':[],'checks':[],'samples':[],'counts':[]}
    save=lambda:(out/'report.json').write_text(json.dumps(res,indent=2)+'\n')
    src=BASE.read_text()
    def build(role,layout,counts=False,controls=False):
        name=f'{layout}-{role}'
        asm=out/(name+'.s')
        s=project(src,role=='candidate',counts)
        if controls:
            s=s.replace(OWNER+':\n',OWNER+':\n  jmp p198_controls\n.globl p198_subject\np198_subject:\n',1)
        asm.write_text(s)
        obj=out/(name+'.o')
        exe=out/name
        args=[as_,*(policy['assemblerFlags'] if layout!='default' else []),'-o',obj,asm]
        subprocess.run(args,check=True,capture_output=True)
        cmd=[cc,*policy['linkerFlags'],obj,rt,*([HERE/'counts.c'] if counts else []),*([HERE/'boundaries.c'] if controls else []),*policy['libraries'],'-o',exe]
        subprocess.run(cmd,check=True,capture_output=True)
        res['builds'].append(dict(name=name,assembly=sha(asm),object=sha(obj),binary=sha(exe),asmCommand=list(map(str,args)),linkCommand=list(map(str,cmd))))
        return exe
    products={layout:{role:build(role,layout) for role in ('baseline','candidate')} for layout in ('project','default')}
    assert sha(out/'project-baseline.o')==sha(BASE.with_suffix('.o'))
    counted=build('candidate','counts',True)
    controls=build('candidate','controls',True,True)
    save()
    for args in ([8,0],[6,17],[9,123],[0,0],[1,3],[3,7],[5,0],[10,17]):
        n=int(list(args)==point['runtimeArgs'])
        co,expected=execute(cexe,args,n,0,point['expectedStdout'] if n else None,c['runtimeArgumentConvention'])
        obs={layout+'-'+role:execute(exe,args,n,0,expected)[0] for layout,d in products.items() for role,exe in d.items()}
        res['checks'].append(dict(args=args,expected=expected,c=co,observations=obs))
        cmd=[counted,*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'0','0',*map(str,args)]
        p=subprocess.run(cmd,capture_output=True,check=True)
        bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),0)
        entries,hits=map(int,p.stderr.split())
        res['counts'].append(dict(args=args,entries=entries,hits=hits))
        if n:
            p=subprocess.run([controls,*cmd[1:]],capture_output=True)
            (out/'boundaries.stderr').write_bytes(p.stderr)
            assert p.returncode==0 and p.stderr.startswith(b'boundaries='),p.stderr
            bench.observation(p.stdout,b'',p.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),0)
            res['boundaries']=p.stderr.decode()
        save()
    args=point['runtimeArgs']
    n=point['repetitions']
    for i in range(8):
        obs,_=execute(products['project']['baseline'],args,n,5,point['expectedStdout'])
        if 150<=obs['elapsedMs']<=400: break
        n=max(1,math.ceil(n*205/max(1,obs['elapsedMs'])))
    else: raise ValueError('calibration')
    for i in range(6):
        for layout in (('default','project') if i%2 else ('project','default')):
            for role in (('candidate','baseline') if (i+(layout=='project'))%2 else ('baseline','candidate')):
                obs,_=execute(products[layout][role],args,n,5,point['expectedStdout'])
                assert obs['elapsedMs']>=90
                res['samples'].append(dict(layout=layout,role=role,round=i,repetitions=n,**obs))
        save()
    res['summary']={}
    for layout in products:
        cells=[[v['elapsedMs'] for v in res['samples'] if v['layout']==layout and v['role']==role] for role in ('baseline','candidate')]
        ratios=[a/b for b,a in zip(*cells)]
        res['summary'][layout]=dict(ratios=ratios,median=statistics.median(ratios),faster=sum(r<1 for r in ratios))
    res['complete']=True
    save()

if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True)
    main(a.parse_args().out)
