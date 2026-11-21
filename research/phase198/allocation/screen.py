"""Two-layout paired timing and independent C oracles for private frame projections."""
import argparse
import json
import math
import os
from pathlib import Path
import random
import statistics
import subprocess
import sys
import time
from project import BUILD, CASES, EMIT, HERE, ROOT, ROLES, RAY, project, sha, source_root
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, execute, read

def run(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(parents=True)
    start=time.monotonic()
    freeze=read(HERE/'frozen.json')
    assert sha(HERE/'project.py') == freeze['implementation']
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    direct={r['id']:r for r in read(BUILD/'phase197/combined-build01/report.json')['rows']}
    current={r['id']:r for r in read(BUILD/'phase198/native45-01/report.json')['rows']}
    direct[RAY]=current[RAY]
    selected={case:next(r for r in read(source_root(case)/'report.json')['rows'] if r['id']==case) for case in CASES}
    assets=read(ASSETS)
    policy=assets['toolchains']['x86']
    asm,ld,rt=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    report=dict(complete=False,freeze=sha(HERE/'frozen.json'),method=sha(Path(__file__)),
        sources=dict(assets=sha(ASSETS),direct=sha(BUILD/'phase197/combined-build01/report.json'),selected=sha(EMIT/'report.json'),references=sha(REFERENCES)),cases={})
    def save(): (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for ci,case in enumerate(CASES):
        pin=freeze['cases'][case]
        src=ROOT/pin['source']
        assert sha(src) == pin['sourceSha'] == selected[case]['assembly']['sha256']
        assert sha(src.with_suffix('.o')) == pin['objectSha'] == selected[case]['product']['sha256']
        receipt=read(checked_tool(direct[case]['buildReceipt'])) if case!=RAY else direct[case]
        assert pin['objectSha'] == receipt['object']['sha256'] == sha(Path(receipt['object']['file']))
        base=src.read_text()
        ref=refs[case]
        point=ref['point']
        artifact=checked_tool(direct[case]['artifact'])
        row=dict(products={},checks=[],timing=[],comparisons={},calibration=[])
        report['cases'][case]=row
        paths={}
        for layout,flags in [('project',policy['assemblerFlags']),('default',[])]:
            for role in ROLES:
                folder=out/case/(layout+'-'+role)
                folder.mkdir(parents=True)
                source=folder/'program.s'
                obj=folder/'program.o'
                elf=folder/'program'
                source.write_text(project(base,role)[0])
                assert sha(source) == pin['roles'][role]['sha']
                for cmd in [[asm,*flags,'-o',obj,source],[ld,*policy['linkerFlags'],obj,rt,*policy['libraries'],'-o',elf]]:
                    subprocess.run(cmd,check=True,capture_output=True,timeout=12)
                row['products'][folder.name]=dict(binary=sha(elf),object=sha(obj),bytes=obj.stat().st_size)
                paths[folder.name]=elf
        for i,argv in enumerate([point['runtimeArgs'],[1,3],[2,29]]):
            reps=int(i==0)
            c=ref['products']['c']
            oracle,expected=execute(checked_tool(c['artifact']),argv,reps,0,point['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            checks={role:execute(path,argv,reps,0,expected)[0]['stdout'] for role,path in [('direct',artifact),*paths.items()]}
            row['checks'].append(dict(args=argv,oracle=oracle['stdout'],observations=checks))
        n=max(1,point['repetitions']//4)
        for _ in range(8):
            sample,_=execute(artifact,point['runtimeArgs'],n,4,point['expectedStdout'])
            row['calibration'].append(dict(n=n,**sample))
            elapsed=sample['elapsedMs']
            if 125 <= elapsed <= 225:break
            n=max(1,math.ceil(n*165/max(1,elapsed)))
        else: raise RuntimeError('calibration '+case)
        rng=random.Random(198991+ci)
        order={key:list(ROLES) for key in ['project','default']}
        for roles in order.values(): rng.shuffle(roles)
        for k in range(4):
            layouts=['project','default'] if (ci+k)%2==0 else ['default','project']
            for layout in layouts:
                roles=order[layout]
                for j,role in enumerate(roles[k%len(roles):]+roles[:k%len(roles)]):
                    t,_=execute(paths[layout+'-'+role],point['runtimeArgs'],n,4,point['expectedStdout'])
                    row['timing'].append(dict(layout=layout,role=role,round=k,position=j,n=n,**t))
            save()
        for layout in order:
            def samples(role): return [s['elapsedMs'] for s in row['timing'] if s['layout']==layout and s['role']==role]
            row['comparisons'][layout]={}
            for role in ROLES[1:]:
                ratios=[b/a for a,b in zip(samples('baseline'),samples(role))]
                row['comparisons'][layout][role]=dict(ratios=ratios,median=statistics.median(ratios),faster=sum(v<1 for v in ratios))
        save()
    report.update(complete=True,wall=time.monotonic()-start)
    save()
    print(json.dumps({c:r['comparisons'] for c,r in report['cases'].items()}))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    run(p.parse_args().out)
