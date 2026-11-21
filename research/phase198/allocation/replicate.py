"""Independent two-scale BST comparison including a frame-rebasing-only control."""
import argparse
import json
import os
from pathlib import Path
import random
import re
import statistics
import subprocess
import sys
import time
from project import BUILD, EMIT, F, FRAME, HERE, ROOT, RAY, layout, sha, source_root
from shared_rbp import unit
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, execute, read

CASES=['coverage-bst-32','coverage-bst-64']
ROLES=['baseline','rebase','rbp','down-only']
DOWN='p113d_FID_' + ''.join(str(ord(c))+'_' for c in '$product.bst.down')
def ray_variant(src,role):
    def transform(m):
        orig=m[1]
        if role=='baseline': return orig
        full,stats=layout(orig,'rbp')
        if role=='rbp' or full==orig: return full
        selected=set(unit(orig)['offsets'])
        frame=int(FRAME.search(orig)[1])
        def operand(m,op):
            disp=int(m[1])
            if -disp in selected: return '%rbp' if op=='movq' else '%ebp'
            return f'{frame+disp}(%rsp)'
        result=[]
        for l in orig.split('\n'):
            if l=='  movq %rsp, %rbp': continue
            if l=='  movq %rbp, %rsp': l=f'  leaq {frame}(%rsp), %rsp'
            elif '(%rbp)' in l:l=re.sub(r'(-?\d+)\(%rbp\)',lambda m:operand(m,l.split()[0]),l)
            result.append(l)
        return '\n'.join(result)
    return F.sub(transform,src)

def variant(src,role):
    def transform(m):
        orig=m[1]
        if role=='baseline' or role=='down-only' and m[2]!=DOWN: return orig
        full,stats=layout(orig,'rbp')
        if full==orig or role in ('rbp','down-only'): return full
        frame=int(FRAME.search(orig)[1])
        result=[]
        for l in orig.split('\n'):
            if l=='  movq %rsp, %rbp': continue
            if l=='  movq %rbp, %rsp': l=f'  leaq {frame}(%rsp), %rsp'
            elif '(%rbp)' in l:
                l=re.sub(r'(-?\d+)\(%rbp\)',lambda m:f'{frame+int(m[1])}(%rsp)',l)
            result.append(l)
        return '\n'.join(result)
    return F.sub(transform,src)

def spec_for(ray):
    if ray:
        return [RAY],['baseline','rbp','shared'],ray_variant,HERE/'ray-freeze.json'
    return CASES,ROLES,variant,HERE/'replication-freeze.json'

def run(out,ray):
    cases,roles,apply,manifest=spec_for(ray)
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    spec=read(manifest)
    assert sha(Path(__file__))==spec['method'] and sha(HERE/'project.py')==spec['projection'] and sha(HERE/'shared_rbp.py')==spec['sharedModel']
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    assets=read(ASSETS)
    policy=assets['toolchains']['x86']
    asm,link,rt=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    report=dict(complete=False,method=spec['method'],freeze=sha(manifest),cases={})
    start=time.monotonic()
    def save(): (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for i,case in enumerate(cases):
        row=dict(verification=[],timings=[],comparisons={},products={},calibration=[])
        report['cases'][case]=row
        ref=refs[case]
        pt=ref['point']
        origins=spec['cases'][case]
        src=source_root(case)/case/'program.s'
        original=checked_tool(origins['direct'])
        assert sha(src)==origins['source'] and sha(src.with_suffix('.o'))==origins['object']
        products={}
        for lay,flags in [('project',policy['assemblerFlags']),('default',[])]:
            for role in roles:
                k=f'{lay}-{role}'
                d=out/case/k
                d.mkdir(parents=True)
                a,o,e=d/'program.s',d/'program.o',d/'program'
                a.write_text(apply(src.read_text(),role))
                assert sha(a)==origins['variants'][role]
                for cmd in [[asm,*flags,'-o',o,a],[link,*policy['linkerFlags'],o,rt,*policy['libraries'],'-o',e]]:
                    subprocess.run(cmd,check=True,capture_output=True,timeout=15)
                products[k]=e
                row['products'][k]=dict(object=sha(o),binary=sha(e))
        for j,argv in enumerate([pt['runtimeArgs'],[17,3],[59,22]]):
            c=ref['products']['c']
            reps=int(j==0)
            co,expected=execute(checked_tool(c['artifact']),argv,reps,0,pt['expectedStdout'] if j==0 else None,c['runtimeArgumentConvention'])
            row['verification'].append(dict(args=argv,c=co,others={k:execute(e,argv,reps,0,expected)[0] for k,e in [('direct',original),*products.items()]}))
        n=pt['repetitions']//3
        for _ in range(10):
            sample,_=execute(original,pt['runtimeArgs'],n,4,pt['expectedStdout'])
            row['calibration'].append(dict(n=n,**sample))
            if 130<=sample['elapsedMs']<=205: break
            n=max(1,round(n*165/max(1,sample['elapsedMs'])))
        else: raise ValueError('calibration '+case)
        order={lay:list(roles) for lay in ['default','project']}
        rng=random.Random(81723+91*i)
        for shuffler in order.values():rng.shuffle(shuffler)
        for r in range(4):
            for lay in (['default','project'] if (r+i)%2==0 else ['project','default']):
                layout_roles=order[lay]
                offset=r%len(layout_roles)
                for pos,role in enumerate(layout_roles[offset:]+layout_roles[:offset]):
                    val,_=execute(products[f'{lay}-{role}'],pt['runtimeArgs'],n,4,pt['expectedStdout'])
                    row['timings'].append(dict(layout=lay,round=r,position=pos,role=role,count=n,**val))
            save()
        for lay in order:
            def samples(role):return [v['elapsedMs'] for v in row['timings'] if v['layout']==lay and v['role']==role]
            pairs=[('baseline','rbp'),('baseline','shared'),('rbp','shared')] if ray else [('baseline','rebase'),('baseline','rbp'),('rebase','rbp'),('baseline','down-only')]
            for a,b in pairs:
                ratios=[y/x for x,y in zip(samples(a),samples(b))]
                row['comparisons'][f'{lay}:{b}/{a}']=dict(ratios=ratios,median=statistics.median(ratios),faster=sum(v<1 for v in ratios))
        save()
    report.update(complete=True,wall=time.monotonic()-start)
    save()

def freeze(ray):
    cases,roles,apply,manifest=spec_for(ray)
    import hashlib
    direct={r['id']:r for r in read(BUILD/'phase197/combined-build01/report.json')['rows']}
    if ray:direct.update({r['id']:r for r in read(BUILD/'phase198/native45-01/report.json')['rows']})
    result=dict(method=sha(Path(__file__)),projection=sha(HERE/'project.py'),cases={},criteria='For a source prototype, require rbp/baseline <=0.98 with >=3/4 favorable pairs in both layouts at BST64, and improvement over rebase in both layouts. Report BST32 transfer and hot-owner-only outcomes separately. Treat failure as a negative.')
    if ray:result['criteria']='Require shared/baseline median <=0.98 with >=3/4 favorable pairs and shared/rbp <1.0 in both layouts for source prototype.'
    result['sharedModel']=sha(HERE/'shared_rbp.py')
    for c in cases:
        p=source_root(c)/c/'program.s';r=direct[c];receipt=read(checked_tool(r['buildReceipt']))
        assert sha(p.with_suffix('.o'))==receipt['object']['sha256']
        result['cases'][c]=dict(source=sha(p),object=receipt['object']['sha256'],direct=r['artifact'],
            variants={role:hashlib.sha256(apply(p.read_text(),role).encode()).hexdigest() for role in roles})
    manifest.write_text(json.dumps(result,indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path)
    p.add_argument('--freeze',action='store_true')
    p.add_argument('--ray',action='store_true')
    a=p.parse_args()
    freeze(a.ray) if a.freeze else run(a.out,a.ray)
