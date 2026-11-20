"""Collect local model, exact event counts, finite ABI controls, and whole-program timing."""
import argparse
import math
import os
from pathlib import Path
import re
import statistics
import subprocess
import time
from projection import HERE, SYMBOL, LABEL, NEW_LABEL, ROOT, BUILD, digest, read, save, project
from measure import checked_tool, ASSETS, REFERENCES, execute, bench


def command(args):
    p=subprocess.run(args,capture_output=True,timeout=15,check=True)
    assert not p.stderr,(args,p.stderr)
    return p.stdout


def model(out,plan):
    acquisition=read(BUILD/'phase195/hardware-tool01/acquisition.json')
    for pin in [acquisition['tool'],*acquisition['libraries']]:
        assert digest(pin['file'])==pin['sha256']
    rows=[]
    for trace in plan['traces']:
        stats={}
        for role in ['before','after']:
            source=out/f"model-{trace['fuel']}-{role}.s"
            source.write_text('.text\n'+'\n'.join(trace[role])+'\n')
            stdout=command([acquisition['tool']['file'],'-mtriple=x86_64-unknown-linux-gnu',
                            '-mcpu=ivybridge','-iterations=100','-noalias=true',str(source)]).decode()
            source.with_suffix('.stdout').write_text(stdout)
            stats[role]={f:float(re.search('^'+f+r':\s*([\d.]+)',stdout,re.M)[1]) for f in ['Total Cycles','Instructions','Block RThroughput']}
            assert stats[role]['Instructions']==100*len(trace[role])
        rows.append(dict(fuel=trace['fuel'],**stats))
    return rows


def instrument(lines):
    result=lines.copy()
    def after(label,statement):
        i=result.index(label)
        result.insert(i+1,'  '+statement)
    # Every incoming flags value here is dead. Only these separately linked
    # counter variants pay for event collection.
    after(SYMBOL+':','incq p197_calls(%rip)')
    after(LABEL+'_b0:','incq p197_steps(%rip)')
    anchor='  jne '+LABEL+'_b2'
    after(anchor,'incq p197_leaf(%rip)')
    return result


def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    plan=read(HERE/'frozen.json')
    result=dict(freeze=digest(HERE/'frozen.json'),script=digest(__file__),model=model(out,plan),cases={},complete=False)
    save(out/'result.json',result)
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    assets=read(ASSETS)
    as_,cc,rt=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    policy=assets['toolchains']['x86']
    for case in plan['directObjects']:
        d=out/case
        d.mkdir()
        machine=BUILD/'phase195/native45-01'/case/'machine'
        ref=refs[case]
        point=ref['point']
        nat=read(machine/'report.json')
        assert checked_tool(nat['binary']) and checked_tool(nat['object'])==checked_tool(plan['directObjects'][case])
        if case=='coverage-bst-64':
            src=BUILD/'phase195/ctor-gate-emit01/off'/case/'program.s'
            assert digest(src)==plan['sourceSha']
        else:
            cmd=nat['compilerCommand'].copy()
            assert cmd[8]=='x86-object'
            assert all(digest(p['file'])==p['sha256'] for p in nat['inputs'])
            cmd[8]='x86'
            src=d/'current.s'
            src.write_bytes(command(cmd))
        lines=src.read_text().splitlines()
        products={'direct':checked_tool(nat['binary'])}
        counters={}
        row=dict(sourceSha=digest(src),checks=[],boundaries={},counters=[],products={},samples=[],pilots=[],cells=[])
        result['cases'][case]=row
        for variant in [False,True]:
            role='candidate' if variant else 'baseline'
            for layout,flags in [('project',policy['assemblerFlags']),('default',[]),('counts',policy['assemblerFlags'])]:
                shape=project(lines,variant)
                if layout=='counts':
                    shape=instrument(shape)
                key=f'{layout}-{role}'
                asm=d/(key+'.s')
                asm.write_text('\n'.join(shape)+'\n')
                if role=='baseline' and layout!='counts':
                    assert digest(asm)==digest(src)
                obj=d/(key+'.o')
                exe=d/key
                command([as_,*flags,'-o',obj,asm])
                extras=[HERE/'counts.c'] if layout=='counts' else []
                command([cc,*policy['linkerFlags'],obj,rt,*extras,*policy['libraries'],'-o',exe])
                row['products'][key]=dict(path=str(exe.relative_to(ROOT)),sha=digest(exe),objectSha=digest(obj),sourceSha=digest(asm),flags=flags)
                if layout=='project':
                    control=d/(key+'-boundaries')
                    command([cc,*policy['linkerFlags'],'-Wl,--wrap=main',obj,rt,HERE/'boundaries.c',*policy['libraries'],'-o',control])
                    assert command([control])==b'72\n'
                    row['boundaries'][key]=dict(checks=72,sha=digest(control))
                if layout=='counts':
                    counters[role]=exe
                else:
                    products[key]=exe
        for i,args in enumerate([point['runtimeArgs'],[0,17],[1,3],[32,0],[61,123],[64,17]]):
            c=ref['products']['c']
            reps=int(i==0)
            obs,expected=execute(checked_tool(c['artifact']),args,reps,0,point['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            row['checks'].append(dict(args=args,c=obs,oracles={k:execute(p,args,reps,0,expected)[0] for k,p in products.items()}))
            ev={}
            for role,exe in counters.items():
                started=time.monotonic()
                pc=subprocess.run([str(exe),*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),'0','0',*map(str,args)],capture_output=True,check=True,timeout=5)
                bench.observation(pc.stdout,b'',pc.returncode,dict(expectedStdout=expected,repetitions=0,warmups=0),time.monotonic()-started)
                m=re.fullmatch(rb'calls=(\d+) steps=(\d+) leaves=(\d+)\n',pc.stderr)
                assert m
                ev[role]=dict(zip(['calls','steps','leaves'],map(int,m.groups())))
            b,a=ev['baseline'],ev['candidate']
            assert b['calls']==a['calls'] and b['steps']-a['steps']==b['leaves']-a['leaves']>=0
            row['counters'].append(dict(args=args,**ev))
        count=point['repetitions']
        for _ in range(10):
            v,_=execute(products['direct'],point['runtimeArgs'],count,4,point['expectedStdout'])
            row['pilots'].append(dict(count=count,**v))
            if 175<=v['elapsedMs']<=320:
                break
            count=max(1,math.ceil(count*230/max(1,v['elapsedMs'])))
        else:
            raise ValueError('Calibration failed')
        for session in range(2):
            for ri in range(4):
                for layout in (['project','default'] if (ri+session)%2==0 else ['default','project']):
                    roles=['baseline','candidate'] if (ri+session+(layout=='default'))%2==0 else ['candidate','baseline']
                    for role in roles:
                        obs,_=execute(products[layout+'-'+role],point['runtimeArgs'],count,4,point['expectedStdout'])
                        assert obs['elapsedMs']>=80
                        row['samples'].append(dict(session=session,round=ri,layout=layout,role=role,**obs))
                save(out/'result.json',result)
            for layout in ['project','default']:
                def times(role):
                    return [r['elapsedMs'] for r in row['samples'] if (r['session'],r['layout'],r['role'])==(session,layout,role)]
                ratios=[b/a for a,b in zip(times('baseline'),times('candidate'))]
                row['cells'].append(dict(session=session,layout=layout,median=statistics.median(ratios),faster=sum(v<1 for v in ratios),ratios=ratios,count=count))
        save(out/'result.json',result)
    result['complete']=True
    save(out/'result.json',result)


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    main(p.parse_args().out)
