"""Exercise checked Bend frame rewriting and actual direct-object BST products."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time
from project import BUILD, EMIT, F, HERE, ROOT, layout, sha
from replicate import DOWN
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, execute, read

CASES=['coverage-bst-64','coverage-bst-32','coverage-expression-32']
def run(out,api,plan):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    assets=read(ASSETS)
    tools=assets['assets']
    policy=assets['toolchains']['x86']
    asm,link,rt,bun=[checked_tool(tools[k]) for k in ['assembler','linker','qbe-runtime','bun']]
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    base={r['id']:r for r in read(BUILD/'phase198/native45-01/report.json')['rows']}
    report=dict(complete=False,authority=sha(api),preparedEmission=sha(plan),method=sha(Path(__file__)),controls={},cases={})
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def command(args,name):
        p=subprocess.run(args,capture_output=True,timeout=100)
        (out/(name+'.stdout')).write_bytes(p.stdout)
        (out/(name+'.stderr')).write_bytes(p.stderr)
        if p.returncode:
            print(p.stderr.decode(errors='replace')[-2200:],file=sys.stderr)
            raise ValueError(name+' failed')
        return p.stdout.decode()
    start=time.monotonic()
    controls=out/'controls'
    command([bun,HERE/'controls.mjs',api,controls],'controls')
    control_asm=controls/'rendered.o'
    command([asm,*policy['assemblerFlags'],'-o',control_asm,controls/'program.s'],'observer-assemble')
    for route,o in [('direct',controls/'program.o'),('rendered',control_asm)]:
        e=controls/('observer-'+route)
        command([link,'-O2','-fomit-frame-pointer','-no-pie',HERE/'observer.c',o,'-o',e],'observer-link-'+route)
        result=command([e],'observer-run-'+route)
        assert result=='512 complete results and preserved caller RBP\n'
        report['controls'][route]=dict(object=sha(o),binary=sha(e),result=result)
    save()
    driver=ROOT/'selfhost/tests/phase195/prepared-emission/driver.mjs'
    authority=read(plan)
    assert authority['producer']['receipt']['sha256']==sha(api)
    assert [v['id'] for v in authority['cases']]==CASES
    em=out/'emission'
    command([bun,driver,'--plan',plan,'--out',em],'emit')
    built=read(em/'candidate/report.json')
    assert built['complete'] and len(built['rows'])==len(CASES)
    for entry in built['rows']:
        c=entry['id']
        ref=refs[c]
        pt=ref['point']
        row=dict(checks=[],timings=[],comparisons={})
        report['cases'][c]=row
        obj=Path(checked_tool(entry['product']))
        source=Path(checked_tool(entry['assembly']))
        direct=checked_tool(base[c]['artifact'])
        e=obj.with_name('program')
        command([link,*policy['linkerFlags'],obj,rt,*policy['libraries'],'-o',e],'link-'+c)
        row.update(object=sha(obj),candidate=sha(e),baseline=sha(Path(direct)),assembly=sha(source))
        if c.startswith('coverage-bst'):
            baseline=next(m[1] for m in F.finditer((EMIT/c/'program.s').read_text()) if m[2]==DOWN)
            emitted=next(m[1] for m in F.finditer(source.read_text()) if m[2]==DOWN)
            expected=layout(baseline,'rbp')[0]
            row['kernel']=dict(exactProjection=emitted==expected,changed=emitted!=baseline,rbpStore='movq %r10, %rbp' in emitted,rbpLoad='movq %rbp, %r10' in emitted)
        for i,args in enumerate([pt['runtimeArgs'],[0,3],[1,0],[17,22],[59,4294967295]]):
            o=ref['products']['c']
            reps=int(i==0)
            oracle,expected=execute(checked_tool(o['artifact']),args,reps,0,pt['expectedStdout'] if i==0 else None,o['runtimeArgumentConvention'])
            row['checks'].append(dict(args=args,oracle=oracle,out={role:execute(path,args,reps,0,expected)[0] for role,path in [('baseline',direct),('candidate',e)]}))
        save()
        if not c.startswith('coverage-bst') or row['object']==base[c]['object']['sha256']:continue
        n=max(1,pt['repetitions']//4)
        for k in range(10):
            t,_=execute(direct,pt['runtimeArgs'],n,4,pt['expectedStdout'])
            if 130<=t['elapsedMs']<=230:break
            n=max(1,round(n*180/max(1,t['elapsedMs'])))
        else:raise ValueError('calibration '+c)
        for k in range(8):
            order=[('candidate',e),('baseline',direct)]
            if k%4 in [1,2]:order.reverse()
            for pos,(role,exe) in enumerate(order):
                measured,_=execute(exe,pt['runtimeArgs'],n,4,pt['expectedStdout'])
                row['timings'].append(dict(round=k,position=pos,role=role,count=n,**measured))
        def observations(role):return [t['elapsedMs'] for t in row['timings'] if t['role']==role]
        ratio=[a/b for a,b in zip(observations('candidate'),observations('baseline'))]
        row['comparisons']=dict(ratios=ratio,median=statistics.median(ratio),faster=sum(v<1 for v in ratio))
        save()
    report.update(complete=True,wall=time.monotonic()-start)
    save()
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--api',type=Path,required=True)
    p.add_argument('--plan',type=Path,required=True)
    args=p.parse_args()
    run(args.out,args.api,args.plan)
