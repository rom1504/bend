"""Whole-program tests of the complete frozen selection under two assembler layouts."""
import argparse
from pathlib import Path
import math
import os
import random
import statistics
import subprocess

from freeze import BUILD, HERE, ROOT, digest, read, save
from measure import ASSETS, EXTRA, REFERENCES, checked_tool, execute

LAYOUTS=('project','default')


def run(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    result=dict(freeze=digest(HERE/'frozen.json'),script=digest(__file__),model=digest(HERE/'model.json'),cases={},complete=False)
    plan=read(HERE/'frozen.json')
    assert result['freeze']==read(HERE/'model.json')['freeze']
    assets=read(ASSETS)
    policy=assets['toolchains']['x86']
    assembler,linker,runtime=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    for case,pin in plan['profiles'].items():
        src=ROOT/pin['source']
        assert digest(src)==pin['sha']
        base=src.read_text().splitlines()
        targets=[r for r in plan['candidates'] if r['case']==case]
        names=['baseline',*[r['name'] for r in targets]]
        products={'direct':checked_tool(pin['elf'])}
        row=dict(products={},oracles=[],pilots=[],samples=[],cells=[])
        result['cases'][case]=row
        for layout in LAYOUTS:
            flags=policy['assemblerFlags'] if layout=='project' else []
            for role in names:
                lines=base.copy()
                if role!='baseline':
                    candidate=next(r for r in targets if r['name']==role)
                    for site in reversed(candidate['sites']):
                        i=site['line']-1
                        stop=i+len(site['before'])
                        assert [v.strip() for v in lines[i:stop]]==site['before']
                        lines[i:stop]=['  '+v for v in site['after']]
                key=f'{layout}-{role}'
                folder=out/case/key
                folder.mkdir(parents=True)
                asm=folder/'program.s'
                asm.write_text('\n'.join(lines)+'\n')
                assert role!='baseline' or digest(asm)==pin['sha']
                obj,elf=folder/'program.o',folder/'program'
                for cmd in ([assembler,*flags,'-o',obj,asm],[linker,*policy['linkerFlags'],obj,runtime,*policy['libraries'],'-o',elf]):
                    p=subprocess.run(cmd,capture_output=True,timeout=15,check=True)
                    assert not p.stderr
                products[key]=str(elf)
                row['products'][key]=dict(path=str(elf.relative_to(ROOT)),sha=digest(elf),sourceSha=digest(asm),objectSha=digest(obj),assemblerFlags=flags)
        row['products']['direct']=pin['elf']
        ref=refs[case]
        point=ref['point']
        for i,args in enumerate([point['runtimeArgs'],*EXTRA[case]]):
            c=ref['products']['c']
            reps=int(i==0)
            obs,expected=execute(checked_tool(c['artifact']),args,reps,0,point['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            row['oracles'].append(dict(args=args,c=obs,expected=expected,checks={k:execute(path,args,reps,0,expected)[0] for k,path in products.items()}))
        count=point['repetitions']
        for _ in range(10):
            v,_=execute(products['direct'],point['runtimeArgs'],count,4,point['expectedStdout'])
            row['pilots'].append(dict(count=count,**v))
            if 160<=v['elapsedMs']<=300:
                break
            count=max(1,math.ceil(count*210/max(1,v['elapsedMs'])))
        else:
            raise ValueError('Calibration '+case)
        for session in range(2):
            rng=random.Random(19701+19*session)
            perm={}
            for layout in LAYOUTS:
                perm[layout]=names.copy()
                rng.shuffle(perm[layout])
            for ri in range(4):
                layouts=LAYOUTS if (ri+session)%2==0 else reversed(LAYOUTS)
                for layout in layouts:
                    names_order=perm[layout]
                    off=ri%len(names)
                    for pos,role in enumerate(names_order[off:]+names_order[:off]):
                        v,_=execute(products[layout+'-'+role],point['runtimeArgs'],count,4,point['expectedStdout'])
                        assert v['elapsedMs']>=100
                        row['samples'].append(dict(session=session,layout=layout,round=ri,position=pos,role=role,count=count,**v))
                save(out/'diagnostic.json',result)
            for layout in LAYOUTS:
                def times(role):
                    return [x['elapsedMs'] for x in row['samples'] if (x['session'],x['layout'],x['role'])==(session,layout,role)]
                for name in names[1:]:
                    ratios=[b/a for a,b in zip(times('baseline'),times(name))]
                    row['cells'].append(dict(session=session,layout=layout,name=name,median=statistics.median(ratios),faster=sum(v<1 for v in ratios),ratios=ratios))
        for key,path in products.items():
            assert digest(path)==(pin['elf']['sha256'] if key=='direct' else row['products'][key]['sha'])
    result['complete']=True
    save(out/'diagnostic.json',result)


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    run(p.parse_args().out)
